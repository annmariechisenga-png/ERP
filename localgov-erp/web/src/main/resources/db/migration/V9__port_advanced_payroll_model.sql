CREATE TABLE IF NOT EXISTS erp_salary_notch_value (
    id BIGSERIAL PRIMARY KEY,
    salary_scale VARCHAR(30) NOT NULL,
    notch_no INTEGER NOT NULL,
    annual_salary NUMERIC(18,2) NOT NULL,
    monthly_salary NUMERIC(18,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_erp_salary_notch_value UNIQUE (salary_scale, notch_no, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_erp_salary_notch_scale_effective
    ON erp_salary_notch_value(salary_scale, effective_from DESC);

CREATE TABLE IF NOT EXISTS erp_employee_salary_notch (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    salary_scale VARCHAR(30) NOT NULL,
    notch_no INTEGER NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_erp_employee_salary_notch_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_erp_employee_salary_notch UNIQUE (employee_id, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_erp_employee_salary_notch_active
    ON erp_employee_salary_notch(employee_id, is_active, effective_from DESC);

CREATE TABLE IF NOT EXISTS erp_allowance_type (
    id BIGSERIAL PRIMARY KEY,
    allowance_code VARCHAR(40) NOT NULL UNIQUE,
    allowance_name VARCHAR(120) NOT NULL,
    calculation_method VARCHAR(40) NOT NULL,
    default_rate NUMERIC(18,6),
    taxable BOOLEAN NOT NULL DEFAULT TRUE,
    pensionable BOOLEAN NOT NULL DEFAULT FALSE,
    source_document VARCHAR(255),
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS erp_employee_allowance (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    allowance_type_id BIGINT NOT NULL,
    allowance_rate NUMERIC(18,6),
    allowance_amount NUMERIC(18,2),
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_erp_employee_allowance_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_erp_employee_allowance_type
        FOREIGN KEY (allowance_type_id)
        REFERENCES erp_allowance_type(id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_erp_employee_allowance UNIQUE (employee_id, allowance_type_id, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_erp_employee_allowance_active
    ON erp_employee_allowance(employee_id, is_active, effective_from DESC);

CREATE TABLE IF NOT EXISTS erp_payroll_period (
    id BIGSERIAL PRIMARY KEY,
    period_code VARCHAR(20) NOT NULL UNIQUE,
    period_year INTEGER NOT NULL,
    period_month INTEGER NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    is_closed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_erp_payroll_period_month CHECK (period_month BETWEEN 1 AND 12)
);

CREATE TABLE IF NOT EXISTS erp_payroll_run (
    id BIGSERIAL PRIMARY KEY,
    run_code VARCHAR(30) NOT NULL UNIQUE,
    payroll_period_id BIGINT NOT NULL,
    run_status VARCHAR(20) NOT NULL,
    processed_by VARCHAR(120),
    processed_at TIMESTAMP,
    total_employees INTEGER NOT NULL DEFAULT 0,
    total_basic NUMERIC(18,2) NOT NULL DEFAULT 0,
    total_allowances NUMERIC(18,2) NOT NULL DEFAULT 0,
    total_gross NUMERIC(18,2) NOT NULL DEFAULT 0,
    total_deductions NUMERIC(18,2) NOT NULL DEFAULT 0,
    total_net NUMERIC(18,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_erp_payroll_run_period
        FOREIGN KEY (payroll_period_id)
        REFERENCES erp_payroll_period(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_erp_payroll_run_period
    ON erp_payroll_run(payroll_period_id, created_at DESC);

CREATE TABLE IF NOT EXISTS erp_payroll_run_item (
    id BIGSERIAL PRIMARY KEY,
    payroll_run_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    employee_name VARCHAR(180) NOT NULL,
    salary_scale VARCHAR(30),
    notch_no INTEGER,
    basic_salary NUMERIC(18,2) NOT NULL,
    allowances_total NUMERIC(18,2) NOT NULL DEFAULT 0,
    gross_pay NUMERIC(18,2) NOT NULL,
    paye_amount NUMERIC(18,2) NOT NULL DEFAULT 0,
    nhima_amount NUMERIC(18,2) NOT NULL DEFAULT 0,
    napsa_amount NUMERIC(18,2) NOT NULL DEFAULT 0,
    other_deductions NUMERIC(18,2) NOT NULL DEFAULT 0,
    total_deductions NUMERIC(18,2) NOT NULL,
    net_pay NUMERIC(18,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_erp_payroll_item_run
        FOREIGN KEY (payroll_run_id)
        REFERENCES erp_payroll_run(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_erp_payroll_item_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_erp_payroll_run_employee UNIQUE (payroll_run_id, employee_id)
);

CREATE INDEX IF NOT EXISTS idx_erp_payroll_run_item_employee
    ON erp_payroll_run_item(employee_id, created_at DESC);

CREATE TABLE IF NOT EXISTS erp_payroll_run_item_allowance (
    id BIGSERIAL PRIMARY KEY,
    payroll_run_item_id BIGINT NOT NULL,
    allowance_type_id BIGINT NOT NULL,
    allowance_name VARCHAR(120) NOT NULL,
    amount NUMERIC(18,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_erp_payroll_item_allowance_item
        FOREIGN KEY (payroll_run_item_id)
        REFERENCES erp_payroll_run_item(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_erp_payroll_item_allowance_type
        FOREIGN KEY (allowance_type_id)
        REFERENCES erp_allowance_type(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_erp_payroll_item_allowance_item
    ON erp_payroll_run_item_allowance(payroll_run_item_id);

CREATE TABLE IF NOT EXISTS erp_payroll_statutory_rate (
    id BIGSERIAL PRIMARY KEY,
    deduction_code VARCHAR(30) NOT NULL,
    deduction_name VARCHAR(120) NOT NULL,
    employee_rate NUMERIC(10,6) NOT NULL DEFAULT 0,
    employer_rate NUMERIC(10,6) NOT NULL DEFAULT 0,
    effective_from DATE NOT NULL,
    effective_to DATE,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_erp_payroll_stat_rate UNIQUE (deduction_code, effective_from)
);

INSERT INTO erp_payroll_statutory_rate (
    deduction_code,
    deduction_name,
    employee_rate,
    employer_rate,
    effective_from,
    notes
) VALUES
('PAYE', 'Pay As You Earn', 0.000000, 0.000000, DATE '2026-01-01', 'Placeholder: tax bands to be configured'),
('NHIMA', 'National Health Insurance', 0.010000, 0.010000, DATE '2026-01-01', 'Initial default rate'),
('NAPSA', 'National Pension Scheme Authority', 0.050000, 0.050000, DATE '2026-01-01', 'Initial default rate')
ON CONFLICT (deduction_code, effective_from) DO NOTHING;
