import csv
import json
import sqlite3
from pathlib import Path

ROOT = Path('/Users/Work/Desktop/ERP')
DB_PATH = ROOT / 'hr_platform.db'
CSV_PATH = ROOT / 'payroll_forced_official_matches_report_2026-03-16.csv'
JSON_PATH = ROOT / 'payroll_forced_official_matches_report_2026-03-16.json'

FIELDNAMES = [
    'record_source',
    'record_id',
    'employee_name',
    'original_position_title',
    'original_department',
    'original_salary_scale_code',
    'establishment_match_method',
    'matched_position_code',
    'matched_position_title',
    'matched_department_name',
    'matched_salary_scale_code',
    'council_type_id',
    'matched_source_table',
]

conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
cur = conn.cursor()
rows = cur.execute('SELECT * FROM vw_payroll_forced_official_matches').fetchall()

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
