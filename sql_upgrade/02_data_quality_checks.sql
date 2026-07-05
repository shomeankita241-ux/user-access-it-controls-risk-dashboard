-- =====================================================================
-- 02_data_quality_checks.sql
-- Synthetic Technology Operations / IT Risk portfolio project
--
-- Purpose:
--   Create a beginner-defensible data_quality_summary view that checks
--   whether the source data is usable for the upgraded analytics model.
--
-- Important scope note:
--   These checks are for a synthetic portfolio dataset. They do not
--   prove production data quality, real compliance, real remediation,
--   real SLA improvement, or real risk reduction.
-- =====================================================================

DROP VIEW IF EXISTS data_quality_summary;

CREATE VIEW data_quality_summary AS

-- ---------------------------------------------------------------------
-- Duplicate primary identifiers
-- ---------------------------------------------------------------------
-- Why this matters:
--   Power BI relationships and record-level exception views assume that
--   user_id, request_id, ticket_id, event_id, and control_id identify
--   one source record. Duplicate IDs can double-count exceptions.
-- ---------------------------------------------------------------------
SELECT
    'Duplicate user_id values' AS check_name,
    'users' AS source_table,
    COALESCE(SUM(duplicate_count), 0) AS issue_count,
    'Duplicate user IDs can overstate user counts or create ambiguous joins.' AS risk_interpretation,
    'Confirm each synthetic user_id is unique before using it as a dimension key.' AS recommended_fix
FROM (
    SELECT COUNT(*) - 1 AS duplicate_count
    FROM users
    WHERE user_id IS NOT NULL
      AND TRIM(user_id) <> ''
    GROUP BY user_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'Duplicate request_id values',
    'access_requests',
    COALESCE(SUM(duplicate_count), 0),
    'Duplicate request IDs can double-count access exceptions.',
    'Confirm each synthetic request_id is unique before building fact_access_requests.'
FROM (
    SELECT COUNT(*) - 1 AS duplicate_count
    FROM access_requests
    WHERE request_id IS NOT NULL
      AND TRIM(request_id) <> ''
    GROUP BY request_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'Duplicate ticket_id values',
    'tickets',
    COALESCE(SUM(duplicate_count), 0),
    'Duplicate ticket IDs can double-count SLA, reopen, and escalation metrics.',
    'Confirm each synthetic ticket_id is unique before ticket workflow analysis.'
FROM (
    SELECT COUNT(*) - 1 AS duplicate_count
    FROM tickets
    WHERE ticket_id IS NOT NULL
      AND TRIM(ticket_id) <> ''
    GROUP BY ticket_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'Duplicate MFA event_id values',
    'mfa_events',
    COALESCE(SUM(duplicate_count), 0),
    'Duplicate MFA event IDs can overstate MFA event risk indicators.',
    'Confirm each synthetic event_id is unique before using MFA event facts.'
FROM (
    SELECT COUNT(*) - 1 AS duplicate_count
    FROM mfa_events
    WHERE event_id IS NOT NULL
      AND TRIM(event_id) <> ''
    GROUP BY event_id
    HAVING COUNT(*) > 1
)

UNION ALL

SELECT
    'Duplicate control_id values',
    'control_tests',
    COALESCE(SUM(duplicate_count), 0),
    'Duplicate control IDs can make sample/control-test evidence hard to trace.',
    'Confirm each synthetic control_id is unique or add a separate sample row key.'
FROM (
    SELECT COUNT(*) - 1 AS duplicate_count
    FROM control_tests
    WHERE control_id IS NOT NULL
      AND TRIM(control_id) <> ''
    GROUP BY control_id
    HAVING COUNT(*) > 1
)

UNION ALL

-- ---------------------------------------------------------------------
-- Missing primary and foreign identifiers
-- ---------------------------------------------------------------------
SELECT
    'Missing user_id',
    'users',
    COUNT(*),
    'A user record without user_id cannot be joined to access requests, tickets, or MFA events.',
    'Populate user_id or exclude the record from relationship-based reporting.'
FROM users
WHERE user_id IS NULL
   OR TRIM(user_id) = ''

UNION ALL

SELECT
    'Missing request_id',
    'access_requests',
    COUNT(*),
    'An access request without request_id cannot be traced to a specific access workflow record.',
    'Populate request_id before using the record in exception-level reporting.'
FROM access_requests
WHERE request_id IS NULL
   OR TRIM(request_id) = ''

UNION ALL

SELECT
    'Missing ticket_id',
    'tickets',
    COUNT(*),
    'A ticket without ticket_id cannot be traced to a specific service desk record.',
    'Populate ticket_id before ticket-level SLA, reopen, or escalation reporting.'
FROM tickets
WHERE ticket_id IS NULL
   OR TRIM(ticket_id) = ''

UNION ALL

SELECT
    'Missing user_id on access requests',
    'access_requests',
    COUNT(*),
    'An access request without user_id cannot be tied back to the requester population.',
    'Populate user_id or label the record as unassigned before Power BI modeling.'
FROM access_requests
WHERE user_id IS NULL
   OR TRIM(user_id) = ''

UNION ALL

SELECT
    'Missing user_id on tickets',
    'tickets',
    COUNT(*),
    'A ticket without user_id cannot be analyzed by user, department, or role.',
    'Populate user_id or keep the ticket in category-only workflow reporting.'
FROM tickets
WHERE user_id IS NULL
   OR TRIM(user_id) = ''

UNION ALL

SELECT
    'Missing user_id on MFA events',
    'mfa_events',
    COUNT(*),
    'An MFA event without user_id cannot be tied to a user risk profile.',
    'Populate user_id or keep the event in aggregate MFA-event reporting only.'
FROM mfa_events
WHERE user_id IS NULL
   OR TRIM(user_id) = ''

UNION ALL

-- ---------------------------------------------------------------------
-- Orphaned user IDs
-- ---------------------------------------------------------------------
-- Why this matters:
--   A user_id that appears in a fact-like table but not in users cannot
--   be enriched with department, role, MFA status, or employment status.
-- ---------------------------------------------------------------------
SELECT
    'Orphaned access_request user_id',
    'access_requests',
    COUNT(*),
    'The access request references a user_id that does not exist in users.',
    'Add the missing user record or correct the access_requests.user_id value.'
FROM access_requests ar
LEFT JOIN users u
    ON ar.user_id = u.user_id
WHERE ar.user_id IS NOT NULL
  AND TRIM(ar.user_id) <> ''
  AND u.user_id IS NULL

UNION ALL

SELECT
    'Orphaned ticket user_id',
    'tickets',
    COUNT(*),
    'The ticket references a user_id that does not exist in users.',
    'Add the missing user record or correct the tickets.user_id value.'
FROM tickets t
LEFT JOIN users u
    ON t.user_id = u.user_id
WHERE t.user_id IS NOT NULL
  AND TRIM(t.user_id) <> ''
  AND u.user_id IS NULL

UNION ALL

SELECT
    'Orphaned MFA event user_id',
    'mfa_events',
    COUNT(*),
    'The MFA event references a user_id that does not exist in users.',
    'Add the missing user record or correct the mfa_events.user_id value.'
FROM mfa_events me
LEFT JOIN users u
    ON me.user_id = u.user_id
WHERE me.user_id IS NOT NULL
  AND TRIM(me.user_id) <> ''
  AND u.user_id IS NULL

UNION ALL

-- ---------------------------------------------------------------------
-- Missing descriptive fields used by Power BI dimensions
-- ---------------------------------------------------------------------
SELECT
    'Missing user department',
    'users',
    COUNT(*),
    'Missing department limits department-level access risk analysis.',
    'Populate department or use a clearly labeled Unknown department bucket.'
FROM users
WHERE department IS NULL
   OR TRIM(department) = ''

UNION ALL

SELECT
    'Missing request department',
    'access_requests',
    COUNT(*),
    'Missing department_at_request limits access request slicing by department.',
    'Populate department_at_request or inherit department from the user dimension when appropriate.'
FROM access_requests
WHERE department_at_request IS NULL
   OR TRIM(department_at_request) = ''

UNION ALL

SELECT
    'Missing system_requested',
    'access_requests',
    COUNT(*),
    'An access request without system_requested cannot support system-level risk reporting.',
    'Populate system_requested before using the record in dim_system or system visuals.'
FROM access_requests
WHERE system_requested IS NULL
   OR TRIM(system_requested) = ''

UNION ALL

SELECT
    'Missing ticket category',
    'tickets',
    COUNT(*),
    'A ticket without category cannot be included in category-level SLA, reopen, or escalation analysis.',
    'Populate category or use a clearly labeled Unknown category bucket.'
FROM tickets
WHERE category IS NULL
   OR TRIM(category) = ''

UNION ALL

-- ---------------------------------------------------------------------
-- Missing evidence fields used in access control testing
-- ---------------------------------------------------------------------
SELECT
    'Missing approver_id on approved/provisioned requests',
    'access_requests',
    COUNT(*),
    'Approved and provisioned access without approver evidence weakens audit traceability.',
    'Require approver_id before a request can be marked approved or provisioned.'
FROM access_requests
WHERE approval_status = 'approved'
  AND provisioned_date IS NOT NULL
  AND TRIM(provisioned_date) <> ''
  AND (approver_id IS NULL OR TRIM(approver_id) = '')

UNION ALL

SELECT
    'Missing business justification on approved/provisioned requests',
    'access_requests',
    COUNT(*),
    'Approved and provisioned access without business justification is an evidence gap.',
    'Make business justification a required field before approval or provisioning.'
FROM access_requests
WHERE approval_status = 'approved'
  AND provisioned_date IS NOT NULL
  AND TRIM(provisioned_date) <> ''
  AND (
      business_justification_present IS NULL
      OR TRIM(business_justification_present) = ''
      OR business_justification_present = 'FALSE'
  )

UNION ALL

-- ---------------------------------------------------------------------
-- Invalid date ordering checks
-- ---------------------------------------------------------------------
SELECT
    'Approval date before request date',
    'access_requests',
    COUNT(*),
    'Approval before request date suggests a data entry or sequencing issue.',
    'Review request_date and approval_date for the affected synthetic records.'
FROM access_requests
WHERE request_date IS NOT NULL
  AND TRIM(request_date) <> ''
  AND approval_date IS NOT NULL
  AND TRIM(approval_date) <> ''
  AND julianday(approval_date) < julianday(request_date)

UNION ALL

SELECT
    'Provisioned date before request date',
    'access_requests',
    COUNT(*),
    'Provisioning before request date suggests a data entry or workflow sequencing issue.',
    'Review request_date and provisioned_date for the affected synthetic records.'
FROM access_requests
WHERE request_date IS NOT NULL
  AND TRIM(request_date) <> ''
  AND provisioned_date IS NOT NULL
  AND TRIM(provisioned_date) <> ''
  AND julianday(provisioned_date) < julianday(request_date)

UNION ALL

SELECT
    'Ticket resolved before opened',
    'tickets',
    COUNT(*),
    'A resolved date before opened date makes ticket aging and SLA analysis unreliable.',
    'Correct opened_date and resolved_date before dashboard reporting.'
FROM tickets
WHERE opened_date IS NOT NULL
  AND TRIM(opened_date) <> ''
  AND resolved_date IS NOT NULL
  AND TRIM(resolved_date) <> ''
  AND julianday(resolved_date) < julianday(opened_date)

UNION ALL

-- ---------------------------------------------------------------------
-- Inconsistent TRUE/FALSE flag checks
-- ---------------------------------------------------------------------
SELECT
    'Inconsistent TRUE/FALSE flags',
    'users',
    COUNT(*),
    'Flag fields should use TRUE or FALSE so SQL and Power BI measures do not silently miscount.',
    'Standardize users flag values to TRUE or FALSE.'
FROM (
    SELECT department_transfer_flag AS flag_value FROM users
    UNION ALL SELECT old_access_retained_flag FROM users
    UNION ALL SELECT account_active_flag FROM users
    UNION ALL SELECT privileged_access_flag FROM users
    UNION ALL SELECT mfa_enabled FROM users
)
WHERE flag_value IS NOT NULL
  AND TRIM(flag_value) <> ''
  AND UPPER(flag_value) NOT IN ('TRUE', 'FALSE')

UNION ALL

SELECT
    'Inconsistent TRUE/FALSE flags',
    'access_requests',
    COUNT(*),
    'Flag fields should use TRUE or FALSE so access exception measures remain reliable.',
    'Standardize access_requests flag values to TRUE or FALSE.'
FROM (
    SELECT business_justification_present AS flag_value FROM access_requests
    UNION ALL SELECT provisioned_before_approval_flag FROM access_requests
    UNION ALL SELECT missing_approval_flag FROM access_requests
)
WHERE flag_value IS NOT NULL
  AND TRIM(flag_value) <> ''
  AND UPPER(flag_value) NOT IN ('TRUE', 'FALSE')

UNION ALL

SELECT
    'Inconsistent TRUE/FALSE flags',
    'tickets',
    COUNT(*),
    'Flag fields should use TRUE or FALSE so ticket workflow rates remain reliable.',
    'Standardize ticket flag values to TRUE or FALSE.'
FROM (
    SELECT escalated_flag AS flag_value FROM tickets
    UNION ALL SELECT reopened_flag FROM tickets
    UNION ALL SELECT knowledge_base_used FROM tickets
    UNION ALL SELECT sla_breach_flag FROM tickets
)
WHERE flag_value IS NOT NULL
  AND TRIM(flag_value) <> ''
  AND UPPER(flag_value) NOT IN ('TRUE', 'FALSE')

UNION ALL

SELECT
    'Inconsistent TRUE/FALSE flags',
    'mfa_events',
    COUNT(*),
    'Flag fields should use TRUE or FALSE so MFA risk indicators remain reliable.',
    'Standardize MFA event flag values to TRUE or FALSE.'
FROM (
    SELECT mfa_exception_flag AS flag_value FROM mfa_events
    UNION ALL SELECT resolved_flag FROM mfa_events
)
WHERE flag_value IS NOT NULL
  AND TRIM(flag_value) <> ''
  AND UPPER(flag_value) NOT IN ('TRUE', 'FALSE')

UNION ALL

SELECT
    'Inconsistent TRUE/FALSE flags',
    'control_tests',
    COUNT(*),
    'Flag fields should use TRUE or FALSE so sample/control-test evidence is counted correctly.',
    'Standardize control_tests flag values to TRUE or FALSE.'
FROM (
    SELECT exception_flag AS flag_value FROM control_tests
    UNION ALL SELECT evidence_missing_flag FROM control_tests
)
WHERE flag_value IS NOT NULL
  AND TRIM(flag_value) <> ''
  AND UPPER(flag_value) NOT IN ('TRUE', 'FALSE')

UNION ALL

-- ---------------------------------------------------------------------
-- Specific missing status fields requested for dashboard readiness
-- ---------------------------------------------------------------------
SELECT
    'Missing SLA flag',
    'tickets',
    COUNT(*),
    'Missing SLA flag prevents tickets from being counted correctly as breached or not breached.',
    'Populate sla_breach_flag as TRUE or FALSE for every synthetic ticket.'
FROM tickets
WHERE sla_breach_flag IS NULL
   OR TRIM(sla_breach_flag) = ''

UNION ALL

SELECT
    'Missing MFA status',
    'users',
    COUNT(*),
    'Missing MFA status prevents privileged-without-MFA testing from being complete.',
    'Populate mfa_enabled as TRUE or FALSE for every synthetic user.'
FROM users
WHERE mfa_enabled IS NULL
   OR TRIM(mfa_enabled) = '';

