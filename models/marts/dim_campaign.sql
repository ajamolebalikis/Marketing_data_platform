-- Small, slowly changing, joined often by BI -> TABLE (rebuilt each run; cheap and always consistent).
select
    campaign_key,
    platform,
    campaign_id,
    max(campaign_name)          as campaign_name,
    max(account_id)             as account_id,
    max(account_name)           as account_name,
    count(distinct ad_id)       as ad_count,
    min(report_date)            as first_report_date,
    max(report_date)            as last_report_date
from {{ ref('int_marketing_ads') }}
group by campaign_key, platform, campaign_id
