-- =====================================================================
-- V63__create_audit_function.sql
-- Central Audit Logging Function
-- =====================================================================
-- Every write operation in the system calls log_audit_event.
-- This provides a unified audit trail for the AGO.
--
-- Design:
--   1. Uses compliance_rule_change_log as the destination table
--   2. Computes hash chaining for tamper detection
--   3. Handles NULLs gracefully
--   4. Returns event ID for reference
--
-- Future: A dedicated audit_event table can be added in a later
-- migration. This function will be re-pointed to it without changing
-- the calling signature.
-- =====================================================================

CREATE OR REPLACE FUNCTION log_audit_event(
    p_event_type VARCHAR DEFAULT 'TRANSACTION',
    p_entity_type VARCHAR DEFAULT 'GENERAL',
    p_entity_id UUID DEFAULT NULL,
    p_action VARCHAR DEFAULT 'CREATE',
    p_old_value JSONB DEFAULT NULL,
    p_new_value JSONB DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_user_role VARCHAR DEFAULT NULL,
    p_authority_code VARCHAR DEFAULT NULL,
    p_ip_address INET DEFAULT NULL,
    p_request_id VARCHAR DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_change_id UUID;
    v_previous_hash VARCHAR(64);
    v_record_hash VARCHAR(64);
    v_new_value JSONB;
BEGIN
    -- Get the most recent record's hash (for chaining)
    SELECT record_hash INTO v_previous_hash
    FROM compliance_rule_change_log
    ORDER BY changed_at DESC, change_id DESC
    LIMIT 1;

    -- Build the new value JSONB combining all event details
    v_new_value := jsonb_build_object(
        'event_type', COALESCE(p_event_type, 'UNKNOWN'),
        'entity_type', COALESCE(p_entity_type, 'UNKNOWN'),
        'entity_id', p_entity_id,
        'action', COALESCE(p_action, 'CREATE'),
        'old_value', p_old_value,
        'new_value', p_new_value,
        'user_id', p_user_id,
        'user_role', p_user_role,
        'authority_code', p_authority_code,
        'ip_address', p_ip_address,
        'request_id', p_request_id
    );

    -- Compute record hash (chains to previous)
    v_record_hash := encode(
        sha256((
            COALESCE(v_previous_hash, '') ||
            COALESCE(p_event_type, '') ||
            COALESCE(p_entity_type, '') ||
            COALESCE(p_entity_id::text, '') ||
            COALESCE(p_action, '') ||
            COALESCE(p_old_value::text, '') ||
            COALESCE(p_new_value::text, '') ||
            COALESCE(p_user_id::text, '') ||
            NOW()::text
        )::bytea),
        'hex'
    );

    -- Insert the audit record
    INSERT INTO compliance_rule_change_log (
        entity_type, entity_id, change_type, old_value, new_value,
        change_reason, changed_by, changed_at, record_hash
    ) VALUES (
        COALESCE(p_entity_type, 'UNKNOWN'),
        COALESCE(p_entity_id, gen_random_uuid()),
        COALESCE(p_action, 'CREATE'),
        p_old_value,
        v_new_value,
        COALESCE(p_event_type || ' — ' || p_action,
                 'Audit event'),
        COALESCE(p_user_id, '00000000-0000-0000-0000-000000000001'::UUID),
        NOW(),
        v_record_hash
    )
    RETURNING change_id INTO v_change_id;

    RETURN v_change_id;
END;
$$;

COMMENT ON FUNCTION log_audit_event IS
'Central audit logging function. Every write operation calls this. '
'Computes hash-chained record hash for tamper detection. '
'Currently writes to compliance_rule_change_log. '
'Will be re-pointed to a dedicated audit_event table in a future migration.';

-- ---------------------------------------------------------------------
-- AUDIT LOG — Record function creation
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason,
     changed_by, record_hash)
VALUES (
    'SYSTEM',
    gen_random_uuid(),
    'CREATE',
    jsonb_build_object(
        'function', 'log_audit_event',
        'migration', 'V63',
        'purpose', 'Central audit logging for all write operations'
    ),
    'Central audit function — chains hash to previous audit record',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256(('V63' || 'log_audit_event' || NOW()::text)::bytea), 'hex')
);
