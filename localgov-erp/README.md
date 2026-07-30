# LocalGov ERP (Java/Spring)

## Runtime Configuration

Application configuration in `web/src/main/resources/application.yml` uses environment variables.

Copy and customize:

```bash
cp .env.example .env
```

Set at minimum:

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `JWT_SECRET` (Base64-encoded strong key)

## Database Migrations

Flyway is enabled and migration scripts are in:

- `web/src/main/resources/db/migration`

Current baseline migration:

- `V1__init_erp_phase2_tables.sql`

## Build and Run

```bash
cd localgov-erp
./mvnw -pl web -am clean test
./mvnw -pl web -am spring-boot:run
```

Base URL:

- `http://localhost:8080/api`

## Testing Strategy

- Unit and integration tests: `mvn -f pom.xml clean test`
- Contract tests (API shape): `mvn -f pom.xml -pl web -am verify`
- Full suite: run both commands above in sequence

## Observability

Actuator and metrics endpoints:

- `GET /api/actuator/health`
- `GET /api/actuator/metrics`
- `GET /api/actuator/prometheus`

Tracing and log correlation are enabled via Micrometer tracing and log pattern fields `traceId` / `spanId`.

With Docker Compose, a full local stack is available:

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000` (default `admin/admin`)
- OTEL collector OTLP endpoint: `http://localhost:4318/v1/traces`

Grafana is auto-provisioned with:

- Prometheus datasource
- Dashboard: `LocalGov ERP Overview`
- Provisioning files in `ops/grafana/provisioning` and dashboard JSON in `ops/grafana/dashboards`

## Docker

Build and run with compose:

```bash
cd localgov-erp
docker compose up --build
```

Application runs on `http://localhost:8080/api` and PostgreSQL on `localhost:5432`.

## CI/CD

GitHub Actions workflow is in `.github/workflows/ci-cd.yml` and runs:

- Unit/integration tests
- Contract tests
- Packaging
- Docker image publish to GHCR (on push to main/master)

## Auth Bootstrapping (Dev)

In-memory users are configured in `web/src/main/java/com/localgov/web/security/SecurityConfig.java`.

Use `/api/auth/login` to obtain JWT and call secured endpoints.