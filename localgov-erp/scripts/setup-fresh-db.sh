#!/usr/bin/env bash
# =====================================================================
# ymbji — Fresh DB setup for local development
#
# Creates a fresh Postgres database, generates dev-only PII keys,
# and starts the Spring Boot app. All 117 migrations (V1, V1_0_1..V1_0_6,
# V2..V116) run automatically on first start.
#
# Usage:
#     ./scripts/setup-fresh-db.sh                # default DB: ymbji_dev
#     DB_NAME=my_dev ./scripts/setup-fresh-db.sh # custom DB name
#
# Requirements:
#   - Postgres running on localhost
#   - psql, python3 on PATH
#   - Maven wrapper (./mvnw) present in repo root
# =====================================================================
set -euo pipefail

DB_NAME="${DB_NAME:-ymbji_dev}"
DB_USER="${DB_USER:-erp_admin}"
DB_PASS="${DB_PASS:-erp2026}"
PG_SUPERUSER="${PG_SUPERUSER:-postgres}"
PG_HOST="${PG_HOST:-localhost}"
PG_PORT="${PG_PORT:-5432}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "==> ymbji fresh DB setup"
echo "    DB name     : $DB_NAME"
echo "    DB user     : $DB_USER"
echo "    DB host:port: $PG_HOST:$PG_PORT"
echo ""

echo "==> Dropping and recreating $DB_NAME (as $PG_SUPERUSER)"
psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPERUSER" -d postgres \
     -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -h "$PG_HOST" -p "$PG_PORT" -U "$PG_SUPERUSER" -d postgres \
     -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
echo ""

echo "==> Generating ephemeral PII keys (dev only)"
export PII_ENCRYPTION_KEY=$(python3 -c 'import os,base64;print(base64.b64encode(os.urandom(32)).decode())')
export PII_HMAC_KEY=$(python3 -c 'import os,base64;print(base64.b64encode(os.urandom(32)).decode())')
echo ""

export DB_URL="jdbc:postgresql://$PG_HOST:$PG_PORT/$DB_NAME"
export DB_USERNAME="$DB_USER"
export DB_PASSWORD="$DB_PASS"

echo "==> Starting Spring Boot against $DB_NAME"
echo "    Migrations will run automatically on first start."
echo "    Health check: http://localhost:8080/actuator/health"
echo ""
exec ./mvnw -pl web spring-boot:run
