with source as (

    select * from {{ source('marketing_raw', 'fb_ads') }}

)

select
    cast(ad_id as string)               as ad_id,
    cast(campaign_id as string)         as campaign_id,
    cast(ad_group_id as string)         as ad_group_id,
    cast(account_id as string)          as account_id,
    ad_name,
    upper(ad_status)                    as ad_status,
    cast(ad_updated_at as timestamp)    as ad_updated_at
from source
qualify row_number() over (partition by ad_id order by ad_updated_at desc) = 1
