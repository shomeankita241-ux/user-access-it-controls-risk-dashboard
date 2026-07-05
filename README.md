# Access-Control Exception Testing & IT Workflow Risk Dashboard

A synthetic-data portfolio project demonstrating SQL-based control testing, IT workflow risk analysis, and Power BI dashboarding for Technology Operations, IT Risk, IT Audit, Cybersecurity Controls, Business Systems Analyst, and Risk Advisory roles.

> **Ethics note:** All data in this repository is synthetic. It does not represent any real employer, organization, customer, or individual. This project does not claim production deployment, real remediation, real compliance validation, real dollar savings, real SLA improvement, or real risk reduction.

## 1. Project Overview

This project simulates the core work of a Technology Operations / IT Risk analyst: define control expectations, test source data with SQL, identify exceptions, summarize findings, and prepare the results for a leadership-style Power BI dashboard.

The project has two clearly separated layers:

- **Current Power BI MVP:** a single-page `.pbix` dashboard already included in the repo.
- **Portfolio-grade SQL upgrade:** upgraded SQL views that support a future multi-page Power BI dashboard, but do not prove that the `.pbix` has already been upgraded.

## 2. Business Problem

Access-control failures such as terminated users retaining access, privileged users missing MFA, access granted before approval, and missing access justification are common IT risk themes. IT ticket workflow issues such as SLA breaches, reopens, and escalations can also show operational friction around access and security processes.

This project uses synthetic data to test those themes in a public, reproducible portfolio format.

## 3. Tools Used

- **SQLite / SQL:** source testing, exception logic, star schema views, data quality checks, validation queries
- **Power BI:** current dashboard MVP and target reporting layer
- **Synthetic data:** generated for this project; no real data used

## 4. Dataset Description

| File | Rows | Description |
|---|---:|---|
| `data/users.csv` | 500 | Synthetic user records with employment status, MFA, privileged access, transfers, and login fields |
| `data/access_requests.csv` | 1,000 | Synthetic access request, approval, provisioning, approver, and justification records |
| `data/tickets.csv` | 3,000 | Synthetic IT service desk tickets with SLA, escalation, and reopen flags |
| `data/mfa_events.csv` | 2,000 | Synthetic MFA-related event records |
| `data/control_tests.csv` | 100 | Synthetic sample/control-test records |
| `data/project_findings_summary.csv` | 9 | Consolidated findings table used by the current MVP dashboard |

Full column-level definitions are in `data/data_dictionary.md`.

## 5. Key Risk/Control Questions

1. Are terminated users still active or logging in after termination?
2. Are active privileged users missing MFA?
3. Was access provisioned before approval?
4. Do approved/provisioned access requests have documented business justification?
5. Which IT ticket categories breach SLA, reopen, or escalate most often?
6. Can upgraded SQL views trace dashboard KPIs back to record-level exceptions?

## 6. Original SQL Testing Approach

The original SQL tests in `/sql` are the source of truth for the documented findings.

- `sql/01_access_control_tests.sql`: 6 tests covering terminated-user exceptions, privileged MFA, approval timing, and justification gaps
- `sql/02_ticket_workflow_analysis.sql`: 3 tests covering SLA breach, reopen, and escalation rates by ticket category
- `sql/03_project_findings_summary.sql`: creates a consolidated findings summary table for reporting

Each test documents the business question, risk, control expectation, exception logic, and recommendation.

## 7. Current Power BI MVP

The current Power BI dashboard file is:

- `dashboard/user_access_it_controls_dashboard.pbix`

Based on the repo audit, the current `.pbix` should be described as a **single-page MVP**, not a completed multi-page dashboard.

Current supported dashboard claims:

- 1 report page
- 4 KPI cards:
  - Total Users
  - Total Tickets
  - SLA Breached Tickets
  - Privileged Users Without MFA
- 1 findings/control matrix style table using `project_findings_summary`
- 1 title textbox

Important dashboard boundary:

- The current `.pbix` does not currently prove upgraded pages, charts, slicers, drill-throughs, or remediation tracker visuals.
- The current `.pbix` does not currently prove a visible synthetic-data disclaimer textbox. Add one manually before final screenshots or recruiter sharing.
- `dashboard/screenshots/` currently needs real screenshots before dashboard claims are visually supported on GitHub.

See:

- `dashboard/dashboard_build_guide.md`
- `dashboard/dax_measures.md`

## 8. Portfolio-Grade SQL Upgrade

The repo also includes a SQL-only portfolio-grade upgrade layer in `/sql_upgrade`. These files strengthen the analytics model behind a future upgraded dashboard.

These files do not mean the Power BI `.pbix` has already been upgraded. They prepare the data model and logic for a future development copy of the dashboard.

| File | What It Adds |
|---|---|
| `sql_upgrade/01_create_star_schema.sql` | Creates dimension and fact views for a cleaner Power BI model, including users, departments, systems, dates, controls, ticket categories, access requests, MFA events, tickets, control exceptions, and simulated remediation actions. |
| `sql_upgrade/02_data_quality_checks.sql` | Creates `data_quality_summary` to check duplicate IDs, missing IDs, orphaned users, missing departments/systems, missing evidence fields, invalid dates, flag issues, and missing status fields. |
| `sql_upgrade/03_build_record_level_control_exceptions.sql` | Creates a record-level `fact_control_exceptions` view with one row per dynamically generated exception from users, access requests, tickets, MFA events, and sample/control-test evidence. |
| `sql_upgrade/04_build_remediation_actions.sql` | Creates simulated `fact_remediation_actions` for portfolio dashboard design, with owners, due dates, days open, status, overdue flag, evidence required, and recommended action. |
| `sql_upgrade/05_risk_scoring_model.sql` | Creates `risk_scored_exceptions` using transparent rule-based prioritization. This is not machine learning and not a real enterprise risk model. |
| `sql_upgrade/06_validation_queries.sql` | Provides validation queries that reconcile upgraded SQL logic back to the original documented synthetic findings. |

Supporting documentation:

- `docs/sql_upgrade_walkthrough.md`
- `docs/data_model_and_architecture.md`
- `dashboard/dax_measures_upgrade.md`
- `dashboard/portfolio_grade_build_guide.md`
- `docs/interview_walkthrough_upgrade.md`

## 9. Key Findings From Original SQL

| Finding | Result |
|---|---:|
| Total users tested | 500 |
| Total tickets analyzed | 3,000 |
| Terminated-user access exceptions | 27 |
| Active privileged users without MFA | 28, including 14 System Administrators |
| Access provisioned before approval | 84 |
| Admin/elevated access provisioned before approval | 25 |
| Missing business justification | 143 |
| Admin/elevated missing business justification | 62 |
| SLA breached tickets | 440 of 3,000 (14.67%) |

Top ticket workflow findings:

- Highest SLA breach categories: access request 23.42%, MFA 19.59%, account lockout 16.87%
- Highest reopened ticket categories: account lockout 23.08%, MFA 21.48%, password reset 20.68%
- Highest escalation categories: access request 36.71%, MFA 33.18%, account lockout 31.02%

These values are synthetic-data findings and should remain traceable to SQL.

## 10. Recommendations

The recommendations are portfolio-style recommendations based on synthetic findings:

- Automate HR-to-IT deprovisioning triggers and create a recurring terminated-user access exception report.
- Require MFA before privileged access is granted or retained.
- Configure access-request workflow controls to block provisioning until approval is documented.
- Make business justification mandatory before access approval or provisioning.
- Review staffing, routing, escalation criteria, and knowledge base quality for high-risk ticket categories.

These are not claims that a real organization implemented remediation.

## 11. Limitations

- Synthetic data only.
- Static dataset, not a live data feed.
- Current Power BI file is a single-page MVP unless manually upgraded.
- Upgraded remediation tracking is simulated.
- Risk scoring is rule-based and illustrative.
- No real employer, client, customer, or employee data.
- No production deployment.
- No real compliance validation or certification.
- No real dollar savings, SLA improvement, or risk reduction claimed.

See `docs/limitations.md` and `docs/final_truth_audit.md`.

## 12. How to Reproduce

1. Clone or download the repository.
2. Open `data/user_access_controls.db` in a SQLite tool, or load the CSV files into SQLite.
3. Run the original scripts in `/sql` to reproduce the documented findings.
4. Run the SQL upgrade scripts in `/sql_upgrade` in numeric order to create the upgraded views.
5. Run `sql_upgrade/06_validation_queries.sql` to confirm upgraded logic reconciles to the documented findings.
6. Open the current `.pbix` in Power BI Desktop to inspect the single-page MVP.
7. If building the upgraded dashboard, follow `dashboard/portfolio_grade_build_guide.md` in a development copy of the `.pbix`.

## Repository Structure

```text
user-access-it-controls-risk-dashboard/
|-- AGENTS.md
|-- README.md
|-- GITHUB_UPLOAD_CHECKLIST.md
|-- data/
|   |-- users.csv
|   |-- access_requests.csv
|   |-- tickets.csv
|   |-- mfa_events.csv
|   |-- control_tests.csv
|   |-- project_findings_summary.csv
|   |-- data_dictionary.md
|   `-- user_access_controls.db
|-- sql/
|   |-- 01_access_control_tests.sql
|   |-- 02_ticket_workflow_analysis.sql
|   `-- 03_project_findings_summary.sql
|-- sql_upgrade/
|   |-- 01_create_star_schema.sql
|   |-- 02_data_quality_checks.sql
|   |-- 03_build_record_level_control_exceptions.sql
|   |-- 04_build_remediation_actions.sql
|   |-- 05_risk_scoring_model.sql
|   `-- 06_validation_queries.sql
|-- dashboard/
|   |-- user_access_it_controls_dashboard.pbix
|   |-- dashboard_build_guide.md
|   |-- dax_measures.md
|   |-- dax_measures_upgrade.md
|   |-- portfolio_grade_build_guide.md
|   `-- screenshots/
|-- docs/
|   |-- current_state_audit.md
|   |-- sql_upgrade_walkthrough.md
|   |-- data_model_and_architecture.md
|   |-- executive_summary.md
|   |-- control_matrix.md
|   |-- interview_walkthrough.md
|   |-- interview_walkthrough_upgrade.md
|   |-- limitations.md
|   |-- resume_bullets.md
|   `-- final_truth_audit.md
`-- presentation/
    `-- 5_minute_project_script.md
```

