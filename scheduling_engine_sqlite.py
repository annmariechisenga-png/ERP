import argparse
import calendar
import json
import sqlite3
import uuid
from dataclasses import dataclass
from datetime import date, datetime, timedelta
from pathlib import Path


@dataclass
class ScheduleRow:
    authority_code: str
    scheduled_payment_date: str
    payslip_generation_date: str


def get_connection(db_path: str):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row
    return con


def ensure_is_active_column(cur):
    cols = {r['name'] for r in cur.execute('PRAGMA table_info(local_authorities)').fetchall()}
    if 'is_active' not in cols:
        cur.execute('ALTER TABLE local_authorities ADD COLUMN is_active INTEGER DEFAULT 1')


def clamp_day(year: int, month: int, day: int) -> int:
    day = max(1, day)
    last = calendar.monthrange(year, month)[1]
    return min(day, last)


def adjust_weekend_to_friday(d: date) -> date:
    # Monday=0 ... Sunday=6
    if d.weekday() == 5:  # Saturday
        return d - timedelta(days=1)
    if d.weekday() == 6:  # Sunday
        return d - timedelta(days=2)
    return d


def generate_payroll_schedules(db_path: str, year: int, month: int):
    con = get_connection(db_path)
    cur = con.cursor()
    ensure_is_active_column(cur)

    rows = cur.execute(
        """
        SELECT authority_id, authority_code, COALESCE(standard_pay_day, 25) AS standard_pay_day
        FROM local_authorities
        WHERE COALESCE(is_active, 1) = 1
        ORDER BY authority_code
        """
    ).fetchall()

    out = []
    for row in rows:
        pay_day = clamp_day(year, month, int(row['standard_pay_day']))
        payment_date = adjust_weekend_to_friday(date(year, month, pay_day))
        payslip_date = payment_date - timedelta(days=2)

        schedule_id = f"SCH-{row['authority_code']}-{year}{month:02d}"
        cur.execute(
            """
            INSERT INTO payroll_schedules (
                schedule_id, authority_id, period_year, period_month,
                scheduled_payment_date, payslip_generation_date, status
            ) VALUES (?, ?, ?, ?, ?, ?, 'SCHEDULED')
            ON CONFLICT(authority_id, period_year, period_month)
            DO UPDATE SET
                scheduled_payment_date = excluded.scheduled_payment_date,
                payslip_generation_date = excluded.payslip_generation_date,
                status = 'SCHEDULED'
            """,
            (
                schedule_id,
                row['authority_id'],
                year,
                month,
                payment_date.isoformat(),
                payslip_date.isoformat(),
            ),
        )

        out.append(
            ScheduleRow(
                authority_code=row['authority_code'],
                scheduled_payment_date=payment_date.isoformat(),
                payslip_generation_date=payslip_date.isoformat(),
            )
        )

    con.commit()
    con.close()
    return out


def authority_employee_count(cur, authority_id: str):
    auth = cur.execute(
        'SELECT authority_code FROM local_authorities WHERE authority_id = ?',
        (authority_id,),
    ).fetchone()
    if not auth:
        return 0
    code = auth['authority_code']

    # SQLite model fallback: infer authority membership by employee_id or LAS number prefix
    row = cur.execute(
        """
        SELECT COUNT(*) AS c
        FROM employees
        WHERE COALESCE(is_active, 1) = 1
          AND (
              UPPER(COALESCE(employee_id, '')) LIKE ?
              OR UPPER(COALESCE(local_authority_service_number, '')) LIKE ?
          )
        """,
        (f'{code}-%', f'{code}%'),
    ).fetchone()
    return int(row['c'] if row else 0)


def validate_payslip_before_payment(db_path: str, authority_id: str, schedule_id: str):
    con = get_connection(db_path)
    cur = con.cursor()

    schedule = cur.execute(
        'SELECT * FROM payroll_schedules WHERE schedule_id = ?',
        (schedule_id,),
    ).fetchone()
    if not schedule:
        con.close()
        return {'ok': False, 'message': 'Schedule not found'}

    employee_count = authority_employee_count(cur, authority_id)
    payslip_count_row = cur.execute(
        'SELECT COUNT(*) AS c FROM payroll_run WHERE schedule_id = ?',
        (schedule_id,),
    ).fetchone()
    payslip_count = int(payslip_count_row['c'] if payslip_count_row else 0)

    if payslip_count < employee_count:
        con.close()
        return {
            'ok': False,
            'message': f'Missing payslips for {employee_count - payslip_count} employees',
            'employee_count': employee_count,
            'payslip_count': payslip_count,
        }

    cur.execute(
        """
        UPDATE payroll_run
        SET payslip_available_date = COALESCE(payslip_available_date, ?)
        WHERE schedule_id = ?
        """,
        (datetime.now().isoformat(timespec='seconds'), schedule_id),
    )

    warning = None
    if date.today().isoformat() > (schedule['payslip_generation_date'] or ''):
        warning = f"Payslips generated late: {date.today().isoformat()} > {schedule['payslip_generation_date']}"

    con.commit()
    con.close()
    return {
        'ok': True,
        'warning': warning,
        'employee_count': employee_count,
        'payslip_count': payslip_count,
    }


def process_authority_payment(db_path: str, authority_id: str, schedule_id: str):
    validation = validate_payslip_before_payment(db_path, authority_id, schedule_id)
    if not validation.get('ok'):
        return {'success': False, 'message': validation.get('message', 'Validation failed')}

    con = get_connection(db_path)
    cur = con.cursor()

    schedule = cur.execute(
        'SELECT * FROM payroll_schedules WHERE schedule_id = ?',
        (schedule_id,),
    ).fetchone()
    if not schedule:
        con.close()
        return {'success': False, 'message': 'Schedule not found'}

    agg = cur.execute(
        'SELECT COALESCE(SUM(net_pay),0) AS total, COUNT(*) AS cnt FROM payroll_run WHERE schedule_id = ?',
        (schedule_id,),
    ).fetchone()

    total_amount = float(agg['total'] if agg else 0)
    employee_count = int(agg['cnt'] if agg else 0)

    auth = cur.execute(
        'SELECT authority_code FROM local_authorities WHERE authority_id = ?',
        (authority_id,),
    ).fetchone()
    authority_code = auth['authority_code'] if auth else authority_id

    batch_reference = f"PAY-{authority_code}-{date.today().strftime('%Y%m%d')}"
    batch_id = f"BATCH-{uuid.uuid4().hex[:12].upper()}"

    cur.execute(
        """
        INSERT INTO payment_batches (
            batch_id, authority_id, schedule_id, batch_reference, batch_date,
            total_amount, employee_count, status
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'CREATED')
        """,
        (
            batch_id,
            authority_id,
            schedule_id,
            batch_reference,
            date.today().isoformat(),
            total_amount,
            employee_count,
        ),
    )

    cur.execute(
        """
        UPDATE payroll_run
        SET payment_status = 'PROCESSED',
            payment_due_date = ?
        WHERE schedule_id = ?
        """,
        (schedule['scheduled_payment_date'], schedule_id),
    )

    cur.execute(
        """
        UPDATE payroll_schedules
        SET status = 'PAYSLIPS_READY'
        WHERE schedule_id = ? AND status = 'SCHEDULED'
        """,
        (schedule_id,),
    )

    con.commit()
    con.close()

    result = {
        'success': True,
        'batch_id': batch_id,
        'authority_id': authority_id,
        'payment_date': schedule['scheduled_payment_date'],
        'total_amount': total_amount,
        'employee_count': employee_count,
        'message': 'Payment batch created. Payslips already available.',
    }
    if validation.get('warning'):
        result['warning'] = validation['warning']
    return result


def parse_args():
    parser = argparse.ArgumentParser(description='SQLite scheduling engine for local-authority payroll')
    parser.add_argument('--db-path', default='/Users/Work/Desktop/ERP/hr_platform.db')

    sub = parser.add_subparsers(dest='cmd', required=True)

    g = sub.add_parser('generate')
    g.add_argument('--year', type=int, required=True)
    g.add_argument('--month', type=int, required=True)

    v = sub.add_parser('validate')
    v.add_argument('--authority-id', required=True)
    v.add_argument('--schedule-id', required=True)

    p = sub.add_parser('process')
    p.add_argument('--authority-id', required=True)
    p.add_argument('--schedule-id', required=True)

    return parser.parse_args()


def main():
    args = parse_args()

    if args.cmd == 'generate':
        rows = generate_payroll_schedules(args.db_path, args.year, args.month)
        for row in rows:
            print(f"{row.authority_code} | {row.scheduled_payment_date} | {row.payslip_generation_date}")
        return

    if args.cmd == 'validate':
        print(json.dumps(validate_payslip_before_payment(args.db_path, args.authority_id, args.schedule_id), indent=2))
        return

    if args.cmd == 'process':
        print(json.dumps(process_authority_payment(args.db_path, args.authority_id, args.schedule_id), indent=2))


if __name__ == '__main__':
    main()
