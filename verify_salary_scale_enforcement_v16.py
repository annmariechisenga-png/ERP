import sqlite3
from pathlib import Path

DB_PATH = '/Users/Work/Desktop/ERP/hr_platform.db'
SQL_PATH = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql')


def apply_section_16(conn):
    text = SQL_PATH.read_text(encoding='utf-8')
    marker = '-- §16  SALARY SCALE & NOTCH ENFORCEMENT SYSTEM (SQLITE)'
    parts = text.split(marker)
    if len(parts) < 2:
        raise RuntimeError('§16 block not found')
    block = marker + parts[-1]
    conn.executescript(block)


def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    apply_section_16(conn)

    print('tables:')
    for name in ['salary_scales_official', 'salary_notch_values_official', 'employment_history']:
        exists = cur.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name=?", (name,)).fetchone()
        print(f'  {name}:', 'OK' if exists else 'MISSING')

    print('triggers:')
    for name in [
        'trg_validate_employment_history_insert',
        'trg_validate_employment_history_update',
        'trg_set_employment_division_insert',
        'trg_set_employment_division_update',
    ]:
        exists = cur.execute("SELECT 1 FROM sqlite_master WHERE type='trigger' AND name=?", (name,)).fetchone()
        print(f'  {name}:', 'OK' if exists else 'MISSING')

    authority_id = cur.execute("SELECT authority_id FROM local_authorities WHERE authority_code='KTC' LIMIT 1").fetchone()[0]

    # clean test rows
    cur.execute("DELETE FROM employment_history WHERE approval_reference IN ('TEST-V16-VALID','TEST-V16-BAD-SALARY','TEST-V16-BAD-NOTCH')")

    # valid insert
    cur.execute(
        """
        INSERT INTO employment_history (
            employment_id, employee_id, authority_id,
            salary_scale, notch_number, monthly_salary,
            approved_by, approval_date, approval_reference, effective_date
        ) VALUES (
            'eh-v16-valid', 'emp-v16-1', ?,
            'LGSS08', 1, 10273,
            'approver-v16', '2026-03-16', 'TEST-V16-VALID', '2026-03-01'
        )
        """,
        (authority_id,)
    )

    row = cur.execute("SELECT salary_scale, notch_number, monthly_salary, division FROM employment_history WHERE employment_id='eh-v16-valid'").fetchone()
    print('valid insert row:', row)

    # invalid salary should fail
    bad_salary_error = None
    try:
        cur.execute(
            """
            INSERT INTO employment_history (
                employment_id, employee_id, authority_id,
                salary_scale, notch_number, monthly_salary,
                approved_by, approval_date, approval_reference, effective_date
            ) VALUES (
                'eh-v16-bad-salary', 'emp-v16-2', ?,
                'LGSS08', 1, 9999,
                'approver-v16', '2026-03-16', 'TEST-V16-BAD-SALARY', '2026-03-01'
            )
            """,
            (authority_id,)
        )
    except Exception as e:
        bad_salary_error = str(e)

    # invalid notch should fail
    bad_notch_error = None
    try:
        cur.execute(
            """
            INSERT INTO employment_history (
                employment_id, employee_id, authority_id,
                salary_scale, notch_number, monthly_salary,
                approved_by, approval_date, approval_reference, effective_date
            ) VALUES (
                'eh-v16-bad-notch', 'emp-v16-3', ?,
                'LGSS08', 99, 10273,
                'approver-v16', '2026-03-16', 'TEST-V16-BAD-NOTCH', '2026-03-01'
            )
            """,
            (authority_id,)
        )
    except Exception as e:
        bad_notch_error = str(e)

    print('bad salary blocked:', bool(bad_salary_error), '|', bad_salary_error)
    print('bad notch blocked :', bool(bad_notch_error), '|', bad_notch_error)

    # cleanup
    cur.execute("DELETE FROM employment_history WHERE employment_id IN ('eh-v16-valid','eh-v16-bad-salary','eh-v16-bad-notch')")

    conn.commit()
    conn.close()


if __name__ == '__main__':
    main()
