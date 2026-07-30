#!/usr/bin/env python3
import sqlite3
import psycopg2
from config import Config

def clean_value(value):
    """Convert empty strings to None for integer/boolean fields"""
    if value == "":
        return None
    return value

print("Migrating employees...")
sqlite_conn = sqlite3.connect("hr_platform.db")
pg_conn = psycopg2.connect(**Config.get_postgres_params())
pg_conn.autocommit = False
cur = pg_conn.cursor()

cur.execute("SET session_replication_role = 'replica';")
cur.execute("DROP TABLE IF EXISTS employees CASCADE;")

# Create employees table (allowing NULLs)
cur.execute("""
CREATE TABLE employees (
    rowid SERIAL PRIMARY KEY,
    province TEXT, district TEXT, name TEXT, nrc_number TEXT,
    sex TEXT, date_of_birth TEXT, position TEXT, salary_scale TEXT,
    local_authority_service_number TEXT, date_of_first_appointment TEXT,
    date_confirmed TEXT, date_substantive_appointment TEXT, date_reported TEXT,
    academic_qualifications TEXT, professional_qualifications TEXT,
    acting_position TEXT, acting_date TEXT, department TEXT, phone_number TEXT,
    carried_forward_leave INTEGER, days_availed INTEGER, leave_taken INTEGER,
    leave_commuted INTEGER, leave_transferred_out INTEGER, leave_balance INTEGER,
    employee_id TEXT, gender TEXT, is_active BOOLEAN DEFAULT TRUE,
    hire_date DATE, email TEXT, phone TEXT, supervisor_id INTEGER,
    notification_preference TEXT DEFAULT 'Both', salary_scale_code TEXT,
    establishment_position_code TEXT, authorized_establishment INTEGER,
    establishment_department TEXT, council_type_id INTEGER,
    establishment_match_method TEXT, union_code TEXT,
    is_zapd_registered INTEGER DEFAULT 0, handles_solid_waste INTEGER DEFAULT 0,
    is_council_police INTEGER DEFAULT 0, authority_code TEXT
);
""")

# Get data with cleaned values
sqlite_cur = sqlite_conn.cursor()
sqlite_cur.execute("SELECT * FROM employees;")
rows = sqlite_cur.fetchall()
cols = [desc[0] for desc in sqlite_cur.description]

# Clean the data
cleaned_rows = []
for row in rows:
    cleaned_row = []
    for i, value in enumerate(row):
        # Check if column is integer type (by column name patterns)
        col_name = cols[i].lower()
        if any(x in col_name for x in ['integer', 'count', 'balance', 'days', 'id', 'level', 'status']):
            if value == "" or value is None:
                cleaned_row.append(None)
            else:
                try:
                    cleaned_row.append(int(float(value)) if isinstance(value, str) and '.' in value else int(value))
                except (ValueError, TypeError):
                    cleaned_row.append(None)
        else:
            cleaned_row.append(None if value == "" else value)
    cleaned_rows.append(tuple(cleaned_row))

if cleaned_rows:
    placeholders = ','.join(['%s'] * len(cols))
    insert_sql = f"INSERT INTO employees ({','.join(cols)}) VALUES ({placeholders})"
    cur.executemany(insert_sql, cleaned_rows)
    print(f"  ✓ Inserted {len(cleaned_rows)} employees")

# Migrate positions
print("\nMigrating positions...")
cur.execute("DROP TABLE IF EXISTS positions CASCADE;")
cur.execute("""
CREATE TABLE positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    section_id INTEGER,
    salary_scale TEXT,
    proposed_establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    level INTEGER,
    is_head_of_section BOOLEAN DEFAULT FALSE,
    council_type_id INTEGER DEFAULT 2
);
""")

sqlite_cur.execute("SELECT * FROM positions;")
rows = sqlite_cur.fetchall()
cols = [desc[0] for desc in sqlite_cur.description]

if rows:
    # Clean positions data
    cleaned_rows = []
    for row in rows:
        cleaned_row = []
        for i, value in enumerate(row):
            col_name = cols[i].lower()
            if col_name in ['section_id', 'proposed_establishment', 'level', 'council_type_id']:
                if value == "" or value is None:
                    cleaned_row.append(None)
                else:
                    try:
                        cleaned_row.append(int(value))
                    except (ValueError, TypeError):
                        cleaned_row.append(None)
            else:
                cleaned_row.append(None if value == "" else value)
        cleaned_rows.append(tuple(cleaned_row))
    
    placeholders = ','.join(['%s'] * len(cols))
    insert_sql = f"INSERT INTO positions ({','.join(cols)}) VALUES ({placeholders})"
    cur.executemany(insert_sql, cleaned_rows)
    print(f"  ✓ Inserted {len(cleaned_rows)} positions")

cur.execute("SET session_replication_role = 'origin';")
pg_conn.commit()

# Verify
cur.execute("SELECT COUNT(*) FROM employees;")
emp_count = cur.fetchone()[0]
print(f"\n✅ Employees table: {emp_count} rows")

cur.execute("SELECT COUNT(*) FROM positions;")
pos_count = cur.fetchone()[0]
print(f"✅ Positions table: {pos_count} rows")

# Show sample
if emp_count > 0:
    cur.execute("SELECT employee_id, name, position FROM employees LIMIT 3;")
    print("\n📋 Sample employees:")
    for row in cur.fetchall():
        print(f"   - {row[0]}: {row[1]} ({row[2]})")

sqlite_conn.close()
pg_conn.close()
