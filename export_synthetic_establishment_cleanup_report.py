import csv
import json
import sqlite3
from pathlib import Path

ROOT = Path('/Users/Work/Desktop/ERP')
DB_PATH = ROOT / 'hr_platform.db'
CSV_PATH = ROOT / 'payroll_synthetic_establishment_cleanup_report_2026-03-16.csv'
JSON_PATH = ROOT / 'payroll_synthetic_establishment_cleanup_report_2026-03-16.json'

FIELDNAMES = [
    'position_code',
    'position_title',
    'department_name',
    'salary_scale_code',
    'authorized_establishment',
    'council_type_id',
    'employee_count',
    'employee_ids',
    'employee_names',
    'recommended_action',
    'source_table',
]

conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
cur = conn.cursor()
rows = cur.execute('SELECT * FROM vw_payroll_synthetic_establishment_cleanup').fetchall()

with CSV_PATH.open('w', newline='', encoding='utf-8') as handle:
    writer = csv.DictWriter(handle, fieldnames=FIELDNAMES)
    writer.writeheader()
    for row in rows:
        writer.writerow({name: row[name] for name in FIELDNAMES})

payload = {
    'generated_on': '2026-03-16',
    'record_count': len(rows),
    'records': [{name: row[name] for name in FIELDNAMES} for row in rows],
}
JSON_PATH.write_text(json.dumps(payload, indent=2), encoding='utf-8')

print(f'csv {CSV_PATH}')
print(f'json {JSON_PATH}')
print(f'records {len(rows)}')

conn.close()
