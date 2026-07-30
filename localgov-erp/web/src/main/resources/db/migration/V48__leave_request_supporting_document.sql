-- V48 – Add supporting document columns to erp_leave_request
-- These columns are required by the LeaveRequest JPA entity for document upload support.

ALTER TABLE erp_leave_request
    ADD COLUMN IF NOT EXISTS supporting_document_name         VARCHAR(255),
    ADD COLUMN IF NOT EXISTS supporting_document_content_type VARCHAR(100),
    ADD COLUMN IF NOT EXISTS supporting_document_data         BYTEA;
