# Power BI Dashboard Build Guide

This guide documents how the current MVP dashboard (`user_access_it_controls_dashboard.pbix`, included in this folder) was actually built. All data is synthetic.

**What the current file contains:** one report page with 4 KPI cards, 1 findings/control matrix table, and 1 text box. It does not (yet) contain multiple pages, charts, drill-down tables, or slicers. Section 7 below outlines possible future additions, clearly labeled as not built.

## 1. Load the data

Load these CSV files (from `/data`) into Power BI Desktop via **Get Data > Text/CSV**, or connect directly to `user_access_controls.db` via an ODBC/SQLite connector if preferred:

- `access_requests.csv`
- `project_findings_summary.csv`

The remaining files (`users.csv`, `tickets.csv`, `mfa_events.csv`, `control_tests.csv`) are included in `/data` for the SQL testing in `/sql` and are not required to reproduce the current MVP dashboard, since the KPI card measures query `access_requests` directly.

**Important data type note:** In this dataset, TRUE/FALSE flag columns (e.g., `account_active_flag`, `mfa_enabled`, `sla_breach_flag`) may load as **text** rather than boolean, depending on export settings. Do not assume Power BI auto-detects them as boolean. Check each flag column's data type in Power Query, and write DAX measures that handle both text `"TRUE"`/`"FALSE"` and boolean `TRUE()`/`FALSE()` forms — see `dax_measures.md`, which uses this robust approach.

## 2. Create the DAX measures

Create the four measures that back the KPI cards in the current dashboard (see `dax_measures.md` for full DAX):
- **Total Users**
- **Total Tickets**
- **SLA Breached Tickets**
- **Privileged Users Without MFA**

`dax_measures.md` also documents additional measures (e.g., Access Before Approval Count, Missing Business Justification Count) that are provided as reference DAX for future expansion — they are not currently wired to a visual in the .pbix.

## 3. Build the current MVP page

- **4 KPI cards**, one row: Total Users (500), Total Tickets (3,000), SLA Breached Tickets (440), Privileged Users Without MFA (28).
- **1 table visual** bound to `project_findings_summary`, showing: finding, risk rating, data source, result, risk interpretation, recommendation. Apply conditional formatting to the Risk Rating column (High = red, Medium/High = orange, Medium = yellow) so it reads like an audit findings memo.
- **1 text box** stating: *"All data in this dashboard is synthetic and was generated for portfolio/demonstration purposes only."*

## 4. Formatting notes

- Keep a consistent color palette: use one color (e.g., dark red) exclusively for "High" risk elements so it reads as a risk signal, not a decoration.
- Add data labels/clear number formatting on the KPI cards so a viewer doesn't have to hover to read the numbers.

## 5. Reproducing this MVP

1. Open Power BI Desktop and load `access_requests.csv` and `project_findings_summary.csv`.
2. Add the four DAX measures from `dax_measures.md`.
3. Add 4 card visuals (one per measure), 1 table visual (bound to `project_findings_summary`), and 1 text box.
4. Save as `.pbix`.

## 6. Known limitation

Because the KPI card measures currently query `access_requests` rather than `users` or `tickets` directly, this file structure works for the dashboard as built, but is not necessarily how a production data model would be organized (a real model would typically define measures on the most relevant fact table, e.g., a `users`-based measure for `Privileged Users Without MFA`). This is noted here for transparency, not corrected retroactively, since it reflects what was actually built.

## 7. Possible Future Enhancements (not yet built)

These are ideas for expanding the dashboard beyond the current MVP. None of the following exist in the current `.pbix` file — do not describe them as complete until they are actually built.

- A second page with drill-down tables for each exception type (terminated-user exceptions, privileged-without-MFA, access-before-approval, missing-justification), with a slicer by access level.
- Bar charts for SLA breach rate, reopened rate, and escalation rate by ticket category (from `tickets.csv`), highlighting the top 3 categories in each.
- A relationships model joining `users`, `access_requests`, and `tickets` on `user_id` to support the drill-down page above.
- Additional KPI cards for Terminated-User Access Exceptions, Access Before Approval Count, and Missing Business Justification Count, using the reference DAX already documented in `dax_measures.md`.
