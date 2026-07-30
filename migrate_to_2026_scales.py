import sqlite3
import json
import os
from datetime import datetime

def migrate():
    db_path = 'hr_platform.db'
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # 1. Backup current salary data
    print("Backing up current salary notch data...")
    cur.execute("SELECT * FROM employee_salary_notch WHERE is_active = 1")
    rows = cur.fetchall()
    with open('employee_salary_notch_backup_2026.json', 'w') as f:
        json.dump(rows, f)
    
    # 2. Identify employees for migration
    # We target both Management (LGSS01-07) and Unionized (LGSS08-18, G1-3)
    # that are still on 2025 or earlier effective dates.
    cur.execute("""
        SELECT esn.employee_id, esn.scale_code, esn.notch_no, e.hire_date
        FROM employee_salary_notch esn
        JOIN employees e ON esn.employee_id = e.employee_id
        WHERE esn.is_active = 1 AND esn.effective_from < '2026-01-01'
    """)
    employees = cur.fetchall()
    print(f"Found {len(employees)} employees to migrate.")
    
    count = 0
    progressed_count = 0
    
    for emp_id, raw_scale, notch_no, hire_date_str in employees:
        # Determine if notch progression is due (Anniversary in 2026 has passed)
        new_notch = notch_no
        try:
            # Hire date format varies, handle DD.MM.YYYY or YYYY-MM-DD
            if '-' in hire_date_str:
                hire_date = datetime.strptime(hire_date_str, '%Y-%m-%d')
            else:
                hire_date = datetime.strptime(hire_date_str, '%d.%m.%Y')
                
            today = datetime.now()
            # If current month/day >= hire month/day, they progressed in 2026
            if (today.month, today.day) >= (hire_date.month, hire_date.day):
                new_notch = notch_no + 1
                progressed_count += 1
        except Exception as e:
            # If date parsing fails, stay on current notch
            pass
            
        # Deactivate old notch
        cur.execute("""
            UPDATE employee_salary_notch 
            SET is_active = 0, effective_to = '2025-12-31'
            WHERE employee_id = ? AND is_active = 1
        """, (emp_id,))
        
        # Insert new notch for 2026
        cur.execute("""
            INSERT INTO employee_salary_notch 
            (employee_id, scale_code, notch_no, effective_from, is_active)
            VALUES (?, ?, ?, '2026-01-01', 1)
        """, (emp_id, raw_scale, new_notch))
        
        count += 1
    
    conn.commit()
    conn.close()
    print(f"Migration complete. {count} employees updated. {progressed_count} progressed one notch.")

if __name__ == "__main__":
    migrate()
