# Renewal Agent Specification

## Purpose

The Renewal Agent monitors subscription health, detects renewal risk, recommends next-best actions, and prepares human-reviewed outreach for customer success and revenue teams.

## Scope

In scope:

- Renewal risk scoring for accounts with active contracts or renewal opportunities.
- Monitoring usage, engagement, support, and sentiment signals.
- Creating follow-up tasks for CSMs and account owners.
- Updating renewal health summaries and recommended next actions.
- Generating draft outreach and talk tracks for human review.

Out of scope:

- Autonomous price negotiation.
- Contract redlining or legal approvals.
- Sending renewal outreach without approval.
- Forecast changes without sales owner review.
- Customer commitments that require commercial approval.

## Subscription Health Signals

- Product usage trend and active user adoption.
- Executive engagement and meeting recency.
- Open support case count and severity.
- NPS or sentiment trend.
- Implementation milestone status.
- Renewal date proximity and contract value.
- Prior renewal risk history.

## Proactive Outreach Triggers

- Renewal date within 120 days and health score is declining.
- Usage decline greater than configured threshold.
- Multiple high-priority cases in current quarter.
- Negative sentiment or executive escalation.
- Low engagement from business owner.
- Expansion or value realization milestone missed.

## Workflow Orchestration

The Renewal Agent runs from scheduled Flow, record-triggered Flow, or Data Cloud activation. It calculates signals, applies risk scoring, recommends a tier, and sends structured output to Flow.

Flow then:

- Updates account health summary fields.
- Updates renewal opportunity risk fields.
- Creates CSM or account owner tasks.
- Stores outreach drafts as internal notes or activity records.
- Routes high-risk accounts to human review.

## Performance Targets

- Risk tier agreement with human review: 85% or higher.
- High-risk account detection recall: 90% or higher.
- False-positive high-risk rate: below 15%.
- Outreach draft approval rate: 80% or higher after human edit.
- Renewal decision cycle time reduction: 35% or higher.
