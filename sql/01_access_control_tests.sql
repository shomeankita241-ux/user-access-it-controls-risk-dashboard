-- =====================================================================
-- 01_access_control_tests.sql
-- Access-Control Exception Testing & IT Workflow Risk Dashboard
-- Synthetic data only. No real employer, customer, or personal data.
-- =====================================================================
-- This script tests whether user access, MFA, and access-approval
-- controls operated effectively across the synthetic user and
-- access_requests populations.
-- =====================================================================


-- ---------------------------------------------------------------------
-- TEST 1: Terminated-user access exceptions
-- ---------------------------------------------------------------------
-- Business question: Did IT remove system access promptly when an
--   employee's employment was terminated?
-- Risk: A terminated user who keeps active access (or logs in after
--   their termination date) is an unauthorized access risk. This is
--   one of the most commonly cited findings in IT general controls
--   (ITGC) audits.
-- Control expectation: Access should be removed at or shortly after
--   termination (this test uses a 2-day tolerance window), and no
--   login activity should occur after the termination date.
-- Exception logic: A user is flagged if ANY of the following is true:
--   (a) the account is still marked active,
--   (b) there is no recorded access-removal date,
--   (c) access was removed more than 2 days after termination, or
--   (d) the user's last login occurred after their termination date.
-- Recommendation: Automate an HR-to-IT deprovisioning trigger so
--   access removal happens on or before the termination date, and
--   build a weekly exception report for any terminated user who still
--   shows account activity.
-- Result in this dataset: 27 exceptions (see project_findings_summary).
-- ---------------------------------------------------------------------

SELECT
    user_id,
    department,
    role,
    termination_date,
    access_removed_date,
    account_active_flag,
    last_login_date,
    CASE
        WHEN account_active_flag = 'TRUE' THEN 'Account still active'
        WHEN access_removed_date IS NULL OR access_removed_date = '' THEN 'Missing access removal date'
        WHEN julianday(access_removed_date) - julianday(termination_date) > 2 THEN 'Late deprovisioning'
        WHEN julianday(last_login_date) > julianday(termination_date) THEN 'Login after termination'
        ELSE 'Other exception'
    END AS exception_reason
FROM users
WHERE employment_status = 'terminated'
  AND (
      account_active_flag = 'TRUE'
      OR access_removed_date IS NULL
      OR access_removed_date = ''
      OR julianday(access_removed_date) - julianday(termination_date) > 2
      OR julianday(last_login_date) > julianday(termination_date)
  );

-- Summary version: exception count by reason (useful for the dashboard)
SELECT
    CASE
        WHEN account_active_flag = 'TRUE' THEN 'Account still active'
        WHEN access_removed_date IS NULL OR access_removed_date = '' THEN 'Missing access removal date'
        WHEN julianday(access_removed_date) - julianday(termination_date) > 2 THEN 'Late deprovisioning'
        WHEN julianday(last_login_date) > julianday(termination_date) THEN 'Login after termination'
        ELSE 'Other exception'
    END AS exception_reason,
    COUNT(*) AS exception_count
FROM users
WHERE employment_status = 'terminated'
  AND (
      account_active_flag = 'TRUE'
      OR access_removed_date IS NULL
      OR access_removed_date = ''
      OR julianday(access_removed_date) - julianday(termination_date) > 2
      OR julianday(last_login_date) > julianday(termination_date)
  )
GROUP BY exception_reason
ORDER BY exception_count DESC;


-- ---------------------------------------------------------------------
-- TEST 2: Privileged (active) users without MFA
-- ---------------------------------------------------------------------
-- Business question: Do all active users with elevated/admin access
--   have multi-factor authentication (MFA) enabled?
-- Risk: Privileged accounts (admins, System Administrators, etc.) are
--   the highest-value target for credential theft and account
--   takeover. A privileged account without MFA is a single-factor
--   control failure on the most sensitive population of users.
-- Control expectation: 100% of active, privileged-access users should
--   have MFA enabled before elevated access is used.
-- Exception logic: Active user, privileged_access_flag = TRUE, and
--   mfa_enabled = FALSE.
-- Recommendation: Enforce MFA as a hard prerequisite for granting or
--   retaining privileged access (a conditional access policy, not a
--   manual step), and review privileged-MFA exceptions weekly.
-- Result in this dataset: 28 exceptions, including 14 System
--   Administrators (see project_findings_summary).
-- ---------------------------------------------------------------------

SELECT
    user_id,
    department,
    role,
    privileged_access_flag,
    mfa_enabled,
    account_active_flag,
    employment_status
FROM users
WHERE privileged_access_flag = 'TRUE'
  AND mfa_enabled = 'FALSE'
  AND account_active_flag = 'TRUE';

-- Breakdown by department
SELECT
    department,
    COUNT(*) AS privileged_without_mfa_count
FROM users
WHERE privileged_access_flag = 'TRUE'
  AND mfa_enabled = 'FALSE'
  AND account_active_flag = 'TRUE'
GROUP BY department
ORDER BY privileged_without_mfa_count DESC;

-- Breakdown by role (used to confirm the 14 System Administrator count)
SELECT
    role,
    COUNT(*) AS privileged_without_mfa_count
FROM users
WHERE privileged_access_flag = 'TRUE'
  AND mfa_enabled = 'FALSE'
  AND account_active_flag = 'TRUE'
GROUP BY role
ORDER BY privileged_without_mfa_count DESC;


-- ---------------------------------------------------------------------
-- TEST 3: Access provisioned before approval
-- ---------------------------------------------------------------------
-- Business question: Was access ever granted (provisioned) to a
--   system before the request was actually approved?
-- Risk: If provisioning can happen before approval, the approval
--   control is not operating effectively -- it exists on paper but
--   does not actually gate access. This is a classic "design vs.
--   operating effectiveness" finding in IT audit.
-- Control expectation: provisioned_date should always be on or after
--   approval_date for approved requests.
-- Exception logic: approval_status = 'approved' AND provisioned_date
--   is earlier (by calendar date) than approval_date.
-- Recommendation: Configure the access-request workflow tool to
--   technically block provisioning until an approval record exists
--   (a system control), rather than relying on staff to follow the
--   process correctly (a manual control).
-- Result in this dataset: 84 exceptions overall; 25 of those involve
--   admin/elevated access (see Test 4 and project_findings_summary).
-- ---------------------------------------------------------------------

SELECT
    request_id,
    user_id,
    system_requested,
    access_level,
    request_date,
    approval_date,
    provisioned_date,
    approval_status,
    business_justification_present
FROM access_requests
WHERE approval_status = 'approved'
  AND approval_date IS NOT NULL
  AND provisioned_date IS NOT NULL
  AND julianday(provisioned_date) < julianday(approval_date);

-- Breakdown by system and access level
SELECT
    system_requested,
    access_level,
    COUNT(*) AS access_before_approval_count
FROM access_requests
WHERE approval_status = 'approved'
  AND approval_date IS NOT NULL
  AND provisioned_date IS NOT NULL
  AND julianday(provisioned_date) < julianday(approval_date)
GROUP BY system_requested, access_level
ORDER BY access_before_approval_count DESC;


-- ---------------------------------------------------------------------
-- TEST 4: High-risk (admin/elevated) access provisioned before approval
-- ---------------------------------------------------------------------
-- Business question: Of the "provisioned before approval" exceptions,
--   how many involve the highest-risk access levels (admin/elevated)?
-- Risk: The same control gap as Test 3, but concentrated on the
--   accounts capable of the most damage if misused -- this is why
--   audit and risk teams typically prioritize high-risk populations
--   for remediation first.
-- Control expectation: Admin/elevated access should never be
--   provisioned ahead of approval; this population should have zero
--   tolerance, not just a lower error rate than standard access.
-- Exception logic: Same as Test 3, filtered to access_level IN
--   ('admin', 'elevated').
-- Recommendation: Prioritize admin/elevated requests for automated
--   approval enforcement and include them in monthly high-risk
--   exception reviews with system owners.
-- Result in this dataset: 25 exceptions.
-- ---------------------------------------------------------------------

SELECT
    request_id,
    user_id,
    system_requested,
    access_level,
    request_date,
    approval_date,
    provisioned_date,
    business_justification_present
FROM access_requests
WHERE approval_status = 'approved'
  AND approval_date IS NOT NULL
  AND provisioned_date IS NOT NULL
  AND julianday(provisioned_date) < julianday(approval_date)
  AND access_level IN ('admin', 'elevated')
ORDER BY system_requested, access_level;


-- ---------------------------------------------------------------------
-- TEST 5: Missing business justification on approved/provisioned access
-- ---------------------------------------------------------------------
-- Business question: Do approved and provisioned access requests have
--   documented business justification on file?
-- Risk: Missing justification is an evidence/documentation control
--   gap. Even if access was appropriate, the organization cannot
--   demonstrate WHY it was granted, which is a common finding in
--   compliance and audit reviews (e.g., SOX, SOC 2, ISO 27001).
-- Control expectation: Every approved, provisioned request should
--   have business_justification_present = TRUE on file.
-- Exception logic: approval_status = 'approved', provisioned_date is
--   not null, and business_justification_present = 'FALSE'.
-- Recommendation: Make business justification a required field in
--   the access-request form so a request cannot be submitted or
--   approved without it.
-- Result in this dataset: 143 exceptions overall; 62 of those involve
--   admin/elevated access (see Test 6).
-- ---------------------------------------------------------------------

SELECT
    request_id,
    user_id,
    system_requested,
    access_level,
    request_date,
    approval_date,
    provisioned_date,
    approval_status,
    approver_id,
    business_justification_present
FROM access_requests
WHERE approval_status = 'approved'
  AND provisioned_date IS NOT NULL
  AND business_justification_present = 'FALSE';

-- Broader evidence-quality view: also flags missing approver evidence
SELECT
    CASE
        WHEN (approver_id IS NULL OR approver_id = '')
             AND business_justification_present = 'FALSE'
        THEN 'Missing approver and business justification'
        WHEN approver_id IS NULL OR approver_id = ''
        THEN 'Missing approver evidence'
        WHEN business_justification_present = 'FALSE'
        THEN 'Missing business justification'
        ELSE 'Other evidence issue'
    END AS evidence_issue,
    COUNT(*) AS issue_count
FROM access_requests
WHERE approval_status = 'approved'
  AND provisioned_date IS NOT NULL
  AND (
      approver_id IS NULL
      OR approver_id = ''
      OR business_justification_present = 'FALSE'
  )
GROUP BY evidence_issue
ORDER BY issue_count DESC;


-- ---------------------------------------------------------------------
-- TEST 6: High-risk (admin/elevated) missing business justification
-- ---------------------------------------------------------------------
-- Business question: Of the missing-justification exceptions, how
--   many involve admin/elevated access?
-- Risk: Same evidence gap as Test 5, concentrated on the population
--   where undocumented access is most dangerous if it is later
--   questioned or misused.
-- Control expectation: Admin/elevated requests should have the
--   strongest documentation standard, not the same minimum bar as
--   standard access.
-- Exception logic: Same as Test 5, filtered to access_level IN
--   ('admin', 'elevated').
-- Recommendation: Require a written justification and a named
--   business sponsor for all admin/elevated requests, and review
--   these monthly with department leadership.
-- Result in this dataset: 62 exceptions.
-- ---------------------------------------------------------------------

SELECT
    system_requested,
    access_level,
    COUNT(*) AS missing_evidence_count
FROM access_requests
WHERE approval_status = 'approved'
  AND provisioned_date IS NOT NULL
  AND access_level IN ('admin', 'elevated')
  AND (
      approver_id IS NULL
      OR approver_id = ''
      OR business_justification_present = 'FALSE'
  )
GROUP BY system_requested, access_level
ORDER BY missing_evidence_count DESC;
