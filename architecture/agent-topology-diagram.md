# Agent Topology Diagrams

## ASCII Overview

```text
                 +----------------------+
                 |      Data Cloud      |
                 | identity + insights  |
                 +----------+-----------+
                            |
                            v
 +-----------+      +----------------+      +------------------+
 | CRM Data  +----->| Agent Grounding+----->| Agentforce Agent |
 | Account   |      | Prompt Builder |      | Topic + Action   |
 | Case      |      +-------+--------+      +--------+---------+
 | Contract  |              |                        |
 +-----------+              |                        v
                            |              +------------------+
                            |              | Flow Orchestration|
                            |              +--------+---------+
                            |                        |
                            v                        v
                  +------------------+      +------------------+
                  | Trust Layer      |      | Apex Actions     |
                  | masking + audit  |      | retrieval/update |
                  +------------------+      +--------+---------+
                                                   |
                               +-------------------+-------------------+
                               v                                       v
                         CRM record update                     Human escalation
                         Case/Task/Opp                         Queue/Task/Alert
```

## Data Cloud to Agent Grounding

```mermaid
flowchart LR
    CRM[CRM Records] --> DC[Data Cloud]
    Product[Product Usage Events] --> DC
    Support[Support Interactions] --> DC
    Engagement[Engagement Signals] --> DC
    DC --> Identity[Identity Resolution]
    Identity --> Insights[Calculated Insights]
    Insights --> Grounding[Agent Grounding Context]
    Grounding --> Trust[Einstein Trust Layer]
    Trust --> Agent[Agentforce Agent]
    Agent --> Flow[Salesforce Flow]
    Flow --> Apex[Apex Invocable Actions]
    Apex --> Updates[CRM Record Updates]
```

## Triage Agent Decision Tree

```mermaid
flowchart TD
    Start[Inbound Case or Request] --> Enrich[Retrieve Account and Case Context]
    Enrich --> Classify[Classify Topic and Intent]
    Classify --> Confidence{Confidence Meets Threshold?}
    Confidence -- No --> Escalate[Create Human Review Task]
    Confidence -- Yes --> Severity{Critical Severity or SLA Risk?}
    Severity -- Yes --> Urgent[Route to Escalation Queue]
    Severity -- No --> Product{Known Product Area?}
    Product -- Yes --> Route[Assign Support Queue]
    Product -- No --> Ops[Route to Triage Operations]
    Urgent --> Update[Update Case Fields]
    Route --> Update
    Ops --> Update
    Escalate --> Notify[Notify Human Owner]
```

## Renewal Agent Workflow

```mermaid
flowchart TD
    Schedule[Scheduled or Event Trigger] --> Signals[Calculate Renewal Signals]
    Signals --> Score[Risk Scoring Prompt]
    Score --> Tier{Risk Tier}
    Tier -- High --> CSM[Create CSM Follow-up Task]
    Tier -- Medium --> Playbook[Enroll in Success Playbook]
    Tier -- Low --> Monitor[Update Health Summary]
    CSM --> Outreach[Generate Draft Outreach]
    Playbook --> UpdateOpp[Update Renewal Opportunity]
    Monitor --> UpdateAccount[Update Account Health Fields]
    Outreach --> Review{Human Approval Required?}
    Review -- Yes --> Human[CSM Review]
    Review -- No --> Save[Save Draft Activity]
```

## Human Escalation and CRM Updates

```mermaid
sequenceDiagram
    participant Agent as Agentforce Agent
    participant Flow as Salesforce Flow
    participant Apex as Apex Action Handler
    participant CRM as CRM Records
    participant Human as Human Owner

    Agent->>Flow: Request governed action
    Flow->>Apex: Invoke typed action
    Apex->>CRM: Retrieve or update record context
    Apex-->>Flow: Structured result with rationale
    Flow->>CRM: Persist decision fields
    alt Escalation required
        Flow->>CRM: Create Task or route Case
        Flow->>Human: Send notification
    else Automation approved
        Flow->>CRM: Complete record update
    end
```
