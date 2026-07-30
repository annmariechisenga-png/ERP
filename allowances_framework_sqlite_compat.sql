-- ===================================================
-- COMPREHENSIVE ALLOWANCES FRAMEWORK (SQLITE COMPAT)
-- For current hr_platform.db schema
-- ===================================================

-- allowance_types schema in SQLite:
-- (allowance_code, allowance_name, calc_method, default_value,
--  taxable, pensionable, active, source_doc, show_on_payslip)

INSERT OR REPLACE INTO allowance_types (
    allowance_code, allowance_name, calc_method, default_value,
    taxable, pensionable, active, source_doc, show_on_payslip
) VALUES
('HOU', 'Housing Allowance', 'PERCENT_BASIC', 0.20, 0, 0, 1, 'Collective Agreement 2025 Sec 4.1(i)', 1),
('EDU', 'Education Allowance', 'PERCENT_BASIC', 0.20, 1, 0, 1, 'Collective Agreement 2025 Sec 4.1(iii)', 1),
('RISK', 'Risk Allowance', 'PERCENT_BASIC', 0.02, 1, 0, 1, 'Collective Agreement 2025 Sec 4.1(iv)', 1),
('TRN_GEN', 'Transport Allowance (General)', 'PERCENT_BASIC', 0.17, 1, 0, 1, 'Collective Agreement 2025 Sec 4.1(ii)', 1),
('TRN_FIRE', 'Transport Allowance (Fire)', 'PERCENT_BASIC', 0.15, 1, 0, 1, 'FIRESUZ Agreement 2024 Sec 2.1(ii)', 1),
('FUL_MGT', 'Fuel Allowance (Management)', 'PERCENT_BASIC', 0.32, 1, 0, 1, 'Management Circular 2025 Sec 2.1(ii)', 1),
('STANDBY', 'Standby Allowance', 'PERCENT_BASIC', 0.06, 1, 0, 1, 'FIRESUZ Agreement 2024 Sec 2.2(iii)', 1),
('EXCESS_HOURS', 'Allowance in Lieu of Excess Hours', 'FIXED_AMOUNT', 400.00, 1, 0, 1, 'FIRESUZ Agreement 2024 Sec 2.2(iv)', 1),
('RATION', 'Ration Allowance', 'PERCENT_BASIC_TIERED', NULL, 1, 0, 1, 'FIRESUZ Agreement 2024 Sec 2.2(v)', 1),
('RURAL', 'Rural Hardship Allowance', 'PERCENT_BASIC', 0.20, 1, 0, 1, 'Collective Agreement 2025 Sec 4.2(i)', 1),
('REMOTE', 'Remote Hardship Allowance', 'PERCENT_BASIC', 0.25, 1, 0, 1, 'Collective Agreement 2025 Sec 4.2(ii)', 1),
('SUBSISTENCE', 'Subsistence Allowance', 'TIERED_BY_LOCATION', NULL, 0, 0, 1, 'Collective Agreement 2025 Sec 4.2(v)', 1),
('MEAL', 'Meal Allowance', 'FIXED_AMOUNT', 150.00, 0, 0, 1, 'Collective Agreement 2025 Sec 4.2(iv)', 1);

CREATE TABLE IF NOT EXISTS ration_allowance_tiers (
    tier_id TEXT PRIMARY KEY,
    salary_scale_range TEXT NOT NULL,
    percentage REAL NOT NULL,
    effective_from TEXT NOT NULL,
    effective_to TEXT,
    is_active INTEGER DEFAULT 1
);

INSERT OR REPLACE INTO ration_allowance_tiers (
    tier_id, salary_scale_range, percentage, effective_from, effective_to, is_active
) VALUES
('RATION-LGSS08-10', 'LGSS08-LGSS10', 12.5, '2024-01-01', NULL, 1),
('RATION-LGSS11-12', 'LGSS11-LGSS12', 15.0, '2024-01-01', NULL, 1),
('RATION-LGSS13-14', 'LGSS13-LGSS14', 20.0, '2024-01-01', NULL, 1);

CREATE TABLE IF NOT EXISTS unions (
    union_id TEXT PRIMARY KEY,
    union_code TEXT UNIQUE NOT NULL,
    union_name TEXT NOT NULL,
    membership_fee_percentage REAL,
    membership_fee_fixed REAL
);

INSERT OR REPLACE INTO unions (
    union_id, union_code, union_name, membership_fee_percentage, membership_fee_fixed
) VALUES
('UNION-ZULAWAU', 'ZULAWAU', 'Zambia United Local Authorities and Allied Workers'' Union', 1.00, NULL),
('UNION-FIRESUZ', 'FIRESUZ', 'Fire Services Union of Zambia', 1.00, NULL),
('UNION-MGMT', 'MANAGEMENT', 'Management (Non-Unionized)', NULL, NULL);

-- SQLite DB has no officers/employment_history tables.
-- Store membership and fire-profile metadata against employees.
ALTER TABLE employees ADD COLUMN union_code TEXT;
ALTER TABLE employees ADD COLUMN union_member INTEGER DEFAULT 0;
ALTER TABLE employees ADD COLUMN union_opt_out INTEGER DEFAULT 0;
ALTER TABLE employees ADD COLUMN is_fire_officer INTEGER DEFAULT 0;
ALTER TABLE employees ADD COLUMN ppe_provided INTEGER DEFAULT 0;
ALTER TABLE employees ADD COLUMN ppe_provision_date TEXT;
ALTER TABLE employees ADD COLUMN standby_rotation TEXT;

CREATE TABLE IF NOT EXISTS fire_ppe_tracking (
    ppe_id TEXT PRIMARY KEY,
    employee_id TEXT NOT NULL,
    ppe_type TEXT NOT NULL,
    issue_date TEXT NOT NULL,
    expiry_date TEXT,
    condition TEXT,
    issued_by TEXT,
    return_date TEXT,
    return_reason TEXT,
    notes TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
