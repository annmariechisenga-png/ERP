"""
generate_hardship_compliance_report.py
SQLite equivalent of hardship_compliance_report(year, month).

Usage:
    python3 generate_hardship_compliance_report.py 2026 3
    python3 generate_hardship_compliance_report.py 2026 3 --out hardship_2026_03.json
"""
import argparse
import json
import sqlite3
from datetime import datetime
from pathlib import Path

DB = Path('/Users/Work/Desktop/ERP/hr_platform.db')


def generate(year: int, month: int) -> dict:
    con = sqlite3.connect(str(DB))
    cur = con.cursor()

    rows = cur.execute("""
        SELECT
            authority_name,
            official_designation,
            employees_claiming,
            total_amount,
            compliant,
            violation_details
        FROM v_hardship_compliance_report
        WHERE period_year = ? AND period_month = ?
        ORDER BY authority_name
    """, (year, month)).fetchall()

    con.close()

    payload = {
        'report_period': f'{year}-{month:02d}',
        'generated_at': datetime.now().isoformat(timespec='seconds'),
        'rows': [
            {
                'authority_name': r[0],
                'official_designation': r[1],
                'employees_claiming': int(r[2] or 0),
                'total_amount': float(r[3] or 0),
                'compliant': bool(r[4]),
                'violation_details': r[5],
            }
            for r in rows
        ],
        'summary': {
            'total_authorities': len(rows),
            'compliant_count': sum(1 for r in rows if bool(r[4])),
            'non_compliant_count': sum(1 for r in rows if not bool(r[4])),
        }
    }
    return payload


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate hardship compliance report')
    parser.add_argument('year', type=int)
    parser.add_argument('month', type=int)
    parser.add_argument('--out', default=None,
                        help='Output JSON file (default: print to stdout)')
    args = parser.parse_args()

    report = generate(args.year, args.month)
    out_json = json.dumps(report, indent=2)

    if args.out:
        Path(args.out).write_text(out_json, encoding='utf-8')
        print(f'Report written to {args.out}')
    else:
        print(out_json)
