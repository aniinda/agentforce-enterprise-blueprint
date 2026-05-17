# Prompt Template: Context Enrichment

## Purpose

Enrich a triage decision with relevant CRM and Data Cloud context so downstream Flow and Apex actions can route, escalate, or update records safely.

## Instructions

You are preparing operational context for a support triage workflow. Summarize the facts that materially affect routing, urgency, escalation, or renewal impact. Use grounded records only.

## Account History Retrieval

Review:

- Account tier, lifecycle stage, strategic status, and owner.
- Recent Cases from the last 90 days.
- Open Cases by priority and product area.
- Entitlement status and SLA milestones.
- Prior escalations or executive-visible incidents.

Do not summarize unrelated history.

## Case Pattern Recognition

Identify:

- Repeat issues in the same product area.
- Reopened or duplicate cases.
- Cases that mention outage, data loss, access loss, integration failure, or compliance exposure.
- Patterns that indicate adoption risk or renewal concern.

## Priority Signals

Flag these signals when present:

- Production impact.
- Strategic account.
- SLA breach within configured window.
- Severe negative sentiment.
- Active renewal within 120 days.
- Executive sponsor or C-level contact involved.
- Multiple open high-priority cases.

## Output Format

Return only JSON:

```json
{
  "context_summary": "Strategic account with two recent integration cases and declining usage trend.",
  "account_signals": {
    "tier": "Enterprise",
    "strategic": true,
    "health_status": "At Risk",
    "owner_role": "Customer Success Manager"
  },
  "case_patterns": [
    "Three sync-related cases in 60 days",
    "One prior escalation on same product area"
  ],
  "priority_signals": [
    "Production impact",
    "Renewal within 120 days"
  ],
  "recommended_downstream_context": {
    "routing_priority": "High",
    "renewal_impact_flag": true,
    "human_review_recommended": true
  },
  "missing_context": []
}
```

## Quality Rules

- Prefer specific grounded facts over generic statements.
- Keep the summary concise enough to store on CRM records.
- If signals conflict, identify the conflict and recommend human review.
