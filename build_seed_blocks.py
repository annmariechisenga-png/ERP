import csv
from pathlib import Path

root = Path('/Users/Work/Desktop/ERP')
rows = list(csv.DictReader((root / 'authority_identifier_template.csv').open(encoding='utf-8')))

existing_109 = {
    'Chilanga','Chibombo','Chisamba','Chitambo','Kabwe','Kapiri Mposhi','Luano','Mkushi','Mumbwa','Ngabwe','Serenje','Shibuyunji','Chingola','Kalulushi','Kitwe','Luanshya','Lufwanyama','Masaiti','Mpongwe','Mufulira','Ndola','Chadiza','Chama','Chasefu','Chipangali','Chipata','Kasenengwa','Katete','Lumezi','Lundazi','Lusangazi','Nyimba','Petauke','Sinda','Vubwi','Chembe','Chiengi','Chifunabuli','Chipili','Kawambwa','Lunga','Mansa','Milenge','Mwansabombwe','Mwense','Nchelenge','Samfya','Kafue','Luangwa','Lusaka','Rufunsa','Chinsali','Isoka','Mafinga','Mpika','Nakonde','Kanchibiya','Lavushimanda',"Shiwang'andu",'Kasama','Chilubi','Kaputa','Mbala','Mporokoso','Mpulungu','Mungwi','Nsama','Lupososhi','Lunte','Senga Hill','Chavuma','Ikelenge','Kabompo','Kalumbila','Kasempa','Manyinga','Mufumbwe','Mushindamo','Mwinilunga','Solwezi','Zambezi','Chikankata','Chirundu','Choma','Gwembe','Itezhi-Tezhi','Kalomo','Kazungula','Livingstone','Mazabuka','Monze','Namwala','Pemba','Siavonga','Sinazongwe','Kaoma','Limulunga','Luampa','Lukulu','Mitete','Mulobezi','Mwandi','Nalolo','Nkeyema','Senanga','Sesheke','Shangombo','Sikongo','Sioma'
}

def base_name(official_name: str) -> str:
    name = official_name
    for suffix in [' City Council', ' Municipal Council', ' Town Council', ' Council']:
        if name.endswith(suffix):
            return name[:-len(suffix)]
    return name

missing = []
authorities = []
for row in rows:
    official = row['official_name']
    base = base_name(official)
    code = row['legacy_authority_code']
    authority_type = row['authority_type'].replace(' Council', '')

    if base not in existing_109:
        missing.append((base, code))

    authorities.append((row['authority_ref'], official, authority_type))

with (root / '_missing_authority_codes.sql').open('w', encoding='utf-8') as f:
    for base, code in sorted(missing):
        esc = base.replace("'", "''")
        f.write(f"INSERT INTO authority_codes VALUES('{esc}','{code}');\n")

with (root / '_all_authorities_inserts.sql').open('w', encoding='utf-8') as f:
    for prefix, name, auth_type in authorities:
        esc_name = name.replace("'", "''")
        f.write(f"INSERT INTO authorities VALUES('{prefix}','{esc_name}','{auth_type}');\n")

print('missing_count', len(missing))
print('authorities_count', len(authorities))
