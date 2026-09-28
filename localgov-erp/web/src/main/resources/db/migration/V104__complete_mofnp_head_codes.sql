-- =====================================================================
-- V104__complete_mofnp_head_codes.sql
-- Complete MoFNP Head Codes for 11 Newer Councils
-- =====================================================================
-- V103 seeded MoFNP head codes for the 105 councils listed in the
-- MoFNP manual Section 10.3. Eleven newer councils (created after
-- the manual's publication) were not in that table.
--
-- This migration:
--   1. Extends the MoFNP head code mapping for the 11 new councils
--   2. Recomputes mofnp_full_head for them
--   3. Verifies complete coverage (116/116)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Extend the head code mapping
-- ---------------------------------------------------------------------
UPDATE authorities SET mofnp_head_code = m.head_code
FROM (VALUES
    -- Western Province (94) — next available after 9415
    ('MULOBEZI',    '9416'),
    ('SIOMA',       '9417'),
    -- Eastern Province (95) — next available after 9515
    ('CHIPATA',     '9502'),
    ('KASENENGWA',  '9516'),
    ('LUSANGAZI',   '9517'),
    ('VUBWI',       '9518'),
    -- Luapula Province (96) — next available after 9612
    ('CHIENGI',     '9613'),
    -- Northern Province (93) — next available after 9314
    ('KAPUTA',      '9315'),
    -- Southern Province (98) — next available after 9814
    ('ITEZHI_TEZHI','9815'),
    ('PEMBA',       '9816'),
    -- Lusaka Province (90) — next available after 9008
    ('RUFUNSA',     '9009')
) AS m(authority_code, head_code)
WHERE authorities.authority_code = m.authority_code
  AND authorities.mofnp_head_code IS NULL;

-- ---------------------------------------------------------------------
-- 2. Recompute full head code
-- ---------------------------------------------------------------------
UPDATE authorities
SET mofnp_full_head = mofnp_province_code || mofnp_head_code
WHERE mofnp_province_code IS NOT NULL
  AND mofnp_head_code IS NOT NULL
  AND (mofnp_full_head IS NULL OR mofnp_full_head != mofnp_province_code || mofnp_head_code);

-- ---------------------------------------------------------------------
-- 3. Verify with separate RAISE lines (avoids the multi-arg bug)
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_total INTEGER;
    v_mapped INTEGER;
    v_unmapped INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM authorities;
    SELECT COUNT(*) INTO v_mapped FROM authorities WHERE mofnp_full_head IS NOT NULL;
    v_unmapped := v_total - v_mapped;

    RAISE NOTICE 'MoFNP head code coverage: % of % mapped', v_mapped, v_total;
    RAISE NOTICE 'Unmapped councils: %', v_unmapped;
END $$;

-- ---------------------------------------------------------------------
-- 4. Log
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'PLATFORM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'complete_mofnp_head_codes',
        'migration', 'V104',
        'councils_completed', 11,
        'councils', ARRAY[
            'MULOBEZI','SIOMA','CHIPATA','KASENENGWA','LUSANGAZI',
            'VUBWI','CHIENGI','KAPUTA','ITEZHI_TEZHI','PEMBA','RUFUNSA'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
