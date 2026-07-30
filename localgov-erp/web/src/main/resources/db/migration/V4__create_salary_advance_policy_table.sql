CREATE TABLE IF NOT EXISTS salary_advance_policy (
    id BIGSERIAL PRIMARY KEY,
    policy_code VARCHAR(50) NOT NULL,
    policy_name VARCHAR(150) NOT NULL,
    max_advance_percent NUMERIC(5,2) NOT NULL,
    max_installments INTEGER NOT NULL,
    minimum_service_months INTEGER NOT NULL,
    interest_rate_percent NUMERIC(5,2) NOT NULL DEFAULT 0.00,
    requires_supervisor_approval BOOLEAN NOT NULL DEFAULT TRUE,
    requires_hr_approval BOOLEAN NOT NULL DEFAULT TRUE,
    applies_to_all_authorities BOOLEAN NOT NULL DEFAULT TRUE,
    authorities_covered INTEGER NOT NULL DEFAULT 116,
    effective_from DATE NOT NULL DEFAULT CURRENT_DATE,
    effective_to DATE,
    version_no INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    approved_by VARCHAR(120),
    approved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_salary_advance_percent_range
        CHECK (max_advance_percent > 0 AND max_advance_percent <= 100),
    CONSTRAINT chk_salary_advance_installments
        CHECK (max_installments > 0),
    CONSTRAINT chk_salary_advance_service_months
        CHECK (minimum_service_months >= 0),
    CONSTRAINT chk_salary_advance_interest_rate
        CHECK (interest_rate_percent >= 0),
    CONSTRAINT chk_salary_advance_authorities_covered
        CHECK (authorities_covered > 0),
    CONSTRAINT chk_salary_advance_effective_window
        CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_salary_advance_policy_code_version
    ON salary_advance_policy(policy_code, version_no);

CREATE UNIQUE INDEX IF NOT EXISTS ux_salary_advance_policy_single_active
    ON salary_advance_policy(policy_code)
    WHERE is_active = TRUE;

INSERT INTO salary_advance_policy (
    policy_code,
    policy_name,
    max_advance_percent,
    max_installments,
    minimum_service_months,
    interest_rate_percent,
    requires_supervisor_approval,
    requires_hr_approval,
    applies_to_all_authorities,
    authorities_covered,
    effective_from,
    version_no,
    is_active,
    approved_by,
    approved_at
)
SELECT
    'GLOBAL_SALARY_ADVANCE',
    'Global Salary Advance Policy',
    50.00,
    6,
    6,
    0.00,
    TRUE,
    TRUE,
    TRUE,
    116,
    CURRENT_DATE,
    1,
    TRUE,
    'SYSTEM',
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1
    FROM salary_advance_policy
    WHERE policy_code = 'GLOBAL_SALARY_ADVANCE'
      AND version_no = 1
);