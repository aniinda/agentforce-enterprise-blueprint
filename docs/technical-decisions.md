# Architecture Decision Records

## Decision 1: Two Agents vs One Unified Agent

Status: Accepted

Decision: Use a Triage Agent and a Renewal Agent.

Rationale: Triage and renewal decisions use different signals, owners, thresholds, and compliance constraints. Separate agents improve topic precision, testing, governance, and operational ownership.

Consequences: Shared actions must be reusable, and handoff must occur through CRM records and Flow rather than direct agent-to-agent calls.

## Decision 2: Prompt Builder vs Custom LLM Prompts

Status: Accepted

Decision: Use Prompt Builder templates managed inside Salesforce.

Rationale: Prompt Builder provides admin visibility, grounding controls, versioning patterns, and Trust Layer integration. Custom prompts outside Salesforce increase integration burden and governance risk.

Consequences: Prompt templates must enforce structured output and regression testing before activation.

## Decision 3: Flow vs Apex for Agent Actions

Status: Accepted

Decision: Use Flow for orchestration and Apex for reusable typed actions.

Rationale: Flow is best for record-triggered orchestration, notifications, decisions, and admin visibility. Apex is best for reusable logic, bulk behavior, structured DTOs, and testable calculations.

Consequences: Apex actions must remain narrow and Flow-friendly. Flow owns process order and fault handling.

## Decision 4: Data Cloud Grounding vs Direct SOQL

Status: Accepted

Decision: Use Data Cloud for aggregated cross-domain signals and direct SOQL/Apex for record-specific transactional context.

Rationale: Data Cloud provides identity resolution and calculated insights that are not practical to recreate with direct SOQL. Apex retrieval remains appropriate for current Case, Account, and Task operations.

Consequences: Prompt grounding must include data freshness and missing-context handling.

## Decision 5: Escalation Thresholds and Human-in-the-Loop Design

Status: Accepted

Decision: Require human review for low confidence, high risk, strategic accounts, sensitive topics, and commercial commitments.

Rationale: Production agents should accelerate decisions without removing accountability from high-impact judgment calls.

Consequences: The system must capture rationale, owner, task status, and override reason for audit and continuous improvement.
