import psycopg2
from config import Config

# Connect to PostgreSQL database
conn = psycopg2.connect(**Config.get_postgres_params())
cursor = conn.cursor()

# Create employees table (if it doesn't exist)
cursor.execute("""
CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    salary_scale TEXT NOT NULL,
    leave_balance REAL DEFAULT 0,
    leave_taken REAL DEFAULT 0
)
""")

conn.commit()
conn.close()
