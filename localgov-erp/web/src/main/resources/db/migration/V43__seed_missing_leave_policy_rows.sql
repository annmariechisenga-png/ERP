-- Step 1: Remove existing undivided / incorrectly-accrued rows for Annual and Vacation leave
-- so we can replace them with correct per-division rows.
DELETE FROM leave_policy
WHERE LOWER(BTRIM(leave_type)) IN ('annual leave', 'vacation leave')
  AND (
      division IS NULL
      OR LOWER(BTRIM(division)) NOT IN ('division i', 'division ii', 'division iii', 'division iv')
  );

-- Step 2: Insert per-division rows for Annual Leave, Vacation Leave, and the missing leave types.
-- The WHERE NOT EXISTS guard makes each row idempotent.
INSERT INTO leave_policy (leave_type, division, accrual_rate, max_days, carry_forward, eligibility, fixed_days, max_accumulation, max_duration, advance_notice)
SELECT * FROM (VALUES
    -- Annual Leave: accrual rate by division
    ('Annual Leave', 'Division I',   3.5, 42, 21, 'All permanent employees', NULL, 42, 42, 30),
    ('Annual Leave', 'Division II',  3.0, 42, 21, 'All permanent employees', NULL, 42, 42, 30),
    ('Annual Leave', 'Division III', 2.5, 42, 21, 'All permanent employees', NULL, 42, 42, 30),
    ('Annual Leave', 'Division IV',  2.0, 42, 21, 'All permanent employees', NULL, 42, 42, 30),
    -- Vacation Leave: accrual rate by division
    ('Vacation Leave', 'Division I',   3.5, 30, 15, 'All permanent employees', NULL, 30, 30, 30),
    ('Vacation Leave', 'Division II',  3.0, 30, 15, 'All permanent employees', NULL, 30, 30, 30),
    ('Vacation Leave', 'Division III', 2.5, 30, 15, 'All permanent employees', NULL, 30, 30, 30),
    ('Vacation Leave', 'Division IV',  2.0, 30, 15, 'All permanent employees', NULL, 30, 30, 30),
    -- Local Leave: accrual rate by division
    ('Local Leave', 'Division I',   3.5, 30, 0, 'All permanent employees', NULL, 30, 30, 0),
    ('Local Leave', 'Division II',  3.0, 30, 0, 'All permanent employees', NULL, 30, 30, 0),
    ('Local Leave', 'Division III', 2.5, 30, 0, 'All permanent employees', NULL, 30, 30, 0),
    ('Local Leave', 'Division IV',  2.0, 30, 0, 'All permanent employees', NULL, 30, 30, 0),
    -- Mother''s Day: fixed 1 day/month, uniform across divisions
    ('Mother''s Day', NULL, NULL, 12, 0, 'Female officers only — one working day per month', 1, 12, 1, 0),
    -- Sick Leave: uniform across divisions
    ('Sick Leave', NULL, NULL, 14, 0, 'All employees — medical certificate required > 3 days', NULL, 14, 14, 0),
    -- Unpaid Leave: uniform across divisions
    ('Unpaid Leave', NULL, NULL, 365, 0, 'All employees — subject to management approval; position not guaranteed after 1 year', 365, 365, 365, 30)
) AS new_rows (leave_type, division, accrual_rate, max_days, carry_forward, eligibility, fixed_days, max_accumulation, max_duration, advance_notice)
WHERE NOT EXISTS (
    SELECT 1 FROM leave_policy lp
    WHERE LOWER(BTRIM(lp.leave_type)) = LOWER(BTRIM(new_rows.leave_type))
      AND (
          (lp.division IS NULL AND new_rows.division IS NULL)
          OR LOWER(BTRIM(lp.division)) = LOWER(BTRIM(new_rows.division))
      )
);
