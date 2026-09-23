import sqlite3
from pathlib import Path

DB_PATH = '/Users/Work/Desktop/ERP/hr_platform.db'
SQL_PATH = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql')


def apply_section_14(conn):
    text = SQL_PATH.read_text(encoding='utf-8')
    marker = '-- §14  LA PAYROLL DASHBOARD (READ-ONLY HARDSHIP DESIGNATION)'
    parts = text.split(marker)
    if len(parts) < 2:
        raise RuntimeError('§14 block not found')
    block = marker + parts[-1]
    conn.executescript(block)


def main():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    apply_section_14(conn)

    has_view = cur.execute(
        "SELECT name FROM sqlite_master WHERE type='view' AND name='la_payroll_dashboard'"
    ).fetchone()
    has_ctx = cur.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='la_session_context'"
    ).fetchone()

    print('View exists   :', bool(has_view))
    print('Context exists:', bool(has_ctx))

    ktc = cur.execute(
        "SELECT authority_id FROM local_authorities WHERE authority_code='KTC' LIMIT 1"
    ).fetchone()
    if not ktc:
        raise RuntimeError('KTC authority not found')

    cur.execute("DELETE FROM la_session_context WHERE context_id=1")
    cur.execute(
        "INSERT INTO la_session_context(context_id, authority_id) VALUES (1, ?)",
        (ktc[0],)
    )

    rows = cur.execute("""
        SELECT authority_code, authority_name, hardship_status, circular_reference, designated_from
        FROM la_payroll_dashboard
    """).fetchall()

    print('\nDashboard rows:', len(rows))
    for row in rows:
        print(' ', row)

    conn.commit()
    conn.close()


if __name__ == '__main__':
    main()
