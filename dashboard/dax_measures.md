# DAX Measures

These measures use robust TRUE/FALSE handling because Power BI may import flag columns as **text** (`"TRUE"` / `"FALSE"`) or as **boolean** (`TRUE()` / `FALSE()`), depending on how the CSV was exported. Each measure checks for both forms so the dashboard does not silently return 0 if the data type changes.

**Currently used in the MVP dashboard's 4 KPI cards:** Total Users, Total Tickets, SLA Breached Tickets, Privileged Users Without MFA.

**Provided as reference DAX for future expansion (not yet wired to a visual in the current `.pbix`):** Terminated User Access Exceptions, High Risk Findings, Access Before Approval Count, Missing Business Justification Count.

```dax
Total Users =
COUNTROWS ( users )
```

```dax
Total Tickets =
COUNTROWS ( tickets )
```

```dax
SLA Breached Tickets =
CALCULATE (
    COUNTROWS ( tickets ),
    OR ( tickets[sla_breach_flag] = "TRUE", tickets[sla_breach_flag] = TRUE () )
)
```

```dax
SLA Breach Rate =
DIVIDE ( [SLA Breached Tickets], [Total Tickets], 0 )
```

```dax
Privileged Users Without MFA =
CALCULATE (
    COUNTROWS ( users ),
    OR ( users[privileged_access_flag] = "TRUE", users[privileged_access_flag] = TRUE () ),
    OR ( users[mfa_enabled] = "FALSE", users[mfa_enabled] = FALSE () ),
    OR ( users[account_active_flag] = "TRUE", users[account_active_flag] = TRUE () )
)
```

```dax
Terminated User Access Exceptions =
CALCULATE (
    COUNTROWS ( users ),
    users[employment_status] = "terminated",
    OR (
        OR ( users[account_active_flag] = "TRUE", users[account_active_flag] = TRUE () ),
        OR (
            ISBLANK ( users[access_removed_date] ),
            DATEDIFF ( users[termination_date], users[access_removed_date], DAY ) > 2
        )
    )
)
```
> Note: this DAX version approximates the SQL exception logic using DATEDIFF; because DAX cannot express the full multi-condition OR chain from the SQL test as cleanly as SQL can, **the SQL query in `01_access_control_tests.sql` is the authoritative exception logic**. This measure is intended for a KPI card, not for record-level exception validation — use the SQL output (or `project_findings_summary`) for the audited count of 27.

```dax
High Risk Findings =
CALCULATE (
    COUNTROWS ( project_findings_summary ),
    project_findings_summary[risk_rating] = "High"
)
```

```dax
Access Before Approval Count =
CALCULATE (
    COUNTROWS ( access_requests ),
    access_requests[approval_status] = "approved",
    NOT ( ISBLANK ( access_requests[approval_date] ) ),
    NOT ( ISBLANK ( access_requests[provisioned_date] ) ),
    DATEDIFF ( access_requests[provisioned_date], access_requests[approval_date], DAY ) > 0
)
```

```dax
Missing Business Justification Count =
CALCULATE (
    COUNTROWS ( access_requests ),
    access_requests[approval_status] = "approved",
    NOT ( ISBLANK ( access_requests[provisioned_date] ) ),
    OR (
        access_requests[business_justification_present] = "FALSE",
        access_requests[business_justification_present] = FALSE ()
    )
)
```

## Reference values (from SQL testing, not the dashboard)

These are the audited counts from `sql/01_access_control_tests.sql` and `sql/02_ticket_workflow_analysis.sql`. Use them to sanity-check the DAX measures above — if a DAX measure and the SQL result disagree, trust the SQL result and treat the difference as a DAX logic bug to fix, since SQL is the source of truth for this project's exception testing.

| Metric | Value |
|---|---|
| Total users | 500 |
| Total tickets | 3,000 |
| Terminated-user access exceptions | 27 |
| Active privileged users without MFA | 28 (14 System Administrators) |
| Access provisioned before approval | 84 |
| Admin/elevated access provisioned before approval | 25 |
| Missing business justification | 143 |
| Admin/elevated missing business justification | 62 |
| SLA breached tickets | 440 of 3,000 (14.67%) |
