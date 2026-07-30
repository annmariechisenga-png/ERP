import sqlite3
from pathlib import Path

DB_PATH = '/Users/Work/Desktop/ERP/hr_platform.db'
SQL_PATH = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql')


def apply_section_13(conn):
    text = SQL_PATH.read_text(encoding='utf-8')
    marker = '-- §13  HARDSHIP ELIGIBILITY + CLAIM VALIDATION (SQLITE EQUIVALENTS)'
    parts = text.split(marker)
    if len(parts) < 2:
        raise RuntimeError('§13 block not found')
    block = marker + parts[-1]
    conn.executescript(block)


def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    apply_section_13(conn)

    views = [r[0] for r in cur.execute(
        "SELECT name FROM sqlite_master WHERE type='view' AND name IN ('la_hardship_eligibility','v_hardship_allowance_rates','v_hardship_claim_validation') ORDER BY name"
    ).fetchall()]
    indexes = [r[0] for r in cur.execute(
        "SELECT name FROM sqlite_master WHERE type='index' AND name IN ('idx_ci_unauth_remote_dedup','idx_ci_unauth_rural_dedup') ORDER BY name"
    ).fetchall()]
    triggers = [r[0] for r in cur.execute(
        "SELECT name FROM sqlite_master WHERE type='trigger' AND name='trg_validate_hardship_claims_insert'"
    ).fetchall()]

    print('Views   :', views)
    print('Indexes :', indexes)
    print('Trigger :', triggers)

    elig = cur.execute("""
        SELECT authority_code, is_remote_hardship, is_rural_hardship
        FROM la_hardship_eligibility
        ORDER BY authority_code
    """).fetchall()
    print('\nEligibility rows:', len(elig))
    for row in elig:
        print(' ', row)

    authority = cur.execute("""
        SELECT authority_id, authority_code
        FROM local_authorities
        WHERE authority_code = 'LCC'
        LIMIT 1
    """).fetchone()
    if not authority:
        raise RuntimeError('LCC authority not found for smoke test')

    authority_id, authority_code = authority
    submission_id = 'test-hardship-submission-20260316'
    archive_id = 'test-hardship-archive-20260316'

    cur.execute("DELETE FROM compliance_issues WHERE submission_id = ?", (submission_id,))
    cur.execute("DELETE FROM central_payslip_archive WHERE archive_id = ?", (archive_id,))
    cur.execute("DELETE FROM la_payroll_submissions WHERE submission_id = ?", (submission_id,))

    cur.execute(
        """
        INSERT INTO la_payroll_submissions (
            submission_id, authority_id, period_year, period_month, payroll_data, submission_status
        ) VALUES (?, ?, 2026, 3, ?, 'PENDING')
        """,
        (submission_id, authority_id, '{"employees": 1}')
    )

    cur.execute(
        """
        INSERT INTO central_payslip_archive (
            archive_id, authority_id, submission_id, period_year, period_month,
            employee_number, employee_name, basic_salary, net_pay, payslip_data
        ) VALUES (?, ?, ?, 2026, 3, 'E001', 'Hardship Test Officer', 10000, 9500, ?)
        """,
        (archive_id, authority_id, submission_id, '{"allowances":["REMOTE"]}')
    )

    issue_rows = cur.execute(
        """
        SELECT issue_type, issue_severity, issue_description
        FROM compliance_issues
        WHERE submission_id = ?
          AND issue_type IN ('UNAUTHORIZED_REMOTE_CLAIM', 'UNAUTHORIZED_RURAL_CLAIM')
        ORDER BY issue_type
        """,
        (submission_id,)
    ).fetchall()

    print(f"\nFraud smoke test authority={authority_code}:")
    print('  Issues created:', len(issue_rows))
    for row in issue_rows:
        print('   ', row)

    cur.execute("DELETE FROM compliance_issues WHERE submission_id = ?", (submission_id,))
    cur.execute("DELETE FROM central_payslip_archive WHERE archive_id = ?", (archive_id,))
    cur.execute("DELETE FROM la_payroll_submissions WHERE submission_id = ?", (submission_id,))

    conn.commit()
    conn.close()


if __name__ == '__main__':
    main()
