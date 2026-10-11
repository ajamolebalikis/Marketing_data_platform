{{ config(materialized='ephemeral') }}
-- Facebook performance enriched with ad, ad group, campaign and account attributes.
-- Ephemeral: pure reusable logic, inlined as a CTE into int_marketing_ads (nothing to store or query).

select
    'facebook'                          as platform,
    s.ad_id,
    s.report_date,
    cast(null as string)                as country,        -- Facebook source has no country split
    a.campaign_id,
    c.campaign_name,
    a.ad_group_id,
    ag.ad_group_name,
    a.ad_name,
    a.ad_status,
    s.account_id,
    acc.account_name,
    acc.currency_code,
    s.spend,
    s.impressions,
    s.clicks,
    s.is_clicks_imputed,
    s._loaded_at
from {{ ref('stg_facebook_ad_stats') }}   as s
left join {{ ref('stg_facebook_ads') }}        as a   on s.ad_id = a.ad_id
left join {{ ref('stg_facebook_campaigns') }}  as c   on a.campaign_id = c.campaign_id
left join {{ ref('stg_facebook_ad_groups') }}  as ag  on a.ad_group_id = ag.ad_group_id
left join {{ ref('stg_facebook_accounts') }}   as acc on s.account_id = acc.account_id
