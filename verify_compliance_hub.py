import sqlite3
from pathlib import Path

sql = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql').read_text(encoding='utf-8')
con = sqlite3.connect('/Users/Work/Desktop/ERP/hr_platform.db')
cur = con.cursor()
cur.executescript(sql)
con.commit()

expected_tables = [
    'la_payroll_config',
    'la_payroll_submissions',
    'compliance_issues',
    'central_payslip_archive',
]
expected_views = ['v_central_compliance_summary']

print('=== Tables ===')
for t in expected_tables:
    exists = cur.execute(
        "SELECT 1 FROM sqlite_master WHERE type='table' AND name=?", (t,)
    ).fetchone()
    print(f'  {t}: {"OK" if exists else "MISSING"}')
    if exists:
        cols = [r[1] for r in cur.execute(f'PRAGMA table_info({t})').fetchall()]
        print(f'    cols ({len(cols)}): {", ".join(cols[:8])}{"..." if len(cols)>8 else ""}')

print('\n=== Views ===')
for v in expected_views:
    exists = cur.execute(
        "SELECT 1 FROM sqlite_master WHERE type='view' AND name=?", (v,)
    ).fetchone()
    print(f'  {v}: {"OK" if exists else "MISSING"}')
    if exists:
        cols = [d[0] for d in cur.execute(f'SELECT * FROM {v} LIMIT 0').description]
        print(f'    cols: {", ".join(cols)}')

print('\n=== Indexes ===')
for idx in ['idx_ci_authority','idx_ci_submission','idx_ci_status','idx_cpa_authority_period','idx_cpa_employee']:
    exists = cur.execute(
        "SELECT 1 FROM sqlite_master WHERE type='index' AND name=?", (idx,)
    ).fetchone()
    print(f'  {idx}: {"OK" if exists else "MISSING"}')

con.close()
print('\ndone')
