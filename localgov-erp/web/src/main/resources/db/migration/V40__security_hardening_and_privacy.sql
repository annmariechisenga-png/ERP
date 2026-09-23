ALTER TABLE erp_user_account
    ADD COLUMN IF NOT EXISTS mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE erp_user_account
    ADD COLUMN IF NOT EXISTS mfa_secret VARCHAR(120);

ALTER TABLE erp_user_account
    ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMP;

ALTER TABLE erp_user_account
    ADD COLUMN IF NOT EXISTS privacy_consent_at TIMESTAMP;

ALTER TABLE erp_user_account
    ADD COLUMN IF NOT EXISTS privacy_notice_version VARCHAR(20) NOT NULL DEFAULT '2026.04';

CREATE TABLE IF NOT EXISTS security_audit_log (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(80) NOT NULL,
    roles_csv VARCHAR(200),
    action VARCHAR(160) NOT NULL,
    http_method VARCHAR(10) NOT NULL,
    path VARCHAR(255) NOT NULL,
    status_code INTEGER NOT NULL,
    success BOOLEAN NOT NULL DEFAULT TRUE,
    client_ip VARCHAR(80),
    user_agent VARCHAR(255),
    correlation_id VARCHAR(80),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_security_audit_log_created_at ON security_audit_log (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_security_audit_log_username ON security_audit_log (username);

CREATE TABLE IF NOT EXISTS privacy_data_request (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(80) NOT NULL,
    request_type VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED',
    details TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_privacy_data_request_username ON privacy_data_request (username);
CREATE INDEX IF NOT EXISTS idx_privacy_data_request_created_at ON privacy_data_request (created_at DESC);
