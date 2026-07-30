-- V50 -- Enforce data integrity on leave_policy and remove any residual Annual Leave rows.

UPDATE leave_policy
SET gender_restriction      = COALESCE(gender_restriction, 'ALL'),
    day_calculation_mode    = COALESCE(day_calculation_mode, 'WORKING'),
    requires_birth_proof    = COALESCE(requires_birth_proof, FALSE),
    requires_medical_cert   = COALESCE(requires_medical_cert, FALSE),
    advance_notice_days     = COALESCE(advance_notice_days, 0);

DELETE FROM leave_policy
WHERE LOWER(BTRIM(leave_type)) = 'annual leave';

ALTER TABLE leave_policy
    ALTER COLUMN leave_type          SET NOT NULL,
    ALTER COLUMN gender_restriction   SET NOT NULL,
    ALTER COLUMN day_calculation_mode SET NOT NULL,
    ALTER COLUMN advance_notice_days  SET NOT NULL;

ALTER TABLE leave_policy
    ADD CONSTRAINT chk_leave_policy_leave_type
        CHECK (BTRIM(leave_type) <> ''),
    ADD CONSTRAINT chk_leave_policy_gender_restriction
        CHECK (gender_restriction IN ('ALL', 'FEMALE', 'MALE')),
    ADD CONSTRAINT chk_leave_policy_day_calculation_mode
        CHECK (day_calculation_mode IN ('WORKING', 'CALENDAR'));
