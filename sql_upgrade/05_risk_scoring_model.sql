-- =====================================================================
-- 05_risk_scoring_model.sql
-- Synthetic Technology Operations / IT Risk portfolio project
--
-- Purpose:
--   Create risk_scored_exceptions using a transparent rule-based score.
--
-- Important scope note:
--   This is rule-based prioritization for a portfolio dashboard design.
--   It is not machine learning, not a production risk model, and not a
--   real enterprise risk appetite model. It does not prove real risk
--   reduction, compliance validation, or business impact.
-- =====================================================================

DROP VIEW IF EXISTS risk_scored_exceptions;

CREATE VIEW risk_scored_exceptions AS
WITH repeat_context AS (
    SELECT
        exception_id,
        COUNT(*) OVER (PARTITION BY department) AS department_exception_count,
        COUNT(*) OVER (PARTITION BY system_name) AS system_exception_count
    FROM fact_control_exceptions
),
scoring_inputs AS (
    SELECT
        f.exception_id,
        f.exception_type,
        f.control_id,
        f.control_name,
        f.user_id,
        f.request_id,
        f.ticket_id,
        f.mfa_event_id,
        f.sample_record_id,
        f.department,
        f.system_name,
        f.access_level,
        f.role,
        f.ticket_category,
        f.risk_rating,
        f.exception_reason,
        f.detected_date,
        f.source_table,
        f.recommended_action,
        f.is_privileged_related,
        f.is_ticket_workflow_related,
        f.is_access_control_related,
        r.control_owner,
        r.remediation_due_date,
        r.days_open,
        r.status,
        r.overdue_flag,
        COALESCE(rc.department_exception_count, 0) AS department_exception_count,
        COALESCE(rc.system_exception_count, 0) AS system_exception_count,
        CASE
            WHEN f.risk_rating = 'Critical' THEN 10
            WHEN f.risk_rating = 'High' THEN 7
            WHEN f.risk_rating = 'Medium/High' THEN 6
            WHEN f.risk_rating = 'Medium' THEN 4
            WHEN f.risk_rating = 'Low' THEN 2
            ELSE 3
        END AS base_severity_weight,
        CASE WHEN f.is_privileged_related = 1 THEN 2 ELSE 0 END AS privileged_access_weight,
        CASE WHEN COALESCE(r.overdue_flag, 0) = 1 THEN 2 ELSE 0 END AS overdue_weight,
        CASE
            WHEN COALESCE(r.days_open, 0) > 60 THEN 2
            WHEN COALESCE(r.days_open, 0) > 30 THEN 1
            ELSE 0
        END AS aging_weight,
        CASE
            WHEN f.department IS NOT NULL
             AND TRIM(f.department) <> ''
             AND COALESCE(rc.department_exception_count, 0) >= 10
            THEN 1
            WHEN f.system_name IS NOT NULL
             AND TRIM(f.system_name) <> ''
             AND COALESCE(rc.system_exception_count, 0) >= 5
            THEN 1
            ELSE 0
        END AS repeat_department_system_issue_weight,
        CASE WHEN f.is_ticket_workflow_related = 1 THEN 1 ELSE 0 END AS ticket_workflow_issue_weight
    FROM fact_control_exceptions f
    LEFT JOIN fact_remediation_actions r
        ON f.exception_id = r.exception_id
    LEFT JOIN repeat_context rc
        ON f.exception_id = rc.exception_id
),
scored AS (
    SELECT
        *,
        base_severity_weight
        + privileged_access_weight
        + overdue_weight
        + aging_weight
        + repeat_department_system_issue_weight
        + ticket_workflow_issue_weight AS risk_score
    FROM scoring_inputs
)
SELECT
    exception_id,
    exception_type,
    control_id,
    control_name,
    user_id,
    request_id,
    ticket_id,
    mfa_event_id,
    sample_record_id,
    department,
    system_name,
    access_level,
    role,
    ticket_category,
    risk_rating,
    exception_reason,
    detected_date,
    source_table,
    recommended_action,
    is_privileged_related,
    is_ticket_workflow_related,
    is_access_control_related,
    control_owner,
    remediation_due_date,
    days_open,
    status,
    overdue_flag,
    base_severity_weight,
    privileged_access_weight,
    overdue_weight,
    aging_weight,
    repeat_department_system_issue_weight,
    ticket_workflow_issue_weight,
    department_exception_count,
    system_exception_count,
    risk_score,
    CASE
        WHEN risk_score >= 10 THEN 'Critical'
        WHEN risk_score >= 7 THEN 'High'
        WHEN risk_score >= 4 THEN 'Medium'
        ELSE 'Low'
    END AS risk_score_band,
    CASE
        WHEN risk_score >= 10 THEN 1
        WHEN risk_score >= 7 THEN 2
        WHEN risk_score >= 4 THEN 3
        ELSE 4
    END AS priority_rank,
    TRIM(
        CASE WHEN base_severity_weight >= 7 THEN 'High base severity; ' ELSE '' END ||
        CASE WHEN privileged_access_weight > 0 THEN 'Privileged access related; ' ELSE '' END ||
        CASE WHEN overdue_weight > 0 THEN 'Simulated remediation overdue; ' ELSE '' END ||
        CASE WHEN aging_weight > 0 THEN 'Older open item; ' ELSE '' END ||
        CASE WHEN repeat_department_system_issue_weight > 0 THEN 'Repeated department/system pattern; ' ELSE '' END ||
        CASE WHEN ticket_workflow_issue_weight > 0 THEN 'Ticket workflow related; ' ELSE '' END
    ) AS risk_driver_summary
FROM scored;

