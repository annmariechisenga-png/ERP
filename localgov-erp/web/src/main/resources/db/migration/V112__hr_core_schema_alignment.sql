-- ============================================================================
-- V112: HR Core — Schema Alignment
-- ----------------------------------------------------------------------------
-- Aligns employees table with official HR register.
-- Reconciles duplicate columns (drops unused gender; phone replaced with
-- phone_number in dependent views before drop).
--
-- Multi-tenant: every view includes authority_code.
--
-- Depends on: V1, V55, V56, V78-V80 (salary advances)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- PART 1: Reconcile `phone` — update dependent views first, then drop
-- ---------------------------------------------------------------------------

-- 1a. Update vw_active_salary_advances to use phone_number instead of phone
--     and to use canonical name from parts (fallback to name)
DROP VIEW IF EXISTS vw_active_salary_advances;

CREATE VIEW vw_active_salary_advances AS
SELECT 
    sa.advance_id,
    sa.employee_id,
    COALESCE(
        NULLIF(TRIM(BOTH ' ' FROM 
            COALESCE(e.first_name,'') || ' ' || 
            COALESCE(e.middle_name,'') || ' ' || 
            COALESCE(e.last_name,'')), ''),
        e.name
    ) AS employee_name,
    e.department,
    e.phone_number AS phone,
    sa.reference_number,
    sa.amount_approved,
    sa.monthly_deduction,
    sa.total_repaid,
    sa.remaining_balance,
    sa.repayment_months,
    sa.deduction_start_month,
    sa.deduction_end_month,
    sa.status,
    sa.approved_by_name,
    sa.approved_at,
    CASE
        WHEN sa.remaining_balance > 0 AND sa.monthly_deduction > 0 
            THEN ceil(sa.remaining_balance / sa.monthly_deduction)
        ELSE 0
    END AS months_remaining,
    CASE
        WHEN sa.deduction_start_month <= date_trunc('month', CURRENT_DATE)
             AND sa.remaining_balance > 0 
            THEN 'Active - Deduction due this month'
        WHEN sa.deduction_start_month > date_trunc('month', CURRENT_DATE) 
            THEN 'Pending - Deduction starts ' || to_char(sa.deduction_start_month, 'FMMonth YYYY')
        WHEN sa.remaining_balance <= 0 
            THEN 'Completed'
        ELSE 'On Hold'
    END AS deduction_status
FROM salary_advances sa
JOIN employees e ON sa.employee_id = e.employee_id
WHERE sa.status IN ('approved', 'active')
ORDER BY sa.deduction_start_month NULLS FIRST, sa.approved_at DESC;

-- 1b. Now safe to drop phone (view no longer references it)
ALTER TABLE employees DROP COLUMN IF EXISTS phone;

-- ---------------------------------------------------------------------------
-- PART 2: Reconcile `gender` — check for dependencies, then drop
-- ---------------------------------------------------------------------------

-- 2a. No dependent views reference gender (verified by diagnostic)
ALTER TABLE employees DROP COLUMN IF EXISTS gender;

-- ---------------------------------------------------------------------------
-- PART 3: Add missing columns from source register
-- ---------------------------------------------------------------------------

ALTER TABLE employees ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE employees ADD COLUMN IF NOT EXISTS lgsc_comment TEXT;

COMMENT ON COLUMN employees.date_reported IS 
    'Date of Arrival at Local Authority. Length of stay = CURRENT_DATE - date_reported. Multi-tenant scoped per authority_code.';

COMMENT ON COLUMN employees.date_of_first_appointment IS 
    'Date of First Appointment (DOFA). Total years of service = CURRENT_DATE - date_of_first_appointment.';

-- ---------------------------------------------------------------------------
-- PART 4: Backfill `name` from first_name + last_name (canonical)
-- ---------------------------------------------------------------------------
UPDATE employees 
SET name = TRIM(BOTH ' ' FROM 
        COALESCE(first_name, '') || ' ' || 
        COALESCE(middle_name, '') || ' ' || 
        COALESCE(last_name, ''))
WHERE name IS NULL OR TRIM(name) = '';

-- ---------------------------------------------------------------------------
-- PART 5: Create view for employee register (derived columns)
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS v_employee_register;

CREATE VIEW v_employee_register AS
SELECT 
    e.employee_id,
    e.employee_uuid,
    e.authority_code,
    e.province,
    e.district,
    e.department,
    e.position,
    e.salary_scale,
    e.employment_status,
    e.contract_type,
    COALESCE(
        NULLIF(TRIM(BOTH ' ' FROM 
            COALESCE(e.first_name,'') || ' ' || 
            COALESCE(e.middle_name,'') || ' ' || 
            COALESCE(e.last_name,'')), ''),
        e.name
    ) AS full_name,
    e.sex,
    CASE 
        WHEN e.date_of_birth IS NOT NULL THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth))::int
        ELSE NULL
    END AS age_years,
    e.date_of_first_appointment,
    e.date_confirmed,
    e.date_substantive_appointment,
    e.date_reported,
    CASE
        WHEN e.salary_scale ~ '^LGSS/0[2-7]$' THEN 'I'
        WHEN e.salary_scale ~ '^LGSS/0[8-9]$' OR e.salary_scale ~ '^LGSS/1[0-2]$' THEN 'II'
        WHEN e.salary_scale ~ '^LGSS/1[3-8]$' THEN 'III'
        WHEN e.salary_scale IN ('G1','G2','G3','Grade 1','Grade 2','Grade 3') THEN 'IV'
        ELSE NULL
    END AS division,
    CASE 
        WHEN e.date_reported IS NOT NULL THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_reported))::int
        ELSE NULL
    END AS years_of_stay,
    CASE 
        WHEN e.date_reported IS NOT NULL THEN
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, e.date_reported))::int
        ELSE NULL
    END AS months_of_stay,
    CASE 
        WHEN e.date_reported IS NOT NULL THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_reported))::int || ' years ' ||
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, e.date_reported))::int || ' months'
        ELSE NULL
    END AS length_of_stay,
    CASE 
        WHEN e.date_reported IS NOT NULL THEN 
            'Filled in on ' || to_char(e.date_reported, 'DD.MM.YYYY')
        ELSE 'Vacant'
    END AS vacancy_status,
    CASE 
        WHEN e.date_of_first_appointment IS NOT NULL THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_first_appointment))::int
        ELSE NULL
    END AS years_of_service,
    CASE 
        WHEN e.date_of_first_appointment IS NOT NULL THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_first_appointment))::int || ' years ' ||
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, e.date_of_first_appointment))::int || ' months'
        ELSE NULL
    END AS service_length,
    e.acting_position,
    e.acting_date,
    e.academic_qualifications,
    e.professional_qualifications,
    e.phone_number,
    e.email,
    e.nrc_number,
    e.tpin,
    e.napsa_number,
    e.nhima_number,
    e.lasf_number,
    e.local_authority_service_number,
    e.bank_name,
    e.bank_branch,
    e.bank_account_number,
    e.bank_account_name,
    e.default_fund_id,
    e.default_cost_center_id,
    e.leave_balance,
    e.supervisor_id,
    e.notification_preference,
    e.remarks,
    e.lgsc_comment,
    e.created_at,
    e.updated_at
FROM employees e;

COMMENT ON VIEW v_employee_register IS 
    'Full employee register with derived columns (division, length of stay, vacancy status, full name). Multi-tenant: filter by authority_code.';

-- ---------------------------------------------------------------------------
-- PART 6: Division summary view
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS v_employee_division_summary;

CREATE VIEW v_employee_division_summary AS
SELECT 
    authority_code,
    division,
    sex,
    COUNT(*) AS employee_count
FROM v_employee_register
WHERE employment_status = 'ACTIVE'
  AND division IS NOT NULL
  AND sex IS NOT NULL
GROUP BY authority_code, division, sex
ORDER BY authority_code, division, sex;

COMMENT ON VIEW v_employee_division_summary IS 
    'Count of active employees per authority by division and sex. Replaces manual spreadsheet COUNTIFS. Multi-tenant scoped.';

-- ---------------------------------------------------------------------------
-- PART 7: Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_employees_scale_div
    ON employees(authority_code, salary_scale) 
    WHERE employment_status = 'ACTIVE';

CREATE INDEX IF NOT EXISTS idx_employees_reported
    ON employees(authority_code, date_reported) 
    WHERE date_reported IS NOT NULL;

-- ---------------------------------------------------------------------------
-- PART 8: Verification
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    emp_count INTEGER;
    register_count INTEGER;
    summary_count INTEGER;
    has_phone BOOLEAN;
    has_gender BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO emp_count FROM employees;
    SELECT COUNT(*) INTO register_count FROM v_employee_register;
    SELECT COUNT(*) INTO summary_count FROM v_employee_division_summary;

    -- Confirm columns were dropped
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'employees' AND column_name = 'phone'
    ) INTO has_phone;

    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'employees' AND column_name = 'gender'
    ) INTO has_gender;

    IF emp_count != register_count THEN
        RAISE EXCEPTION 'V112 FAILED: employees=%, register=%', emp_count, register_count;
    END IF;

    IF has_phone THEN
        RAISE EXCEPTION 'V112 FAILED: phone column still exists';
    END IF;

    IF has_gender THEN
        RAISE EXCEPTION 'V112 FAILED: gender column still exists';
    END IF;

    RAISE NOTICE 'V112 PASSED: % employees, % division summaries, phone dropped, gender dropped',
                 register_count, summary_count;
END $$;
