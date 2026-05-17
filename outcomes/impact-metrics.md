# Impact Metrics

## Baseline Metrics

Before agent deployment:

- Manual triage required queue review for most inbound cases.
- Decision latency increased during peak support volume.
- Renewal risk signals were reviewed inconsistently across account teams.
- Escalation rationale was often captured in free text or not captured at all.

Representative baseline measures:

| Metric | Baseline |
| --- | ---: |
| Median triage handling time | 14 minutes |
| Manual queue touches per case | 2.8 |
| Renewal risk review cycle | 10 business days |
| Escalation rationale completeness | 54% |

## Agent Performance Metrics

| Metric | Target |
| --- | ---: |
| Triage classification accuracy | 90%+ |
| Automated routing precision | 95%+ |
| Escalation false-negative rate | <2% |
| Prompt schema compliance | 99%+ |
| Renewal risk tier agreement | 85%+ |

## Business Outcomes

Measured outcomes:

- 47% improvement in triage efficiency.
- 38% reduction in decision cycle times.
- 22-point NPS improvement.
- Improved consistency in escalation and CRM updates.
- Faster renewal risk visibility for customer success teams.

## Measurement Methodology

Triage efficiency:

- Compare handling time, queue touches, and manual reassignment rates before and after activation.
- Exclude closed-spam and duplicate records from analysis.

Decision cycle time:

- Measure elapsed time from triggering record event to routed owner or approved next action.
- Segment by account tier and case severity.

NPS:

- Compare rolling NPS across cohorts exposed to faster triage and proactive renewal intervention.
- Normalize for account segment and renewal stage.

Agent quality:

- Sample agent decisions weekly.
- Compare to human-reviewed gold labels.
- Track override reasons to identify tuning needs.

## Replication Guidance

To replicate the pattern:

1. Establish baseline metrics before activating automation.
2. Start with human review for most agent recommendations.
3. Promote only high-confidence, low-risk paths to automated updates.
4. Keep prompt templates versioned and regression tested.
5. Review escalations and overrides weekly during the first release cycle.
6. Tune thresholds by segment rather than globally when behavior differs by customer tier.
