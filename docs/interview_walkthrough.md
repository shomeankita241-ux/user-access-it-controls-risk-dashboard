# Interview Walkthrough

Interview-ready answers for this project. All answers are written for synthetic data — do not claim a real employer or real business impact.

---

**1. Tell me about this project.**

I built an access-control exception testing and IT workflow risk dashboard using synthetic data modeled on a mid-size organization: 500 users, 1,000 access requests, 3,000 IT tickets, and 2,000 MFA events. I used SQL against a SQLite database to test whether access, MFA, approval, and deprovisioning controls were operating effectively, then built a Power BI dashboard to summarize the results for a leadership-style audience.

**2. Why did you choose this project?**

I wanted a project that mirrors real IT audit and technology risk work — testing controls against evidence, quantifying exceptions, and communicating findings — rather than a generic data-visualization exercise. Access management and MFA are two of the most commonly cited control areas in IT audits, so I built a project around exactly that.

**3. What data did you use?**

Entirely synthetic data I generated for this project: a users table (employment status, termination dates, MFA and privileged-access flags), an access_requests table (request/approval/provisioning dates, business justification), a tickets table (SLA, escalation, reopen flags), and supporting MFA event and control test tables. No real employer, customer, or personal data was used.

**4. What SQL logic did you use?**

Mostly `SELECT`, `WHERE` with compound `AND`/`OR` conditions, `CASE WHEN` to categorize exception reasons, `GROUP BY`/`COUNT`/`SUM` for rate calculations, and `julianday()` date-math functions in SQLite to compare dates — for example, checking whether a user's last login date fell after their termination date, or whether provisioning happened before approval.

**5. What was your strongest finding?**

Two, tied for most significant: 27 terminated users had access exceptions (still active, late deprovisioning, or logins after termination), and 28 active privileged users — including 14 System Administrators — did not have MFA enabled. Both represent concentrated risk on populations that should have the strictest controls.

**6. How did you define an exception?**

An exception is any record that fails the stated control expectation based on the data — for example, a terminated user whose account is still marked active, or an approved access request where the provisioned date is earlier than the approval date. I wrote the exception logic explicitly in SQL comments before writing the query, so the "why" is documented alongside the "what."

**7. What is the difference between risk, control, and exception?**

Risk is the thing that could go wrong (e.g., unauthorized access by a former employee). A control is the process meant to prevent or detect that risk (e.g., deprovisioning access at termination). An exception is a specific instance where the evidence shows the control did not operate as intended (e.g., a terminated user whose access was removed 10 days late). Testing exceptions is how you measure whether a control is actually working, not just whether it's documented.

**8. How did you decide risk rating?**

I rated findings High when they involved privileged/admin access, active unauthorized access, or a security control (MFA) — populations where a failure has outsized impact. I rated findings Medium when they involved documentation/evidence gaps (like missing business justification) on standard access, and Medium/High for aggregate patterns like SLA and escalation rates that affect operations broadly but aren't a direct access breach.

**9. What would leadership do with this dashboard?**

The current dashboard is an MVP: a single page with four KPI cards (Total Users, Total Tickets, SLA Breached Tickets, Privileged Users Without MFA) and a findings/control matrix table. Leadership could use the KPI cards to see the size of each exception population at a glance, and the findings table to see each risk-rated finding mapped to a recommendation. A next iteration would add drill-down detail pages so an analyst could trace each finding back to individual records, but that isn't built yet.

**10. What were the limitations?**

This is a synthetic-data MVP, not a production audit. It doesn't include real-time data feeds, doesn't validate against an actual HR or IAM system, and some values (like DAX-based KPI cards) are approximations of the SQL logic — the SQL queries are the source of truth. See `limitations.md` for the full list.

**11. How did you use AI ethically?**

I used AI to help scaffold documentation, SQL comments, and dashboard-build instructions faster, but I generated the synthetic data and defined the control logic and risk ratings myself, and I did not let AI invent numbers — every finding in this project traces back to a specific SQL query I can rerun and verify.

**12. How does this connect to Technology Risk / IT Audit / Business Systems Analyst roles?**

The core skill in all three roles is the same: translate a business process into testable control logic, use data to determine whether the control is operating, and communicate the result (with a clear risk rating and recommendation) to a non-technical audience. This project is a small, complete cycle of that work — from raw data to SQL testing to a dashboard and a findings memo.
