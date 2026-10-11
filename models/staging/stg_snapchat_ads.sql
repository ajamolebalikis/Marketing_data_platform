select
    cast(ad_id as string)                   as ad_id,
    cast(ad_group_id as string)             as ad_group_id,
    ad_name,
    cast(ad_detail_updated_at as timestamp) as ad_updated_at
from {{ source('marketing_raw', 'snap_ads') }}
qualify row_number() over (partition by ad_id order by ad_detail_updated_at desc) = 1
