# Agentforce Enterprise Blueprint

Reference implementation for enterprise Agentforce patterns in a production go-to-market environment. The repository shows how autonomous Salesforce agents can replace manual triage routing and reactive CRM workflows while preserving governance, human oversight, and auditable decision paths.

This pattern is based on common enterprise SaaS engagement needs and uses only generic data, examples, and implementation concepts. No customer code, data, credentials, or proprietary configuration is included.

## Problem Statement

Enterprise GTM teams often rely on manual queue review, inconsistent account research, and after-the-fact CRM updates. The result is high decision latency, uneven customer experience, and limited visibility into why work was routed or escalated.

The operating challenges addressed here are:

- Manual triage across support, success, and revenue operations queues.
- Reactive workflows that update CRM records only after human intervention.
- High decision latency for prioritization, escalation, and renewal risk response.
- Inconsistent use of account health, case history, entitlement, and usage signals.

## Agentforce Approach

Traditional automation works well when every branch is deterministic. The implementation pattern in this repository uses Agentforce when the decision requires context synthesis, natural-language interpretation, and confidence-aware routing.

Agents are used for:

- Interpreting unstructured case and customer context.
- Grounding decisions in CRM and Data Cloud signals.
- Recommending or executing governed actions through Flow and Apex.
- Escalating to humans when confidence, risk, or policy thresholds require review.

Deterministic automation remains in Flow and Apex. The agent decides what should happen; Flow and Apex enforce how it happens.

## Architecture Overview

The architecture separates customer issue triage from renewal risk orchestration. This keeps each agent focused, measurable, and governed by domain-specific thresholds.

See [agent topology overview](architecture/agent-topology-overview.md) and [agent topology diagrams](architecture/agent-topology-diagram.md).

## Agents

### Triage Agent

Classifies inbound cases, enriches CRM context, recommends routing, and creates human follow-up tasks when risk or ambiguity exceeds automation thresholds.

### Renewal Agent

Monitors subscription health signals, scores renewal risk, recommends next-best actions, and prepares compliant outreach for customer success and account teams.

## Technology Stack

- Salesforce Agentforce
- Agent Builder
- Prompt Builder
- Salesforce Flow
- Apex invocable actions
- Salesforce Data Cloud
- Einstein Trust Layer
- CRM standard objects including Account, Case, Opportunity, Contract, and Task

## Key Outcomes

- 47% improvement in triage efficiency.
- 38% reduction in decision cycle times.
- 22-point NPS improvement.
- Higher consistency in escalation, routing, and CRM record updates.

## Folder Structure

```text
agentforce-enterprise-blueprint/
├── architecture/
├── agents/
│   ├── triage-agent/
│   └── renewal-agent/
├── apex/
├── data-cloud/
├── docs/
├── flows/
└── outcomes/
```

## Setup Prerequisites

- Salesforce org with Agentforce enabled.
- Agent Builder and Prompt Builder access.
- Data Cloud configured for CRM and usage signal grounding.
- Permission sets for agent administrators, service users, and customer success users.
- Salesforce DX or Metadata API deployment workflow for Apex classes.

Deployment guidance is covered in [agent-triggered workflow setup](flows/agentforce-triggered-workflows-README.md).

## About This Pattern

This is a public portfolio reference implementation, not a managed package. It demonstrates architecture, prompts, action contracts, Flow orchestration, trust controls, and testing strategy that can be adapted to enterprise Salesforce programs.

Use it as a blueprint for implementation planning, design reviews, proof-of-value builds, and architecture conversations.
