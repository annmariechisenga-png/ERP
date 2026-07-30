import sqlite3

def migrate():
    db_path = 'hr_platform.db'
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    # 1. Get provincial mapping
    cur.execute("SELECT province_name, province_code FROM province_codes")
    prov_map = dict(cur.fetchall())
    
    # 2. Get all employees with old-style IDs (those not starting with ZM)
    cur.execute("SELECT employee_id, province, authority_code FROM employees WHERE employee_id NOT LIKE 'ZM%'")
    employees = cur.fetchall()
    print(f"Found {len(employees)} employee IDs to modernize.")
    
    for old_id, province, auth_code in employees:
        prov_code = prov_map.get(province, 'ZMXX')
        # Use auth_code if available, else extract from old ID (e.g., CHL from CHL-2024-000001)
        if not auth_code and '-' in old_id:
            auth_code = old_id.split('-')[0]
            
        new_prefix = f"{prov_code}-{auth_code}"
        new_id = old_id.replace(old_id.split('-')[0], new_prefix, 1) if '-' in old_id else f"{new_prefix}-{old_id}"
        
        print(f"Migrating: {old_id} -> {new_id}")
        
        try:
            # Update main employee table
            cur.execute("UPDATE employees SET employee_id = ?, authority_code = ? WHERE employee_id = ?", (new_id, auth_code, old_id))
            
            # Update all related tables
            tables_to_update = [
                ('employee_salary_notch', 'employee_id'),
                ('employee_allowances', 'employee_id'),
                ('employee_deductions', 'employee_id'),
                ('leave_balances', 'employee_id'),
                ('leave_requests', 'employee_id'),
                ('central_payslip_archive', 'employee_number'),
                ('payroll_run_items', 'employee_id'),
                ('length_of_stay', 'employee_id')
            ]
            
            for table, col in tables_to_update:
                cur.execute(f"UPDATE {table} SET {col} = ? WHERE {col} = ?", (new_id, old_id))
                
        except Exception as e:
            print(f"Error migrating {old_id}: {e}")
            
    conn.commit()
    conn.close()
    print("ID Migration complete.")

if __name__ == "__main__":
    migrate()
