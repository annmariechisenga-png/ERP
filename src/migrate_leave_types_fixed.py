import sqlite3, psycopg2
from config import Config

print("📋 Migrating leave_types table with proper schema...")

sqlite = sqlite3.connect("hr_platform.db")
pg = psycopg2.connect(**Config.get_postgres_params())
cur = pg.cursor()
cur.execute("SET session_replication_role = 'replica';")

# Drop existing if any
cur.execute("DROP TABLE IF EXISTS leave_types CASCADE;")

# Create table with proper PostgreSQL types
cur.execute("""
CREATE TABLE leave_types (
    leave_type_id SERIAL PRIMARY KEY,
    leave_type_code TEXT UNIQUE NOT NULL,
    leave_type_name TEXT NOT NULL,
    description TEXT,
    requires_approval BOOLEAN DEFAULT TRUE,
    is_paid BOOLEAN DEFAULT TRUE,
    is_cumulative BOOLEAN DEFAULT FALSE,
    max_days_per_month INTEGER,
    max_days_per_year INTEGER,
    applicable_to TEXT,
    requires_supervisor_notification BOOLEAN DEFAULT TRUE,
    requires_hr_notification BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
""")
print("✓ Table created")

# Get data from SQLite
data = sqlite.execute("SELECT * FROM leave_types;").fetchall()
print(f"Found {len(data)} leave types")

# Insert data
for row in data:
    cur.execute("""
        INSERT INTO leave_types (
            leave_type_id, leave_type_code, leave_type_name, description,
            requires_approval, is_paid, is_cumulative, max_days_per_month,
            max_days_per_year, applicable_to, requires_supervisor_notification,
            requires_hr_notification, created_at
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, row)

pg.commit()
print(f"✅ Inserted {len(data)} leave types")

# Verify
cur.execute("SELECT leave_type_code, leave_type_name, applicable_to, max_days_per_month, max_days_per_year FROM leave_types;")
results = cur.fetchall()
print("\n📋 Migrated leave types:")
for r in results:
    print(f"   - {r[0]}: {r[1]} (Applicable: {r[2]}, Max/month: {r[3]}, Max/year: {r[4]})")

cur.execute("SET session_replication_role = 'origin';")
pg.commit()

sqlite.close()
pg.close()
print("\n✅ leave_types migration complete!")
