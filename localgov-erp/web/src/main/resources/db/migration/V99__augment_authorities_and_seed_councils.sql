-- =====================================================================
-- V99__augment_authorities_and_seed_councils.sql
-- Layer 1 — National Registry: Augment authorities + seed 116 councils
-- =====================================================================
-- Augments the existing `authorities` table with registry fields and
-- seeds all 116 Zambian local authorities.
--
-- authority_code convention: UPPERCASE, underscores for spaces.
-- council_seq: alphabetical within province, frozen forever.
--
-- Hardship classification:
--   NULL     → not yet classified (data collection in progress)
--   'NONE'   → 0% allowance
--   'RURAL'  → 20% allowance
--   'REMOTE' → 25% allowance
--
-- The hardship classification drives a payroll allowance. It is
-- expected to be updated over time as the Ministry completes data
-- collection. Every change is audited.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Augment authorities
-- ---------------------------------------------------------------------
ALTER TABLE authorities
    ADD COLUMN IF NOT EXISTS authority_code VARCHAR(50),
    ADD COLUMN IF NOT EXISTS province_code VARCHAR(2),
    ADD COLUMN IF NOT EXISTS council_seq INTEGER,
    ADD COLUMN IF NOT EXISTS council_type_id INTEGER REFERENCES council_types(council_type_id),
    ADD COLUMN IF NOT EXISTS hardship_classification VARCHAR(20),
    ADD COLUMN IF NOT EXISTS hardship_allowance_pct NUMERIC(5,2),
    ADD COLUMN IF NOT EXISTS hardship_updated_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS hardship_updated_by UUID,
    ADD COLUMN IF NOT EXISTS hardship_source TEXT,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS sequence_frozen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS notes TEXT,
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS created_by UUID,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS updated_by UUID;

-- ---------------------------------------------------------------------
-- 2. Constraints
-- ---------------------------------------------------------------------
ALTER TABLE authorities
    DROP CONSTRAINT IF EXISTS uq_authorities_code,
    ADD CONSTRAINT uq_authorities_code UNIQUE (authority_code);

ALTER TABLE authorities
    DROP CONSTRAINT IF EXISTS uq_authorities_province_seq,
    ADD CONSTRAINT uq_authorities_province_seq UNIQUE (province_code, council_seq);

ALTER TABLE authorities
    DROP CONSTRAINT IF EXISTS chk_authorities_province,
    ADD CONSTRAINT chk_authorities_province CHECK (
        province_code IN ('01','02','03','04','05','06','07','08','09','10')
    );

-- Hardship: NULL is allowed (not yet classified).
-- If classification is set, allowance_pct must match (or be NULL).
ALTER TABLE authorities
    DROP CONSTRAINT IF EXISTS chk_authorities_hardship,
    ADD CONSTRAINT chk_authorities_hardship CHECK (
        hardship_classification IS NULL
        OR hardship_classification IN ('NONE', 'RURAL', 'REMOTE')
    );

ALTER TABLE authorities
    DROP CONSTRAINT IF EXISTS chk_authorities_hardship_pct,
    ADD CONSTRAINT chk_authorities_hardship_pct CHECK (
        (hardship_classification IS NULL)
        OR (hardship_classification = 'NONE'   AND COALESCE(hardship_allowance_pct, 0)  = 0)
        OR (hardship_classification = 'RURAL'  AND COALESCE(hardship_allowance_pct, 20) = 20)
        OR (hardship_classification = 'REMOTE' AND COALESCE(hardship_allowance_pct, 25) = 25)
    );

-- ---------------------------------------------------------------------
-- 3. Indexes
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_authorities_code
    ON authorities(authority_code);
CREATE INDEX IF NOT EXISTS idx_authorities_province
    ON authorities(province_code, council_seq);
CREATE INDEX IF NOT EXISTS idx_authorities_active
    ON authorities(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_authorities_hardship
    ON authorities(hardship_classification)
    WHERE hardship_classification IS NOT NULL;

-- ---------------------------------------------------------------------
-- 4. Seed 116 councils
-- ---------------------------------------------------------------------
INSERT INTO authorities (
    authority_code, authority_name, authority_prefix, authority_type,
    province_code, council_seq, council_type_id,
    hardship_classification, hardship_allowance_pct, hardship_source
) VALUES

-- CENTRAL PROVINCE (02)
('CHIBOMBO',    'Chibombo Town Council',      'CHB', 'TOWN',      '02',  1, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('CHISAMBA',    'Chisamba Town Council',      'CSB', 'TOWN',      '02',  2, 1, NULL,     NULL,  NULL),
('CHITAMBO',    'Chitambo Town Council',      'CTB', 'TOWN',      '02',  3, 1, NULL,     NULL,  NULL),
('KABWE',       'Kabwe Municipal Council',    'KBW', 'MUNICIPAL', '02',  4, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('KAPIRI_MPOSHI','Kapiri Mposhi Town Council','KPM', 'TOWN',      '02',  5, 1, NULL,     NULL,  NULL),
('LUANO',       'Luano Town Council',         'LNO', 'TOWN',      '02',  6, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('MKUSHI',      'Mkushi Town Council',        'MKS', 'TOWN',      '02',  7, 1, NULL,     NULL,  NULL),
('MUMBWA',      'Mumbwa Town Council',        'MBW', 'TOWN',      '02',  8, 1, NULL,     NULL,  NULL),
('NGABWE',      'Ngabwe Town Council',        'NGB', 'TOWN',      '02',  9, 1, NULL,     NULL,  NULL),
('SERENJE',     'Serenje Town Council',       'SRJ', 'TOWN',      '02', 10, 1, NULL,     NULL,  NULL),
('SHIBUYUNJI',  'Shibuyunji Town Council',    'SBY', 'TOWN',      '02', 11, 1, NULL,     NULL,  NULL),

-- COPPERBELT PROVINCE (08)
('CHILILABOMBWE','Chililabombwe Municipal Council','CLB','MUNICIPAL','08', 1, 2, 'NONE',  0.00, 'Hardship Allowance 2026'),
('CHINGOLA',    'Chingola Municipal Council', 'CHG', 'MUNICIPAL', '08',  2, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('KALULUSHI',   'Kalulushi Municipal Council','KLU', 'MUNICIPAL', '08',  3, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('KITWE',       'Kitwe City Council',         'KTW', 'CITY',      '08',  4, 3, 'NONE',    0.00, 'Hardship Allowance 2026'),
('LUANSHYA',    'Luanshya Municipal Council', 'LUN', 'MUNICIPAL', '08',  5, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('LUFWANYAMA',  'Lufwanyama Town Council',    'LFW', 'TOWN',      '08',  6, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('MASAITI',     'Masaiti Town Council',       'MST', 'TOWN',      '08',  7, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('MPONGWE',     'Mpongwe Town Council',       'MPG', 'TOWN',      '08',  8, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('MUFULIRA',    'Mufulira Municipal Council', 'MFL', 'MUNICIPAL', '08',  9, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('NDOLA',       'Ndola City Council',         'NDL', 'CITY',      '08', 10, 3, 'NONE',    0.00, 'Hardship Allowance 2026'),

-- EASTERN PROVINCE (03)
('CHADIZA',     'Chadiza Town Council',       'CDZ', 'TOWN',      '03',  1, 1, NULL,     NULL,  NULL),
('CHAMA',       'Chama Town Council',         'CHM', 'TOWN',      '03',  2, 1, NULL,     NULL,  NULL),
('CHASEFU',     'Chasefu Town Council',       'CSF', 'TOWN',      '03',  3, 1, NULL,     NULL,  NULL),
('CHIPANGALI',  'Chipangali Town Council',    'CPG', 'TOWN',      '03',  4, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('CHIPATA',     'Chipata City Council',       'CPT', 'CITY',      '03',  5, 3, NULL,     NULL,  NULL),
('KASENENGWA',  'Kasenengwa Town Council',    'KSN', 'TOWN',      '03',  6, 1, NULL,     NULL,  NULL),
('KATETE',      'Katete Town Council',        'KTT', 'TOWN',      '03',  7, 1, NULL,     NULL,  NULL),
('LUMEZI',      'Lumezi Town Council',        'LMZ', 'TOWN',      '03',  8, 1, NULL,     NULL,  NULL),
('LUNDAZI',     'Lundazi Town Council',       'LDZ', 'TOWN',      '03',  9, 1, 'NONE',    0.00, 'Hardship Allowance 2026'),
('LUSANGAZI',   'Lusangazi Town Council',     'LSG', 'TOWN',      '03', 10, 1, NULL,     NULL,  NULL),
('MAMBWE',      'Mambwe Town Council',        'MBE', 'TOWN',      '03', 11, 1, NULL,     NULL,  NULL),
('NYIMBA',      'Nyimba Town Council',        'NYB', 'TOWN',      '03', 12, 1, NULL,     NULL,  NULL),
('PETAUKE',     'Petauke Town Council',       'PTK', 'TOWN',      '03', 13, 1, 'NONE',    0.00, 'Hardship Allowance 2026'),
('SINDA',       'Sinda Town Council',         'SND', 'TOWN',      '03', 14, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('VUBWI',       'Vubwi Town Council',         'VBW', 'TOWN',      '03', 15, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),

-- LUAPULA PROVINCE (04)
('CHEMBE',      'Chembe Town Council',        'CMB', 'TOWN',      '04',  1, 1, NULL,     NULL,  NULL),
('CHIENGI',     'Chiengi Town Council',       'CNG', 'TOWN',      '04',  2, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('CHIFUNABULI', 'Chifunabuli Town Council',   'CFB', 'TOWN',      '04',  3, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('CHIPILI',     'Chipili Town Council',       'CPL', 'TOWN',      '04',  4, 1, NULL,     NULL,  NULL),
('KAWAMBWA',    'Kawambwa Town Council',      'KWB', 'TOWN',      '04',  5, 1, NULL,     NULL,  NULL),
('LUNGA',       'Lunga Town Council',         'LNG', 'TOWN',      '04',  6, 1, NULL,     NULL,  NULL),
('MANSA',       'Mansa Municipal Council',    'MNS', 'MUNICIPAL', '04',  7, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('MILENGE',     'Milenge Town Council',       'MLG', 'TOWN',      '04',  8, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('MWANSABOMBWE','Mwansabombwe Town Council',  'MWB', 'TOWN',      '04',  9, 1, NULL,     NULL,  NULL),
('MWENSE',      'Mwense Town Council',        'MWS', 'TOWN',      '04', 10, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('NCHELENGE',   'Nchelenge Town Council',     'NCH', 'TOWN',      '04', 11, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('SAMFYA',      'Samfya Town Council',        'SMF', 'TOWN',      '04', 12, 1, 'NONE',    0.00, 'Hardship Allowance 2026'),

-- LUSAKA PROVINCE (09)
('CHILANGA',    'Chilanga Town Council',      'CHL', 'TOWN',      '09',  1, 1, 'NONE',    0.00, 'Hardship Allowance 2026'),
('CHONGWE',     'Chongwe Municipal Council',  'CHW', 'MUNICIPAL', '09',  2, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('KAFUE',       'Kafue Town Council',         'KAF', 'TOWN',      '09',  3, 1, 'NONE',    0.00, 'Hardship Allowance 2026'),
('LUANGWA',     'Luangwa Town Council',       'LGW', 'TOWN',      '09',  4, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('LUSAKA_CITY', 'Lusaka City Council',        'LSK', 'CITY',      '09',  5, 3, 'NONE',    0.00, 'Hardship Allowance 2026'),
('RUFUNSA',     'Rufunsa Town Council',       'RFS', 'TOWN',      '09',  6, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),

-- MUCHINGA PROVINCE (10)
('CHINSALI',    'Chinsali Municipal Council', 'CNS', 'MUNICIPAL', '10',  1, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('ISOKA',       'Isoka Town Council',         'ISK', 'TOWN',      '10',  2, 1, NULL,     NULL,  NULL),
('KANCHIBIYA',  'Kanchibiya Town Council',    'KCB', 'TOWN',      '10',  3, 1, NULL,     NULL,  NULL),
('LAVUSHIMANDA','Lavushimanda Town Council',  'LVD', 'TOWN',      '10',  4, 1, NULL,     NULL,  NULL),
('MAFINGA',     'Mafinga Town Council',       'MFG', 'TOWN',      '10',  5, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('MPIKA',       'Mpika Town Council',         'MPK', 'TOWN',      '10',  6, 1, NULL,     NULL,  NULL),
('NAKONDE',     'Nakonde Town Council',       'NKD', 'TOWN',      '10',  7, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('SHIWANGANDU', 'Shiwang''andu Town Council', 'SWD', 'TOWN',      '10',  8, 1, NULL,     NULL,  NULL),

-- NORTHERN PROVINCE (05)
('CHILUBI',     'Chilubi Town Council',       'CBI', 'TOWN',      '05',  1, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('KAPUTA',      'Kaputa Town Council',        'KPT', 'TOWN',      '05',  2, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('KASAMA',      'Kasama Municipal Council',   'KSM', 'MUNICIPAL', '05',  3, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('LUNTE',       'Lunte Town Council',         'LNT', 'TOWN',      '05',  4, 1, NULL,     NULL,  NULL),
('LUPOSOSHI',   'Lupososhi Town Council',     'LPS', 'TOWN',      '05',  5, 1, NULL,     NULL,  NULL),
('LUWINGU',     'Luwingu Town Council',       'LWG', 'TOWN',      '05',  6, 1, NULL,     NULL,  NULL),
('MBALA',       'Mbala Municipal Council',    'MBL', 'MUNICIPAL', '05',  7, 2, NULL,     NULL,  NULL),
('MPOROKOSO',   'Mporokoso Town Council',     'MPR', 'TOWN',      '05',  8, 1, NULL,     NULL,  NULL),
('MPULUNGU',    'Mpulungu Town Council',      'MPL', 'TOWN',      '05',  9, 1, NULL,     NULL,  NULL),
('MUNGWI',      'Mungwi Town Council',        'MNG', 'TOWN',      '05', 10, 1, NULL,     NULL,  NULL),
('NSAMA',       'Nsama Town Council',         'NSM', 'TOWN',      '05', 11, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('SENGA_HILL',  'Senga Hill Town Council',    'SGH', 'TOWN',      '05', 12, 1, NULL,     NULL,  NULL),

-- NORTH-WESTERN PROVINCE (06)
('CHAVUMA',     'Chavuma Town Council',       'CVM', 'TOWN',      '06',  1, 1, NULL,     NULL,  NULL),
('IKELENGE',    'Ikelenge Town Council',      'IKL', 'TOWN',      '06',  2, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('KABOMPO',     'Kabompo Town Council',       'KBP', 'TOWN',      '06',  3, 1, NULL,     NULL,  NULL),
('KALUMBILA',   'Kalumbila Town Council',     'KLB', 'TOWN',      '06',  4, 1, NULL,     NULL,  NULL),
('KASEMPA',     'Kasempa Town Council',       'KSP', 'TOWN',      '06',  5, 1, NULL,     NULL,  NULL),
('MANYINGA',    'Manyinga Town Council',      'MYN', 'TOWN',      '06',  6, 1, NULL,     NULL,  NULL),
('MUFUMBWE',    'Mufumbwe Town Council',      'MFB', 'TOWN',      '06',  7, 1, NULL,     NULL,  NULL),
('MUSHINDAMO',  'Mushindamo Town Council',    'MSD', 'TOWN',      '06',  8, 1, NULL,     NULL,  NULL),
('MWINILUNGA',  'Mwinilunga Town Council',    'MWL', 'TOWN',      '06',  9, 1, NULL,     NULL,  NULL),
('SOLWEZI',     'Solwezi Municipal Council',  'SWZ', 'MUNICIPAL', '06', 10, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('ZAMBEZI',     'Zambezi Town Council',       'ZMB', 'TOWN',      '06', 11, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),

-- SOUTHERN PROVINCE (07)
('CHIKANKATA',  'Chikankata Town Council',    'CKK', 'TOWN',      '07',  1, 1, NULL,     NULL,  NULL),
('CHIRUNDU',    'Chirundu Town Council',      'CRD', 'TOWN',      '07',  2, 1, NULL,     NULL,  NULL),
('CHOMA',       'Choma Municipal Council',    'CMA', 'MUNICIPAL', '07',  3, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('GWEMBE',      'Gwembe Town Council',        'GWB', 'TOWN',      '07',  4, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('ITEZHI_TEZHI','Itezhi Tezhi Town Council',  'ITT', 'TOWN',      '07',  5, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('KALOMO',      'Kalomo Town Council',        'KLM', 'TOWN',      '07',  6, 1, NULL,     NULL,  NULL),
('KAZUNGULA',   'Kazungula Town Council',     'KZL', 'TOWN',      '07',  7, 1, NULL,     NULL,  NULL),
('LIVINGSTONE', 'Livingstone City Council',   'LVS', 'CITY',      '07',  8, 3, 'NONE',    0.00, 'Hardship Allowance 2026'),
('MAZABUKA',    'Mazabuka Municipal Council', 'MZB', 'MUNICIPAL', '07',  9, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('MONZE',       'Monze Town Council',         'MNZ', 'TOWN',      '07', 10, 1, NULL,     NULL,  NULL),
('NAMWALA',     'Namwala Town Council',       'NMW', 'TOWN',      '07', 11, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('PEMBA',       'Pemba Town Council',         'PMB', 'TOWN',      '07', 12, 1, 'RURAL',  20.00, 'Hardship Allowance 2026'),
('SIAVONGA',    'Siavonga Town Council',      'SVG', 'TOWN',      '07', 13, 1, NULL,     NULL,  NULL),
('SINAZONGWE',  'Sinazongwe Town Council',    'SZG', 'TOWN',      '07', 14, 1, NULL,     NULL,  NULL),
('ZIMBA',       'Zimba Town Council',         'ZMA', 'TOWN',      '07', 15, 1, NULL,     NULL,  NULL),

-- WESTERN PROVINCE (01)
('KALABO',      'Kalabo Town Council',        'KBO', 'TOWN',      '01',  1, 1, NULL,     NULL,  NULL),
('KAOMA',       'Kaoma Town Council',         'KMA', 'TOWN',      '01',  2, 1, NULL,     NULL,  NULL),
('LIMULUNGA',   'Limulunga Town Council',     'LML', 'TOWN',      '01',  3, 1, NULL,     NULL,  NULL),
('LUAMPA',      'Luampa Town Council',        'LMP', 'TOWN',      '01',  4, 1, NULL,     NULL,  NULL),
('LUKULU',      'Lukulu Town Council',        'LKL', 'TOWN',      '01',  5, 1, NULL,     NULL,  NULL),
('MITETE',      'Mitete Town Council',        'MTT', 'TOWN',      '01',  6, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('MONGU',       'Mongu Municipal Council',    'MNG', 'MUNICIPAL', '01',  7, 2, 'NONE',    0.00, 'Hardship Allowance 2026'),
('MULOBEZI',    'Mulobezi Town Council',      'MLB', 'TOWN',      '01',  8, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('MWANDI',      'Mwandi Town Council',        'MWD', 'TOWN',      '01',  9, 1, NULL,     NULL,  NULL),
('NALOLO',      'Nalolo Town Council',        'NLL', 'TOWN',      '01', 10, 1, NULL,     NULL,  NULL),
('NKEYEMA',     'Nkeyema Town Council',       'NKY', 'TOWN',      '01', 11, 1, NULL,     NULL,  NULL),
('SENANGA',     'Senanga Town Council',       'SNG', 'TOWN',      '01', 12, 1, NULL,     NULL,  NULL),
('SESHEKE',     'Sesheke Town Council',       'SSK', 'TOWN',      '01', 13, 1, NULL,     NULL,  NULL),
('SHANGOMBO',   'Shangombo Town Council',     'SHG', 'TOWN',      '01', 14, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('SIKONGO',     'Sikongo Town Council',       'SKG', 'TOWN',      '01', 15, 1, 'REMOTE', 25.00, 'Hardship Allowance 2026'),
('SIOMA',       'Sioma Town Council',         'SMA', 'TOWN',      '01', 16, 1, NULL,     NULL,  NULL)

ON CONFLICT (authority_code) DO NOTHING;

-- ---------------------------------------------------------------------
-- 5. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'PLATFORM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'augment_authorities_and_seed_councils',
        'migration', 'V99',
        'councils_seeded', 116,
        'provinces_covered', 10,
        'hardship_note', 'Partial classifications. Updates audited.'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
