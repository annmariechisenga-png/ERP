import csv
import sqlite3
from pathlib import Path

root = Path('/Users/Work/Desktop/ERP')
db_path = root / 'hr_platform.db'
csv_path = root / 'authority_identifier_template.csv'
sql_path = root / 'merge_authorities_into_existing_db.sql'

province_names = {
    'ZM-01': 'Western',
    'ZM-02': 'Central',
    'ZM-03': 'Eastern',
    'ZM-04': 'Luapula',
    'ZM-05': 'Northern',
    'ZM-06': 'North-Western',
    'ZM-07': 'Southern',
    'ZM-08': 'Copperbelt',
    'ZM-09': 'Lusaka',
    'ZM-10': 'Muchinga',
}

rows = []
with csv_path.open(encoding='utf-8') as f:
    for row in csv.DictReader(f):
        official_name = row['official_name']
        suffixes = [' City Council', ' Municipal Council', ' Town Council', ' Council']
        authority_name = official_name
        for suffix in suffixes:
            if authority_name.endswith(suffix):
                authority_name = authority_name[:-len(suffix)]
                break

        authority_type = row['authority_type']
        short_type = authority_type.replace(' Council', '') if authority_type.endswith(' Council') else authority_type
        rows.append({
            **row,
            'province_name': province_names[row['province_code']],
            'authority_name': authority_name,
            'short_authority_type': short_type,
        })

sql_lines = []
sql_lines.append('BEGIN TRANSACTION;')
sql_lines.append('')
sql_lines.append('CREATE TABLE IF NOT EXISTS provinces (')
sql_lines.append('    province_code TEXT PRIMARY KEY,')
sql_lines.append('    country_code TEXT NOT NULL DEFAULT \'ZM\',')
sql_lines.append('    province_name TEXT NOT NULL UNIQUE')
sql_lines.append(');')
sql_lines.append('')
sql_lines.append('CREATE TABLE IF NOT EXISTS authority_master (')
sql_lines.append('    authority_id TEXT PRIMARY KEY,')
sql_lines.append('    country_code TEXT NOT NULL,')
sql_lines.append('    province_code TEXT NOT NULL,')
sql_lines.append('    legacy_authority_code TEXT NOT NULL UNIQUE,')
sql_lines.append('    display_code TEXT NOT NULL,')
sql_lines.append('    authority_ref TEXT NOT NULL UNIQUE,')
sql_lines.append('    authority_name TEXT NOT NULL UNIQUE,')
sql_lines.append('    official_name TEXT NOT NULL UNIQUE,')
sql_lines.append('    authority_type TEXT NOT NULL,')
sql_lines.append('    status TEXT NOT NULL DEFAULT \'active\',')
sql_lines.append('    valid_from DATE,')
sql_lines.append('    valid_to DATE,')
sql_lines.append('    FOREIGN KEY (province_code) REFERENCES provinces(province_code)')
sql_lines.append(');')
sql_lines.append('')
sql_lines.append('DELETE FROM authority_master;')
sql_lines.append('DELETE FROM provinces;')
sql_lines.append('DELETE FROM authorities;')
sql_lines.append('DELETE FROM authority_codes;')
sql_lines.append('')
for code, name in province_names.items():
    sql_lines.append(
        f"INSERT INTO provinces (province_code, country_code, province_name) VALUES ('{code}', 'ZM', '{name}');"
    )
sql_lines.append('')
for row in rows:
    def q(value: str) -> str:
        return value.replace("'", "''")
    sql_lines.append(
        "INSERT INTO authority_master (authority_id, country_code, province_code, legacy_authority_code, display_code, authority_ref, authority_name, official_name, authority_type, status, valid_from, valid_to) VALUES "
        f"('{q(row['authority_id'])}', '{q(row['country_code'])}', '{q(row['province_code'])}', '{q(row['legacy_authority_code'])}', '{q(row['display_code'])}', '{q(row['authority_ref'])}', '{q(row['authority_name'])}', '{q(row['official_name'])}', '{q(row['authority_type'])}', '{q(row['status'])}', "
        + (f"'{q(row['valid_from'])}'" if row['valid_from'] else 'NULL') + ', '
        + (f"'{q(row['valid_to'])}'" if row['valid_to'] else 'NULL')
        + ');'
    )
    sql_lines.append(
        f"INSERT INTO authority_codes (authority_name, authority_code) VALUES ('{q(row['authority_name'])}', '{q(row['legacy_authority_code'])}');"
    )
    sql_lines.append(
        f"INSERT INTO authorities (authority_prefix, authority_name, authority_type) VALUES ('{q(row['authority_ref'])}', '{q(row['official_name'])}', '{q(row['short_authority_type'])}');"
    )
sql_lines.append('')
sql_lines.append('DROP VIEW IF EXISTS authority_lookup;')
sql_lines.append('CREATE VIEW authority_lookup AS')
sql_lines.append('SELECT am.authority_id, am.country_code, am.province_code, p.province_name, am.legacy_authority_code, am.display_code, am.authority_ref, am.authority_name, am.official_name, am.authority_type, am.status, am.valid_from, am.valid_to')
sql_lines.append('FROM authority_master am')
sql_lines.append('JOIN provinces p ON p.province_code = am.province_code;')
sql_lines.append('')
sql_lines.append('COMMIT;')
sql_lines.append('')

sql_path.write_text('\n'.join(sql_lines), encoding='utf-8')

con = sqlite3.connect(db_path)
cur = con.cursor()
cur.executescript(sql_path.read_text(encoding='utf-8'))
con.commit()

checks = {}
for table in ['provinces', 'authority_master', 'authority_codes', 'authorities', 'Councils']:
    try:
        cur.execute(f'SELECT COUNT(*) FROM "{table}"')
        checks[table] = cur.fetchone()[0]
    except Exception as exc:
        checks[table] = f'ERR: {exc}'

cur.execute("SELECT authority_ref, official_name FROM authority_master WHERE official_name IN ('Chilanga Town Council','Lusaka City Council','Kitwe City Council','Livingstone City Council','Itezhi Tezhi Town Council') ORDER BY official_name")
samples = cur.fetchall()
con.close()

print('Applied merge to', db_path)
print('Counts:', checks)
print('Samples:', samples)
print('SQL saved to', sql_path)
