# Current State Audit

This audit describes what exists in the repository today. It separates the current synthetic-data MVP from future portfolio-grade upgrades and avoids claims that are not supported by the repo files.

## 1. Current Files and Folders

Root files:

- `README.md`
- `GITHUB_UPLOAD_CHECKLIST.md`
- `AGENTS.md`

Folders:

- `data/`
  - `users.csv`
  - `access_requests.csv`
  - `tickets.csv`
  - `mfa_events.csv`
  - `control_tests.csv`
  - `project_findings_summary.csv`
  - `data_dictionary.md`
  - `user_access_controls.db`
- `sql/`
  - `01_access_control_tests.sql`
  - `02_ticket_workflow_analysis.sql`
  - `03_project_findings_summary.sql`
- `dashboard/`
  - `user_access_it_controls_dashboard.pbix`
  - `dashboard_build_guide.md`
  - `dax_measures.md`
  - `screenshots/.gitkeep`
- `docs/`
  - `executive_summary.md`
  - `control_matrix.md`
  - `interview_walkthrough.md`
  - `limitations.md`
  - `resume_bullets.md`
  - `current_state_audit.md`
- `presentation/`
  - `5_minute_project_script.md`
- `sql_upgrade/`
  - planned for portfolio-grade SQL model work

The `dashboard/screenshots/` folder currently contains only `.gitkeep`; it does not contain real screenshots yet.

## 2. What the Project Currently Does

This is a synthetic-data portfolio project for Technology Operations, IT Risk, IT Audit, Cybersecurity Controls, Business Systems Analyst, and Risk Advisory roles.

The project simulates access-control and IT workflow risk testing. It uses synthetic users, access requests, tickets, MFA events, and control test records to show how an analyst can:

- define control expectations
- write SQL exception logic
- quantify exceptions and workflow risk indicators
- summarize findings for a leadership-style audience
- present the work through documentation and a Power BI MVP

The project does not represent a real employer, client, customer, system, or production environment.

## 3. Current SQL Tests

The current SQL testing is in `/sql` and is the source of truth for findings.

`sql/01_access_control_tests.sql` covers:

- terminated-user access exceptions
- active privileged users without MFA
- access provisioned before approval
- admin/elevated access provisioned before approval
- missing business justification on approved/provisioned access
- admin/elevated access missing justification or approval evidence

`sql/02_ticket_workflow_analysis.sql` covers:

- SLA breach rate by ticket category
- reopened ticket rate by ticket category
- escalation rate by ticket category
- a combined ticket workflow risk view

`sql/03_project_findings_summary.sql` creates a consolidated `project_findings_summary` reporting table. It is not a new control test. It hard-codes the summarized results from the prior SQL test outputs so Power BI and non-technical documentation can consume them more easily.

Current documented headline results include:

- 27 terminated-user access exceptions
- 28 active privileged users without MFA, including 14 System Administrators
- 84 access requests provisioned before approval
- 25 admin/elevated requests provisioned before approval
- 143 approved/provisioned requests missing business justification
- 62 admin/elevated requests missing business justification
- 440 SLA-breached tickets out of 3,000

All findings should remain traceable to SQL logic and the synthetic source data.

## 4. Current Power BI Dashboard Ground Truth

The current Power BI file is `dashboard/user_access_it_controls_dashboard.pbix`.

Based on the repository files and inspected `.pbix` layout, the current dashboard is a single-page MVP with:

- 1 report page
- 4 KPI card visuals:
  - Total Users
  - Total Tickets
  - SLA Breached Tickets
  - Privileged Users Without MFA
- 1 table visual using `project_findings_summary`
- 1 title textbox

The table visual uses fields from `project_findings_summary`. In the inspected layout, the projected table fields are:

- `risk_rating`
- `data_source`
- `result`
- `recommendation`

The current `.pbix` does not prove that it contains:

- multiple report pages
- bar charts
- slicers
- drilldowns or drill-through pages
- remediation tracking visuals
- real screenshots
- a visible synthetic-data disclaimer textbox

The project documentation should be honest that the dashboard is a single-page MVP with 4 KPI cards and a findings/control matrix style table, not a full multi-page dashboard.

Before final screenshots or presentation use, a visible synthetic-data disclaimer should be added manually to the Power BI page.

## 5. What Would Be Overclaiming

It would be overclaiming to describe the current project as:

- production deployed
- built from real employer, client, customer, or employee data
- a real audit or real control assessment
- a certified SOX, SOC 2, NIST, CIS, ISO, or regulatory compliance validation
- a real risk-reduction, SLA-improvement, or dollar-savings initiative
- a full multi-page Power BI dashboard
- an interactive dashboard with slicers, charts, drilldowns, or drill-throughs
- a remediation tracking system
- a live HR, IAM, GRC, or ITSM integration
- a recurring automated control monitoring platform

Accurate wording would be:

- synthetic-data portfolio project
- SQL-based control testing project
- Power BI single-page MVP
- audit-style documentation and findings summary
- portfolio-grade roadmap or future enhancement ideas

## 6. Portfolio-Grade Upgrade Roadmap

To upgrade this into a stronger Technology Operations / IT Risk portfolio project, the next build steps should be:

1. Fix dashboard documentation to match the actual `.pbix` and add a visible synthetic-data disclaimer before final screenshots.
2. Add real screenshots of the current MVP dashboard to `dashboard/screenshots/`.
3. Build a portfolio-grade star schema using the existing synthetic datasets.
4. Create dynamic SQL views for exception summaries instead of relying only on hard-coded reporting text.
5. Add Power BI model relationships across users, access requests, tickets, MFA events, and control tests.
6. Add future dashboard pages only after they are actually built, such as an executive overview, access exceptions page, ticket workflow page, and remediation tracker page.
7. Add slicers and drill-through views only after the `.pbix` or screenshots prove they exist.
8. Add remediation action fields such as owner, status, due date, aging, priority, and evidence needed as a portfolio demonstration layer.
9. Add a repeatable validation script that checks SQL counts against documented findings.
10. Keep all upgraded claims separated from the current MVP until the files prove the upgraded features exist.

