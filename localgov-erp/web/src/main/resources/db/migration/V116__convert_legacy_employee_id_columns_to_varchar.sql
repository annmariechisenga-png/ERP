-- =====================================================================
-- V116 — Convert legacy BIGINT employee-scoped columns to VARCHAR
-- =====================================================================
-- Several tables created by V22–V60 kept employee_id (and related columns)
-- as BIGINT, but the current JPA entities expect String. This migration
-- converts them so Hibernate's `ddl-auto=validate` passes on fresh DBs.
--
-- V115 dropped the erp_employee table and its FKs, so no FK conflicts here.
-- Columns are converted with USING <col>::text, preserving numeric values
-- as decimal strings (the current schema convention).
-- =====================================================================

-- =====================================================================
-- Drop FKs on columns we're about to convert, then convert overtime_team.id
-- =====================================================================
ALTER TABLE overtime_sessions DROP CONSTRAINT IF EXISTS fk_ot_session_team;

-- overtime_team.id: entity expects String
ALTER TABLE overtime_team ALTER COLUMN id TYPE VARCHAR(50) USING id::text;

-- employee_id columns
ALTER TABLE commuted_overtime            ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE employee_work_locations      ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE erp_user_account             ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE leave_balances               ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE leave_calculation_audit_log  ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE overtime_sessions            ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;
ALTER TABLE vacation_leave_allowance     ALTER COLUMN employee_id TYPE VARCHAR(50) USING employee_id::text;

-- other employee-scoped columns
ALTER TABLE overtime_sessions ALTER COLUMN supervisor_id TYPE VARCHAR(50) USING supervisor_id::text;
ALTER TABLE overtime_sessions ALTER COLUMN team_id       TYPE VARCHAR(50) USING team_id::text;
ALTER TABLE overtime_team     ALTER COLUMN hod_id        TYPE VARCHAR(50) USING hod_id::text;

-- Re-add the FK between overtime_sessions.team_id and overtime_team.id
ALTER TABLE overtime_sessions
    ADD CONSTRAINT fk_ot_session_team
    FOREIGN KEY (team_id) REFERENCES overtime_team(id);
