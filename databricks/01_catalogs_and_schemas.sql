-- Run once as a metastore/workspace admin in a Databricks SQL editor.
-- If your workspace requires a managed location, add: MANAGED LOCATION 's3://... / abfss://...'

CREATE CATALOG IF NOT EXISTS bronze_production;       -- raw data (single copy, read by all envs)
CREATE CATALOG IF NOT EXISTS analytics_production;    -- prod dbt output (staging/intermediate/marts/elementary)
CREATE CATALOG IF NOT EXISTS analytics_development;   -- developer sandboxes (schema per developer)
CREATE CATALOG IF NOT EXISTS ci_development;          -- CI (schema set per pull request)

CREATE SCHEMA IF NOT EXISTS bronze_production.marketing_raw
  COMMENT 'Raw Facebook Ads and Snapchat Ads exports, loaded as-is from CSV.';

CREATE VOLUME IF NOT EXISTS bronze_production.marketing_raw.landing
  COMMENT 'Landing zone for the raw CSV files.';
