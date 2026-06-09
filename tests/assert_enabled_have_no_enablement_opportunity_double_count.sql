-- An account already at/above benchmark penetration should show zero expansion opportunity.
select customer_id, penetration_rate, benchmark_penetration, gpv_opportunity_6mo
from {{ ref('mart_account_priority') }}
where customer_state = 'E_enabled_low_penetration'
  and penetration_rate >= benchmark_penetration
  and gpv_opportunity_6mo > 0
