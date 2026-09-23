import sqlite3

db = '/Users/Work/Desktop/ERP/hr_platform.db'
con = sqlite3.connect(db)
cur = con.cursor()

# Repair payroll_run only if safe (empty table)
row_count = cur.execute('SELECT COUNT(*) FROM payroll_run').fetchone()[0]
if row_count != 0:
    print(f'skipped payroll_run repair: table has {row_count} rows')
else:
    cur.execute('DROP TABLE IF EXISTS payroll_run')
    cur.execute(
        '''
        CREATE TABLE payroll_run (
            payroll_id TEXT PRIMARY KEY,
            schedule_id TEXT REFERENCES payroll_schedules(schedule_id),
            authority_id TEXT REFERENCES local_authorities(authority_id),
            employee_id TEXT,
            payslip_number TEXT UNIQUE NOT NULL,
            document_verification_code TEXT UNIQUE NOT NULL,
            payslip_available_date TEXT,
            payslip_viewed_date TEXT,
            payslip_delivery_method TEXT,
            payment_due_date TEXT,
            payment_actual_date TEXT,
            payment_status TEXT DEFAULT 'PENDING',
            payment_reference TEXT,
            basic_salary REAL,
            total_allowances REAL,
            total_deductions REAL,
            net_pay REAL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(schedule_id, employee_id)
        )
        '''
    )
    print('recreated payroll_run')

# Repair payslip_access_log safely
cur.execute('DROP TABLE IF EXISTS payslip_access_log')
cur.execute(
    '''
    CREATE TABLE payslip_access_log (
        access_id TEXT PRIMARY KEY,
        payroll_id TEXT REFERENCES payroll_run(payroll_id),
        employee_id TEXT,
        access_type TEXT,
        access_timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        access_ip TEXT,
        access_device TEXT,
        delivery_confirmation INTEGER DEFAULT 0,
        delivery_confirmation_time TEXT
    )
    '''
)
print('recreated payslip_access_log')

con.commit()
con.close()
print('repair_complete')
