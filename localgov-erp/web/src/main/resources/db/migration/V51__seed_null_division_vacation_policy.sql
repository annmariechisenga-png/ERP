-- V51 -- Insert a null-division Vacation Leave policy as a catch-all fallback.

INSERT INTO leave_policy (
    leave_type,
    division,
    accrual_rate,
    max_days,
    carry_forward,
    eligibility,
    fixed_days,
    max_accumulation,
    max_duration,
    advance_notice,
    gender_restriction,
    day_calculation_mode,
    monthly_limit,
    annual_limit,
    requires_birth_proof,
    requires_medical_cert,
    advance_notice_days,
    continuous_leave_limit
) SELECT
    'Vacation Leave',
    NULL,
    NULL,
    NULL,
    NULL,
    'All permanent employees -- fallback policy for employees without a division mapping.',
    NULL,
    160,
    NULL,
    30,
    'ALL',
    'WORKING',
    NULL,
    NULL,
    FALSE,
    FALSE,
    30,
    100
WHERE NOT EXISTS (
    SELECT 1 FROM leave_policy
    WHERE LOWER(BTRIM(leave_type)) = 'vacation leave'
      AND division IS NULL
);
