import sqlite3

# Connect to database (creates file if it doesn't exist)
conn = sqlite3.connect("hr_platform.db")
cursor = conn.cursor()

# Create employees table
cursor.execute("""
CREATE TABLE IF NOT EXISTS employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    salary_scale TEXT NOT NULL,
    leave_balance REAL DEFAULT 0,
    leave_taken REAL DEFAULT 0
)
""")

conn.commit()
conn.close()
