-- Prerequisite: the 9 CSV files from data/raw/ are uploaded to
--   /Volumes/bronze_production/marketing_raw/landing/raw/
-- (Catalog Explorer -> bronze_production -> marketing_raw -> landing -> Upload to this volume)
-- Raw layer principle: load as-is, add only ingestion metadata (_loaded_at, _source_file).

USE CATALOG bronze_production;
USE SCHEMA marketing_raw;

-- ---------- Facebook ----------
CREATE OR REPLACE TABLE fb_ads_stats AS
SELECT *, current_timestamp() AS _loaded_at, 'fb_ads_stats.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/fb_ads_stats.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE fb_ads AS
SELECT *, current_timestamp() AS _loaded_at, 'fb_ads.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/fb_ads.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE fb_campaigns AS
SELECT *, current_timestamp() AS _loaded_at, 'fb_campaigns.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/fb_campaigns.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE fb_ad_groups AS
SELECT *, current_timestamp() AS _loaded_at, 'fb_ad_groups.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/fb_ad_groups.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE fb_accounts AS
SELECT *, current_timestamp() AS _loaded_at, 'fb_accounts.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/fb_accounts.csv', format => 'csv', header => true, inferSchema => true);

-- ---------- Snapchat ----------
CREATE OR REPLACE TABLE snap_ads_stats AS
SELECT *, current_timestamp() AS _loaded_at, 'snap_ads_stats.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/snap_ads_stats.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE snap_ads AS
SELECT *, current_timestamp() AS _loaded_at, 'snap_ads.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/snap_ads.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE snap_ad_groups AS
SELECT *, current_timestamp() AS _loaded_at, 'snap_ad_groups.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/snap_ad_groups.csv', format => 'csv', header => true, inferSchema => true);

CREATE OR REPLACE TABLE snap_campaigns AS
SELECT *, current_timestamp() AS _loaded_at, 'snap_campaigns.csv' AS _source_file
FROM read_files('/Volumes/bronze_production/marketing_raw/landing/raw/snap_campaigns.csv', format => 'csv', header => true, inferSchema => true);

-- ---------- Sanity checks (expected: 92300 / 98926 / 4162 / 13433 / 16 / 2809 / 2513 / 267 / 109) ----------
SELECT 'fb_ads_stats' t, count(*) n FROM fb_ads_stats UNION ALL
SELECT 'fb_ads', count(*) FROM fb_ads UNION ALL
SELECT 'fb_campaigns', count(*) FROM fb_campaigns UNION ALL
SELECT 'fb_ad_groups', count(*) FROM fb_ad_groups UNION ALL
SELECT 'fb_accounts', count(*) FROM fb_accounts UNION ALL
SELECT 'snap_ads_stats', count(*) FROM snap_ads_stats UNION ALL
SELECT 'snap_ads', count(*) FROM snap_ads UNION ALL
SELECT 'snap_ad_groups', count(*) FROM snap_ad_groups UNION ALL
SELECT 'snap_campaigns', count(*) FROM snap_campaigns;
