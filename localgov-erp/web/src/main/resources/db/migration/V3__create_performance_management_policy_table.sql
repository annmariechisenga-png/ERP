CREATE TABLE IF NOT EXISTS performance_management_policy (
    id BIGSERIAL PRIMARY KEY,
    policy_code VARCHAR(50) NOT NULL UNIQUE,
    policy_name VARCHAR(150) NOT NULL,
    appraisal_cycle_months INTEGER NOT NULL,
    rating_scale VARCHAR(50) NOT NULL,
    probation_review_months INTEGER NOT NULL,
    improvement_plan_days INTEGER NOT NULL,
    applies_to_all_authorities BOOLEAN NOT NULL DEFAULT TRUE,
    authorities_covered INTEGER NOT NULL DEFAULT 116,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO performance_management_policy (
    policy_code,
    policy_name,
    appraisal_cycle_months,
    rating_scale,
    probation_review_months,
    improvement_plan_days,
    applies_to_all_authorities,
    authorities_covered,
    is_active
)
SELECT
    'GLOBAL_PM',
    'Global Performance Management Policy',
    12,
    '1-5',
    6,
    90,
    TRUE,
    116,
    TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM performance_management_policy
    WHERE policy_code = 'GLOBAL_PM'
);