import sqlite3
from datetime import datetime

def calculate_arrears():
    db_path = 'hr_platform.db'
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 1. Ensure BACKPAY_2026 allowance type exists
    cursor.execute("""
        INSERT OR IGNORE INTO allowance_types 
        (allowance_code, allowance_name, calc_method, default_value, taxable, pensionable, active, source_doc)
        VALUES ('BACKPAY_2026', '2026 Salary Arrears (Jan-Apr)', 'FIXED_AMOUNT', 0, 1, 1, 1, 'Collective Agreement 2026')
    """)

    # 2. Get affected employees
    # Note: We join with salary_scales_official 2025 to identify the division
    cursor.execute("""
        SELECT esn.employee_id, esn.scale_code, esn.notch_no, e.date_of_first_appointment,
               snv2025.monthly_basic as basic_2025, snv2026.monthly_basic as basic_2026
        FROM employee_salary_notch esn
        JOIN employees e ON esn.employee_id = e.employee_id
        JOIN salary_scales_official sso ON esn.scale_code = sso.salary_scale AND sso.effective_from = '2025-01-01'
        JOIN salary_notch_values snv2025 ON esn.scale_code = snv2025.scale_code AND esn.notch_no = snv2025.notch_no AND snv2025.effective_from = '2025-01-01'
        JOIN salary_notch_values snv2026 ON esn.scale_code = snv2026.scale_code AND esn.notch_no = snv2026.notch_no AND snv2026.effective_from = '2026-01-01'
        WHERE sso.division IN ('DIVISION_II', 'DIVISION_III', 'DIVISION_IV')
          AND esn.is_active = 1
          AND esn.effective_from = '2025-01-01'
    """)
    
    affected = cursor.fetchall()
    print(f"Calculating arrears for {len(affected)} employees...")

    count = 0
    for emp_id, scale_code, notch_no, hire_date_str, basic_2025, basic_2026 in affected:
        # Determine number of months for arrears (Max 4: Jan, Feb, Mar, Apr)
        months = 4
        if hire_date_str:
            try:
                # Format in DB is DD.MM.YYYY
                hire_date = datetime.strptime(hire_date_str, '%d.%m.%Y')
                if hire_date.year == 2026:
                    if hire_date.month > 1:
                        # If hired Feb 1st, they get 3 months arrears (Feb, Mar, Apr)
                        months = 4 - (hire_date.month - 1)
                        if months < 0: months = 0
                elif hire_date.year > 2026:
                    months = 0
            except:
                pass 
        
        arrears_amount = (basic_2026 - basic_2025) * months
        
        if arrears_amount > 0:
            # Insert into employee_allowances
            cursor.execute("""
                INSERT OR REPLACE INTO employee_allowances
                (employee_id, allowance_code, calc_method, value, effective_from, is_active)
                VALUES (?, 'BACKPAY_2026', 'FIXED_AMOUNT', ?, '2026-05-01', 1)
            """, (emp_id, round(arrears_amount, 2)))

        # Update employee_salary_notch to 2026
        # Deactivate old
        cursor.execute("""
            UPDATE employee_salary_notch
            SET is_active = 0, effective_to = '2025-12-31'
            WHERE employee_id = ? AND effective_from = '2025-01-01'
        """, (emp_id,))
        
        # Insert new
        cursor.execute("""
            INSERT OR REPLACE INTO employee_salary_notch
            (employee_id, scale_code, notch_no, effective_from, is_active)
            VALUES (?, ?, ?, '2026-01-01', 1)
        """, (emp_id, scale_code, notch_no))
        count += 1

    conn.commit()
    conn.close()
    print(f"Successfully processed {count} employees.")

if __name__ == "__main__":
    calculate_arrears()
