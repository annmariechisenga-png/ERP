-- IT Department user roles with granular JSON permissions

CREATE TABLE user_roles (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT    NOT NULL,
    role        VARCHAR(20) NOT NULL,
    permissions JSONB,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_user_roles_employee FOREIGN KEY (user_id) REFERENCES employees (id),
    CONSTRAINT chk_user_roles_role CHECK (role IN (
        'it_admin', 'hr_admin', 'supervisor', 'manager', 'auditor', 'viewer'
    ))
);

CREATE INDEX idx_user_roles_user_id ON user_roles (user_id);
CREATE INDEX idx_user_roles_role    ON user_roles (role);

-- ── Seed: IT Admin permissions ───────────────────────────────────────────────
-- Replace user_id = 1 with the actual IT Admin employee id if different.
INSERT INTO user_roles (user_id, role, permissions) VALUES (
    1,
    'it_admin',
    '{
        "work_locations":       ["create", "read", "update", "delete", "activate", "deactivate"],
        "geofence":             ["create", "read", "update", "delete"],
        "employee_assignments": ["create", "read", "update"],
        "audit_logs":           ["read", "export"],
        "system_config":        ["create", "read", "update"]
    }'::jsonb
);
