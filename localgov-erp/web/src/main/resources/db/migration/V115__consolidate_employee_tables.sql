-- ============================================================================
-- V115: HR Employee Table Consolidation
-- ----------------------------------------------------------------------------
-- The system has two employee tables:
--   - employees:    real HR master (183 rows, V112/V114 schema)
--   - erp_employee: legacy prototype (2 test rows only)
--
-- Four tables still reference erp_employee:
--   - erp_leave_request.employee_id
--   - erp_payroll_record.employee_id
--   - salary_advance_request.employee_id
--   - salary_advance_deduction.employee_id
--
-- Two views reference erp_employee (created in V8):
--   - eng_summary_by_council
--   - eng_staff_by_unit
--
-- This migration:
--   1. Drops the two legacy reporting views
--   2. Deletes all test rows from the four legacy FK tables
--   3. Drops the FK constraints to erp_employee
--   4. Alters employee_id columns from bigint to text
--   5. Recreates FK constraints pointing to employees.employee_id
--   6. Drops erp_employee (test data only)
--   7. Recreates the two reporting views against employees
--
-- Depends on: V114 (finalized employees schema)
-- ============================================================================

-- PART 1: Drop legacy reporting views
DROP VIEW IF EXISTS eng_staff_by_unit;
DROP VIEW IF EXISTS eng_summary_by_council;

-- PART 2: Delete test data from legacy FK tables
DELETE FROM salary_advance_deduction;
DELETE FROM salary_advance_request;
DELETE FROM erp_payroll_record;
DELETE FROM erp_leave_request;

-- PART 3: Drop FK constraints to erp_employee
ALTER TABLE erp_leave_request
    DROP CONSTRAINT IF EXISTS fktgp5g2awah8764d1fl9fqbj2f;
ALTER TABLE erp_payroll_record
    DROP CONSTRAINT IF EXISTS fksv42bxmn93kowyhbfo4lenvw5;
ALTER TABLE salary_advance_request
    DROP CONSTRAINT IF EXISTS fk_salary_advance_employee;
ALTER TABLE salary_advance_deduction
    DROP CONSTRAINT IF EXISTS fk_salary_advance_deduction_employee;

-- PART 4: Alter employee_id columns from bigint to text
ALTER TABLE erp_leave_request
    ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE erp_payroll_record
    ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE salary_advance_request
    ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE salary_advance_deduction
    ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;

-- PART 5: Recreate FK constraints to employees
ALTER TABLE erp_leave_request
    ADD CONSTRAINT erp_leave_request_employee_id_fkey
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE erp_payroll_record
    ADD CONSTRAINT erp_payroll_record_employee_id_fkey
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE salary_advance_request
    ADD CONSTRAINT salary_advance_request_employee_id_fkey
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE salary_advance_deduction
    ADD CONSTRAINT salary_advance_deduction_employee_id_fkey
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

-- PART 6: Drop erp_employee
DROP TABLE IF EXISTS erp_employee;
DROP SEQUENCE IF EXISTS erp_employee_id_seq;

-- PART 7: Recreate reporting views against employees
CREATE VIEW eng_staff_by_unit AS
SELECT 
    department,
    position AS position_title,
    COUNT(*) AS staff_count
FROM employees
WHERE employment_status = 'ACTIVE'
  AND department IS NOT NULL
  AND position IS NOT NULL
GROUP BY department, position;

CREATE VIEW eng_summary_by_council AS
SELECT 
    department,
    COUNT(*) AS employee_count,
    NULL::numeric AS average_salary,
    NULL::numeric AS min_salary,
    NULL::numeric AS max_salary
FROM employees
WHERE employment_status = 'ACTIVE'
  AND department IS NOT NULL
GROUP BY department;

COMMENT ON VIEW eng_summary_by_council IS 
    'Summary per department. Salary columns are NULL pending payroll engine (V120).';

-- PART 8: Verification
DO $$
DECLARE
    erp_employee_exists BOOLEAN;
    employee_count INTEGER;
    fk_count INTEGER;
    views_count INTEGER;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables WHERE table_name = 'erp_employee'
    ) INTO erp_employee_exists;

    IF erp_employee_exists THEN
        RAISE EXCEPTION 'V115 FAILED: erp_employee table still exists';
    END IF;

    SELECT COUNT(*) INTO employee_count FROM employees;
    IF employee_count < 180 THEN
        RAISE EXCEPTION 'V115 FAILED: employees has only % rows', employee_count;
    END IF;

    SELECT COUNT(*) INTO fk_count
    FROM information_schema.table_constraints tc
    JOIN information_schema.constraint_column_usage ccu
      ON tc.constraint_name = ccu.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY' AND ccu.table_name = 'erp_employee';

    IF fk_count > 0 THEN
        RAISE EXCEPTION 'V115 FAILED: % FKs still reference erp_employee', fk_count;
    END IF;

    SELECT COUNT(*) INTO views_count
    FROM pg_views
    WHERE schemaname = 'public' 
      AND viewname IN ('eng_staff_by_unit', 'eng_summary_by_council');

    IF views_count != 2 THEN
        RAISE EXCEPTION 'V115 FAILED: expected 2 reporting views, found %', views_count;
    END IF;

    RAISE NOTICE 'V115 PASSED: employees=%, erp_employee dropped, 2 views recreated', employee_count;
END $$;
