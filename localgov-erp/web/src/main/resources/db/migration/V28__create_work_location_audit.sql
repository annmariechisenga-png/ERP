CREATE TABLE IF NOT EXISTS work_location_audit (
    id BIGSERIAL PRIMARY KEY,
    location_id BIGINT NOT NULL,
    action VARCHAR(20) NOT NULL,
    field_changed VARCHAR(50),
    old_value TEXT,
    new_value TEXT,
    performed_by BIGINT NOT NULL,
    performed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_work_location_audit_location
        FOREIGN KEY (location_id) REFERENCES work_locations(id),
    CONSTRAINT fk_work_location_audit_performed_by
        FOREIGN KEY (performed_by) REFERENCES erp_employee(id),
    CONSTRAINT chk_work_location_audit_action
        CHECK (action IN ('CREATE', 'UPDATE', 'DELETE', 'ACTIVATE', 'DEACTIVATE'))
);

CREATE INDEX IF NOT EXISTS idx_work_location_audit_location
    ON work_location_audit (location_id);

CREATE INDEX IF NOT EXISTS idx_work_location_audit_performed_at
    ON work_location_audit (performed_at);