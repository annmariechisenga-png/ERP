#!/usr/bin/env python3
"""
Migration script to convert SQLite database to PostgreSQL
"""
import sqlite3
import psycopg2
from psycopg2 import sql
import re
from config import Config

def get_sqlite_tables(sqlite_conn):
    """Get all table names from SQLite database"""
    cursor = sqlite_conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
    tables = [row[0] for row in cursor.fetchall()]
    return tables

def get_table_schema(sqlite_conn, table_name):
    """Get the CREATE TABLE statement from SQLite"""
    cursor = sqlite_conn.cursor()
    cursor.execute(f"SELECT sql FROM sqlite_master WHERE type='table' AND name='{table_name}';")
    result = cursor.fetchone()
    return result[0] if result else None

def convert_sqlite_to_postgres(sqlite_schema):
    """Convert SQLite schema to PostgreSQL compatible format"""
    if not sqlite_schema:
        return None
    
    # Replace SQLite specific syntax with PostgreSQL equivalents
    postgres_schema = sqlite_schema
    
    # Replace AUTOINCREMENT with SERIAL or BIGSERIAL
    postgres_schema = re.sub(
        r'INTEGER PRIMARY KEY AUTOINCREMENT',
        'SERIAL PRIMARY KEY',
        postgres_schema
    )
    
    # Replace INTEGER PRIMARY KEY (without AUTOINCREMENT) with SERIAL PRIMARY KEY
    postgres_schema = re.sub(
        r'INTEGER PRIMARY KEY(?!\s+AUTOINCREMENT)',
        'SERIAL PRIMARY KEY',
        postgres_schema
    )
    
    # Replace TEXT with VARCHAR or TEXT (PostgreSQL handles both)
    # Keep TEXT for now as it's more flexible
    
    # Replace REAL with DOUBLE PRECISION or NUMERIC
    postgres_schema = re.sub(r'\bREAL\b', 'DOUBLE PRECISION', postgres_schema)
    
    # Replace BOOLEAN with BOOLEAN (already compatible)
    
    # Replace DATE with DATE (already compatible)
    
    # Replace DATETIME with TIMESTAMP
    postgres_schema = re.sub(r'\bDATETIME\b', 'TIMESTAMP', postgres_schema)
    
    # Replace SQLite randomblob() with PostgreSQL gen_random_uuid() or similar
    postgres_schema = re.sub(
        r'lower\(hex\(randomblob\(\d+\)\)\)',
        'gen_random_uuid()::text',
        postgres_schema
    )
    
    # Fix boolean default values (SQLite uses 0/1, PostgreSQL requires true/false)
    postgres_schema = re.sub(
        r'BOOLEAN DEFAULT 1',
        'BOOLEAN DEFAULT true',
        postgres_schema
    )
    postgres_schema = re.sub(
        r'BOOLEAN DEFAULT 0',
        'BOOLEAN DEFAULT false',
        postgres_schema
    )
    
    # Replace CURRENT_TIMESTAMP with CURRENT_TIMESTAMP (already compatible)
    
    # Remove CHECK constraints that reference other tables (will need manual handling)
    # For now, keep them but they might need adjustment
    
    # Remove REFERENCES that use TEXT columns (PostgreSQL prefers INTEGER for foreign keys)
    # This is a simplification - complex foreign keys may need manual handling
    
    return postgres_schema

def get_table_data(sqlite_conn, table_name):
    """Get all data from a SQLite table"""
    cursor = sqlite_conn.cursor()
    cursor.execute(f"SELECT * FROM {table_name};")
    columns = [description[0] for description in cursor.description]
    rows = cursor.fetchall()
    return columns, rows

def create_postgres_table(postgres_conn, table_name, schema):
    """Create a table in PostgreSQL"""
    cursor = postgres_conn.cursor()
    try:
        # Remove FOREIGN KEY and REFERENCES clauses more carefully
        # Remove FOREIGN KEY (columns) REFERENCES table(columns)
        schema_no_fk = re.sub(
            r',\s*FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s+\w+\s*\([^)]*\)',
            '',
            schema,
            flags=re.IGNORECASE | re.MULTILINE
        )
        
        # Remove any remaining FOREIGN KEY clauses (incomplete ones)
        schema_no_fk = re.sub(
            r',\s*FOREIGN KEY\s*\([^)]*\)',
            '',
            schema_no_fk,
            flags=re.IGNORECASE | re.MULTILINE
        )
        
        # Remove standalone REFERENCES clauses at end of column definitions
        schema_no_fk = re.sub(
            r'\s+REFERENCES\s+\w+\s*\([^)]*\)',
            '',
            schema_no_fk,
            flags=re.IGNORECASE | re.MULTILINE
        )
        
        # Remove UNIQUE constraints that reference columns that might not exist
        # This is a temporary fix - we'll add proper constraints later
        schema_no_fk = re.sub(
            r',\s*UNIQUE\s*\([^)]+\)',
            '',
            schema_no_fk,
            flags=re.IGNORECASE | re.MULTILINE
        )
        
        # Clean up trailing commas and whitespace
        schema_no_fk = re.sub(r',\s*\)', ')', schema_no_fk)
        schema_no_fk = re.sub(r',\s*,', ',', schema_no_fk)
        
        cursor.execute(schema_no_fk)
        postgres_conn.commit()
        print(f"✓ Created table: {table_name}")
        return True
    except Exception as e:
        print(f"✗ Error creating table {table_name}: {e}")
        postgres_conn.rollback()
        return False

def insert_postgres_data(postgres_conn, table_name, columns, rows):
    """Insert data into PostgreSQL table"""
    if not rows:
        print(f"  No data to insert for {table_name}")
        return True
    
    cursor = postgres_conn.cursor()
    try:
        # Build the INSERT statement
        insert_query = sql.SQL("INSERT INTO {} ({}) VALUES ({})").format(
            sql.Identifier(table_name),
            sql.SQL(', ').join(map(sql.Identifier, columns)),
            sql.SQL(', ').join([sql.Placeholder()] * len(columns))
        )
        
        # Execute batch insert
        cursor.executemany(insert_query, rows)
        postgres_conn.commit()
        print(f"  ✓ Inserted {len(rows)} rows into {table_name}")
        return True
    except Exception as e:
        print(f"  ✗ Error inserting data into {table_name}: {e}")
        postgres_conn.rollback()
        return False

def migrate_table(sqlite_conn, postgres_conn, table_name):
    """Migrate a single table from SQLite to PostgreSQL"""
    print(f"\nMigrating table: {table_name}")
    
    # Get schema
    sqlite_schema = get_table_schema(sqlite_conn, table_name)
    if not sqlite_schema:
        print(f"  ✗ Could not get schema for {table_name}")
        return False
    
    # Convert schema
    postgres_schema = convert_sqlite_to_postgres(sqlite_schema)
    if not postgres_schema:
        print(f"  ✗ Could not convert schema for {table_name}")
        return False
    
    # Create table
    if not create_postgres_table(postgres_conn, table_name, postgres_schema):
        return False
    
    # Get data
    columns, rows = get_table_data(sqlite_conn, table_name)
    print(f"  Found {len(rows)} rows with {len(columns)} columns")
    
    # Insert data
    if not insert_postgres_data(postgres_conn, table_name, columns, rows):
        return False
    
    return True

def main():
    # Connect to SQLite
    sqlite_db_path = "/home/chisenga/projects/ERP/hr_platform.db"
    print(f"Connecting to SQLite database: {sqlite_db_path}")
    sqlite_conn = sqlite3.connect(sqlite_db_path)
    
    # Connect to PostgreSQL
    print(f"Connecting to PostgreSQL database: {Config.POSTGRES_DB}")
    try:
        postgres_conn = psycopg2.connect(**Config.get_postgres_params())
        postgres_conn.autocommit = False
    except Exception as e:
        print(f"✗ Could not connect to PostgreSQL: {e}")
        print("Please ensure PostgreSQL is running and credentials are correct.")
        print("You can start PostgreSQL with: sudo service postgresql start")
        print("And create the database with: sudo -u postgres createdb hr_platform")
        sqlite_conn.close()
        return
    
    # Get all tables
    tables = get_sqlite_tables(sqlite_conn)
    print(f"\nFound {len(tables)} tables to migrate")
    
    # Migrate each table
    success_count = 0
    failed_tables = []
    
    for table_name in tables:
        if migrate_table(sqlite_conn, postgres_conn, table_name):
            success_count += 1
        else:
            failed_tables.append(table_name)
    
    # Close connections
    sqlite_conn.close()
    postgres_conn.close()
    
    # Summary
    print(f"\n{'='*50}")
    print(f"Migration complete!")
    print(f"Successfully migrated: {success_count}/{len(tables)} tables")
    if failed_tables:
        print(f"Failed tables: {', '.join(failed_tables)}")
    print(f"{'='*50}")

if __name__ == "__main__":
    main()
