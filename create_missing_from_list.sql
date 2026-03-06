-- ============================================
-- CREATE MISSING TABLES FROM THE LIST
-- ============================================

-- Councils (with capital C - your data expects this)
CREATE TABLE IF NOT EXISTS Councils (
    council_id SERIAL PRIMARY KEY,
    council_name TEXT NOT NULL,
    top_authority TEXT NOT NULL
);

-- HRA Positions
CREATE TABLE IF NOT EXISTS HRA_Positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    is_specialist BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Positions
CREATE TABLE IF NOT EXISTS audit_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_vacant BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Commercial City Positions
CREATE TABLE IF NOT EXISTS commercial_city_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Commercial Positions
CREATE TABLE IF NOT EXISTS commercial_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Community Positions
CREATE TABLE IF NOT EXISTS community_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    is_special_unit BOOLEAN DEFAULT FALSE,
    specific_council_id INTEGER,
    special_unit_name TEXT,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COS Positions (Council Secretary Office)
CREATE TABLE IF NOT EXISTS cos_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Engineering Position Hierarchy
CREATE TABLE IF NOT EXISTS eng_position_hierarchy (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    supervisor_id TEXT,
    level INTEGER,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Engineering Positions
CREATE TABLE IF NOT EXISTS eng_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Executive Positions
CREATE TABLE IF NOT EXISTS executive_positions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    standard_id TEXT UNIQUE,
    council_id INTEGER,
    is_council_secretary BOOLEAN DEFAULT FALSE,
    is_head_of_department BOOLEAN DEFAULT FALSE,
    establishment INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Finance Positions
CREATE TABLE IF NOT EXISTS finance_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Health Positions
CREATE TABLE IF NOT EXISTS health_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    is_special_unit BOOLEAN DEFAULT FALSE,
    specific_council_id INTEGER,
    special_unit_name TEXT,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ICT City Positions
CREATE TABLE IF NOT EXISTS ict_city_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ICT Positions
CREATE TABLE IF NOT EXISTS ict_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_specialist BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Leave Approval Chain
CREATE TABLE IF NOT EXISTS leave_approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    approver_role TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Leave Types
CREATE TABLE IF NOT EXISTS leave_types (
    leave_type_id SERIAL PRIMARY KEY,
    leave_type_code TEXT UNIQUE NOT NULL,
    leave_type_name TEXT NOT NULL,
    description TEXT,
    max_days_per_year INTEGER,
    min_service_months INTEGER DEFAULT 0,
    requires_medical_certificate BOOLEAN DEFAULT FALSE,
    is_paid BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Legal Positions
CREATE TABLE IF NOT EXISTS legal_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    has_practicing_certificate BOOLEAN DEFAULT FALSE,
    specialization TEXT,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Planning Positions
CREATE TABLE IF NOT EXISTS planning_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Position Role Codes
CREATE TABLE IF NOT EXISTS position_role_codes (
    id SERIAL PRIMARY KEY,
    role_code TEXT UNIQUE,
    role_name TEXT,
    role_level INTEGER,
    department TEXT,
    council_id INTEGER
);

-- Position Standard ID Map
CREATE TABLE IF NOT EXISTS position_standard_id_map (
    id SERIAL PRIMARY KEY,
    old_standard_id TEXT,
    new_standard_id TEXT,
    position_id TEXT,
    council_id INTEGER,
    migrated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Position Supervision
CREATE TABLE IF NOT EXISTS position_supervision (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    supervisor_id TEXT,
    supervision_level INTEGER,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Positions
CREATE TABLE IF NOT EXISTS positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    section_id INTEGER,
    council_id INTEGER,
    is_head BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procurement Positions
CREATE TABLE IF NOT EXISTS procurement_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    is_specialist BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Salary Scales
CREATE TABLE IF NOT EXISTS salary_scales (
    scale_id SERIAL PRIMARY KEY,
    salary_scale TEXT UNIQUE,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    step_increment DECIMAL(10,2),
    council_id INTEGER
);

-- Sections
CREATE TABLE IF NOT EXISTS sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TOC City Positions (Town Clerk Office)
CREATE TABLE IF NOT EXISTS toc_city_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TOC Positions
CREATE TABLE IF NOT EXISTS toc_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Valuation City Positions
CREATE TABLE IF NOT EXISTS valuation_city_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    stream TEXT,
    council_id INTEGER,
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_positions_council ON positions(council_id);
CREATE INDEX IF NOT EXISTS idx_positions_standard ON positions(standard_id);
CREATE INDEX IF NOT EXISTS idx_hra_positions_council ON HRA_Positions(council_id);
CREATE INDEX IF NOT EXISTS idx_finance_positions_council ON finance_positions(council_id);
CREATE INDEX IF NOT EXISTS idx_legal_positions_council ON legal_positions(council_id);
CREATE INDEX IF NOT EXISTS idx_health_positions_council ON health_positions(council_id);
CREATE INDEX IF NOT EXISTS idx_community_positions_council ON community_positions(council_id);
CREATE INDEX IF NOT EXISTS idx_eng_positions_council ON eng_positions(council_id);
CREATE INDEX IF NOT EXISTS idx_planning_positions_council ON planning_positions(council_id);
