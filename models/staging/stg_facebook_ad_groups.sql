select
    cast(ad_group_id as string)             as ad_group_id,
    ad_group_name,
    cast(ad_group_updated_at as timestamp)  as ad_group_updated_at
from {{ source('marketing_raw', 'fb_ad_groups') }}
qualify row_number() over (partition by ad_group_id order by ad_group_updated_at desc) = 1
