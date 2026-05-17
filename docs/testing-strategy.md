# Agent Testing Strategy

## Objectives

Testing must prove that the agents are accurate, safe, measurable, and stable across prompt changes. The strategy combines Agentforce Testing Center, Apex tests, Flow path validation, prompt regression suites, and production monitoring.

## Agentforce Testing Center

Use Testing Center to:

- Define synthetic cases and renewal scenarios.
- Validate topic classification.
- Compare expected and actual agent actions.
- Track confidence distribution.
- Regression test prompt template versions.

Test sets should include normal, ambiguous, high-risk, and policy-restricted scenarios.

## Synthetic Scenario Design

Triage scenarios:

- Standard technical support request.
- Production outage from strategic account.
- Billing request misclassified as support.
- Low-context ambiguous message.
- Renewal-impacting support issue.
- Security or privacy-sensitive request.

Renewal scenarios:

- Healthy renewal with strong adoption.
- High-value account with declining usage.
- Medium-risk account with stale engagement.
- High-risk account with multiple severe support cases.
- Missing renewal date or contract value.

## Performance Benchmarking

Measure:

- Classification accuracy.
- Escalation precision and recall.
- Decision latency.
- Prompt schema compliance.
- Human override rate.
- Flow fault rate.

Benchmark before deployment and after each prompt or threshold change.

## Regression Testing for Prompt Changes

Prompt changes require:

- Versioned prompt template.
- Expected JSON schema validation.
- Side-by-side comparison against approved baseline.
- Review of changed classifications and risk tiers.
- Approval from the business owner for material behavior changes.

## Apex and Flow Testing

Apex:

- Test all invocable methods.
- Include bulk requests.
- Include missing and invalid Id scenarios.
- Assert structured error responses.

Flow:

- Test each decision path.
- Test fault paths.
- Validate record updates and task creation.
- Confirm bypass controls for administrators.

## Production Monitoring

Monitor:

- Agent action volume.
- Escalation rate by queue and account segment.
- Human override rate.
- Average decision latency.
- Prompt failure or schema failure rate.
- Business outcome trends.

Use dashboards and scheduled reviews to tune thresholds and identify new topics.
