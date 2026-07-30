import sqlite3
from pathlib import Path

ROOT = Path('/Users/Work/Desktop/ERP')
DB_PATH = ROOT / 'hr_platform.db'
OUT_PATH = ROOT / 'payroll_forced_official_matches_review_2026-03-16.md'

conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
cur = conn.cursor()
rows = cur.execute(
    '''
    SELECT
        record_source,
        record_id,
        employee_name,
        original_position_title,
        original_department,
        original_salary_scale_code,
        establishment_match_method,
        matched_position_code,
        matched_position_title,
        matched_department_name,
        matched_salary_scale_code,
        council_type_id,
        matched_source_table
    FROM vw_payroll_forced_official_matches
    ORDER BY record_source, employee_name, original_position_title, matched_department_name, matched_position_title
    '''
).fetchall()

lines = []
lines.append('# Forced Official Matches Review')
lines.append('')
lines.append('Generated: 2026-03-16')
lines.append(f'Total records: {len(rows)}')
lines.append('')

by_source = {}
for row in rows:
    by_source.setdefault(row['record_source'], []).append(row)

for source in ['EMPLOYEE', 'PAYROLL']:
    group = by_source.get(source, [])
    lines.append(f'## {source} ({len(group)})')
    lines.append('')
    for idx, row in enumerate(group, start=1):
        lines.append(f"### {source} {idx}")
        lines.append(f"- Record ID: {row['record_id']}")
        lines.append(f"- Employee Name: {row['employee_name']}")
        lines.append(f"- Original Position: {row['original_position_title']}")
        lines.append(f"- Original Department: {row['original_department'] or 'N/A'}")
        lines.append(f"- Original Salary Scale: {row['original_salary_scale_code'] or 'N/A'}")
        lines.append(f"- Match Method: {row['establishment_match_method']}")
        lines.append(f"- Matched Position Code: {row['matched_position_code']}")
        lines.append(f"- Matched Position Title: {row['matched_position_title']}")
        lines.append(f"- Matched Department: {row['matched_department_name']}")
        lines.append(f"- Matched Salary Scale: {row['matched_salary_scale_code'] or 'N/A'}")
        lines.append(f"- Council Type ID: {row['council_type_id'] if row['council_type_id'] is not None else 'N/A'}")
        lines.append(f"- Matched Source Table: {row['matched_source_table']}")
        lines.append('')

OUT_PATH.write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(OUT_PATH)
print(len(rows))
conn.close()
