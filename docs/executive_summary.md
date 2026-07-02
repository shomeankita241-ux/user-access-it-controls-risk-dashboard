# Executive Summary: Access-Control Exception Testing & IT Workflow Risk

**Prepared as a portfolio project. All data is synthetic and does not represent any real organization.**

## Background

Access-related control failures — accounts that stay active after termination, privileged accounts without multi-factor authentication (MFA), and access granted without a completed approval — are among the most common findings in IT general controls (ITGC) and cybersecurity audits. This project builds a small analytics workflow to test for these exceptions using synthetic data modeled on a mid-size organization's user, access-request, and IT ticket population.

## Objective

Test whether user access, MFA, access-approval, and deprovisioning controls operated effectively, and identify whether IT service desk ticket workflows (SLA, reopens, escalations) show operational risk patterns tied to access and security issues.

## Scope

- 500 synthetic users
- 1,000 synthetic access requests
- 3,000 synthetic IT tickets
- 2,000 synthetic MFA events
- 100 synthetic control test samples
- Testing performed in SQLite/SQL; results visualized in Power BI

## Key Findings

| Finding | Result |
|---|---|
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

## Risk Impact

The findings cluster around three control themes:

1. **Deprovisioning timeliness** — terminated-user exceptions mean unauthorized access can persist after someone leaves the organization.
2. **Privileged access hygiene** — MFA gaps on privileged accounts, and approval/justification gaps on admin/elevated access requests, concentrate risk on the population capable of the most damage if compromised or misused.
3. **Operational strain on access-related IT support** — access request, MFA, and account lockout tickets have the highest SLA breach, reopen, and escalation rates, suggesting the support process around access issues is a recurring pain point, not an isolated one.

## Recommendations

- Automate HR-to-IT deprovisioning triggers and build a weekly terminated-user access exception report.
- Require MFA as a precondition for granting or retaining privileged access; review exceptions weekly.
- Configure access-request workflow tooling to technically block provisioning until approval is on record (a system control, not a manual step), prioritizing admin/elevated requests.
- Make business justification a mandatory field on the access-request form, with a stronger evidence standard for admin/elevated requests.
- Review staffing, routing rules, and knowledge base quality for the access request, MFA, and account lockout ticket categories specifically.

## Limitations

This is a synthetic-data MVP built for portfolio purposes. It does not reflect any real organization's control environment, and no dollar savings, percentage risk reduction, or SLA improvement is claimed beyond what is directly shown by the data above. See `limitations.md` for the full list of scope boundaries.
