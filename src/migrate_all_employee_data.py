import sqlite3, psycopg2
from config import Config

# All tables with employee/position data
tables_to_migrate = [
    'employees', 'positions', 'HRA_Positions', 'HRA_ReportingLines',
    'eng_positions', 'eng_units', 'eng_leave_approval_chain',
    'finance_positions', 'finance_sections', 'finance_units', 'finance_leave_approval_chain',
    'health_positions', 'health_sections', 'health_units', 'health_leave_approval_chain',
    'planning_positions', 'planning_sections', 'planning_units', 'planning_leave_approval_chain',
    'community_positions', 'legal_positions', 'procurement_positions',
    'audit_positions', 'commercial_positions', 'ict_positions',
    'toc_positions', 'executive_positions',
    'position_attributes', 'position_supervisors', 'leave_approval_chain',
    'employee_allowances', 'employee_deductions', 'employee_salary_notch',
    'authorities', 'authority_codes', 'councils', 'sections', 'departments'
]

def to_int(x):
    if x is None or x == "": return None
    try: return int(float(x)) if isinstance(x, str) and '.' in x else int(x)
    except: return None

print("Connecting to databases...")
sqlite = sqlite3.connect("hr_platform.db")
pg = psycopg2.connect(**Config.get_postgres_params())
cur = pg.cursor()
cur.execute("SET session_replication_role = 'replica';")

success = []
failed = []

for table in tables_to_migrate:
    try:
        # Check if table exists in SQLite
        exists = sqlite.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table}';").fetchone()
        if not exists:
            print(f"⚠ {table} not found, skipping")
            continue
        
        # Get row count
        count = sqlite.execute(f"SELECT COUNT(*) FROM {table};").fetchone()[0]
        if count == 0:
            print(f"ℹ {table} is empty, skipping")
            continue
        
        # Get schema
        schema = sqlite.execute(f"PRAGMA table_info({table});").fetchall()
        col_names = [col[1] for col in schema]
        
        # Drop and recreate table
        cur.execute(f"DROP TABLE IF EXISTS {table};")
        create_sql = f"CREATE TABLE {table} (" + ", ".join([f"{name} TEXT" for name in col_names]) + ");"
        cur.execute(create_sql)
        
        # Insert data
        data = sqlite.execute(f"SELECT * FROM {table};").fetchall()
        placeholders = ','.join(['%s'] * len(col_names))
        insert_sql = f"INSERT INTO {table} VALUES ({placeholders})"
        
        for row in data:
            cleaned = [None if x is None else str(x) for x in row]
            cur.execute(insert_sql, cleaned)
        
        pg.commit()
        print(f"✅ {table}: {count} rows")
        success.append(f"{table} ({count})")
        
    except Exception as e:
        print(f"✗ {table}: {e}")
        failed.append(table)
        pg.rollback()

cur.execute("SET session_replication_role = 'origin';")
pg.commit()

print("\n" + "=" * 50)
print("MIGRATION SUMMARY")
print("=" * 50)
print(f"✅ Successful: {len(success)} tables")
for s in success[:10]:
    print(f"   - {s}")
if len(success) > 10:
    print(f"   ... and {len(success) - 10} more")

if failed:
    print(f"\n❌ Failed: {len(failed)} tables")
    for f in failed[:10]:
        print(f"   - {f}")

sqlite.close()
pg.close()
print("\n🎉 Employee data migration complete!")
