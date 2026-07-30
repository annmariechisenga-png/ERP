-- ============================================================
-- V44 – Leave Policy Engine Consolidation
-- Makes PostgreSQL the single source of truth for all leave
-- policies in line with the Local Government Service Commission
-- Conditions of Service.
-- ============================================================

-- ── 0. Add surrogate PK so JPA can map the entity ───────────
ALTER TABLE leave_policy
    ADD COLUMN IF NOT EXISTS id BIGSERIAL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'leave_policy_pkey'
          AND conrelid = 'leave_policy'::regclass
    ) THEN
        ALTER TABLE leave_policy ADD PRIMARY KEY (id);
    END IF;
END$$;

-- ── 1. Extend leave_policy with new semantic columns ────────
ALTER TABLE leave_policy
    ADD COLUMN IF NOT EXISTS gender_restriction              TEXT    DEFAULT 'ALL',
    ADD COLUMN IF NOT EXISTS day_calculation_mode            TEXT    DEFAULT 'WORKING',
    ADD COLUMN IF NOT EXISTS monthly_limit                   INTEGER,
    ADD COLUMN IF NOT EXISTS annual_limit                    INTEGER,
    ADD COLUMN IF NOT EXISTS sick_full_pay_months            INTEGER,
    ADD COLUMN IF NOT EXISTS sick_half_pay_months            INTEGER,
    ADD COLUMN IF NOT EXISTS sick_full_pay_days_contract     INTEGER,
    ADD COLUMN IF NOT EXISTS sick_half_pay_days_contract     INTEGER,
    ADD COLUMN IF NOT EXISTS requires_birth_proof            BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS requires_medical_cert           BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS advance_notice_days             INTEGER DEFAULT 0;

-- ── 2. Remove Annual Leave rows ──────────────────────────────
DELETE FROM leave_policy
WHERE LOWER(BTRIM(leave_type)) = 'annual leave';

-- ── 3. Correct Vacation Leave per-division accumulation ──────
DELETE FROM leave_policy
WHERE LOWER(BTRIM(leave_type)) = 'vacation leave';

INSERT INTO leave_policy
    (leave_type, division, accrual_rate, max_days, carry_forward, eligibility,
     fixed_days, max_accumulation, max_duration, advance_notice,
     gender_restriction, day_calculation_mode,
     monthly_limit, annual_limit,
     requires_birth_proof, requires_medical_cert, advance_notice_days)
VALUES
    ('Vacation Leave','Division I',   3.5, NULL, NULL, 'All permanent employees',
     NULL, 230, NULL, 30, 'ALL', 'WORKING', NULL, NULL, FALSE, FALSE, 30),
    ('Vacation Leave','Division II',  3.0, NULL, NULL, 'All permanent employees',
     NULL, 205, NULL, 30, 'ALL', 'WORKING', NULL, NULL, FALSE, FALSE, 30),
    ('Vacation Leave','Division III', 2.5, NULL, NULL, 'All permanent employees',
     NULL, 160, NULL, 30, 'ALL', 'WORKING', NULL, NULL, FALSE, FALSE, 30),
    ('Vacation Leave','Division IV',  2.0, NULL, NULL, 'All permanent employees',
     NULL, 160, NULL, 30, 'ALL', 'WORKING', NULL, NULL, FALSE, FALSE, 30);

-- ── 4. Update Local Leave ────────────────────────────────────
UPDATE leave_policy
SET  day_calculation_mode = 'WORKING',
     gender_restriction   = 'ALL',
     advance_notice_days  = 0
WHERE LOWER(BTRIM(leave_type)) = 'local leave';

-- ── 5. Update Maternity Leave ────────────────────────────────
UPDATE leave_policy
SET  day_calculation_mode = 'CALENDAR',
     gender_restriction   = 'FEMALE',
     requires_birth_proof = TRUE,
     fixed_days           = 98,
     max_duration         = 98
WHERE LOWER(BTRIM(leave_type)) = 'maternity leave';

-- ── 6. Update Paternity Leave ────────────────────────────────
UPDATE leave_policy
SET  day_calculation_mode = 'CALENDAR',
     gender_restriction   = 'MALE',
     requires_birth_proof = TRUE,
     fixed_days           = 10,
     max_duration         = 10
WHERE LOWER(BTRIM(leave_type)) = 'paternity leave';

-- ── 7. Update Compassionate Leave ───────────────────────────
--   max_duration = SPOUSE limit (21), fixed_days = CHILD/PARENT limit (14)
UPDATE leave_policy
SET  day_calculation_mode = 'WORKING',
     gender_restriction   = 'ALL',
     max_duration         = 21,
     fixed_days           = 14
WHERE LOWER(BTRIM(leave_type)) = 'compassionate leave';

-- ── 8. Update Mother's Day Leave ─────────────────────────────
UPDATE leave_policy
SET  day_calculation_mode = 'WORKING',
     gender_restriction   = 'FEMALE',
     monthly_limit        = 1,
     annual_limit         = 12,
     fixed_days           = 1,
     max_accumulation     = 12,
     max_duration         = 1,
     carry_forward        = 0,
     advance_notice_days  = 0
WHERE LOWER(BTRIM(leave_type)) IN ('mother''s day', 'mothers day');

-- ── 9. Replace Sick Leave with Conditions of Service values ──
DELETE FROM leave_policy
WHERE LOWER(BTRIM(leave_type)) = 'sick leave';

INSERT INTO leave_policy
    (leave_type, division, accrual_rate, max_days, carry_forward, eligibility,
     fixed_days, max_accumulation, max_duration, advance_notice,
     gender_restriction, day_calculation_mode,
     sick_full_pay_months, sick_half_pay_months,
     sick_full_pay_days_contract, sick_half_pay_days_contract,
     requires_medical_cert, advance_notice_days)
VALUES
    ('Sick Leave', NULL, NULL, NULL, 0,
     'Full pay first 3 months (26 days contract); half pay next 3 months (26 days contract). Discharge on medical grounds after 6 months.',
     NULL, NULL, NULL, 0,
     'ALL', 'CALENDAR',
     3, 3,
     26, 26,
     TRUE, 0);

-- ── 10. Update Unpaid Leave ───────────────────────────────────
UPDATE leave_policy
SET  day_calculation_mode = 'WORKING',
     gender_restriction   = 'ALL',
     advance_notice_days  = 30
WHERE LOWER(BTRIM(leave_type)) = 'unpaid leave';

-- ── 11. Insert Family Care Leave ─────────────────────────────
INSERT INTO leave_policy
    (leave_type, division, accrual_rate, max_days, carry_forward, eligibility,
     fixed_days, max_accumulation, max_duration, advance_notice,
     gender_restriction, day_calculation_mode,
     annual_limit, advance_notice_days)
SELECT 'Family Care Leave', NULL, NULL, NULL, 0,
       'All employees – fixed 3 paid working days per calendar year. Does not accumulate.',
       NULL, NULL, 3, 0,
       'ALL', 'WORKING',
       3, 0
WHERE NOT EXISTS (
    SELECT 1 FROM leave_policy
    WHERE LOWER(BTRIM(leave_type)) = 'family care leave'
);

-- ── 12. Insert Study Leave ────────────────────────────────────
INSERT INTO leave_policy
    (leave_type, division, accrual_rate, max_days, carry_forward, eligibility,
     fixed_days, max_accumulation, max_duration, advance_notice,
     gender_restriction, day_calculation_mode, advance_notice_days)
SELECT 'Study Leave', NULL, NULL, NULL, 0,
       'All employees – subject to management approval and relevance to duties.',
       NULL, NULL, NULL, 30,
       'ALL', 'CALENDAR',
       30
WHERE NOT EXISTS (
    SELECT 1 FROM leave_policy
    WHERE LOWER(BTRIM(leave_type)) = 'study leave'
);

-- ── 13. Back-fill any remaining NULL metadata columns ─────────
UPDATE leave_policy
SET  gender_restriction   = COALESCE(gender_restriction,   'ALL'),
     day_calculation_mode = COALESCE(day_calculation_mode, 'WORKING'),
     requires_birth_proof  = COALESCE(requires_birth_proof,  FALSE),
     requires_medical_cert = COALESCE(requires_medical_cert, FALSE),
     advance_notice_days   = COALESCE(advance_notice_days,   0);
