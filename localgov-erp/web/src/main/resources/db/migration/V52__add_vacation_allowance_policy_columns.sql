-- V52 -- Add Vacation Leave allowance policy columns and seed defaults.

ALTER TABLE leave_policy
    ADD COLUMN IF NOT EXISTS vacation_allowance_min_days INTEGER DEFAULT 30 NOT NULL,
    ADD COLUMN IF NOT EXISTS vacation_allowance_frequency_months INTEGER DEFAULT 24 NOT NULL;

UPDATE leave_policy
SET vacation_allowance_min_days         = 30,
    vacation_allowance_frequency_months = 24
WHERE LOWER(BTRIM(leave_type)) = 'vacation leave';
