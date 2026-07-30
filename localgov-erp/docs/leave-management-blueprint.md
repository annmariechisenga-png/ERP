# Enterprise Leave Management Implementation Blueprint
## Phase 1 — Vacation Leave Refactoring

**Status:** Architecture approved with mandatory refinements.  
**Scope:** Replace Annual Leave with Vacation Leave, freeze Phase 1 boundaries, and establish the LeaveCalendarService architecture.

---

## 1. Architecture Freeze

The following business decisions are final for Phase 1 and all future phases.

- **Annual Leave does not exist as a leave type.**
- Vacation Leave is the official annual leave entitlement.
- There must be:
  - no `Annual Leave` enum value
  - no `Annual Leave` policy rows
  - no `Annual Leave` UI options
  - no `Annual Leave` API values
  - no `Annual Leave` migration rows
- Legacy Annual Leave records must always migrate to `Vacation Leave` in any future data-migration phase.

---

## 2. Leave Calendar Architecture

### 2.1 New Service: `LeaveCalendarService`

A dedicated service is introduced as the **single owner** of all calendar and date arithmetic.

Responsibilities:

| Method | Purpose |
|--------|---------|
| `countWorkingDays(start, end, authorityCode)` | Working days excluding weekends and public holidays |
| `countCalendarDays(start, end)` | Calendar days in inclusive range |
| `excludeWeekends(start, end)` | Count weekend days in range |
| `excludePublicHolidays(start, end, authorityCode)` | Count public holidays in range |
| `calculateResumeDate(endDate, authorityCode)` | Next working day after leave ends |
| `isWorkingDay(date, authorityCode)` | Not weekend and not public holiday |
| `isWeekend(date)` | Saturday or Sunday |
| `isPublicHoliday(date, authorityCode)` | Public holiday for authority/nation |
| `nextWorkingDay(date, authorityCode)` | First working day on or after date |
| `computeSchedule(...)` | Complete leave schedule record (`ScheduleResult`) |

### 2.2 Flow

```
Browser
  ↓
LeaveController
  ↓
LeaveCalculationService
  ↓
LeaveCalendarService
  ↓
LeaveCalculationResult
  ↓
LeaveService
  ↓
Persistence
```

### 2.3 Service Ownership

- `LeaveCalendarService` → date/calendar engine.
- `LeaveCalculationService` → orchestration: policy lookup, validation, advance notice, eligibility, allowance, balance, limits, and result creation.
- `LeaveService` → persistence orchestration: save `LeaveRequest`, call `logSubmissionAuditAndAllowance(...)`.

### 2.4 Removed Components

- `LeaveCalendar` helper class (legacy) is deleted.
- No direct date arithmetic in `LeaveCalculationService` or `LeaveService`.

---

## 3. Leave Calculation Responsibilities

`LeaveCalculationService` owns:

- policy lookup via `PolicyResolver`
- policy validation (gender restriction)
- advance notice validation (Vacation Leave)
- leave eligibility
- **Vacation Leave allowance eligibility**
- balance validation
- limit enforcement via `LimitEnforcer`
- orchestration of `LeaveCalendarService`
- creation of `LeaveCalculationResult`

It does **not** perform direct calendar calculations.

---

## 4. Vacation Leave Allowance

### 4.1 No `VacationAllowanceService`

All allowance eligibility logic lives inside `LeaveCalculationService`.

### 4.2 Persistence Model

- Entity: `VacationLeaveAllowance` (not `VacationLeaveAllowanceHistory`).
- Table: `vacation_leave_allowance`.
- Represents the **complete lifecycle** of an allowance and is designed for future extension.

### 4.3 Lifecycle Status

`AllowanceStatus` enum values:

| Status | Phase 1 | Future Phases |
|--------|---------|---------------|
| `NOT_ELIGIBLE` | Yes | Yes |
| `ELIGIBLE` | Yes | Yes |
| `APPROVED` | No | Yes |
| `PAID` | No | Yes |
| `REVERSED` | No | Yes |

No `String` event types are used.

### 4.4 Preview Non-Persistence

- `LeaveCalculationService.calculate(...)` is a **pure preview**.
- It performs no database writes.
- The `VacationLeaveAllowance` table must **never** contain preview records.
- Real business events (submission) trigger persistence.

### 4.5 24-Month Rule

The 24-month rule is based **only** on `PAID` allowance records.

Not based on:
- preview
- calculation
- submission
- approval

Rejected, cancelled, and preview records must never block future allowance eligibility.

Implementation:

```java
Optional<VacationLeaveAllowance> paidWithinWindow =
    repository.findFirstByEmployeeIdAndStatusAndCreatedAtAfterOrderByCreatedAtDesc(
        employeeId, AllowanceStatus.PAID, LocalDateTime.now().minusMonths(24));
```

### 4.6 Eligibility Threshold

Vacation Leave allowance eligibility uses:

```java
chargeableWorkingDays >= 30
```

Never use `== 30`.

---

## 5. Entity Design

### 5.1 `LeavePolicy`

New columns for Vacation Leave allowance policy:

- `vacation_allowance_min_days` (default 30)
- `vacation_allowance_frequency_months` (default 24)

### 5.2 `VacationLeaveAllowance`

| Field | Type | Notes |
|-------|------|-------|
| `id` | BIGINT PK | |
| `employee_id` | BIGINT FK | `erp_employee(id)` |
| `leave_request_id` | BIGINT FK | `erp_leave_request(id)`, nullable |
| `authority_code` | VARCHAR(10) | |
| `status` | VARCHAR(20) | `AllowanceStatus` enum |
| `payment_date` | DATE | Future phase |
| `period_start_date` | DATE | |
| `period_end_date` | DATE | |
| `chargeable_working_days` | INTEGER | |
| `reason` | VARCHAR(255) | Eligibility reason |
| `created_by` | VARCHAR(120) | |
| `created_at` | TIMESTAMP | |
| `username` | VARCHAR(80) | Audit context |
| `authority_type` | VARCHAR(50) | Audit context |
| `role` | VARCHAR(200) | Audit context |

### 5.3 `AllowanceStatus`

```java
public enum AllowanceStatus {
    NOT_ELIGIBLE,
    ELIGIBLE,
    APPROVED,
    PAID,
    REVERSED
}
```

### 5.4 `Employee`

- `division` expanded to `VARCHAR(30)` to hold canonical labels (`Division I`–`Division IV`).
- `salary_scale` is already mapped to `VARCHAR(30)`.

---

## 6. Repository Design

### 6.1 `VacationLeaveAllowanceRepository`

```java
public interface VacationLeaveAllowanceRepository
    extends JpaRepository<VacationLeaveAllowance, Long> {

    Optional<VacationLeaveAllowance>
        findFirstByEmployeeIdAndStatusAndCreatedAtAfterOrderByCreatedAtDesc(
            Long employeeId, AllowanceStatus status, LocalDateTime since);
}
```

---

## 7. DTO Design

### 7.1 `LeaveCalculationResult`

Composite record with `@JsonUnwrapped` sub-records:

- `CalculationSummary`
- `PolicyEvaluation`
- `BalanceProjection`
- `AllowanceEvaluation`

Includes allowance fields for Vacation Leave:

- `allowanceEligible`
- `allowanceReason`
- `allowanceThresholdDays`
- `allowanceFrequencyMonths`

### 7.2 `LeaveCalculationRequest`

Preview/submission request containing:

- `employeeId`
- `leaveType`
- `startDate`
- `requestedDays`
- `compassionateRelation`

### 7.3 `ScheduleResult`

Record returned by `LeaveCalendarService.computeSchedule(...)`:

- `startDate`
- `endDate`
- `resumptionDate`
- `chargeableDays`
- `weekendDaysSkipped`
- `publicHolidaysSkipped`

---

## 8. Service Design

### 8.1 `LeaveCalendarService`

- `@Service`
- Single constructor receiving `PublicHolidayRepository`.
- Stateless calendar engine.

### 8.2 `LeaveCalculationService`

- `@Service` with `@Transactional(readOnly = true)`.
- Constructor dependencies:
  - `PolicyResolver`
  - `LeaveCalendarService`
  - `BalanceEvaluator`
  - `LimitEnforcer`
  - `EmployeeService`
  - `CalculationAuditor`
  - `VacationLeaveAllowanceRepository`
  - `AuthenticatedUserContextResolver`

Public methods:

- `LeaveCalculationResult calculate(LeaveCalculationRequest)` — pure preview, no writes.
- `void logSubmissionAuditAndAllowance(Long employeeId, Long leaveRequestId, LeaveCalculationResult)` — persists submission audit and allowance.
- `LeavePolicy loadPolicy(LeaveType, Employee)`
- `int countWorkingDays(...)` / `int countCalendarDays(...)`
- `int resolveRequestedDaysForRange(LeavePolicy, LocalDate, LocalDateDate, String)`

### 8.3 `LeaveService`

- Removed feature-flag branching (`LeaveFeatureFlags`).
- Removed legacy calculation path.
- Removed direct calendar helpers (`countWorkingDays`, `isNonWorking`).
- Removed direct `CalculationAuditor` usage.
- Submission flow:
  1. validate access and basic request
  2. resolve requested days from date range via `LeaveCalculationService`
  3. call `LeaveCalculationService.calculate(...)`
  4. enforce Family Care annual limit
  5. apply balance deduction
  6. create and save `LeaveRequest`
  7. call `LeaveCalculationService.logSubmissionAuditAndAllowance(...)`

---

## 9. Migration Plan (Frozen: V49–V54)

| Migration | Purpose |
|-----------|---------|
| `V49__seed_employee_salary_scale_and_division.sql` | Seed salary_scale and division for demo users; widen `erp_employee.division` to `VARCHAR(30)` |
| `V50__add_leave_policy_constraints.sql` | Enforce data integrity; remove residual Annual Leave rows; NOT NULL and CHECK constraints |
| `V51__seed_null_division_vacation_policy.sql` | Insert fallback `Vacation Leave` policy with `division = NULL` |
| `V52__add_vacation_allowance_policy_columns.sql` | Add `vacation_allowance_min_days` and `vacation_allowance_frequency_months` to `leave_policy` |
| `V53__add_vacation_leave_allowance_table.sql` | Create `vacation_leave_allowance` table and indexes |
| `V54__add_employee_hierarchy_indexes.sql` | Add hierarchy and policy lookup indexes |

**Migration numbering is frozen.** No renumbering after implementation begins.

---

## 10. Testing Strategy

### 10.1 `LeaveCalendarService` Unit Tests

- weekend exclusion
- public holiday exclusion
- working day calculation
- calendar day calculation
- resume date calculation
- next working day calculation
- authority-specific vs national holiday handling

### 10.2 `LeaveCalendarService` Integration Tests

Scenario:

- Employee starts Vacation Leave on a Friday.
- Duration qualifies for allowance.
- Period includes multiple weekends and public holidays.

Verify:

- chargeable working days
- resume date
- allowance eligibility (`chargeableWorkingDays >= 30`)
- policy lookup
- advance notice validation

### 10.3 `LeaveCalculationService` Tests

- preview does not persist
- submission persists `VacationLeaveAllowance` with correct status
- 24-month rule uses only `PAID` records
- rejected/cancelled records do not block eligibility
- advance notice validation for Vacation Leave

---

## 11. UI / API Changes

- Remove all Annual Leave options and labels.
- Leave type list returns only current types (`VACATION`, `LOCAL`, `SICK`, etc.).
- Swagger examples updated to use `VACATION` instead of `ANNUAL`.
- UI advance-notice banner and date-min logic apply only to `VACATION`.

---

## 12. Out of Scope (Future Phases)

Do **not** implement in Phase 1:

- workflow engine
- notifications
- authority-specific policies beyond the null-division fallback
- legacy data migration (actual migration execution)
- transaction ledger
- HR compliance reporting ("officer must proceed on Vacation Leave every year")

---

## 13. Deliverables After Phase 1 Implementation

1. Implementation summary.
2. Files modified.
3. Migration report.
4. Architectural deviations (if any).
5. Test results.
6. Risks discovered during implementation.
7. Recommendations before Phase 2.
