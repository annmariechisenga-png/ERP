import sqlite3, json
from pathlib import Path
from datetime import datetime

sql = Path('/Users/Work/Desktop/ERP/local_authority_payroll_config_sqlite.sql').read_text(encoding='utf-8')
con = sqlite3.connect('/Users/Work/Desktop/ERP/hr_platform.db')
cur = con.cursor()
cur.executescript(sql)
con.commit()

# Confirm view
exists = cur.execute("SELECT 1 FROM sqlite_master WHERE type='view' AND name='v_compliance_dashboard'").fetchone()
print('v_compliance_dashboard:', 'OK' if exists else 'MISSING')
cols = [d[0] for d in cur.execute('SELECT * FROM v_compliance_dashboard LIMIT 0').description]
print('columns:', cols)

# Insert a current-month submission with a late date to see the dashboard pick it up
yr, mo = datetime.now().year, datetime.now().month
late_date = f'{yr}-{mo:02d}-14'   # submitted on 14th (9 days after 5th deadline)

cur.execute("INSERT OR IGNORE INTO local_authorities (authority_id,authority_code,authority_name,is_active) VALUES ('LA_DSH','DSH','Dashboard Test Council',1)")
cur.execute(f"""
    INSERT OR REPLACE INTO la_payroll_submissions
        (submission_id,authority_id,period_year,period_month,
         la_payroll_date,submission_date,submission_status,payroll_data)
    VALUES ('SUB_DSH','LA_DSH',{yr},{mo},
            '{yr}-{mo:02d}-25','{late_date} 10:00:00','PENDING','{{}}')
""")
cur.execute(f"""
    INSERT OR IGNORE INTO central_payslip_archive
        (archive_id,authority_id,submission_id,employee_number,employee_name,
         period_year,period_month,net_pay,payment_date,payslip_generated_date)
    VALUES
        (lower(hex(randomblob(16))),'LA_DSH','SUB_DSH','EMP001','Jane Doe',{yr},{mo},5200.00,'{yr}-{mo:02d}-25','{yr}-{mo:02d}-24'),
        (lower(hex(randomblob(16))),'LA_DSH','SUB_DSH','EMP002','John Banda',{yr},{mo},4800.00,'{yr}-{mo:02d}-25','{yr}-{mo:02d}-24')
""")
con.commit()

print('\nDashboard rows (current month):')
rows = cur.execute('SELECT * FROM v_compliance_dashboard').fetchall()
for r in rows:
    if r[0] in ('Dashboard Test Council', 'Kafue Town Council', 'Lusaka City Council', 'Ndola City Council', 'Mongu Town Council'):
        print(' ', dict(zip(cols, r)))

# cleanup
cur.execute("DELETE FROM central_payslip_archive WHERE submission_id='SUB_DSH'")
cur.execute("DELETE FROM compliance_issues WHERE submission_id='SUB_DSH'")
cur.execute("DELETE FROM la_payroll_submissions WHERE submission_id='SUB_DSH'")
cur.execute("DELETE FROM local_authorities WHERE authority_id='LA_DSH'")
con.commit()
con.close()
print('\ndone')
