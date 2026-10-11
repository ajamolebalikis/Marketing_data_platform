select
    cast(campaign_id as string)             as campaign_id,
    campaign_name,
    cast(campaign_updated_at as timestamp)  as campaign_updated_at
from {{ source('marketing_raw', 'fb_campaigns') }}
qualify row_number() over (partition by campaign_id order by campaign_updated_at desc) = 1
