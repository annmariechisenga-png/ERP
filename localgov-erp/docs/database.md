# ymbji — Database

## Fresh-DB reproducibility

**Status: fully reproducible.** All 117 migrations (`V1`, `V1_0_1`..`V1_0_6`, `V2`..`V116`) apply cleanly to an empty PostgreSQL 16 database. The app boots end-to-end with `ddl-auto=validate`.

Verified at commit `2d0d458` (tag `schema-query-aligned`).

## Quick start

One command for a fresh dev DB + app:

    ./scripts/setup-fresh-db.sh

This drops/recreates the `ymbji_dev` database, generates ephemeral dev-only PII keys, and starts the Spring Boot app.

## Required environment variables

| Var | Purpose | Format |
|---|---|---|
| `DB_URL` | Postgres JDBC URL | `jdbc:postgresql://host:port/db` |
| `DB_USERNAME` | DB user | text |
| `DB_PASSWORD` | DB password | text |
| `PII_ENCRYPTION_KEY` | AES-256-GCM key for PII columns | base64 of 32 bytes |
| `PII_HMAC_KEY` | HMAC-SHA256 key for per-tenant hashing | base64 of 32 bytes |

The app refuses to start if the PII keys are missing.

## Database landscape (dev machine)

| Database | Purpose |
|---|---|
| `ymbji_dev` | Canonical fresh dev DB |
| `ymbji` | Local working DB (schema validated) |
| `ymbji_archive_20261013` | Legacy DB, historical reference only |

Do not use `ymbji_archive_20261013` for development — stale flyway history.

## Manual startup

    # 1. Create an empty DB
    psql -h localhost -U postgres -d postgres -c "DROP DATABASE IF EXISTS ymbji_dev;"
    psql -h localhost -U postgres -d postgres -c "CREATE DATABASE ymbji_dev OWNER erp_admin;"

    # 2. Set env vars
    export DB_URL='jdbc:postgresql://localhost:5432/ymbji_dev'
    export DB_USERNAME='erp_admin'
    export DB_PASSWORD='erp2026'
    export PII_ENCRYPTION_KEY=$(python3 -c "import os,base64;print(base64.b64encode(os.urandom(32)).decode())")
    export PII_HMAC_KEY=$(python3 -c "import os,base64;print(base64.b64encode(os.urandom(32)).decode())")

    # 3. Run
    ./mvnw -pl web spring-boot:run

Expected: `Started LocalGovErpApplication in ~25-30 seconds`.
Health check: `curl http://localhost:8080/actuator/health` → `{"status":"UP"}`.

## Migration chain — quick reference

Migrations live in `web/src/main/resources/db/migration/`. Naming: `V<version>__<description>.sql`.

Key ranges:
- `V1`, `V1_0_1`..`V1_0_6` — base tables
- `V2`..`V54` — early migrations (leave policy, work locations, user roles)
- `V55`..`V72` — Finance Core (COA, GL, audit functions)
- `V73`..`V110` — AP/AR/Budget
- `V111`..`V116` — MoFNP, HR core, schema fixes

Once a migration has been applied to a live DB, do not edit it. Add a new migration instead. Editing applied migrations causes checksum mismatches — Flyway refuses to continue, and correctly so.

## Migration chain fixes (2026-10-11/12)

The chain was debugged from "fails at V20 on fresh DB" to full reproducibility.

Phantom tables created (referenced by later migrations but never created):
- `V4_2` — `employees` base table
- `V1_0_2` — `leave_policy`
- `V1_0_3` — `compliance_rule_change_log`
- `V1_0_4` — `authorities` + `council_types`
- `V1_0_5` — `salary_advances`
- `V1_0_6` — `employee_leave_master`

Legacy prototype migrations deleted:
- `V20` — dead view
- `V21` — prototype employee columns
- `V29` — dead user_roles feature
- `V49` — demo seed referencing dropped table

Migrations patched (schema/data fixes):
- `V22` — removed dead FK to `erp_employee.primary_location_id`
- `V54` — removed indexes on nonexistent `erp_employee` columns
- `V66`, `V94` — added `DROP FUNCTION` before `CREATE OR REPLACE`
- `V67` — wrapped trailing `PERFORM` in `DO` block
- `V76` — fixed `LIMIT 1 UNION ALL` syntax in `export_audit`
- `V103` — fixed `RAISE NOTICE` placeholder count
- `V105` — corrected 4 MoFNP chart-of-accounts codes
- `V107` — added repair step (MAPPED-with-NULL to KEPT)
- `V108`, `V109` — converted single-column FK to composite key
- `V110` — disambiguated `COMMENT ON FUNCTION` with explicit signatures
- `V115` — dynamic `erp_employee` FK drop + empty-DB tolerance
- `V116` — converted legacy BIGINT employee columns to VARCHAR; converted `leave_policy` BIGINT columns to INTEGER

See `git log --oneline 39fd65c..2d0d458` for the full commit list.

## Reference data

`docs/reference/mofnp_chart_of_accounts_2026.csv` — extracted chart of accounts from V105 (749 distinct codes), used for duplicate detection and future reconciliation.

## Known deviations from MoFNP manual

The MoFNP Local Government Accounting and Financial Procedures Manual (Dec 2023) contains code anomalies preserved but noted here:

- `152199 Other fees and charges` — every other "Other X" uses `NNNN99`; migration uses `152099`.
- `281020` (double use) — under both 2710 Subsidies and 2810 Legal Expenses; migration uses `271020` for the subsidies row.
- `221100 Insurance of office machines` — breaks the 2210 pattern; migration uses `221099`.
- `291030 CDF Skills and Secondary Schools Bursaries` — orphaned in the manual; migration re-parents under a consistent prefix.

If MoFNP publishes a corrected chart, re-run the extraction and diff against the reference CSV.

## Verification

    # All migrations applied
    psql -h localhost -U erp_admin -d ymbji_dev -c "SELECT COUNT(*) AS applied, SUM(CASE WHEN success THEN 1 ELSE 0 END) AS succeeded FROM flyway_schema_history;"
    # Expected: applied = 117, succeeded = 117

    # App is up
    curl -s http://localhost:8080/actuator/health
    # Expected: {"status":"UP", ...}

## See also

- `docs/commission-requirements.md` — LGSC cross-council reporting requirements
- `docs/multi-tenancy.md` — tenant isolation, RLS, subdomain routing (planned)
- `docs/workflows/overtime.md` — overtime approval workflow (planned)
