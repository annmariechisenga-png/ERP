import csv
import re
import uuid
from pathlib import Path

root = Path('/Users/Work/Desktop/ERP')
ocr_text = (root / 'province_ocr_all.txt').read_text(encoding='utf-8')
auth_sql = (root / 'extracted_data' / 'authority_codes.sql').read_text(encoding='utf-8')
out = root / 'authority_identifier_template.csv'

existing = {}
for name, code in re.findall(r"INSERT INTO authority_codes VALUES\('((?:[^']|'{2})*)','([A-Z0-9]+)'\);", auth_sql):
    existing[name.replace("''", "'")] = code

province_codes = {
    'Central Province.png': 'ZM-02',
    'Copperbelt Province.png': 'ZM-08',
    'Eastern Province.png': 'ZM-03',
    'Luapula Province.png': 'ZM-04',
    'Lusaka Province.png': 'ZM-09',
    'Muchinga Province.png': 'ZM-10',
    'North-Western Province.png': 'ZM-06',
    'Northern Province.png': 'ZM-05',
    'Southern Province.png': 'ZM-07',
    'Western Province.png': 'ZM-01',
}

official_name_fixes = {
    'MUFULIRIA MUNICIPAL COUNCIL': 'Mufulira Municipal Council',
    'KASENEGWA TOWN COUNCIL': 'Kasenengwa Town Council',
    'MANS MUNICIPAL COUNCIL': 'Mansa Municipal Council',
    'CHIENGE TOWN COUNCIL': 'Chiengi Town Council',
    'SHIWANGANDU TOWN COUNCIL': "Shiwang'andu Town Council",
    'SENGAHILL TOWN COUNCIL': 'Senga Hill Town Council',
    'COMA MUNICIPAL COUNCIL': 'Choma Municipal Council',
    'ITEZHITEHZI COUNCIL': 'Itezhi Tezhi Town Council',
}

# Preferred short/display abbreviations.
# Defaults use the existing local-authority codes where present.
# Explicit overrides handle user-provided council abbreviations.
display_code_overrides = {
    'Lusaka City Council': 'LCC',
    'Kitwe City Council': 'KCC',
    'Livingstone City Council': 'LCC',
}

# For the 7 councils missing from the current SQL list, infer practical short codes.
inferred_legacy_codes = {
    'Chililabombwe Municipal Council': 'CLC',
    'Mambwe Town Council': 'MMB',
    'Chongwe Municipal Council': 'CHG',
    'Luwingu Town Council': 'LWI',
    'Zimba Town Council': 'ZIM',
    'Mongu Municipal Council': 'MNG',
    'Kalabo Town Council': 'KLB',
}

# Since some inferred codes can collide with existing legacy codes, keep a distinct fallback set.
inferred_legacy_fallbacks = {
    'Chongwe Municipal Council': 'CHW',
    'Mongu Municipal Council': 'MGU',
    'Kalabo Town Council': 'KLO',
}

name_to_existing_source = {
    'Kabwe Municipal Council': 'Kabwe',
    'Serenje Town Council': 'Serenje',
    'Mumbwa Town Council': 'Mumbwa',
    'Kapiri Mposhi Town Council': 'Kapiri Mposhi',
    'Chisamba Town Council': 'Chisamba',
    'Shibuyunji Town Council': 'Shibuyunji',
    'Ngabwe Town Council': 'Ngabwe',
    'Chitambo Town Council': 'Chitambo',
    'Mkushi Town Council': 'Mkushi',
    'Chibombo Town Council': 'Chibombo',
    'Luano Town Council': 'Luano',
    'Ndola City Council': 'Ndola',
    'Kitwe City Council': 'Kitwe',
    'Chingola Municipal Council': 'Chingola',
    'Luanshya Municipal Council': 'Luanshya',
    'Kalulushi Municipal Council': 'Kalulushi',
    'Mufulira Municipal Council': 'Mufulira',
    'Mpongwe Town Council': 'Mpongwe',
    'Masaiti Town Council': 'Masaiti',
    'Lufwanyama Town Council': 'Lufwanyama',
    'Chipata City Council': 'Chipata',
    'Chama Town Council': 'Chama',
    'Lusangazi Town Council': 'Lusangazi',
    'Chadiza Town Council': 'Chadiza',
    'Katete Town Council': 'Katete',
    'Sinda Town Council': 'Sinda',
    'Lundazi Town Council': 'Lundazi',
    'Nyimba Town Council': 'Nyimba',
    'Lumezi Town Council': 'Lumezi',
    'Kasenengwa Town Council': 'Kasenengwa',
    'Chasefu Town Council': 'Chasefu',
    'Chipangali Town Council': 'Chipangali',
    'Petauke Town Council': 'Petauke',
    'Vubwi Town Council': 'Vubwi',
    'Mansa Municipal Council': 'Mansa',
    'Mwense Town Council': 'Mwense',
    'Nchelenge Town Council': 'Nchelenge',
    'Samfya Town Council': 'Samfya',
    'Milenge Town Council': 'Milenge',
    'Mwansabombwe Town Council': 'Mwansabombwe',
    'Chipili Town Council': 'Chipili',
    'Lunga Town Council': 'Lunga',
    'Chifunabuli Town Council': 'Chifunabuli',
    'Kawambwa Town Council': 'Kawambwa',
    'Chiengi Town Council': 'Chiengi',
    'Chembe Town Council': 'Chembe',
    'Lusaka City Council': 'Lusaka',
    'Rufunsa Town Council': 'Rufunsa',
    'Chilanga Town Council': 'Chilanga',
    'Kafue Town Council': 'Kafue',
    'Luangwa Town Council': 'Luangwa',
    'Chinsali Municipal Council': 'Chinsali',
    'Mpika Town Council': 'Mpika',
    "Shiwang'andu Town Council": "Shiwang'andu",
    'Lavushimanda Town Council': 'Lavushimanda',
    'Nakonde Town Council': 'Nakonde',
    'Mafinga Town Council': 'Mafinga',
    'Isoka Town Council': 'Isoka',
    'Kanchibiya Town Council': 'Kanchibiya',
    'Solwezi Municipal Council': 'Solwezi',
    'Zambezi Town Council': 'Zambezi',
    'Kalumbila Town Council': 'Kalumbila',
    'Mufumbwe Town Council': 'Mufumbwe',
    'Kasempa Town Council': 'Kasempa',
    'Mushindamo Town Council': 'Mushindamo',
    'Chavuma Town Council': 'Chavuma',
    'Manyinga Town Council': 'Manyinga',
    'Ikelenge Town Council': 'Ikelenge',
    'Kabompo Town Council': 'Kabompo',
    'Mwinilunga Town Council': 'Mwinilunga',
    'Kasama Municipal Council': 'Kasama',
    'Mbala Municipal Council': 'Mbala',
    'Mporokoso Town Council': 'Mporokoso',
    'Mpulungu Town Council': 'Mpulungu',
    'Nsama Town Council': 'Nsama',
    'Mungwi Town Council': 'Mungwi',
    'Senga Hill Town Council': 'Senga Hill',
    'Lunte Town Council': 'Lunte',
    'Lupososhi Town Council': 'Lupososhi',
    'Luwingu Town Council': 'Luwingu',
    'Kaputa Town Council': 'Kaputa',
    'Chilubi Town Council': 'Chilubi',
    'Livingstone City Council': 'Livingstone',
    'Mazabuka Municipal Council': 'Mazabuka',
    'Choma Municipal Council': 'Choma',
    'Kalomo Town Council': 'Kalomo',
    'Chikankata Town Council': 'Chikankata',
    'Namwala Town Council': 'Namwala',
    'Siavonga Town Council': 'Siavonga',
    'Monze Town Council': 'Monze',
    'Pemba Town Council': 'Pemba',
    'Zimba Town Council': 'Zimba',
    'Gwembe Town Council': 'Gwembe',
    'Sinazongwe Town Council': 'Sinazongwe',
    'Chirundu Town Council': 'Chirundu',
    'Kazungula Town Council': 'Kazungula',
    'Itezhi Tezhi Town Council': 'Itezhi-Tezhi',
    'Mongu Municipal Council': 'Mongu',
    'Lukulu Town Council': 'Lukulu',
    'Nkeyema Town Council': 'Nkeyema',
    'Sikongo Town Council': 'Sikongo',
    'Luampa Town Council': 'Luampa',
    'Kalabo Town Council': 'Kalabo',
    'Shangombo Town Council': 'Shangombo',
    'Nalolo Town Council': 'Nalolo',
    'Sioma Town Council': 'Sioma',
    'Senanga Town Council': 'Senanga',
    'Mwandi Town Council': 'Mwandi',
    'Limulunga Town Council': 'Limulunga',
    'Sesheke Town Council': 'Sesheke',
    'Mulobezi Town Council': 'Mulobezi',
    'Kaoma Town Council': 'Kaoma',
    'Mitete Town Council': 'Mitete',
    'Chongwe Municipal Council': 'Chongwe',
    'Mambwe Town Council': 'Mambwe',
    'Chililabombwe Municipal Council': 'Chililabombwe',
}

existing_codes_in_use = set(existing.values())
used_legacy_codes = set(existing.values())


def normalize_official_name(line: str) -> str:
    return official_name_fixes.get(line, line.title())


def authority_type_for(name: str) -> str:
    if name.endswith('City Council'):
        return 'City Council'
    if name.endswith('Municipal Council'):
        return 'Municipal Council'
    if name.endswith('Town Council'):
        return 'Town Council'
    return 'Council'


def pick_legacy_code(official_name: str) -> str:
    source_name = name_to_existing_source.get(official_name)
    if source_name and source_name in existing:
        return existing[source_name]

    code = inferred_legacy_codes.get(official_name)
    if code and code not in used_legacy_codes:
        used_legacy_codes.add(code)
        return code

    fallback = inferred_legacy_fallbacks.get(official_name)
    if fallback:
        used_legacy_codes.add(fallback)
        return fallback

    raise KeyError(f'No code mapping for {official_name}')


def pick_display_code(official_name: str, legacy_code: str) -> str:
    return display_code_overrides.get(official_name, legacy_code)

records = []
current_province = None
for raw in ocr_text.splitlines():
    line = raw.strip()
    if not line:
        continue
    if line.startswith('=== ') and line.endswith(' ==='):
        current_province = line[4:-4]
        continue
    if line.startswith('['):
        continue
    official_name = normalize_official_name(line)
    records.append((current_province, official_name))

seen = set()
unique_records = []
for province_file, official_name in records:
    key = (province_file, official_name)
    if key in seen:
        continue
    seen.add(key)
    unique_records.append((province_file, official_name))

rows = []
ns = uuid.UUID('12345678-1234-5678-1234-567812345678')
for province_file, official_name in unique_records:
    province_code = province_codes[province_file]
    legacy_code = pick_legacy_code(official_name)
    display_code = pick_display_code(official_name, legacy_code)
    authority_ref = f'{province_code}-{display_code}'
    authority_id = str(uuid.uuid5(ns, f'{province_code}|{display_code}|{official_name}'))
    rows.append({
        'authority_id': authority_id,
        'country_code': 'ZM',
        'province_code': province_code,
        'legacy_authority_code': legacy_code,
        'display_code': display_code,
        'authority_ref': authority_ref,
        'official_name': official_name,
        'authority_type': authority_type_for(official_name),
        'status': 'active',
        'valid_from': '',
        'valid_to': '',
    })

rows.sort(key=lambda r: (r['province_code'], r['official_name']))
with out.open('w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=[
        'authority_id',
        'country_code',
        'province_code',
        'legacy_authority_code',
        'display_code',
        'authority_ref',
        'official_name',
        'authority_type',
        'status',
        'valid_from',
        'valid_to',
    ])
    writer.writeheader()
    writer.writerows(rows)

print(f'Wrote {len(rows)} rows to {out}')
