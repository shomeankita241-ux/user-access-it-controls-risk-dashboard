-- =====================================================================
-- 02_ticket_workflow_analysis.sql
-- Access-Control Exception Testing & IT Workflow Risk Dashboard
-- Synthetic data only. No real employer, customer, or personal data.
-- =====================================================================
-- This script analyzes IT service desk ticket workflow performance
-- (3,000 synthetic tickets) to identify categories with the highest
-- SLA breach, reopen, and escalation rates. These metrics indicate
-- where the IT operational process -- not just the access controls
-- above -- may be creating risk (slow account lockout response, MFA
-- support friction, etc.).
-- =====================================================================


-- ---------------------------------------------------------------------
-- TEST 7: SLA breach rate by ticket category
-- ---------------------------------------------------------------------
-- Business question: Which ticket categories most often miss their
--   Service Level Agreement (SLA) resolution target?
-- Risk: Slow resolution of access-related and security tickets (e.g.,
--   account lockout, MFA, access request) extends the window in
--   which a user cannot work, or in which a security issue remains
--   unresolved. Chronic SLA breaches also signal understaffing or
--   process bottlenecks.
-- Control expectation: SLA breach rate should be low and evenly
--   distributed; no single category should be a persistent outlier.
-- Exception logic: sla_breach_flag = 'TRUE', aggregated as a rate
--   (breaches / total tickets) per category.
-- Recommendation: Review staffing, routing rules, and knowledge base
--   quality for the highest-breach categories first.
-- Result in this dataset: 440 of 3,000 tickets breached SLA overall.
--   Highest categories: access request 23.42%, MFA 19.59%, account
--   lockout 16.87%.
-- ---------------------------------------------------------------------

SELECT
    category,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END) AS sla_breaches,
    ROUND(
        100.0 * SUM(CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS sla_breach_rate_percent
FROM tickets
GROUP BY category
ORDER BY sla_breach_rate_percent DESC;

-- Overall SLA breach total (used for the headline KPI: 440 of 3,000)
SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END) AS sla_breached_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS overall_sla_breach_rate_percent
FROM tickets;


-- ---------------------------------------------------------------------
-- TEST 8: Reopened ticket rate by category
-- ---------------------------------------------------------------------
-- Business question: Which ticket categories are most often reopened
--   after being marked resolved?
-- Risk: A high reopen rate suggests the issue was not actually fixed
--   the first time -- either the fix was incomplete, the user did not
--   understand the resolution, or the root cause was not addressed.
--   For access-related tickets (account lockout, MFA, password
--   reset), a reopen also means the user experienced an extended
--   access outage.
-- Control expectation: Reopen rate should be low and should not be
--   concentrated in access/security categories.
-- Exception logic: reopened_flag = 'TRUE', aggregated as a rate per
--   category.
-- Recommendation: Improve knowledge base articles and first-contact
--   resolution scripts for the highest-reopen categories.
-- Result in this dataset: account lockout 23.08%, MFA 21.48%,
--   password reset 20.68%.
-- ---------------------------------------------------------------------

SELECT
    category,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN reopened_flag = 'TRUE' THEN 1 ELSE 0 END) AS reopened_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN reopened_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS reopened_rate_percent
FROM tickets
GROUP BY category
ORDER BY reopened_rate_percent DESC;


-- ---------------------------------------------------------------------
-- TEST 9: Escalation rate by category
-- ---------------------------------------------------------------------
-- Business question: Which ticket categories are most often escalated
--   beyond the first tier of support?
-- Risk: A high escalation rate suggests Tier 1 support may lack the
--   access, training, or documented process to resolve these ticket
--   types, adding time and cost to every request. For access and
--   security categories, escalation also adds delay to something
--   that may be time-sensitive (e.g., a locked-out user, an MFA
--   issue blocking login).
-- Control expectation: Escalation should be the exception, not a
--   routine step, for any single category.
-- Exception logic: escalated_flag = 'TRUE', aggregated as a rate per
--   category.
-- Recommendation: Review escalation criteria and create clearer
--   Tier 1 routing/resolution guidance for the highest-escalation
--   categories.
-- Result in this dataset: access request 36.71%, MFA 33.18%, account
--   lockout 31.02%.
-- ---------------------------------------------------------------------

SELECT
    category,
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN escalated_flag = 'TRUE' THEN 1 ELSE 0 END) AS escalated_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN escalated_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS escalation_rate_percent
FROM tickets
GROUP BY category
ORDER BY escalation_rate_percent DESC;


-- ---------------------------------------------------------------------
-- Supplementary: combined workflow risk view (all three rates together)
-- ---------------------------------------------------------------------
-- Useful for a single "ticket workflow risk" table in the dashboard,
-- showing SLA breach, reopen, and escalation rate side by side per
-- category so the three highest-risk categories (access request,
-- MFA, account lockout) are easy to see together.
-- ---------------------------------------------------------------------

SELECT
    category,
    COUNT(*) AS total_tickets,
    ROUND(100.0 * SUM(CASE WHEN sla_breach_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS sla_breach_rate_percent,
    ROUND(100.0 * SUM(CASE WHEN reopened_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS reopened_rate_percent,
    ROUND(100.0 * SUM(CASE WHEN escalated_flag = 'TRUE' THEN 1 ELSE 0 END) / COUNT(*), 2) AS escalation_rate_percent
FROM tickets
GROUP BY category
ORDER BY sla_breach_rate_percent DESC;
