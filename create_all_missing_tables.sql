-- ============================================
-- CREATE ALL MISSING TABLES
-- ============================================

-- HRA Tables
CREATE TABLE IF NOT EXISTS hra_leave_approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS hra_leaveapprovalchains (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS hra_position_attributes (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    attribute_name TEXT,
    attribute_value TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS hra_position_supervisors (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    supervisor_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS hra_reportinglines (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    supervisor_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS hra_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'HRA',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Finance Tables
CREATE TABLE IF NOT EXISTS finance_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS finance_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS finance_leave_approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS finance_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'FIN',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Legal Tables
CREATE TABLE IF NOT EXISTS legal_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS legal_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS legal_leave_approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS legal_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'LEG',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Health Tables
CREATE TABLE IF NOT EXISTS health_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS health_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS health_leave_approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS health_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'HLT',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Community Tables
CREATE TABLE IF NOT EXISTS community_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS community_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS community_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Engineering Tables
CREATE TABLE IF NOT EXISTS eng_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS eng_leave_approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS eng_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'ENG',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Planning Tables
CREATE TABLE IF NOT EXISTS planning_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS planning_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS planning_leave_approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS planning_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'PLN',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ICT Tables
CREATE TABLE IF NOT EXISTS ict_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ict_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'ICT',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ict_city_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ict_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'ICT',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Tables
CREATE TABLE IF NOT EXISTS audit_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'AUD',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Procurement Tables
CREATE TABLE IF NOT EXISTS procurement_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS procurement_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS procurement_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'PRO',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Commercial Tables
CREATE TABLE IF NOT EXISTS commercial_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS commercial_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS commercial_city_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS commercial_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- COS/TOC Tables
CREATE TABLE IF NOT EXISTS cos_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS cos_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'COS',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS toc_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS toc_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'TOC',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS toc_city_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS toc_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'TOC',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Valuation Tables
CREATE TABLE IF NOT EXISTS valuation_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_id INTEGER,
    department TEXT DEFAULT 'VAL',
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notification and SMS Tables (already have some)
CREATE TABLE IF NOT EXISTS notification_queue (
    notification_id SERIAL PRIMARY KEY,
    recipient_standard_id TEXT,
    recipient_phone TEXT,
    recipient_email TEXT,
    notification_type TEXT NOT NULL,
    subject TEXT,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'PENDING',
    sent_at TIMESTAMP,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS notification_history (
    history_id SERIAL PRIMARY KEY,
    notification_id INTEGER,
    sent_at TIMESTAMP,
    delivery_status TEXT,
    error_message TEXT
);

CREATE TABLE IF NOT EXISTS hr_recipients (
    recipient_id SERIAL PRIMARY KEY,
    employee_standard_id TEXT UNIQUE,
    phone_number TEXT,
    email TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Job Description Tables (already created in your previous successful output)
-- The CREATE TABLE at the end of your output shows they were created successfully

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_hra_supervision_position ON hra_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_finance_supervision_position ON finance_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_legal_supervision_position ON legal_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_health_supervision_position ON health_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_community_supervision_position ON community_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_eng_supervision_position ON eng_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_planning_supervision_position ON planning_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_ict_supervision_position ON ict_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_audit_supervision_position ON audit_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_procurement_supervision_position ON procurement_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_commercial_supervision_position ON commercial_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_cos_supervision_position ON cos_supervision(position_standard_id);
CREATE INDEX IF NOT EXISTS idx_toc_supervision_position ON toc_supervision(position_standard_id);
