# Limitations

This project is a portfolio MVP built entirely on synthetic data. It is not an audit of any real organization, and the following limitations apply:

- **Synthetic data only.** Users, access requests, tickets, and MFA events are generated for demonstration purposes and do not represent any real employer, customer, or individual.
- **No real business impact claimed.** This project does not claim any dollar savings, percentage risk reduction, or SLA improvement beyond what is directly calculable from the synthetic data (e.g., exception counts and rates shown in `executive_summary.md` and `control_matrix.md`).
- **Static dataset, single point in time.** The data represents one snapshot, not a live feed. A production control-testing process would run these tests on a recurring schedule (daily/weekly) against live systems.
- **No validation against a real source system.** In a real environment, findings like "terminated-user access exceptions" would be validated against the actual HR system and identity/access management (IAM) platform. Here, the "termination" and "access removal" fields are synthetic fields in the same table, not cross-system validated data.
- **DAX approximation vs. SQL source of truth.** Some Power BI DAX measures (see `dashboard/dax_measures.md`) approximate the SQL exception logic using simplified date-difference conditions, because DAX cannot express the full multi-condition `OR` logic as directly as SQL. The SQL scripts in `/sql` are the authoritative exception logic; the DAX measures are for dashboard KPI cards.
- **No sampling methodology.** This project tests 100% of the synthetic population rather than a statistical sample, which is common in an MVP/portfolio context but differs from how a real audit team might use sampling on a much larger population.
- **Risk ratings are illustrative.** Risk ratings (High/Medium/High/Medium) reflect a reasonable, explainable rationale (population sensitivity, control type) but were not validated against a formal enterprise risk framework or a real risk appetite statement.
- **No remediation tracking.** Recommendations are documented, but this project does not include a remediation-tracking workflow (owner, due date, status) that a real GRC (governance, risk, and compliance) tool would provide.
