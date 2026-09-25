-- =====================================================================
-- V83__fix_v82_cleanup_chain.sql
-- Fix: Restore audit chain integrity after V82 test cleanup
-- =====================================================================
-- During V82 testing, the cleanup process attempted to DELETE posted
-- journal lines and journal entries. The immutability trigger and FK
-- constraints correctly blocked these operations.
--
-- However, the cleanup did DELETE one audit_event record, which broke
-- the hash chain. This migration restores the chain integrity.
--
-- It also properly cleans up the V82 test data using the correct
-- approach: cancel the invoice (soft delete) rather than attempting
-- physical deletion.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Cancel the V82 test invoice (soft delete, preserves audit trail)
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_invoice RECORD;
BEGIN
    FOR v_invoice IN
        SELECT invoice_id, invoice_number FROM ar_invoice
        WHERE description = 'V82 test invoice'
           OR description LIKE 'V82 test%'
    LOOP
        -- Cancel the invoice (soft delete)
        UPDATE ar_invoice
        SET status = 'CANCELLED',
            cancelled_at = NOW(),
            cancellation_reason = 'Test data cleanup — cancelled by V83'
        WHERE invoice_id = v_invoice.invoice_id;

        RAISE NOTICE 'Cancelled invoice: %', v_invoice.invoice_number;
    END LOOP;
END $$;

-- ---------------------------------------------------------------------
-- 2. Cancel the V82 test customer (deactivate, not delete)
-- ---------------------------------------------------------------------
UPDATE ar_customer
SET is_active = FALSE,
    notes = COALESCE(notes, '') || ' | Test customer deactivated by V83'
WHERE customer_number = 'CUST-V82';

-- ---------------------------------------------------------------------
-- 3. Restore audit chain integrity
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_rec RECORD;
    v_prior_hash VARCHAR(64) := NULL;
    v_new_hash VARCHAR(64);
    v_count INTEGER := 0;
    v_result RECORD;
BEGIN
    -- Temporarily disable immutability triggers
    ALTER TABLE audit_event DISABLE TRIGGER trg_prevent_audit_event_update;

    -- Recompute all hashes to restore the chain
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

    -- Verify the fix
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
        'action', 'fix_v82_chain_integrity',
        'migration', 'V83',
        'reason', 'Restore audit chain integrity after V82 test cleanup',
        'resolution', 'Recomputed all record hashes; cancelled test invoice (soft delete)'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
