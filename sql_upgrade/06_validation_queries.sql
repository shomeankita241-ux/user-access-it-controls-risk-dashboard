-- =====================================================================
-- 06_validation_queries.sql
-- Synthetic Technology Operations / IT Risk portfolio project
--
-- Purpose:
--   Reconcile the upgraded record-level exception logic back to the
--   original documented findings.
--
-- Important scope note:
--   These are validation SELECT queries only. They do not claim the
--   Power BI dashboard has been upgraded, and they do not prove real
--   production deployment, compliance validation, remediation, dollar
--   savings, SLA improvement, or risk reduction.
--
-- How to read the output:
--   PASS means the upgraded logic matches the documented synthetic-data
--   finding. REVIEW means the count or category order differs and the
--   filter should be inspected.
-- =====================================================================

WITH
validation_counts AS (
    SELECT
        'Terminated-user access exceptions' AS validation_name,
        '27' AS expected_result,
        CAST(COUNT(DISTINCT user_id) AS TEXT) AS actual_result,
        'Uses DISTINCT user_id across the four terminated-user exception types because the record-level view can contain more than one exception row for the same user.' AS notes
    FROM fact_control_exceptions
    WHERE exception_type IN (
        'Terminated user account still active',
        'Missing access removal date',
        'Late deprovisioning',
        'Login after termination'
    )

    UNION ALL

    SELECT
        'Active privileged users without MFA',
        '28',
        CAST(COUNT(*) AS TEXT),
        'Uses the active account filter from the original SQL: privileged_access_flag = TRUE, mfa_enabled = FALSE, account_active_flag = TRUE.'
    FROM fact_control_exceptions
    WHERE exception_type = 'Privileged user without MFA'

    UNION ALL

    SELECT
        'Access provisioned before approval',
        '84',
        CAST(COUNT(*) AS TEXT),
        'Uses the broad access-before-approval exception type, including all access levels.'
    FROM fact_control_exceptions
    WHERE exception_type = 'Access provisioned before approval'

    UNION ALL

    SELECT
        'Admin/elevated access before approval',
        '25',
        CAST(COUNT(*) AS TEXT),
        'Uses the admin/elevated high-risk subset of access-before-approval exceptions.'
    FROM fact_control_exceptions
    WHERE exception_type = 'Admin/elevated access provisioned before approval'

    UNION ALL

    SELECT
        'Missing business justification',
        '143',
        CAST(COUNT(*) AS TEXT),
        'Uses approved/provisioned requests where business_justification_present = FALSE.'
    FROM fact_control_exceptions
    WHERE exception_type = 'Missing business justification'

    UNION ALL

    SELECT
        'Admin/elevated missing business justification',
        '62',
        CAST(COUNT(*) AS TEXT),
        'Uses missing business justification exceptions filtered to admin/elevated access_level.'
    FROM fact_control_exceptions
    WHERE exception_type = 'Missing business justification'
      AND access_level IN ('admin', 'elevated')

    UNION ALL

    SELECT
        'SLA breached tickets',
        '440 of 3000',
        CAST(SUM(CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END) AS TEXT)
            || ' of '
            || CAST(COUNT(*) AS TEXT),
        'Uses the original ticket table so both numerator and denominator are visible.'
    FROM tickets
),
sla_ranked AS (
    SELECT
        category,
        ROUND(100.0 * SUM(CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS rate_percent
    FROM tickets
    GROUP BY category
),
sla_actual AS (
    SELECT
        GROUP_CONCAT(category || ' ' || printf('%.2f%%', rate_percent), ', ') AS actual_result
    FROM (
        SELECT category, rate_percent
        FROM sla_ranked
        ORDER BY rate_percent DESC, category
        LIMIT 3
    )
),
reopen_ranked AS (
    SELECT
        category,
        ROUND(100.0 * SUM(CASE WHEN reopened_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS rate_percent
    FROM tickets
    GROUP BY category
),
reopen_actual AS (
    SELECT
        GROUP_CONCAT(category || ' ' || printf('%.2f%%', rate_percent), ', ') AS actual_result
    FROM (
        SELECT category, rate_percent
        FROM reopen_ranked
        ORDER BY rate_percent DESC, category
        LIMIT 3
    )
),
escalation_ranked AS (
    SELECT
        category,
        ROUND(100.0 * SUM(CASE WHEN escalated_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS rate_percent
    FROM tickets
    GROUP BY category
),
escalation_actual AS (
    SELECT
        GROUP_CONCAT(category || ' ' || printf('%.2f%%', rate_percent), ', ') AS actual_result
    FROM (
        SELECT category, rate_percent
        FROM escalation_ranked
        ORDER BY rate_percent DESC, category
        LIMIT 3
    )
),
all_validations AS (
    SELECT
        validation_name,
        expected_result,
        actual_result,
        notes
    FROM validation_counts

    UNION ALL

    SELECT
        'Highest SLA breach categories',
        'access request 23.42%, MFA 19.59%, account lockout 16.87%',
        actual_result,
        'Compares the top 3 SLA breach categories and rates from the source tickets table.'
    FROM sla_actual

    UNION ALL

    SELECT
        'Highest reopened ticket categories',
        'account lockout 23.08%, MFA 21.48%, password reset 20.68%',
        actual_result,
        'Compares the top 3 reopened ticket categories and rates from the source tickets table.'
    FROM reopen_actual

    UNION ALL

    SELECT
        'Highest escalation categories',
        'access request 36.71%, MFA 33.18%, account lockout 31.02%',
        actual_result,
        'Compares the top 3 escalation categories and rates from the source tickets table.'
    FROM escalation_actual
)
SELECT
    validation_name,
    expected_result,
    actual_result,
    CASE
        WHEN expected_result = actual_result THEN 'PASS'
        ELSE 'REVIEW'
    END AS validation_status,
    CASE
        WHEN expected_result = actual_result THEN notes
        ELSE notes || ' If this row shows REVIEW, inspect whether the upgraded record-level filter is intentionally broader or narrower than the original documented SQL.'
    END AS notes
FROM all_validations;

