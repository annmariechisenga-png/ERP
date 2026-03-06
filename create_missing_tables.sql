-- Create tables that might be missing

-- Council types (already created)
-- Councils view (already created)

-- HRA tables
CREATE TABLE IF NOT EXISTS hra_leave_approval_chain (LIKE hra_leave_approval_chain INCLUDING ALL);
CREATE TABLE IF NOT EXISTS hra_leaveapprovalchains (LIKE hra_leaveapprovalchains INCLUDING ALL);
CREATE TABLE IF NOT EXISTS hra_position_attributes (LIKE hra_position_attributes INCLUDING ALL);
CREATE TABLE IF NOT EXISTS hra_position_supervisors (LIKE hra_position_supervisors INCLUDING ALL);
CREATE TABLE IF NOT EXISTS hra_reportinglines (LIKE hra_reportinglines INCLUDING ALL);
CREATE TABLE IF NOT EXISTS hra_supervision (LIKE hra_supervision INCLUDING ALL);

-- Finance tables
CREATE TABLE IF NOT EXISTS finance_sections (LIKE finance_sections INCLUDING ALL);
CREATE TABLE IF NOT EXISTS finance_units (LIKE finance_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS finance_leave_approval_chain (LIKE finance_leave_approval_chain INCLUDING ALL);
CREATE TABLE IF NOT EXISTS finance_supervision (LIKE finance_supervision INCLUDING ALL);

-- Legal tables
CREATE TABLE IF NOT EXISTS legal_sections (LIKE legal_sections INCLUDING ALL);
CREATE TABLE IF NOT EXISTS legal_units (LIKE legal_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS legal_leave_approval_chain (LIKE legal_leave_approval_chain INCLUDING ALL);
CREATE TABLE IF NOT EXISTS legal_supervision (LIKE legal_supervision INCLUDING ALL);

-- Health tables
CREATE TABLE IF NOT EXISTS health_sections (LIKE health_sections INCLUDING ALL);
CREATE TABLE IF NOT EXISTS health_units (LIKE health_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS health_leave_approval_chain (LIKE health_leave_approval_chain INCLUDING ALL);
CREATE TABLE IF NOT EXISTS health_supervision (LIKE health_supervision INCLUDING ALL);

-- Community tables
CREATE TABLE IF NOT EXISTS community_sections (LIKE community_sections INCLUDING ALL);
CREATE TABLE IF NOT EXISTS community_units (LIKE community_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS community_supervision (LIKE community_supervision INCLUDING ALL);

-- Engineering tables
CREATE TABLE IF NOT EXISTS eng_units (LIKE eng_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS eng_leave_approval_chain (LIKE eng_leave_approval_chain INCLUDING ALL);
CREATE TABLE IF NOT EXISTS eng_supervision (LIKE eng_supervision INCLUDING ALL);

-- Planning tables
CREATE TABLE IF NOT EXISTS planning_sections (LIKE planning_sections INCLUDING ALL);
CREATE TABLE IF NOT EXISTS planning_units (LIKE planning_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS planning_leave_approval_chain (LIKE planning_leave_approval_chain INCLUDING ALL);
CREATE TABLE IF NOT EXISTS planning_supervision (LIKE planning_supervision INCLUDING ALL);

-- ICT tables
CREATE TABLE IF NOT EXISTS ict_units (LIKE ict_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS ict_supervision (LIKE ict_supervision INCLUDING ALL);
CREATE TABLE IF NOT EXISTS ict_city_units (LIKE ict_city_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS ict_city_supervision (LIKE ict_city_supervision INCLUDING ALL);

-- Audit tables
CREATE TABLE IF NOT EXISTS audit_units (LIKE audit_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS audit_supervision (LIKE audit_supervision INCLUDING ALL);

-- Procurement tables
CREATE TABLE IF NOT EXISTS procurement_sections (LIKE procurement_sections INCLUDING ALL);
CREATE TABLE IF NOT EXISTS procurement_units (LIKE procurement_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS procurement_supervision (LIKE procurement_supervision INCLUDING ALL);

-- Commercial tables
CREATE TABLE IF NOT EXISTS commercial_units (LIKE commercial_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS commercial_supervision (LIKE commercial_supervision INCLUDING ALL);
CREATE TABLE IF NOT EXISTS commercial_city_units (LIKE commercial_city_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS commercial_city_supervision (LIKE commercial_city_supervision INCLUDING ALL);

-- COS/TOC tables
CREATE TABLE IF NOT EXISTS cos_units (LIKE cos_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS cos_supervision (LIKE cos_supervision INCLUDING ALL);
CREATE TABLE IF NOT EXISTS toc_units (LIKE toc_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS toc_supervision (LIKE toc_supervision INCLUDING ALL);
CREATE TABLE IF NOT EXISTS toc_city_units (LIKE toc_city_units INCLUDING ALL);
CREATE TABLE IF NOT EXISTS toc_city_supervision (LIKE toc_city_supervision INCLUDING ALL);

-- Valuation tables
CREATE TABLE IF NOT EXISTS valuation_city_supervision (LIKE valuation_city_supervision INCLUDING ALL);

-- Job description tables
CREATE TABLE IF NOT EXISTS job_description_documents (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT,
    original_filename TEXT,
    file_path TEXT,
    file_type TEXT,
    position_title TEXT,
    grade TEXT,
    department TEXT,
    council_id INTEGER,
    reports_to_standard_id TEXT,
    version INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT TRUE,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS jd_upload_queue (
    id SERIAL PRIMARY KEY,
    filename TEXT,
    file_path TEXT,
    upload_status TEXT DEFAULT 'pending',
    extracted_title TEXT,
    suggested_standard_id TEXT,
    confidence_score INTEGER,
    needs_review BOOLEAN DEFAULT TRUE,
    uploaded_by TEXT,
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- SMS gateway tables
CREATE TABLE IF NOT EXISTS sms_gateway_config (
    config_id SERIAL PRIMARY KEY,
    provider_name TEXT NOT NULL,
    api_url TEXT,
    api_key TEXT,
    sender_id TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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

CREATE TABLE IF NOT EXISTS sms_delivery_log (
    log_id SERIAL PRIMARY KEY,
    part_id INTEGER,
    provider_response TEXT,
    delivered_at TIMESTAMP,
    status TEXT
);

-- Mothers Day tables
CREATE TABLE IF NOT EXISTS mothers_day_leave_tracking (
    tracking_id SERIAL PRIMARY KEY,
    employee_id TEXT,
    leave_date DATE NOT NULL,
    status TEXT DEFAULT 'PENDING',
    approved_by TEXT,
    approved_at TIMESTAMP,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mothers_day_acknowledgments (
    acknowledgment_id SERIAL PRIMARY KEY,
    employee_id TEXT,
    acknowledged_date DATE NOT NULL,
    acknowledged_by TEXT,
    notes TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS mothers_day_notification_log (
    log_id SERIAL PRIMARY KEY,
    employee_id TEXT,
    notification_type TEXT NOT NULL,
    sent_at TIMESTAMP,
    status TEXT,
    council_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
