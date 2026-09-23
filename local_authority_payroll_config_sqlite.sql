-- ===================================================
-- LOCAL AUTHORITY-SPECIFIC PAYROLL CONFIGURATION
-- SQLite-Compatible Migration for hr_platform.db
-- ===================================================

PRAGMA foreign_keys = ON;

-- 1. LOCAL AUTHORITIES TABLE (Enhanced)
CREATE TABLE IF NOT EXISTS local_authorities (
    authority_id TEXT PRIMARY KEY,
    authority_code TEXT UNIQUE NOT NULL,
    authority_name TEXT NOT NULL,
    is_active INTEGER DEFAULT 1,

    payroll_cycle TEXT DEFAULT 'MONTHLY',
    standard_pay_day INTEGER,
    pay_day_frequency TEXT,

    allows_split_payment INTEGER DEFAULT 0,
    grace_period_days INTEGER DEFAULT 0,
    max_pay_delay_days INTEGER DEFAULT 5,

    annual_payroll_budget REAL,
    current_cash_position REAL,
    last_payroll_date TEXT,
    next_payroll_date TEXT,

    payroll_bank_account TEXT,
    payroll_bank_branch TEXT,

    payroll_contact_name TEXT,
    payroll_contact_email TEXT,
    payroll_contact_phone TEXT,

    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
INSERT OR IGNORE INTO local_authorities (
    authority_id, authority_code, authority_name, standard_pay_day
) VALUES
('LA-KTC', 'KTC', 'Kafue Town Council', 25),
('LA-LCC', 'LCC', 'Lusaka City Council', 28),
('LA-NDC', 'NDC', 'Ndola City Council', 20),
('LA-MTC', 'MTC', 'Mongu Town Council', 15);

-- 2. PAYROLL_SCHEDULES (Per Authority)
CREATE TABLE IF NOT EXISTS payroll_schedules (
    schedule_id TEXT PRIMARY KEY,
    authority_id TEXT REFERENCES local_authorities(authority_id),
    period_year INTEGER NOT NULL,
    period_month INTEGER NOT NULL,

    payroll_cutoff_date TEXT,
    processing_start_date TEXT,
    processing_end_date TEXT,
    payslip_generation_date TEXT,
    scheduled_payment_date TEXT,

    actual_payslip_date TEXT,
    actual_payment_date TEXT,

    status TEXT DEFAULT 'SCHEDULED',
    delay_reason TEXT,

    UNIQUE(authority_id, period_year, period_month)
);

-- 3. PAYROLL_RUN (Authority schedule linked; employees used in place of officers)
CREATE TABLE IF NOT EXISTS payroll_run (
    payroll_id TEXT PRIMARY KEY,
    schedule_id TEXT REFERENCES payroll_schedules(schedule_id),
    authority_id TEXT REFERENCES local_authorities(authority_id),
    employee_id TEXT,

    payslip_number TEXT UNIQUE NOT NULL,
    document_verification_code TEXT UNIQUE NOT NULL,

    payslip_available_date TEXT,
    payslip_viewed_date TEXT,
    payslip_delivery_method TEXT,

    payment_due_date TEXT,
    payment_actual_date TEXT,
    payment_status TEXT DEFAULT 'PENDING',
    payment_reference TEXT,

    basic_salary REAL,
    total_allowances REAL,
    total_deductions REAL,
    net_pay REAL,

    created_at TEXT DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(schedule_id, employee_id)
);

-- 4. PAYMENT_BATCHES (For bank files)
CREATE TABLE IF NOT EXISTS payment_batches (
    batch_id TEXT PRIMARY KEY,
    authority_id TEXT REFERENCES local_authorities(authority_id),
    schedule_id TEXT REFERENCES payroll_schedules(schedule_id),

    batch_reference TEXT UNIQUE NOT NULL,
    batch_date TEXT NOT NULL,
    total_amount REAL NOT NULL,
    employee_count INTEGER NOT NULL,

    bank_file_generated_at TEXT,
    bank_file_sent_at TEXT,
    bank_confirmation_received INTEGER DEFAULT 0,
    bank_confirmation_date TEXT,
    bank_rejection_reason TEXT,

    status TEXT DEFAULT 'CREATED'
);

-- 5. PAYSLIP_ACCESS_LOG (Audit trail)
CREATE TABLE IF NOT EXISTS payslip_access_log (
    access_id TEXT PRIMARY KEY,
    payroll_id TEXT REFERENCES payroll_run(payroll_id),
    employee_id TEXT,

    access_type TEXT,
    access_timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
    access_ip TEXT,
    access_device TEXT,

    delivery_confirmation INTEGER DEFAULT 0,
    delivery_confirmation_time TEXT
);

-- 6. PAYMENT DELAY APPROVALS (Cash flow exceptions)
CREATE TABLE IF NOT EXISTS payment_delay_approvals (
    delay_id TEXT PRIMARY KEY,
    authority_id TEXT REFERENCES local_authorities(authority_id),
    schedule_id TEXT REFERENCES payroll_schedules(schedule_id),
    delay_days INTEGER NOT NULL,
    reason TEXT NOT NULL,
    approved_by TEXT,
    approval_date TEXT,
    payslips_issued_on_time INTEGER DEFAULT 0,
    notification_sent_to_employees INTEGER DEFAULT 0,
    notification_date TEXT
);

-- 6. VIEW TO MONITOR PAYROLL STATUS ACROSS ALL AUTHORITIES
DROP VIEW IF EXISTS v_payroll_compliance;
CREATE VIEW v_payroll_compliance AS
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
    CASE
        WHEN ps.actual_payment_date IS NULL OR ps.scheduled_payment_date IS NULL THEN NULL
        ELSE CAST(julianday(ps.actual_payment_date) - julianday(ps.scheduled_payment_date) AS INTEGER)
    END AS days_late,
    (SELECT COUNT(*) FROM payroll_run pr WHERE pr.schedule_id = ps.schedule_id) AS employee_count,
    (SELECT SUM(net_pay) FROM payroll_run pr WHERE pr.schedule_id = ps.schedule_id) AS total_payroll
FROM payroll_schedules ps
JOIN local_authorities la ON ps.authority_id = la.authority_id
ORDER BY ps.scheduled_payment_date;

-- 7. PAYMENT GUARD (SQLite equivalent of PostgreSQL trigger)
CREATE TABLE IF NOT EXISTS payroll_integrity_log (
    log_id TEXT PRIMARY KEY,
    payroll_id TEXT,
    event_type TEXT,
    message TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS payroll_payment_check;
CREATE TRIGGER payroll_payment_check
BEFORE UPDATE ON payroll_run
FOR EACH ROW
WHEN NEW.payment_status IN ('PROCESSED', 'PAID')
BEGIN
    SELECT
        CASE
            WHEN NEW.payslip_available_date IS NULL THEN
                RAISE(ABORT, 'Cannot process payment: Payslip not yet generated')
        END;

    -- Check 2: late payments require an approval that covers the actual delay days
    SELECT
        CASE
            WHEN NEW.payment_status = 'PAID'
             AND NEW.payment_due_date IS NOT NULL
             AND date(COALESCE(NEW.payment_actual_date, date('now'))) > date(NEW.payment_due_date)
             AND (
                 NEW.schedule_id IS NULL
                 OR (
                     SELECT COUNT(*)
                     FROM payment_delay_approvals pda
                     WHERE pda.schedule_id = NEW.schedule_id
                       AND (NEW.authority_id IS NULL OR pda.authority_id = NEW.authority_id)
                       -- approved delay_days must cover the actual calendar days late
                       AND pda.delay_days >= CAST(
                             julianday(COALESCE(NEW.payment_actual_date, date('now')))
                             - julianday(NEW.payment_due_date)
                           AS INTEGER)
                       AND TRIM(COALESCE(pda.reason, '')) <> ''
                       AND TRIM(COALESCE(pda.approved_by, '')) <> ''
                       AND pda.approval_date IS NOT NULL
                       AND pda.payslips_issued_on_time IN (0, 1)
                       AND pda.notification_sent_to_employees = 1
                       AND pda.notification_date IS NOT NULL
                 ) = 0
             ) THEN
                RAISE(ABORT, 'Cannot mark delayed payment as PAID: an approved delay covering the actual delay days, plus employee notification, is required')
        END;
END;

DROP TRIGGER IF EXISTS payroll_payment_late_warning;
CREATE TRIGGER payroll_payment_late_warning
AFTER UPDATE ON payroll_run
FOR EACH ROW
WHEN NEW.payment_status IN ('PROCESSED', 'PAID')
 AND NEW.payslip_available_date IS NOT NULL
 AND NEW.payment_due_date IS NOT NULL
 AND date(NEW.payslip_available_date) > date(NEW.payment_due_date)
BEGIN
    INSERT INTO payroll_integrity_log (log_id, payroll_id, event_type, message)
    VALUES (
        'LOG-' || hex(randomblob(8)),
        NEW.payroll_id,
        'LATE_PAYSLIP_WARNING',
        'Payslip generated after payment due date: ' || date(NEW.payslip_available_date) || ' > ' || date(NEW.payment_due_date)
    );
END;

-- ===================================================
-- 8. MONTHLY COMPLIANCE REPORT VIEW (Ministry of Local Government)
-- SQLite equivalent of generate_compliance_report(year, month).
-- Filter with: SELECT * FROM v_compliance_report WHERE period_year=2026 AND period_month=3;
-- ===================================================
DROP VIEW IF EXISTS v_compliance_report;
CREATE VIEW v_compliance_report AS
SELECT
    la.authority_name,
    la.standard_pay_day                    AS pay_day,
    ps.period_year,
    ps.period_month,
    ps.scheduled_payment_date              AS payment_date,
    ps.payslip_generation_date             AS payslip_due_date,
    ps.actual_payslip_date,
    ps.actual_payment_date,
    -- compliant only when payslips were issued on or before the scheduled generation date
    CASE
        WHEN ps.actual_payslip_date IS NOT NULL
             AND ps.actual_payslip_date <= ps.payslip_generation_date
        THEN 1 ELSE 0
    END AS compliant,
    CASE
        WHEN ps.actual_payslip_date IS NULL
            THEN 'No payslips generated'
        WHEN ps.actual_payslip_date > ps.scheduled_payment_date
            THEN 'PAYSLIPS AFTER PAYMENT - VIOLATION'
        WHEN ps.actual_payslip_date > ps.payslip_generation_date
             AND ps.actual_payslip_date <= ps.scheduled_payment_date
            THEN 'Late payslips but before payment'
        ELSE 'Compliant'
    END AS violation_details,
    -- days between actual payslip and the scheduled generation target
    CASE
        WHEN ps.actual_payslip_date IS NOT NULL AND ps.payslip_generation_date IS NOT NULL
        THEN CAST(julianday(ps.actual_payslip_date) - julianday(ps.payslip_generation_date) AS INTEGER)
    END AS payslip_days_late,
    -- days between actual payment and scheduled payment
    CASE
        WHEN ps.actual_payment_date IS NOT NULL AND ps.scheduled_payment_date IS NOT NULL
        THEN CAST(julianday(ps.actual_payment_date) - julianday(ps.scheduled_payment_date) AS INTEGER)
    END AS payment_days_late,
    (SELECT COUNT(*) FROM payroll_run pr WHERE pr.schedule_id = ps.schedule_id) AS employee_count,
    (SELECT COALESCE(SUM(net_pay), 0) FROM payroll_run pr WHERE pr.schedule_id = ps.schedule_id) AS total_net_payroll
FROM payroll_schedules ps
JOIN local_authorities la ON ps.authority_id = la.authority_id
ORDER BY ps.period_year, ps.period_month, la.standard_pay_day;

-- ===================================================
-- 9. CENTRAL COMPLIANCE HUB ARCHITECTURE
-- Local Authorities process payments; central office tracks compliance.
-- ===================================================

-- 9a. LA-SPECIFIC PAYROLL CONFIGURATION (compliance deadlines only)
CREATE TABLE IF NOT EXISTS la_payroll_config (
    config_id                   TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    authority_id                TEXT REFERENCES local_authorities(authority_id),
    payslip_submission_deadline INTEGER NOT NULL DEFAULT 5,  -- day of following month
    payroll_data_deadline       INTEGER NOT NULL DEFAULT 7,
    compliance_officer_name     TEXT,
    compliance_officer_email    TEXT,
    compliance_officer_phone    TEXT,
    created_at                  TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(authority_id)
);

-- 9b. LA PAYROLL SUBMISSIONS (what LAs send to central office)
CREATE TABLE IF NOT EXISTS la_payroll_submissions (
    submission_id           TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    authority_id            TEXT REFERENCES local_authorities(authority_id),
    period_year             INTEGER NOT NULL,
    period_month            INTEGER NOT NULL,
    la_payroll_date         TEXT,   -- ISO date; when the LA paid staff
    submission_date         TEXT DEFAULT CURRENT_TIMESTAMP,
    submission_status       TEXT DEFAULT 'PENDING',  -- PENDING | VALIDATED | REJECTED
    payroll_data            TEXT NOT NULL,            -- JSON blob from LA
    compliance_check_passed INTEGER,                  -- 0/1
    compliance_check_notes  TEXT,
    compliance_officer_id   TEXT,
    compliance_check_date   TEXT,
    UNIQUE(authority_id, period_year, period_month)
);

-- 9c. COMPLIANCE ISSUES TRACKING
CREATE TABLE IF NOT EXISTS compliance_issues (
    issue_id            TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    authority_id        TEXT REFERENCES local_authorities(authority_id),
    submission_id       TEXT REFERENCES la_payroll_submissions(submission_id),
    issue_type          TEXT NOT NULL,   -- LATE_SUBMISSION | MISSING_DATA | CALCULATION_ERROR
    issue_severity      TEXT,            -- WARNING | MINOR | MAJOR | CRITICAL
    issue_description   TEXT NOT NULL,
    days_late           INTEGER,
    deadline_date       TEXT,
    submission_date     TEXT,
    affected_employees  INTEGER,
    total_discrepancy   REAL,
    resolution_status   TEXT DEFAULT 'OPEN',  -- OPEN | IN_PROGRESS | RESOLVED
    resolution_notes    TEXT,
    resolved_by         TEXT,
    resolved_date       TEXT,
    created_at          TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_ci_authority   ON compliance_issues(authority_id);
CREATE INDEX IF NOT EXISTS idx_ci_submission  ON compliance_issues(submission_id);
CREATE INDEX IF NOT EXISTS idx_ci_status      ON compliance_issues(resolution_status);

-- 9d. CENTRALISED PAYSLIP ARCHIVE
CREATE TABLE IF NOT EXISTS central_payslip_archive (
    archive_id              TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    authority_id            TEXT REFERENCES local_authorities(authority_id),
    submission_id           TEXT REFERENCES la_payroll_submissions(submission_id),
    officer_id              TEXT,
    employee_number         TEXT,
    employee_name           TEXT,
    period_year             INTEGER NOT NULL,
    period_month            INTEGER NOT NULL,
    basic_salary            REAL,
    housing_allowance       REAL,
    total_allowances        REAL,
    total_deductions        REAL,
    net_pay                 REAL,
    paye_amount             REAL,
    napsa_amount            REAL,
    nhis_amount             REAL,
    leave_earned            REAL,
    leave_taken             REAL,
    leave_balance           REAL,
    payment_date            TEXT,
    payslip_generated_date  TEXT,
    payslip_data            TEXT,  -- JSON string
    archived_at             TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_cpa_authority_period ON central_payslip_archive(authority_id, period_year, period_month);
CREATE INDEX IF NOT EXISTS idx_cpa_employee         ON central_payslip_archive(employee_number);

-- 9e. CENTRAL COMPLIANCE SUMMARY VIEW
DROP VIEW IF EXISTS v_central_compliance_summary;
CREATE VIEW v_central_compliance_summary AS
SELECT
    la.authority_code,
    la.authority_name,
    lps.period_year,
    lps.period_month,
    lps.la_payroll_date,
    date(lps.submission_date)               AS submitted_on,
    lps.submission_status,
    lps.compliance_check_passed,
    cfg.payslip_submission_deadline,
    cfg.payroll_data_deadline,
    -- Days between LA pay date and central submission
    CASE
        WHEN lps.la_payroll_date IS NOT NULL AND lps.submission_date IS NOT NULL
        THEN CAST(julianday(date(lps.submission_date)) - julianday(lps.la_payroll_date) AS INTEGER)
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
-- 10. COMPLIANCE FUNCTIONS (SQLite equivalents)
-- SQLite has no stored functions; logic is expressed as:
--   - Views  for read-only queries
--   - Triggers for auto-issue creation on INSERT/UPDATE
--   - Python helper generate_ministry_report.py for the JSON report
-- ===================================================

-- Dedupe guard: prevent duplicate LATE_SUBMISSION issues per submission
CREATE UNIQUE INDEX IF NOT EXISTS idx_ci_late_submission_dedup
    ON compliance_issues(submission_id, issue_type)
    WHERE issue_type = 'LATE_SUBMISSION';

-- 10a. VIEW: late submission summary (equivalent to check_late_submissions)
DROP VIEW IF EXISTS v_late_submissions;
CREATE VIEW v_late_submissions AS
SELECT
    la.authority_name,
    la.authority_code,
    lps.period_year,
    lps.period_month,
    -- deadline = 5th of the submitted month (caller passes the following month)
    date(lps.period_year || '-' || printf('%02d', lps.period_month) || '-05') AS deadline_date,
    date(lps.submission_date)                                                  AS submitted_on,
    CASE
        WHEN date(lps.submission_date) >
             date(lps.period_year || '-' || printf('%02d', lps.period_month) || '-05')
        THEN CAST(
            julianday(date(lps.submission_date)) -
            julianday(date(lps.period_year || '-' || printf('%02d', lps.period_month) || '-05'))
            AS INTEGER)
        ELSE 0
    END AS days_late,
    CASE
        WHEN date(lps.submission_date) <=
             date(lps.period_year || '-' || printf('%02d', lps.period_month) || '-05')
        THEN 'ON_TIME'
        WHEN CAST(
            julianday(date(lps.submission_date)) -
            julianday(date(lps.period_year || '-' || printf('%02d', lps.period_month) || '-05'))
            AS INTEGER) <= 5  THEN 'MINOR'
        WHEN CAST(
            julianday(date(lps.submission_date)) -
            julianday(date(lps.period_year || '-' || printf('%02d', lps.period_month) || '-05'))
            AS INTEGER) <= 15 THEN 'MAJOR'
        ELSE 'CRITICAL'
    END AS severity,
    lps.submission_id,
    lps.authority_id
FROM la_payroll_submissions lps
JOIN local_authorities la ON lps.authority_id = la.authority_id
ORDER BY days_late DESC, la.authority_name;

-- 10a. TRIGGER: auto-create compliance issue on late submission (INSERT)
DROP TRIGGER IF EXISTS trg_late_submission_insert;
CREATE TRIGGER trg_late_submission_insert
AFTER INSERT ON la_payroll_submissions
FOR EACH ROW
WHEN date(NEW.submission_date) >
     date(NEW.period_year || '-' || printf('%02d', NEW.period_month) || '-05')
BEGIN
    INSERT OR IGNORE INTO compliance_issues (
        issue_id, authority_id, submission_id,
        issue_type, issue_severity, issue_description,
        days_late, deadline_date, submission_date
    ) VALUES (
        lower(hex(randomblob(16))),
        NEW.authority_id,
        NEW.submission_id,
        'LATE_SUBMISSION',
        CASE
            WHEN CAST(julianday(date(NEW.submission_date)) -
                      julianday(date(NEW.period_year || '-' || printf('%02d', NEW.period_month) || '-05'))
                 AS INTEGER) <= 5  THEN 'MINOR'
            WHEN CAST(julianday(date(NEW.submission_date)) -
                      julianday(date(NEW.period_year || '-' || printf('%02d', NEW.period_month) || '-05'))
                 AS INTEGER) <= 15 THEN 'MAJOR'
            ELSE 'CRITICAL'
        END,
        'Payroll data submitted ' ||
        CAST(julianday(date(NEW.submission_date)) -
             julianday(date(NEW.period_year || '-' || printf('%02d', NEW.period_month) || '-05'))
             AS INTEGER) || ' days late',
        CAST(julianday(date(NEW.submission_date)) -
             julianday(date(NEW.period_year || '-' || printf('%02d', NEW.period_month) || '-05'))
             AS INTEGER),
        date(NEW.period_year || '-' || printf('%02d', NEW.period_month) || '-05'),
        date(NEW.submission_date)
    );
END;

-- 10b. VIEW: payslip-after-payment violations (equivalent to validate_payslip_timing)
-- Reads payment_date and payslip_generated_date from central_payslip_archive
DROP VIEW IF EXISTS v_payslip_timing_violations;
CREATE VIEW v_payslip_timing_violations AS
SELECT
    la.authority_code,
    la.authority_name,
    cpa.period_year,
    cpa.period_month,
    cpa.employee_number,
    cpa.employee_name,
    cpa.payslip_generated_date,
    cpa.payment_date,
    CAST(julianday(cpa.payslip_generated_date) - julianday(cpa.payment_date) AS INTEGER) AS days_after_payment,
    'VIOLATION OF SECTION 105: payslip generated ' ||
        CAST(julianday(cpa.payslip_generated_date) - julianday(cpa.payment_date) AS INTEGER) ||
        ' day(s) after payment' AS violation_detail
FROM central_payslip_archive cpa
JOIN local_authorities la ON cpa.authority_id = la.authority_id
WHERE cpa.payslip_generated_date IS NOT NULL
  AND cpa.payment_date IS NOT NULL
  AND cpa.payslip_generated_date > cpa.payment_date
ORDER BY days_after_payment DESC, la.authority_name;

-- ===================================================
-- 11. TEAM COMPLIANCE DASHBOARD VIEW
-- Always shows the current calendar month.
-- ===================================================
DROP VIEW IF EXISTS v_compliance_dashboard;
CREATE VIEW v_compliance_dashboard AS
SELECT
    la.authority_name,
    la.authority_code,
    COUNT(DISTINCT lps.submission_id)                                           AS submissions,
    COUNT(DISTINCT ci.issue_id)                                                 AS open_issues,
    MAX(CASE WHEN ci.issue_severity = 'CRITICAL' THEN 1 ELSE 0 END)            AS has_critical,
    ROUND(
        AVG(CASE WHEN ci.issue_type = 'LATE_SUBMISSION' THEN ci.days_late ELSE NULL END),
    1)                                                                          AS avg_days_late,
    COALESCE(SUM(cpa.net_pay), 0)                                               AS total_payroll_processed,
    lps.period_year,
    lps.period_month
FROM local_authorities la
LEFT JOIN la_payroll_submissions lps
       ON la.authority_id  = lps.authority_id
      AND lps.period_year  = CAST(strftime('%Y', 'now') AS INTEGER)
      AND lps.period_month = CAST(strftime('%m', 'now') AS INTEGER)
LEFT JOIN compliance_issues ci
       ON lps.submission_id    = ci.submission_id
      AND ci.resolution_status = 'OPEN'
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
    classification_id     TEXT PRIMARY KEY,   -- lower(hex(randomblob(16)))
    authority_id          TEXT REFERENCES local_authorities(authority_id),

    -- Only one designation flag may be 1 at a time
    is_remote_hardship    INTEGER DEFAULT 0 CHECK (is_remote_hardship IN (0,1)),
    is_rural_hardship     INTEGER DEFAULT 0 CHECK (is_rural_hardship  IN (0,1)),

    -- Effective dates (ISO-8601 text)
    designated_from       TEXT NOT NULL,
    designated_to         TEXT,
    is_current            INTEGER DEFAULT 1 CHECK (is_current IN (0,1)),

    -- Official circular reference
    circular_reference    TEXT NOT NULL,
    circular_date         TEXT NOT NULL,
    circular_document_url TEXT,

    -- Criteria met (JSON text array)
    criteria_met          TEXT,

    -- Approval
    approved_by           TEXT,
    approval_date         TEXT,

    -- Audit
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_by            TEXT,

    -- Mutual exclusivity
    CHECK (NOT (is_remote_hardship = 1 AND is_rural_hardship = 1)),
    -- Only one active designation per authority
    UNIQUE (authority_id, is_current)
);

-- 2. Historical tracking (when designations change)
CREATE TABLE IF NOT EXISTS station_hardship_history (
    history_id            TEXT PRIMARY KEY,
    authority_id          TEXT REFERENCES local_authorities(authority_id),

    previous_designation  TEXT,
    new_designation       TEXT,
    change_reason         TEXT,
    circular_reference    TEXT,
    effective_date        TEXT,

    changed_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by            TEXT
);

CREATE INDEX IF NOT EXISTS idx_shc_authority ON station_hardship_classification(authority_id);
CREATE INDEX IF NOT EXISTS idx_shc_current   ON station_hardship_classification(is_current);
CREATE INDEX IF NOT EXISTS idx_shh_authority ON station_hardship_history(authority_id);

-- Maintain updated_at automatically
CREATE TRIGGER IF NOT EXISTS trg_shc_updated_at
    AFTER UPDATE ON station_hardship_classification
    FOR EACH ROW
BEGIN
    UPDATE station_hardship_classification
       SET updated_at = CURRENT_TIMESTAMP
     WHERE classification_id = NEW.classification_id;
END;

-- Auto-populate history when is_current flipped to 0
CREATE TRIGGER IF NOT EXISTS trg_shc_history_on_change
    AFTER UPDATE OF is_current ON station_hardship_classification
    FOR EACH ROW
    WHEN OLD.is_current = 1 AND NEW.is_current = 0
BEGIN
    INSERT INTO station_hardship_history
        (history_id, authority_id,
         previous_designation, new_designation,
         change_reason, circular_reference, effective_date)
    VALUES (
        lower(hex(randomblob(16))),
        OLD.authority_id,
        CASE WHEN OLD.is_remote_hardship = 1 THEN 'REMOTE_HARDSHIP'
             WHEN OLD.is_rural_hardship   = 1 THEN 'RURAL_HARDSHIP'
             ELSE 'NONE' END,
        'NONE',
        'Superseded by new designation',
        OLD.circular_reference,
        date('now')
    );
END;

-- 3. Seed with official designations (real authority codes)
INSERT OR IGNORE INTO station_hardship_classification
    (classification_id, authority_id, is_remote_hardship, is_rural_hardship,
     designated_from, circular_reference, circular_date, criteria_met)
SELECT lower(hex(randomblob(16))), authority_id, 1, 0,
       '2025-01-01', 'MLGRD/CIR/01/2025', '2025-01-15',
       '["Banking facilities >50km","No all-weather roads"]'
FROM local_authorities WHERE authority_code = 'MTC';   -- Mongu Town Council (remote)

INSERT OR IGNORE INTO station_hardship_classification
    (classification_id, authority_id, is_remote_hardship, is_rural_hardship,
     designated_from, circular_reference, circular_date, criteria_met)
SELECT lower(hex(randomblob(16))), authority_id, 0, 1,
       '2025-01-01', 'MLGRD/CIR/01/2025', '2025-01-15',
       '["No electricity","No piped water"]'
FROM local_authorities WHERE authority_code = 'KTC';   -- Kafue Town Council (rural)

-- ============================================================
-- §13  HARDSHIP ELIGIBILITY + CLAIM VALIDATION (SQLITE EQUIVALENTS)
-- ============================================================

-- 4. View for LAs - show only officially designated authorities
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
      AND shc.is_current = 1
WHERE shc.authority_id IS NOT NULL;

-- 5. Calculation equivalent (rate matrix).
-- Use in queries as: amount = p_basic_salary * hardship_rate
DROP VIEW IF EXISTS v_hardship_allowance_rates;
CREATE VIEW v_hardship_allowance_rates AS
SELECT
    authority_id,
    CASE
        WHEN is_remote_hardship = 1 THEN 'REMOTE'
        WHEN is_rural_hardship  = 1 THEN 'RURAL'
        ELSE NULL
    END AS allowance_code,
    CASE
        WHEN is_remote_hardship = 1 THEN 'Remote Hardship Allowance'
        WHEN is_rural_hardship  = 1 THEN 'Rural Hardship Allowance'
        ELSE NULL
    END AS allowance_name,
    CASE
        WHEN is_remote_hardship = 1 THEN 0.25
        WHEN is_rural_hardship  = 1 THEN 0.20
        ELSE 0.00
    END AS hardship_rate,
    CASE
        WHEN is_remote_hardship = 1 THEN 25.00
        WHEN is_rural_hardship  = 1 THEN 20.00
        ELSE 0.00
    END AS rate_percent,
    CASE
        WHEN is_remote_hardship = 1 THEN 'REMOTE'
        WHEN is_rural_hardship  = 1 THEN 'RURAL'
        ELSE 'NONE'
    END AS designation_type
FROM station_hardship_classification
WHERE is_current = 1;

-- 6. Validation equivalent (read model) - detects unauthorized hardship claims by submission
DROP VIEW IF EXISTS v_hardship_claim_validation;
CREATE VIEW v_hardship_claim_validation AS
SELECT
    lps.submission_id,
    lps.authority_id,
    COALESCE(MAX(shc.is_remote_hardship), 0) AS authorized_remote,
    COALESCE(MAX(shc.is_rural_hardship), 0)  AS authorized_rural,
    SUM(CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%REMOTE%' THEN 1 ELSE 0 END) AS claiming_remote,
    SUM(CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%RURAL%'  THEN 1 ELSE 0 END) AS claiming_rural,
    CASE
        WHEN COALESCE(MAX(shc.is_remote_hardship),0) = 0
         AND SUM(CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%REMOTE%' THEN 1 ELSE 0 END) > 0
        THEN 1 ELSE 0
    END AS unauthorized_remote_claim,
    CASE
        WHEN COALESCE(MAX(shc.is_rural_hardship),0) = 0
         AND SUM(CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%RURAL%' THEN 1 ELSE 0 END) > 0
        THEN 1 ELSE 0
    END AS unauthorized_rural_claim,
    CASE
        WHEN (
             (COALESCE(MAX(shc.is_remote_hardship),0) = 0
              AND SUM(CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%REMOTE%' THEN 1 ELSE 0 END) > 0)
             OR
             (COALESCE(MAX(shc.is_rural_hardship),0) = 0
              AND SUM(CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%RURAL%' THEN 1 ELSE 0 END) > 0)
        ) THEN 0 ELSE 1
    END AS passed
FROM la_payroll_submissions lps
LEFT JOIN station_hardship_classification shc
       ON shc.authority_id = lps.authority_id
      AND shc.is_current = 1
LEFT JOIN central_payslip_archive cpa
       ON cpa.submission_id = lps.submission_id
GROUP BY lps.submission_id, lps.authority_id;

-- Write-path enforcement equivalent: auto-create CRITICAL compliance issues
CREATE UNIQUE INDEX IF NOT EXISTS idx_ci_unauth_remote_dedup
    ON compliance_issues(submission_id, issue_type)
    WHERE issue_type = 'UNAUTHORIZED_REMOTE_CLAIM';

CREATE UNIQUE INDEX IF NOT EXISTS idx_ci_unauth_rural_dedup
    ON compliance_issues(submission_id, issue_type)
    WHERE issue_type = 'UNAUTHORIZED_RURAL_CLAIM';

DROP TRIGGER IF EXISTS trg_validate_hardship_claims_insert;
CREATE TRIGGER trg_validate_hardship_claims_insert
    AFTER INSERT ON central_payslip_archive
    FOR EACH ROW
BEGIN
    INSERT OR IGNORE INTO compliance_issues (
        issue_id, authority_id, submission_id, issue_type, issue_severity,
        issue_description, affected_employees, resolution_status
    )
    SELECT lower(hex(randomblob(16))), NEW.authority_id, NEW.submission_id,
           'UNAUTHORIZED_REMOTE_CLAIM', 'CRITICAL',
           'Claimed Remote Hardship but authority is not designated',
           1, 'OPEN'
    WHERE NEW.submission_id IS NOT NULL
      AND UPPER(COALESCE(NEW.payslip_data,'')) LIKE '%REMOTE%'
      AND NOT EXISTS (
          SELECT 1
          FROM station_hardship_classification shc
          WHERE shc.authority_id = NEW.authority_id
            AND shc.is_current = 1
            AND shc.is_remote_hardship = 1
      );

    INSERT OR IGNORE INTO compliance_issues (
        issue_id, authority_id, submission_id, issue_type, issue_severity,
        issue_description, affected_employees, resolution_status
    )
    SELECT lower(hex(randomblob(16))), NEW.authority_id, NEW.submission_id,
           'UNAUTHORIZED_RURAL_CLAIM', 'CRITICAL',
           'Claimed Rural Hardship but authority is not designated',
           1, 'OPEN'
    WHERE NEW.submission_id IS NOT NULL
      AND UPPER(COALESCE(NEW.payslip_data,'')) LIKE '%RURAL%'
      AND NOT EXISTS (
          SELECT 1
          FROM station_hardship_classification shc
          WHERE shc.authority_id = NEW.authority_id
            AND shc.is_current = 1
            AND shc.is_rural_hardship = 1
      );
END;

-- ============================================================
-- §14  LA PAYROLL DASHBOARD (READ-ONLY HARDSHIP DESIGNATION)
-- ============================================================

-- Runtime context (SQLite equivalent of current_la_id())
CREATE TABLE IF NOT EXISTS la_session_context (
    context_id   INTEGER PRIMARY KEY CHECK (context_id = 1),
    authority_id TEXT REFERENCES local_authorities(authority_id),
    set_at       TEXT DEFAULT CURRENT_TIMESTAMP
);

DROP VIEW IF EXISTS la_payroll_dashboard;
CREATE VIEW la_payroll_dashboard AS
SELECT
    la.authority_code,
    la.authority_name,
    CASE
        WHEN shc.is_remote_hardship = 1 THEN 'REMOTE HARDSHIP (25%) - Designated'
        WHEN shc.is_rural_hardship  = 1 THEN 'RURAL HARDSHIP (20%) - Designated'
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
      AND shc.is_current = 1
WHERE la.authority_id = (
    SELECT authority_id
    FROM la_session_context
    WHERE context_id = 1
    LIMIT 1
);

-- ============================================================
-- §15  MINISTRY HARDSHIP ALLOWANCE COMPLIANCE REPORT (SQLITE)
-- ============================================================
-- Filter by period with:
--   SELECT * FROM v_hardship_compliance_report
--   WHERE period_year = 2026 AND period_month = 3;

DROP VIEW IF EXISTS v_hardship_compliance_report;
CREATE VIEW v_hardship_compliance_report AS
WITH base AS (
    SELECT
        lps.period_year,
        lps.period_month,
        la.authority_id,
        la.authority_name,
        COALESCE(shc.is_remote_hardship, 0) AS is_remote_hardship,
        COALESCE(shc.is_rural_hardship, 0)  AS is_rural_hardship,
        cpa.officer_id,
        COALESCE(cpa.total_allowances, 0) AS total_allowances,
        CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%REMOTE%' THEN 1 ELSE 0 END AS has_remote_claim,
        CASE WHEN UPPER(COALESCE(cpa.payslip_data,'')) LIKE '%RURAL%'  THEN 1 ELSE 0 END AS has_rural_claim
    FROM la_payroll_submissions lps
    JOIN central_payslip_archive cpa
      ON lps.submission_id = cpa.submission_id
    JOIN local_authorities la
      ON lps.authority_id = la.authority_id
    LEFT JOIN station_hardship_classification shc
      ON la.authority_id = shc.authority_id
     AND shc.is_current = 1
), agg AS (
    SELECT
        period_year,
        period_month,
        authority_name,
        MAX(is_remote_hardship) AS is_remote_hardship,
        MAX(is_rural_hardship)  AS is_rural_hardship,
        COUNT(DISTINCT officer_id) AS employees_claiming,
        SUM(CASE WHEN has_remote_claim = 1 THEN total_allowances * 0.25
                 WHEN has_rural_claim  = 1 THEN total_allowances * 0.20
                 ELSE 0 END) AS total_amount,
        SUM(has_remote_claim) AS remote_claim_rows,
        SUM(has_rural_claim)  AS rural_claim_rows
    FROM base
    GROUP BY period_year, period_month, authority_name
)
SELECT
    period_year,
    period_month,
    authority_name,
    CASE
        WHEN is_remote_hardship = 1 THEN 'REMOTE (25%)'
        WHEN is_rural_hardship  = 1 THEN 'RURAL (20%)'
        ELSE 'NONE'
    END AS official_designation,
    employees_claiming,
    ROUND(COALESCE(total_amount, 0), 2) AS total_amount,
    CASE
        WHEN is_remote_hardship = 1 AND remote_claim_rows > 0 THEN 1
        WHEN is_rural_hardship  = 1 AND rural_claim_rows  > 0 THEN 1
        WHEN is_remote_hardship = 0 AND is_rural_hardship = 0
             AND remote_claim_rows = 0 AND rural_claim_rows = 0 THEN 1
        ELSE 0
    END AS compliant,
    CASE
        WHEN is_remote_hardship = 1 AND remote_claim_rows = 0
            THEN 'Designated REMOTE but not paying'
        WHEN is_rural_hardship = 1 AND rural_claim_rows = 0
            THEN 'Designated RURAL but not paying'
        WHEN is_remote_hardship = 0 AND is_rural_hardship = 0
             AND (remote_claim_rows > 0 OR rural_claim_rows > 0)
            THEN 'Paying hardship without designation - ILLEGAL'
        ELSE 'Compliant'
    END AS violation_details
FROM agg;

-- ============================================================
-- §16  SALARY SCALE & NOTCH ENFORCEMENT SYSTEM (SQLITE)
-- ============================================================
-- Note: Uses *_official tables for strict controlled values and trigger validation.

-- 1. Salary scales with valid notch ranges (official source)
CREATE TABLE IF NOT EXISTS salary_scales_official (
    scale_id             TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    salary_scale         TEXT NOT NULL,
    division             TEXT NOT NULL,
    min_notch            INTEGER NOT NULL,
    max_notch            INTEGER NOT NULL,
    effective_from       TEXT NOT NULL,
    effective_to         TEXT,
    is_active            INTEGER DEFAULT 1 CHECK (is_active IN (0,1)),
    authority_document   TEXT,
    page_reference       TEXT,
    CHECK (min_notch <= max_notch),
    UNIQUE (salary_scale, effective_from)
);

INSERT OR IGNORE INTO salary_scales_official
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
('GRADE_03','DIVISION_IV', 1, 7, '2025-01-01', 'Collective Agreement 2025');

-- 2. Salary notch values (official amounts)
CREATE TABLE IF NOT EXISTS salary_notch_values_official (
    notch_value_id       TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    salary_scale         TEXT NOT NULL,
    notch_number         INTEGER NOT NULL,
    annual_amount        REAL NOT NULL,
    monthly_amount       REAL NOT NULL,
    notch_increment      REAL,
    effective_from       TEXT NOT NULL,
    effective_to         TEXT,
    is_active            INTEGER DEFAULT 1 CHECK (is_active IN (0,1)),
    UNIQUE (salary_scale, notch_number, effective_from),
    FOREIGN KEY (salary_scale, effective_from)
        REFERENCES salary_scales_official(salary_scale, effective_from)
);

INSERT OR IGNORE INTO salary_notch_values_official
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
('LGSS05', 7, 126665, 10555, '2025-01-01');

-- 3. Employment history with strict scale/notch enforcement
CREATE TABLE IF NOT EXISTS employment_history (
    employment_id            TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
    employee_id              TEXT,
    authority_id             TEXT REFERENCES local_authorities(authority_id),
    salary_scale             TEXT NOT NULL,
    notch_number             INTEGER NOT NULL,
    monthly_salary           REAL NOT NULL,
    division                 TEXT,
    approved_by              TEXT NOT NULL,
    approval_date            TEXT NOT NULL,
    approval_reference       TEXT,
    appointment_letter_url   TEXT,
    effective_date           TEXT NOT NULL,
    end_date                 TEXT,
    is_current               INTEGER DEFAULT 1 CHECK (is_current IN (0,1)),
    created_at               TEXT DEFAULT CURRENT_TIMESTAMP,
    created_by               TEXT
);

CREATE INDEX IF NOT EXISTS idx_eh_employee       ON employment_history(employee_id);
CREATE INDEX IF NOT EXISTS idx_eh_authority      ON employment_history(authority_id);
CREATE INDEX IF NOT EXISTS idx_eh_scale_notch    ON employment_history(salary_scale, notch_number);
CREATE INDEX IF NOT EXISTS idx_snvo_scale_date   ON salary_notch_values_official(salary_scale, notch_number, effective_from);

DROP TRIGGER IF EXISTS trg_validate_employment_history_insert;
CREATE TRIGGER trg_validate_employment_history_insert
BEFORE INSERT ON employment_history
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM salary_scales_official sso
            WHERE sso.salary_scale = NEW.salary_scale
              AND sso.is_active = 1
              AND sso.effective_from <= NEW.effective_date
              AND NEW.notch_number BETWEEN sso.min_notch AND sso.max_notch
        ) THEN RAISE(ABORT, 'Invalid salary scale/notch/effective date')
    END;

    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM salary_notch_values_official snv
            WHERE snv.salary_scale = NEW.salary_scale
              AND snv.notch_number = NEW.notch_number
              AND snv.is_active = 1
              AND snv.effective_from <= NEW.effective_date
        ) THEN RAISE(ABORT, 'No official notch value found')
    END;

    SELECT CASE
        WHEN NEW.monthly_salary != (
            SELECT snv.monthly_amount
            FROM salary_notch_values_official snv
            WHERE snv.salary_scale = NEW.salary_scale
              AND snv.notch_number = NEW.notch_number
              AND snv.is_active = 1
              AND snv.effective_from <= NEW.effective_date
            ORDER BY snv.effective_from DESC
            LIMIT 1
        ) THEN RAISE(ABORT, 'Monthly salary does not match official notch value')
    END;
END;

DROP TRIGGER IF EXISTS trg_validate_employment_history_update;
CREATE TRIGGER trg_validate_employment_history_update
BEFORE UPDATE ON employment_history
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM salary_scales_official sso
            WHERE sso.salary_scale = NEW.salary_scale
              AND sso.is_active = 1
              AND sso.effective_from <= NEW.effective_date
              AND NEW.notch_number BETWEEN sso.min_notch AND sso.max_notch
        ) THEN RAISE(ABORT, 'Invalid salary scale/notch/effective date')
    END;

    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1
            FROM salary_notch_values_official snv
            WHERE snv.salary_scale = NEW.salary_scale
              AND snv.notch_number = NEW.notch_number
              AND snv.is_active = 1
              AND snv.effective_from <= NEW.effective_date
        ) THEN RAISE(ABORT, 'No official notch value found')
    END;

    SELECT CASE
        WHEN NEW.monthly_salary != (
            SELECT snv.monthly_amount
            FROM salary_notch_values_official snv
            WHERE snv.salary_scale = NEW.salary_scale
              AND snv.notch_number = NEW.notch_number
              AND snv.is_active = 1
              AND snv.effective_from <= NEW.effective_date
            ORDER BY snv.effective_from DESC
            LIMIT 1
        ) THEN RAISE(ABORT, 'Monthly salary does not match official notch value')
    END;
END;

DROP TRIGGER IF EXISTS trg_set_employment_division_insert;
CREATE TRIGGER trg_set_employment_division_insert
AFTER INSERT ON employment_history
FOR EACH ROW
BEGIN
    UPDATE employment_history
       SET division = (
            SELECT sso.division
            FROM salary_scales_official sso
            WHERE sso.salary_scale = NEW.salary_scale
              AND sso.is_active = 1
              AND sso.effective_from <= NEW.effective_date
            ORDER BY sso.effective_from DESC
            LIMIT 1
       )
     WHERE employment_id = NEW.employment_id;
END;

DROP TRIGGER IF EXISTS trg_set_employment_division_update;
CREATE TRIGGER trg_set_employment_division_update
AFTER UPDATE OF salary_scale, notch_number, effective_date ON employment_history
FOR EACH ROW
BEGIN
    UPDATE employment_history
       SET division = (
            SELECT sso.division
            FROM salary_scales_official sso
            WHERE sso.salary_scale = NEW.salary_scale
              AND sso.is_active = 1
              AND sso.effective_from <= NEW.effective_date
            ORDER BY sso.effective_from DESC
            LIMIT 1
       )
     WHERE employment_id = NEW.employment_id;
END;
