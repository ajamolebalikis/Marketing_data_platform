select
    ad_key,
    platform,
    ad_id,
    max(ad_name)        as ad_name,
    max(ad_status)      as ad_status,
    max(ad_group_id)    as ad_group_id,
    max(ad_group_name)  as ad_group_name,
    max(campaign_key)   as campaign_key
from {{ ref('int_marketing_ads') }}
group by ad_key, platform, ad_id
