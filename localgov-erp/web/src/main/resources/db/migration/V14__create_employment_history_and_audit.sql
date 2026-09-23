CREATE TABLE IF NOT EXISTS employment_history (
    id BIGSERIAL PRIMARY KEY,
    officer_id BIGINT NOT NULL,
    authority_id VARCHAR(40) NOT NULL,
    salary_scale VARCHAR(30) NOT NULL,
    notch_number INTEGER NOT NULL,
    monthly_salary NUMERIC(18,2) NOT NULL,
    approved_by VARCHAR(120) NOT NULL,
    approval_date DATE NOT NULL,
    approval_reference VARCHAR(100),
    appointment_letter_url VARCHAR(500),
    effective_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    created_by VARCHAR(120) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employment_history_officer
        FOREIGN KEY (officer_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_employment_history_authority
        FOREIGN KEY (authority_id)
        REFERENCES erp_authority_master(authority_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_employment_history_officer_effective UNIQUE (officer_id, effective_date)
);

CREATE INDEX IF NOT EXISTS idx_employment_history_scale_notch
    ON employment_history (salary_scale, notch_number, effective_date DESC);

CREATE TABLE IF NOT EXISTS employment_placement_audit_log (
    id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(60) NOT NULL,
    officer_id BIGINT NOT NULL,
    details VARCHAR(500) NOT NULL,
    created_by VARCHAR(120) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employment_audit_officer
        FOREIGN KEY (officer_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_employment_placement_audit_officer_created
    ON employment_placement_audit_log (officer_id, created_at DESC);
