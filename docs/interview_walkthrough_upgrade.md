# Interview Walkthrough: SQL Upgrade

All answers below are for a synthetic-data portfolio project. Do not claim real employer data, production deployment, real remediation, real compliance validation, dollar savings, SLA improvement, or risk reduction.

## 1. Why did you build this project?

I built it to practice the type of work that appears in Technology Operations, IT Risk, IT Audit, Cybersecurity Controls, Business Systems Analyst, and Risk Advisory roles: turning operational data into testable control logic, finding exceptions, and explaining the risk in plain language.

The project is synthetic so it can be shared publicly without exposing any real employer, customer, employee, or system data.

## 2. What problem does it solve?

It answers practical access-control and IT workflow questions:

- Are terminated users still active?
- Are privileged users missing MFA?
- Was access provisioned before approval?
- Are approved requests missing business justification?
- Which ticket categories breach SLA, reopen, or escalate most often?

The project does not solve a real company's problem. It demonstrates how I would structure the analysis.

## 3. Why did you use synthetic data?

Real access, HR, IAM, MFA, and ticket data is sensitive. Synthetic data lets me show the analysis workflow without exposing confidential information.

It also makes the project reproducible. A reviewer can inspect the CSVs, run the SQL, and see how each finding is calculated.

## 4. How does the SQL exception logic work?

Each SQL test defines the business question, risk, control expectation, exception logic, and recommended action.

For example, the privileged-MFA test looks for active users where `privileged_access_flag = 'TRUE'`, `mfa_enabled = 'FALSE'`, and `account_active_flag = 'TRUE'`. That logic is simple enough to defend in an interview and precise enough to trace back to the source data.

## 5. What does "record-level exception engine" mean?

It means the upgraded SQL creates one row per actual exception instead of only showing summary totals.

For example, if 28 active privileged users are missing MFA, the upgraded `fact_control_exceptions` view has 28 rows for that exception type. Each row includes the user ID, department, role, risk rating, source table, exception reason, and recommended action.

That makes the dashboard more audit-like because a KPI can be traced back to the records behind it.

## 6. How does the risk scoring work?

The risk scoring is rule-based, not machine learning.

It starts with a base severity score and adds weight for factors like privileged-access relevance, simulated overdue remediation, older open items, repeated department or system patterns, and ticket workflow relevance.

The score is then placed into bands: Low, Medium, High, or Critical. This is a transparent prioritization method for a portfolio dashboard, not a real enterprise risk model.

## 7. Why is remediation tracking simulated?

Because this is not a real company environment. There are no real control owners, due dates, remediation approvals, or closure evidence.

The `fact_remediation_actions` view shows how remediation tracking could be modeled in Power BI. It uses simulated statuses like Open, In Progress, Remediated, and Accepted Risk so the dashboard design can show owner tracking and overdue logic without pretending real remediation occurred.

## 8. How do data quality checks improve trust?

Data quality checks help show whether the source data is reliable enough for analysis.

For example, duplicate IDs can cause double counting, missing user IDs can break joins, invalid dates can break timing analysis, missing approver or justification fields can signal evidence gaps, and inconsistent TRUE/FALSE values can cause measures to miscount.

The checks do not prove real data quality. They make the synthetic analysis more transparent.

## 9. What do the validation queries prove?

The validation queries prove that the upgraded SQL logic reconciles back to the original documented findings.

They check counts such as 27 terminated-user access exceptions, 28 active privileged users without MFA, 84 access-before-approval exceptions, 25 admin/elevated access-before-approval exceptions, 143 missing business justification exceptions, 62 admin/elevated missing business justification exceptions, and 440 SLA-breached tickets out of 3,000.

This matters because the upgraded model is more detailed, but the headline findings should still tie back to the original SQL.

## 10. What should a hiring manager notice?

A hiring manager should notice that the project is not just a dashboard. It shows the full thinking chain: define the control, write the SQL test, generate record-level exceptions, check data quality, simulate remediation tracking honestly, score risk with transparent rules, validate upgraded outputs against original findings, and document the limitations clearly.

That is the workflow expected in analytical IT risk and operations roles.

## 11. What are the limitations?

The biggest limitations are:

- all data is synthetic
- the current `.pbix` is still a single-page MVP unless manually upgraded
- the remediation workflow is simulated
- the risk score is rule-based, not an enterprise model
- there is no live HR, IAM, ITSM, MFA, or GRC integration
- no real business impact or compliance validation is claimed

These limitations are intentional and documented so the project stays truthful.

## 12. What would you build next in a real company?

In a real company, I would first validate the fields with system owners and connect to actual HR, IAM, ticketing, MFA, and GRC sources. Then I would build recurring exception refreshes, owner assignment, evidence capture, due-date tracking, and management reporting.

I would also define risk ratings with the company's actual risk framework and confirm remediation status with evidence instead of simulated dashboard fields.

