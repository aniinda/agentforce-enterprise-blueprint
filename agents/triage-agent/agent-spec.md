# Triage Agent Specification

## Purpose

The Triage Agent classifies inbound customer requests, enriches the request with CRM context, recommends routing, and initiates governed follow-up actions. It is designed for production service operations where speed matters but high-risk records still need human oversight.

## Scope

In scope:

- New or updated Cases that require queue assignment.
- Customer messages that indicate urgency, sentiment, product area, or entitlement impact.
- SLA risk detection and escalation recommendations.
- Case context enrichment using Account, Case, Entitlement, and Data Cloud signals.
- Task creation for human follow-up.

Out of scope:

- Legal, pricing, or contractual decisions.
- Autonomous customer commitments.
- Final root cause analysis.
- Product bug prioritization outside configured routing fields.
- Sending external customer communications without approval.

## Topics

- Case Classification
- SLA and Escalation Risk
- Account Context Enrichment
- Renewal Impact Detection
- Human Review Required

## Actions

- Retrieve CRM Context
- Classify Triage Route
- Calculate Routing Priority
- Create Escalation Task
- Create Case From Agent Decision
- Update Case Routing Fields
- Flag Renewal Impact

## Data Sources

- Account: tier, owner, region, strategic status, lifecycle stage.
- Case: subject, description, priority, status, product area, origin, entitlement.
- Contact: role, relationship, language, executive flag.
- Entitlement and milestone status.
- Data Cloud: account health, usage trend, support sentiment, open risk indicators.
- Opportunity and Contract: renewal date, amount, stage, and owner.

## Escalation Criteria

Escalate to a human when any of the following are true:

- Classification confidence is below 0.75.
- Customer sentiment is highly negative or mentions executive escalation.
- Account is strategic or annual contract value is above configured threshold.
- SLA breach is predicted within configured window.
- Case indicates security, privacy, legal, or contractual exposure.
- Required grounding data is missing or inconsistent.

## Performance Targets

- Classification accuracy: 90% or higher against reviewed test set.
- Automated routing precision: 95% or higher for high-confidence cases.
- Median triage decision time: under 60 seconds after trigger.
- Escalation false-negative rate: below 2%.
- Prompt schema compliance: 99% or higher.

## Configuration Parameters

| Parameter | Default | Description |
| --- | ---: | --- |
| `classificationConfidenceThreshold` | `0.75` | Minimum confidence for automated routing. |
| `criticalConfidenceThreshold` | `0.90` | Required confidence for non-human critical routing. |
| `strategicAccountEscalation` | `true` | Escalates strategic accounts by default. |
| `slaRiskWindowHours` | `8` | Escalates cases projected to breach within this window. |
| `renewalImpactWindowDays` | `120` | Flags support cases that may affect active renewal cycles. |
| `maxAutomatedUpdatesPerCase` | `3` | Prevents repeated agent churn on the same record. |

## Operating Model

The agent is triggered by Flow when a Case is created or materially updated. Flow retrieves deterministic context, calls prompt templates through Agentforce, invokes Apex actions for record operations, and records decision output on the Case and Task records.
