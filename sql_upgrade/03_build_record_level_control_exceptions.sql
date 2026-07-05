-- =====================================================================
-- 03_build_record_level_control_exceptions.sql
-- Synthetic Technology Operations / IT Risk portfolio project
--
-- Purpose:
--   Build a record-level fact_control_exceptions view. Each row is a
--   real exception generated dynamically from the synthetic source data.
--
-- Important scope note:
--   This is an upgraded analytics layer for portfolio demonstration.
--   It does not claim production deployment, real compliance validation,
--   real business impact, real remediation, dollar savings, SLA
--   improvement, or risk reduction.
-- =====================================================================

DROP VIEW IF EXISTS fact_control_exceptions;

CREATE VIEW fact_control_exceptions AS

-- ---------------------------------------------------------------------
-- Exception 1: Terminated user account still active
-- Business question:
--   Are terminated users still active in the user population?
-- Risk:
--   A terminated user with an active account could retain unauthorized
--   access.
-- Control expectation:
--   A terminated user's account should not remain active.
-- Exception logic:
--   employment_status = 'terminated' and account_active_flag = 'TRUE'.
-- ---------------------------------------------------------------------
SELECT
    'EX-USER-ACTIVE-' || user_id AS exception_id,
    'Terminated user account still active' AS exception_type,
    'AC-DEPROV-001' AS control_id,
    'Terminated user deprovisioning' AS control_name,
    user_id,
    NULL AS request_id,
    NULL AS ticket_id,
    NULL AS mfa_event_id,
    NULL AS sample_record_id,
    department,
    NULL AS system_name,
    NULL AS access_level,
    role,
    NULL AS ticket_category,
    'High' AS risk_rating,
    'Terminated user account is still marked active.' AS exception_reason,
    COALESCE(last_login_date, termination_date) AS detected_date,
    'users' AS source_table,
    'Disable the account and review deprovisioning workflow evidence.' AS recommended_action,
    CASE WHEN privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END AS is_privileged_related,
    0 AS is_ticket_workflow_related,
    1 AS is_access_control_related
FROM users
WHERE employment_status = 'terminated'
  AND account_active_flag = 'TRUE'

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 2: Missing access removal date
-- Business question:
--   Is there evidence that terminated-user access was removed?
-- Risk:
--   Missing removal evidence makes it difficult to prove access was
--   disabled after termination.
-- Control expectation:
--   Every terminated user should have a documented access_removed_date.
-- Exception logic:
--   employment_status = 'terminated' and access_removed_date is blank.
-- ---------------------------------------------------------------------
SELECT
    'EX-USER-MISSING-REMOVAL-' || user_id,
    'Missing access removal date',
    'AC-DEPROV-002',
    'Terminated user access removal evidence',
    user_id,
    NULL,
    NULL,
    NULL,
    NULL,
    department,
    NULL,
    NULL,
    role,
    NULL,
    'High',
    'Terminated user does not have an access removal date on file.',
    COALESCE(last_login_date, termination_date),
    'users',
    'Document access removal or investigate whether access is still active.',
    CASE WHEN privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END,
    0,
    1
FROM users
WHERE employment_status = 'terminated'
  AND (access_removed_date IS NULL OR TRIM(access_removed_date) = '')

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 3: Late deprovisioning
-- Business question:
--   Was access removed promptly after termination?
-- Risk:
--   Late access removal extends the unauthorized-access window after a
--   user leaves the organization.
-- Control expectation:
--   This synthetic test allows a 2-day tolerance after termination.
-- Exception logic:
--   access_removed_date is more than 2 days after termination_date.
-- ---------------------------------------------------------------------
SELECT
    'EX-USER-LATE-DEPROV-' || user_id,
    'Late deprovisioning',
    'AC-DEPROV-003',
    'Timely terminated user deprovisioning',
    user_id,
    NULL,
    NULL,
    NULL,
    NULL,
    department,
    NULL,
    NULL,
    role,
    NULL,
    'High',
    'Access was removed more than 2 days after termination.',
    access_removed_date,
    'users',
    'Automate HR-to-IT deprovisioning triggers and review late removals weekly.',
    CASE WHEN privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END,
    0,
    1
FROM users
WHERE employment_status = 'terminated'
  AND access_removed_date IS NOT NULL
  AND TRIM(access_removed_date) <> ''
  AND termination_date IS NOT NULL
  AND TRIM(termination_date) <> ''
  AND julianday(access_removed_date) - julianday(termination_date) > 2

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 4: Login after termination
-- Business question:
--   Did a terminated user show login activity after termination?
-- Risk:
--   Post-termination login activity suggests access may have remained
--   usable after employment ended.
-- Control expectation:
--   No login activity should occur after termination_date.
-- Exception logic:
--   last_login_date is later than termination_date for terminated users.
-- ---------------------------------------------------------------------
SELECT
    'EX-USER-POSTTERM-LOGIN-' || user_id,
    'Login after termination',
    'AC-DEPROV-004',
    'Post-termination login monitoring',
    user_id,
    NULL,
    NULL,
    NULL,
    NULL,
    department,
    NULL,
    NULL,
    role,
    NULL,
    'High',
    'Last login date is after the user termination date.',
    last_login_date,
    'users',
    'Investigate post-termination login activity and confirm account disablement.',
    CASE WHEN privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END,
    0,
    1
FROM users
WHERE employment_status = 'terminated'
  AND last_login_date IS NOT NULL
  AND TRIM(last_login_date) <> ''
  AND termination_date IS NOT NULL
  AND TRIM(termination_date) <> ''
  AND julianday(last_login_date) > julianday(termination_date)

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 5: Privileged user without MFA
-- Business question:
--   Do active privileged users have MFA enabled?
-- Risk:
--   A privileged user without MFA is a high-risk single-factor access
--   exposure.
-- Control expectation:
--   All active privileged users should have MFA enabled.
-- Exception logic:
--   privileged_access_flag = TRUE, mfa_enabled = FALSE, and account is
--   active.
-- ---------------------------------------------------------------------
SELECT
    'EX-USER-PRIV-NO-MFA-' || user_id,
    'Privileged user without MFA',
    'AC-MFA-001',
    'Privileged access MFA enforcement',
    user_id,
    NULL,
    NULL,
    NULL,
    NULL,
    department,
    NULL,
    NULL,
    role,
    NULL,
    'High',
    'Active privileged user does not have MFA enabled.',
    COALESCE(last_login_date, transfer_date),
    'users',
    'Require MFA before privileged access is granted or retained.',
    1,
    0,
    1
FROM users
WHERE privileged_access_flag = 'TRUE'
  AND mfa_enabled = 'FALSE'
  AND account_active_flag = 'TRUE'

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 6: Access provisioned before approval
-- Business question:
--   Was access granted before the request was approved?
-- Risk:
--   If provisioning happens before approval, the approval step is not
--   operating as a true access gate.
-- Control expectation:
--   provisioned_date should be on or after approval_date.
-- Exception logic:
--   approved request with provisioned_date earlier than approval_date.
-- ---------------------------------------------------------------------
SELECT
    'EX-REQ-BEFORE-APPROVAL-' || ar.request_id,
    'Access provisioned before approval',
    'AC-APPROVAL-001',
    'Access approval before provisioning',
    ar.user_id,
    ar.request_id,
    NULL,
    NULL,
    NULL,
    COALESCE(ar.department_at_request, u.department),
    ar.system_requested,
    ar.access_level,
    u.role,
    NULL,
    'Medium/High',
    'Access was provisioned before the approval date.',
    ar.provisioned_date,
    'access_requests',
    'Configure workflow controls to block provisioning until approval exists.',
    CASE WHEN ar.access_level IN ('admin', 'elevated') THEN 1 ELSE 0 END,
    0,
    1
FROM access_requests ar
LEFT JOIN users u
    ON ar.user_id = u.user_id
WHERE ar.approval_status = 'approved'
  AND ar.approval_date IS NOT NULL
  AND TRIM(ar.approval_date) <> ''
  AND ar.provisioned_date IS NOT NULL
  AND TRIM(ar.provisioned_date) <> ''
  AND julianday(ar.provisioned_date) < julianday(ar.approval_date)

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 7: Admin/elevated access provisioned before approval
-- Business question:
--   Did the access-before-approval issue affect high-risk access?
-- Risk:
--   Admin or elevated access before approval is a higher-impact version
--   of the approval control failure.
-- Control expectation:
--   Admin/elevated access should never be provisioned before approval.
-- Exception logic:
--   Same as access provisioned before approval, filtered to admin or
--   elevated access_level.
-- ---------------------------------------------------------------------
SELECT
    'EX-REQ-HIGHRISK-BEFORE-APPROVAL-' || ar.request_id,
    'Admin/elevated access provisioned before approval',
    'AC-APPROVAL-002',
    'High-risk access approval before provisioning',
    ar.user_id,
    ar.request_id,
    NULL,
    NULL,
    NULL,
    COALESCE(ar.department_at_request, u.department),
    ar.system_requested,
    ar.access_level,
    u.role,
    NULL,
    'High',
    'Admin/elevated access was provisioned before approval.',
    ar.provisioned_date,
    'access_requests',
    'Prioritize admin/elevated requests for automated approval enforcement.',
    1,
    0,
    1
FROM access_requests ar
LEFT JOIN users u
    ON ar.user_id = u.user_id
WHERE ar.approval_status = 'approved'
  AND ar.approval_date IS NOT NULL
  AND TRIM(ar.approval_date) <> ''
  AND ar.provisioned_date IS NOT NULL
  AND TRIM(ar.provisioned_date) <> ''
  AND julianday(ar.provisioned_date) < julianday(ar.approval_date)
  AND ar.access_level IN ('admin', 'elevated')

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 8: Missing approver evidence
-- Business question:
--   Do approved/provisioned requests have approver evidence?
-- Risk:
--   Missing approver evidence weakens audit traceability.
-- Control expectation:
--   Approved and provisioned access should have a named approver.
-- Exception logic:
--   approved/provisioned request with blank approver_id.
-- ---------------------------------------------------------------------
SELECT
    'EX-REQ-MISSING-APPROVER-' || ar.request_id,
    'Missing approver evidence',
    'AC-EVIDENCE-001',
    'Access approval evidence completeness',
    ar.user_id,
    ar.request_id,
    NULL,
    NULL,
    NULL,
    COALESCE(ar.department_at_request, u.department),
    ar.system_requested,
    ar.access_level,
    u.role,
    NULL,
    CASE WHEN ar.access_level IN ('admin', 'elevated') THEN 'High' ELSE 'Medium' END,
    'Approved and provisioned access request is missing approver evidence.',
    COALESCE(ar.provisioned_date, ar.approval_date, ar.request_date),
    'access_requests',
    'Require approver evidence before approved requests can be provisioned.',
    CASE WHEN ar.access_level IN ('admin', 'elevated') THEN 1 ELSE 0 END,
    0,
    1
FROM access_requests ar
LEFT JOIN users u
    ON ar.user_id = u.user_id
WHERE ar.approval_status = 'approved'
  AND ar.provisioned_date IS NOT NULL
  AND TRIM(ar.provisioned_date) <> ''
  AND (ar.approver_id IS NULL OR TRIM(ar.approver_id) = '')

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 9: Missing business justification
-- Business question:
--   Do approved/provisioned requests have documented business need?
-- Risk:
--   Missing justification makes it difficult to prove why access was
--   granted.
-- Control expectation:
--   Approved and provisioned access should have business justification.
-- Exception logic:
--   approved/provisioned request where business_justification_present
--   equals FALSE.
-- ---------------------------------------------------------------------
SELECT
    'EX-REQ-MISSING-JUSTIFICATION-' || ar.request_id,
    'Missing business justification',
    'AC-EVIDENCE-002',
    'Access business justification evidence',
    ar.user_id,
    ar.request_id,
    NULL,
    NULL,
    NULL,
    COALESCE(ar.department_at_request, u.department),
    ar.system_requested,
    ar.access_level,
    u.role,
    NULL,
    CASE WHEN ar.access_level IN ('admin', 'elevated') THEN 'High' ELSE 'Medium' END,
    'Approved and provisioned access request is missing business justification.',
    COALESCE(ar.provisioned_date, ar.approval_date, ar.request_date),
    'access_requests',
    'Make business justification mandatory before approval or provisioning.',
    CASE WHEN ar.access_level IN ('admin', 'elevated') THEN 1 ELSE 0 END,
    0,
    1
FROM access_requests ar
LEFT JOIN users u
    ON ar.user_id = u.user_id
WHERE ar.approval_status = 'approved'
  AND ar.provisioned_date IS NOT NULL
  AND TRIM(ar.provisioned_date) <> ''
  AND ar.business_justification_present = 'FALSE'

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 10: SLA breached ticket
-- Business question:
--   Which tickets missed their SLA target?
-- Risk:
--   SLA breaches show access/security support delays and operational
--   bottlenecks.
-- Control expectation:
--   Tickets should be resolved within their assigned SLA target.
-- Exception logic:
--   sla_breach_flag = TRUE.
-- ---------------------------------------------------------------------
SELECT
    'EX-TICKET-SLA-' || t.ticket_id,
    'SLA breached ticket',
    'OPS-SLA-001',
    'IT ticket SLA performance',
    t.user_id,
    NULL,
    t.ticket_id,
    NULL,
    NULL,
    u.department,
    NULL,
    NULL,
    u.role,
    t.category,
    CASE WHEN t.priority IN ('Critical', 'High') THEN 'High' ELSE 'Medium/High' END,
    'Ticket breached its SLA target.',
    COALESCE(t.resolved_date, t.opened_date),
    'tickets',
    'Review staffing, routing, and knowledge base quality for breached categories.',
    CASE WHEN u.privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END,
    1,
    0
FROM tickets t
LEFT JOIN users u
    ON t.user_id = u.user_id
WHERE t.sla_breach_flag = 'TRUE'

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 11: Reopened ticket
-- Business question:
--   Which tickets were reopened after resolution?
-- Risk:
--   Reopened tickets suggest first-contact resolution or root-cause
--   quality issues.
-- Control expectation:
--   Reopen rates should remain low and not cluster in access/security
--   categories.
-- Exception logic:
--   reopened_flag = TRUE.
-- ---------------------------------------------------------------------
SELECT
    'EX-TICKET-REOPENED-' || t.ticket_id,
    'Reopened ticket',
    'OPS-REOPEN-001',
    'IT ticket first-contact resolution quality',
    t.user_id,
    NULL,
    t.ticket_id,
    NULL,
    NULL,
    u.department,
    NULL,
    NULL,
    u.role,
    t.category,
    'Medium',
    'Ticket was reopened after being marked resolved.',
    COALESCE(t.resolved_date, t.opened_date),
    'tickets',
    'Improve knowledge base guidance and first-contact resolution scripts.',
    CASE WHEN u.privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END,
    1,
    0
FROM tickets t
LEFT JOIN users u
    ON t.user_id = u.user_id
WHERE t.reopened_flag = 'TRUE'

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 12: Escalated ticket
-- Business question:
--   Which tickets required escalation beyond normal handling?
-- Risk:
--   High escalation volume suggests routing, access, training, or
--   documentation gaps in the support process.
-- Control expectation:
--   Escalation should be the exception, not the normal path.
-- Exception logic:
--   escalated_flag = TRUE.
-- ---------------------------------------------------------------------
SELECT
    'EX-TICKET-ESCALATED-' || t.ticket_id,
    'Escalated ticket',
    'OPS-ESCALATION-001',
    'IT ticket escalation control',
    t.user_id,
    NULL,
    t.ticket_id,
    NULL,
    NULL,
    u.department,
    NULL,
    NULL,
    u.role,
    t.category,
    'Medium/High',
    'Ticket was escalated beyond normal handling.',
    COALESCE(t.resolved_date, t.opened_date),
    'tickets',
    'Review escalation criteria and improve Tier 1 routing guidance.',
    CASE WHEN u.privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END,
    1,
    0
FROM tickets t
LEFT JOIN users u
    ON t.user_id = u.user_id
WHERE t.escalated_flag = 'TRUE'

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 13: MFA security event risk
-- Business question:
--   Which MFA events suggest support or security friction?
-- Risk:
--   MFA exceptions, unresolved MFA events, or high failed-login counts
--   can signal access friction or elevated authentication risk.
-- Control expectation:
--   MFA exceptions should be limited, resolved, and monitored.
-- Exception logic:
--   mfa_exception_flag = TRUE, resolved_flag = FALSE, or failed_login_count
--   is 5 or more. These are synthetic risk indicators only.
-- ---------------------------------------------------------------------
SELECT
    'EX-MFA-EVENT-' || me.event_id,
    'MFA security event risk',
    'SEC-MFA-002',
    'MFA event monitoring',
    me.user_id,
    NULL,
    NULL,
    me.event_id,
    NULL,
    u.department,
    NULL,
    NULL,
    u.role,
    NULL,
    CASE
        WHEN me.mfa_exception_flag = 'TRUE'
          OR me.resolved_flag = 'FALSE'
          OR CAST(COALESCE(me.failed_login_count, '0') AS INTEGER) >= 10
        THEN 'High'
        ELSE 'Medium/High'
    END,
    'Synthetic MFA event met the portfolio risk threshold for review.',
    me.event_date,
    'mfa_events',
    'Review MFA event details and confirm whether the event needs follow-up.',
    CASE WHEN u.privileged_access_flag = 'TRUE' THEN 1 ELSE 0 END,
    0,
    1
FROM mfa_events me
LEFT JOIN users u
    ON me.user_id = u.user_id
WHERE me.mfa_exception_flag = 'TRUE'
   OR me.resolved_flag = 'FALSE'
   OR CAST(COALESCE(me.failed_login_count, '0') AS INTEGER) >= 5

UNION ALL

-- ---------------------------------------------------------------------
-- Exception 14: Control test exception from sample/control-test evidence
-- Business question:
--   Which synthetic control test samples were marked as exceptions?
-- Risk:
--   Sample/control-test exceptions show audit-style evidence gaps or
--   control failures in the synthetic testing file.
-- Control expectation:
--   Sampled controls should pass or have documented remediation.
-- Exception logic:
--   control_tests.exception_flag = TRUE.
-- ---------------------------------------------------------------------
SELECT
    'EX-CONTROL-SAMPLE-' || control_id,
    'Control test exception (sample/control-test evidence)',
    control_id,
    control_name,
    NULL,
    NULL,
    NULL,
    NULL,
    sample_record_id,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    risk_rating,
    'Sample/control-test evidence exception: ' || COALESCE(exception_reason, 'No exception reason provided.'),
    test_date,
    'control_tests',
    'Review the synthetic sample evidence and document a portfolio remediation action if needed.',
    CASE
        WHEN LOWER(control_name) LIKE '%privileged%'
          OR LOWER(control_name) LIKE '%admin%'
        THEN 1 ELSE 0
    END,
    CASE
        WHEN LOWER(control_name) LIKE '%ticket%'
          OR LOWER(control_name) LIKE '%sla%'
        THEN 1 ELSE 0
    END,
    CASE
        WHEN LOWER(control_name) LIKE '%access%'
          OR LOWER(control_name) LIKE '%mfa%'
          OR LOWER(control_name) LIKE '%approval%'
        THEN 1 ELSE 0
    END
FROM control_tests
WHERE exception_flag = 'TRUE';

