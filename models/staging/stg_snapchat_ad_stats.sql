-- Snapchat daily performance at ad x date x country grain (Facebook has no country).
with source as (

    select * from {{ source('marketing_raw', 'snap_ads_stats') }}

),

cleaned as (

    select
        cast(ad_detail_id as string)                as ad_id,
        upper(ad_country)                           as country,
        upper(ad_currency_code)                     as currency_code,
        cast(ad_date as date)                       as report_date,
        cast(ad_spend as decimal(18, 4))            as spend,
        coalesce(try_cast(ad_impressions as bigint), 0) as impressions,
        coalesce(try_cast(ad_clicks as bigint), 0)      as clicks,
        try_cast(ad_clicks as bigint) is null                           as is_clicks_imputed,
        _loaded_at
    from source

)

select * from cleaned
qualify row_number() over (partition by ad_id, report_date, country order by _loaded_at desc) = 1
