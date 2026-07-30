-- V53 -- Create the Vacation Leave allowance lifecycle table.
-- Phase 1 stores only ELIGIBLE / NOT_ELIGIBLE submission records.
-- Payment and approval statuses are reserved for future phases.

CREATE TABLE IF NOT EXISTS vacation_leave_allowance (
    id                      BIGSERIAL PRIMARY KEY,
    employee_id             BIGINT NOT NULL REFERENCES erp_employee(id),
    leave_request_id        BIGINT REFERENCES erp_leave_request(id),
    authority_code          VARCHAR(10),
    status                  VARCHAR(20) NOT NULL,
    payment_date            DATE,
    period_start_date       DATE,
    period_end_date         DATE,
    chargeable_working_days INTEGER,
    reason                  VARCHAR(255),
    created_by              VARCHAR(120),
    created_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    username                VARCHAR(80),
    authority_type          VARCHAR(50),
    role                    VARCHAR(200)
);

CREATE INDEX IF NOT EXISTS idx_vacation_leave_allowance_employee_created
    ON vacation_leave_allowance(employee_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_vacation_leave_allowance_employee_status
    ON vacation_leave_allowance(employee_id, status, created_at DESC);
