#!/usr/bin/env python3
import sqlite3
import psycopg2
from config import Config
from datetime import datetime

def parse_date(date_str):
    """Parse various date formats to PostgreSQL DATE format"""
    if not date_str or date_str == "":
        return None
    try:
        # Try DD/MM/YYYY format
        if '/' in date_str:
            parts = date_str.split('/')
            if len(parts) == 3:
                return f"{parts[2]}-{parts[1]}-{parts[0]}"
        # Try YYYY-MM-DD format
        elif '-' in date_str:
            return date_str
        return date_str
    except:
        return None

def parse_int(val):
    """Safely parse integer values"""
    if val is None or val == "":
        return None
    try:
        # If it looks like a date, return None
        if '/' in str(val) or (isinstance(val, str) and len(val) > 4 and val[:4].isdigit() and '-' in val):
            return None
        return int(float(val)) if isinstance(val, str) and '.' in val else int(val)
    except:
        return None

print("📂 Connecting to databases...")
sqlite_conn = sqlite3.connect("hr_platform.db")
sqlite_cur = sqlite_conn.cursor()

pg_conn = psycopg2.connect(**Config.get_postgres_params())
pg_conn.autocommit = False
cur = pg_conn.cursor()

cur.execute("SET session_replication_role = 'replica';")
cur.execute("DROP TABLE IF EXISTS employees CASCADE;")

# Create employees table with proper types
cur.execute("""
CREATE TABLE employees (
    province TEXT,
    district TEXT,
    name TEXT,
    nrc_number TEXT,
    sex TEXT,
    date_of_birth DATE,
    position TEXT,
    salary_scale TEXT,
    local_authority_service_number TEXT,
    date_of_first_appointment DATE,
    date_confirmed DATE,
    date_substantive_appointment DATE,
    date_reported DATE,
    academic_qualifications TEXT,
    professional_qualifications TEXT,
    acting_position TEXT,
    acting_date DATE,
    department TEXT,
    phone_number TEXT,
    carried_forward_leave INTEGER,
    days_availed INTEGER,
    leave_taken INTEGER,
    leave_commuted INTEGER,
    leave_transferred_out INTEGER,
    leave_balance INTEGER,
    employee_id TEXT,
    gender TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    hire_date DATE,
    email TEXT,
    phone TEXT,
    supervisor_id INTEGER,
    notification_preference TEXT DEFAULT 'Both',
    salary_scale_code TEXT,
    establishment_position_code TEXT,
    authorized_establishment INTEGER,
    establishment_department TEXT,
    council_type_id INTEGER,
    establishment_match_method TEXT,
    union_code TEXT,
    is_zapd_registered INTEGER DEFAULT 0,
    handles_solid_waste INTEGER DEFAULT 0,
    is_council_police INTEGER DEFAULT 0,
    authority_code TEXT
);
""")
print("✓ Created employees table")

# Get and migrate data
sqlite_cur.execute("SELECT * FROM employees;")
rows = sqlite_cur.fetchall()

inserted = 0
for row in rows:
    try:
        cur.execute("""
            INSERT INTO employees VALUES (
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            )
        """, (
            row[0], row[1], row[2], row[3], row[4],
            parse_date(row[5]),  # date_of_birth
            row[6], row[7], row[8],
            parse_date(row[9]),   # date_of_first_appointment
            parse_date(row[10]),  # date_confirmed
            parse_date(row[11]),  # date_substantive_appointment
            parse_date(row[12]),  # date_reported
            row[13], row[14], row[15],
            parse_date(row[16]),  # acting_date
            row[17], row[18],
            parse_int(row[19]),   # carried_forward_leave
            parse_int(row[20]),   # days_availed
            parse_int(row[21]),   # leave_taken
            parse_int(row[22]),   # leave_commuted
            parse_int(row[23]),   # leave_transferred_out
            parse_int(row[24]),   # leave_balance
            row[25], row[26],
            bool(row[27]) if row[27] not in (None, "") else None,  # is_active
            parse_date(row[28]),  # hire_date
            row[29], row[30],
            parse_int(row[31]),   # supervisor_id
            row[32], row[33], row[34],
            parse_int(row[35]),   # authorized_establishment
            row[36],
            parse_int(row[37]),   # council_type_id
            row[38], row[39],
            parse_int(row[40]),   # is_zapd_registered
            parse_int(row[41]),   # handles_solid_waste
            parse_int(row[42]),   # is_council_police
            row[43]
        ))
        inserted += 1
        if inserted % 100 == 0:
            print(f"  Inserted {inserted} employees...")
    except Exception as e:
        print(f"  ⚠ Error on row {inserted + 1}: {e}")
        continue

pg_conn.commit()
print(f"✓ Inserted {inserted} employees")

# Now migrate positions
print("\n📋 Migrating positions...")
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

inserted = 0
for row in rows:
    try:
        cur.execute("""
            INSERT INTO positions VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            row[0], row[1],
            parse_int(row[2]),
            row[3],
            parse_int(row[4]) if row[4] not in (None, "") else 1,
            row[5],
            parse_int(row[6]),
            bool(row[7]) if row[7] not in (None, "") else False,
            parse_int(row[8]) if row[8] not in (None, "") else 2
        ))
        inserted += 1
    except Exception as e:
        print(f"  ⚠ Error: {e}")

pg_conn.commit()
print(f"✓ Inserted {inserted} positions")

cur.execute("SET session_replication_role = 'origin';")
pg_conn.commit()

# Final verification
cur.execute("SELECT COUNT(*) FROM employees;")
emp_count = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM positions;")
pos_count = cur.fetchone()[0]

print("\n" + "=" * 50)
print("✅ MIGRATION COMPLETE!")
print("=" * 50)
print(f"📊 Employees: {emp_count} rows")
print(f"📊 Positions: {pos_count} rows")

if emp_count > 0:
    cur.execute("SELECT employee_id, name, position FROM employees LIMIT 3;")
    print("\n📋 Sample employees:")
    for row in cur.fetchall():
        print(f"   - {row[0]}: {row[1]} → {row[2]}")

sqlite_conn.close()
pg_conn.close()
