-- Sample answers to the case-study business questions. Run in Databricks SQL against analytics_production.marts.
-- (Facebook = 2025, Snapchat = 2024 -> "last month" below is relative to the latest date in the data.)

-- 1) Total spend (EUR)
select round(sum(spend_eur), 2) as total_spend_eur from analytics_production.marts.fct_marketing_spend;

-- 2) Spend, impressions, clicks, CTR, CPC, CPM by platform
select platform,
       round(sum(spend_eur), 2) as spend_eur,
       sum(impressions) as impressions,
       sum(clicks) as clicks,
       sum(clicks) / nullif(sum(impressions), 0) as ctr,
       sum(spend_eur) / nullif(sum(clicks), 0) as cpc_eur,
       sum(spend_eur) * 1000 / nullif(sum(impressions), 0) as cpm_eur
from analytics_production.marts.fct_marketing_spend
group by platform;

-- 3) Spend by campaign
select platform, campaign_name, round(sum(spend_eur), 2) as spend_eur
from analytics_production.marts.marketing_daily_campaign
group by platform, campaign_name order by spend_eur desc;

-- 4) Campaigns with the most impressions / clicks
select platform, campaign_name, sum(impressions) as impressions, sum(clicks) as clicks
from analytics_production.marts.marketing_daily_campaign
group by platform, campaign_name order by clicks desc limit 10;

-- 5) Which platform generated more clicks?
select platform, sum(clicks) as clicks
from analytics_production.marts.marketing_daily_campaign group by platform order by clicks desc;

-- 6) Performance over time (monthly)
select report_month, platform, round(sum(spend_eur), 2) as spend_eur, sum(clicks) as clicks, sum(impressions) as impressions
from analytics_production.marts.marketing_daily_campaign
group by report_month, platform order by report_month, platform;

-- 7) "How much did we spend on Facebook last month?" (last month of data available for Facebook)
select round(sum(spend_eur), 2) as facebook_spend_eur
from analytics_production.marts.marketing_daily_campaign
where platform = 'facebook'
  and report_month = (select max(report_month) from analytics_production.marts.marketing_daily_campaign where platform = 'facebook');

-- 8) Compare Facebook and Snapchat spend by month
select report_month,
       round(sum(case when platform = 'facebook' then spend_eur end), 2) as facebook_spend_eur,
       round(sum(case when platform = 'snapchat' then spend_eur end), 2) as snapchat_spend_eur
from analytics_production.marts.marketing_daily_campaign
group by report_month order by report_month;
