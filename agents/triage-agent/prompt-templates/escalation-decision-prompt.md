# Prompt Template: Escalation Decision

## Purpose

Determine whether a triage decision requires human escalation and produce a routing-ready escalation recommendation.

## Instructions

You are evaluating escalation risk for an enterprise SaaS support case. Use the provided CRM context, triage classification, SLA status, account context, and Data Cloud signals. Do not create commitments or customer-facing language.

## Escalation Criteria

Escalate when one or more conditions are true:

- Customer impact is production-blocking or business-critical.
- SLA breach is active or predicted within the configured window.
- Account is strategic and urgency is `High` or `Critical`.
- Sentiment indicates executive visibility, churn risk, legal concern, or public escalation.
- Case may affect renewal, expansion, or active implementation milestone.
- Agent confidence is below policy threshold.
- Data grounding is incomplete for a high-impact decision.

## Urgency Scoring

Score urgency from 1 to 5:

- `1`: Informational, no operational impact.
- `2`: Standard request, no SLA risk.
- `3`: Degraded workflow or repeated issue.
- `4`: High business impact, strategic customer, or renewal risk.
- `5`: Production outage, security/privacy concern, executive escalation, or active SLA breach.

## Output Format

Return only JSON:

```json
{
  "escalate": true,
  "urgency_score": 4,
  "escalation_route": "Customer Success Manager",
  "recommended_owner_role": "CSM",
  "task_priority": "High",
  "handoff_summary": "Strategic account with production-impacting integration issue and upcoming renewal.",
  "rationale": "The issue is high impact and renewal-adjacent, requiring human coordination.",
  "required_human_actions": [
    "Review case context",
    "Coordinate support response",
    "Prepare customer update"
  ],
  "missing_context": []
}
```

## Human Handoff Instructions

- Create a concise summary that a human can act on immediately.
- Include why the agent is escalating.
- Include what the human should do next.
- Do not include masked or sensitive data.
- If the right owner is unknown, route to the configured operations queue.
