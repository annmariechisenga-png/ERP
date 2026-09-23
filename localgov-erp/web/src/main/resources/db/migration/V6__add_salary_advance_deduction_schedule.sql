ALTER TABLE salary_advance_request
    ADD COLUMN IF NOT EXISTS requested_installments INTEGER NOT NULL DEFAULT 1;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_salary_advance_requested_installments'
    ) THEN
        ALTER TABLE salary_advance_request
            ADD CONSTRAINT chk_salary_advance_requested_installments
            CHECK (requested_installments > 0);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS salary_advance_deduction (
    id BIGSERIAL PRIMARY KEY,
    salary_advance_request_id BIGINT NOT NULL,
    employee_id BIGINT NOT NULL,
    installment_no INTEGER NOT NULL,
    total_installments INTEGER NOT NULL,
    scheduled_pay_period DATE NOT NULL,
    deduction_amount NUMERIC(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    payroll_record_id BIGINT,
    applied_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_salary_advance_deduction_request
        FOREIGN KEY (salary_advance_request_id)
        REFERENCES salary_advance_request(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_salary_advance_deduction_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_salary_advance_deduction_payroll_record
        FOREIGN KEY (payroll_record_id)
        REFERENCES erp_payroll_record(id)
        ON DELETE SET NULL,
    CONSTRAINT chk_salary_advance_deduction_installment_no
        CHECK (installment_no > 0),
    CONSTRAINT chk_salary_advance_deduction_total_installments
        CHECK (total_installments > 0),
    CONSTRAINT chk_salary_advance_deduction_amount
        CHECK (deduction_amount > 0),
    CONSTRAINT chk_salary_advance_deduction_status
        CHECK (status IN ('PENDING', 'APPLIED')),
    CONSTRAINT uq_salary_advance_deduction_installment
        UNIQUE (salary_advance_request_id, installment_no)
);

CREATE INDEX IF NOT EXISTS idx_salary_advance_deduction_employee_status_period
    ON salary_advance_deduction(employee_id, status, scheduled_pay_period ASC);

CREATE INDEX IF NOT EXISTS idx_salary_advance_deduction_request
    ON salary_advance_deduction(salary_advance_request_id);