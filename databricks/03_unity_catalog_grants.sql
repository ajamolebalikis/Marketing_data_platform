-- Run as a catalog owner/admin AFTER creating the Service Principal.
-- REPLACE the two placeholders (do NOT reuse the example IDs/emails from the case study):
--   <SERVICE_PRINCIPAL_APPLICATION_ID>  -> Application ID (UUID) of YOUR service principal
--   <YOUR_EMAIL>                         -> YOUR Databricks login email
-- Principals are written in backticks.

-- =====================================================================
-- 1) PRODUCTION SERVICE PRINCIPAL
-- =====================================================================
-- 1a) READ the raw layer (it never writes to bronze)
GRANT USE CATALOG ON CATALOG bronze_production TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;
GRANT USE SCHEMA  ON SCHEMA  bronze_production.marketing_raw TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;
GRANT SELECT      ON SCHEMA  bronze_production.marketing_raw TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;

-- 1b) WRITE the production analytics catalog (dbt creates schemas, tables, views)
GRANT USE CATALOG    ON CATALOG analytics_production TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;
GRANT USE SCHEMA     ON CATALOG analytics_production TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;
GRANT CREATE SCHEMA  ON CATALOG analytics_production TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;
GRANT CREATE TABLE   ON CATALOG analytics_production TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;
GRANT SELECT         ON CATALOG analytics_production TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;
GRANT MODIFY         ON CATALOG analytics_production TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;

-- Optional (the case study example grants it; NOT needed here because an admin created the catalogs,
-- and least privilege says a pipeline identity should not be able to create catalogs):
-- GRANT CREATE CATALOG ON METASTORE TO `<SERVICE_PRINCIPAL_APPLICATION_ID>`;

-- The SP also needs "Can use" on the SQL warehouse:
--   SQL Warehouses -> your warehouse -> Permissions -> add the service principal -> Can use

-- =====================================================================
-- 2) CI / DEVELOPMENT (your user)
-- =====================================================================
-- Case-study minimum (read):
GRANT USE CATALOG ON CATALOG ci_development TO `<YOUR_EMAIL>`;
GRANT USE SCHEMA  ON CATALOG ci_development TO `<YOUR_EMAIL>`;
GRANT SELECT      ON CATALOG ci_development TO `<YOUR_EMAIL>`;
-- dbt in CI must also CREATE objects, so add write privileges (skip if you own the catalog):
GRANT CREATE SCHEMA ON CATALOG ci_development TO `<YOUR_EMAIL>`;
GRANT CREATE TABLE  ON CATALOG ci_development TO `<YOUR_EMAIL>`;
GRANT MODIFY        ON CATALOG ci_development TO `<YOUR_EMAIL>`;

-- Development sandbox
GRANT USE CATALOG, USE SCHEMA, CREATE SCHEMA, CREATE TABLE, SELECT, MODIFY
  ON CATALOG analytics_development TO `<YOUR_EMAIL>`;

-- Dev and CI read the shared raw data
GRANT USE CATALOG ON CATALOG bronze_production TO `<YOUR_EMAIL>`;
GRANT USE SCHEMA, SELECT ON SCHEMA bronze_production.marketing_raw TO `<YOUR_EMAIL>`;

-- =====================================================================
-- 3) CONSUMPTION LAYER (analysts / BI / AI agents): read-only on marts only
-- =====================================================================
GRANT USE CATALOG ON CATALOG analytics_production TO `account users`;
GRANT USE SCHEMA, SELECT ON SCHEMA analytics_production.marts TO `account users`;

-- =====================================================================
-- 4) VERIFY
-- =====================================================================
-- SHOW GRANTS ON CATALOG analytics_production;
-- SHOW GRANTS ON SCHEMA bronze_production.marketing_raw;
