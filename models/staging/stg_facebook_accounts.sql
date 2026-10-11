select
    cast(account_id as string)              as account_id,
    account_name,
    upper(ad_currency_code)                 as currency_code,
    cast(account_created_at as timestamp)   as account_created_at,
    cast(account_updated_at as timestamp)   as account_updated_at
from {{ source('marketing_raw', 'fb_accounts') }}
qualify row_number() over (partition by account_id order by account_updated_at desc) = 1
