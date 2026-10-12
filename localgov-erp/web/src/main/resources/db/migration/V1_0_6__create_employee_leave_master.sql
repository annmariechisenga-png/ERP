-- V1_0_6 — Create employee_leave_master
-- Table referenced by EmployeeLeaveMaster entity but never created by
-- any migration. Provides the opening leave balance and 30-year-taken
-- counter per employee.

CREATE TABLE IF NOT EXISTS employee_leave_master (
    employee_id              VARCHAR(50) PRIMARY KEY,
    opening_balance          NUMERIC(10,2) DEFAULT 0,
    total_taken_thirty_year  NUMERIC(10,2) DEFAULT 0,
    is_active                BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_employee_leave_master_active
    ON employee_leave_master(employee_id)
    WHERE is_active = TRUE;
