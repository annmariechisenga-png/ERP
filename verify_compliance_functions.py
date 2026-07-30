import sqlite3
from pathlib import Path

sql = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql').read_text(encoding='utf-8')
con = sqlite3.connect('/Users/Work/Desktop/ERP/hr_platform.db')
cur = con.cursor()
cur.executescript(sql)
con.commit()

checks = {
    'views':   ['v_late_submissions', 'v_payslip_timing_violations', 'v_central_compliance_summary', 'v_compliance_report'],
    'triggers':['trg_late_submission_insert', 'payroll_payment_check', 'payroll_payment_late_warning'],
    'indexes': ['idx_ci_late_submission_dedup', 'idx_ci_authority', 'idx_cpa_authority_period'],
}

for kind, names in checks.items():
    print(f'\n=== {kind} ===')
    for name in names:
        exists = cur.execute(
            f"SELECT 1 FROM sqlite_master WHERE type=? AND name=?",
            (kind.rstrip('s'), name)
        ).fetchone()
        print(f'  {name}: {"OK" if exists else "MISSING"}')

# Functional smoke test: insert a late submission, check issue auto-created
cur.execute("INSERT OR IGNORE INTO local_authorities (authority_id, authority_code, authority_name) VALUES ('LA_SMK','SMK','Smoke Test Council')")
cur.execute("""
    INSERT OR REPLACE INTO la_payroll_submissions
        (submission_id, authority_id, period_year, period_month,
         la_payroll_date, submission_date, submission_status, payroll_data)
    VALUES
        ('SUB_SMK','LA_SMK',2026,2,
         '2026-02-25','2026-02-14 09:00:00','PENDING','{}')
""")
con.commit()

issue = cur.execute("""
    SELECT issue_type, issue_severity, days_late
    FROM compliance_issues
    WHERE submission_id='SUB_SMK'
""").fetchone()
print(f'\n=== Auto-issue trigger ===')
print(f'  Late submission issue created: {issue}')

# v_late_submissions view
row = cur.execute("""
    SELECT authority_name, days_late, severity
    FROM v_late_submissions
    WHERE submission_id='SUB_SMK'
""").fetchone()
print(f'  v_late_submissions row: {row}')

# clean up
cur.execute("DELETE FROM compliance_issues WHERE submission_id='SUB_SMK'")
cur.execute("DELETE FROM la_payroll_submissions WHERE submission_id='SUB_SMK'")
cur.execute("DELETE FROM local_authorities WHERE authority_id='LA_SMK'")
con.commit()
con.close()
print('\ndone')
