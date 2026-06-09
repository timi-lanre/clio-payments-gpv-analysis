-- int_gpv_opportunity: size the incremental 6-month GPV opportunity per account.
-- Benchmark = median penetration rate of healthy enabled accounts.
-- Competitor-locked accounts are excluded from the addressable opportunity.
with state as (
    select * from {{ ref('int_customer_state') }}
),
benchmark as (
    select
        approx_quantiles(penetration_rate, 2)[offset(1)] as benchmark_penetration
    from state
    where customer_state = 'F_healthy'
)
select
    s.*,
    b.benchmark_penetration,
    case
        when s.is_competitor_locked then 0
        when s.customer_state in ('B_not_enabled_billing','C_self_serve_incomplete','D_enabled_no_gpv')
            then s.est_billing_vol_6mo_usd * b.benchmark_penetration
        when s.customer_state = 'E_enabled_low_penetration'
            then greatest(0, b.benchmark_penetration - s.penetration_rate) * s.est_billing_vol_6mo_usd
        else 0
    end as gpv_opportunity_6mo
from state s
cross join benchmark b
