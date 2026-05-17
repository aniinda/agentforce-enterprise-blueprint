/**
 * Reference implementation for Agentforce invocable actions.
 *
 * Salesforce allows one @InvocableMethod per Apex class, so this class exposes a
 * single bulk-safe dispatcher. Flow and Agentforce pass an actionName plus typed
 * inputs, and the handler returns a structured response for each request.
 *
 * Production implementations should add object/field-level security checks,
 * custom audit persistence, and org-specific routing metadata.
 */
public with sharing class AgentforceActionHandler {
    public static final String ACTION_RETRIEVE_CONTEXT = 'RETRIEVE_CRM_CONTEXT';
    public static final String ACTION_TRIAGE_ROUTE = 'TRIAGE_ROUTE';
    public static final String ACTION_CALCULATE_RENEWAL_SIGNALS = 'CALCULATE_RENEWAL_SIGNALS';
    public static final String ACTION_CREATE_CASE = 'CREATE_CASE';
    public static final String ACTION_CREATE_TASK = 'CREATE_TASK';

    @InvocableMethod(
        label='Agentforce Enterprise Action Handler'
        description='Executes governed CRM actions for Agentforce and Flow.'
    )
    public static List<ActionResponse> execute(List<ActionRequest> requests) {
        List<ActionResponse> responses = new List<ActionResponse>();
        if (requests == null || requests.isEmpty()) {
            return responses;
        }

        Map<Id, Case> casesById = loadCases(requests);
        Map<Id, Account> accountsById = loadAccounts(requests, casesById);
        Map<Id, List<Case>> casesByAccountId = loadRecentCases(accountsById.keySet());
        Map<Id, Opportunity> renewalOppByAccountId = loadRenewalOpportunities(accountsById.keySet());

        List<CaseRequestEnvelope> caseCreates = new List<CaseRequestEnvelope>();
        List<TaskRequestEnvelope> taskCreates = new List<TaskRequestEnvelope>();
        Map<Integer, ActionResponse> deferredResponses = new Map<Integer, ActionResponse>();

        for (Integer i = 0; i < requests.size(); i++) {
            ActionRequest request = requests[i];
            ActionResponse response = new ActionResponse();
            response.success = false;
            response.actionName = request == null ? null : request.actionName;

            try {
                validateRequest(request);

                if (request.actionName == ACTION_RETRIEVE_CONTEXT) {
                    response = retrieveContext(request, casesById, accountsById, casesByAccountId, renewalOppByAccountId);
                } else if (request.actionName == ACTION_TRIAGE_ROUTE) {
                    response = calculateTriageRoute(request);
                } else if (request.actionName == ACTION_CALCULATE_RENEWAL_SIGNALS) {
                    response = calculateRenewalSignals(request, accountsById, casesByAccountId, renewalOppByAccountId);
                } else if (request.actionName == ACTION_CREATE_CASE) {
                    caseCreates.add(new CaseRequestEnvelope(i, request));
                    response.message = 'Case create queued.';
                    deferredResponses.put(i, response);
                } else if (request.actionName == ACTION_CREATE_TASK) {
                    taskCreates.add(new TaskRequestEnvelope(i, request));
                    response.message = 'Task create queued.';
                    deferredResponses.put(i, response);
                } else {
                    throw new AgentforceActionException('Unsupported actionName: ' + request.actionName);
                }
            } catch (Exception ex) {
                response.success = false;
                response.message = ex.getMessage();
            }

            responses.add(response);
        }

        createCases(caseCreates, responses, deferredResponses);
        createTasks(taskCreates, responses, deferredResponses);
        return responses;
    }

    private static void validateRequest(ActionRequest request) {
        if (request == null) {
            throw new AgentforceActionException('Request cannot be null.');
        }
        if (String.isBlank(request.actionName)) {
            throw new AgentforceActionException('actionName is required.');
        }
    }

    private static Map<Id, Case> loadCases(List<ActionRequest> requests) {
        Set<Id> caseIds = new Set<Id>();
        for (ActionRequest request : requests) {
            if (request != null && request.recordId != null && String.valueOf(request.recordId).startsWith('500')) {
                caseIds.add(request.recordId);
            }
            if (request != null && request.caseId != null) {
                caseIds.add(request.caseId);
            }
        }

        if (caseIds.isEmpty()) {
            return new Map<Id, Case>();
        }

        return new Map<Id, Case>([
            SELECT Id, Subject, Description, Priority, Status, Origin, AccountId, ContactId, OwnerId,
                   CreatedDate, IsClosed
            FROM Case
            WHERE Id IN :caseIds
        ]);
    }

    private static Map<Id, Account> loadAccounts(List<ActionRequest> requests, Map<Id, Case> casesById) {
        Set<Id> accountIds = new Set<Id>();
        for (ActionRequest request : requests) {
            if (request == null) {
                continue;
            }
            if (request.accountId != null) {
                accountIds.add(request.accountId);
            }
            if (request.recordId != null && String.valueOf(request.recordId).startsWith('001')) {
                accountIds.add(request.recordId);
            }
            if (request.recordId != null && casesById.containsKey(request.recordId)) {
                accountIds.add(casesById.get(request.recordId).AccountId);
            }
            if (request.caseId != null && casesById.containsKey(request.caseId)) {
                accountIds.add(casesById.get(request.caseId).AccountId);
            }
        }
        accountIds.remove(null);

        if (accountIds.isEmpty()) {
            return new Map<Id, Account>();
        }

        return new Map<Id, Account>([
            SELECT Id, Name, OwnerId, Industry, Type, AnnualRevenue, NumberOfEmployees
            FROM Account
            WHERE Id IN :accountIds
        ]);
    }

    private static Map<Id, List<Case>> loadRecentCases(Set<Id> accountIds) {
        Map<Id, List<Case>> results = new Map<Id, List<Case>>();
        if (accountIds == null || accountIds.isEmpty()) {
            return results;
        }

        for (Case relatedCase : [
            SELECT Id, AccountId, Subject, Priority, Status, CreatedDate, IsClosed
            FROM Case
            WHERE AccountId IN :accountIds
            ORDER BY CreatedDate DESC
            LIMIT 200
        ]) {
            if (!results.containsKey(relatedCase.AccountId)) {
                results.put(relatedCase.AccountId, new List<Case>());
            }
            results.get(relatedCase.AccountId).add(relatedCase);
        }
        return results;
    }

    private static Map<Id, Opportunity> loadRenewalOpportunities(Set<Id> accountIds) {
        Map<Id, Opportunity> results = new Map<Id, Opportunity>();
        if (accountIds == null || accountIds.isEmpty()) {
            return results;
        }

        for (Opportunity opportunity : [
            SELECT Id, AccountId, Name, StageName, Amount, CloseDate, OwnerId, IsClosed
            FROM Opportunity
            WHERE AccountId IN :accountIds
            AND IsClosed = false
            AND CloseDate = NEXT_N_DAYS:180
            ORDER BY CloseDate ASC
            LIMIT 200
        ]) {
            if (!results.containsKey(opportunity.AccountId)) {
                results.put(opportunity.AccountId, opportunity);
            }
        }
        return results;
    }

    private static ActionResponse retrieveContext(
        ActionRequest request,
        Map<Id, Case> casesById,
        Map<Id, Account> accountsById,
        Map<Id, List<Case>> casesByAccountId,
        Map<Id, Opportunity> renewalOppByAccountId
    ) {
        ActionResponse response = baseSuccess(request);
        Case sourceCase = request.caseId == null ? casesById.get(request.recordId) : casesById.get(request.caseId);
        Id accountId = request.accountId;
        if (accountId == null && sourceCase != null) {
            accountId = sourceCase.AccountId;
        }
        if (accountId == null && request.recordId != null && String.valueOf(request.recordId).startsWith('001')) {
            accountId = request.recordId;
        }

        Account account = accountsById.get(accountId);
        if (account == null) {
            throw new AgentforceActionException('No Account context found for request.');
        }

        List<Case> recentCases = casesByAccountId.containsKey(account.Id)
            ? casesByAccountId.get(account.Id)
            : new List<Case>();
        Integer openCaseCount = 0;
        Integer highPriorityOpenCases = 0;
        for (Case relatedCase : recentCases) {
            if (!relatedCase.IsClosed) {
                openCaseCount++;
                if (relatedCase.Priority == 'High') {
                    highPriorityOpenCases++;
                }
            }
        }

        Opportunity renewal = renewalOppByAccountId.get(account.Id);
        response.recordId = account.Id;
        response.recommendedQueue = sourceCase == null ? null : routeBySubject(sourceCase.Subject);
        response.priority = derivePriority(request, account, sourceCase, highPriorityOpenCases);
        response.requiresHumanReview = highPriorityOpenCases > 1 || isStrategic(account);
        response.confidence = response.requiresHumanReview ? 0.78 : 0.9;
        response.message = 'Context retrieved for ' + account.Name + '.';
        response.rationale =
            'Account=' + account.Name +
            '; openCases=' + String.valueOf(openCaseCount) +
            '; highPriorityOpenCases=' + String.valueOf(highPriorityOpenCases) +
            '; renewal=' + (renewal == null ? 'none in next 180 days' : renewal.Name + ' on ' + String.valueOf(renewal.CloseDate)) + '.';
        return response;
    }

    private static ActionResponse calculateTriageRoute(ActionRequest request) {
        ActionResponse response = baseSuccess(request);
        response.priority = String.isBlank(request.priority) ? 'Medium' : request.priority;
        response.recommendedQueue = routeBySubject(
            String.join(new List<String>{ request.subject, request.description, request.productArea }, ' ')
        );
        response.requiresHumanReview =
            request.confidence == null ||
            request.confidence < 0.75 ||
            containsSensitiveSignal(request.description) ||
            response.priority == 'High';
        response.confidence = request.confidence == null ? 0.0 : request.confidence;
        response.rationale = response.requiresHumanReview
            ? 'Routing calculated with human review due to confidence, priority, or sensitive signal.'
            : 'Routing calculated for automated update.';
        response.message = 'Triage route calculated.';
        return response;
    }

    private static ActionResponse calculateRenewalSignals(
        ActionRequest request,
        Map<Id, Account> accountsById,
        Map<Id, List<Case>> casesByAccountId,
        Map<Id, Opportunity> renewalOppByAccountId
    ) {
        Id accountId = request.accountId == null ? request.recordId : request.accountId;
        Account account = accountsById.get(accountId);
        if (account == null) {
            throw new AgentforceActionException('Account is required for renewal signal calculation.');
        }

        List<Case> recentCases = casesByAccountId.containsKey(account.Id)
            ? casesByAccountId.get(account.Id)
            : new List<Case>();
        Integer openHighCases = 0;
        for (Case relatedCase : recentCases) {
            if (!relatedCase.IsClosed && relatedCase.Priority == 'High') {
                openHighCases++;
            }
        }

        Opportunity renewal = renewalOppByAccountId.get(account.Id);
        Integer riskScore = 20;
        if (openHighCases > 0) {
            riskScore += Math.min(30, openHighCases * 15);
        }
        if (isStrategic(account)) {
            riskScore += 15;
        }
        if (renewal != null && renewal.Amount != null && renewal.Amount >= 100000) {
            riskScore += 15;
        }
        if (request.usageTrendPercent != null && request.usageTrendPercent < -10) {
            riskScore += 20;
        }
        riskScore = Math.min(100, riskScore);

        ActionResponse response = baseSuccess(request);
        response.riskScore = riskScore;
        response.riskTier = riskScore >= 70 ? 'High' : riskScore >= 40 ? 'Medium' : 'Low';
        response.requiresHumanReview = response.riskTier == 'High';
        response.confidence = renewal == null ? 0.72 : 0.86;
        response.rationale =
            'Risk score uses open high-priority cases, strategic account status, renewal value, and usage trend.';
        response.message = 'Renewal signals calculated.';
        return response;
    }

    private static void createCases(
        List<CaseRequestEnvelope> envelopes,
        List<ActionResponse> responses,
        Map<Integer, ActionResponse> deferredResponses
    ) {
        if (envelopes.isEmpty()) {
            return;
        }

        List<Case> records = new List<Case>();
        for (CaseRequestEnvelope envelope : envelopes) {
            ActionRequest request = envelope.request;
            records.add(new Case(
                AccountId = request.accountId,
                ContactId = request.contactId,
                Subject = String.isBlank(request.subject) ? 'Agent-created case' : request.subject.left(255),
                Description = request.description,
                Priority = String.isBlank(request.priority) ? 'Medium' : request.priority,
                Origin = String.isBlank(request.origin) ? 'Web' : request.origin
            ));
        }

        Database.SaveResult[] saveResults = Database.insert(records, false);
        for (Integer i = 0; i < saveResults.size(); i++) {
            ActionResponse response = deferredResponses.get(envelopes[i].index);
            if (saveResults[i].isSuccess()) {
                response.success = true;
                response.recordId = saveResults[i].getId();
                response.message = 'Case created.';
            } else {
                response.success = false;
                response.message = firstError(saveResults[i]);
            }
            responses[envelopes[i].index] = response;
        }
    }

    private static void createTasks(
        List<TaskRequestEnvelope> envelopes,
        List<ActionResponse> responses,
        Map<Integer, ActionResponse> deferredResponses
    ) {
        if (envelopes.isEmpty()) {
            return;
        }

        List<Task> records = new List<Task>();
        for (TaskRequestEnvelope envelope : envelopes) {
            ActionRequest request = envelope.request;
            records.add(new Task(
                WhatId = request.recordId,
                OwnerId = request.ownerId == null ? UserInfo.getUserId() : request.ownerId,
                Subject = String.isBlank(request.subject) ? 'Review Agentforce recommendation' : request.subject.left(255),
                Description = request.rationale,
                Priority = String.isBlank(request.priority) ? 'Normal' : request.priority,
                Status = 'Not Started',
                ActivityDate = Date.today().addDays(1)
            ));
        }

        Database.SaveResult[] saveResults = Database.insert(records, false);
        for (Integer i = 0; i < saveResults.size(); i++) {
            ActionResponse response = deferredResponses.get(envelopes[i].index);
            if (saveResults[i].isSuccess()) {
                response.success = true;
                response.recordId = saveResults[i].getId();
                response.message = 'Task created.';
            } else {
                response.success = false;
                response.message = firstError(saveResults[i]);
            }
            responses[envelopes[i].index] = response;
        }
    }

    private static ActionResponse baseSuccess(ActionRequest request) {
        ActionResponse response = new ActionResponse();
        response.success = true;
        response.actionName = request.actionName;
        response.recordId = request.recordId;
        return response;
    }

    private static String firstError(Database.SaveResult result) {
        return result.getErrors().isEmpty() ? 'Unknown DML error.' : result.getErrors()[0].getMessage();
    }

    private static Boolean containsSensitiveSignal(String value) {
        if (String.isBlank(value)) {
            return false;
        }
        String normalized = value.toLowerCase();
        return normalized.contains('legal') ||
            normalized.contains('security') ||
            normalized.contains('privacy') ||
            normalized.contains('breach') ||
            normalized.contains('compensation');
    }

    private static String routeBySubject(String value) {
        if (String.isBlank(value)) {
            return 'Triage Operations';
        }
        String normalized = value.toLowerCase();
        if (normalized.contains('invoice') || normalized.contains('billing') || normalized.contains('contract')) {
            return 'Billing Operations';
        }
        if (normalized.contains('integration') || normalized.contains('sync') || normalized.contains('api')) {
            return 'Integration Support';
        }
        if (normalized.contains('login') || normalized.contains('access') || normalized.contains('permission')) {
            return 'Access Support';
        }
        return 'General Support';
    }

    private static String derivePriority(ActionRequest request, Account account, Case sourceCase, Integer highPriorityOpenCases) {
        if (!String.isBlank(request.priority)) {
            return request.priority;
        }
        if (sourceCase != null && sourceCase.Priority == 'High') {
            return 'High';
        }
        if (highPriorityOpenCases > 0 || isStrategic(account)) {
            return 'High';
        }
        return 'Medium';
    }

    private static Boolean isStrategic(Account account) {
        return account != null && (
            account.Type == 'Customer - Direct' ||
            (account.AnnualRevenue != null && account.AnnualRevenue >= 1000000)
        );
    }

    public class ActionRequest {
        @InvocableVariable(required=true description='Dispatcher action name.')
        public String actionName;

        @InvocableVariable(description='Primary record Id, usually Case or Account.')
        public Id recordId;

        @InvocableVariable(description='Case Id when the action is case-specific.')
        public Id caseId;

        @InvocableVariable(description='Account Id for context, renewal, or case creation.')
        public Id accountId;

        @InvocableVariable(description='Contact Id for case creation.')
        public Id contactId;

        @InvocableVariable(description='Owner Id for human follow-up tasks.')
        public Id ownerId;

        @InvocableVariable(description='Subject for created Case or Task.')
        public String subject;

        @InvocableVariable(description='Description or source text to classify.')
        public String description;

        @InvocableVariable(description='Priority requested by the agent.')
        public String priority;

        @InvocableVariable(description='Case origin for created records.')
        public String origin;

        @InvocableVariable(description='Product area inferred by the agent.')
        public String productArea;

        @InvocableVariable(description='Agent confidence from 0 to 1.')
        public Decimal confidence;

        @InvocableVariable(description='Usage trend percentage for renewal scoring.')
        public Decimal usageTrendPercent;

        @InvocableVariable(description='Agent rationale to persist on human task.')
        public String rationale;
    }

    public class ActionResponse {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String actionName;
        @InvocableVariable public Id recordId;
        @InvocableVariable public String message;
        @InvocableVariable public String rationale;
        @InvocableVariable public String recommendedQueue;
        @InvocableVariable public String priority;
        @InvocableVariable public Boolean requiresHumanReview;
        @InvocableVariable public Decimal confidence;
        @InvocableVariable public Integer riskScore;
        @InvocableVariable public String riskTier;
    }

    private class CaseRequestEnvelope {
        Integer index;
        ActionRequest request;

        CaseRequestEnvelope(Integer index, ActionRequest request) {
            this.index = index;
            this.request = request;
        }
    }

    private class TaskRequestEnvelope {
        Integer index;
        ActionRequest request;

        TaskRequestEnvelope(Integer index, ActionRequest request) {
            this.index = index;
            this.request = request;
        }
    }

    private class AgentforceActionException extends Exception {}
}
