-- V55 -- Align erp_employee.division with canonical Division I-IV labels

-- 1. Remove any previous division constraint
ALTER TABLE erp_employee
    DROP CONSTRAINT IF EXISTS chk_employee_division;

-- 2. Ensure the column can store canonical labels
ALTER TABLE erp_employee
    ALTER COLUMN division TYPE VARCHAR(30);

-- 3. Enforce canonical division values
ALTER TABLE erp_employee
    ADD CONSTRAINT chk_employee_division
    CHECK (
        division IN (
            'Division I',
            'Division II',
            'Division III',
            'Division IV'
        )
    );
