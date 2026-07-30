import sqlite3, psycopg2
from config import Config

failed_tables = ['HRA_Positions', 'finance_sections', 'health_sections', 'planning_sections']

print("Fixing failed tables...")
sqlite = sqlite3.connect("hr_platform.db")
pg = psycopg2.connect(**Config.get_postgres_params())
cur = pg.cursor()
cur.execute("SET session_replication_role = 'replica';")

for table in failed_tables:
    try:
        # Check if table exists
        exists = sqlite.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table}';").fetchone()
        if not exists:
            print(f"⚠ {table} not found")
            continue
        
        # Get data
        data = sqlite.execute(f"SELECT * FROM {table};").fetchall()
        if not data:
            print(f"ℹ {table} is empty")
            continue
        
        # Get column names
        schema = sqlite.execute(f"PRAGMA table_info({table});").fetchall()
        col_names = [col[1] for col in schema]
        
        # Drop and recreate
        cur.execute(f"DROP TABLE IF EXISTS {table};")
        create_sql = f"CREATE TABLE {table} (" + ", ".join([f"{name} TEXT" for name in col_names]) + ");"
        cur.execute(create_sql)
        
        # Insert data
        placeholders = ','.join(['%s'] * len(col_names))
        insert_sql = f"INSERT INTO {table} VALUES ({placeholders})"
        
        for row in data:
            cleaned = [None if x is None else str(x) for x in row]
            cur.execute(insert_sql, cleaned)
        
        pg.commit()
        print(f"✅ {table}: {len(data)} rows")
        
    except Exception as e:
        print(f"✗ {table}: {e}")
        pg.rollback()

cur.execute("SET session_replication_role = 'origin';")
pg.commit()
sqlite.close()
pg.close()
print("\n✅ Failed tables migrated!")
