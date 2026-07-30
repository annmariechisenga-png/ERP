import sqlite3
from pathlib import Path

DB_PATH = '/Users/Work/Desktop/ERP/hr_platform.db'
SQL_PATH = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql')


def apply_section_15(conn):
    text = SQL_PATH.read_text(encoding='utf-8')
    marker = '-- §15  MINISTRY HARDSHIP ALLOWANCE COMPLIANCE REPORT (SQLITE)'
    parts = text.split(marker)
    if len(parts) < 2:
        raise RuntimeError('§15 block not found')
    block = marker + parts[-1]
    conn.executescript(block)


def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    apply_section_15(conn)

    has_view = cur.execute(
        "SELECT name FROM sqlite_master WHERE type='view' AND name='v_hardship_compliance_report'"
    ).fetchone()
    print('View exists:', bool(has_view))

    rows = cur.execute("""
        SELECT period_year, period_month, authority_name, official_designation,
               employees_claiming, total_amount, compliant, violation_details
        FROM v_hardship_compliance_report
        WHERE period_year = 2026 AND period_month = 3
        ORDER BY authority_name
        LIMIT 20
    """).fetchall()

    print('Rows for 2026-03:', len(rows))
    for row in rows:
        print(row)

    conn.close()


if __name__ == '__main__':
    main()
