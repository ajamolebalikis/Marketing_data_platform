# Marketing Data Platform (Databricks + dbt + Elementary)

One governed, documented, tested dataset for Facebook Ads + Snapchat Ads performance, built for
analysts, BI tools and AI agents. Setup instructions: **SETUP_GUIDE.md**.

## Architecture

```
 CSV exports (Facebook, Snapchat)
        |  upload to UC Volume, databricks/02_load_raw_data.sql
        v
 RAW / BRONZE      bronze_production.marketing_raw.*      (as-is + _loaded_at, never edited)
        |  dbt sources
        v
 STAGING (views)   stg_facebook_*  stg_snapchat_*         (rename, cast, dedupe, null rules)
        |
        v
 INTERMEDIATE      int_facebook_ad_performance (ephemeral)
                   int_snapchat_ad_performance (ephemeral)
                   int_marketing_ads (view)               (enrich, UNION, keys, EUR conversion)
        |
        v
 MARTS             fct_marketing_spend (incremental)      <- main analytical model
                   dim_campaign, dim_ad (tables)
                   marketing_daily_campaign (table)       <- BI / AI entry point
        |
        v
 CONSUMPTION       SQL / Databricks, BI tools, Claude / AI agents (read-only on marts)

 Observability: Elementary (tests, anomalies, run history) -> analytics_production.elementary
```

## Model grain and keys

| Model | Grain | Key |
|---|---|---|
| stg_facebook_ad_stats | ad x day | (ad_id, report_date) |
| stg_snapchat_ad_stats | ad x day x country | (ad_id, report_date, country) |
| int_marketing_ads | platform x ad x day x country | ad_performance_key |
| **fct_marketing_spend** | **platform x ad x day x country** (country NULL for Facebook) | ad_performance_key (surrogate) |
| dim_campaign | platform x campaign_id | campaign_key |
| dim_ad | platform x ad_id | ad_key |
| marketing_daily_campaign | day x platform x campaign | (report_date, platform, campaign_key) |

## Key engineering decisions

| Decision | Why |
|---|---|
| Keep **ad-level** grain in the fact | Lowest grain answers every question (campaign, platform, month) by aggregation; the reverse is impossible. |
| Separate Facebook/Snapchat staging, UNION in intermediate | Platform quirks (UUID vs bigint ids, country, currency location) are isolated; downstream sees one shape. |
| All ids cast to **string** | Facebook ids are bigint, Snapchat ids are UUIDs. One type avoids join/union errors. |
| Null clicks/impressions -> 0 + `is_clicks_imputed` | 24k Facebook rows have NULL clicks; every NULL-impression row has spend 0. Exports omit zeros. The flag keeps the assumption auditable. |
| History tables deduped with `qualify row_number()` | Snapchat ad groups has 3 duplicated ids; history files carry several versions. |
| Spend converted to **EUR** via seed | Facebook accounts are 14 EUR / 2 USD. Summing mixed currencies is wrong. `currency_rates` is a placeholder rate: replace with finance-approved values. |
| Ratios via `safe_divide` (NULL on 0 denominators) | CTR/CPC/CPM are undefined, not 0, when denominators are 0. Aggregates recompute ratios from sums. |
| Incremental merge with **per-platform watermark** + 3-day lookback | Platforms land independently; ad platforms restate recent days; merge on key = idempotent. |
| Date coverage differs (Snapchat 2024, Facebook 2025) | Documented. Platform comparison over time is month-by-month, not like-for-like periods. |

## Materializations

| Model | Type | Reason |
|---|---|---|
| staging | view | 1:1 with source, no storage cost, always fresh |
| int_*_ad_performance | ephemeral | reusable logic, no need to store or query |
| int_marketing_ads | view | testable union, small compute |
| fct_marketing_spend | incremental (merge) | largest, growing model |
| dim_*, marketing_daily_campaign | table | small, queried constantly by BI/AI |
| currency_rates | seed | tiny reference data under version control |

## Data quality

PK `unique`/`not_null`, `accepted_values` (platform, status, currency), `relationships` (fact -> dims),
`accepted_range` (spend/impressions/clicks >= 0), `clicks <= impressions`, grain uniqueness with
`unique_combination_of_columns`, `spend_eur not_null` (catches a new currency with no rate),
singular tests (fact reconciles with int, no future dates), source freshness, and Elementary
`schema_changes` + `volume_anomalies` (warn).

## Environments and security

| | Dev | CI | Prod |
|---|---|---|---|
| Catalog | analytics_development | ci_development | analytics_production |
| Schemas | dbt_<user>_* | pr_<n>_* (dropped after run) | staging / intermediate / marts / elementary / reference |
| Auth | personal access token | CI token (user per case study; a CI service principal is better) | **Service Principal, OAuth M2M, no PAT** |
| Raw read | bronze_production.marketing_raw (SELECT) | same | same |

Secrets exist only as GitHub secrets / env vars; `profiles.yml` contains none. Unity Catalog grants:
`databricks/03_unity_catalog_grants.sql` (SP: read raw, write analytics_production only; analysts: read marts only).

## CI/CD flow

```
feature branch -> pull request -> CI: parse, seed, build (run+test) in ci_development.pr_<n>_*, docs
              -> review + required check -> merge to main -> CD: prod build as Service Principal
              -> Elementary report + dbt docs published as artifacts -> daily schedule keeps prod fresh
```

## Using it with AI agents / BI

Point them at `analytics_production.marts`. Column and metric descriptions live in Unity Catalog
(persisted via dbt `persist_docs` if you enable it) and in the dbt docs. Start with `marketing_daily_campaign`.

