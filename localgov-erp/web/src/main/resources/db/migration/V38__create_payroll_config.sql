-- Payroll cut-off and overtime governance configuration

CREATE TABLE IF NOT EXISTS payroll_config (
    id           BIGSERIAL PRIMARY KEY,
    config_key   VARCHAR(50)  NOT NULL UNIQUE,
    config_value VARCHAR(100) NOT NULL,
    description  TEXT,
    updated_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);

INSERT INTO payroll_config (config_key, config_value, description) VALUES
    ('payroll_cutoff_day', '15', 'Day of month when payroll closes'),
    ('overtime_ro_threshold_hours', '2', 'Hours threshold requiring RO approval'),
    ('overtime_max_hours_per_month', '40', 'Maximum overtime hours per month per employee')
ON CONFLICT (config_key) DO UPDATE
SET
    config_value = EXCLUDED.config_value,
    description = EXCLUDED.description,
    updated_at = NOW();
