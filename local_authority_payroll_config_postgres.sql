-- ===================================================
-- LOCAL AUTHORITY-SPECIFIC PAYROLL CONFIGURATION
-- PostgreSQL Migration
-- ===================================================

-- 1. LOCAL AUTHORITIES TABLE (Enhanced)
CREATE TABLE IF NOT EXISTS local_authorities (
    authority_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code VARCHAR(20) UNIQUE NOT NULL,
    authority_name VARCHAR(200) NOT NULL,

    payroll_cycle VARCHAR(20) DEFAULT 'MONTHLY',
    standard_pay_day INTEGER,
    pay_day_frequency VARCHAR(20),

    allows_split_payment BOOLEAN DEFAULT FALSE,
    grace_period_days INTEGER DEFAULT 0,
    max_pay_delay_days INTEGER DEFAULT 5,

    annual_payroll_budget DECIMAL(15,2),
    current_cash_position DECIMAL(15,2),
    last_payroll_date DATE,
    next_payroll_date DATE,

    payroll_bank_account VARCHAR(50),
    payroll_bank_branch VARCHAR(100),

    payroll_contact_name VARCHAR(200),
    payroll_contact_email VARCHAR(100),
    payroll_contact_phone VARCHAR(20),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO local_authorities (authority_code, authority_name, standard_pay_day)
VALUES
('KTC', 'Kafue Town Council', 25),
('LCC', 'Lusaka City Council', 28),
('NDC', 'Ndola City Council', 20),
('MTC', 'Mongu Town Council', 15)
ON CONFLICT (authority_code) DO NOTHING;

-- 2. PAYROLL_SCHEDULES (Per Authority)
CREATE TABLE IF NOT EXISTS payroll_schedules (
    schedule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id UUID REFERENCES local_authorities(authority_id),
    period_year INTEGER NOT NULL,
    period_month INTEGER NOT NULL,

    payroll_cutoff_date DATE,
    processing_start_date DATE,
    processing_end_date DATE,
    payslip_generation_date DATE,
    scheduled_payment_date DATE,

    actual_payslip_date DATE,
    actual_payment_date DATE,

    status VARCHAR(20) DEFAULT 'SCHEDULED',
    delay_reason TEXT,

    UNIQUE(authority_id, period_year, period_month)
);

-- 3. PAYROLL_RUN (Now tied to authority schedule)
CREATE TABLE IF NOT EXISTS payroll_run (
    payroll_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    schedule_id UUID REFERENCES payroll_schedules(schedule_id),
    authority_id UUID REFERENCES local_authorities(authority_id),
    officer_id UUID REFERENCES officers(officer_id),

    payslip_number VARCHAR(50) UNIQUE NOT NULL,
    document_verification_code VARCHAR(50) UNIQUE NOT NULL,

    payslip_available_date TIMESTAMP WITH TIME ZONE,
    payslip_viewed_date TIMESTAMP WITH TIME ZONE,
    payslip_delivery_method VARCHAR(50),

    payment_due_date DATE,
    payment_actual_date DATE,
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    payment_reference VARCHAR(100),

    basic_salary DECIMAL(10,2),
    total_allowances DECIMAL(10,2),
    total_deductions DECIMAL(10,2),
    net_pay DECIMAL(10,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(schedule_id, officer_id)
);

-- 4. PAYMENT_BATCHES (For bank files)
CREATE TABLE IF NOT EXISTS payment_batches (
    batch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id UUID REFERENCES local_authorities(authority_id),
    schedule_id UUID REFERENCES payroll_schedules(schedule_id),

    batch_reference VARCHAR(100) UNIQUE NOT NULL,
    batch_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    employee_count INTEGER NOT NULL,

    bank_file_generated_at TIMESTAMP,
    bank_file_sent_at TIMESTAMP,
    bank_confirmation_received BOOLEAN DEFAULT FALSE,
    bank_confirmation_date TIMESTAMP,
    bank_rejection_reason TEXT,

    status VARCHAR(20) DEFAULT 'CREATED'
);

-- 5. PAYSLIP_ACCESS_LOG (Audit trail)
CREATE TABLE IF NOT EXISTS payslip_access_log (
    access_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payroll_id UUID REFERENCES payroll_run(payroll_id),
    officer_id UUID REFERENCES officers(officer_id),

    access_type VARCHAR(20),
    access_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    access_ip INET,
    access_device VARCHAR(200),

    delivery_confirmation BOOLEAN DEFAULT FALSE,
    delivery_confirmation_time TIMESTAMP
);

-- 6. PAYMENT DELAY APPROVALS (Cash flow exceptions)
CREATE TABLE IF NOT EXISTS payment_delay_approvals (
    delay_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id UUID REFERENCES local_authorities(authority_id),
    schedule_id UUID REFERENCES payroll_schedules(schedule_id),
    delay_days INTEGER NOT NULL,
    reason TEXT NOT NULL,
    approved_by VARCHAR(200),
    approval_date DATE,
    payslips_issued_on_time BOOLEAN DEFAULT FALSE,
    notification_sent_to_employees BOOLEAN DEFAULT FALSE,
    notification_date DATE
);

-- 6. VIEW TO MONITOR PAYROLL STATUS ACROSS ALL AUTHORITIES
CREATE OR REPLACE VIEW v_payroll_compliance AS
SELECT
    la.authority_code,
    la.authority_name,
    ps.period_year,
    ps.period_month,
    ps.scheduled_payment_date,
    ps.payslip_generation_date,
    ps.actual_payslip_date,
    ps.actual_payment_date,
    ps.status,
    CASE
        WHEN ps.actual_payslip_date IS NULL THEN 'NO_PAYSLIPS'
        WHEN ps.actual_payslip_date <= ps.payslip_generation_date THEN 'COMPLIANT'
        WHEN ps.actual_payslip_date <= ps.scheduled_payment_date THEN 'LATE_PAYSLIPS_BUT_BEFORE_PAYMENT'
        WHEN ps.actual_payslip_date > ps.scheduled_payment_date THEN 'PAYSLIPS_AFTER_PAYMENT - VIOLATION'
        ELSE 'UNKNOWN'
    END AS compliance_status,
    CASE
        WHEN ps.actual_payment_date IS NULL THEN 'NOT_PAID'
        WHEN ps.actual_payment_date <= ps.scheduled_payment_date THEN 'PAID_ON_TIME'
        WHEN ps.actual_payment_date > ps.scheduled_payment_date THEN 'PAID_LATE'
    END AS payment_timeliness,
    EXTRACT(DAY FROM (ps.actual_payment_date - ps.scheduled_payment_date)) AS days_late,
    (SELECT COUNT(*) FROM payroll_run pr WHERE pr.schedule_id = ps.schedule_id) AS employee_count,
    (SELECT SUM(net_pay) FROM payroll_run pr WHERE pr.schedule_id = ps.schedule_id) AS total_payroll
FROM payroll_schedules ps
JOIN local_authorities la ON ps.authority_id = la.authority_id
ORDER BY ps.scheduled_payment_date;

-- 7. TRIGGER TO PREVENT PAYMENT WITHOUT PAYSLIP
CREATE OR REPLACE FUNCTION trg_prevent_payment_without_payslip()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment_status IN ('PROCESSED', 'PAID') THEN
        IF NEW.payslip_available_date IS NULL THEN
            RAISE EXCEPTION 'Cannot process payment: Payslip not yet generated';
        END IF;

        IF NEW.payment_due_date IS NOT NULL
           AND NEW.payslip_available_date::DATE > NEW.payment_due_date THEN
            RAISE WARNING 'Payslip generated after payment due date: % > %',
                NEW.payslip_available_date::DATE, NEW.payment_due_date;
        END IF;

        -- Check: late payments require an approval that covers the actual delay days
        IF NEW.payment_status = 'PAID'
           AND NEW.payment_due_date IS NOT NULL
           AND COALESCE(NEW.payment_actual_date, CURRENT_DATE) > NEW.payment_due_date THEN
            IF NEW.schedule_id IS NULL OR NOT EXISTS (
                SELECT 1
                FROM payment_delay_approvals pda
                WHERE pda.schedule_id = NEW.schedule_id
                  AND (NEW.authority_id IS NULL OR pda.authority_id = NEW.authority_id)
                  -- approved delay_days must cover the actual calendar days late
                  AND pda.delay_days >= (COALESCE(NEW.payment_actual_date, CURRENT_DATE) - NEW.payment_due_date)
                  AND btrim(COALESCE(pda.reason, '')) <> ''
                  AND btrim(COALESCE(pda.approved_by, '')) <> ''
                  AND pda.approval_date IS NOT NULL
                  AND pda.payslips_issued_on_time IS NOT NULL
                  AND pda.notification_sent_to_employees = TRUE
                  AND pda.notification_date IS NOT NULL
            ) THEN
                RAISE EXCEPTION 'Cannot mark delayed payment as PAID: an approved delay covering the actual delay days, plus employee notification, is required';
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS payroll_payment_check ON payroll_run;
CREATE TRIGGER payroll_payment_check
    BEFORE UPDATE ON payroll_run
    FOR EACH ROW
    EXECUTE FUNCTION trg_prevent_payment_without_payslip();

-- ===================================================
-- 8. MONTHLY COMPLIANCE REPORT (Ministry of Local Government)
-- ===================================================
CREATE OR REPLACE FUNCTION generate_compliance_report(
    p_year  INTEGER,
    p_month INTEGER
) RETURNS TABLE (
    authority_name      VARCHAR,
    pay_day             INTEGER,
    payment_date        DATE,
    payslip_date        DATE,
    compliant           BOOLEAN,
    violation_details   TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        la.authority_name,
        la.standard_pay_day,
        ps.scheduled_payment_date,
        ps.payslip_generation_date,
        -- compliant only when payslips were issued on or before the scheduled generation date
        (ps.actual_payslip_date IS NOT NULL
         AND ps.actual_payslip_date <= ps.payslip_generation_date) AS compliant,
        CASE
            WHEN ps.actual_payslip_date IS NULL
                THEN 'No payslips generated'
            WHEN ps.actual_payslip_date > ps.scheduled_payment_date
                THEN 'PAYSLIPS AFTER PAYMENT - VIOLATION'
            WHEN ps.actual_payslip_date > ps.payslip_generation_date
                 AND ps.actual_payslip_date <= ps.scheduled_payment_date
                THEN 'Late payslips but before payment'
            ELSE 'Compliant'
        END AS violation_details
    FROM payroll_schedules ps
    JOIN local_authorities la ON ps.authority_id = la.authority_id
    WHERE ps.period_year = p_year
      AND ps.period_month = p_month
    ORDER BY la.standard_pay_day;
END;
$$ LANGUAGE plpgsql;

-- ===================================================
-- 9. CENTRAL COMPLIANCE HUB ARCHITECTURE
-- Local Authorities process payments; central office tracks compliance.
-- ===================================================

-- 9a. LA-SPECIFIC PAYROLL CONFIGURATION (minimal; compliance deadlines only)
CREATE TABLE IF NOT EXISTS la_payroll_config (
    config_id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id                UUID REFERENCES local_authorities(authority_id),
    -- Compliance deadlines (days into the following month)
    payslip_submission_deadline INTEGER NOT NULL DEFAULT 5,
    payroll_data_deadline       INTEGER NOT NULL DEFAULT 7,
    compliance_officer_name     VARCHAR(200),
    compliance_officer_email    VARCHAR(100),
    compliance_officer_phone    VARCHAR(20),
    created_at                  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(authority_id)
);

-- 9b. LA PAYROLL SUBMISSIONS (what LAs send to the central office)
CREATE TABLE IF NOT EXISTS la_payroll_submissions (
    submission_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id            UUID REFERENCES local_authorities(authority_id),
    period_year             INTEGER NOT NULL,
    period_month            INTEGER NOT NULL,
    la_payroll_date         DATE,            -- When the LA actually paid staff
    submission_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    submission_status       VARCHAR(20) DEFAULT 'PENDING',  -- PENDING | VALIDATED | REJECTED
    payroll_data            JSONB NOT NULL,  -- Full payroll run from the LA
    compliance_check_passed BOOLEAN,
    compliance_check_notes  TEXT,
    compliance_officer_id   UUID,
    compliance_check_date   TIMESTAMP,
    UNIQUE(authority_id, period_year, period_month)
);

-- 9c. COMPLIANCE ISSUES TRACKING
CREATE TABLE IF NOT EXISTS compliance_issues (
    issue_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id        UUID REFERENCES local_authorities(authority_id),
    submission_id       UUID REFERENCES la_payroll_submissions(submission_id),
    issue_type          VARCHAR(50)  NOT NULL,  -- LATE_SUBMISSION | MISSING_DATA | CALCULATION_ERROR
    issue_severity      VARCHAR(20),            -- WARNING | MINOR | MAJOR | CRITICAL
    issue_description   TEXT NOT NULL,
    -- Late-submission fields
    days_late           INTEGER,
    deadline_date       DATE,
    submission_date     DATE,
    -- Calculation-error fields
    affected_employees  INTEGER,
    total_discrepancy   DECIMAL(15,2),
    -- Resolution
    resolution_status   VARCHAR(20) DEFAULT 'OPEN',  -- OPEN | IN_PROGRESS | RESOLVED
    resolution_notes    TEXT,
    resolved_by         UUID,
    resolved_date       TIMESTAMP,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9d. CENTRALISED PAYSLIP ARCHIVE (read-only view derived from LA submissions)
CREATE TABLE IF NOT EXISTS central_payslip_archive (
    archive_id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id            UUID REFERENCES local_authorities(authority_id),
    submission_id           UUID REFERENCES la_payroll_submissions(submission_id),
    officer_id              UUID,            -- Shared reference across LAs if applicable
    employee_number         VARCHAR(50),
    employee_name           VARCHAR(200),
    period_year             INTEGER NOT NULL,
    period_month            INTEGER NOT NULL,
    -- Key pay figures for compliance analytics
    basic_salary            DECIMAL(10,2),
    housing_allowance       DECIMAL(10,2),
    total_allowances        DECIMAL(10,2),
    total_deductions        DECIMAL(10,2),
    net_pay                 DECIMAL(10,2),
    -- Statutory compliance
    paye_amount             DECIMAL(10,2),
    napsa_amount            DECIMAL(10,2),
    nhis_amount             DECIMAL(10,2),
    -- Leave compliance
    leave_earned            DECIMAL(5,2),
    leave_taken             DECIMAL(5,2),
    leave_balance           DECIMAL(5,2),
    -- Dates
    payment_date            DATE,
    payslip_generated_date  DATE,
    -- Full payslip for reference
    payslip_data            JSONB,
    archived_at             TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_cpa_authority_period
    ON central_payslip_archive(authority_id, period_year, period_month);
CREATE INDEX IF NOT EXISTS idx_cpa_employee
    ON central_payslip_archive(employee_number);

-- 9e. CENTRAL COMPLIANCE SUMMARY VIEW
CREATE OR REPLACE VIEW v_central_compliance_summary AS
SELECT
    la.authority_code,
    la.authority_name,
    lps.period_year,
    lps.period_month,
    lps.la_payroll_date,
    lps.submission_date::DATE           AS submitted_on,
    lps.submission_status,
    lps.compliance_check_passed,
    cfg.payslip_submission_deadline,
    cfg.payroll_data_deadline,
    -- Days between LA pay date and central submission
    CASE
        WHEN lps.la_payroll_date IS NOT NULL AND lps.submission_date IS NOT NULL
        THEN (lps.submission_date::DATE - lps.la_payroll_date)
    END AS days_to_submission,
    (SELECT COUNT(*) FROM compliance_issues ci
     WHERE ci.submission_id = lps.submission_id) AS open_issues,
    (SELECT COUNT(*) FROM central_payslip_archive cpa
     WHERE cpa.submission_id = lps.submission_id) AS archived_payslips
FROM la_payroll_submissions lps
JOIN local_authorities la ON lps.authority_id = la.authority_id
LEFT JOIN la_payroll_config cfg ON cfg.authority_id = lps.authority_id
ORDER BY lps.period_year, lps.period_month, la.authority_name;

-- ===================================================
-- 10. COMPLIANCE FUNCTIONS
-- ===================================================

-- 10a. TRACK LATE SUBMISSIONS
CREATE OR REPLACE FUNCTION check_late_submissions(
    p_year  INTEGER,
    p_month INTEGER
) RETURNS TABLE (
    authority_name  VARCHAR,
    deadline_date   DATE,
    submission_date DATE,
    days_late       INTEGER,
    issue_created   BOOLEAN
) AS $$
DECLARE
    v_deadline   DATE := make_date(p_year, p_month, 5);  -- 5th of the reported month
    v_submission RECORD;
BEGIN
    FOR v_submission IN
        SELECT
            la.authority_name,
            lps.submission_date::DATE AS sub_date,
            lps.submission_id,
            lps.authority_id
        FROM la_payroll_submissions lps
        JOIN local_authorities la ON lps.authority_id = la.authority_id
        WHERE lps.period_year = p_year
          AND lps.period_month = p_month
    LOOP
        authority_name  := v_submission.authority_name;
        deadline_date   := v_deadline;
        submission_date := v_submission.sub_date;
        days_late       := GREATEST(0, v_submission.sub_date - v_deadline);

        IF days_late > 0 THEN
            INSERT INTO compliance_issues (
                authority_id, submission_id, issue_type, issue_severity,
                issue_description, days_late, deadline_date, submission_date
            ) VALUES (
                v_submission.authority_id,
                v_submission.submission_id,
                'LATE_SUBMISSION',
                CASE
                    WHEN days_late <= 5  THEN 'MINOR'
                    WHEN days_late <= 15 THEN 'MAJOR'
                    ELSE 'CRITICAL'
                END,
                'Payroll data submitted ' || days_late || ' days late',
                days_late, v_deadline, v_submission.sub_date
            ) ON CONFLICT DO NOTHING;
            issue_created := TRUE;
        ELSE
            issue_created := FALSE;
        END IF;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 10b. VALIDATE PAYSLIP TIMING (payslip must precede payment)
CREATE OR REPLACE FUNCTION validate_payslip_timing(
    p_authority_id  UUID,
    p_submission_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_payment_date      DATE;
    v_payslip_generated DATE;
    v_violation         BOOLEAN := FALSE;
BEGIN
    SELECT
        (payroll_data->>'payment_date')::DATE,
        (payroll_data->>'payslip_generated_date')::DATE
    INTO v_payment_date, v_payslip_generated
    FROM la_payroll_submissions
    WHERE submission_id = p_submission_id;

    IF v_payslip_generated > v_payment_date THEN
        INSERT INTO compliance_issues (
            authority_id, submission_id, issue_type, issue_severity,
            issue_description
        ) VALUES (
            p_authority_id, p_submission_id,
            'PAYSLIP_AFTER_PAYMENT', 'CRITICAL',
            'Payslip generated on ' || v_payslip_generated ||
            ' but payment was on ' || v_payment_date ||
            ' - VIOLATION OF SECTION 105'
        );
        v_violation := TRUE;
    END IF;

    RETURN NOT v_violation;
END;
$$ LANGUAGE plpgsql;

-- 10c. GENERATE MINISTRY COMPLIANCE REPORT (returns JSONB)
CREATE OR REPLACE FUNCTION generate_ministry_compliance_report(
    p_year  INTEGER,
    p_month INTEGER
) RETURNS JSONB AS $$
DECLARE
    v_report        JSONB;
    v_period_start  DATE := make_date(p_year, p_month, 1);
    v_period_end    DATE := make_date(p_year, p_month, 1) + INTERVAL '1 month';
    v_deadline      DATE := make_date(p_year, p_month, 5);
BEGIN
    -- Auto-run late submission check first
    PERFORM check_late_submissions(p_year, p_month);

    SELECT jsonb_build_object(
        'report_period',     p_year || '-' || LPAD(p_month::TEXT, 2, '0'),
        'generated_at',      CURRENT_TIMESTAMP,
        'total_authorities', (SELECT COUNT(*) FROM local_authorities WHERE is_active = TRUE),
        'submitted_on_time', (
            SELECT COUNT(*) FROM la_payroll_submissions lps
            WHERE lps.period_year = p_year AND lps.period_month = p_month
              AND lps.submission_date::DATE <= v_deadline
        ),
        'submitted_late', (
            SELECT COUNT(*) FROM la_payroll_submissions lps
            WHERE lps.period_year = p_year AND lps.period_month = p_month
              AND lps.submission_date::DATE > v_deadline
        ),
        'not_submitted', (
            SELECT COUNT(*) FROM local_authorities la
            WHERE la.is_active = TRUE
              AND NOT EXISTS (
                SELECT 1 FROM la_payroll_submissions lps
                WHERE lps.authority_id = la.authority_id
                  AND lps.period_year  = p_year
                  AND lps.period_month = p_month
              )
        ),
        'critical_issues', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object(
                'authority', la.authority_name,
                'issue',     ci.issue_description,
                'severity',  ci.issue_severity
            )), '[]'::JSONB)
            FROM compliance_issues ci
            JOIN local_authorities la ON ci.authority_id = la.authority_id
            WHERE ci.issue_severity     = 'CRITICAL'
              AND ci.resolution_status  = 'OPEN'
              AND ci.created_at::DATE  >= v_period_start
              AND ci.created_at::DATE   < v_period_end
        ),
        'summary', 'Compliance monitoring complete - ' || (
            SELECT COUNT(*) FROM compliance_issues
            WHERE created_at::DATE >= v_period_start
              AND created_at::DATE  < v_period_end
        ) || ' issues identified'
    ) INTO v_report;

    RETURN v_report;
END;
$$ LANGUAGE plpgsql;

-- ===================================================
-- 11. TEAM COMPLIANCE DASHBOARD VIEW
-- Always shows the current calendar month.
-- ===================================================
CREATE OR REPLACE VIEW v_compliance_dashboard AS
SELECT
    la.authority_name,
    la.authority_code,
    COUNT(DISTINCT lps.submission_id)                                      AS submissions,
    COUNT(DISTINCT ci.issue_id)                                            AS open_issues,
    MAX(CASE WHEN ci.issue_severity = 'CRITICAL' THEN 1 ELSE 0 END)       AS has_critical,
    ROUND(
        AVG(CASE WHEN ci.issue_type = 'LATE_SUBMISSION' THEN ci.days_late ELSE NULL END)::NUMERIC,
    1)                                                                     AS avg_days_late,
    COALESCE(SUM(cpa.net_pay), 0)                                          AS total_payroll_processed,
    lps.period_year,
    lps.period_month
FROM local_authorities la
LEFT JOIN la_payroll_submissions lps
       ON la.authority_id  = lps.authority_id
      AND lps.period_year  = EXTRACT(YEAR  FROM CURRENT_DATE)
      AND lps.period_month = EXTRACT(MONTH FROM CURRENT_DATE)
LEFT JOIN compliance_issues ci
       ON lps.submission_id      = ci.submission_id
      AND ci.resolution_status   = 'OPEN'
LEFT JOIN central_payslip_archive cpa
       ON lps.submission_id = cpa.submission_id
GROUP BY la.authority_name, la.authority_code, lps.period_year, lps.period_month
ORDER BY has_critical DESC, open_issues DESC, la.authority_name;

-- ============================================================
-- §12  HARDSHIP ALLOWANCE CONTROL SYSTEM
--      Central designation of eligible stations
--      Collective Agreement – hardship allowance eligibility
-- ============================================================

-- 1. Official station classification (maintained by Ministry)
CREATE TABLE IF NOT EXISTS station_hardship_classification (
    classification_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id          UUID REFERENCES local_authorities(authority_id),

    -- Only one designation flag may be TRUE at a time
    is_remote_hardship    BOOLEAN DEFAULT FALSE,
    is_rural_hardship     BOOLEAN DEFAULT FALSE,

    -- Effective dates
    designated_from       DATE NOT NULL,
    designated_to         DATE,
    is_current            BOOLEAN DEFAULT TRUE,

    -- Official circular reference
    circular_reference    VARCHAR(100) NOT NULL,
    circular_date         DATE NOT NULL,
    circular_document_url VARCHAR(500),

    -- Criteria met (from Collective Agreement)
    criteria_met          JSONB,   -- e.g. '["Banking >50km","No all-weather roads"]'

    -- Approval
    approved_by           VARCHAR(200),  -- Permanent Secretary
    approval_date         DATE,

    -- Audit
    created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by            UUID,

    -- Mutual exclusivity
    CHECK (NOT (is_remote_hardship AND is_rural_hardship)),
    -- Only one active designation per authority
    UNIQUE (authority_id, is_current)
);

-- 2. Historical tracking (when designations change)
CREATE TABLE IF NOT EXISTS station_hardship_history (
    history_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_id          UUID REFERENCES local_authorities(authority_id),

    previous_designation  VARCHAR(50),
    new_designation       VARCHAR(50),
    change_reason         TEXT,
    circular_reference    VARCHAR(100),
    effective_date        DATE,

    changed_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by            UUID
);

CREATE INDEX IF NOT EXISTS idx_shc_authority  ON station_hardship_classification(authority_id);
CREATE INDEX IF NOT EXISTS idx_shc_current    ON station_hardship_classification(is_current);
CREATE INDEX IF NOT EXISTS idx_shh_authority  ON station_hardship_history(authority_id);

-- Maintain updated_at automatically
CREATE OR REPLACE FUNCTION fn_shc_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_shc_updated_at ON station_hardship_classification;
CREATE TRIGGER trg_shc_updated_at
    BEFORE UPDATE ON station_hardship_classification
    FOR EACH ROW EXECUTE FUNCTION fn_shc_updated_at();

-- Auto-populate history when is_current flipped to FALSE
CREATE OR REPLACE FUNCTION fn_shc_history_on_change()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.is_current = TRUE AND NEW.is_current = FALSE THEN
        INSERT INTO station_hardship_history
            (authority_id, previous_designation, new_designation,
             change_reason, circular_reference, effective_date)
        VALUES (
            OLD.authority_id,
            CASE WHEN OLD.is_remote_hardship THEN 'REMOTE_HARDSHIP'
                 WHEN OLD.is_rural_hardship   THEN 'RURAL_HARDSHIP'
                 ELSE 'NONE' END,
            'NONE',
            'Superseded by new designation',
            OLD.circular_reference,
            CURRENT_DATE
        );
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_shc_history_on_change ON station_hardship_classification;
CREATE TRIGGER trg_shc_history_on_change
    AFTER UPDATE OF is_current ON station_hardship_classification
    FOR EACH ROW EXECUTE FUNCTION fn_shc_history_on_change();

-- 3. Seed with official designations (real authority codes)
INSERT INTO station_hardship_classification
    (authority_id, is_remote_hardship, is_rural_hardship,
     designated_from, circular_reference, circular_date, criteria_met)
SELECT authority_id, TRUE, FALSE,
       '2025-01-01', 'MLGRD/CIR/01/2025', '2025-01-15',
       '["Banking facilities >50km", "No all-weather roads"]'::jsonb
FROM local_authorities WHERE authority_code = 'MTC'   -- Mongu Town Council (remote)
ON CONFLICT DO NOTHING;

INSERT INTO station_hardship_classification
    (authority_id, is_remote_hardship, is_rural_hardship,
     designated_from, circular_reference, circular_date, criteria_met)
SELECT authority_id, FALSE, TRUE,
       '2025-01-01', 'MLGRD/CIR/01/2025', '2025-01-15',
       '["No electricity", "No piped water"]'::jsonb
FROM local_authorities WHERE authority_code = 'KTC'   -- Kafue Town Council (rural)
ON CONFLICT DO NOTHING;

-- ============================================================
-- §13  HARDSHIP ELIGIBILITY + CLAIM VALIDATION
-- ============================================================

-- 4. View for LAs - show only officially allowed options
DROP VIEW IF EXISTS la_hardship_eligibility;
CREATE VIEW la_hardship_eligibility AS
SELECT
    la.authority_id,
    la.authority_code,
    la.authority_name,
    shc.is_remote_hardship,
    shc.is_rural_hardship,
    shc.circular_reference,
    shc.designated_from,
    shc.criteria_met
FROM local_authorities la
LEFT JOIN station_hardship_classification shc
       ON la.authority_id = shc.authority_id
      AND shc.is_current = TRUE
WHERE shc.authority_id IS NOT NULL;

-- 5. Payroll calculation - auto-applies based on official designation
CREATE OR REPLACE FUNCTION calculate_hardship_allowance(
    p_authority_id UUID,
    p_basic_salary DECIMAL
) RETURNS TABLE (
    allowance_code VARCHAR,
    allowance_name VARCHAR,
    amount DECIMAL,
    rate DECIMAL,
    designation_type VARCHAR
) AS $$
DECLARE
    v_is_remote BOOLEAN;
    v_is_rural  BOOLEAN;
BEGIN
    SELECT is_remote_hardship, is_rural_hardship
      INTO v_is_remote, v_is_rural
      FROM station_hardship_classification
     WHERE authority_id = p_authority_id
       AND is_current = TRUE;

    IF v_is_remote THEN
        RETURN QUERY
        SELECT
            'REMOTE'::VARCHAR,
            'Remote Hardship Allowance'::VARCHAR,
            p_basic_salary * 0.25,
            25.00,
            'REMOTE'::VARCHAR;
    ELSIF v_is_rural THEN
        RETURN QUERY
        SELECT
            'RURAL'::VARCHAR,
            'Rural Hardship Allowance'::VARCHAR,
            p_basic_salary * 0.20,
            20.00,
            'RURAL'::VARCHAR;
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

-- 6. LA submission validation - prevents hardship claim fraud
CREATE OR REPLACE FUNCTION validate_hardship_claims(
    p_submission_id UUID
) RETURNS JSONB AS $$
DECLARE
    v_authority_id       UUID;
    v_claiming_remote    INTEGER;
    v_claiming_rural     INTEGER;
    v_authorized_remote  BOOLEAN;
    v_authorized_rural   BOOLEAN;
    v_violations         JSONB := '[]'::JSONB;
BEGIN
    SELECT authority_id INTO v_authority_id
      FROM la_payroll_submissions
     WHERE submission_id = p_submission_id;

    SELECT is_remote_hardship, is_rural_hardship
      INTO v_authorized_remote, v_authorized_rural
      FROM station_hardship_classification
     WHERE authority_id = v_authority_id
       AND is_current = TRUE;

    IF NOT COALESCE(v_authorized_remote, FALSE) THEN
        SELECT COUNT(*) INTO v_claiming_remote
          FROM central_payslip_archive
         WHERE submission_id = p_submission_id
           AND payslip_data::text ILIKE '%REMOTE%';

        IF v_claiming_remote > 0 THEN
            v_violations := v_violations || jsonb_build_object(
                'issue', 'UNAUTHORIZED_REMOTE_CLAIM',
                'description', 'Claimed Remote Hardship for ' || v_claiming_remote || ' employees but not designated',
                'severity', 'CRITICAL'
            );
        END IF;
    END IF;

    IF NOT COALESCE(v_authorized_rural, FALSE) THEN
        SELECT COUNT(*) INTO v_claiming_rural
          FROM central_payslip_archive
         WHERE submission_id = p_submission_id
           AND payslip_data::text ILIKE '%RURAL%';

        IF v_claiming_rural > 0 THEN
            v_violations := v_violations || jsonb_build_object(
                'issue', 'UNAUTHORIZED_RURAL_CLAIM',
                'description', 'Claimed Rural Hardship for ' || v_claiming_rural || ' employees but not designated',
                'severity', 'CRITICAL'
            );
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'passed', jsonb_array_length(v_violations) = 0,
        'violations', v_violations
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- §14  LA PAYROLL DASHBOARD (READ-ONLY HARDSHIP DESIGNATION)
-- ============================================================

-- Session helper: application sets per connection, e.g.
--   SET app.current_la_id = '<authority-uuid>';
CREATE OR REPLACE FUNCTION current_la_id()
RETURNS UUID
LANGUAGE SQL
STABLE
AS $$
    SELECT NULLIF(current_setting('app.current_la_id', true), '')::UUID;
$$;

DROP VIEW IF EXISTS la_payroll_dashboard;
CREATE VIEW la_payroll_dashboard AS
SELECT
    la.authority_code,
    la.authority_name,
    CASE
        WHEN shc.is_remote_hardship THEN 'REMOTE HARDSHIP (25%) - Designated'
        WHEN shc.is_rural_hardship  THEN 'RURAL HARDSHIP (20%) - Designated'
        ELSE 'NO HARDSHIP ALLOWANCE - Not designated'
    END AS hardship_status,
    shc.circular_reference,
    shc.designated_from,
    shc.criteria_met,
    'This is your official designation from Ministry Circular '
        || COALESCE(shc.circular_reference, 'N/A') AS notice
FROM local_authorities la
LEFT JOIN station_hardship_classification shc
       ON la.authority_id = shc.authority_id
      AND shc.is_current = TRUE
WHERE la.authority_id = current_la_id();

-- ============================================================
-- §15  MINISTRY HARDSHIP ALLOWANCE COMPLIANCE REPORT
-- ============================================================

CREATE OR REPLACE FUNCTION hardship_compliance_report(
    p_year INTEGER,
    p_month INTEGER
) RETURNS TABLE (
    authority_name VARCHAR,
    official_designation VARCHAR,
    employees_claiming INTEGER,
    total_amount DECIMAL,
    compliant BOOLEAN,
    violation_details TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH base AS (
        SELECT
            la.authority_id,
            la.authority_name,
            COALESCE(shc.is_remote_hardship, FALSE) AS is_remote_hardship,
            COALESCE(shc.is_rural_hardship,  FALSE) AS is_rural_hardship,
            cpa.officer_id,
            COALESCE(cpa.total_allowances, 0) AS total_allowances,
            CASE WHEN cpa.payslip_data::text ILIKE '%REMOTE%' THEN 1 ELSE 0 END AS has_remote_claim,
            CASE WHEN cpa.payslip_data::text ILIKE '%RURAL%'  THEN 1 ELSE 0 END AS has_rural_claim
        FROM la_payroll_submissions lps
        JOIN central_payslip_archive cpa
          ON lps.submission_id = cpa.submission_id
        JOIN local_authorities la
          ON lps.authority_id = la.authority_id
        LEFT JOIN station_hardship_classification shc
          ON la.authority_id = shc.authority_id
         AND shc.is_current = TRUE
        WHERE lps.period_year = p_year
          AND lps.period_month = p_month
    ), agg AS (
        SELECT
            authority_name,
            MAX(is_remote_hardship::int)::boolean AS is_remote_hardship,
            MAX(is_rural_hardship::int)::boolean  AS is_rural_hardship,
            COUNT(DISTINCT officer_id) AS employees_claiming,
            SUM(CASE WHEN has_remote_claim = 1 THEN total_allowances * 0.25
                     WHEN has_rural_claim  = 1 THEN total_allowances * 0.20
                     ELSE 0 END) AS total_amount,
            SUM(has_remote_claim) AS remote_claim_rows,
            SUM(has_rural_claim)  AS rural_claim_rows
        FROM base
        GROUP BY authority_name
    )
    SELECT
        a.authority_name,
        CASE
            WHEN a.is_remote_hardship THEN 'REMOTE (25%)'
            WHEN a.is_rural_hardship  THEN 'RURAL (20%)'
            ELSE 'NONE'
        END AS official_designation,
        a.employees_claiming::INTEGER,
        COALESCE(a.total_amount, 0)::DECIMAL AS total_amount,
        CASE
            WHEN a.is_remote_hardship AND a.remote_claim_rows > 0 THEN TRUE
            WHEN a.is_rural_hardship  AND a.rural_claim_rows  > 0 THEN TRUE
            WHEN NOT a.is_remote_hardship AND NOT a.is_rural_hardship
                 AND a.remote_claim_rows = 0 AND a.rural_claim_rows = 0 THEN TRUE
            ELSE FALSE
        END AS compliant,
        CASE
            WHEN a.is_remote_hardship AND a.remote_claim_rows = 0
                THEN 'Designated REMOTE but not paying'
            WHEN a.is_rural_hardship AND a.rural_claim_rows = 0
                THEN 'Designated RURAL but not paying'
            WHEN NOT a.is_remote_hardship AND NOT a.is_rural_hardship
                 AND (a.remote_claim_rows > 0 OR a.rural_claim_rows > 0)
                THEN 'Paying hardship without designation - ILLEGAL'
            ELSE 'Compliant'
        END AS violation_details
    FROM agg a
    ORDER BY a.authority_name;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- §16  SALARY SCALE & NOTCH ENFORCEMENT SYSTEM
-- ============================================================

-- 1. Salary scales with valid notch ranges (official source)
CREATE TABLE IF NOT EXISTS salary_scales_official (
    scale_id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    salary_scale         VARCHAR(20) NOT NULL,
    division             VARCHAR(20) NOT NULL,
    min_notch            INTEGER NOT NULL,
    max_notch            INTEGER NOT NULL,
    effective_from       DATE NOT NULL,
    effective_to         DATE,
    is_active            BOOLEAN DEFAULT TRUE,
    authority_document   VARCHAR(200),
    page_reference       VARCHAR(50),
    CHECK (min_notch <= max_notch),
    UNIQUE (salary_scale, effective_from)
);

INSERT INTO salary_scales_official
    (salary_scale, division, min_notch, max_notch, effective_from, authority_document)
VALUES
('LGSS01', 'DIVISION_I',   1, 7, '2025-01-01', 'Management Circular 2025'),
('LGSS02', 'DIVISION_I',   1, 7, '2025-01-01', 'Management Circular 2025'),
('LGSS03', 'DIVISION_I',   1, 7, '2025-01-01', 'Management Circular 2025'),
('LGSS04', 'DIVISION_I',   1, 7, '2025-01-01', 'Management Circular 2025'),
('LGSS05', 'DIVISION_I',   1, 7, '2025-01-01', 'Management Circular 2025'),
('LGSS06', 'DIVISION_I',   1, 7, '2025-01-01', 'Management Circular 2025'),
('LGSS07', 'DIVISION_I',   1, 7, '2025-01-01', 'Management Circular 2025'),
('LGSS08', 'DIVISION_II',  1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS09', 'DIVISION_II',  1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS10', 'DIVISION_II',  1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS11', 'DIVISION_II',  1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS12', 'DIVISION_II',  1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS13', 'DIVISION_III', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS14', 'DIVISION_III', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS15', 'DIVISION_III', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS16', 'DIVISION_III', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS17', 'DIVISION_III', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('LGSS18', 'DIVISION_III', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('GRADE_01','DIVISION_IV', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('GRADE_02','DIVISION_IV', 1, 7, '2025-01-01', 'Collective Agreement 2025'),
('GRADE_03','DIVISION_IV', 1, 7, '2025-01-01', 'Collective Agreement 2025')
ON CONFLICT (salary_scale, effective_from) DO NOTHING;

-- 2. Salary notch values (official amounts)
CREATE TABLE IF NOT EXISTS salary_notch_values_official (
    notch_value_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    salary_scale         VARCHAR(20) NOT NULL,
    notch_number         INTEGER NOT NULL,
    annual_amount        DECIMAL(10,2) NOT NULL,
    monthly_amount       DECIMAL(10,2) NOT NULL,
    notch_increment      DECIMAL(10,2),
    effective_from       DATE NOT NULL,
    effective_to         DATE,
    is_active            BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (salary_scale, effective_from)
        REFERENCES salary_scales_official(salary_scale, effective_from),
    UNIQUE (salary_scale, notch_number, effective_from)
);

INSERT INTO salary_notch_values_official
    (salary_scale, notch_number, annual_amount, monthly_amount, effective_from)
VALUES
('LGSS08', 1, 123277, 10273, '2025-01-01'),
('LGSS08', 2, 120410, 10034, '2025-01-01'),
('LGSS08', 3, 117543,  9795, '2025-01-01'),
('LGSS08', 4, 114676,  9556, '2025-01-01'),
('LGSS08', 5, 111809,  9317, '2025-01-01'),
('LGSS08', 6, 108942,  9079, '2025-01-01'),
('LGSS08', 7, 106075,  8840, '2025-01-01'),
('LGSS05', 1, 147629, 12302, '2025-01-01'),
('LGSS05', 2, 144135, 12011, '2025-01-01'),
('LGSS05', 3, 140641, 11720, '2025-01-01'),
('LGSS05', 4, 137147, 11429, '2025-01-01'),
('LGSS05', 5, 133653, 11138, '2025-01-01'),
('LGSS05', 6, 130159, 10847, '2025-01-01'),
('LGSS05', 7, 126665, 10555, '2025-01-01')
ON CONFLICT (salary_scale, notch_number, effective_from) DO NOTHING;

-- 3. Employment history with strict scale/notch enforcement
CREATE TABLE IF NOT EXISTS employment_history (
    employment_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    officer_id               UUID REFERENCES officers(officer_id),
    authority_id             UUID REFERENCES local_authorities(authority_id),
    salary_scale             VARCHAR(20) NOT NULL,
    notch_number             INTEGER NOT NULL,
    monthly_salary           DECIMAL(10,2) NOT NULL,
    division                 VARCHAR(20),
    approved_by              UUID NOT NULL,
    approval_date            DATE NOT NULL,
    approval_reference       VARCHAR(100),
    appointment_letter_url   VARCHAR(500),
    effective_date           DATE NOT NULL,
    end_date                 DATE,
    is_current               BOOLEAN DEFAULT TRUE,
    created_at               TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by               UUID
);

CREATE INDEX IF NOT EXISTS idx_eh_officer      ON employment_history(officer_id);
CREATE INDEX IF NOT EXISTS idx_eh_authority    ON employment_history(authority_id);
CREATE INDEX IF NOT EXISTS idx_eh_scale_notch  ON employment_history(salary_scale, notch_number);
CREATE INDEX IF NOT EXISTS idx_snvo_scale_date ON salary_notch_values_official(salary_scale, notch_number, effective_from);

CREATE OR REPLACE FUNCTION fn_validate_employment_history()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_division       VARCHAR(20);
    v_monthly_amount DECIMAL(10,2);
BEGIN
    SELECT sso.division
      INTO v_division
      FROM salary_scales_official sso
     WHERE sso.salary_scale = NEW.salary_scale
       AND sso.effective_from <= NEW.effective_date
       AND sso.is_active = TRUE
       AND NEW.notch_number BETWEEN sso.min_notch AND sso.max_notch
     ORDER BY sso.effective_from DESC
     LIMIT 1;

    IF v_division IS NULL THEN
        RAISE EXCEPTION 'Invalid salary_scale/notch/effective_date combination: %, %, %',
            NEW.salary_scale, NEW.notch_number, NEW.effective_date;
    END IF;

    SELECT snv.monthly_amount
      INTO v_monthly_amount
      FROM salary_notch_values_official snv
     WHERE snv.salary_scale = NEW.salary_scale
       AND snv.notch_number = NEW.notch_number
       AND snv.effective_from <= NEW.effective_date
       AND snv.is_active = TRUE
     ORDER BY snv.effective_from DESC
     LIMIT 1;

    IF v_monthly_amount IS NULL THEN
        RAISE EXCEPTION 'No official notch value found for salary_scale %, notch % (effective %)',
            NEW.salary_scale, NEW.notch_number, NEW.effective_date;
    END IF;

    IF NEW.monthly_salary <> v_monthly_amount THEN
        RAISE EXCEPTION 'Monthly salary % does not match official amount % for % notch %',
            NEW.monthly_salary, v_monthly_amount, NEW.salary_scale, NEW.notch_number;
    END IF;

    NEW.division := v_division;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_validate_employment_history ON employment_history;
CREATE TRIGGER trg_validate_employment_history
    BEFORE INSERT OR UPDATE ON employment_history
    FOR EACH ROW EXECUTE FUNCTION fn_validate_employment_history();
