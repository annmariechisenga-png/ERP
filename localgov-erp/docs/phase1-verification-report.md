# Phase 1 Implementation — Verification Report

**Date:** 2026-07-10  
**Scope:** Final architectural verification of the completed Vacation Leave / LeaveCalendarService refactoring.  
**Status:** Phase 1 is functionally complete and the test suite is green. A small number of deviations and risks are noted below.

---

## 1. Architecture Compliance

### 1.1 LeaveCalendarService as single owner of calendar/date arithmetic

**Finding:** `LeaveCalendarService` is the only service performing leave schedule computation, working-day counting, resume-date calculation, weekend/holiday exclusion, and next-working-day resolution.

**Evidence:**
- `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/leave/LeaveCalendarService.java:42-152`
- `LeaveCalculationService` delegates all schedule math to `leaveCalendarService.computeSchedule(...)`.
- `LeaveService` does not call `LeaveCalendarService` directly; it consumes `LeaveCalculationResult` from `LeaveCalculationService`.

### 1.2 LeaveCalculationService orchestration only

**Finding:** `LeaveCalculationService` performs policy lookup, gender validation, advance notice validation, allowance eligibility, balance evaluation, limit enforcement, and result construction. It delegates all calendar math.

**Evidence:**
- `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveCalculationService.java:81-126`
- No direct `plusDays`/`minusDays` for schedule math; only `LocalDate.now().plusDays(noticeDays)` for advance notice and `LocalDateTime.now().minusMonths(months)` for the 24-month cutoff.

### 1.3 LeaveService contains no calculation logic

**Finding:** `LeaveService.submitLeaveRequest` validates access, basic date ordering, documents, and family-care annual limits; it delegates calculation to `LeaveCalculationService` and balance mutation to `applyBalance`.

**Evidence:**
- `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveService.java:84-172`

### 1.4 PolicyResolver is the single policy lookup entry point

**Finding:** Only `LeaveCalculationService` depends on `PolicyResolver`. `LeaveService` accesses policies via `leaveCalculationService.loadPolicy(...)`.

**Evidence:**
- `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveCalculationService.java:149`
- `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveService.java:109`

### 1.5 Deviations

| # | Deviation | Severity | Notes |
|---|-----------|----------|-------|
| 1 | `LeaveCalculationService` uses `LocalDate.now().plusDays(noticeDays)` and `LocalDateTime.now().minusMonths(months)` for advance notice and 24-month cutoff. | Low | These are policy-validity checks, not schedule math, but they are technically date arithmetic outside `LeaveCalendarService`. |
| 2 | `SchemaIntrospectionService` performs its own date arithmetic (`plusDays`, `minusDays`) to generate schema example leave periods. | Medium | This is not part of the production leave calculation flow, but it duplicates calendar logic and could drift from `LeaveCalendarService` rules. |
| 3 | `SchemaIntrospectionServiceTest` still references `Annual Leave` in test data and assertions. | Low | Production code does not expose Annual Leave; this is test-only residue. |

---

## 2. Database Verification

### 2.1 Migration inventory

| Version | File | Status |
|---------|------|--------|
| V49 | `V49__seed_employee_salary_scale_and_division.sql` | Present |
| V50 | `V50__add_leave_policy_constraints.sql` | Present |
| V51 | `V51__seed_null_division_vacation_policy.sql` | Present |
| V52 | `V52__add_vacation_allowance_policy_columns.sql` | Present |
| V53 | `V53__add_vacation_leave_allowance_table.sql` | Present |
| V54 | `V54__add_employee_hierarchy_indexes.sql` | Present |

### 2.2 Order and uniqueness

- **In order:** V49 < V50 < V51 < V52 < V53 < V54.
- **No duplicate versions:** `ls V*.sql | sort | uniq -d` returned empty.
- **Checksum conflicts:** Flyway migrations executed successfully in the H2 test environment; no checksum errors observed during `mvn test`.

### 2.3 Schema/entity alignment

| Migration | Schema change | Entity | Aligned |
|-----------|---------------|--------|---------|
| V49 | `erp_employee.division VARCHAR(30)` | `Employee.division` `@Column(length = 30)` | Yes |
| V52 | `leave_policy.vacation_allowance_min_days INTEGER DEFAULT 30 NOT NULL` | `LeavePolicy.vacationAllowanceMinDays` | Yes |
| V52 | `leave_policy.vacation_allowance_frequency_months INTEGER DEFAULT 24 NOT NULL` | `LeavePolicy.vacationAllowanceFrequencyMonths` | Yes |
| V53 | `vacation_leave_allowance` table with FKs to `erp_employee` and `erp_leave_request` | `VacationLeaveAllowance` entity | Yes |
| V54 | Indexes on `erp_employee` hierarchy and `leave_policy(leave_type, division)` | N/A | Yes |

### 2.4 Foreign keys

- `vacation_leave_allowance.employee_id` → `erp_employee(id)`
- `vacation_leave_allowance.leave_request_id` → `erp_leave_request(id)` (nullable)

### 2.5 Constraints

- V50 adds `NOT NULL` constraints on `leave_policy.leave_type`, `gender_restriction`, `day_calculation_mode`, `advance_notice_days`.
- V50 adds `CHECK` constraints for `leave_type` non-blank, `gender_restriction IN ('ALL','FEMALE','MALE')`, `day_calculation_mode IN ('WORKING','CALENDAR')`.
- V50 removes residual `Annual Leave` rows.

### 2.6 Indexes

- `idx_vacation_leave_allowance_employee_created`
- `idx_vacation_leave_allowance_employee_status`
- `idx_erp_employee_supervisor_id`
- `idx_erp_employee_hod_id`
- `idx_erp_employee_team_id`
- `idx_erp_employee_salary_scale`
- `idx_leave_policy_leave_type_division`

### 2.7 Rollback considerations

- **No down migrations provided.** Rollback would require manual scripts or restoring from backup.
- V49 uses PostgreSQL `UPDATE ... FROM` syntax; portability to non-PostgreSQL targets is limited.

### 2.8 Operational note

- Command-line `mvn flyway:info` fails because DB credentials are externalized in `.env` and not supplied to Maven. This is a deployment configuration issue, not a migration defect. Test execution with H2 confirmed migrations apply cleanly.

---

## 3. Leave Calculation Verification

### Trace for a Vacation Leave request

1. **UI / API entry:** `LeaveController.calculateLeave` (preview) or `LeaveController.submitLeaveRequest` (submission).
2. **Controller delegates to:** `LeaveCalculationService.calculate(...)` or `LeaveService.submitLeaveRequest(...)`.
3. **LeaveCalculationService:**
   - Loads employee and resolves policy via `PolicyResolver`.
   - Enforces gender restriction.
   - Validates advance notice (`LocalDate.now().plusDays`).
   - Resolves requested days.
   - Calls `LeaveCalendarService.computeSchedule(...)` for schedule and chargeable days.
   - Evaluates balance via `BalanceEvaluator`.
   - Enforces limits via `LimitEnforcer`.
   - Determines Vacation Leave allowance eligibility.
   - Builds `LeaveCalculationResult`.
4. **LeaveCalendarService:** performs all schedule/date math and returns `ScheduleResult`.
5. **PolicyResolver:** single lookup entry point; derives division from salary scale or stored division, falls back to null-division policy.
6. **Persistence:**
   - Preview path returns the DTO; nothing is written.
   - Submission path saves `LeaveRequest`, applies balance mutation, then calls `logSubmissionAuditAndAllowance`, which persists `VacationLeaveAllowance`.

### Single calculation path

**Confirmed.** Both preview (`/leaves/calculate`) and submission (`POST /leaves`) route through `LeaveCalculationService`. There is no legacy duplicate path or feature-flag branch.

**Evidence:**
- `@/home/chisenga/projects/ERP/localgov-erp/web/src/main/java/com/localgov/web/controller/LeaveController.java:75-84`
- `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveService.java:109-125`

---

## 4. Vacation Leave Allowance Verification

### 4.1 Preview requests never create allowance records

**Confirmed.** `LeaveCalculationService.calculate(...)` does not call `recordVacationLeaveAllowance(...)` or any repository save method.

**Evidence:** `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveCalculationService.java:81-126`

### 4.2 Submission creates eligibility records

**Confirmed.** `LeaveService.submitLeaveRequest` saves `LeaveRequest`, then calls `leaveCalculationService.logSubmissionAuditAndAllowance(...)`, which records a `VacationLeaveAllowance` with status `ELIGIBLE` or `NOT_ELIGIBLE`.

**Evidence:** `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveService.java:162-169` and `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveCalculationService.java:201-219`

### 4.3 Only PAID allowance records participate in the 24-month rule

**Confirmed.** Repository query `findFirstByEmployeeIdAndStatusAndCreatedAtAfterOrderByCreatedAtDesc(..., AllowanceStatus.PAID, ...)` is used exclusively.

**Evidence:** `@/home/chisenga/projects/ERP/localgov-erp/repository/src/main/java/com/localgov/repository/VacationLeaveAllowanceRepository.java:18-24`

### 4.4 `>= 30` working-day rule enforced everywhere

**Confirmed.** `determineAllowanceEligibility` returns `NOT_ELIGIBLE` when `chargeableWorkingDays < threshold` (default 30).

**Evidence:** `@/home/chisenga/projects/ERP/localgov-erp/service/src/main/java/com/localgov/service/LeaveCalculationService.java:177-180`

---

## 5. UI Verification

### Search results

A project-wide search for `Annual Leave`, `ANNUAL`, and `annual leave type` was performed across `.java`, `.js`, `.html`, `.sql`, `.yml`, and `.properties` files.

**Confirmed absent from production code and UI:**
- No `ANNUAL` enum value in `LeaveType`.
- No Annual Leave options in `erp-dashboard.js` or `dashboard.html`.
- No Annual Leave API values in controllers or Swagger examples.
- No Annual Leave policy rows remain after V50.

**Remaining references (acceptable per user instruction):**
- Historical migration notes in V43, V44, and V50 describing the removal of Annual Leave rows.
- Test-only references in `SchemaIntrospectionServiceTest` (noted as Deviation #3 above).
- Unrelated salary features: `AnnualIncrementService`, `process-annual-increment`, "annual appraisal", "Annual limit" (generic limit wording).

---

## 6. Test Coverage Review

### 6.1 Unit coverage

| Class | Test file |
|-------|-----------|
| `LeaveCalendarService` | `@/home/chisenga/projects/ERP/localgov-erp/service/src/test/java/com/localgov/service/leave/LeaveCalendarServiceTest.java` |
| `LeaveAccrualService` | `@/home/chisenga/projects/ERP/localgov-erp/service/src/test/java/com/localgov/service/leave/LeaveAccrualServiceTest.java` |
| `EmployeeService` | `@/home/chisenga/projects/ERP/localgov-erp/service/src/test/java/com/localgov/service/EmployeeServiceTest.java` |
| `PayrollService` | `@/home/chisenga/projects/ERP/localgov-erp/service/src/test/java/com/localgov/service/PayrollServiceTest.java` |
| `LeaveAccessValidator` | `@/home/chisenga/projects/ERP/localgov-erp/service/src/test/java/com/localgov/service/security/LeaveAccessValidatorTest.java` |

`LeaveCalendarServiceTest` covers: weekend exclusion, public holiday exclusion, working-day counting, calendar-day counting, resume-date calculation, next-working-day resolution, authority-specific vs national holidays, and schedule computation for both working-day and fixed-duration modes.

### 6.2 Integration coverage

| Flow | Test file |
|------|-----------|
| Leave calculation preview | `LeaveCalculationIntegrationTest` |
| Leave submission workflow | `LeaveWorkflowIntegrationTest` |
| LeaveCalendarService end-to-end | `LeaveCalendarServiceIntegrationTest` |
| Reporting | `ReportingIntegrationTest` |
| Schema introspection | `SchemaIntrospectionServiceTest` |
| Security/auth | `SecurityIntegrationTest` |

### 6.3 Migration coverage

Migrations are exercised automatically during every Spring Boot integration test startup via Flyway against H2 in PostgreSQL mode. No separate migration-specific test exists.

### 6.4 Policy coverage

Integration tests seed a representative set of policies (Vacation, Local, Sick, Maternity, Paternity, Compassionate, Family Care, Mother's Day, Study, Unpaid) and exercise division resolution for `Division I`–`Division IV`. The null-division fallback policy is created by V51 and is exercised implicitly when no division-specific policy exists.

### 6.5 Missing edge cases

1. **24-month PAID rule integration test:** No dedicated test seeds a PAID allowance record and verifies it blocks a subsequent eligibility request.
2. **Rejected/cancelled non-blocking rule:** No dedicated test verifies that `REJECTED` or `CANCELLED` statuses do not block future allowance eligibility.
3. **Null-division fallback:** Not explicitly asserted in an integration test.
4. **Authority-specific public holidays:** Only national holidays are exercised in integration tests; authority-specific holiday lookup is unit-tested only.
5. **Date-sensitive integration tests:** Several tests use hardcoded calendar dates; as the current date advances, `@FutureOrPresent` validation will fail again unless dates are made relative.

---

## 7. Risk Assessment

| # | Risk | Severity | Rationale |
|---|------|----------|-----------|
| 1 | Hardcoded calendar dates in integration tests will fail when real time advances. | Critical | Tests passed today but will break on/after the hardcoded dates because of `@FutureOrPresent` validation. |
| 2 | `SchemaIntrospectionService` duplicates date arithmetic outside `LeaveCalendarService`. | Medium | Could produce example schedules inconsistent with the real leave engine. |
| 3 | No Flyway down-migrations. | Medium | Rollback of Phase 1 schema changes requires manual scripts. |
| 4 | V49 uses PostgreSQL-specific `UPDATE ... FROM` syntax. | Medium | Limits portability; may fail on non-PostgreSQL targets. |
| 5 | Allowance default values (30 days / 24 months) are duplicated in service code and migrations. | Medium | No single source of truth; changing defaults requires edits in multiple places. |
| 6 | `SchemaIntrospectionServiceTest` still references Annual Leave. | Low | Test-only; does not affect production behavior. |
| 7 | Contract test suite (`mvn verify`) was not completed in this session. | Medium | Unclear if API contract tests pass against the new response shape. |
| 8 | V50 unconditionally deletes `Annual Leave` rows; safe but destructive if any legitimate Annual Leave data should have been migrated. | Low | User mandated removal of Annual Leave; migration aligns with that decision. |

---

## 8. Phase 2 Readiness

### Recommendation

**The codebase is structurally ready for Phase 2 — Transactional Balance Ledger, provided the following corrective actions are taken first:**

1. **Fix date-sensitive tests (Critical).** Replace hardcoded dates in `LeaveCalculationIntegrationTest` and `LeaveWorkflowIntegrationTest` with dates computed relative to `LocalDate.now()`.
2. **Complete contract test run.** Run `mvn -pl web -am verify` and fix any contract failures before Phase 2 begins.
3. **Add missing allowance edge-case tests.** Cover the 24-month PAID rule and rejected/cancelled non-blocking behavior.
4. **Align `SchemaIntrospectionService` with `LeaveCalendarService`.** Delegate its date arithmetic to the single calendar owner or clearly document it as out-of-scope sample data.
5. **Introduce a constants class for allowance defaults.** Replace literal `30` / `24` in service code with a shared constant or policy default to reduce duplication.

If these actions are completed, Phase 1 can be considered fully verified and Phase 2 can commence with a stable foundation.
