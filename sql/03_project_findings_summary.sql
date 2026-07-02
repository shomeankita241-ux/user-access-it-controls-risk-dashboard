-- =====================================================================
-- 03_project_findings_summary.sql
-- Access-Control Exception Testing & IT Workflow Risk Dashboard
-- Synthetic data only. No real employer, customer, or personal data.
-- =====================================================================
-- Business purpose: Consolidate the results of all nine control tests
--   (01_access_control_tests.sql and 02_ticket_workflow_analysis.sql)
--   into a single summary table that Power BI can load directly for
--   the dashboard's "Findings" and "Control Matrix" views, and that a
--   non-technical leadership audience can read without running SQL.
-- This is a reporting/presentation table, not a new control test --
--   the numbers below are hard-coded from the test results because
--   SQLite does not have a simple way to interpolate query results
--   into text within a single CREATE TABLE statement. If the source
--   data changes, re-run the tests above and update this table.
-- =====================================================================

DROP TABLE IF EXISTS project_findings_summary;

CREATE TABLE project_findings_summary AS
SELECT
    'Terminated-user access exceptions' AS finding,
    'High' AS risk_rating,
    'Users' AS data_source,
    '27 exceptions' AS result,
    'Terminated users had active accounts, late access removal, missing removal dates, or login after termination.' AS risk_interpretation,
    'Automate HR-to-IT deprovisioning alerts and create a weekly terminated-user access exception report.' AS recommendation

UNION ALL

SELECT
    'Privileged users without MFA',
    'High',
    'Users',
    '28 exceptions',
    'Active privileged accounts did not have MFA enabled, including 14 System Administrators.',
    'Require MFA before privileged access is granted and review privileged-MFA exceptions weekly.'

UNION ALL

SELECT
    'Access provisioned before approval',
    'Medium/High',
    'Access requests',
    '84 exceptions',
    'Access was granted before the approval date, meaning the approval control did not operate before provisioning.',
    'Configure workflow controls to block provisioning until approval is completed.'

UNION ALL

SELECT
    'Admin/elevated access provisioned before approval',
    'High',
    'Access requests',
    '25 exceptions',
    'Admin or elevated access was granted before approval, increasing unauthorized access risk.',
    'Prioritize admin/elevated access requests for approval enforcement and exception review.'

UNION ALL

SELECT
    'Missing business justification',
    'Medium',
    'Access requests',
    '143 exceptions',
    'Approved and provisioned access requests lacked documented business justification.',
    'Require business justification as a mandatory field before approval or provisioning.'

UNION ALL

SELECT
    'Admin/elevated access missing business justification',
    'High',
    'Access requests',
    '62 exceptions',
    'Admin/elevated access was approved or provisioned without documented business need.',
    'Require stronger evidence for admin/elevated access and review these requests monthly.'

UNION ALL

SELECT
    'SLA breaches in ticket workflow',
    'Medium/High',
    'Tickets',
    '440 of 3,000 tickets',
    'Access request and MFA tickets had the highest SLA breach rates.',
    'Review routing, staffing, escalation rules, and knowledge base quality for access and MFA tickets.'

UNION ALL

SELECT
    'High reopened ticket rate',
    'Medium',
    'Tickets',
    'Account lockout 23.08%, MFA 21.48%, password reset 20.68%',
    'Repeated reopening suggests incomplete first-contact resolution or unclear user instructions.',
    'Improve knowledge base articles and first-contact resolution scripts for account lockout, MFA, and password reset issues.'

UNION ALL

SELECT
    'High escalation rate',
    'Medium/High',
    'Tickets',
    'Access request 36.71%, MFA 33.18%, account lockout 31.02%',
    'High escalation suggests Tier 1 may not have enough access, guidance, or routing clarity.',
    'Review escalation criteria and create clearer routing rules for access request, MFA, and account lockout tickets.';

SELECT * FROM project_findings_summary;
