-- ============================================
-- COMPLETE POSTGRESQL SCHEMA FROM SQLITE
-- ============================================

-- Drop sqlite_sequence table (not needed in PostgreSQL)
-- (sqlite_sequence is automatically handled by SERIAL)

-- Employees table
CREATE TABLE employees (
    employee_id TEXT PRIMARY KEY,
    province TEXT,
    district TEXT,
    name TEXT NOT NULL,
    nrc_number TEXT UNIQUE,
    sex TEXT,
    date_of_birth DATE,
    position TEXT,
    salary_scale TEXT,
    local_authority_service_number TEXT,
    date_of_first_appointment DATE,
    date_confirmed DATE,
    date_substantive_appointment DATE,
    date_reported DATE,
    academic_qualifications TEXT,
    professional_qualifications TEXT,
    acting_position TEXT,
    acting_date DATE,
    department TEXT,
    phone_number TEXT,
    carried_forward_leave INTEGER DEFAULT 0,
    days_availed INTEGER DEFAULT 0,
    leave_taken INTEGER DEFAULT 0,
    leave_commuted INTEGER DEFAULT 0,
    leave_transferred_out INTEGER DEFAULT 0,
    leave_balance INTEGER DEFAULT 0,
    gender TEXT CHECK (gender IN ('Male', 'Female', 'Other')),
    is_active BOOLEAN DEFAULT TRUE,
    hire_date DATE,
    email TEXT,
    phone TEXT,
    supervisor_id TEXT REFERENCES employees(employee_id),
    notification_preference TEXT DEFAULT 'Both',
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX idx_employees_nrc ON employees(nrc_number);
CREATE INDEX idx_employees_council ON employees(council_id);
CREATE INDEX idx_employees_supervisor ON employees(supervisor_id);

-- Duplicates archive table
CREATE TABLE duplicates_archive (
    archive_id SERIAL PRIMARY KEY,
    province TEXT,
    district TEXT,
    name TEXT,
    nrc_number TEXT,
    sex TEXT,
    date_of_birth DATE,
    position TEXT,
    salary_scale TEXT,
    local_authority_service_number TEXT,
    date_of_first_appointment DATE,
    date_confirmed DATE,
    date_substantive_appointment DATE,
    date_reported DATE,
    academic_qualifications TEXT,
    professional_qualifications TEXT,
    acting_position TEXT,
    acting_date DATE,
    department TEXT,
    phone_number TEXT,
    carried_forward_leave INTEGER DEFAULT 0,
    days_availed INTEGER DEFAULT 0,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    archived_by TEXT,
    council_id INTEGER
);

-- Audit log table
CREATE TABLE audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    record_id TEXT,
    action TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    council_id INTEGER
);

CREATE INDEX idx_audit_log_table ON audit_log(table_name);
CREATE INDEX idx_audit_log_changed_at ON audit_log(changed_at);

-- Leave policy table
CREATE TABLE leave_policy (
    policy_id SERIAL PRIMARY KEY,
    policy_name TEXT NOT NULL,
    leave_type TEXT NOT NULL,
    max_days INTEGER,
    min_service_days INTEGER,
    requires_approval BOOLEAN DEFAULT TRUE,
    requires_medical_certificate BOOLEAN DEFAULT FALSE,
    is_paid BOOLEAN DEFAULT TRUE,
    applicable_genders TEXT[],
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Leave requests table
CREATE TABLE leave_requests (
    request_id SERIAL PRIMARY KEY,
    employee_id TEXT REFERENCES employees(employee_id),
    leave_type TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days_requested DECIMAL(5,2),
    reason TEXT,
    status TEXT DEFAULT 'PENDING',
    current_approver_id TEXT,
    approval_level INTEGER DEFAULT 1,
    submitted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_leave_requests_employee ON leave_requests(employee_id);
CREATE INDEX idx_leave_requests_status ON leave_requests(status);
CREATE INDEX idx_leave_requests_dates ON leave_requests(start_date, end_date);

-- Holidays table
CREATE TABLE holidays (
    holiday_id SERIAL PRIMARY KEY,
    holiday_name TEXT NOT NULL,
    holiday_date DATE NOT NULL,
    is_recurring BOOLEAN DEFAULT FALSE,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Calendar table (for date dimensions)
CREATE TABLE calendar (
    date_id SERIAL PRIMARY KEY,
    calendar_date DATE UNIQUE NOT NULL,
    day_of_week INTEGER,
    day_name TEXT,
    month INTEGER,
    month_name TEXT,
    quarter INTEGER,
    year INTEGER,
    is_weekend BOOLEAN DEFAULT FALSE,
    is_holiday BOOLEAN DEFAULT FALSE,
    council_id INTEGER
);

-- Leave balances table
CREATE TABLE leave_balances (
    balance_id SERIAL PRIMARY KEY,
    employee_id TEXT REFERENCES employees(employee_id),
    year INTEGER NOT NULL,
    leave_type TEXT NOT NULL,
    days_entitled INTEGER DEFAULT 0,
    days_taken INTEGER DEFAULT 0,
    days_remaining INTEGER GENERATED ALWAYS AS (days_entitled - days_taken) STORED,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    council_id INTEGER,
    UNIQUE(employee_id, year, leave_type)
);

-- Authority codes table
CREATE TABLE authority_codes (
    code_id SERIAL PRIMARY KEY,
    authority_code TEXT UNIQUE,
    authority_name TEXT,
    description TEXT,
    max_amount DECIMAL(10,2),
    requires_second_approval BOOLEAN DEFAULT FALSE,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employee sequence table
CREATE TABLE employee_sequence (
    seq_id SERIAL PRIMARY KEY,
    council_id INTEGER UNIQUE,
    last_employee_number INTEGER DEFAULT 0,
    prefix TEXT,
    year INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vacation allowances table
CREATE TABLE vacation_allowances (
    allowance_id SERIAL PRIMARY KEY,
    employee_id TEXT REFERENCES employees(employee_id),
    year INTEGER NOT NULL,
    days_entitled INTEGER DEFAULT 30,
    days_carried_forward INTEGER DEFAULT 0,
    days_taken INTEGER DEFAULT 0,
    days_remaining INTEGER GENERATED ALWAYS AS (days_entitled + days_carried_forward - days_taken) STORED,
    council_id INTEGER,
    UNIQUE(employee_id, year)
);

-- Approval chain table
CREATE TABLE approval_chain (
    chain_id SERIAL PRIMARY KEY,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    approver_level INTEGER NOT NULL,
    approver_id TEXT,
    approver_role TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Departments table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_code TEXT UNIQUE,
    department_name TEXT NOT NULL,
    description TEXT,
    head_position_id TEXT,
    council_id INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Position attributes table
CREATE TABLE position_attributes (
    attribute_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    attribute_name TEXT NOT NULL,
    attribute_value TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Authorities table
CREATE TABLE authorities (
    authority_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    authority_type TEXT NOT NULL,
    max_amount DECIMAL(10,2),
    can_approve BOOLEAN DEFAULT FALSE,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Position supervisors table
CREATE TABLE position_supervisors (
    id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    supervisor_id TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ReportingLines table
CREATE TABLE ReportingLines (
    line_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    supervisor_id TEXT NOT NULL,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- LeaveApprovalChains table
CREATE TABLE LeaveApprovalChains (
    chain_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    approver_level INTEGER NOT NULL,
    approver_id TEXT NOT NULL,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Councils table
CREATE TABLE Councils (
    council_id SERIAL PRIMARY KEY,
    council_name TEXT NOT NULL,
    top_authority TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- HRA Positions table
CREATE TABLE HRA_Positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_id INTEGER REFERENCES Councils(council_id),
    is_head_of_unit BOOLEAN DEFAULT FALSE,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    is_specialist BOOLEAN DEFAULT FALSE,
    standard_id TEXT UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Continue with more tables...
