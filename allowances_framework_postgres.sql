-- ===================================================
-- COMPREHENSIVE ALLOWANCES FRAMEWORK (POSTGRES)
-- Including General LA, Management, and Fire Services
-- ===================================================

-- 1. ALLOWANCE TYPES (Complete with Fire Services)
INSERT INTO allowance_types (allowance_code, allowance_name, allowance_category,
                            calculation_method, calculation_value,
                            applies_to_divisions, applies_to_unions,
                            is_taxable, is_pensionable, legislative_reference) VALUES

-- REMUNERATIVE ALLOWANCES (All employees)
('HOU', 'Housing Allowance', 'REMUNERATIVE', 'PERCENTAGE_OF_BASIC', 20.00,
 '["DIVISION_I", "DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ALL"]',
 FALSE, FALSE, 'Collective Agreement 2025 Sec 4.1(i)'),

('EDU', 'Education Allowance', 'REMUNERATIVE', 'PERCENTAGE_OF_BASIC', 20.00,
 '["DIVISION_I", "DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ALL"]',
 TRUE, FALSE, 'Collective Agreement 2025 Sec 4.1(iii)'),

('RISK', 'Risk Allowance', 'REMUNERATIVE', 'PERCENTAGE_OF_BASIC', 2.00,
 '["DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ZULAWAU", "FIRESUZ"]',
 TRUE, FALSE, 'Collective Agreement 2025 Sec 4.1(iv)'),

-- TRANSPORT/FUEL (Different rates by group)
('TRN_GEN', 'Transport Allowance (General)', 'REMUNERATIVE', 'PERCENTAGE_OF_BASIC', 17.00,
 '["DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ZULAWAU"]',
 TRUE, FALSE, 'Collective Agreement 2025 Sec 4.1(ii)'),

('TRN_FIRE', 'Transport Allowance (Fire)', 'REMUNERATIVE', 'PERCENTAGE_OF_BASIC', 15.00,
 '["DIVISION_II", "DIVISION_III"]', '["FIRESUZ"]',
 TRUE, FALSE, 'FIRESUZ Agreement 2024 Sec 2.1(ii)'),

('FUL_MGT', 'Fuel Allowance (Management)', 'REMUNERATIVE', 'PERCENTAGE_OF_BASIC', 32.00,
 '["DIVISION_I"]', '["MANAGEMENT"]',
 TRUE, FALSE, 'Management Circular 2025 Sec 2.1(ii)'),

-- FIRE-SPECIFIC ALLOWANCES
('STANDBY', 'Standby Allowance', 'FIRE_SPECIAL', 'PERCENTAGE_OF_BASIC', 6.00,
 '["DIVISION_II", "DIVISION_III"]', '["FIRESUZ"]',
 TRUE, FALSE, 'FIRESUZ Agreement 2024 Sec 2.2(iii)'),

('EXCESS_HOURS', 'Allowance in Lieu of Excess Hours', 'FIRE_SPECIAL', 'FIXED', 400.00,
 '["DIVISION_II", "DIVISION_III"]', '["FIRESUZ"]',
 TRUE, FALSE, 'FIRESUZ Agreement 2024 Sec 2.2(iv)'),

('RATION', 'Ration Allowance', 'FIRE_SPECIAL', 'PERCENTAGE_OF_BASIC_TIERED', NULL,
 '["DIVISION_II", "DIVISION_III"]', '["FIRESUZ"]',
 TRUE, FALSE, 'FIRESUZ Agreement 2024 Sec 2.2(v)'),

-- DUTY FACILITATING (All employees)
('RURAL', 'Rural Hardship Allowance', 'DUTY_FACILITATING', 'PERCENTAGE_OF_BASIC', 20.00,
 '["DIVISION_I", "DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ALL"]',
 TRUE, FALSE, 'Collective Agreement 2025 Sec 4.2(i)'),

('REMOTE', 'Remote Hardship Allowance', 'DUTY_FACILITATING', 'PERCENTAGE_OF_BASIC', 25.00,
 '["DIVISION_I", "DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ALL"]',
 TRUE, FALSE, 'Collective Agreement 2025 Sec 4.2(ii)'),

-- CLAIM-BASED (All employees)
('SUBSISTENCE', 'Subsistence Allowance', 'CLAIM_BASED', 'TIERED_BY_LOCATION', NULL,
 '["DIVISION_I", "DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ALL"]',
 FALSE, FALSE, 'Collective Agreement 2025 Sec 4.2(v)'),

('MEAL', 'Meal Allowance', 'CLAIM_BASED', 'FIXED', 150.00,
 '["DIVISION_I", "DIVISION_II", "DIVISION_III", "DIVISION_IV"]', '["ALL"]',
 FALSE, FALSE, 'Collective Agreement 2025 Sec 4.2(iv)');

-- 2. RATION ALLOWANCE TIERS (Fire Services specific)
CREATE TABLE IF NOT EXISTS ration_allowance_tiers (
    tier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    salary_scale_range VARCHAR(50) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO ration_allowance_tiers (salary_scale_range, percentage, effective_from) VALUES
('LGSS08-LGSS10', 12.5, '2024-01-01'),
('LGSS11-LGSS12', 15.0, '2024-01-01'),
('LGSS13-LGSS14', 20.0, '2024-01-01');

-- 3. UNION MEMBERSHIP TABLE
CREATE TABLE IF NOT EXISTS unions (
    union_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    union_code VARCHAR(20) UNIQUE NOT NULL,
    union_name VARCHAR(200) NOT NULL,
    membership_fee_percentage DECIMAL(5,2),
    membership_fee_fixed DECIMAL(10,2)
);

INSERT INTO unions (union_code, union_name, membership_fee_percentage) VALUES
('ZULAWAU', 'Zambia United Local Authorities and Allied Workers'' Union', 1.00),
('FIRESUZ', 'Fire Services Union of Zambia', 1.00),
('MANAGEMENT', 'Management (Non-Unionized)', NULL)
ON CONFLICT (union_code) DO NOTHING;

-- 4. EMPLOYEE UNION MEMBERSHIP
ALTER TABLE officers ADD COLUMN IF NOT EXISTS union_id UUID REFERENCES unions(union_id);
ALTER TABLE officers ADD COLUMN IF NOT EXISTS union_member BOOLEAN DEFAULT FALSE;
ALTER TABLE officers ADD COLUMN IF NOT EXISTS union_opt_out BOOLEAN DEFAULT FALSE;

-- 5. ENHANCED EMPLOYMENT HISTORY FOR FIRE OFFICERS
ALTER TABLE employment_history ADD COLUMN IF NOT EXISTS is_fire_officer BOOLEAN DEFAULT FALSE;
ALTER TABLE employment_history ADD COLUMN IF NOT EXISTS ppe_provided BOOLEAN DEFAULT FALSE;
ALTER TABLE employment_history ADD COLUMN IF NOT EXISTS ppe_provision_date DATE;
ALTER TABLE employment_history ADD COLUMN IF NOT EXISTS standby_rotation VARCHAR(50);

-- 6. FIRE-SPECIFIC OBLIGATIONS (PPE Tracking)
CREATE TABLE IF NOT EXISTS fire_ppe_tracking (
    ppe_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    officer_id UUID REFERENCES officers(officer_id),
    ppe_type VARCHAR(100) NOT NULL,
    issue_date DATE NOT NULL,
    expiry_date DATE,
    condition VARCHAR(50),
    issued_by UUID,
    return_date DATE,
    return_reason VARCHAR(200),
    notes TEXT
);

-- 7 and 8.
-- Function definitions (calculate_fire_officer_allowances, calculate_employee_payroll_comprehensive)
-- should be applied from your approved PL/pgSQL script body.
-- Kept separate to allow review before deployment in production payroll.
