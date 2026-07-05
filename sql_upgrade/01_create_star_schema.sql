-- =====================================================================
-- 01_create_star_schema.sql
-- Portfolio-grade star schema design for a synthetic Technology
-- Operations / IT Risk project.
--
-- Source datasets expected to already exist:
--   users
--   access_requests
--   tickets
--   mfa_events
--   control_tests
--
-- This file creates analytical views that organize the existing
-- synthetic data into dimensions and facts for Power BI.
--
-- Important scope note:
--   This script designs a portfolio-grade model layer. It does not
--   claim that a production data warehouse, live integration, or final
--   upgraded dashboard already exists. Any remediation fields created
--   here are derived for portfolio demonstration only.
-- =====================================================================


-- ---------------------------------------------------------------------
-- dim_user
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   One row per synthetic user. This is the user dimension Power BI can
--   use to slice access requests, MFA events, tickets, and control
--   exceptions by department, user type, role, employment status, and
--   privileged-access status.
--
-- Power BI connection:
--   Join dim_user.user_id to fact tables that include user_id.
--
-- Business/risk questions supported:
--   Which user populations have the most access exceptions?
--   Are privileged users, terminated users, or transferred users driving
--   higher risk?
--
-- Data lineage:
--   Directly from the synthetic users dataset. No real employee data.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS dim_user;

CREATE VIEW dim_user AS
SELECT
    user_id,
    user_type,
    department,
    previous_department,
    department_transfer_flag,
    transfer_date,
    old_access_retained_flag,
    employment_status,
    termination_date,
    access_removed_date,
    account_active_flag,
    role,
    privileged_access_flag,
    mfa_enabled,
    last_login_date
FROM users;


-- ---------------------------------------------------------------------
-- dim_department
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   A clean department lookup for Power BI slicers and visuals.
--
-- Power BI connection:
--   Join department_name to user, access request, or remediation views
--   where department values are present.
--
-- Business/risk questions supported:
--   Which departments have higher access-control or workflow risk?
--
-- Data lineage:
--   Derived from synthetic users and access_requests department fields.
--   This is a convenience dimension for portfolio reporting.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS dim_department;

CREATE VIEW dim_department AS
SELECT DISTINCT
    department AS department_name
FROM users
WHERE department IS NOT NULL
  AND department <> ''

UNION

SELECT DISTINCT
    department_at_request AS department_name
FROM access_requests
WHERE department_at_request IS NOT NULL
  AND department_at_request <> '';


-- ---------------------------------------------------------------------
-- dim_system
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   One row per requested system/application in the synthetic access
--   request data.
--
-- Power BI connection:
--   Join dim_system.system_requested to
--   fact_access_requests.system_requested.
--
-- Business/risk questions supported:
--   Which systems have the most access-before-approval or missing
--   justification exceptions?
--
-- Data lineage:
--   Directly derived from access_requests.system_requested.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS dim_system;

CREATE VIEW dim_system AS
SELECT DISTINCT
    system_requested
FROM access_requests
WHERE system_requested IS NOT NULL
  AND system_requested <> '';


-- ---------------------------------------------------------------------
-- dim_date
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   A portfolio-grade date dimension built from all relevant dates in
--   the synthetic datasets. Power BI can use it for calendar slicers,
--   trend charts, and aging views in future dashboard upgrades.
--
-- Power BI connection:
--   Join dim_date.date_key to date keys in fact views, such as
--   request_date_key, approval_date_key, ticket_opened_date_key, or
--   event_date_key.
--
-- Business/risk questions supported:
--   How do exceptions or workflow risks trend over time?
--
-- Data lineage:
--   Derived from existing synthetic date fields. It does not represent
--   a live calendar or production data warehouse.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS dim_date;

CREATE VIEW dim_date AS
WITH all_dates AS (
    SELECT request_date AS date_value FROM access_requests WHERE request_date IS NOT NULL AND request_date <> ''
    UNION
    SELECT approval_date FROM access_requests WHERE approval_date IS NOT NULL AND approval_date <> ''
    UNION
    SELECT provisioned_date FROM access_requests WHERE provisioned_date IS NOT NULL AND provisioned_date <> ''
    UNION
    SELECT opened_date FROM tickets WHERE opened_date IS NOT NULL AND opened_date <> ''
    UNION
    SELECT resolved_date FROM tickets WHERE resolved_date IS NOT NULL AND resolved_date <> ''
    UNION
    SELECT event_date FROM mfa_events WHERE event_date IS NOT NULL AND event_date <> ''
    UNION
    SELECT test_date FROM control_tests WHERE test_date IS NOT NULL AND test_date <> ''
    UNION
    SELECT termination_date FROM users WHERE termination_date IS NOT NULL AND termination_date <> ''
    UNION
    SELECT access_removed_date FROM users WHERE access_removed_date IS NOT NULL AND access_removed_date <> ''
    UNION
    SELECT last_login_date FROM users WHERE last_login_date IS NOT NULL AND last_login_date <> ''
    UNION
    SELECT transfer_date FROM users WHERE transfer_date IS NOT NULL AND transfer_date <> ''
)
SELECT
    date_value,
    CAST(strftime('%Y%m%d', date_value) AS INTEGER) AS date_key,
    CAST(strftime('%Y', date_value) AS INTEGER) AS year,
    CAST(strftime('%m', date_value) AS INTEGER) AS month_number,
    strftime('%Y-%m', date_value) AS year_month,
    CAST(strftime('%d', date_value) AS INTEGER) AS day_of_month,
    CAST(strftime('%w', date_value) AS INTEGER) AS day_of_week_number
FROM all_dates
WHERE date_value IS NOT NULL
  AND date_value <> '';


-- ---------------------------------------------------------------------
-- dim_control
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   One row per synthetic control test name/objective. This gives Power
--   BI a control-oriented dimension for audit-style reporting.
--
-- Power BI connection:
--   Join dim_control.control_name to
--   fact_control_exceptions.control_name.
--
-- Business/risk questions supported:
--   Which controls have exceptions? Which risk ratings or remediation
--   owners appear most often in the synthetic control test sample?
--
-- Data lineage:
--   Directly from synthetic control_tests. Framework mappings are
--   illustrative and are not compliance validation.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS dim_control;

CREATE VIEW dim_control AS
SELECT DISTINCT
    control_name,
    control_objective,
    test_criteria,
    framework_mapping
FROM control_tests
WHERE control_name IS NOT NULL
  AND control_name <> '';


-- ---------------------------------------------------------------------
-- dim_ticket_category
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   A lookup table for IT ticket categories such as MFA, account
--   lockout, access request, and password reset.
--
-- Power BI connection:
--   Join dim_ticket_category.category to fact_tickets.category.
--
-- Business/risk questions supported:
--   Which ticket categories drive SLA breaches, reopens, or escalations?
--
-- Data lineage:
--   Directly derived from synthetic tickets.category.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS dim_ticket_category;

CREATE VIEW dim_ticket_category AS
SELECT DISTINCT
    category
FROM tickets
WHERE category IS NOT NULL
  AND category <> '';


-- ---------------------------------------------------------------------
-- fact_access_requests
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   One row per synthetic access request, with derived exception flags
--   that Power BI can use for KPI cards, tables, and drill-through
--   pages in future upgrades.
--
-- Power BI connection:
--   Join user_id to dim_user, department_at_request to dim_department,
--   system_requested to dim_system, and date keys to dim_date.
--
-- Business/risk questions supported:
--   Was access provisioned before approval? Are admin/elevated requests
--   missing business justification? Which systems or departments have
--   higher exception counts?
--
-- Data lineage:
--   Request fields are direct from access_requests. The numeric flags
--   are derived from documented SQL-style exception logic for portfolio
--   reporting.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS fact_access_requests;

CREATE VIEW fact_access_requests AS
SELECT
    request_id,
    user_id,
    system_requested,
    access_level,
    department_at_request,
    request_date,
    CAST(strftime('%Y%m%d', request_date) AS INTEGER) AS request_date_key,
    approval_date,
    CAST(strftime('%Y%m%d', approval_date) AS INTEGER) AS approval_date_key,
    provisioned_date,
    CAST(strftime('%Y%m%d', provisioned_date) AS INTEGER) AS provisioned_date_key,
    approver_id,
    approval_status,
    business_justification_present,
    provisioned_before_approval_flag,
    missing_approval_flag,
    CASE
        WHEN approval_status = 'approved'
         AND approval_date IS NOT NULL
         AND approval_date <> ''
         AND provisioned_date IS NOT NULL
         AND provisioned_date <> ''
         AND julianday(provisioned_date) < julianday(approval_date)
        THEN 1 ELSE 0
    END AS access_before_approval_exception,
    CASE
        WHEN approval_status = 'approved'
         AND provisioned_date IS NOT NULL
         AND provisioned_date <> ''
         AND business_justification_present = 'FALSE'
        THEN 1 ELSE 0
    END AS missing_business_justification_exception,
    CASE
        WHEN access_level IN ('admin', 'elevated') THEN 1 ELSE 0
    END AS high_risk_access_flag
FROM access_requests;


-- ---------------------------------------------------------------------
-- fact_mfa_events
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   One row per synthetic MFA/security event.
--
-- Power BI connection:
--   Join user_id to dim_user and event_date_key to dim_date.
--
-- Business/risk questions supported:
--   Which users or event types have MFA support or security friction?
--   How many MFA exceptions or unresolved events exist in the synthetic
--   dataset?
--
-- Data lineage:
--   Event fields are direct from mfa_events. The numeric flags are
--   derived for Power BI-friendly aggregation.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS fact_mfa_events;

CREATE VIEW fact_mfa_events AS
SELECT
    event_id,
    user_id,
    event_date,
    CAST(strftime('%Y%m%d', event_date) AS INTEGER) AS event_date_key,
    event_type,
    failed_login_count,
    mfa_exception_flag,
    resolved_flag,
    CASE WHEN mfa_exception_flag = 'TRUE' THEN 1 ELSE 0 END AS mfa_exception_count,
    CASE WHEN resolved_flag = 'FALSE' THEN 1 ELSE 0 END AS unresolved_event_count
FROM mfa_events;


-- ---------------------------------------------------------------------
-- fact_tickets
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   One row per synthetic IT service desk ticket, with numeric flags for
--   SLA breach, reopen, and escalation analysis.
--
-- Power BI connection:
--   Join user_id to dim_user, category to dim_ticket_category, and date
--   keys to dim_date.
--
-- Business/risk questions supported:
--   Which ticket categories miss SLA, reopen, or escalate most often?
--   Are access/security categories creating operational risk?
--
-- Data lineage:
--   Ticket fields are direct from tickets. Numeric flags are derived for
--   Power BI measures.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS fact_tickets;

CREATE VIEW fact_tickets AS
SELECT
    ticket_id,
    user_id,
    category,
    priority,
    opened_date,
    CAST(strftime('%Y%m%d', opened_date) AS INTEGER) AS opened_date_key,
    resolved_date,
    CAST(strftime('%Y%m%d', resolved_date) AS INTEGER) AS resolved_date_key,
    resolution_hours,
    sla_hours,
    assignment_group,
    escalated_flag,
    reopened_flag,
    knowledge_base_used,
    sla_breach_flag,
    CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END AS sla_breach_count,
    CASE WHEN reopened_flag = 'TRUE' THEN 1 ELSE 0 END AS reopened_count,
    CASE WHEN escalated_flag = 'TRUE' THEN 1 ELSE 0 END AS escalated_count,
    CASE WHEN knowledge_base_used = 'TRUE' THEN 1 ELSE 0 END AS knowledge_base_used_count
FROM tickets;


-- ---------------------------------------------------------------------
-- fact_control_exceptions
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   One row per synthetic control test sample. It turns the audit-style
--   control_tests file into a fact table that Power BI can use for
--   exception counts, risk ratings, owners, and evidence gaps.
--
-- Power BI connection:
--   Join control_name to dim_control and test_date_key to dim_date.
--   sample_record_id can be used for drill-through design in future
--   portfolio upgrades, but it is not a validated production key.
--
-- Business/risk questions supported:
--   Which controls have the most exceptions? Which risk ratings or
--   evidence gaps should be prioritized?
--
-- Data lineage:
--   Directly from synthetic control_tests, with numeric flags derived
--   for aggregation.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS fact_control_exceptions;

CREATE VIEW fact_control_exceptions AS
SELECT
    control_id,
    control_name,
    test_date,
    CAST(strftime('%Y%m%d', test_date) AS INTEGER) AS test_date_key,
    sample_record_id,
    exception_flag,
    exception_reason,
    risk_rating,
    remediation_owner,
    evidence_missing_flag,
    CASE WHEN exception_flag = 'TRUE' THEN 1 ELSE 0 END AS exception_count,
    CASE WHEN evidence_missing_flag = 'TRUE' THEN 1 ELSE 0 END AS evidence_missing_count,
    CASE WHEN risk_rating = 'High' THEN 1 ELSE 0 END AS high_risk_exception_count
FROM control_tests;


-- ---------------------------------------------------------------------
-- fact_remediation_actions
-- ---------------------------------------------------------------------
-- What this table/view is for:
--   A portfolio demonstration remediation fact view. It translates
--   synthetic control exceptions into action-style rows with an owner,
--   suggested status, priority, and due date.
--
-- Power BI connection:
--   Join control_name to dim_control, remediation_owner to owner fields
--   in visuals, and target_due_date_key to dim_date.
--
-- Business/risk questions supported:
--   If this were expanded into a portfolio-grade dashboard, which
--   exceptions would need owners, due dates, status tracking, and aging?
--
-- Data lineage:
--   control_id, control_name, risk_rating, remediation_owner, test_date,
--   and exception_reason are directly from synthetic control_tests.
--   remediation_action_id, action_status, target_due_date, priority_rank,
--   and remediation_note are derived for portfolio demonstration only.
--   They do not prove a real remediation workflow exists.
-- ---------------------------------------------------------------------
DROP VIEW IF EXISTS fact_remediation_actions;

CREATE VIEW fact_remediation_actions AS
SELECT
    'ACT-' || control_id AS remediation_action_id,
    control_id,
    control_name,
    remediation_owner,
    risk_rating,
    exception_reason,
    test_date AS identified_date,
    CAST(strftime('%Y%m%d', test_date) AS INTEGER) AS identified_date_key,
    CASE
        WHEN risk_rating = 'High' THEN date(test_date, '+30 days')
        WHEN risk_rating = 'Medium' THEN date(test_date, '+60 days')
        ELSE date(test_date, '+90 days')
    END AS target_due_date,
    CASE
        WHEN risk_rating = 'High' THEN CAST(strftime('%Y%m%d', date(test_date, '+30 days')) AS INTEGER)
        WHEN risk_rating = 'Medium' THEN CAST(strftime('%Y%m%d', date(test_date, '+60 days')) AS INTEGER)
        ELSE CAST(strftime('%Y%m%d', date(test_date, '+90 days')) AS INTEGER)
    END AS target_due_date_key,
    CASE
        WHEN risk_rating = 'High' THEN 'Proposed - High Priority'
        WHEN risk_rating = 'Medium' THEN 'Proposed - Medium Priority'
        ELSE 'Proposed - Standard Priority'
    END AS action_status,
    CASE
        WHEN risk_rating = 'High' THEN 1
        WHEN risk_rating = 'Medium' THEN 2
        ELSE 3
    END AS priority_rank,
    'Derived portfolio demo action from synthetic control exception. Validate owner, due date, and evidence requirements before making any real-world claim.' AS remediation_note
FROM control_tests
WHERE exception_flag = 'TRUE';

