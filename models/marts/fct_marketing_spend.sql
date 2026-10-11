{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='ad_performance_key',
        on_schema_change='append_new_columns',
        file_format='delta'
    )
}}
-- INCREMENTAL because it is the largest, append-mostly model (daily ad-level rows, will keep growing).
-- Watermark is tracked PER PLATFORM: the two platforms are loaded independently, so a single global
-- max(date) would hide late data from the platform that is behind. We re-read the last N days
-- (var incremental_lookback_days) because ad platforms restate recent days. MERGE on the key makes it idempotent.

with performance as (

    select * from {{ ref('int_marketing_ads') }}
    {% if is_incremental() %}
    where
    {% for p in ['facebook', 'snapchat'] %}
        (platform = '{{ p }}' and report_date >= (
            select coalesce(date_sub(max(report_date), {{ var('incremental_lookback_days') }}), date'1900-01-01')
            from {{ this }}
            where platform = '{{ p }}'
        ))
        {%- if not loop.last %} or {% endif %}
    {% endfor %}
    {% endif %}

)

select
    ad_performance_key,
    report_date,
    platform,
    country,
    account_id,
    account_name,
    campaign_key,
    campaign_id,
    campaign_name,
    ad_group_id,
    ad_group_name,
    ad_key,
    ad_id,
    ad_name,
    ad_status,
    currency_code,
    spend,
    spend_eur,
    impressions,
    clicks,
    {{ safe_divide('clicks', 'impressions') }}              as ctr,
    {{ safe_divide('spend_eur', 'clicks') }}                as cpc_eur,
    {{ safe_divide('spend_eur * 1000', 'impressions') }}    as cpm_eur,
    is_clicks_imputed,
    current_timestamp()                                     as _dbt_loaded_at
from performance
