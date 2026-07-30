-- Bridge migration for databases that were Flyway-baselined at version 1.
-- Such databases skip V1__init_erp_phase2_tables.sql, so create the core ERP tables
-- here before V5+ migrations that depend on erp_employee.

CREATE TABLE IF NOT EXISTS erp_employee (
    id BIGSERIAL PRIMARY KEY,
    employee_code VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    department VARCHAR(120) NOT NULL,
    position_title VARCHAR(120) NOT NULL,
    base_salary NUMERIC(18,2) NOT NULL,
    hire_date DATE NOT NULL,
    role VARCHAR(40) NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS erp_leave_request (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    leave_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason VARCHAR(500) NOT NULL,
    days_requested INTEGER NOT NULL,
    approved_by VARCHAR(100),
    approved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_erp_leave_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS erp_payroll_record (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    pay_period DATE NOT NULL,
    base_salary NUMERIC(18,2) NOT NULL,
    overtime_hours NUMERIC(10,2) NOT NULL,
    overtime_rate NUMERIC(18,2) NOT NULL,
    deductions NUMERIC(18,2) NOT NULL,
    net_pay NUMERIC(18,2) NOT NULL,
    generated_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_erp_payroll_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_erp_leave_employee_created
    ON erp_leave_request(employee_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_erp_leave_status_created
    ON erp_leave_request(status, created_at ASC);

CREATE INDEX IF NOT EXISTS idx_erp_payroll_employee_period
    ON erp_payroll_record(employee_id, pay_period DESC);
