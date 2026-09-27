-- =====================================================================
-- V101__registry_hardening.sql
-- Layer 1 — National Registry: Hardening and cleanup
-- =====================================================================
--   1. Attach audit trigger to authorities (every registry change audited)
--   2. Attach audit trigger to provinces
--   3. Attach audit trigger to council_types
--   4. Attach audit trigger to id_sequence (registry counter changes)
--   5. Add hardship update helper function
--   6. Drop the two stub tables: authority_codes, councils
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Audit trigger on authorities
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_authorities ON authorities;
CREATE TRIGGER trg_audit_authorities
    AFTER INSERT OR UPDATE OR DELETE ON authorities
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 2. Audit trigger on provinces
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_provinces ON provinces;
CREATE TRIGGER trg_audit_provinces
    AFTER INSERT OR UPDATE OR DELETE ON provinces
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 3. Audit trigger on council_types
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_council_types ON council_types;
CREATE TRIGGER trg_audit_council_types
    AFTER INSERT OR UPDATE OR DELETE ON council_types
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 4. Audit trigger on id_sequence
-- ---------------------------------------------------------------------
-- Note: id_sequence changes on every ID generation. Auditing this will
-- generate high volume. But it's important for traceability — if an ID
-- was issued, we can prove it. The audit trail becomes the ledger of
-- every auto-generated identifier.
DROP TRIGGER IF EXISTS trg_audit_id_sequence ON id_sequence;
CREATE TRIGGER trg_audit_id_sequence
    AFTER INSERT OR UPDATE OR DELETE ON id_sequence
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 5. Helper function: set hardship classification with audit trail
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_hardship_classification(
    p_authority_code      VARCHAR,
    p_classification      VARCHAR,
    p_source              TEXT,
    p_user_id             UUID
) RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE
    v_pct NUMERIC(5,2);
BEGIN
    IF p_classification IS NULL THEN
        v_pct := NULL;
    ELSIF p_classification = 'NONE' THEN
        v_pct := 0;
    ELSIF p_classification = 'RURAL' THEN
        v_pct := 20;
    ELSIF p_classification = 'REMOTE' THEN
        v_pct := 25;
    ELSE
        RAISE EXCEPTION 'Invalid hardship classification: %. Must be NONE, RURAL, REMOTE, or NULL.',
            p_classification;
    END IF;

    UPDATE authorities
    SET hardship_classification = p_classification,
        hardship_allowance_pct  = v_pct,
        hardship_updated_at     = NOW(),
        hardship_updated_by     = p_user_id,
        hardship_source         = p_source,
        updated_at              = NOW(),
        updated_by              = p_user_id
    WHERE authority_code = p_authority_code;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown authority_code: %', p_authority_code;
    END IF;
END;
$$;

COMMENT ON FUNCTION set_hardship_classification IS
'Updates the hardship classification for a council. Audited via the '
'auto-audit trigger on authorities. Use this instead of raw UPDATE so '
'the classification, percentage, source, and updater are all recorded '
'consistently.

Example:
  SELECT set_hardship_classification(
      p_authority_code := ''CHISAMBA'',
      p_classification := ''RURAL'',
      p_source := ''Ministry Circular No. X of 2026'',
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- 6. Drop stub tables (empty, superseded by authorities)
-- ---------------------------------------------------------------------
-- authority_codes: 0 rows, 2 columns (authority_name, authority_code)
-- councils:        0 rows, 3 columns (council_id, council_name, top_authority)
-- Both are stubs from earlier design iterations. The authoritative
-- registry is `authorities`.
DROP TABLE IF EXISTS authority_codes;
DROP TABLE IF EXISTS councils;

-- ---------------------------------------------------------------------
-- 7. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'PLATFORM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'registry_hardening',
        'migration', 'V101',
        'triggers_added', ARRAY[
            'trg_audit_authorities',
            'trg_audit_provinces',
            'trg_audit_council_types',
            'trg_audit_id_sequence'
        ],
        'functions_added', ARRAY['set_hardship_classification'],
        'tables_dropped', ARRAY['authority_codes', 'councils']
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
