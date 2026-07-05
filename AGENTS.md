# AGENTS.md

This repository is a synthetic-data portfolio project for Technology Operations, IT Risk, IT Audit, Cybersecurity Controls, Business Systems Analyst, and Risk Advisory roles.

## Non-Negotiable Rules

- Do not claim production deployment.
- Do not mention or imply real employers, clients, customers, or real individuals.
- Do not claim real dollar savings, SLA improvement, operational improvement, or risk reduction.
- Do not claim real compliance certification, audit validation, or framework validation such as SOX, SOC 2, NIST, CIS, or ISO.
- Do not claim dashboard pages, charts, slicers, drilldowns, or remediation tracking exist unless the `.pbix` file or screenshots prove they exist.
- Keep all findings traceable to SQL logic in `/sql` or clearly label them as future/demo design.
- Clearly separate the current MVP from future portfolio-grade upgrades.
- Keep explanations beginner-defensible and interview-ready.

## Current Project Ground Truth

The current project is a synthetic-data SQL testing and Power BI dashboard MVP. It includes CSV data, a SQLite database, SQL control tests, documentation, and a Power BI `.pbix` file.

The current Power BI dashboard is a single-page MVP. Based on the repository files, it contains:

- 1 report page
- 4 KPI cards
- 1 table visual using `project_findings_summary`
- 1 title textbox

It should not be described as a full multi-page dashboard unless future files prove that those pages exist.

## SQL And Findings Rules

The SQL scripts in `/sql` are the source of truth for exception logic. If a number appears in the README, docs, dashboard, resume bullets, or presentation material, it should be traceable to:

- `sql/01_access_control_tests.sql`
- `sql/02_ticket_workflow_analysis.sql`
- `sql/03_project_findings_summary.sql`
- the corresponding synthetic CSV or SQLite data

Do not invent final findings numbers. New SQL in folders such as `/sql_upgrade` may design future structures, but it must not imply that upgraded findings, dashboards, or remediation workflows have already been completed.

## Documentation Rules

Use honest wording:

- "synthetic-data portfolio project"
- "single-page Power BI MVP"
- "SQL-based control testing"
- "illustrative risk ratings"
- "future enhancement" or "portfolio-grade upgrade"

Avoid inflated wording:

- "production-ready"
- "deployed"
- "real business impact"
- "certified compliant"
- "validated against SOX/SOC 2/NIST/CIS/ISO"
- "automated remediation tracking" unless it is actually built
- "multi-page dashboard" unless the `.pbix` or screenshots prove it

## Dashboard Rules

Before claiming a dashboard feature exists, inspect the `.pbix` file, screenshots, or build documentation. If there is a mismatch between docs and the `.pbix`, update the docs to match the `.pbix` and label missing items as future work.

The synthetic-data disclaimer is required for final presentation/screenshots, but it should only be described as already visible in the `.pbix` if the `.pbix` actually contains that visible text.

## Future Upgrade Rules

Future or portfolio-grade upgrades may include a star schema, multi-page Power BI design, slicers, drill-through pages, remediation action tracking, and recurring control monitoring. These must be described as proposed or not yet built until the repo contains working files or screenshots proving them.

When adding upgrade SQL, include comments explaining:

- what each table or view is for
- how it connects to Power BI
- what business or risk question it supports
- which fields are directly from synthetic data
- which fields are derived for portfolio demonstration

