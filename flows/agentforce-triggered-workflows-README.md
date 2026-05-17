# Agentforce Triggered Workflows

## Overview

This guide describes the Flow orchestration patterns used by the Triage Agent and Renewal Agent. Agentforce handles contextual reasoning. Flow handles deterministic orchestration. Apex handles reusable record actions and calculations.

## Triage Agent Workflow

Trigger: Case created or materially updated.

Entry criteria:

- Case status is not closed.
- Case has subject or description.
- Case has not exceeded the configured maximum automated agent updates.

Steps:

1. Start from a record-triggered Flow on Case.
2. Retrieve Account, Contact, Entitlement, and recent Case records.
3. Invoke `Retrieve CRM Context` Apex action for a structured grounding summary.
4. Call the Context Enrichment prompt.
5. Call the Triage Classification prompt.
6. Evaluate confidence and sensitivity thresholds.
7. If confidence is high and policy allows automation, update Case routing fields.
8. If escalation is required, call the Escalation Decision prompt.
9. Create a human follow-up Task when required.
10. Persist agent rationale, classification, confidence, and timestamp.

Decision logic:

- Confidence below 0.75 routes to Triage Operations.
- Critical severity with confidence below 0.90 requires human review.
- Strategic account plus high urgency creates a CSM follow-up task.
- Renewal impact creates a CSM task and updates renewal-impact fields.

Record update patterns:

- Keep agent rationale concise and auditable.
- Store prompt version and confidence in dedicated fields where possible.
- Avoid repeatedly overwriting human-owned fields after a human takes ownership.
- Use Flow fault paths to create an operations task when updates fail.

Notification patterns:

- Notify support manager for critical operational impact.
- Notify CSM for renewal-impacting support issues.
- Notify operations queue for ambiguous or failed automation.

## Renewal Agent Workflow

Trigger: Scheduled Flow, renewal Opportunity update, or Data Cloud activation.

Entry criteria:

- Account has active Contract or renewal Opportunity.
- Renewal is within configured monitoring horizon.
- Account has sufficient grounding context or requires human review.

Steps:

1. Start from scheduled Flow or record-triggered Flow.
2. Retrieve Account, Contract, Opportunity, Case, and Data Cloud signal context.
3. Invoke `Calculate Renewal Signals` Apex action.
4. Call Renewal Risk Scoring prompt.
5. Evaluate risk tier and confidence.
6. Update Account and Opportunity health fields.
7. For High risk, create CSM task and generate outreach draft.
8. For Medium risk, enroll in success playbook or create monitoring task.
9. For Low risk, update health summary and continue scheduled monitoring.
10. Store score, rationale, driver summary, and prompt version.

Decision logic:

- High risk always requires human review.
- Medium risk creates task when renewal is within 90 days.
- Low risk updates records only.
- Missing contract value or renewal date lowers confidence and creates review task.

## Recreate the Triage Flow

1. Create a Case record-triggered Flow.
2. Add Get Records for Case, Account, Contact, Entitlement, open Cases, and renewal Opportunity.
3. Add Apex Action: `retrieveCrmContext`.
4. Add Agentforce prompt action for context enrichment.
5. Add Agentforce prompt action for classification.
6. Add Decision: confidence and sensitivity policy.
7. Add Update Records for Case route, priority, status, and agent rationale.
8. Add Apex Action: `createHumanFollowUpTasks` for escalation.
9. Add fault connectors to create an operations Task.
10. Activate with a bypass custom permission for administrators.

## Recreate the Renewal Flow

1. Create a scheduled-triggered Flow that runs daily.
2. Query renewal Opportunities closing in the next 120 days.
3. Get related Account, Contract, Cases, and engagement signal records.
4. Add Apex Action: `calculateRenewalSignals`.
5. Add Agentforce prompt action for risk scoring.
6. Add Decision: High, Medium, Low risk.
7. Add Update Records for Account and Opportunity health fields.
8. Add Agentforce prompt action for outreach draft for High risk only.
9. Add Apex Action: `createHumanFollowUpTasks`.
10. Activate monitoring dashboards for task completion and risk movement.
