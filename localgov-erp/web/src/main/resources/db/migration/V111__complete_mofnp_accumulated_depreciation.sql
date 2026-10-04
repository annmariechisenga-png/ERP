-- ============================================================================
-- V111: Complete MoFNP Accumulated Depreciation Codes
-- ----------------------------------------------------------------------------
-- The MoFNP Local Government Accounting and Financial Procedures Manual
-- (Dec 2023), Table 9 (pages 67-70), defines accumulated depreciation codes
-- as sub-entries under each asset class.
--
-- During V105/V106 (initial MoFNP chart creation), the asset-side codes were
-- loaded but the accumulated depreciation sub-codes were omitted. This
-- migration completes the chart.
--
-- AMBIGUITIES IN THE MoFNP MANUAL
-- --------------------------------
-- The manual has three code collisions where the same code is used for both
-- an asset-side entry and an accumulated depreciation entry. These are
-- presumed to be editorial typos. Where collisions occur, the accumulated
-- depreciation codes are shifted by +1 to preserve uniqueness.
--
-- Collision 1: Office Equipment
--   Manual: 311309 "Other office Equipment" (asset)
--           311309 "Other Office Equipment" (accum-dep) ← duplicate
--   Resolution: Accum dep uses 311310 for "Other Office Equipment"
--
-- Collision 2: Defence Equipment
--   Manual: 311603 "Naval Equipment" (asset)
--           311603 "Land Equipment" (accum-dep) ← duplicate
--   Resolution: Accum dep range shifted to 311604-311606
--
-- Collision 3: Specialised Vehicles
--   Manual: 311898 "Other Specialised vehicles" (accum-dep) ← out of range
--   Resolution: Accum dep uses 311807 for "Other Specialised Vehicles"
--
-- Idempotent (ON CONFLICT DO NOTHING). Safe on fresh, partial, or complete DBs.
--
-- FUTURE REVIEW: MoFNP may issue errata clarifying these codes.
--
-- Depends on: V105 (mofnp_chart_of_accounts table), V106 (MoFNP seed data)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- OFFICE EQUIPMENT (parent 3113)
-- Asset-side: 311301, 311302, 311303, 311304, 311309
-- Accum-dep:  311305, 311306, 311307, 311308, 311310
-- ---------------------------------------------------------------------------
INSERT INTO mofnp_chart_of_accounts
    (account_code, account_name, account_type, mofnp_classification,
     parent_account_code, hierarchy_level, is_postable, is_national_template)
VALUES
    ('311305', 'Accumulated Depreciation — Computers, Peripherals, Equipment', 'ASSET', '3', '3113', 2, true, true),
    ('311306', 'Accumulated Depreciation — Communication Equipment',            'ASSET', '3', '3113', 2, true, true),
    ('311307', 'Accumulated Depreciation — Telephone, Fax, Telex, Radio',       'ASSET', '3', '3113', 2, true, true),
    ('311308', 'Accumulated Depreciation — Refrigerator, TV, VCR, Cameras',     'ASSET', '3', '3113', 2, true, true),
    ('311310', 'Accumulated Depreciation — Other Office Equipment',             'ASSET', '3', '3113', 2, true, true)
ON CONFLICT (account_code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- PRODUCED ASSETS (parent 3114)
-- Asset-side: 311401-311410
-- Accum-dep:  311411-311420
-- ---------------------------------------------------------------------------
INSERT INTO mofnp_chart_of_accounts
    (account_code, account_name, account_type, mofnp_classification,
     parent_account_code, hierarchy_level, is_postable, is_national_template)
VALUES
    ('311411', 'Accumulated Depreciation — Dams',                              'ASSET', '3', '3114', 2, true, true),
    ('311412', 'Accumulated Depreciation — Cultivated Assets',                 'ASSET', '3', '3114', 2, true, true),
    ('311413', 'Accumulated Depreciation — Forfeited Assets',                  'ASSET', '3', '3114', 2, true, true),
    ('311414', 'Accumulated Depreciation — State Highways',                    'ASSET', '3', '3114', 2, true, true),
    ('311415', 'Accumulated Depreciation — State Highway Bridges',             'ASSET', '3', '3114', 2, true, true),
    ('311416', 'Accumulated Depreciation — Full Road Regravelling',            'ASSET', '3', '3114', 2, true, true),
    ('311417', 'Accumulated Depreciation — Upgrading/Rehabilitation of Roads', 'ASSET', '3', '3114', 2, true, true),
    ('311418', 'Accumulated Depreciation — Boreholes',                         'ASSET', '3', '3114', 2, true, true),
    ('311419', 'Accumulated Depreciation — Railway',                           'ASSET', '3', '3114', 2, true, true),
    ('311420', 'Accumulated Depreciation — Electricity Connectivity',          'ASSET', '3', '3114', 2, true, true)
ON CONFLICT (account_code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- FURNITURE (parent 3115)
-- Asset-side: 311501-311504
-- Accum-dep:  311505-311508
-- ---------------------------------------------------------------------------
INSERT INTO mofnp_chart_of_accounts
    (account_code, account_name, account_type, mofnp_classification,
     parent_account_code, hierarchy_level, is_postable, is_national_template)
VALUES
    ('311505', 'Accumulated Depreciation — Office Furniture',       'ASSET', '3', '3115', 2, true, true),
    ('311506', 'Accumulated Depreciation — Residential Furniture',  'ASSET', '3', '3115', 2, true, true),
    ('311507', 'Accumulated Depreciation — School Furniture',       'ASSET', '3', '3115', 2, true, true),
    ('311508', 'Accumulated Depreciation — Hospital Furniture',     'ASSET', '3', '3115', 2, true, true)
ON CONFLICT (account_code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- DEFENCE EQUIPMENT (parent 3116)
-- Asset-side: 311601, 311602, 311603
-- Accum-dep:  311604, 311605, 311606  (shifted from manual's 311603-311605)
-- ---------------------------------------------------------------------------
INSERT INTO mofnp_chart_of_accounts
    (account_code, account_name, account_type, mofnp_classification,
     parent_account_code, hierarchy_level, is_postable, is_national_template)
VALUES
    ('311604', 'Accumulated Depreciation — Land Equipment',   'ASSET', '3', '3116', 2, true, true),
    ('311605', 'Accumulated Depreciation — Air Equipment',    'ASSET', '3', '3116', 2, true, true),
    ('311606', 'Accumulated Depreciation — Naval Equipment',  'ASSET', '3', '3116', 2, true, true)
ON CONFLICT (account_code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- VEHICLES AND MOTOR CYCLES (parent 3117)
-- Asset-side: 311701-311706
-- Accum-dep:  311707-311712
-- ---------------------------------------------------------------------------
INSERT INTO mofnp_chart_of_accounts
    (account_code, account_name, account_type, mofnp_classification,
     parent_account_code, hierarchy_level, is_postable, is_national_template)
VALUES
    ('311707', 'Accumulated Depreciation — Bicycles',                          'ASSET', '3', '3117', 2, true, true),
    ('311708', 'Accumulated Depreciation — Motor Cycles <= 125cc',             'ASSET', '3', '3117', 2, true, true),
    ('311709', 'Accumulated Depreciation — Motor Cycles > 125cc',              'ASSET', '3', '3117', 2, true, true),
    ('311710', 'Accumulated Depreciation — Motor Vehicles <= 3500kg',          'ASSET', '3', '3117', 2, true, true),
    ('311711', 'Accumulated Depreciation — Motor Vehicles > 3500kg <= 16000kg','ASSET', '3', '3117', 2, true, true),
    ('311712', 'Accumulated Depreciation — Heavy Duty Vehicles > 16000kg',     'ASSET', '3', '3117', 2, true, true)
ON CONFLICT (account_code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- SPECIALISED VEHICLES (parent 3118)
-- Asset-side: 311801, 311802, 311803
-- Accum-dep:  311804, 311805, 311806, 311807  (311807 replaces manual's 311898)
-- ---------------------------------------------------------------------------
INSERT INTO mofnp_chart_of_accounts
    (account_code, account_name, account_type, mofnp_classification,
     parent_account_code, hierarchy_level, is_postable, is_national_template)
VALUES
    ('311804', 'Accumulated Depreciation — Ambulances',                  'ASSET', '3', '3118', 2, true, true),
    ('311805', 'Accumulated Depreciation — Fire Engines',                'ASSET', '3', '3118', 2, true, true),
    ('311806', 'Accumulated Depreciation — Graders',                     'ASSET', '3', '3118', 2, true, true),
    ('311807', 'Accumulated Depreciation — Other Specialised Vehicles',  'ASSET', '3', '3118', 2, true, true)
ON CONFLICT (account_code) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Documentation of ambiguous decisions (for future MoFNP review)
-- ---------------------------------------------------------------------------
DO $$
BEGIN
    RAISE NOTICE 'V111: Accumulated depreciation codes loaded with documented decisions.';
    RAISE NOTICE 'V111: Collisions resolved:';
    RAISE NOTICE '  - Office Equipment accum-dep uses 311310 (not 311309)';
    RAISE NOTICE '  - Defence Equipment accum-dep uses 311604-311606 (not 311603-311605)';
    RAISE NOTICE '  - Specialised Vehicles accum-dep uses 311807 (not 311898)';
    RAISE NOTICE 'V111: MoFNP errata review recommended.';
END $$;

-- ---------------------------------------------------------------------------
-- Verification — all 32 accum-dep codes must exist
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    codes_present INTEGER;
    expected_codes TEXT[] := ARRAY[
        '311305','311306','311307','311308','311310',
        '311411','311412','311413','311414','311415',
        '311416','311417','311418','311419','311420',
        '311505','311506','311507','311508',
        '311604','311605','311606',
        '311707','311708','311709','311710','311711','311712',
        '311804','311805','311806','311807'
    ];
BEGIN
    SELECT COUNT(*) INTO codes_present
    FROM mofnp_chart_of_accounts
    WHERE account_code = ANY(expected_codes);

    IF codes_present < 32 THEN
        RAISE EXCEPTION 'V111 FAILED: Only % of 32 accum-dep codes present', codes_present;
    END IF;

    RAISE NOTICE 'V111 PASSED: All 32 accumulated depreciation codes present';
END $$;

-- ---------------------------------------------------------------------------
-- Update legacy 15900 mapping note
-- ---------------------------------------------------------------------------
UPDATE chart_of_accounts
SET mofnp_mapping_notes = 'Legacy consolidated accumulated depreciation. '
    || 'MoFNP class-specific accum-dep codes loaded in V111: '
    || '311305-311310 (Office Equip), 311411-311420 (Produced), '
    || '311505-311508 (Furniture), 311604-311606 (Defence), '
    || '311707-311712 (Vehicles), 311804-311807 (Specialised). '
    || 'No balance to split (15900 never posted). '
    || 'This account remains KEPT for historical reference only.'
WHERE account_code = '15900';
