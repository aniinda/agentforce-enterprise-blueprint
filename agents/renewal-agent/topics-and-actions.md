# Renewal Agent Topics and Actions

## Topics

### Renewal Risk Monitoring

Description: Scores account renewal risk using usage, support, engagement, and commercial signals.

Example utterances:

- "Score this account's renewal risk."
- "Why did this renewal become high risk?"

Logic:

- Weight usage and engagement highest for product-led accounts.
- Weight support severity and sentiment highest for strategic accounts.
- Require human review for high contract value accounts.

### Proactive Outreach

Description: Generates internal outreach drafts and talk tracks for CSM review.

Example utterances:

- "Draft a renewal risk outreach email."
- "Prepare a CSM call talk track."

Logic:

- Use grounded context.
- Keep tone consultative and specific.
- Never promise discounts, roadmap delivery, or support resolution dates.

### Health Summary Update

Description: Produces CRM-ready health summaries for account and opportunity records.

Example utterances:

- "Summarize the renewal health drivers."
- "Update the opportunity risk reason."

Logic:

- Include only decision-relevant signals.
- Identify positive and negative drivers.

### Human Intervention Required

Description: Routes sensitive or high-value renewal decisions to account teams.

Example utterances:

- "Should this be escalated to leadership?"
- "Does this require CSM follow-up?"

Logic:

- Escalate high-risk, high-value, executive-visible, or compliance-sensitive renewals.

## Actions

### Calculate Renewal Signals

Input:

- `accountId`
- `renewalOpportunityId`
- `asOfDate`

Output:

- Health score, usage trend, support risk, engagement risk, and contract risk.

Backing:

- Apex: `AgentforceActionHandler.calculateRenewalSignals`.

### Create Human Follow-up Task

Input:

- `relatedRecordId`
- `ownerId`
- `subject`
- `rationale`
- `priority`

Output:

- Task Id and status.

Backing:

- Apex: `AgentforceActionHandler.createHumanFollowUpTasks`.

### Update Renewal Health Fields

Input:

- `accountId`
- `riskTier`
- `riskSummary`
- `nextAction`

Output:

- Update status.

Backing:

- Flow record update.

### Save Outreach Draft

Input:

- `accountId`
- `subject`
- `emailBody`
- `talkTrack`

Output:

- Activity or note reference.

Backing:

- Flow create record.

### Escalate Renewal Risk

Input:

- `accountId`
- `opportunityId`
- `riskTier`
- `rationale`

Output:

- Escalation task and notification status.

Backing:

- Flow and Apex task action.

### Refresh Data Cloud Context

Input:

- `accountId`

Output:

- Most recent calculated insights and identity status.

Backing:

- Data Cloud activation plus Flow.
