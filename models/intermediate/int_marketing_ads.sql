-- Unified, platform-agnostic ad performance. Union of both platforms + keys + EUR conversion.
-- Materialized as a VIEW (inherits project default) so it can be tested and inspected without storing a copy.

with unioned as (

    select * from {{ ref('int_facebook_ad_performance') }}
    union all
    select * from {{ ref('int_snapchat_ad_performance') }}

)

select
    {{ dbt_utils.generate_surrogate_key(['u.platform', 'u.ad_id', 'u.report_date', 'u.country']) }} as ad_performance_key,
    {{ dbt_utils.generate_surrogate_key(['u.platform', 'u.campaign_id']) }}                        as campaign_key,
    {{ dbt_utils.generate_surrogate_key(['u.platform', 'u.ad_id']) }}                              as ad_key,
    u.platform,
    u.report_date,
    u.country,
    u.account_id,
    u.account_name,
    u.campaign_id,
    u.campaign_name,
    u.ad_group_id,
    u.ad_group_name,
    u.ad_id,
    u.ad_name,
    u.ad_status,
    u.currency_code,
    u.spend,
    -- NULL (not 0) if a currency has no rate: the not_null test then fails loudly instead of under-reporting spend.
    cast(u.spend * fx.rate_to_eur as decimal(18, 4)) as spend_eur,
    u.impressions,
    u.clicks,
    u.is_clicks_imputed,
    u._loaded_at
from unioned as u
left join {{ ref('currency_rates') }} as fx
    on u.currency_code = fx.currency_code
