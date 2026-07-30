CREATE TABLE IF NOT EXISTS leave_balances (
    employee_id BIGINT PRIMARY KEY,
    local_leave_balance INTEGER DEFAULT 0,
    vacation_leave_balance INTEGER DEFAULT 0
);

ALTER TABLE erp_leave_request
    ADD COLUMN IF NOT EXISTS compassionate_relation VARCHAR(20);