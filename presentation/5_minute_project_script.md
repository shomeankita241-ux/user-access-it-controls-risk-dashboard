# 5-Minute Project Script

A spoken walkthrough you can use in an interview or presentation. All numbers below are from synthetic data.

---

### 30-second overview

"This is a portfolio project called Access-Control Exception Testing and IT Workflow Risk Dashboard. I used synthetic data — 500 users, 1,000 access requests, 3,000 IT tickets — to test whether access, MFA, approval, and deprovisioning controls were actually working, using SQL for the testing and Power BI for the dashboard."

### 1-minute business problem

"In IT audit and technology risk, some of the most common findings are things like: a terminated employee whose access wasn't removed, a privileged account without multi-factor authentication, or access that was granted before it was actually approved. These aren't hypothetical — they show up constantly in real control testing. So I built a synthetic environment that reflects that same pattern, and set out to answer: is access being provisioned, approved, and removed the way the process says it should be? And separately, is the IT service desk handling access-related tickets efficiently, or is that process itself a source of risk?"

### 1-minute data/SQL explanation

"I generated synthetic tables for users, access requests, tickets, MFA events, and control test samples, and loaded them into SQLite. I wrote nine SQL tests — each one starts with a comment block explaining the business question, the risk, the control expectation, the exact exception logic, and a recommendation. For example, the terminated-user test flags anyone whose account is still active, has no recorded access-removal date, was deprovisioned more than two days late, or logged in after their termination date. I used `CASE WHEN` to categorize why each record failed, and `GROUP BY`/`COUNT` to roll exceptions up into rates for the ticket workflow tests."

### 1-minute dashboard/findings explanation

"The Power BI dashboard is an MVP: a single page with four KPI cards — Total Users, Total Tickets, SLA Breached Tickets, and Privileged Users Without MFA — plus a findings/control matrix table that maps every finding to a risk rating and recommendation. The headline findings: 27 terminated-user access exceptions, 28 active privileged users without MFA — 14 of them System Administrators — 84 instances of access provisioned before approval, and 143 instances of missing business justification. On the ticket side, access request, MFA, and account lockout tickets had the highest SLA breach, reopen, and escalation rates across the board."

### 1-minute recommendations/limitations

"My recommendations follow directly from the findings: automate the HR-to-IT deprovisioning trigger, enforce MFA as a precondition for privileged access, configure the access-request workflow so provisioning can't technically happen before approval — prioritizing admin and elevated access first — and make business justification a required field. On the limitations side, this is a synthetic-data MVP: it's a single snapshot, not validated against a live HR or IAM system, and I don't claim any dollar savings or risk-reduction percentage that isn't directly shown in the data."

### 30-second closing

"Overall, this project was about practicing the full analyst workflow — turning raw data into testable control logic, quantifying exceptions, and communicating findings in a way a non-technical leadership audience could act on. I'd be glad to walk through any of the SQL logic or the dashboard in more detail."

---

## Things I Must Understand

Plain-language explanations of the SQL and concepts used in this project, so I can answer follow-up questions confidently.

- **SELECT** — tells the database which columns (fields) I want to see in the results.
- **FROM** — tells the database which table to pull those columns from.
- **WHERE** — filters rows down to only the ones that meet a condition (e.g., only terminated users).
- **AND** — combines conditions where ALL of them must be true for a row to be included.
- **OR** — combines conditions where ANY ONE of them being true is enough to include the row. I used OR heavily in exception logic because a record should be flagged if it fails ANY of several possible checks.
- **COUNT** — counts the number of rows that match a condition; I used it to get exception counts and totals.
- **GROUP BY** — groups rows that share a value (like ticket category) so I can calculate something per group (like a breach rate per category) instead of one number for the whole table.
- **ORDER BY** — sorts the results, usually so the highest-risk or highest-count items appear first.
- **AS** — renames a column or calculated value in the output so it's readable (e.g., `AS exception_reason`).
- **Date comparison** — SQLite stores dates as text, so I used `julianday()` to convert dates into numbers I can subtract, which lets me check things like "was the last login after the termination date?"
- **Risk vs. control vs. exception** — risk is what could go wrong; a control is the process meant to prevent or catch it; an exception is a specific record where the evidence shows the control didn't work as intended.
- **Why MFA matters** — a password alone can be stolen, guessed, or reused; MFA adds a second proof of identity, which is especially important for privileged/admin accounts that can cause the most damage if compromised.
- **Why approval before provisioning matters** — if access can be granted before it's approved, the approval step isn't really controlling anything; it becomes a formality that happens after the fact instead of a gate.
- **Why missing business justification matters** — even if access was appropriate, without documented justification the organization can't prove why it was granted if it's ever questioned, reviewed, or audited.
- **Why SLA/reopened/escalated tickets matter** — these are operational health signals: SLA breaches mean users wait too long, reopens mean the first fix didn't actually solve the problem, and escalations mean Tier 1 support may lack what it needs to resolve the issue — all of which compound when they cluster around access and security categories.
