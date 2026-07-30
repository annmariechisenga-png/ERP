ALTER TABLE work_locations
    ADD COLUMN IF NOT EXISTS authority_code VARCHAR(10);

UPDATE work_locations
SET authority_code = 'ALL'
WHERE authority_code IS NULL OR TRIM(authority_code) = '';

ALTER TABLE work_locations
    ALTER COLUMN authority_code SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_work_locations_authority_code
    ON work_locations (authority_code);

ALTER TABLE employee_work_locations
    ADD COLUMN IF NOT EXISTS authority_code VARCHAR(10);

UPDATE employee_work_locations ewl
SET authority_code = COALESCE(wl.authority_code, 'ALL')
FROM work_locations wl
WHERE wl.id = ewl.location_id
  AND (ewl.authority_code IS NULL OR TRIM(ewl.authority_code) = '');

UPDATE employee_work_locations
SET authority_code = 'ALL'
WHERE authority_code IS NULL OR TRIM(authority_code) = '';

ALTER TABLE employee_work_locations
    ALTER COLUMN authority_code SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_employee_work_locations_authority_code
    ON employee_work_locations (authority_code);

CREATE INDEX IF NOT EXISTS idx_employee_work_locations_emp_auth_from_to
    ON employee_work_locations (employee_id, authority_code, effective_from, effective_to);
