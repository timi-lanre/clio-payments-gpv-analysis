-- int_customer_state: classify every customer into one of six payments states.
-- These states map directly to the GTM motions AMs and CSMs run.
with c as (
    select * from {{ ref('stg_customers') }}
)
select
    *,
    case
        when not is_payments_enabled and is_self_serve_incomplete
            then 'C_self_serve_incomplete'
        when not is_payments_enabled and bills_per_month > 0 and est_billing_vol_6mo_usd > 0
            then 'B_not_enabled_billing'
        when not is_payments_enabled
            then 'A_not_enabled_not_billing'
        when is_payments_enabled and gpv_last_6mo_usd = 0
            then 'D_enabled_no_gpv'
        when is_payments_enabled and penetration_rate < 0.30
            then 'E_enabled_low_penetration'
        else 'F_healthy'
    end as customer_state
from c
