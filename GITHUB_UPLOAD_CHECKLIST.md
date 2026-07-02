# GitHub Upload Checklist

Audit completed. All files below reflect what was actually built: a synthetic-data SQL testing project and a **single-page Power BI MVP dashboard** (4 KPI cards + 1 findings/control matrix table + 1 text box). No multi-page dashboard, no production deployment, and no real business impact is claimed anywhere in this repo.

## Files corrected during this audit

| File | Change |
|---|---|
| `README.md` | Section 7 rewritten to describe the actual single-page MVP dashboard (4 KPI cards, 1 findings table, 1 text box); removed `.sqbpro` from the repo structure diagram |
| `dashboard/dashboard_build_guide.md` | Fully rewritten: documents only what's actually in the `.pbix`; multi-page/chart/slicer content moved to a clearly labeled "Possible Future Enhancements (not yet built)" section |
| `dashboard/dax_measures.md` | Added a note distinguishing the 4 measures actually used in the MVP dashboard from additional measures provided as reference DAX for future work |
| `docs/interview_walkthrough.md` | Q9 answer corrected to describe the single-page MVP instead of three pages |
| `docs/resume_bullets.md` | "multi-page Power BI dashboard" changed to "Power BI dashboard MVP" |
| `presentation/5_minute_project_script.md` | Dashboard description corrected to the single-page MVP with 4 named KPI cards |

## Files reviewed, no changes needed

`docs/executive_summary.md`, `docs/control_matrix.md`, `docs/limitations.md`, `data/data_dictionary.md` — already accurate, already disclaim synthetic data and real business impact appropriately.

## File removed — do not upload

- **`user_access_controls.sqbpro`** — a DB Browser for SQLite session/workbench file (query scratch history and UI state), not a portfolio deliverable. It has been removed from this package. The equivalent, cleaned-up SQL logic already lives in `/sql`, so nothing is lost by excluding it.

## Ready to upload as-is

- `README.md`
- `data/` — all CSVs, `data_dictionary.md`, `user_access_controls.db`
- `sql/01_access_control_tests.sql`, `sql/02_ticket_workflow_analysis.sql`, `sql/03_project_findings_summary.sql`
- `dashboard/user_access_it_controls_dashboard.pbix`
- `dashboard/dashboard_build_guide.md`, `dashboard/dax_measures.md`
- `docs/executive_summary.md`, `docs/control_matrix.md`, `docs/interview_walkthrough.md`, `docs/limitations.md`, `docs/resume_bullets.md`
- `presentation/5_minute_project_script.md`

## Needs your manual action before/after upload

1. **Screenshots.** `dashboard/screenshots/` currently only has a placeholder (`.gitkeep`). Add 1–2 real screenshots of the MVP dashboard page (the 4 KPI cards + findings table) so the README/GitHub page has visual proof, not just a description. Reference them in the README under Section 7 once added (e.g., `![Dashboard MVP](dashboard/screenshots/mvp_overview.png)`).
2. **GitHub repo description/tags.** When you create the repo, use a short description like: *"Synthetic-data SQL + Power BI project testing access, MFA, and approval controls, and IT ticket workflow risk."* Suggested topics: `sql`, `sqlite`, `power-bi`, `it-audit`, `technology-risk`, `data-analytics`, `portfolio-project`.
3. **LICENSE file (optional).** Not included here. Add one (e.g., MIT) if you want to make reuse terms explicit — not required for a portfolio project but common practice.
4. **Final read-through.** Before pushing, skim `README.md` and `docs/executive_summary.md` one more time yourself — you know the project best, and a final human check is good practice before anything goes public.

## Confirmation

- No real employer, client, or customer references found anywhere in the repo.
- No production-deployment claims found.
- No invented dollar savings, risk-reduction percentages, or SLA-improvement claims found.
- No numbers were changed or invented during this audit — all figures still match your original SQL findings exactly (27, 28/14, 84, 25, 143, 62, 440/3,000, and all three category breakdowns).
