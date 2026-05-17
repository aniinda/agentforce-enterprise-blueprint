# Data Cloud Agent Integration

## Role of Data Cloud

Data Cloud improves agent decision quality by giving Agentforce a resolved, cross-domain view of the customer. Instead of relying only on the triggering Case or Opportunity, agents can use aggregated usage, engagement, support, and health signals.

## Grounding Agent Decisions

Recommended grounding inputs:

- Unified Individual and Unified Account profiles.
- Product usage events and adoption metrics.
- Support interaction history.
- Marketing and customer success engagement.
- Contract and renewal milestones.
- Calculated Insights such as health score, usage trend, open support severity, and sentiment.

Grounding should be scoped to what the agent needs for the decision. More data is not always better. The goal is decision-relevant context, not full customer history.

## Relevant Data Model Objects

Common Data Model Objects for this pattern:

- Account DMO for firmographic and ownership context.
- Contact or Individual DMO for stakeholder context.
- Case or Interaction DMO for support history.
- Opportunity or Sales Order DMO for renewal context.
- Product Usage Event DMO for adoption and engagement.
- Subscription or Contract DMO for term and entitlement context.
- Calculated Insight DMO for health and risk signals.

## Identity Resolution Impact

Identity resolution directly affects agent quality. If product users, CRM contacts, and support requesters are not resolved correctly, the agent may understate adoption, miss executive involvement, or misread repeat issue patterns.

Implementation guidance:

- Define match rules for account domain, CRM Account Id, and external customer identifiers.
- Validate match quality before using insights for automated decisions.
- Expose identity confidence to the agent grounding context.
- Require human review when identity confidence is below threshold for high-impact actions.

## Real-Time Activation Patterns

Activation patterns:

- Scheduled activation for daily renewal risk monitoring.
- Event-triggered activation when usage drops below threshold.
- Case-triggered activation when support sentiment or severity changes.
- Segment activation for accounts entering a renewal watchlist.

Flow should consume activated context as structured fields and pass only relevant values to prompts.

## Zero-Copy Integration Pattern

Where available, use zero-copy integrations to access governed data without unnecessary duplication. This reduces latency, storage overhead, and compliance complexity. Agents should reference trusted calculated insights and CRM identifiers rather than ungoverned replicated datasets.

## Production Controls

- Monitor freshness of calculated insights.
- Include `asOfDate` in grounded context.
- Record data source names in decision audit fields.
- Use fallback behavior when Data Cloud signals are stale or incomplete.
