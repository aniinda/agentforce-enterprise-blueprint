@IsTest
private class AgentforceActionHandlerTest {
    @TestSetup
    static void setupData() {
        Account account = new Account(
            Name = 'Generic SaaS Customer',
            Type = 'Customer - Direct',
            Industry = 'Technology',
            AnnualRevenue = 1500000
        );
        insert account;

        Contact contact = new Contact(
            LastName = 'Customer',
            Email = 'customer@example.com',
            AccountId = account.Id
        );
        insert contact;

        insert new Case(
            AccountId = account.Id,
            ContactId = contact.Id,
            Subject = 'Integration sync failing',
            Description = 'Production integration sync is failing for all users.',
            Priority = 'High',
            Origin = 'Web',
            Status = 'New'
        );

        insert new Opportunity(
            AccountId = account.Id,
            Name = 'Generic SaaS Renewal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(60),
            Amount = 250000
        );
    }

    @IsTest
    static void retrievesCrmContext() {
        Case sourceCase = [SELECT Id, AccountId FROM Case LIMIT 1];

        AgentforceActionHandler.ActionRequest request = new AgentforceActionHandler.ActionRequest();
        request.actionName = AgentforceActionHandler.ACTION_RETRIEVE_CONTEXT;
        request.recordId = sourceCase.Id;

        Test.startTest();
        List<AgentforceActionHandler.ActionResponse> responses =
            AgentforceActionHandler.execute(new List<AgentforceActionHandler.ActionRequest>{ request });
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].success);
        System.assertEquals(sourceCase.AccountId, responses[0].recordId);
        System.assertEquals('Integration Support', responses[0].recommendedQueue);
        System.assertEquals(true, responses[0].requiresHumanReview);
    }

    @IsTest
    static void calculatesTriageRoutePositiveAndSensitive() {
        AgentforceActionHandler.ActionRequest standard = new AgentforceActionHandler.ActionRequest();
        standard.actionName = AgentforceActionHandler.ACTION_TRIAGE_ROUTE;
        standard.subject = 'API sync delay';
        standard.description = 'Data is delayed for one workflow.';
        standard.confidence = 0.91;
        standard.priority = 'Medium';

        AgentforceActionHandler.ActionRequest sensitive = new AgentforceActionHandler.ActionRequest();
        sensitive.actionName = AgentforceActionHandler.ACTION_TRIAGE_ROUTE;
        sensitive.subject = 'Access concern';
        sensitive.description = 'Customer mentions privacy concern and legal review.';
        sensitive.confidence = 0.92;
        sensitive.priority = 'Medium';

        Test.startTest();
        List<AgentforceActionHandler.ActionResponse> responses =
            AgentforceActionHandler.execute(new List<AgentforceActionHandler.ActionRequest>{ standard, sensitive });
        Test.stopTest();

        System.assertEquals(false, responses[0].requiresHumanReview);
        System.assertEquals('Integration Support', responses[0].recommendedQueue);
        System.assertEquals(true, responses[1].requiresHumanReview);
    }

    @IsTest
    static void calculatesRenewalSignals() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        AgentforceActionHandler.ActionRequest request = new AgentforceActionHandler.ActionRequest();
        request.actionName = AgentforceActionHandler.ACTION_CALCULATE_RENEWAL_SIGNALS;
        request.accountId = account.Id;
        request.usageTrendPercent = -25;

        Test.startTest();
        List<AgentforceActionHandler.ActionResponse> responses =
            AgentforceActionHandler.execute(new List<AgentforceActionHandler.ActionRequest>{ request });
        Test.stopTest();

        System.assertEquals(true, responses[0].success);
        System.assertEquals('High', responses[0].riskTier);
        System.assert(responses[0].riskScore >= 70);
        System.assertEquals(true, responses[0].requiresHumanReview);
    }

    @IsTest
    static void createsCaseFromAgentDecision() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];

        AgentforceActionHandler.ActionRequest request = new AgentforceActionHandler.ActionRequest();
        request.actionName = AgentforceActionHandler.ACTION_CREATE_CASE;
        request.accountId = account.Id;
        request.contactId = contact.Id;
        request.subject = 'Agent detected support issue';
        request.description = 'Created from a governed Agentforce decision.';
        request.priority = 'High';
        request.origin = 'Web';

        Test.startTest();
        List<AgentforceActionHandler.ActionResponse> responses =
            AgentforceActionHandler.execute(new List<AgentforceActionHandler.ActionRequest>{ request });
        Test.stopTest();

        System.assertEquals(true, responses[0].success);
        System.assertNotEquals(null, responses[0].recordId);
        Case createdCase = [SELECT Subject, Origin FROM Case WHERE Id = :responses[0].recordId];
        System.assertEquals('Agent detected support issue', createdCase.Subject);
        System.assertEquals('Web', createdCase.Origin);
    }

    @IsTest
    static void createsHumanFollowUpTask() {
        Account account = [SELECT Id FROM Account LIMIT 1];

        AgentforceActionHandler.ActionRequest request = new AgentforceActionHandler.ActionRequest();
        request.actionName = AgentforceActionHandler.ACTION_CREATE_TASK;
        request.recordId = account.Id;
        request.ownerId = UserInfo.getUserId();
        request.subject = 'Review high-risk renewal';
        request.rationale = 'Agent identified renewal risk from support and usage signals.';
        request.priority = 'High';

        Test.startTest();
        List<AgentforceActionHandler.ActionResponse> responses =
            AgentforceActionHandler.execute(new List<AgentforceActionHandler.ActionRequest>{ request });
        Test.stopTest();

        System.assertEquals(true, responses[0].success);
        Task createdTask = [SELECT Subject, Priority, WhatId FROM Task WHERE Id = :responses[0].recordId];
        System.assertEquals('Review high-risk renewal', createdTask.Subject);
        System.assertEquals('High', createdTask.Priority);
        System.assertEquals(account.Id, createdTask.WhatId);
    }

    @IsTest
    static void handlesNegativeScenarios() {
        AgentforceActionHandler.ActionRequest missingAction = new AgentforceActionHandler.ActionRequest();

        AgentforceActionHandler.ActionRequest unsupported = new AgentforceActionHandler.ActionRequest();
        unsupported.actionName = 'DOES_NOT_EXIST';

        AgentforceActionHandler.ActionRequest missingAccount = new AgentforceActionHandler.ActionRequest();
        missingAccount.actionName = AgentforceActionHandler.ACTION_CALCULATE_RENEWAL_SIGNALS;

        Test.startTest();
        List<AgentforceActionHandler.ActionResponse> responses =
            AgentforceActionHandler.execute(new List<AgentforceActionHandler.ActionRequest>{
                missingAction,
                unsupported,
                missingAccount
            });
        Test.stopTest();

        System.assertEquals(false, responses[0].success);
        System.assert(responses[0].message.contains('actionName is required'));
        System.assertEquals(false, responses[1].success);
        System.assert(responses[1].message.contains('Unsupported actionName'));
        System.assertEquals(false, responses[2].success);
        System.assert(responses[2].message.contains('Account is required'));
    }
}
