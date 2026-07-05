# GitHub Upload Checklist

This checklist keeps the repository truthful before sharing it publicly. The project is synthetic-data only. It does not claim production deployment, real employer data, real remediation, real compliance validation, real dollar savings, real SLA improvement, or real risk reduction.

## Current Repository State

The repository currently supports these claims:

- Synthetic-data SQL control testing project.
- Original SQL findings in `/sql`.
- Single-page Power BI MVP in `dashboard/user_access_it_controls_dashboard.pbix`.
- Portfolio-grade SQL upgrade files in `/sql_upgrade`.
- Documentation explaining current state, upgraded SQL design, limitations, interview answers, and truth-audit boundaries.

The repository does not currently prove a completed upgraded multi-page Power BI dashboard unless the `.pbix` is manually rebuilt and screenshots are added.

## Ready to Upload As-Is

- `README.md`
- `AGENTS.md`
- `data/`
- `sql/`
- `sql_upgrade/`
- `dashboard/user_access_it_controls_dashboard.pbix`
- `dashboard/dashboard_build_guide.md`
- `dashboard/dax_measures.md`
- `dashboard/dax_measures_upgrade.md`
- `dashboard/portfolio_grade_build_guide.md`
- `docs/`
- `presentation/5_minute_project_script.md`

## Manual Action Still Recommended

1. Add real screenshots to `dashboard/screenshots/`.
2. Add a visible synthetic-data disclaimer textbox to the Power BI page before screenshots.
3. Add a LICENSE file if you want reuse terms to be explicit.
4. Skim the README and final truth audit before pushing.

## Before Sharing With Recruiters

1. Run `sql_upgrade/06_validation_queries.sql` and confirm the documented finding counts still reconcile.
2. Open `dashboard/user_access_it_controls_dashboard.pbix` in Power BI Desktop.
3. Add a visible synthetic-data disclaimer textbox before taking final screenshots.
4. Decide whether you are sharing the current single-page MVP or a manually upgraded dashboard.
5. If you build the upgraded pages, confirm the `.pbix` actually contains them before describing them as complete.
6. Save screenshots in `dashboard/screenshots/` and use filenames that match `dashboard/portfolio_grade_build_guide.md`.
7. Verify `README.md` matches the actual screenshots and current `.pbix` state.
8. Check that `docs/resume_bullets.md` matches the version you are actually sharing.
9. Use the current honest resume bullets until upgraded Power BI pages and screenshots exist.
10. Test the GitHub link in an incognito/private browser to confirm screenshots and files render correctly.

## Final Claim Check

Before posting the GitHub link, confirm:

- No real employer, client, customer, or employee data is mentioned.
- No production deployment is claimed.
- No real remediation outcome is claimed.
- No real compliance validation or certification is claimed.
- No invented dollar savings, SLA improvement, or risk reduction is claimed.
- No upgraded Power BI pages, slicers, charts, drill-throughs, or remediation tracker visuals are claimed unless screenshots or the `.pbix` prove they exist.

