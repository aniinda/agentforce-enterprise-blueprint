# Triage Agent Topics and Actions

## Topics

### 1. Case Classification

Description: Determines the customer intent, product area, operational category, and recommended support queue.

Example utterances:

- "The integration stopped syncing after the latest release."
- "I need help understanding my invoice."
- "Our admin cannot access the workspace."

Classification logic:

- Use the case subject and description as primary signals.
- Use product, entitlement, and historical case patterns as secondary signals.
- Return `Human Review Required` when intent is ambiguous or conflicting.

### 2. SLA and Escalation Risk

Description: Detects whether a case is urgent, likely to breach SLA, or requires immediate human attention.

Example utterances:

- "This is blocking our go-live tomorrow."
- "Our executive team is asking for updates."
- "We have a production outage."

Classification logic:

- Escalate when impact is production-blocking, executive-visible, security-sensitive, or near SLA breach.
- Increase priority when a strategic account has multiple open high-priority cases.

### 3. Account Context Enrichment

Description: Summarizes relevant account history and operational context for routing and human review.

Example utterances:

- "Summarize what matters about this customer before routing."
- "Has this account had similar issues?"

Classification logic:

- Retrieve recent case history, account tier, health score, owner, and entitlement context.
- Highlight only signals that change routing, urgency, or next action.

### 4. Renewal Impact Detection

Description: Determines whether a support issue may affect an active or upcoming renewal.

Example utterances:

- "This outage is making us reconsider renewal."
- "We need this fixed before contract discussions."

Classification logic:

- Flag if renewal date is within the configured window and the issue affects adoption, trust, executive sentiment, or value realization.

### 5. Human Review Required

Description: Catches low-confidence, sensitive, or policy-constrained decisions.

Example utterances:

- "I want compensation for this incident."
- "This involves customer data exposure."

Classification logic:

- Route to human when the agent lacks enough grounded context or the requested action requires judgment outside approved automation.

## Actions

### Retrieve CRM Context

Description: Gets account, case, and renewal context for grounding.

Input parameters:

- `recordId`: Case or Account Id.
- `includeRenewalSignals`: Boolean.

Output:

- Structured context summary.
- Account tier, owner, open case count, renewal date, and health indicators.

Backing:

- Apex: `AgentforceActionHandler.retrieveCrmContext`.

### Classify Triage Route

Description: Converts agent classification into a route recommendation.

Input parameters:

- `caseId`
- `topic`
- `confidence`
- `productArea`
- `urgency`

Output:

- Recommended queue.
- Priority.
- Escalation flag.

Backing:

- Flow decision element plus Apex support logic.

### Calculate Routing Priority

Description: Applies deterministic priority rules after agent classification.

Input parameters:

- `accountTier`
- `sentimentScore`
- `slaHoursRemaining`
- `businessImpact`

Output:

- Priority value and rationale.

Backing:

- Flow formula and Apex helper.

### Create Escalation Task

Description: Creates a Task for the support owner, CSM, or operations queue.

Input parameters:

- `relatedRecordId`
- `ownerId`
- `subject`
- `rationale`
- `priority`

Output:

- Created Task Id.

Backing:

- Apex: `AgentforceActionHandler.createHumanFollowUpTasks`.

### Create Case From Agent Decision

Description: Creates a Case when a conversation or signal requires formal tracking.

Input parameters:

- `accountId`
- `contactId`
- `subject`
- `description`
- `priority`
- `origin`

Output:

- Created Case Id.

Backing:

- Apex: `AgentforceActionHandler.createCasesFromAgentDecisions`.

### Update Case Routing Fields

Description: Updates queue, priority, product area, and agent rationale fields.

Input parameters:

- `caseId`
- `priority`
- `status`
- `reason`
- `rationale`

Output:

- Update status and message.

Backing:

- Flow record update with Apex validation helper.

### Flag Renewal Impact

Description: Marks a case as renewal-impacting and creates a CSM follow-up.

Input parameters:

- `caseId`
- `accountId`
- `renewalOpportunityId`
- `impactReason`

Output:

- Flag status and task Id.

Backing:

- Flow update plus Apex task creation.
