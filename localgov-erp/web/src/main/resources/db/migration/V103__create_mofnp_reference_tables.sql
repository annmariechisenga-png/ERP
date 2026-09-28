-- =====================================================================
-- V103__create_mofnp_reference_tables.sql
-- MoFNP Multi-Dimensional Model — Reference Tables
-- =====================================================================
-- Compliance:
--   MoFNP Local Government Accounting and Financial Procedures Manual
--   (December 2023), Section 10.2 (functional classification),
--   Section 10.3 (Local Authorities Head), Section 10.12 (coding structure)
--
-- Creates:
--   1. mofnp_department        — council departments
--   2. mofnp_unit              — units within departments (schema only)
--   3. mofnp_function          — COFOG functional classification
--   4. mofnp_programme         — programme registry per council
--   5. mofnp_commitment_type   — commitment type codes
--   6. Extends `authorities` with MoFNP province + head codes
--
-- The full code structure from the manual:
--   {Head}.{Dept}.{Unit}.{Prog}.{SubProg}.{CommitType}.{CoA}{ManNumber}
--   Example: 01103.37.01xx.001.322070xxxxx
--
-- NOTE: Legal and Valuation departments are deferred to a later
-- incremental migration once their MoFNP codes are confirmed.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. MoFNP Department
-- ---------------------------------------------------------------------
-- Nine confirmed council departments (2026-09-28):
--   01 Office of the Council Secretary / Town Clerk
--   02 Finance
--   03 HRA
--   04 Planning
--   05 Engineering
--   06 Public Health
--   07 Community Services
--   08 Procurement
--   09 Internal Audit
-- ---------------------------------------------------------------------
CREATE TABLE mofnp_department (
    department_code    VARCHAR(2) PRIMARY KEY,
    department_name    VARCHAR(200) NOT NULL,
    department_short   VARCHAR(20),
    mofnp_function     VARCHAR(2),
    sort_order         INTEGER NOT NULL DEFAULT 0,
    is_active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by         UUID,
    updated_at         TIMESTAMPTZ,
    updated_by         UUID
);

COMMENT ON TABLE mofnp_department IS
'MoFNP council departments. Codes 01-09 confirmed by user. Legal and '
'Valuation to be added via incremental migration when codes confirmed.';

INSERT INTO mofnp_department (department_code, department_name, department_short, mofnp_function, sort_order) VALUES
    ('01', 'Office of the Council Secretary / Town Clerk', 'COS',   '01', 1),
    ('02', 'Finance',                                       'FIN',   '01', 2),
    ('03', 'Human Resource & Administration',               'HRA',   '01', 3),
    ('04', 'Planning',                                      'PLAN',  '06', 4),
    ('05', 'Engineering',                                   'ENG',   '04', 5),
    ('06', 'Public Health',                                 'HLTH',  '07', 6),
    ('07', 'Community Services',                            'COMM',  '08', 7),
    ('08', 'Procurement',                                   'PROC',  '01', 8),
    ('09', 'Internal Audit',                                'AUD',   '01', 9)
ON CONFLICT (department_code) DO NOTHING;

-- ---------------------------------------------------------------------
-- 2. MoFNP Unit
-- ---------------------------------------------------------------------
CREATE TABLE mofnp_unit (
    unit_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code     VARCHAR(50) NOT NULL REFERENCES authorities(authority_code),
    department_code    VARCHAR(2) NOT NULL REFERENCES mofnp_department(department_code),
    unit_code          VARCHAR(1) NOT NULL,
    unit_name          VARCHAR(200) NOT NULL,
    is_active          BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by         UUID,
    updated_at         TIMESTAMPTZ,
    updated_by         UUID,
    UNIQUE (authority_code, department_code, unit_code)
);

CREATE INDEX idx_mofnp_unit_authority ON mofnp_unit(authority_code);
CREATE INDEX idx_mofnp_unit_department ON mofnp_unit(authority_code, department_code);

COMMENT ON TABLE mofnp_unit IS
'MoFNP units within departments. Unit code is 1 character per manual. '
'Data seeded per council on onboarding.';

-- ---------------------------------------------------------------------
-- 3. MoFNP Function (COFOG)
-- ---------------------------------------------------------------------
CREATE TABLE mofnp_function (
    function_code      VARCHAR(2) PRIMARY KEY,
    function_name      VARCHAR(100) NOT NULL,
    description        TEXT,
    sort_order         INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE mofnp_function IS
'COFOG functional classification from MoFNP manual Section 10.2. '
'Identifies the socio-economic objective of government spending.';

INSERT INTO mofnp_function (function_code, function_name, sort_order) VALUES
    ('01', 'General Public Services',                    1),
    ('02', 'Defence',                                    2),
    ('03', 'Public Order and Safety',                    3),
    ('04', 'Economic Affairs',                           4),
    ('05', 'Environmental Protection',                   5),
    ('06', 'Housing and Community Amenities',            6),
    ('07', 'Health',                                     7),
    ('08', 'Recreation, Culture, and Religion',          8),
    ('09', 'Education',                                  9),
    ('10', 'Social Protection',                          10)
ON CONFLICT (function_code) DO NOTHING;

-- ---------------------------------------------------------------------
-- 4. MoFNP Programme Registry
-- ---------------------------------------------------------------------
CREATE TABLE mofnp_programme (
    programme_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code         VARCHAR(50) NOT NULL REFERENCES authorities(authority_code),
    department_code        VARCHAR(2) NOT NULL REFERENCES mofnp_department(department_code),
    unit_code              VARCHAR(1) NOT NULL,
    programme_code         VARCHAR(2) NOT NULL,
    programme_name         VARCHAR(200) NOT NULL,
    sub_programme_code     VARCHAR(4) NOT NULL,
    sub_programme_name     VARCHAR(200) NOT NULL,
    mofnp_function         VARCHAR(2) REFERENCES mofnp_function(function_code),
    output_description     TEXT,
    is_active              BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from         DATE NOT NULL DEFAULT CURRENT_DATE,
    effective_to           DATE,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by             UUID,
    updated_at             TIMESTAMPTZ,
    updated_by             UUID,
    UNIQUE (authority_code, department_code, unit_code,
            programme_code, sub_programme_code, effective_from)
);

CREATE INDEX idx_mofnp_programme_authority
    ON mofnp_programme(authority_code);
CREATE INDEX idx_mofnp_programme_dept
    ON mofnp_programme(authority_code, department_code);
CREATE INDEX idx_mofnp_programme_active
    ON mofnp_programme(authority_code) WHERE is_active = TRUE;

COMMENT ON TABLE mofnp_programme IS
'MoFNP programme registry per council. Each row is a unique '
'(dept, unit, programme, sub-programme) combination.';

-- ---------------------------------------------------------------------
-- 5. MoFNP Commitment Type
-- ---------------------------------------------------------------------
CREATE TABLE mofnp_commitment_type (
    commitment_type_code VARCHAR(3) PRIMARY KEY,
    commitment_type_name VARCHAR(100) NOT NULL,
    description          TEXT,
    sort_order           INTEGER NOT NULL DEFAULT 0,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE mofnp_commitment_type IS
'MoFNP commitment type codes (Section 14.4).';

INSERT INTO mofnp_commitment_type (commitment_type_code, commitment_type_name, description, sort_order) VALUES
    ('001', 'Commitment',      'An obligation incurred (order placed, contract signed)', 1),
    ('002', 'Payment',          'Payment made against a commitment',                      2),
    ('003', 'Adjustment',       'Journal adjustment or correction',                        3),
    ('004', 'Reversal',         'Reversal of a previous commitment or payment',            4),
    ('099', 'Other',            'Other transaction type',                                  99)
ON CONFLICT (commitment_type_code) DO NOTHING;

-- ---------------------------------------------------------------------
-- 6. Extend authorities with MoFNP head codes
-- ---------------------------------------------------------------------
ALTER TABLE authorities
    ADD COLUMN IF NOT EXISTS mofnp_province_code VARCHAR(2),
    ADD COLUMN IF NOT EXISTS mofnp_head_code     VARCHAR(4),
    ADD COLUMN IF NOT EXISTS mofnp_full_head     VARCHAR(6);

CREATE INDEX IF NOT EXISTS idx_authorities_mofnp_head
    ON authorities(mofnp_full_head) WHERE mofnp_full_head IS NOT NULL;

COMMENT ON COLUMN authorities.mofnp_province_code IS
'MoFNP province code (2 digits) from manual Section 10.3.';
COMMENT ON COLUMN authorities.mofnp_head_code IS
'MoFNP council head code (4 digits) from manual Section 10.3.';
COMMENT ON COLUMN authorities.mofnp_full_head IS
'Composed MoFNP head code: province_code || head_code (6 digits).';

-- ---------------------------------------------------------------------
-- 7. Populate MoFNP province codes (all 10 provinces)
-- ---------------------------------------------------------------------
UPDATE authorities a SET mofnp_province_code = m.mofnp_code
FROM (VALUES
    ('01', '94'),
    ('02', '92'),
    ('03', '95'),
    ('04', '96'),
    ('05', '93'),
    ('06', '97'),
    ('07', '98'),
    ('08', '91'),
    ('09', '90'),
    ('10', '88')
) AS m(iso_code, mofnp_code)
WHERE a.province_code = m.iso_code;

-- ---------------------------------------------------------------------
-- 8. Populate MoFNP council head codes (from Section 10.3)
-- ---------------------------------------------------------------------
UPDATE authorities SET mofnp_head_code = m.head_code
FROM (VALUES
    -- Lusaka Province (90)
    ('CHILANGA',    '9001'),
    ('CHIRUNDU',    '9002'),
    ('CHONGWE',     '9003'),
    ('KAFUE',       '9004'),
    ('LUANGWA',     '9005'),
    ('LUSAKA_CITY', '9006'),
    ('SHIBUYUNJI',  '9008'),
    -- Central Province (92)
    ('CHIBOMBO',    '9201'),
    ('CHISAMBA',    '9202'),
    ('CHITAMBO',    '9203'),
    ('KABWE',       '9205'),
    ('KAPIRI_MPOSHI','9206'),
    ('LUANO',       '9207'),
    ('MKUSHI',      '9208'),
    ('MUMBWA',      '9209'),
    ('SERENJE',     '9210'),
    ('NGABWE',      '9211'),
    -- Copperbelt Province (91)
    ('CHILILABOMBWE','9101'),
    ('CHINGOLA',    '9102'),
    ('KALULUSHI',   '9103'),
    ('KITWE',       '9104'),
    ('LUANSHYA',    '9105'),
    ('LUFWANYAMA',  '9106'),
    ('MASAITI',     '9107'),
    ('MPONGWE',     '9108'),
    ('MUFULIRA',    '9109'),
    ('NDOLA',       '9110'),
    -- Eastern Province (95)
    ('CHADIZA',     '9501'),
    ('CHASEFU',     '9515'),
    ('CHIPANGALI',  '9514'),
    ('KATETE',      '9504'),
    ('LUMEZI',      '9512'),
    ('LUNDAZI',     '9505'),
    ('MAMBWE',      '9506'),
    ('NYIMBA',      '9507'),
    ('PETAUKE',     '9508'),
    ('SINDA',       '9511'),
    -- Luapula Province (96)
    ('CHEMBE',      '9601'),
    ('CHIFUNABULI', '9612'),
    ('CHIPILI',     '9602'),
    ('KAWAMBWA',    '9604'),
    ('LUNGA',       '9605'),
    ('MANSA',       '9606'),
    ('MILENGE',     '9607'),
    ('MWANSABOMBWE','9608'),
    ('MWENSE',      '9609'),
    ('NCHELENGE',   '9610'),
    ('SAMFYA',      '9611'),
    -- Northern Province (93)
    ('CHILUBI',     '9301'),
    ('KASAMA',      '9303'),
    ('LUWINGU',     '9304'),
    ('MBALA',       '9305'),
    ('MPOROKOSO',   '9306'),
    ('MUNGWI',      '9308'),
    ('NSAMA',       '9309'),
    ('MPULUNGU',    '9311'),
    ('SENGA_HILL',  '9312'),
    ('LUNTE',       '9313'),
    ('LUPOSOSHI',   '9314'),
    -- North-Western Province (97)
    ('CHAVUMA',     '9701'),
    ('IKELENGE',    '9702'),
    ('KABOMPO',     '9703'),
    ('KASEMPA',     '9704'),
    ('MANYINGA',    '9705'),
    ('MUFUMBWE',    '9706'),
    ('MWINILUNGA',  '9707'),
    ('SOLWEZI',     '9708'),
    ('ZAMBEZI',     '9709'),
    ('KALUMBILA',   '9711'),
    ('MUSHINDAMO',  '9712'),
    -- Southern Province (98)
    ('CHIKANKATA',  '9801'),
    ('CHOMA',       '9802'),
    ('GWEMBE',      '9803'),
    ('KALOMO',      '9804'),
    ('KAZUNGULA',   '9805'),
    ('LIVINGSTONE', '9806'),
    ('MAZABUKA',    '9807'),
    ('MONZE',       '9808'),
    ('NAMWALA',     '9809'),
    ('SIAVONGA',    '9810'),
    ('SINAZONGWE',  '9812'),
    ('ZIMBA',       '9814'),
    -- Western Province (94)
    ('KALABO',      '9401'),
    ('KAOMA',       '9402'),
    ('LIMULUNGA',   '9403'),
    ('LUAMPA',      '9404'),
    ('LUKULU',      '9405'),
    ('MITETE',      '9406'),
    ('MONGU',       '9407'),
    ('MWANDI',      '9409'),
    ('NALOLO',      '9410'),
    ('NKEYEMA',     '9411'),
    ('SENANGA',     '9412'),
    ('SESHEKE',     '9413'),
    ('SHANGOMBO',   '9414'),
    ('SIKONGO',     '9415'),
    -- Muchinga Province (88)
    ('CHAMA',       '8801'),
    ('CHINSALI',    '8802'),
    ('ISOKA',       '8803'),
    ('MPIKA',       '8805'),
    ('NAKONDE',     '8806'),
    ('SHIWANGANDU', '8808'),
    ('KANCHIBIYA',  '8810'),
    ('LAVUSHIMANDA','8820'),
    ('MAFINGA',     '8811')
) AS m(authority_code, head_code)
WHERE authorities.authority_code = m.authority_code;

-- ---------------------------------------------------------------------
-- 9. Compose the full head code
-- ---------------------------------------------------------------------
UPDATE authorities
SET mofnp_full_head = mofnp_province_code || mofnp_head_code
WHERE mofnp_province_code IS NOT NULL
  AND mofnp_head_code IS NOT NULL;

-- ---------------------------------------------------------------------
-- 10. Verify
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_total INTEGER;
    v_mapped INTEGER;
    v_depts INTEGER;
    v_funcs INTEGER;
    v_comm_types INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM authorities;
    SELECT COUNT(*) INTO v_mapped FROM authorities WHERE mofnp_full_head IS NOT NULL;
    SELECT COUNT(*) INTO v_depts FROM mofnp_department;
    SELECT COUNT(*) INTO v_funcs FROM mofnp_function;
    SELECT COUNT(*) INTO v_comm_types FROM mofnp_commitment_type;

    RAISE NOTICE 'MoFNP reference tables created:';
    RAISE NOTICE '  authorities: % total, % with MoFNP head codes (%%)',
        v_total, v_mapped, ROUND((v_mapped::NUMERIC / NULLIF(v_total, 0)) * 100, 1);
    RAISE NOTICE '  mofnp_department: % rows', v_depts;
    RAISE NOTICE '  mofnp_function: % rows', v_funcs;
    RAISE NOTICE '  mofnp_commitment_type: % rows', v_comm_types;
END $$;

-- ---------------------------------------------------------------------
-- 11. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'PLATFORM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_mofnp_reference_tables',
        'migration', 'V103',
        'compliance', 'MoFNP Local Government Accounting Manual (Dec 2023), Sections 10.2, 10.3, 10.12',
        'tables_created', ARRAY[
            'mofnp_department',
            'mofnp_unit',
            'mofnp_function',
            'mofnp_programme',
            'mofnp_commitment_type'
        ],
        'columns_added', jsonb_build_object(
            'authorities', ARRAY['mofnp_province_code', 'mofnp_head_code', 'mofnp_full_head']
        ),
        'departments_deferred', ARRAY['Legal', 'Valuation'],
        'seeded', jsonb_build_object(
            'departments', 9,
            'functions', 10,
            'commitment_types', 5
        )
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
