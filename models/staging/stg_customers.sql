-- stg_customers: one-to-one with the seeded raw data, typed and cleaned.
-- Reads from the dbt seed (customers.csv loaded via `dbt seed`).
with source as (
    select * from {{ ref('customers') }}
)
select
    customer_id,
    segment,
    owning_team,
    cast(company_size_employees as int64)                       as company_size_employees,
    practice_area,
    cast(arr_usd as numeric)                                    as arr_usd,
    cast(tenure_months as int64)                                as tenure_months,
    cast(weekly_active_users as int64)                          as weekly_active_users,
    cast(manage_utilization_score as int64)                     as manage_utilization_score,
    cast(bills_per_month as int64)                              as bills_per_month,
    payments_enabled = 'Yes'                                    as is_payments_enabled,
    coalesce(cast(gpv_last_6mo_usd as numeric), 0)              as gpv_last_6mo_usd,
    cast(time_to_adoption_days as numeric)                      as time_to_adoption_days,
    coalesce(cast(estimated_billing_vol_6mo_usd as numeric), 0) as est_billing_vol_6mo_usd,
    coalesce(cast(payments_penetration_rate as numeric), 0)     as penetration_rate,
    self_serve_attempt_incomplete = 'Yes'                       as is_self_serve_incomplete,
    declined_competitor_contract = 'Yes'                        as is_competitor_locked,
    cast(nps_score as int64)                                    as nps_score,
    health_score,
    cast(gtm_touches_last_90_days as int64)                     as gtm_touches_90d,
    attended_payments_webinar = 'Yes'                           as attended_webinar
from source
