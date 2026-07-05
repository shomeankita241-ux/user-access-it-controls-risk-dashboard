# Data Model and Architecture

This document explains the project data flow and upgraded SQL model. All data is synthetic, and the upgraded SQL views are for portfolio analytics design. They do not prove production deployment or real compliance validation.

## Data Flow

```text
Synthetic CSV files / SQLite database
    ->
Original SQL control tests in /sql
    ->
Upgraded SQL views in /sql_upgrade
    ->
Power BI reporting layer
    ->
Screenshots and interview-ready documentation
```

## Architecture Diagram

```text
                 +----------------------------+
                 | Synthetic source data      |
                 | users, access_requests,    |
                 | tickets, mfa_events,       |
                 | control_tests              |
                 +-------------+--------------+
                               |
                               v
                 +----------------------------+
                 | Original SQL tests         |
                 | /sql/01, /sql/02, /sql/03  |
                 +-------------+--------------+
                               |
                               v
       +-----------------------------------------------+
       | Upgraded SQL analytics layer                  |
       | dimensions, facts, data quality, exceptions,  |
       | simulated remediation, risk scoring, QA       |
       +-----------------------+-----------------------+
                               |
                               v
                 +----------------------------+
                 | Power BI reporting layer   |
                 | Current MVP now; upgraded  |
                 | pages only after built     |
                 +----------------------------+
```

## Original Source Tables

- `users`: synthetic user population, employment status, MFA status, privileged access, department, role, and termination fields.
- `access_requests`: synthetic access request, approval, provisioning, approver, access level, and justification fields.
- `tickets`: synthetic IT service desk tickets with category, priority, SLA, reopen, and escalation flags.
- `mfa_events`: synthetic MFA/security event records with event type, failed login count, exception flag, and resolved flag.
- `control_tests`: synthetic sample/control-test evidence records.

## Upgraded Dimensions

### dim_user

Purpose: One row per synthetic user.

Power BI use: Slice exceptions by user type, department, employment status, role, privileged-access status, and MFA status.

Business questions:

- Which user populations have the most access-control exceptions?
- Are terminated or privileged users driving more risk?

### dim_department

Purpose: A department lookup derived from users and access requests.

Power BI use: Department slicers, department-level exception charts, and department-level QA views.

Business questions:

- Which departments appear most often in the synthetic exceptions?
- Are repeated issues concentrated in one department?

### dim_system

Purpose: A lookup of requested systems from access requests.

Power BI use: System slicers and system-level exception charts.

Business questions:

- Which systems have access-before-approval or missing-justification exceptions?

### dim_date

Purpose: A date dimension derived from request, approval, provisioning, ticket, MFA, control test, termination, removal, login, and transfer dates.

Power BI use: Date slicers, trend visuals, aging views, and due-date analysis.

Business questions:

- How do exceptions trend over time?
- Which simulated remediation actions are old or overdue?

### dim_control

Purpose: A lookup of synthetic control names, objectives, test criteria, and illustrative framework mappings.

Power BI use: Control-level slicers and control exception summaries.

Business questions:

- Which controls have exceptions?
- Which controls need clearer evidence or owner follow-up?

### dim_ticket_category

Purpose: A lookup of ticket categories from the synthetic ticket data.

Power BI use: Ticket category slicers and workflow charts.

Business questions:

- Which ticket categories drive SLA breaches, reopens, or escalations?

## Upgraded Facts

### fact_access_requests

Purpose: One row per synthetic access request with derived exception flags.

Power BI use: KPI cards and tables for access-before-approval, missing business justification, and high-risk access.

Business questions:

- Was access provisioned before approval?
- Are admin/elevated requests missing justification?

### fact_mfa_events

Purpose: One row per synthetic MFA event with aggregation-friendly flags.

Power BI use: MFA event count, unresolved event count, exception count, and MFA trend visuals.

Business questions:

- Which MFA events suggest support or security friction?

### fact_tickets

Purpose: One row per synthetic IT ticket with SLA, reopen, escalation, and knowledge base flags.

Power BI use: SLA breach, reopen, escalation, and ticket workflow analytics.

Business questions:

- Which ticket categories create operational workflow risk?

### fact_control_exceptions

Purpose: One row per dynamically generated exception from source data.

Power BI use: Main exception engine for exception counts, detail tables, drill-through, and risk prioritization.

Business questions:

- What are the actual records behind each finding?
- Which exceptions are access-control, privileged-access, ticket-workflow, MFA, or sample/control-test related?

### fact_remediation_actions

Purpose: Simulated remediation tracking derived from record-level exceptions.

Power BI use: Owner, due date, status, overdue, evidence-required, and days-open visuals.

Business questions:

- If this were a portfolio-grade dashboard, which exceptions would need owner follow-up?
- Which simulated actions are overdue?

Important: This is not evidence that real remediation happened.

### data_quality_summary

Purpose: Summary of data quality checks across the synthetic source data.

Power BI use: QA page, data readiness card, and issue table.

Business questions:

- Are source fields complete enough for reporting?
- What data issues could affect trust in the model?

### risk_scored_exceptions

Purpose: Rule-based risk scoring layer built on exceptions and simulated remediation actions.

Power BI use: priority ranking, high/critical risk views, and risk driver summaries.

Business questions:

- Which exceptions should be reviewed first in a portfolio dashboard?
- Why did an exception receive a higher score?

Important: This is not machine learning and not a real enterprise risk model.

## Current Dashboard Boundary

The current `.pbix` remains a single-page MVP unless it is manually rebuilt and screenshots are added. The upgraded SQL views are ready to support a future portfolio-grade Power BI dashboard, but those pages should not be claimed complete until the `.pbix` and screenshots prove they exist.

