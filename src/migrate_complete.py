#!/usr/bin/env python3
"""
Complete migration script for all tables and views
"""
import sqlite3
import psycopg2
from psycopg2 import sql
import re
import time
from config import Config

def get_all_sqlite_objects(sqlite_conn):
    """Get all tables and views from SQLite"""
    cursor = sqlite_conn.cursor()
    
    # Get tables
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;")
    tables = [row[0] for row in cursor.fetchall()]
    
    # Get views
    cursor.execute("SELECT name FROM sqlite_master WHERE type='view' ORDER BY name;")
    views = [row[0] for row in cursor.fetchall()]
    
    return tables, views

def convert_sqlite_to_postgres(sqlite_schema, is_view=False):
    """Convert SQLite schema to PostgreSQL compatible format"""
    if not sqlite_schema:
        return None
    
    postgres_schema = sqlite_schema
    
    if not is_view:
        # Replace AUTOINCREMENT with SERIAL
        postgres_schema = re.sub(r'INTEGER PRIMARY KEY AUTOINCREMENT', 'SERIAL PRIMARY KEY', postgres_schema, flags=re.IGNORECASE)
        postgres_schema = re.sub(r'INTEGER PRIMARY KEY(?!\s+AUTOINCREMENT)', 'SERIAL PRIMARY KEY', postgres_schema, flags=re.IGNORECASE)
        postgres_schema = re.sub(r'\bREAL\b', 'DOUBLE PRECISION', postgres_schema, flags=re.IGNORECASE)
        postgres_schema = re.sub(r'\bDATETIME\b', 'TIMESTAMP', postgres_schema, flags=re.IGNORECASE)
        postgres_schema = re.sub(r'\bCURRENT_TIMESTAMP\b', 'NOW()', postgres_schema, flags=re.IGNORECASE)
    
    return postgres_schema

def create_or_replace_view(postgres_conn, view_name, view_sql):
    """Create or replace a view in PostgreSQL"""
    cursor = postgres_conn.cursor()
    try:
        # Drop view if exists
        cursor.execute(f"DROP VIEW IF EXISTS {view_name} CASCADE;")
        # Create view
        cursor.execute(view_sql)
        postgres_conn.commit()
        print(f"  ✓ Created view: {view_name}")
        return True
    except Exception as e:
        print(f"  ✗ Failed to create view {view_name}: {e}")
        postgres_conn.rollback()
        return False

def create_table(postgres_conn, table_name, schema):
    """Create table in PostgreSQL"""
    cursor = postgres_conn.cursor()
    try:
        cursor.execute(schema)
        postgres_conn.commit()
        print(f"  ✓ Created table: {table_name}")
        return True
    except Exception as e:
        print(f"  ✗ Failed to create {table_name}: {e}")
        postgres_conn.rollback()
        return False

def insert_data(sqlite_conn, postgres_conn, table_name):
    """Insert data into PostgreSQL table"""
    try:
        # Get data from SQLite
        cursor = sqlite_conn.cursor()
        cursor.execute(f"SELECT * FROM {table_name};")
        rows = cursor.fetchall()
        
        if not rows:
            print(f"  ℹ No data in {table_name}")
            return True
        
        # Get column names
        columns = [description[0] for description in cursor.description]
        
        # Insert into PostgreSQL
        postgres_cursor = postgres_conn.cursor()
        insert_query = sql.SQL("INSERT INTO {} ({}) VALUES ({})").format(
            sql.Identifier(table_name),
            sql.SQL(', ').join(map(sql.Identifier, columns)),
            sql.SQL(', ').join([sql.Placeholder()] * len(columns))
        )
        
        # Insert in batches to handle large datasets
        batch_size = 1000
        for i in range(0, len(rows), batch_size):
            batch = rows[i:i+batch_size]
            postgres_cursor.executemany(insert_query, batch)
            postgres_conn.commit()
            print(f"  ✓ Inserted {len(batch)} rows into {table_name} (batch {i//batch_size + 1})")
        
        return True
    except Exception as e:
        print(f"  ✗ Data insertion failed for {table_name}: {e}")
        postgres_conn.rollback()
        return False

def main():
    # Connect to SQLite
    sqlite_path = "/home/chisenga/projects/ERP/hr_platform.db"
    print(f"📂 Source: {sqlite_path}")
    sqlite_conn = sqlite3.connect(sqlite_path)
    
    # Connect to PostgreSQL
    print(f"🐘 Target: PostgreSQL ({Config.POSTGRES_DB})\n")
    try:
        postgres_conn = psycopg2.connect(**Config.get_postgres_params())
        postgres_conn.autocommit = False
    except Exception as e:
        print(f"✗ PostgreSQL connection failed: {e}")
        return
    
    # Get all objects
    tables, views = get_all_sqlite_objects(sqlite_conn)
    print(f"📋 Found {len(tables)} tables and {len(views)} views\n")
    
    # Phase 1: Create all tables
    print("=" * 60)
    print("PHASE 1: Creating Tables")
    print("=" * 60)
    
    tables_created = []
    for table_name in tables:
        cursor = sqlite_conn.cursor()
        cursor.execute(f"SELECT sql FROM sqlite_master WHERE type='table' AND name='{table_name}';")
        result = cursor.fetchone()
        
        if result and result[0]:
            postgres_schema = convert_sqlite_to_postgres(result[0], is_view=False)
            if postgres_schema and create_table(postgres_conn, table_name, postgres_schema):
                tables_created.append(table_name)
        time.sleep(0.05)
    
    # Phase 2: Insert data
    print("\n" + "=" * 60)
    print("PHASE 2: Inserting Data")
    print("=" * 60)
    
    for table_name in tables_created:
        insert_data(sqlite_conn, postgres_conn, table_name)
    
    # Phase 3: Create views
    print("\n" + "=" * 60)
    print("PHASE 3: Creating Views")
    print("=" * 60)
    
    views_created = []
    for view_name in views:
        cursor = sqlite_conn.cursor()
        cursor.execute(f"SELECT sql FROM sqlite_master WHERE type='view' AND name='{view_name}';")
        result = cursor.fetchone()
        
        if result and result[0]:
            view_sql = convert_sqlite_to_postgres(result[0], is_view=True)
            if view_sql and create_or_replace_view(postgres_conn, view_name, view_sql):
                views_created.append(view_name)
    
    # Close connections
    sqlite_conn.close()
    postgres_conn.close()
    
    # Final summary
    print("\n" + "=" * 60)
    print("✅ MIGRATION COMPLETE!")
    print("=" * 60)
    print(f"📊 Tables created: {len(tables_created)}/{len(tables)}")
    print(f"👁️  Views created: {len(views_created)}/{len(views)}")
    
    if len(tables_created) < len(tables):
        missing = set(tables) - set(tables_created)
        print(f"\n⚠️  Missing tables ({len(missing)}):")
        for i, table in enumerate(list(missing)[:10], 1):
            print(f"   {i}. {table}")
        if len(missing) > 10:
            print(f"   ... and {len(missing) - 10} more")
    
    print("=" * 60)

if __name__ == "__main__":
    main()
