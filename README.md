# Access-Control Exception Testing & IT Workflow Risk Dashboard

A synthetic-data portfolio project demonstrating SQL-based control testing and Power BI dashboarding for Technology Risk, IT Audit, Internal Audit Technology, Cybersecurity & Technology Controls, Business Systems Analyst, and Risk Advisory roles.

> **Ethics note:** All data in this repository is synthetic. It does not represent any real employer, organization, customer, or individual. No real business impact (dollar savings, risk-reduction percentage, SLA improvement) is claimed beyond what is directly calculable from the synthetic data itself.

---

## 1. Project Overview

This project simulates the core work of an IT audit / technology risk analyst: given raw data about users, access requests, and IT tickets, test whether key access-management controls are actually operating as intended, quantify the exceptions, and communicate the results to a non-technical leadership audience through a dashboard and supporting documentation.

## 2. Business Problem

Access-control failures — terminated employees who retain system access, privileged accounts without multi-factor authentication (MFA), and access granted before it's approved — are among the most frequently cited findings in IT general controls (ITGC) and cybersecurity audits. This project builds a small, reproducible testing framework to detect exactly these kinds of exceptions, plus a look at whether the IT service desk's ticket workflow (SLA, reopens, escalations) is itself a source of operational risk.

## 3. Tools Used

- **SQLite / SQL** — control testing and exception logic
- **Power BI** — dashboarding and visualization
- **Synthetic data** — generated for this project; no real data used

## 4. Dataset Description

| File | Rows | Description |
|---|---|---|
| `data/users.csv` | 500 | Synthetic user records (employment status, MFA, privileged access, transfers) |
| `data/access_requests.csv` | 1,000 | Synthetic access request/approval/provisioning records |
| `data/tickets.csv` | 3,000 | Synthetic IT service desk tickets (SLA, escalation, reopen flags) |
| `data/mfa_events.csv` | 2,000 | Synthetic MFA-related security events |
| `data/control_tests.csv` | 100 | Synthetic control test samples with risk ratings |
| `data/project_findings_summary.csv` | 9 | Consolidated findings table used by the dashboard |

Full column-level definitions are in `data/data_dictionary.md`.

## 5. Key Risk/Control Questions

1. Are terminated users still active or logging in after termination?
2. Are privileged (admin/elevated) users missing MFA?
3. Was access granted before it was approved?
4. Do approved/provisioned access requests have documented business justification?
5. Which IT ticket categories breach SLA, get reopened, or get escalated most often?

## 6. SQL Testing Approach

Each SQL test in `/sql` follows the same structure, documented directly in the query comments:
**business question → risk → control expectation → exception logic → recommendation.**

- `sql/01_access_control_tests.sql` — 6 tests covering terminated-user exceptions, privileged MFA, and access approval/justification gaps
- `sql/02_ticket_workflow_analysis.sql` — 3 tests covering SLA breach, reopen, and escalation rates by ticket category
- `sql/03_project_findings_summary.sql` — consolidates all test results into a single summary table for the dashboard

## 7. Dashboard Overview

The Power BI dashboard (`dashboard/user_access_it_controls_dashboard.pbix`) is a **single-page MVP** consisting of:

- **4 KPI cards:** Total Users (500), Total Tickets (3,000), SLA Breached Tickets (440), Privileged Users Without MFA (28)
- **1 findings/control matrix table**, sourced from `project_findings_summary`, showing each finding with its risk rating, data source, result, risk interpretation, and recommendation
- **1 text box** with a synthetic-data disclaimer

This is intentionally a minimum viable dashboard, not a multi-page report. See `dashboard/dashboard_build_guide.md` for exact build steps, and its "Possible Future Enhancements" section for ideas on expanding it (not yet built).

See `dashboard/dax_measures.md` for the DAX measures used.

## 8. Key Findings

| Finding | Result |
|---|---|
| Total users tested | 500 |
| Total tickets analyzed | 3,000 |
| Terminated-user access exceptions | 27 |
| Active privileged users without MFA | 28 (including 14 System Administrators) |
| Access provisioned before approval | 84 |
| Admin/elevated access provisioned before approval | 25 |
| Missing business justification | 143 |
| Admin/elevated missing business justification | 62 |
| SLA breached tickets | 440 of 3,000 (14.67%) |
| Highest SLA breach categories | Access request 23.42%, MFA 19.59%, account lockout 16.87% |
| Highest reopened ticket categories | Account lockout 23.08%, MFA 21.48%, password reset 20.68% |
| Highest escalation categories | Access request 36.71%, MFA 33.18%, account lockout 31.02% |

## 9. Recommendations

- Automate HR-to-IT deprovisioning triggers; build a weekly terminated-user access exception report.
- Require MFA before privileged access is granted or retained; review exceptions weekly.
- Configure access-request workflow tooling to block provisioning until approval is on record, prioritizing admin/elevated requests.
- Make business justification a required field on the access-request form.
- Review staffing, routing, and knowledge base quality for the access request, MFA, and account lockout ticket categories.

Full detail in `docs/executive_summary.md` and `docs/control_matrix.md`.

## 10. Limitations

This is a synthetic-data MVP: a single static snapshot, not validated against a live HR/IAM system, with no formal sampling methodology or remediation tracking. Full list in `docs/limitations.md`.

## 11. What I Learned

Building this project reinforced how much of technology risk/IT audit work is about precisely defining exception logic *before* writing a query — the hardest part isn't the SQL syntax, it's deciding exactly what "the control failed" means for each specific risk, and being able to explain that logic in plain language to someone who doesn't write SQL. It also reinforced the difference between a control existing on paper (an approval step in a workflow tool) and a control operating effectively in practice (provisioning actually waiting for that approval).

## 12. How to Reproduce This Project

1. Clone this repository.
2. Open `data/user_access_controls.db` in DB Browser for SQLite (or import the CSVs in `/data` into a new SQLite database).
3. Run the scripts in `/sql` in order (`01`, `02`, `03`) to reproduce all control tests and the findings summary table.
4. Open `dashboard/user_access_it_controls_dashboard.pbix` in Power BI Desktop, or follow `dashboard/dashboard_build_guide.md` to rebuild it from the CSVs in `/data`.
5. Read `docs/executive_summary.md` for the leadership-style writeup, and `docs/interview_walkthrough.md` to see how the project is discussed in an interview setting.

---

## Repository Structure

```
user-access-it-controls-risk-dashboard/
├── README.md
├── data/
│   ├── users.csv
│   ├── access_requests.csv
│   ├── tickets.csv
│   ├── mfa_events.csv
│   ├── control_tests.csv
│   ├── project_findings_summary.csv
│   ├── data_dictionary.md
│   └── user_access_controls.db
├── sql/
│   ├── 01_access_control_tests.sql
│   ├── 02_ticket_workflow_analysis.sql
│   └── 03_project_findings_summary.sql
├── dashboard/
│   ├── user_access_it_controls_dashboard.pbix
│   ├── dashboard_build_guide.md
│   ├── dax_measures.md
│   └── screenshots/
├── docs/
│   ├── executive_summary.md
│   ├── control_matrix.md
│   ├── interview_walkthrough.md
│   ├── limitations.md
│   └── resume_bullets.md
└── presentation/
    └── 5_minute_project_script.md
```
