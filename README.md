# Clio Payments GPV: dbt + BigQuery Analytics Model

A scalable, repeatable analytics model for tracking and growing Payments GPV through
AM and CSM led motions. Built on BigQuery with dbt, fed by a version controlled seed,
and surfaced through a Looker Studio dashboard.

## The headline

A $335M incremental GPV opportunity over six months, concentrated in three plays:

- **$109M** from 1,132 accounts billing through Manage but not yet enabled
- **$106M** from 269 self serve incomplete accounts, the warmest and highest intent group in the base
- **$121M** from 215 enabled accounts underpenetrated against the 67% benchmark

Billing volume is the dominant driver of both enablement and GPV. The model prioritizes
by value and feasibility, surfacing 123 P1 accounts that hold $223M of the opportunity.

## Why this exists

The case analysis was a one time exercise. This turns it into production infrastructure:
the customer state classification, GPV opportunity model, predictive signal scoring, and
priority tiering all live as versioned dbt models that can refresh on a schedule and feed
the VP dashboard directly.

## Architecture (medallion)

    seeds/customers.csv          the 5,000 row dataset, loaded via `dbt seed`
    staging/      one to one with the seed, light cleaning and typing
    intermediate/ business logic: state classification, opportunity sizing, feasibility
    marts/        the OBT and KPI pack the dashboard and AM/CSM queues read from

## Lineage

    seed customers
      -> stg_customers
         -> int_customer_state         (6 states: A through F)
         -> int_gpv_opportunity        (benchmark penetration, opportunity sizing)
         -> int_account_feasibility    (enablement likelihood score)
            -> mart_account_priority   (OBT: priority tier, team routing, $ opp, action)
            -> mart_gpv_kpis           (weekly KPI pack for the VP dashboard)

## Build

    dbt deps
    dbt seed       # loads the dataset
    dbt build      # run + test, in dependency order

## Dashboard

Looker Studio connects natively to the two mart tables. One governed definition powers
the dashboard, the AM trigger queue, and any ad hoc query.

## Tests

    schema tests: unique/not null keys, accepted values on states and tiers, ranges
    singular tests:
        assert_opportunity_excludes_competitor_locked
        assert_enabled_have_no_enablement_opportunity_double_count
