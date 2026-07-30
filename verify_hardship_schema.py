import sqlite3
from pathlib import Path

db = '/Users/Work/Desktop/ERP/hr_platform.db'
sql_file = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql')

text = sql_file.read_text(encoding='utf-8')
parts = text.split('-- §12  HARDSHIP ALLOWANCE CONTROL SYSTEM')
if len(parts) < 2:
    raise RuntimeError('§12 block not found in file')
block = '-- §12  HARDSHIP ALLOWANCE CONTROL SYSTEM' + parts[-1]

conn = sqlite3.connect(db)
cur = conn.cursor()
errors = []
try:
    conn.executescript(block)
except Exception as e:
    errors.append(str(e))

tables = [r[0] for r in cur.execute(
    "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%hardship%'").fetchall()]
indexes = [r[0] for r in cur.execute(
    "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_sh%'").fetchall()]
triggers = [r[0] for r in cur.execute(
    "SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE 'trg_shc%'").fetchall()]

print('Tables  :', tables)
print('Indexes :', indexes)
print('Triggers:', triggers)

rows = cur.execute("""
    SELECT la.authority_code,
           shc.is_remote_hardship, shc.is_rural_hardship,
           shc.circular_reference, shc.criteria_met
    FROM station_hardship_classification shc
    JOIN local_authorities la USING (authority_id)
    ORDER BY la.authority_code
""").fetchall()
print('\nSeed rows:', len(rows))
for r in rows:
    print(' ', r)

if errors:
    print('\nERRORS:')
    for e in errors:
        print(' ', e)
else:
    print('\nAll statements applied OK')

conn.close()
