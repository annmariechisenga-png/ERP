"""
generate_ministry_report.py
SQLite equivalent of generate_ministry_compliance_report(year, month).

Usage:
    python3 generate_ministry_report.py 2026 3
    python3 generate_ministry_report.py 2026 3 --out report_2026_03.json
"""
import json
import sqlite3
import sys
from datetime import date, datetime
from pathlib import Path

DB = Path('/Users/Work/Desktop/ERP/hr_platform.db')


def _deadline(year: int, month: int) -> str:
    return f'{year}-{month:02d}-05'


def _period_bounds(year: int, month: int):
    start = f'{year}-{month:02d}-01'
    if month == 12:
        end = f'{year + 1}-01-01'
    else:
        end = f'{year}-{month + 1:02d}-01'
    return start, end


def run_late_submission_check(cur, year: int, month: int):
    """Auto-insert compliance issues for any late submissions (idempotent)."""
    deadline = _deadline(year, month)
    rows = cur.execute("""
        SELECT lps.submission_id, lps.authority_id, date(lps.submission_date) AS sub_date
        FROM la_payroll_submissions lps
        WHERE lps.period_year = ? AND lps.period_month = ?
          AND date(lps.submission_date) > ?
    """, (year, month, deadline)).fetchall()

    for sub_id, auth_id, sub_date in rows:
        days_late = int((date.fromisoformat(sub_date) - date.fromisoformat(deadline)).days)
        severity = 'MINOR' if days_late <= 5 else ('MAJOR' if days_late <= 15 else 'CRITICAL')
        cur.execute("""
            INSERT OR IGNORE INTO compliance_issues (
                issue_id, authority_id, submission_id,
                issue_type, issue_severity, issue_description,
                days_late, deadline_date, submission_date
            ) VALUES (
                lower(hex(randomblob(16))), ?, ?,
                'LATE_SUBMISSION', ?, ?,
                ?, ?, ?
            )
        """, (
            auth_id, sub_id, severity,
            f'Payroll data submitted {days_late} days late',
            days_late, deadline, sub_date
        ))


def generate(year: int, month: int) -> dict:
    con = sqlite3.connect(str(DB))
    cur = con.cursor()

    run_late_submission_check(cur, year, month)
    con.commit()

    deadline = _deadline(year, month)
    period_start, period_end = _period_bounds(year, month)

    total_authorities = cur.execute(
        "SELECT COUNT(*) FROM local_authorities WHERE is_active = 1"
    ).fetchone()[0]

    submitted_on_time = cur.execute("""
        SELECT COUNT(*) FROM la_payroll_submissions
        WHERE period_year = ? AND period_month = ?
          AND date(submission_date) <= ?
    """, (year, month, deadline)).fetchone()[0]

    submitted_late = cur.execute("""
        SELECT COUNT(*) FROM la_payroll_submissions
        WHERE period_year = ? AND period_month = ?
          AND date(submission_date) > ?
    """, (year, month, deadline)).fetchone()[0]

    not_submitted = cur.execute("""
        SELECT COUNT(*) FROM local_authorities la
        WHERE la.is_active = 1
          AND NOT EXISTS (
              SELECT 1 FROM la_payroll_submissions lps
              WHERE lps.authority_id = la.authority_id
                AND lps.period_year  = ?
                AND lps.period_month = ?
          )
    """, (year, month)).fetchone()[0]

    critical_rows = cur.execute("""
        SELECT la.authority_name, ci.issue_description, ci.issue_severity
        FROM compliance_issues ci
        JOIN local_authorities la ON ci.authority_id = la.authority_id
        WHERE ci.issue_severity    = 'CRITICAL'
          AND ci.resolution_status = 'OPEN'
          AND date(ci.created_at) >= ?
          AND date(ci.created_at)  < ?
    """, (period_start, period_end)).fetchall()

    total_issues = cur.execute("""
        SELECT COUNT(*) FROM compliance_issues
        WHERE date(created_at) >= ? AND date(created_at) < ?
    """, (period_start, period_end)).fetchone()[0]

    # Late-submission authority detail
    late_detail = cur.execute("""
        SELECT la.authority_name, ls.days_late, ls.severity, ls.submitted_on
        FROM v_late_submissions ls
        JOIN local_authorities la ON ls.authority_id = la.authority_id
        WHERE ls.period_year = ? AND ls.period_month = ? AND ls.days_late > 0
        ORDER BY ls.days_late DESC
    """, (year, month)).fetchall()

    # Section-105 violations
    violations = cur.execute("""
        SELECT authority_name, employee_name, payslip_generated_date,
               payment_date, days_after_payment
        FROM v_payslip_timing_violations
        WHERE period_year = ? AND period_month = ?
    """, (year, month)).fetchall()

    con.close()

    report = {
        'report_period':     f'{year}-{month:02d}',
        'generated_at':      datetime.now().isoformat(timespec='seconds'),
        'total_authorities': total_authorities,
        'submitted_on_time': submitted_on_time,
        'submitted_late':    submitted_late,
        'not_submitted':     not_submitted,
        'late_detail': [
            {'authority': r[0], 'days_late': r[1],
             'severity': r[2], 'submitted_on': r[3]}
            for r in late_detail
        ],
        'section_105_violations': [
            {'authority': r[0], 'employee': r[1],
             'payslip_date': r[2], 'payment_date': r[3],
             'days_after_payment': r[4]}
            for r in violations
        ],
        'critical_issues': [
            {'authority': r[0], 'issue': r[1], 'severity': r[2]}
            for r in critical_rows
        ],
        'summary': (
            f'Compliance monitoring complete - {total_issues} issue(s) identified. '
            f'{submitted_on_time} on time, {submitted_late} late, '
            f'{not_submitted} not submitted.'
        ),
    }
    return report


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description='Generate ministry compliance report')
    parser.add_argument('year',  type=int)
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
