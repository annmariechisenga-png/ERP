DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'erp_leave_request_status_check'
          AND conrelid = 'erp_leave_request'::regclass
    ) THEN
        ALTER TABLE erp_leave_request
            DROP CONSTRAINT erp_leave_request_status_check;
    END IF;
END $$;

ALTER TABLE erp_leave_request
    ADD CONSTRAINT erp_leave_request_status_check
    CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'));
