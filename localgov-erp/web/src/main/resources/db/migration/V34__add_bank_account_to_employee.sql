-- Payroll export requires bank account on employee profile

ALTER TABLE erp_employee
    ADD COLUMN IF NOT EXISTS bank_account VARCHAR(60);

CREATE INDEX IF NOT EXISTS idx_erp_employee_bank_account ON erp_employee (bank_account);
