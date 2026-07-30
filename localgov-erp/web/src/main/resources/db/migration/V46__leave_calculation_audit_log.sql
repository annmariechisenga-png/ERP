-- V46 – Leave Calculation Audit Log
-- Required for government compliance and dispute resolution.

CREATE TABLE IF NOT EXISTS leave_calculation_audit_log (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    leave_request_id BIGINT,
    leave_type VARCHAR(100) NOT NULL,
    division VARCHAR(100),
    start_date DATE,
    requested_days INTEGER NOT NULL,
    adjusted_days INTEGER,
    forfeited_days INTEGER,
    reason VARCHAR(255),
    balance_before INTEGER,
    balance_after INTEGER,
    calculation_mode VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    triggered_by VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS idx_calc_audit_employee ON leave_calculation_audit_log (employee_id);
CREATE INDEX IF NOT EXISTS idx_calc_audit_leave_request ON leave_calculation_audit_log (leave_request_id);
CREATE INDEX IF NOT EXISTS idx_calc_audit_created_at ON leave_calculation_audit_log (created_at);
