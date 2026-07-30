ALTER TABLE salary_advance_request
    ADD COLUMN IF NOT EXISTS authority_ref VARCHAR(30);

ALTER TABLE salary_advance_request
    ADD COLUMN IF NOT EXISTS authority_type_at_request VARCHAR(50);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_salary_advance_authority_ref'
    ) THEN
        ALTER TABLE salary_advance_request
            ADD CONSTRAINT fk_salary_advance_authority_ref
            FOREIGN KEY (authority_ref)
            REFERENCES erp_authority_master(authority_ref)
            ON DELETE RESTRICT;
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_salary_advance_authority_type_values'
    ) THEN
        ALTER TABLE salary_advance_request
            ADD CONSTRAINT chk_salary_advance_authority_type_values
            CHECK (
                authority_type_at_request IS NULL
                OR authority_type_at_request IN ('Town Council', 'Municipal Council', 'City Council')
            );
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_salary_advance_head_title_by_authority_type'
    ) THEN
        ALTER TABLE salary_advance_request
            ADD CONSTRAINT chk_salary_advance_head_title_by_authority_type
            CHECK (
                head_approver_title IS NULL
                OR authority_type_at_request IS NULL
                OR (
                    authority_type_at_request = 'Town Council'
                    AND head_approver_title = 'COUNCIL_SECRETARY'
                )
                OR (
                    authority_type_at_request IN ('Municipal Council', 'City Council')
                    AND head_approver_title = 'TOWN_CLERK'
                )
            );
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_salary_advance_authority_ref
    ON salary_advance_request(authority_ref);
