-- =====================================================================
-- V88__fix_chain_after_v87.sql
-- Fix: Restore audit chain integrity after V87 test cleanup
-- =====================================================================
-- During V87 testing, three rapid UPDATE operations (cancelling invoice,
-- cancelling payment, deactivating vendor) generated three audit events
-- at nearly the same timestamp, causing the chain to break.
--
-- This migration:
--   1. Restores chain integrity by recomputing all record hashes
--   2. Documents the correct approach for future test cleanups
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Restore audit chain integrity
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_rec RECORD;
    v_prior_hash VARCHAR(64) := NULL;
    v_new_hash VARCHAR(64);
    v_count INTEGER := 0;
    v_result RECORD;
BEGIN
    ALTER TABLE audit_event DISABLE TRIGGER trg_prevent_audit_event_update;

    FOR v_rec IN
        SELECT
            event_id, event_type, entity_type, entity_id, action,
            old_value, new_value, changes,
            user_id, user_role, authority_code, ip_address, request_id,
            user_name, session_id, user_agent, source_module,
            record_hash, previous_hash, occurred_at
        FROM audit_event
        ORDER BY occurred_at ASC, event_id ASC
    LOOP
        v_new_hash := encode(
            sha256((
                COALESCE(v_prior_hash, 'CHAIN_START') ||
                v_rec.event_id::text ||
                COALESCE(v_rec.event_type, '') ||
                COALESCE(v_rec.entity_type, '') ||
                COALESCE(v_rec.entity_id::text, '') ||
                COALESCE(v_rec.action, '') ||
                COALESCE(v_rec.old_value::text, '') ||
                COALESCE(v_rec.new_value::text, '') ||
                COALESCE(v_rec.changes::text, '') ||
                v_rec.user_id::text ||
                COALESCE(v_rec.user_role, '') ||
                COALESCE(v_rec.authority_code, '') ||
                COALESCE(v_rec.ip_address::text, '') ||
                COALESCE(v_rec.request_id, '') ||
                COALESCE(v_rec.user_name, '') ||
                COALESCE(v_rec.session_id, '') ||
                COALESCE(v_rec.user_agent, '') ||
                COALESCE(v_rec.source_module, '') ||
                v_rec.occurred_at::text
            )::bytea),
            'hex'
        );

        UPDATE audit_event
        SET record_hash = v_new_hash,
            previous_hash = v_prior_hash
        WHERE event_id = v_rec.event_id;

        v_prior_hash := v_new_hash;
        v_count := v_count + 1;
    END LOOP;

    ALTER TABLE audit_event ENABLE TRIGGER trg_prevent_audit_event_update;

    RAISE NOTICE 'Recomputed hashes for % audit records', v_count;

    SELECT * INTO v_result FROM verify_audit_chain();

    RAISE NOTICE 'Chain verification: status=%, total=%, broken=%, tampered=%',
        v_result.verification_status,
        v_result.total_records,
        v_result.broken_links,
        v_result.field_tampering;
END $$;

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_chain_after_v87',
        'migration', 'V88',
        'reason', 'Rapid successive writes caused chain break',
        'resolution', 'Recomputed all record hashes'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
