select
    cast(campaign_id as string)  as campaign_id,
    cast(account_id as string)   as account_id,
    campaign_name
from {{ source('marketing_raw', 'snap_campaigns') }}
qualify row_number() over (partition by campaign_id order by campaign_name) = 1
