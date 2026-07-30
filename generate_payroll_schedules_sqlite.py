import argparse
import calendar
import sqlite3
from datetime import date, timedelta

DB_PATH = '/Users/Work/Desktop/ERP/hr_platform.db'


def adjusted_pay_date(year: int, month: int, day: int) -> date:
    last_day = calendar.monthrange(year, month)[1]
    safe_day = min(max(day, 1), last_day)
    pay_date = date(year, month, safe_day)
    if pay_date.weekday() == 5:
        pay_date -= timedelta(days=1)
    elif pay_date.weekday() == 6:
        pay_date -= timedelta(days=2)
    return pay_date


def ensure_is_active_column(cur):
    cols = {r[1] for r in cur.execute('PRAGMA table_info(local_authorities)').fetchall()}
    if 'is_active' not in cols:
        cur.execute('ALTER TABLE local_authorities ADD COLUMN is_active INTEGER DEFAULT 1')
        cur.execute('UPDATE local_authorities SET is_active = 1 WHERE is_active IS NULL')


def generate_schedules(year: int, month: int):
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    ensure_is_active_column(cur)

    authorities = cur.execute(
        '''
        SELECT authority_id, authority_code, COALESCE(standard_pay_day, 25)
        FROM local_authorities
        WHERE COALESCE(is_active, 1) = 1
        ORDER BY authority_code
        '''
    ).fetchall()

    generated = []
    for authority_id, authority_code, standard_pay_day in authorities:
        pay_date = adjusted_pay_date(year, month, int(standard_pay_day))
        payslip_date = pay_date - timedelta(days=2)
        schedule_id = f'SCH-{authority_code}-{year}{month:02d}'

        cur.execute(
            '''
            INSERT OR REPLACE INTO payroll_schedules (
                schedule_id, authority_id, period_year, period_month,
                payroll_cutoff_date, processing_start_date, processing_end_date,
                payslip_generation_date, scheduled_payment_date,
                actual_payslip_date, actual_payment_date,
                status, delay_reason
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,
                      COALESCE((SELECT actual_payslip_date FROM payroll_schedules WHERE schedule_id=?), NULL),
                      COALESCE((SELECT actual_payment_date FROM payroll_schedules WHERE schedule_id=?), NULL),
                      COALESCE((SELECT status FROM payroll_schedules WHERE schedule_id=?), 'SCHEDULED'),
                      COALESCE((SELECT delay_reason FROM payroll_schedules WHERE schedule_id=?), NULL))
            ''',
            (
                schedule_id,
                authority_id,
                year,
                month,
                (payslip_date - timedelta(days=3)).isoformat(),
                (payslip_date - timedelta(days=2)).isoformat(),
                (payslip_date - timedelta(days=1)).isoformat(),
                payslip_date.isoformat(),
                pay_date.isoformat(),
                schedule_id,
                schedule_id,
                schedule_id,
                schedule_id,
            ),
        )
        generated.append((authority_code, pay_date.isoformat(), payslip_date.isoformat()))

    con.commit()
    con.close()
    return generated


def main():
    parser = argparse.ArgumentParser(description='Generate payroll schedules for all active local authorities (SQLite).')
    parser.add_argument('--year', type=int, required=True)
    parser.add_argument('--month', type=int, required=True)
    args = parser.parse_args()

    rows = generate_schedules(args.year, args.month)
    print(f'Generated {len(rows)} schedules for {args.year}-{args.month:02d}')
    for row in rows:
        print(row)


if __name__ == '__main__':
    main()
