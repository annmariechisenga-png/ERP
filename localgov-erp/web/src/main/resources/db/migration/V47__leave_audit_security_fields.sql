-- V47 – Add security context fields to leave_calculation_audit_log
-- These fields ensure audit entries always record authenticated identity.

ALTER TABLE leave_calculation_audit_log
    ADD COLUMN IF NOT EXISTS username       VARCHAR(80),
    ADD COLUMN IF NOT EXISTS authority_code  VARCHAR(10),
    ADD COLUMN IF NOT EXISTS authority_type  VARCHAR(50),
    ADD COLUMN IF NOT EXISTS role            VARCHAR(200);
