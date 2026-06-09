-- int_account_feasibility: enablement-likelihood score (0-100) from the signals
-- the regression identified as predictive. Used to rank the AM trigger queue.
with o as (
    select * from {{ ref('int_gpv_opportunity') }}
),
bounds as (
    select approx_quantiles(bills_per_month, 20)[offset(19)] as bills_p95 from o
)
select
    o.*,
    round(100 * (
        0.45 * least(1.0, o.bills_per_month / nullif(bd.bills_p95, 0))
      + 0.25 * (o.manage_utilization_score / 100.0)
      + 0.15 * case o.health_score when 'Green' then 1.0 when 'Yellow' then 0.5 else 0.1 end
      + 0.15 * case when o.attended_webinar then 1.0 else 0.0 end
    ) * case when o.customer_state = 'C_self_serve_incomplete' then 1.4 else 1.0 end
    , 0) as feasibility_score
from o cross join bounds bd
