# Data Dictionary — Access-Control Exception Testing & IT Workflow Risk Dashboard

This synthetic dataset is designed for a Technology Risk / IT Audit / Business Systems Analytics portfolio project. It does not contain real employer data.

## 1. users.csv
| Column | Meaning | Why it matters |
|---|---|---|
| user_id | Unique synthetic user identifier | Primary key used to join users to tickets, MFA events, and access requests |
| user_type | staff, faculty, student_worker, contractor, admin | Different populations may carry different access risks |
| department | Current department | Supports department-level risk reporting |
| previous_department | Prior department for transferred users | Helps test access creep after transfers |
| department_transfer_flag | Whether the user changed departments | Used to test whether old access was removed after transfer |
| transfer_date | Date of department transfer | Helps assess whether access review occurred after transfer |
| old_access_retained_flag | Whether old access appears retained | Potential access creep exception |
| employment_status | active, terminated, leave, transferred | Used for deprovisioning and active-access testing |
| termination_date | User end date | Required to test late deprovisioning and post-termination logins |
| access_removed_date | Date access was removed | Used to test whether removal happened within policy |
| account_active_flag | Whether the account is still active | Key field for terminated-user active exceptions |
| role | Business/technical role | Helps contextualize access risk |
| privileged_access_flag | Whether user has elevated/admin access | Privileged users carry higher risk |
| mfa_enabled | Whether MFA is enabled | Used to test privileged users without MFA |
| last_login_date | Most recent login date | Used to detect post-termination activity |

## 2. access_requests.csv
| Column | Meaning | Why it matters |
|---|---|---|
| request_id | Unique synthetic access request identifier | Primary key for access-request testing |
| user_id | User requesting access | Foreign key to users.csv |
| system_requested | Application/system requested | Helps identify high-risk systems |
| access_level | standard, elevated, admin | Higher levels require stronger controls |
| department_at_request | Department tied to request | Supports transfer/access creep analysis |
| request_date | Date access was requested | Starting point of approval workflow |
| approval_date | Date access was approved | Used to test timing and completeness of approval |
| provisioned_date | Date access was granted | Used to detect access granted before approval |
| approver_id | Synthetic approver user ID | Evidence that approval occurred |
| approval_status | approved, pending, denied | Indicates workflow outcome |
| business_justification_present | Whether justification exists | Missing justification is a control evidence issue |
| provisioned_before_approval_flag | Access granted before approval | Direct operating effectiveness exception |
| missing_approval_flag | Provisioned without documented approval | Direct evidence/control gap |

## 3. mfa_events.csv
| Column | Meaning | Why it matters |
|---|---|---|
| event_id | Unique MFA/security event ID | Primary key for MFA analysis |
| user_id | User tied to MFA event | Foreign key to users.csv |
| event_date | Date of MFA event | Supports trend analysis |
| event_type | reset, failed_login, bypass_request, device_change | Categorizes MFA risk and support workload |
| failed_login_count | Count of failed attempts tied to event | Higher counts may indicate user friction or security concern |
| mfa_exception_flag | Whether MFA exception/bypass exists | Used to detect risky MFA exceptions |
| resolved_flag | Whether event was resolved | Supports operational risk analysis |

## 4. tickets.csv
| Column | Meaning | Why it matters |
|---|---|---|
| ticket_id | Unique ticket identifier | Primary key for ticket analysis |
| user_id | User tied to ticket | Foreign key to users.csv |
| category | Ticket category | Used to identify high-risk/high-volume workflows |
| priority | Critical, High, Medium, Low | Determines SLA target |
| opened_date | Ticket open date | Used for aging/trend analysis |
| resolved_date | Ticket resolved date | Used for resolution time and SLA calculations |
| resolution_hours | Hours to resolve | Used to calculate SLA performance |
| sla_hours | SLA target by priority | Benchmark for SLA breach testing |
| assignment_group | Support group assigned | Helps identify routing/escalation issues |
| escalated_flag | Whether ticket was escalated | High escalation may show weak Tier 1 process or routing |
| reopened_flag | Whether ticket was reopened | Reopens may indicate unresolved root cause |
| knowledge_base_used | Whether KB article was used | Helps assess self-service/process improvement opportunity |
| sla_breach_flag | Whether SLA was breached | Core IT workflow risk metric |

## 5. control_tests.csv
| Column | Meaning | Why it matters |
|---|---|---|
| control_id | Unique control test sample ID | Primary key for control testing |
| control_name | Name of tested control | Defines the control being evaluated |
| control_objective | What the control is intended to achieve | Helps connect process to risk |
| test_criteria | How the control is tested | Shows audit/testing logic |
| test_date | Date of test | Supports evidence timeline |
| sample_record_id | Related sampled user/request/ticket | Traceable evidence sample |
| exception_flag | Whether the test found an exception | Core control testing outcome |
| exception_reason | Why the item failed | Explains control gap |
| risk_rating | High, Medium, Low | Prioritizes remediation |
| remediation_owner | Owner responsible for fixing issue | Supports action tracking |
| evidence_missing_flag | Whether evidence was missing | Missing evidence is a control issue even if process occurred |
| framework_mapping | Light NIST/CIS mapping | Connects findings to recognized control language |
