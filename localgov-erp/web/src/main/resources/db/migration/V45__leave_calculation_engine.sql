-- V45 – Leave Calculation Engine schema changes

ALTER TABLE leave_policy ADD COLUMN IF NOT EXISTS continuous_leave_limit INTEGER;

UPDATE leave_policy SET continuous_leave_limit = 120
WHERE LOWER(BTRIM(division)) IN ('division i', 'i') AND LOWER(BTRIM(leave_type)) = 'vacation leave';

UPDATE leave_policy SET continuous_leave_limit = 110
WHERE LOWER(BTRIM(division)) IN ('division ii', 'ii') AND LOWER(BTRIM(leave_type)) = 'vacation leave';

UPDATE leave_policy SET continuous_leave_limit = 100
WHERE LOWER(BTRIM(division)) IN ('division iii', 'iii', 'division iv', 'iv') AND LOWER(BTRIM(leave_type)) = 'vacation leave';

UPDATE leave_policy SET max_accumulation = 230
WHERE LOWER(BTRIM(division)) IN ('division i', 'i') AND LOWER(BTRIM(leave_type)) = 'vacation leave';

UPDATE leave_policy SET max_accumulation = 205
WHERE LOWER(BTRIM(division)) IN ('division ii', 'ii') AND LOWER(BTRIM(leave_type)) = 'vacation leave';

UPDATE leave_policy SET max_accumulation = 160
WHERE LOWER(BTRIM(division)) IN ('division iii', 'iii', 'division iv', 'iv') AND LOWER(BTRIM(leave_type)) = 'vacation leave';

ALTER TABLE erp_leave_request ADD COLUMN IF NOT EXISTS resumption_date DATE;
