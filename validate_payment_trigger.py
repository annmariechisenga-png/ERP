import sqlite3
from pathlib import Path

sql = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql').read_text(encoding='utf-8')
con = sqlite3.connect('/Users/Work/Desktop/ERP/hr_platform.db')
cur = con.cursor()

cur.executescript(sql)
con.commit()

print('triggers:')
for row in cur.execute("SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE 'payroll_payment_%' ORDER BY name").fetchall():
    print(' -', row[0])

cur.execute("INSERT OR IGNORE INTO local_authorities (authority_id, authority_code, authority_name, standard_pay_day) VALUES ('LA_TST','TST','Test Council',25)")
cur.execute("INSERT OR IGNORE INTO payroll_schedules (schedule_id, authority_id, period_year, period_month, status) VALUES ('SCH_TST','LA_TST',2026,3,'SCHEDULED')")
cur.execute("INSERT OR REPLACE INTO payroll_run (payroll_id, schedule_id, authority_id, employee_id, payslip_number, document_verification_code, net_pay, payment_status) VALUES ('PR_TST','SCH_TST','LA_TST',NULL,'PS-TST-001','VC-TST-001',1000.0,'PENDING')")
con.commit()

print('\nTest 1: block when payslip missing')
try:
    cur.execute("UPDATE payroll_run SET payment_due_date='2026-03-25', payment_status='PROCESSED' WHERE payroll_id='PR_TST'")
    con.commit()
    print('ERROR: did not block')
except Exception as exc:
    con.rollback()
    print('blocked_ok:', str(exc))

print('\nTest 2: allow when payslip available')
cur.execute("UPDATE payroll_run SET payslip_available_date='2026-03-24 10:00:00', payment_due_date='2026-03-25', payment_status='PROCESSED' WHERE payroll_id='PR_TST'")
con.commit()
print('allowed_ok')

print('\nTest 3: block PAID when delayed and no approval')
try:
    cur.execute("UPDATE payroll_run SET payslip_available_date='2026-03-24 10:00:00', payment_due_date='2026-03-25', payment_actual_date='2026-03-27', payment_status='PAID' WHERE payroll_id='PR_TST'")
    con.commit()
    print('ERROR: delayed PAID did not block')
except Exception as exc:
    con.rollback()
    print('blocked_ok:', str(exc))

print('\nTest 4: block PAID when approval exists but notification missing')
cur.execute("""
INSERT INTO payment_delay_approvals (
    delay_id, authority_id, schedule_id, delay_days, reason, approved_by, approval_date,
    payslips_issued_on_time, notification_sent_to_employees, notification_date
) VALUES (
    'DLY_TST_1', 'LA_TST', 'SCH_TST', 2, 'Cash flow constraint', 'Council Secretary', '2026-03-26',
    0, 0, NULL
)
""")
con.commit()
try:
    cur.execute("UPDATE payroll_run SET payment_status='PAID', payment_actual_date='2026-03-27' WHERE payroll_id='PR_TST'")
    con.commit()
    print('ERROR: delayed PAID with missing notification did not block')
except Exception as exc:
    con.rollback()
    print('blocked_ok:', str(exc))

print('\nTest 5a: block PAID when approval delay_days < actual lateness (2d approved, 3d late)')
cur.execute("""
UPDATE payment_delay_approvals
SET notification_sent_to_employees=1,
    notification_date='2026-03-26',
    payslips_issued_on_time=0,
    delay_days=2
WHERE delay_id='DLY_TST_1'
""")
con.commit()
try:
    # payment_actual_date 3 days after due (2026-03-28 vs due 2026-03-25 = 3 days late)
    cur.execute("UPDATE payroll_run SET payment_status='PAID', payment_actual_date='2026-03-28' WHERE payroll_id='PR_TST'")
    con.commit()
    print('ERROR: under-coverage approval did not block')
except Exception as exc:
    con.rollback()
    print('blocked_ok:', str(exc))

print('\nTest 5b: allow PAID when approval delay_days >= actual lateness (2d approved, 2d late)')
cur.execute("""
UPDATE payment_delay_approvals SET delay_days=2 WHERE delay_id='DLY_TST_1'
""")
con.commit()
# payment_actual_date exactly 2 days after due (2026-03-27 vs 2026-03-25)
cur.execute("UPDATE payroll_run SET payment_status='PAID', payment_actual_date='2026-03-27' WHERE payroll_id='PR_TST'")
con.commit()
print('allowed_ok')

print('\nTest 6: late payslip warning log')
cur.execute("UPDATE payroll_run SET payslip_available_date='2026-03-26 10:00:00', payment_due_date='2026-03-25', payment_status='PAID' WHERE payroll_id='PR_TST'")
con.commit()
rows = cur.execute("SELECT event_type, message FROM payroll_integrity_log WHERE payroll_id='PR_TST' ORDER BY created_at DESC LIMIT 1").fetchall()
for row in rows:
    print(row)

cur.execute("DELETE FROM payroll_integrity_log WHERE payroll_id='PR_TST'")
cur.execute("DELETE FROM payment_delay_approvals WHERE delay_id='DLY_TST_1'")
cur.execute("DELETE FROM payroll_run WHERE payroll_id='PR_TST'")
cur.execute("DELETE FROM payroll_schedules WHERE schedule_id='SCH_TST'")
cur.execute("DELETE FROM local_authorities WHERE authority_id='LA_TST'")
con.commit()

con.close()
print('\nvalidation_complete')
