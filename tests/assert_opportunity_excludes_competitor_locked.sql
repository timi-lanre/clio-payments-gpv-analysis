-- Competitor-locked accounts must never carry GPV opportunity.
-- Fails (returns rows) if any locked account has non-zero opportunity.
select customer_id, gpv_opportunity_6mo
from {{ ref('mart_account_priority') }}
where is_competitor_locked and gpv_opportunity_6mo > 0
