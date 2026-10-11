# Setup guide: from zero to a working platform

Order matters. Placeholders in <angle brackets> are yours to replace.

## 0. Prerequisites
- Databricks workspace with Unity Catalog and a **SQL Warehouse** (serverless is fine).
- GitHub account, Git, Python 3.11+.

## 1. Create catalogs, schema, volume (Databricks SQL editor, as admin)
Run `databricks/01_catalogs_and_schemas.sql`.
If catalog creation asks for a storage location, add `MANAGED LOCATION '<your external location>'`.

## 2. Load the raw data
1. Catalog -> `bronze_production` -> `marketing_raw` -> volume `landing` -> **Upload to this volume**.
   Upload the 9 files from `data/raw/`.
2. Run `databricks/02_load_raw_data.sql`. The last query should show:
   92300 / 98926 / 4162 / 13433 / 16 / 2809 / 2513 / 267 / 109 rows.

## 3. Get connection details
- SQL Warehouses -> your warehouse -> **Connection details**: copy *Server hostname* and *HTTP path*.
- User settings -> Developer -> Access tokens -> generate a **personal access token** (dev only).
- Create a second token for CI (or reuse; better: create a CI service principal the same way as step 4).

## 4. Create the production Service Principal
1. Account console (accounts.cloud.databricks.com) -> User management -> Service principals -> **Add**.
   Name it `marketing-dbt-prod`. Copy its **Application ID** (UUID).
2. Add it to the workspace: Workspace -> Settings -> Identity and access -> Service principals -> Add.
   Grant entitlement *Databricks SQL access*.
3. Open the SP -> **Secrets** -> **Generate secret**. Copy the *secret* (shown once) and the *client ID*.
4. SQL Warehouse -> Permissions -> add the SP with **Can use**.

## 5. Apply Unity Catalog permissions
Open `databricks/03_unity_catalog_grants.sql`, replace `<SERVICE_PRINCIPAL_APPLICATION_ID>` and `<YOUR_EMAIL>`,
run sections 1 and 2. Run section 3 (analysts) **after the first production run** (the `marts` schema must exist).

## 6. Local development
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env     # fill values, then:
set -a; source .env; set +a
dbt deps
dbt debug                # must say "All checks passed"
dbt seed
dbt run --select elementary
dbt build                # runs + tests every model in analytics_development.dbt_<you>_*
```
First time only; if `dbt build` fails on a test, read the failing test: that is the project working as intended.

## 7. Docs and Elementary report
```bash
dbt docs generate --static        # -> target/static_index.html (lineage graph: blue button bottom right)
edr report --profiles-dir . --profile-target dev    # -> edr_output/elementary_report.html
```
Commit a copy of both HTML files into a `docs_output/` folder for the case-study deliverable.
Screenshot the lineage graph (staging -> intermediate -> fct) for your README.

## 8. GitHub repository and secrets
```bash
git init && git add . && git commit -m "Initial marketing data platform"
git branch -M main
git remote add origin https://github.com/<you>/marketing-data-platform.git
git push -u origin main
```
Repo -> Settings -> Secrets and variables -> Actions -> add:
`DATABRICKS_HOST`, `DATABRICKS_HTTP_PATH`, `DATABRICKS_TOKEN_CI`, `DATABRICKS_CLIENT_ID`, `DATABRICKS_CLIENT_SECRET`.
Settings -> Environments -> create `production` (optional: required reviewers).
Settings -> Branches -> protect `main`: require pull request + require the **dbt-ci** status check.

## 9. Prove the CI/CD flow (this is what graders look at)
```bash
git checkout -b feature/add-readme-note
# make a small change (e.g. a column description)
git commit -am "Improve description" && git push -u origin feature/add-readme-note
```
Open a pull request -> CI runs (see Actions tab) -> merge -> `CD (production)` runs as the Service Principal.
Screenshot: green CI run, green production run, and `analytics_production` tables created by the SP
(Catalog Explorer -> table -> Details -> *Owner* shows the service principal).

## 10. First production run, then analyst access
After the first CD run, run section 3 of the grants file. Then validate with `analyses/business_questions.sql`.

## 11. Optional: let an AI agent query it
Give the agent (or a Databricks Genie space) read access to `analytics_production.marts`.
Column descriptions are persisted to Unity Catalog so it understands `spend_eur`, `ctr`, `cpc_eur`, etc.

## Troubleshooting
| Symptom | Fix |
|---|---|
| `PERMISSION_DENIED` / schema cannot be created | Re-check grants for the principal actually running (user vs SP). |
| Source table not found | Check `RAW_CATALOG` env var and that step 2 finished. |
| Prod OAuth fails | Client ID must be the SP *Application ID*; secret not expired; SP has warehouse *Can use*. |
| Elementary tests fail the first run | Anomaly tests need history; they are set to `warn`. Re-run `dbt run --select elementary` first. |
| `fct_marketing_spend` looks stale | Full rebuild: `dbt run --select fct_marketing_spend --full-refresh`. |
| Deprecation warnings (test arguments) | Harmless; syntax kept for compatibility with older dbt. |

## Case-study checklist
Raw loaded, dbt connects, staging + intermediate + mart, grain documented, tests, docs HTML, lineage,
Elementary report, dev/CI/prod, SP in prod, UC grants, materializations explained, CI/CD workflows, README. All present in this repo.
