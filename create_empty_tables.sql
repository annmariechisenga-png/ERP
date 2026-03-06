-- ============================================
-- CREATE EMPTY TABLES (NO DATA)
-- ============================================

-- HRA Tables
CREATE TABLE IF NOT EXISTS HRA_LeaveApprovalChains (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS HRA_ReportingLines (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    supervisor_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Approval Chains
CREATE TABLE IF NOT EXISTS LeaveApprovalChains (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ReportingLines (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    supervisor_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS approval_chain (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    approver_level INTEGER,
    approver_id TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit
CREATE TABLE IF NOT EXISTS audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    table_name TEXT,
    record_id TEXT,
    action TEXT,
    old_data JSONB,
    new_data JSONB,
    changed_by TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS authorities (
    authority_id SERIAL PRIMARY KEY,
    position_id TEXT,
    authority_type TEXT,
    max_amount DECIMAL(10,2),
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Duplicates Archive
CREATE TABLE IF NOT EXISTS duplicates_archive (
    archive_id SERIAL PRIMARY KEY,
    table_name TEXT,
    original_id TEXT,
    duplicate_id TEXT,
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    council_id INTEGER
);

-- Engineering Flow Tables
CREATE TABLE IF NOT EXISTS eng_leave_flow_verification (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    leave_request_id INTEGER,
    verification_status TEXT,
    verified_by TEXT,
    verified_at TIMESTAMP,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS eng_organization_chart (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    level INTEGER,
    parent_id TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS eng_positions_detailed (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    job_description TEXT,
    qualifications TEXT,
    responsibilities TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS eng_salary_scale_distribution (
    id SERIAL PRIMARY KEY,
    salary_scale TEXT,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS eng_staff_by_unit (
    id SERIAL PRIMARY KEY,
    unit_id INTEGER,
    staff_count INTEGER,
    report_date DATE,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS eng_summary_by_council (
    id SERIAL PRIMARY KEY,
    council_id INTEGER,
    total_staff INTEGER,
    total_units INTEGER,
    report_date DATE
);

-- Finance Flow Tables
CREATE TABLE IF NOT EXISTS finance_leave_flow_verification (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    leave_request_id INTEGER,
    verification_status TEXT,
    verified_by TEXT,
    verified_at TIMESTAMP,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS finance_org_chart (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    level INTEGER,
    parent_id TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS finance_positions_detailed (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    job_description TEXT,
    qualifications TEXT,
    responsibilities TEXT,
    financial_limit DECIMAL(10,2),
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS finance_salary_distribution (
    id SERIAL PRIMARY KEY,
    salary_scale TEXT,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS finance_staff_by_section (
    id SERIAL PRIMARY KEY,
    section_id INTEGER,
    staff_count INTEGER,
    report_date DATE,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS finance_summary_by_council (
    id SERIAL PRIMARY KEY,
    council_id INTEGER,
    total_staff INTEGER,
    total_sections INTEGER,
    total_units INTEGER,
    report_date DATE
);

-- Health Flow Tables
CREATE TABLE IF NOT EXISTS health_leave_flow_verification (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    leave_request_id INTEGER,
    verification_status TEXT,
    verified_by TEXT,
    verified_at TIMESTAMP,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS health_org_chart (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    level INTEGER,
    parent_id TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS health_positions_detailed (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    job_description TEXT,
    qualifications TEXT,
    responsibilities TEXT,
    professional_registration TEXT,
    specialty TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS health_salary_distribution (
    id SERIAL PRIMARY KEY,
    salary_scale TEXT,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS health_staff_by_unit (
    id SERIAL PRIMARY KEY,
    unit_id INTEGER,
    staff_count INTEGER,
    report_date DATE,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS health_summary_by_council (
    id SERIAL PRIMARY KEY,
    council_id INTEGER,
    total_staff INTEGER,
    total_units INTEGER,
    report_date DATE
);

-- HR Tables
CREATE TABLE IF NOT EXISTS hr_recipients (
    recipient_id SERIAL PRIMARY KEY,
    employee_standard_id TEXT UNIQUE,
    phone_number TEXT,
    email TEXT,
    is_active BOOLEAN DEFAULT TRUE,
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

-- Immutable Audit Log
CREATE TABLE IF NOT EXISTS immutable_audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    council_id INTEGER,
    period_date DATE NOT NULL,
    approved_by TEXT NOT NULL,
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_hash TEXT NOT NULL,
    payload TEXT,
    previous_hash TEXT,
    signature TEXT
);

-- Job Description Review
CREATE TABLE IF NOT EXISTS jd_review_queue (
    id SERIAL PRIMARY KEY,
    jd_id INTEGER,
    suggested_standard_id TEXT,
    confidence_score INTEGER,
    needs_review BOOLEAN DEFAULT TRUE,
    reviewed_by TEXT,
    review_date TIMESTAMP,
    approved BOOLEAN,
    notes TEXT
);

-- Leave Balances
CREATE TABLE IF NOT EXISTS leave_balances (
    balance_id SERIAL PRIMARY KEY,
    employee_standard_id TEXT,
    leave_type_id INTEGER,
    year INTEGER NOT NULL,
    days_entitled INTEGER,
    days_taken INTEGER DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS leave_resumption (
    resumption_id SERIAL PRIMARY KEY,
    leave_request_id INTEGER,
    resumed_date DATE,
    comments TEXT,
    recorded_by TEXT,
    council_id INTEGER
);

-- Legal Flow Tables
CREATE TABLE IF NOT EXISTS legal_leave_flow_verification (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    leave_request_id INTEGER,
    verification_status TEXT,
    verified_by TEXT,
    verified_at TIMESTAMP,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS legal_org_chart (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    level INTEGER,
    parent_id TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS legal_positions_detailed (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    job_description TEXT,
    qualifications TEXT,
    responsibilities TEXT,
    practicing_certificate BOOLEAN DEFAULT FALSE,
    specialization TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS legal_salary_distribution (
    id SERIAL PRIMARY KEY,
    salary_scale TEXT,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS legal_staff_by_section (
    id SERIAL PRIMARY KEY,
    section_id INTEGER,
    staff_count INTEGER,
    report_date DATE,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS legal_summary_by_council (
    id SERIAL PRIMARY KEY,
    council_id INTEGER,
    total_staff INTEGER,
    total_sections INTEGER,
    total_units INTEGER,
    report_date DATE
);

-- Mothers Day Tables
CREATE TABLE IF NOT EXISTS mothers_day_acknowledgments (
    acknowledgment_id SERIAL PRIMARY KEY,
    employee_standard_id TEXT,
    acknowledged_date DATE NOT NULL,
    acknowledged_by TEXT,
    notes TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mothers_day_notification_log (
    log_id SERIAL PRIMARY KEY,
    employee_standard_id TEXT,
    notification_type TEXT NOT NULL,
    sent_at TIMESTAMP,
    status TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications
CREATE TABLE IF NOT EXISTS notification_history (
    history_id SERIAL PRIMARY KEY,
    notification_id INTEGER,
    sent_at TIMESTAMP,
    delivery_status TEXT,
    error_message TEXT
);

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

-- Planning Flow Tables
CREATE TABLE IF NOT EXISTS planning_leave_flow_verification (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    leave_request_id INTEGER,
    verification_status TEXT,
    verified_by TEXT,
    verified_at TIMESTAMP,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS planning_management_structure (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    management_level INTEGER,
    reports_to TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS planning_org_chart (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    level INTEGER,
    parent_id TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS planning_positions_detailed (
    id SERIAL PRIMARY KEY,
    position_id TEXT,
    job_description TEXT,
    qualifications TEXT,
    responsibilities TEXT,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS planning_salary_distribution (
    id SERIAL PRIMARY KEY,
    salary_scale TEXT,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS planning_staff_by_unit (
    id SERIAL PRIMARY KEY,
    unit_id INTEGER,
    staff_count INTEGER,
    report_date DATE,
    council_id INTEGER
);

CREATE TABLE IF NOT EXISTS planning_summary_by_council (
    id SERIAL PRIMARY KEY,
    council_id INTEGER,
    total_staff INTEGER,
    total_units INTEGER,
    report_date DATE
);

-- Procurement
CREATE TABLE IF NOT EXISTS procurement_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_id INTEGER,
    head_position_id TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- SMS Tables
CREATE TABLE IF NOT EXISTS sms_delivery_log (
    log_id SERIAL PRIMARY KEY,
    part_id INTEGER,
    provider_response TEXT,
    delivered_at TIMESTAMP,
    status TEXT
);

CREATE TABLE IF NOT EXISTS sms_message_parts (
    part_id SERIAL PRIMARY KEY,
    recipient_phone TEXT NOT NULL,
    message_text TEXT NOT NULL,
    priority INTEGER DEFAULT 1,
    status TEXT DEFAULT 'PENDING',
    sent_at TIMESTAMP,
    error_message TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Vacation Allowances
CREATE TABLE IF NOT EXISTS vacation_allowances (
    allowance_id SERIAL PRIMARY KEY,
    employee_standard_id TEXT,
    year INTEGER,
    days_entitled INTEGER,
    days_taken INTEGER DEFAULT 0,
    council_id INTEGER
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_immutable_audit_council ON immutable_audit_log(council_id, period_date);
CREATE INDEX IF NOT EXISTS idx_leave_balances_employee ON leave_balances(employee_standard_id);
CREATE INDEX IF NOT EXISTS idx_notification_queue_status ON notification_queue(status);
