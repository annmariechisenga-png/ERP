DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_salary_advance_requested_installments_max_6'
    ) THEN
        ALTER TABLE salary_advance_request
            ADD CONSTRAINT chk_salary_advance_requested_installments_max_6
            CHECK (requested_installments <= 6);
    END IF;
END $$;

ALTER TABLE salary_advance_request
    ADD COLUMN IF NOT EXISTS disbursed_by_title VARCHAR(40);

UPDATE salary_advance_request
SET disbursed_by_title = 'DIRECTOR_OF_FINANCE'
WHERE disbursed_at IS NOT NULL
  AND disbursed_by_title IS NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_salary_advance_disbursed_by_title'
    ) THEN
        ALTER TABLE salary_advance_request
            ADD CONSTRAINT chk_salary_advance_disbursed_by_title
            CHECK (
                disbursed_by_title IS NULL
                OR disbursed_by_title IN ('DIRECTOR_OF_FINANCE')
            );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_salary_advance_disburser_title_required'
    ) THEN
        ALTER TABLE salary_advance_request
            ADD CONSTRAINT chk_salary_advance_disburser_title_required
            CHECK (
                disbursed_at IS NULL
                OR disbursed_by_title = 'DIRECTOR_OF_FINANCE'
            );
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS ux_salary_advance_one_active_request_per_employee
    ON salary_advance_request(employee_id)
    WHERE status IN (
        'SUBMITTED',
        'PENDING_HEAD_APPROVAL',
        'PENDING_FINANCE_APPROVAL',
        'APPROVED_FOR_DISBURSEMENT',
        'DISBURSED'
    );
