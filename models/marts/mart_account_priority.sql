-- mart_account_priority: the OBT (one big table) that powers the dashboard and the
-- AM/CSM working queues. One row per account with state, opportunity, feasibility,
-- priority tier, and recommended action. This is what self-serve analytics reads.
{{ config(materialized='table') }}
with f as (
    select * from {{ ref('int_account_feasibility') }}
),
ranked as (
    select
        *,
        case when gpv_opportunity_6mo > 0
             then ntile(10) over (order by gpv_opportunity_6mo)
        end as value_decile
    from f
)
select
    customer_id, segment, owning_team, practice_area,
    company_size_employees, arr_usd, tenure_months, health_score,
    is_payments_enabled, is_self_serve_incomplete, is_competitor_locked,
    customer_state,
    est_billing_vol_6mo_usd, gpv_last_6mo_usd, penetration_rate, benchmark_penetration,
    gpv_opportunity_6mo, feasibility_score, value_decile,
    case
        when gpv_opportunity_6mo = 0 then null
        when value_decile >= 8 and feasibility_score >= 60 then 'P1_critical'
        when (value_decile >= 8 and feasibility_score >= 40)
          or (value_decile >= 5 and feasibility_score >= 60) then 'P2_high'
        when value_decile >= 5 or feasibility_score >= 40 then 'P3_medium'
        else 'P4_low'
    end as priority_tier,
    case customer_state
        when 'B_not_enabled_billing'     then 'Assisted enablement - already billing'
        when 'C_self_serve_incomplete'   then 'Complete self-serve attempt (high intent)'
        when 'E_enabled_low_penetration' then 'Drive penetration to benchmark'
        when 'D_enabled_no_gpv'          then 'Activate first transaction'
        when 'A_not_enabled_not_billing' then 'Nurture Manage adoption first'
        else 'Maintain'
    end as recommended_action
from ranked
