import sqlite3
from datetime import datetime

def automate_notch_placement(db_path='hr_platform.db', ref_date='2026-01-01'):
    """
    Automates the placement of employees onto the correct salary notch based on
    the number of full years since their 'date_substantive_appointment'.
    
    Formula: Notch = 1 + years_of_service (capped at scale max)
    """
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # 1. Map scale codes to their maximum allowed notches
    cur.execute("SELECT scale_code, MAX(notch_no) FROM salary_notch_values GROUP BY scale_code")
    max_notches = dict(cur.fetchall())
    
    # 2. Find employees who don't have an active salary notch record yet
    # This targets newly onboarded authorities or hires
    cur.execute("""
        SELECT e.employee_id, e.salary_scale_code, e.date_substantive_appointment 
        FROM employees e
        LEFT JOIN employee_salary_notch esn ON e.employee_id = esn.employee_id AND esn.is_active = 1
        WHERE esn.employee_id IS NULL 
          AND e.date_substantive_appointment IS NOT NULL 
          AND e.date_substantive_appointment != ''
    """)
    
    to_process = cur.fetchall()
    if not to_process:
        print("No employees found requiring notch placement.")
        conn.close()
        return

    print(f"Found {len(to_process)} employees to place on notches.")
    
    ref_dt = datetime.strptime(ref_date, '%Y-%m-%d')
    count = 0
    
    for emp_id, scale, date_str in to_process:
        try:
            # Handle possible empty or malformed dates
            if not date_str or '.' not in date_str:
                continue
                
            # Parse DD.MM.YYYY
            apt_dt = datetime.strptime(date_str, '%d.%m.%Y')
            
            # Calculate full years of service in the present post
            years = ref_dt.year - apt_dt.year
            # Adjust if the anniversary hasn't happened yet in the reference year
            if (ref_dt.month, ref_dt.day) < (apt_dt.month, apt_dt.day):
                years -= 1
            
            # Notch logic: start at 1, increment for every full year
            # Ensure years is at least 0
            calculated_notch = 1 + max(0, years)
            
            # Get max notch for this specific scale (fallback to 7 if unknown)
            limit = max_notches.get(scale, 7)
            
            final_notch = min(calculated_notch, limit)
            
            # Insert the new notch placement record
            cur.execute("""
                INSERT INTO employee_salary_notch (employee_id, scale_code, notch_no, effective_from, is_active)
                VALUES (?, ?, ?, ?, 1)
            """, (emp_id, scale, final_notch, ref_date))
            
            count += 1
        except Exception as e:
            print(f"Skipping {emp_id} due to error: {e}")
            
    conn.commit()
    conn.close()
    print(f"Successfully automated notch placement for {count} employees.")

if __name__ == "__main__":
    # You can set the reference date to the start of the current payroll year
    automate_notch_placement(ref_date='2026-01-01')
