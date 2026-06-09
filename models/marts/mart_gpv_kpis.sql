-- mart_gpv_kpis: weekly KPI pack for the VP of CS dashboard, sliced by team and segment.
{{ config(materialized='table') }}
with p as (
    select * from {{ ref('mart_account_priority') }}
)
select
    owning_team,
    segment,
    count(*)                                                      as accounts,
    countif(is_payments_enabled)                                 as enabled_accounts,
    safe_divide(countif(is_payments_enabled), count(*))          as enablement_rate,
    countif(is_self_serve_incomplete)                            as self_serve_incomplete,
    sum(gpv_last_6mo_usd)                                        as gpv_6mo,
    safe_divide(sum(gpv_last_6mo_usd), nullif(countif(is_payments_enabled),0)) as gpv_per_enabled_acct,
    avg(case when is_payments_enabled then penetration_rate end) as avg_penetration,
    sum(gpv_opportunity_6mo)                                     as gpv_opportunity_6mo,
    countif(priority_tier = 'P1_critical')                       as p1_accounts,
    sum(case when priority_tier = 'P1_critical' then gpv_opportunity_6mo else 0 end) as p1_opportunity
from p
group by 1, 2
