-- Facebook daily performance. Standardises names/types and applies the null-handling rules.
with source as (

    select * from {{ source('marketing_raw', 'fb_ads_stats') }}

),

cleaned as (

    select
        cast(ad_id as string)                       as ad_id,
        cast(account_id as string)                  as account_id,
        cast(ad_date as date)                       as report_date,
        cast(ad_spend as decimal(18, 4))            as spend,
        -- Facebook exports leave metrics NULL instead of 0 (every NULL-impression row has spend = 0).
        coalesce(try_cast(ad_impressions as bigint), 0) as impressions,
        coalesce(try_cast(ad_clicks as bigint), 0)      as clicks,
        -- keep the evidence: was clicks imputed from NULL?
        try_cast(ad_clicks as bigint) is null                           as is_clicks_imputed,
        _loaded_at
    from source

)

select * from cleaned
-- defensive deduplication on the natural key (none today, but exports get re-sent)
qualify row_number() over (partition by ad_id, report_date order by _loaded_at desc) = 1
