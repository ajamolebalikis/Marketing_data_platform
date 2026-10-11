{{ config(materialized='ephemeral') }}
-- Snapchat performance enriched via ad -> ad group -> campaign.
-- Snapchat has no account dimension: account_id comes from the campaign, currency from the stats row.

select
    'snapchat'                          as platform,
    s.ad_id,
    s.report_date,
    s.country,
    ag.campaign_id,
    c.campaign_name,
    a.ad_group_id,
    ag.ad_group_name,
    a.ad_name,
    cast(null as string)                as ad_status,      -- not provided by Snapchat export
    c.account_id,
    cast(null as string)                as account_name,   -- not provided by Snapchat export
    s.currency_code,
    s.spend,
    s.impressions,
    s.clicks,
    s.is_clicks_imputed,
    s._loaded_at
from {{ ref('stg_snapchat_ad_stats') }}   as s
left join {{ ref('stg_snapchat_ads') }}        as a   on s.ad_id = a.ad_id
left join {{ ref('stg_snapchat_ad_groups') }}  as ag  on a.ad_group_id = ag.ad_group_id
left join {{ ref('stg_snapchat_campaigns') }}  as c   on ag.campaign_id = c.campaign_id
