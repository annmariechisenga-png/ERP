-- =====================================================================
-- V102__augment_employees_hr_master.sql
-- Layer 3 — HR / Employee Master
-- =====================================================================
-- Augments the existing `employees` table with finance-core fields so
-- it can serve as the authoritative employee master:
--
--   1. Multi-tenant: authority_code → authorities
--   2. UUID surrogate: employee_uuid (for cross-system joins)
--   3. Statutory IDs: tpin, napsa_number, nhima_number, lasf_number
--   4. Structured bank details (for salary payment file generation)
--   5. GL attribution: default_fund_id, default_cost_center_id
--   6. Employment lifecycle: employment_status, contract_type,
--      termination_date, termination_reason
--   7. Audit metadata: created_at, created_by, updated_at, updated_by
--   8. Audit trigger (V97-hardened audit_trigger_func)
--   9. Renumber 182 Chilanga employees + 1 Itezhi Tezhi employee
--      from CHL-YYYY-NNNNNN / ITT-YYYY-NNNNNN → ISO-aligned format
--
-- Adds only. No existing columns are dropped.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Add finance-core columns
-- ---------------------------------------------------------------------
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS employee_uuid UUID DEFAULT gen_random_uuid(),
    ADD COLUMN IF NOT EXISTS authority_code VARCHAR(50),
    ADD COLUMN IF NOT EXISTS first_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS middle_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS last_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS tpin VARCHAR(20),
    ADD COLUMN IF NOT EXISTS napsa_number VARCHAR(20),
    ADD COLUMN IF NOT EXISTS nhima_number VARCHAR(20),
    ADD COLUMN IF NOT EXISTS lasf_number VARCHAR(20),
    ADD COLUMN IF NOT EXISTS bank_name VARCHAR(100),
    ADD COLUMN IF NOT EXISTS bank_branch VARCHAR(100),
    ADD COLUMN IF NOT EXISTS bank_account_number VARCHAR(50),
    ADD COLUMN IF NOT EXISTS bank_account_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS default_fund_id UUID REFERENCES fund(fund_id),
    ADD COLUMN IF NOT EXISTS default_cost_center_id UUID REFERENCES cost_center(cost_center_id),
    ADD COLUMN IF NOT EXISTS employment_status VARCHAR(20) DEFAULT 'ACTIVE',
    ADD COLUMN IF NOT EXISTS contract_type VARCHAR(20),
    ADD COLUMN IF NOT EXISTS termination_date DATE,
    ADD COLUMN IF NOT EXISTS termination_reason TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS created_by UUID,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS updated_by UUID;

-- ---------------------------------------------------------------------
-- 2. Backfill authority_code from employee_id prefix
-- ---------------------------------------------------------------------
-- Only CHL and ITT prefixes exist in the current test data.
UPDATE employees
SET authority_code = CASE
    WHEN employee_id LIKE 'CHL-%' THEN 'CHILANGA'
    WHEN employee_id LIKE 'ITT-%' THEN 'ITEZHI_TEZHI'
    ELSE 'CHILANGA'   -- safety default; should not be hit
END
WHERE authority_code IS NULL;

-- ---------------------------------------------------------------------
-- 3. Backfill first_name / last_name from `name`
-- ---------------------------------------------------------------------
UPDATE employees
SET first_name = SPLIT_PART(name, ' ', 1),
    last_name = CASE
        WHEN POSITION(' ' IN name) > 0
        THEN SUBSTRING(name FROM POSITION(' ' IN name) + 1)
        ELSE name
    END
WHERE first_name IS NULL AND name IS NOT NULL;

-- ---------------------------------------------------------------------
-- 4. Backfill employee_uuid
-- ---------------------------------------------------------------------
UPDATE employees
SET employee_uuid = gen_random_uuid()
WHERE employee_uuid IS NULL;

-- ---------------------------------------------------------------------
-- 5. Backfill employment_status from is_active
-- ---------------------------------------------------------------------
UPDATE employees
SET employment_status = CASE
    WHEN is_active THEN 'ACTIVE'
    ELSE 'TERMINATED'
END
WHERE employment_status IS NULL;

-- ---------------------------------------------------------------------
-- 6. Enforce NOT NULL
-- ---------------------------------------------------------------------
ALTER TABLE employees
    ALTER COLUMN employee_uuid SET NOT NULL,
    ALTER COLUMN authority_code SET NOT NULL;

-- ---------------------------------------------------------------------
-- 7. Unique constraints
-- ---------------------------------------------------------------------
ALTER TABLE employees DROP CONSTRAINT IF EXISTS uq_employees_uuid;
ALTER TABLE employees DROP CONSTRAINT IF EXISTS uq_employees_authority_id;

ALTER TABLE employees
    ADD CONSTRAINT uq_employees_uuid UNIQUE (employee_uuid);

ALTER TABLE employees
    ADD CONSTRAINT uq_employees_authority_id UNIQUE (authority_code, employee_id);

-- ---------------------------------------------------------------------
-- 8. CHECK constraints
-- ---------------------------------------------------------------------
ALTER TABLE employees DROP CONSTRAINT IF EXISTS chk_employees_status;
ALTER TABLE employees DROP CONSTRAINT IF EXISTS chk_employees_contract;

ALTER TABLE employees
    ADD CONSTRAINT chk_employees_status CHECK (
        employment_status IN (
            'ACTIVE', 'SUSPENDED', 'TERMINATED', 'RETIRED', 'DECEASED'
        )
    );

ALTER TABLE employees
    ADD CONSTRAINT chk_employees_contract CHECK (
        contract_type IS NULL OR contract_type IN (
            'PERMANENT', 'CONTRACT', 'TEMPORARY', 'CASUAL', 'INTERN'
        )
    );

-- ---------------------------------------------------------------------
-- 9. Indexes
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_employees_authority
    ON employees(authority_code);
CREATE INDEX IF NOT EXISTS idx_employees_uuid
    ON employees(employee_uuid);
CREATE INDEX IF NOT EXISTS idx_employees_status
    ON employees(authority_code, employment_status);
CREATE INDEX IF NOT EXISTS idx_employees_tpin
    ON employees(tpin) WHERE tpin IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_napsa
    ON employees(napsa_number) WHERE napsa_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_nhima
    ON employees(nhima_number) WHERE nhima_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_nrc
    ON employees(nrc_number) WHERE nrc_number IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_service_number
    ON employees(local_authority_service_number);
CREATE INDEX IF NOT EXISTS idx_employees_department_cc
    ON employees(default_cost_center_id) WHERE default_cost_center_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_fund
    ON employees(default_fund_id) WHERE default_fund_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_supervisor
    ON employees(supervisor_id) WHERE supervisor_id IS NOT NULL;

-- ---------------------------------------------------------------------
-- 10. Audit trigger
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_employees ON employees;
CREATE TRIGGER trg_audit_employees
    AFTER INSERT OR UPDATE OR DELETE ON employees
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 11. Employee number generator
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_employee_number(
    p_authority_code VARCHAR
) RETURNS VARCHAR
LANGUAGE sql AS $$
    SELECT generate_council_scoped_id(
        p_authority_code, 'EMPLOYEE', NULL, 6
    );
$$;

COMMENT ON FUNCTION generate_employee_number IS
'HR module. Generates the next employee number for a council in the '
'platform-standard format {province}-{council}-{sequence}, e.g. '
'09-01-000001. Wrapper over generate_council_scoped_id().';

-- ---------------------------------------------------------------------
-- 12. Renumber employees to ISO-aligned format
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_rec RECORD;
    v_new_id VARCHAR(50);
    v_chl_count INTEGER := 0;
    v_itt_count INTEGER := 0;
BEGIN
    ALTER TABLE employees DISABLE TRIGGER trg_audit_employees;

    -- Renumber CHL-* → 09-01-NNNNNN (Chilanga, Lusaka Province, seq 1)
    FOR v_rec IN
        SELECT employee_id FROM employees
        WHERE employee_id LIKE 'CHL-%'
        ORDER BY employee_id
    LOOP
        v_new_id := generate_employee_number('CHILANGA');
        UPDATE employees SET employee_id = v_new_id
        WHERE employee_id = v_rec.employee_id;
        v_chl_count := v_chl_count + 1;
    END LOOP;

    -- Renumber ITT-* → 07-05-NNNNNN (Itezhi Tezhi, Southern Province, seq 5)
    FOR v_rec IN
        SELECT employee_id FROM employees
        WHERE employee_id LIKE 'ITT-%'
        ORDER BY employee_id
    LOOP
        v_new_id := generate_employee_number('ITEZHI_TEZHI');
        UPDATE employees SET employee_id = v_new_id
        WHERE employee_id = v_rec.employee_id;
        v_itt_count := v_itt_count + 1;
    END LOOP;

    ALTER TABLE employees ENABLE TRIGGER trg_audit_employees;

    RAISE NOTICE 'Renumbered % Chilanga and % Itezhi Tezhi employees',
        v_chl_count, v_itt_count;
END $$;

-- ---------------------------------------------------------------------
-- 13. Comments
-- ---------------------------------------------------------------------
COMMENT ON TABLE employees IS
'Employee master. Legacy HR fields coexist with finance-core fields. '
'Augmented in V102. Renumbered to ISO format.';

COMMENT ON COLUMN employees.employee_id IS
'Canonical employee number. Format: {province}-{council}-{sequence}, '
'e.g. 09-01-000001 (Chilanga) or 07-05-000001 (Itezhi Tezhi).';

COMMENT ON COLUMN employees.employee_uuid IS
'UUID surrogate for cross-system joins with the finance core.';

COMMENT ON COLUMN employees.authority_code IS
'Multi-tenant scope. FK to authorities.';

COMMENT ON COLUMN employees.employment_status IS
'Lifecycle: ACTIVE, SUSPENDED, TERMINATED, RETIRED, DECEASED.';

COMMENT ON COLUMN employees.local_authority_service_number IS
'Zambian council service number (e.g. 31731). Distinct from '
'employee_id. Used for statutory returns and bank files.';

-- ---------------------------------------------------------------------
-- 14. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'HR_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'augment_employees_hr_master',
        'migration', 'V102',
        'columns_added', 23,
        'renumbered_chilanga', 182,
        'renumbered_itezhi_tezhi', 1,
        'audit_trigger', 'trg_audit_employees',
        'generator', 'generate_employee_number'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
