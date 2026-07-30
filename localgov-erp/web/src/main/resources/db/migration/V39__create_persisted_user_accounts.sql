CREATE TABLE IF NOT EXISTS erp_user_account (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    employee_id BIGINT NOT NULL UNIQUE,
    roles_csv VARCHAR(200) NOT NULL,
    dashboard_position_id VARCHAR(80) NOT NULL,
    authority_code VARCHAR(10),
    authority_type VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_erp_user_account_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_erp_user_account_username ON erp_user_account (username);
CREATE INDEX IF NOT EXISTS idx_erp_user_account_active ON erp_user_account (is_active);
