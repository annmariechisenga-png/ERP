import sqlite3
from pathlib import Path

sql = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql').read_text(encoding='utf-8')
con = sqlite3.connect('/Users/Work/Desktop/ERP/hr_platform.db')
cur = con.cursor()
cur.executescript(sql)
con.commit()

exists = cur.execute("SELECT 1 FROM sqlite_master WHERE type='view' AND name='v_compliance_report'").fetchone()
print('v_compliance_report_exists:', bool(exists))

names = [d[0] for d in cur.execute('SELECT * FROM v_compliance_report LIMIT 0').description]
print('columns:', names)

rows = cur.execute("""
    SELECT authority_name, pay_day, period_year, period_month,
           payment_date, payslip_due_date, compliant, violation_details,
           payslip_days_late, payment_days_late, employee_count
    FROM v_compliance_report
    WHERE period_year=2026 AND period_month=3
    ORDER BY pay_day
""").fetchall()
print(f'\nMarch 2026 compliance ({len(rows)} authorities):')
for r in rows:
    print(r)

con.close()
print('done')
