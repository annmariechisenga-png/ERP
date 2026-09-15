-- Expand division to hold canonical division labels.
ALTER TABLE erp_employee ALTER COLUMN division TYPE VARCHAR(30);

-- V49 -- Seed employee salary_scale and derive division
-- Required so PolicyResolver can derive division from salary_scale for demo users.

UPDATE erp_employee
SET salary_scale = 'LGSS01',
    division     = 'Division I'
WHERE employee_code = 'EMP-ADMIN' AND (salary_scale IS NULL OR salary_scale = '');

UPDATE erp_employee
SET salary_scale = 'LGSS02',
    division     = 'Division I'
WHERE employee_code = 'EMP-HR-001' AND (salary_scale IS NULL OR salary_scale = '');

UPDATE erp_employee
SET salary_scale = 'LGSS08',
    division     = 'Division II'
WHERE employee_code = 'EMP-PAY-001' AND (salary_scale IS NULL OR salary_scale = '');

UPDATE erp_employee
SET salary_scale = 'LGSS01',
    division     = 'Division I'
WHERE employee_code = 'EMP-HOI-001' AND (salary_scale IS NULL OR salary_scale = '');

UPDATE erp_employee
SET salary_scale = 'LGSS09',
    division     = 'Division II'
WHERE employee_code = 'EMP-FIN-001' AND (salary_scale IS NULL OR salary_scale = '');

UPDATE erp_employee
SET salary_scale = 'GRADE_01',
    division     = 'Division IV'
WHERE employee_code = 'EMP-ESS-001' AND (salary_scale IS NULL OR salary_scale = '');

-- Derive canonical employee division for any remaining employees
-- with a salary_scale but no valid division.
UPDATE erp_employee e
SET division = CASE sso.division
    WHEN 'DIVISION_I'   THEN 'Division I'
    WHEN 'DIVISION_II'  THEN 'Division II'
    WHEN 'DIVISION_III' THEN 'Division III'
    WHEN 'DIVISION_IV'  THEN 'Division IV'
END
FROM (
    SELECT DISTINCT ON (salary_scale)
        salary_scale,
        division
    FROM salary_scales_official
    WHERE is_active = TRUE
      AND CURRENT_DATE BETWEEN effective_from
                           AND COALESCE(effective_to, CURRENT_DATE)
    ORDER BY salary_scale, effective_from DESC
) sso
WHERE (e.division IS NULL OR e.division = '' OR e.division = 'N/A')
  AND e.salary_scale IS NOT NULL
  AND e.salary_scale <> ''
  AND sso.salary_scale = e.salary_scale
  AND sso.division IN (
      'DIVISION_I',
      'DIVISION_II',
      'DIVISION_III',
      'DIVISION_IV'
  );
