# Agent Topology Overview

## Design Principles

The topology uses two specialized agents instead of one unified agent:

- The Triage Agent optimizes for fast, accurate interpretation of inbound operational work.
- The Renewal Agent optimizes for longitudinal account health assessment and proactive orchestration.

Separating the agents improves prompt focus, action boundaries, testing precision, and governance. Each agent has its own topics, confidence thresholds, escalation policy, and performance targets. This avoids a broad agent that can answer many questions but is harder to validate in production.

## Why Two Agents Instead of One

A unified agent would share a single topic model across support triage, customer health, outreach generation, and renewal orchestration. That creates avoidable ambiguity. A routing decision for an urgent support case and a renewal risk decision use different signals, decision windows, and human approvers.

The two-agent model creates clean ownership:

- Triage decisions are owned by support operations and service leadership.
- Renewal decisions are owned by customer success and revenue leadership.
- Shared CRM actions are exposed through common Apex and Flow contracts.
- Cross-agent handoff occurs only through explicit CRM records and Flow events.

## Human-in-the-Loop Patterns

The agents do not bypass humans for high-risk decisions. Human review is required when:

- Confidence is below the configured threshold.
- The account is strategic, executive-sponsored, or flagged for legal sensitivity.
- The recommended action changes commercial terms or customer commitments.
- A customer sentiment signal indicates high dissatisfaction.
- Data grounding is incomplete or contradictory.

Human handoff is implemented through Case ownership changes, Task creation, Slack or email notifications, and CRM fields that capture the agent recommendation, confidence, rationale, and next action.

## Trust Layer Configuration Approach

The Trust Layer is configured to protect customer data before prompt execution and response persistence.

Controls include:

- Data masking for personally identifiable information and sensitive free text.
- Toxicity detection for inbound customer language and generated outreach.
- Audit capture for prompt input, grounding references, action selection, and final response.
- Role-based access to agent topics and actions.
- Grounded response requirements for business-critical decisions.

The agent should never rely on ungrounded assumptions when updating CRM records. If required data is unavailable, the agent should request a deterministic action that retrieves context or escalate to a human.

## Data Grounding Strategy

Agents are grounded through a combination of CRM records and Data Cloud calculated insights.

Typical grounding inputs:

- Account tier, lifecycle stage, owner, region, entitlement status, and strategic flag.
- Case severity, open case count, historical case pattern, SLA status, and product area.
- Opportunity and renewal context including renewal date, amount, stage, and forecast category.
- Usage trend, adoption score, executive engagement, support sentiment, and health score.

Data Cloud resolves identity and aggregates product, engagement, support, and contract signals into reusable context. Apex retrieves record-specific CRM context when a Flow or agent action needs deterministic access.

## Action Design Patterns

A good agent action is narrow, typed, auditable, and reversible where possible.

Action rules:

- Accept explicit input parameters instead of free-form blobs.
- Return structured output with status, confidence, rationale, and record references.
- Perform CRUD/FLS checks in production implementations.
- Handle bulk input because Flow and invocable actions can receive lists.
- Avoid irreversible side effects unless a human approval step exists.
- Persist decision context for audit and replay.

This repository uses a single Apex handler to demonstrate reusable action contracts. A production implementation may split actions by bounded domain.

## Agent Handoff Patterns

Agent-to-agent handoff is indirect. The Triage Agent does not call the Renewal Agent directly. Instead, it updates CRM state and emits a Flow-visible signal when a support issue may affect renewal risk. The Renewal Agent then evaluates account health through its own workflow.

Handoff examples:

- Triage Agent identifies renewal-impacting case and updates Case escalation reason.
- Flow creates a Customer Success Task.
- Renewal Agent includes the new case pattern in the next risk evaluation.
- Human owner receives a task with agent rationale and recommended next step.

## Failure Modes and Fallback Design

Expected failure modes:

- Missing or stale account context.
- Conflicting health signals across CRM and Data Cloud.
- Low confidence classification.
- Action failure caused by validation rules or permissions.
- Prompt output that does not match the expected schema.

Fallback patterns:

- Retry deterministic context retrieval before asking the agent to decide.
- Route ambiguous records to a human operations queue.
- Persist failure details on a task or monitoring object.
- Use Flow fault paths for notification and recovery.
- Prevent agent-generated outreach from sending automatically when compliance checks fail.

## Governance and Audit Trail

Every production agent decision should leave an audit trail:

- Input record identifiers.
- Grounding data sources used.
- Prompt template version.
- Agent confidence and rationale.
- Selected action and action output.
- Human override or approval result.
- Timestamp and running user context.

Audit data supports compliance, prompt regression testing, leadership reporting, and continuous improvement.
