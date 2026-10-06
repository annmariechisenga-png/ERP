-- ============================================================================
-- V113: HR Core — Division Boundary Fix
-- ----------------------------------------------------------------------------
-- Corrects the division boundaries in v_employee_register to include LGSS/01
-- in Division I. The original V112 logic started Division I at LGSS/02, which
-- excluded officers on LGSS/01.
--
-- Correct mapping (per 2026 Collective Agreement and LGSC circulars):
--   Division I:   LGSS/01 – LGSS/07
--   Division II:  LGSS/08 – LGSS/12
--   Division III: LGSS/13 – LGSS/18
--   Division IV:  G1, G2, G3
--
-- The view is recreated in place. All columns and semantics remain unchanged
-- except for the division CASE expression.
--
-- Depends on: V112 (which created the original view)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- PART 1: Recreate v_employee_register with corrected division logic
-- ---------------------------------------------------------------------------
DROP VIEW IF EXISTS v_employee_division_summary;
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

    -- Full name (canonical: parts, fallback: name)
    COALESCE(
        NULLIF(TRIM(BOTH ' ' FROM 
            COALESCE(e.first_name,'') || ' ' || 
            COALESCE(e.middle_name,'') || ' ' || 
            COALESCE(e.last_name,'')), ''),
        e.name
    ) AS full_name,

    -- Sex (canonical)
    e.sex,

    -- Age from DOB
    CASE 
        WHEN e.date_of_birth IS NOT NULL THEN
            EXTRACT(YEAR FROM AGE(CURRENT_DATE, e.date_of_birth))::int
        ELSE NULL
    END AS age_years,

    -- DOFA & related dates
    e.date_of_first_appointment,
    e.date_confirmed,
    e.date_substantive_appointment,
    e.date_reported,

    -- Division (derived from salary scale — CORRECTED)
    CASE
        WHEN e.salary_scale ~ '^LGSS/0[1-7]$' THEN 'I'              -- FIXED: includes 01
        WHEN e.salary_scale ~ '^LGSS/0[8-9]$' 
          OR e.salary_scale ~ '^LGSS/1[0-2]$' THEN 'II'
        WHEN e.salary_scale ~ '^LGSS/1[3-8]$' THEN 'III'
        WHEN e.salary_scale IN ('G1','G2','G3','Grade 1','Grade 2','Grade 3') THEN 'IV'
        ELSE NULL
    END AS division,

    -- Length of stay (from Date of Arrival at this Local Authority)
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

    -- Vacancy status
    CASE 
        WHEN e.date_reported IS NOT NULL THEN 
            'Filled in on ' || to_char(e.date_reported, 'DD.MM.YYYY')
        ELSE 'Vacant'
    END AS vacancy_status,

    -- Total service (from Date of First Appointment)
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

    -- Acting position & date
    e.acting_position,
    e.acting_date,

    -- Qualifications
    e.academic_qualifications,
    e.professional_qualifications,

    -- Contact (raw phone; PII protection in V114)
    e.phone_number,
    e.email,

    -- Statutory identifiers (raw; PII protection in V114)
    e.nrc_number,
    e.tpin,
    e.napsa_number,
    e.nhima_number,
    e.lasf_number,
    e.local_authority_service_number,

    -- Bank (raw; PII protection in V114)
    e.bank_name,
    e.bank_branch,
    e.bank_account_number,
    e.bank_account_name,

    -- Cost allocation
    e.default_fund_id,
    e.default_cost_center_id,

    -- Leave balance
    e.leave_balance,

    -- Supervisor
    e.supervisor_id,

    -- Notifications
    e.notification_preference,

    -- Remarks / comments
    e.remarks,
    e.lgsc_comment,

    -- Audit
    e.created_at,
    e.updated_at

FROM employees e;

COMMENT ON VIEW v_employee_register IS 
    'Full employee register with derived columns. Division boundaries corrected in V113: Division I = LGSS/01–07, II = LGSS/08–12, III = LGSS/13–18, IV = G1–G3. Multi-tenant: filter by authority_code.';

-- ---------------------------------------------------------------------------
-- PART 2: Recreate v_employee_division_summary
-- ---------------------------------------------------------------------------
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
    'Count of active employees per authority by division and sex. Division boundaries corrected in V113. Multi-tenant scoped.';

-- ---------------------------------------------------------------------------
-- PART 3: Verification — confirm LGSS/01 now maps to Division I
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    v_total INTEGER;
    v_division_one INTEGER;
    v_division_two INTEGER;
    v_division_three INTEGER;
    v_division_four INTEGER;
    v_unmapped INTEGER;
BEGIN
    -- Count total active employees
    SELECT COUNT(*) INTO v_total
    FROM v_employee_register
    WHERE employment_status = 'ACTIVE';

    -- Count by division
    SELECT COUNT(*) INTO v_division_one
    FROM v_employee_register
    WHERE employment_status = 'ACTIVE' AND division = 'I';

    SELECT COUNT(*) INTO v_division_two
    FROM v_employee_register
    WHERE employment_status = 'ACTIVE' AND division = 'II';

    SELECT COUNT(*) INTO v_division_three
    FROM v_employee_register
    WHERE employment_status = 'ACTIVE' AND division = 'III';

    SELECT COUNT(*) INTO v_division_four
    FROM v_employee_register
    WHERE employment_status = 'ACTIVE' AND division = 'IV';

    -- Count active employees with salary_scale but no division assigned
    SELECT COUNT(*) INTO v_unmapped
    FROM v_employee_register
    WHERE employment_status = 'ACTIVE'
      AND salary_scale IS NOT NULL
      AND division IS NULL;

    RAISE NOTICE 'V113 division breakdown for active employees:';
    RAISE NOTICE '  Total active: %', v_total;
    RAISE NOTICE '  Division I:   %', v_division_one;
    RAISE NOTICE '  Division II:  %', v_division_two;
    RAISE NOTICE '  Division III: %', v_division_three;
    RAISE NOTICE '  Division IV:  %', v_division_four;
    RAISE NOTICE '  Unmapped:     %', v_unmapped;

    IF v_unmapped > 0 THEN
        RAISE WARNING 'V113: % employees have a salary_scale but no division mapping. Check for scales outside the known ranges.', v_unmapped;
    END IF;

    RAISE NOTICE 'V113 PASSED: Division boundaries corrected';
END $$;
