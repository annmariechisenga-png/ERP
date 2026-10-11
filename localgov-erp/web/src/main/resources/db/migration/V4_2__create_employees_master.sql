-- =====================================================================
-- V4_2 — Create the base `employees` table
-- =====================================================================
-- The `employees` table was previously created out-of-band (manually)
-- on development databases, so later migrations (V20, V102, V112, V114,
-- V115) assumed it existed. On a fresh database Flyway reached V20 and
-- failed with "relation employees does not exist".
--
-- This migration creates the base shape with the columns that V20 and
-- the pre-V102 chain expect. Later migrations (V102+) use
-- ADD COLUMN IF NOT EXISTS and will add their columns on top.
--
-- ARCHITECTURAL NOTES:
--   * `division` is NOT stored — it is derived from `salary_scale`
--     (I: LGSS/01–LGSS/07, II: LGSS/08–LGSS/12, III: LGSS/13–LGSS/18,
--      IV: G1–G3). The Employee entity computes it; no column required.
--     Migration V30 adds a historical `division` column which is unused
--     by the entity — a future cleanup migration may drop it.
--   * `supervisor_id` is PROVISIONAL. Final ownership of the supervisor
--     relationship belongs to org structure (WSL). It is kept here as a
--     local projection so HR Core can answer leave/appraisal/overtime
--     queries without a cross-system dependency. To be reconciled at
--     merge time: one source of truth, or a cached column with a sync
--     trigger.
--
-- CREATE TABLE IF NOT EXISTS keeps existing databases unaffected.
-- =====================================================================

CREATE TABLE IF NOT EXISTS employees (
    employee_id                     TEXT PRIMARY KEY,
    name                            TEXT,
    province                        TEXT,
    district                        TEXT,
    nrc_number                      TEXT,
    sex                             TEXT,
    date_of_birth                   DATE,
    position                        TEXT,
    salary_scale                    TEXT,
    local_authority_service_number  TEXT,
    date_of_first_appointment       DATE,
    date_confirmed                  DATE,
    date_substantive_appointment    DATE,
    date_reported                   DATE,
    academic_qualifications         TEXT,
    professional_qualifications     TEXT,
    acting_position                 TEXT,
    acting_date                     DATE,
    department                      TEXT,
    phone_number                    TEXT,
    carried_forward_leave           TEXT,
    days_availed                    TEXT,
    leave_taken                     TEXT,
    leave_commuted                  TEXT,
    leave_transferred_out           TEXT,
    leave_balance                   TEXT,
    is_active                       BOOLEAN DEFAULT TRUE,
    hire_date                       DATE,
    email                           TEXT,
    supervisor_id                   TEXT,
    notification_preference         TEXT DEFAULT 'Both'
);

CREATE INDEX IF NOT EXISTS idx_employees_employee_id   ON employees(employee_id);
CREATE INDEX IF NOT EXISTS idx_employees_email         ON employees(email) WHERE email IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_employees_supervisor_id ON employees(supervisor_id) WHERE supervisor_id IS NOT NULL;
