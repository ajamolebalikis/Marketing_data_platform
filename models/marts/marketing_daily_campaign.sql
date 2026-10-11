-- Consumption-ready aggregate for BI tools and AI agents. Small, pre-joined, no surrogate keys needed.
-- Ratios are recomputed from SUMS (never averaged from row-level ratios).
select
    report_date,
    date_trunc('month', report_date)                             as report_month,
    platform,
    campaign_key,
    campaign_id,
    campaign_name,
    sum(spend_eur)                                               as spend_eur,
    sum(impressions)                                             as impressions,
    sum(clicks)                                                  as clicks,
    {{ safe_divide('sum(clicks)', 'sum(impressions)') }}         as ctr,
    {{ safe_divide('sum(spend_eur)', 'sum(clicks)') }}           as cpc_eur,
    {{ safe_divide('sum(spend_eur) * 1000', 'sum(impressions)') }} as cpm_eur
from {{ ref('fct_marketing_spend') }}
group by report_date, date_trunc('month', report_date), platform, campaign_key, campaign_id, campaign_name
