import sqlite3, psycopg2, re
from config import Config

def to_int(x):
    if x is None or x == "":
        return None
    try:
        return int(float(x)) if isinstance(x, str) and '.' in x else int(x)
    except:
        return None

def to_date(x):
    if not x or x == "":
        return None
    x = str(x).strip()
    # Handle DD.MM.YYYY format
    if '.' in x and len(x.split('.')) == 3:
        parts = x.split('.')
        return f"{parts[2]}-{parts[1]}-{parts[0]}"
    # Handle DD/MM/YYYY format
    elif '/' in x:
        parts = x.split('/')
        return f"{parts[2]}-{parts[1]}-{parts[0]}"
    # Handle YYYY-MM-DD format
    elif '-' in x and len(x.split('-')) == 3:
        return x
    # Handle DD-MM-YYYY format
    elif '-' in x:
        parts = x.split('-')
        return f"{parts[2]}-{parts[1]}-{parts[0]}"
    return None

def to_bool(x):
    if x is None or x == "":
        return None
    return bool(int(x)) if str(x).isdigit() else None

print("Connecting...")
sqlite = sqlite3.connect("hr_platform.db")
pg = psycopg2.connect(**Config.get_postgres_params())
cur = pg.cursor()
cur.execute("SET session_replication_role = 'replica';")

# Create employees table
cur.execute("DROP TABLE IF EXISTS employees;")
cur.execute("""
CREATE TABLE employees (
    province TEXT, district TEXT, name TEXT, nrc_number TEXT, sex TEXT,
    date_of_birth DATE, position TEXT, salary_scale TEXT,
    local_authority_service_number TEXT, date_of_first_appointment DATE,
    date_confirmed DATE, date_substantive_appointment DATE, date_reported DATE,
    academic_qualifications TEXT, professional_qualifications TEXT,
    acting_position TEXT, acting_date DATE, department TEXT, phone_number TEXT,
    carried_forward_leave INTEGER, days_availed INTEGER, leave_taken INTEGER,
    leave_commuted INTEGER, leave_transferred_out INTEGER, leave_balance INTEGER,
    employee_id TEXT, gender TEXT, is_active BOOLEAN, hire_date DATE, email TEXT,
    phone TEXT, supervisor_id INTEGER, notification_preference TEXT,
    salary_scale_code TEXT, establishment_position_code TEXT,
    authorized_establishment INTEGER, establishment_department TEXT,
    council_type_id INTEGER, establishment_match_method TEXT, union_code TEXT,
    is_zapd_registered INTEGER, handles_solid_waste INTEGER,
    is_council_police INTEGER, authority_code TEXT
);
""")

print("Migrating employees...")
data = sqlite.execute("SELECT * FROM employees;").fetchall()
count = 0
for row in data:
    try:
        cur.execute("""
            INSERT INTO employees VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
            %s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
            %s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            row[0], row[1], row[2], row[3], row[4],
            to_date(row[5]), row[6], row[7], row[8],
            to_date(row[9]), to_date(row[10]), to_date(row[11]), to_date(row[12]),
            row[13], row[14], row[15], to_date(row[16]), row[17], row[18],
            to_int(row[19]), to_int(row[20]), to_int(row[21]), to_int(row[22]),
            to_int(row[23]), to_int(row[24]), row[25], row[26], to_bool(row[27]),
            to_date(row[28]), row[29], row[30], to_int(row[31]), row[32], row[33],
            row[34], to_int(row[35]), row[36], to_int(row[37]), row[38], row[39],
            to_int(row[40]), to_int(row[41]), to_int(row[42]), row[43]
        ))
        count += 1
        if count % 100 == 0:
            print(f"  {count} rows...")
    except Exception as e:
        print(f"  Error on row {count+1}: {e}")
        continue

pg.commit()
print(f"✅ Employees: {count} rows")

# Migrate positions
print("\nMigrating positions...")
cur.execute("DROP TABLE IF EXISTS positions;")
cur.execute("""
CREATE TABLE positions (
    position_id TEXT PRIMARY KEY, title TEXT, section_id INTEGER,
    salary_scale TEXT, proposed_establishment INTEGER, reports_to TEXT,
    level INTEGER, is_head_of_section BOOLEAN, council_type_id INTEGER
);
""")

data = sqlite.execute("SELECT * FROM positions;").fetchall()
count = 0
for row in data:
    try:
        cur.execute("""
            INSERT INTO positions VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            row[0], row[1], to_int(row[2]), row[3],
            to_int(row[4]), row[5], to_int(row[6]),
            to_bool(row[7]), to_int(row[8])
        ))
        count += 1
    except Exception as e:
        print(f"  Error: {e}")
pg.commit()
print(f"✅ Positions: {count} rows")

cur.execute("SET session_replication_role = 'origin';")
pg.commit()
sqlite.close()
pg.close()

print(f"\n🎉 Complete! Employees: {count} rows")
