-- =====================================================================
-- V1_0_5 — Create salary_advances
-- =====================================================================
-- The salary_advances table was created out-of-band on dev databases
-- (manually) but no migration ever created it. V112 references it in
-- the view vw_active_salary_advances.
--
-- This table holds issued salary advances (one row per advance), with
-- the repayment schedule and status. It complements salary_advance_request
-- (the workflow table created by V5), matching the manual's distinction
-- between the application (request) and the issued advance.
--
-- Schema mirrors the live table on localgov_erp. council_id kept as
-- INTEGER for compatibility; will be reconciled to authority_code at
-- the org-structure merge.
--
-- CREATE TABLE IF NOT EXISTS keeps existing databases unaffected.
-- =====================================================================

CREATE TABLE IF NOT EXISTS salary_advances (
    advance_id                     SERIAL PRIMARY KEY,
    employee_id                    TEXT           NOT NULL,
    amount_requested               NUMERIC(10,2)  NOT NULL,
    amount_approved                NUMERIC(10,2),
    monthly_salary_at_time         NUMERIC(10,2)  NOT NULL,
    repayment_months               INTEGER        NOT NULL,
    monthly_deduction              NUMERIC(10,2),
    total_repaid                   NUMERIC(10,2)  DEFAULT 0,
    remaining_balance              NUMERIC(10,2),
    application_date               DATE           NOT NULL DEFAULT CURRENT_DATE,
    deduction_start_month          DATE,
    deduction_end_month            DATE,
    status                         TEXT           DEFAULT 'pending',
    rejection_reason               TEXT,
    approved_by                    TEXT,
    approved_by_name               TEXT,
    approved_at                    TIMESTAMP,
    approver_notes                 TEXT,
    payroll_integrated             BOOLEAN        DEFAULT FALSE,
    payroll_integrated_at          TIMESTAMP,
    payroll_run_id                 INTEGER,
    last_payroll_deduction_amount  NUMERIC(10,2),
    last_payroll_deduction_month   DATE,
    reference_number               TEXT           NOT NULL,
    council_id                     INTEGER,
    created_by                     TEXT,
    created_at                     TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    updated_at                     TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    reason                         TEXT,
    CONSTRAINT salary_advances_reference_number_key UNIQUE (reference_number)
);

CREATE INDEX IF NOT EXISTS idx_salary_advances_employee
    ON salary_advances(employee_id);

CREATE INDEX IF NOT EXISTS idx_salary_advances_reference
    ON salary_advances(reference_number);

CREATE INDEX IF NOT EXISTS idx_salary_advances_status
    ON salary_advances(status);

CREATE INDEX IF NOT EXISTS idx_salary_advances_active
    ON salary_advances(employee_id, status)
    WHERE status IN ('approved', 'active');

COMMENT ON TABLE salary_advances IS
'Issued salary advances with repayment schedule. Complements
salary_advance_request (workflow). Values: status in
pending|approved|rejected|active|completed|cancelled.';
