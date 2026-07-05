-- =====================================================================
-- 04_build_remediation_actions.sql
-- Synthetic Technology Operations / IT Risk portfolio project
--
-- Purpose:
--   Create fact_remediation_actions from the record-level
--   fact_control_exceptions view.
--
-- Important scope note:
--   This is simulated remediation tracking for portfolio dashboard
--   design. It is not evidence that real remediation occurred. Do not
--   claim production deployment, real remediation, dollar savings, SLA
--   improvement, real risk reduction, or compliance validation.
-- =====================================================================

DROP VIEW IF EXISTS fact_remediation_actions;

CREATE VIEW fact_remediation_actions AS
WITH remediation_base AS (
    SELECT
        'REM-' || exception_id AS remediation_id,
        exception_id,
        exception_type,
        CASE
            WHEN exception_type = 'MFA security event risk'
            THEN 'Security Operations'
            WHEN is_ticket_workflow_related = 1
            THEN 'IT Service Desk'
            WHEN is_access_control_related = 1
            THEN 'Identity and Access Management'
            ELSE 'Technology Risk'
        END AS control_owner,
        department,
        system_name,
        risk_rating,
        detected_date,
        CASE
            WHEN risk_rating = 'Critical' THEN date(detected_date, '+7 days')
            WHEN risk_rating = 'High' THEN date(detected_date, '+14 days')
            WHEN risk_rating = 'Medium/High' THEN date(detected_date, '+21 days')
            WHEN risk_rating = 'Medium' THEN date(detected_date, '+30 days')
            WHEN risk_rating = 'Low' THEN date(detected_date, '+45 days')
            ELSE date(detected_date, '+30 days')
        END AS remediation_due_date,
        CASE
            WHEN detected_date IS NULL OR TRIM(detected_date) = ''
            THEN NULL
            ELSE CAST(julianday('now') - julianday(detected_date) AS INTEGER)
        END AS days_open,
        CASE
            -- These statuses are simulated labels for dashboard design.
            -- They are not evidence that any real remediation occurred.
            WHEN risk_rating IN ('Critical', 'High')
            THEN 'Open'
            WHEN exception_type IN ('SLA breached ticket', 'Escalated ticket')
            THEN 'In Progress'
            WHEN exception_type = 'Reopened ticket'
            THEN 'Remediated'
            WHEN exception_type = 'Control test exception (sample/control-test evidence)'
            THEN 'Accepted Risk'
            ELSE 'In Progress'
        END AS status,
        CASE
            WHEN exception_type IN (
                'Terminated user account still active',
                'Missing access removal date',
                'Late deprovisioning',
                'Login after termination'
            )
            THEN 'Account disablement evidence and HR termination/access removal support.'
            WHEN exception_type = 'Privileged user without MFA'
            THEN 'MFA enablement evidence or approved temporary exception record.'
            WHEN exception_type IN (
                'Access provisioned before approval',
                'Admin/elevated access provisioned before approval',
                'Missing approver evidence',
                'Missing business justification'
            )
            THEN 'Approval, approver, business justification, and provisioning evidence.'
            WHEN exception_type IN (
                'SLA breached ticket',
                'Reopened ticket',
                'Escalated ticket'
            )
            THEN 'Ticket resolution notes, routing history, SLA target, and support process evidence.'
            WHEN exception_type = 'MFA security event risk'
            THEN 'MFA event details, resolution status, and exception/bypass evidence.'
            ELSE 'Sample/control-test evidence and documented follow-up rationale.'
        END AS evidence_required,
        recommended_action
    FROM fact_control_exceptions
),
remediation_status AS (
    SELECT
        *,
        CASE
            WHEN status IN ('Remediated', 'Accepted Risk')
            THEN 0
            WHEN remediation_due_date IS NOT NULL
             AND julianday('now') > julianday(remediation_due_date)
            THEN 1
            ELSE 0
        END AS overdue_flag
    FROM remediation_base
)
SELECT
    remediation_id,
    exception_id,
    exception_type,
    control_owner,
    department,
    system_name,
    risk_rating,
    detected_date,
    remediation_due_date,
    days_open,
    status,
    overdue_flag,
    evidence_required,
    recommended_action
FROM remediation_status;

