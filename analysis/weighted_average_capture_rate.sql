WITH play_opportunity AS (
  SELECT
    CASE
      WHEN customer_state = 'C_self_serve_incomplete'    THEN '1_self_serve_incomplete'
      WHEN customer_state = 'B_not_enabled_billing'       THEN '2_billing_not_enabled'
      WHEN customer_state = 'E_enabled_low_penetration'   THEN '3_low_penetration_expansion'
      ELSE 'other'
    END AS play,
    SUM(gpv_opportunity_6mo) AS play_gpv_opportunity,
    COUNT(*) AS accounts
  FROM `ae-bootcamp-498005.clio_payments_dev.mart_account_priority`
  WHERE customer_state IN (
    'C_self_serve_incomplete',
    'B_not_enabled_billing',
    'E_enabled_low_penetration'
  )
  GROUP BY play
),

play_capture AS (
  SELECT
    play,
    accounts,
    play_gpv_opportunity,
    CASE play
      WHEN '1_self_serve_incomplete'     THEN 0.55
      WHEN '2_billing_not_enabled'        THEN 0.20
      WHEN '3_low_penetration_expansion'  THEN 0.35
    END AS assumed_capture_rate
  FROM play_opportunity
)

SELECT
  play,
  accounts,
  ROUND(play_gpv_opportunity, 0) AS gpv_opportunity,
  assumed_capture_rate,
  ROUND(play_gpv_opportunity * assumed_capture_rate, 0) AS captured_gpv,
  ROUND(play_gpv_opportunity * assumed_capture_rate * 0.0295, 0) AS gross_fee_revenue
FROM play_capture

UNION ALL

SELECT
  'BLENDED TOTAL' AS play,
  SUM(accounts),
  ROUND(SUM(play_gpv_opportunity), 0),
  ROUND(SUM(play_gpv_opportunity * assumed_capture_rate) / SUM(play_gpv_opportunity), 4) AS blended_capture_rate,
  ROUND(SUM(play_gpv_opportunity * assumed_capture_rate), 0),
  ROUND(SUM(play_gpv_opportunity * assumed_capture_rate) * 0.0295, 0)
FROM play_capture

ORDER BY play;
