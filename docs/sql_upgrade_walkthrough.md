# SQL Upgrade Walkthrough

This walkthrough explains the upgraded SQL pipeline in beginner-defensible language. The upgrade is a SQL/modeling upgrade only. It does not mean the Power BI `.pbix` file has already been rebuilt into a multi-page dashboard.

All data is synthetic. Nothing in this project proves production deployment, real remediation, real compliance validation, real business impact, dollar savings, SLA improvement, or risk reduction.

## Why the Star Schema Was Added

The original project had strong SQL tests and a simple dashboard summary. The upgraded SQL adds a star schema so the data is easier to analyze in Power BI.

A star schema separates descriptive lookup tables from activity tables:

- Dimension views describe the "who, what, when, where" of the data.
- Fact views hold the events, requests, tickets, exceptions, and counts.

This matters because Power BI works better when facts and dimensions are clearly separated. For example, `dim_user` describes users, while `fact_access_requests` contains access request activity. That makes it easier to slice exception counts by department, role, system, access level, or date.

## Why Data Quality Checks Matter

Control testing depends on trustworthy source fields. If the data has duplicate IDs, missing user IDs, invalid dates, or inconsistent TRUE/FALSE flags, the SQL can still run but the results may be misleading.

`sql_upgrade/02_data_quality_checks.sql` creates `data_quality_summary`, which lists each check, the source table, the issue count, why it matters, and the recommended fix.

Examples:

- Duplicate IDs can double-count records.
- Missing user IDs can break joins between users, tickets, MFA events, and access requests.
- Missing approver IDs or business justifications are evidence gaps.
- Invalid date order can make workflow timing analysis unreliable.

These checks do not prove real data quality. They help explain whether the synthetic dataset is ready for portfolio reporting.

## How Record-Level Control Exceptions Work

The original project summarized findings, such as "28 privileged users without MFA." The upgraded SQL goes deeper by creating one row per exception.

`sql_upgrade/03_build_record_level_control_exceptions.sql` creates `fact_control_exceptions`. Each row includes:

- the exception type
- the relevant user, request, ticket, MFA event, or sample record
- risk rating
- exception reason
- detected date
- source table
- recommended action
- flags for access-control, privileged-access, or ticket-workflow relevance

This is stronger than a summary table because an analyst can trace each KPI back to the records that created it.

Example:

- A single active privileged user without MFA becomes one exception row.
- A single ticket that breached SLA becomes one exception row.
- A single access request provisioned before approval becomes one exception row.

Some records may appear in more than one exception type. For example, an admin request can be counted both as "access provisioned before approval" and as the high-risk subset "admin/elevated access provisioned before approval." That is intentional because the second row supports high-risk prioritization.

## How Remediation Actions Are Simulated

`sql_upgrade/04_build_remediation_actions.sql` creates `fact_remediation_actions` from the exception rows.

This view adds portfolio-design fields such as:

- remediation owner
- due date
- days open
- status
- overdue flag
- evidence required

The statuses are simulated:

- Open
- In Progress
- Remediated
- Accepted Risk

This is not evidence that real remediation happened. It is a design layer for showing how a portfolio-grade dashboard could track owners, due dates, and evidence if this were expanded in a real environment.

## How Rule-Based Risk Scoring Works

`sql_upgrade/05_risk_scoring_model.sql` creates `risk_scored_exceptions`.

The scoring is rule-based, not machine learning. It adds points for transparent reasons:

- base severity
- privileged-access relevance
- simulated overdue remediation
- older open items
- repeated department or system patterns
- ticket workflow relevance

Suggested score bands:

- 0-3: Low
- 4-6: Medium
- 7-9: High
- 10+: Critical

The score helps prioritize synthetic exceptions for dashboard design. It is not a real enterprise risk model and should not be described as one.

## How Validation Queries Prove Counts Reconcile

`sql_upgrade/06_validation_queries.sql` checks whether the upgraded record-level logic reconciles to the original documented findings.

It validates:

- terminated-user access exceptions
- active privileged users without MFA
- access provisioned before approval
- admin/elevated access provisioned before approval
- missing business justification
- admin/elevated missing business justification
- SLA breached tickets
- top SLA breach, reopen, and escalation categories

This is important because the upgraded model is more detailed than the original summary. The validation queries show that the upgrade has not changed the original headline findings unless a filter difference is explicitly explained.

## Interview-Ready Summary

The SQL upgrade turns a summary-level portfolio project into a traceable analytics model. It keeps the original findings, adds data quality checks, builds one row per exception, simulates remediation tracking for dashboard design, adds transparent risk scoring, and validates the upgraded logic back to the original SQL results.

