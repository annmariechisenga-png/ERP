-- =====================================================================
-- V66__rebuild_log_audit_event.sql
-- Rebuild log_audit_event() to write to the audit_event table
-- =====================================================================
-- The previous version of log_audit_event wrote to
-- compliance_rule_change_log (a temporary destination). This rebuild
-- points it at the canonical audit_event table with full hash chaining.
--
-- Improvements over the previous version:
--   1. Writes to audit_event (the immutable table)
--   2. Computes record_hash from ALL fields (including context)
--   3. Chains to previous_hash for tamper detection
--   4. Captures user_name, session_id, user_agent, request_id
--   5. Supports a changes JSONB field (diff of changed values)
--   6. Fully backward compatible signature
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
    p_request_id VARCHAR DEFAULT NULL,
    p_changes JSONB DEFAULT NULL,
    p_user_name VARCHAR DEFAULT NULL,
    p_session_id VARCHAR DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_source_module VARCHAR DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_event_id UUID;
    v_previous_hash VARCHAR(64);
    v_record_hash VARCHAR(64);
    v_occurred_at TIMESTAMPTZ := NOW();
    v_user_id UUID := COALESCE(p_user_id, '00000000-0000-0000-0000-000000000001'::UUID);
BEGIN
    -- Get the most recent record's hash (for chaining)
    SELECT record_hash INTO v_previous_hash
    FROM audit_event
    ORDER BY occurred_at DESC, event_id DESC
    LIMIT 1;

    -- Generate event ID
    v_event_id := gen_random_uuid();

    -- Compute the record hash from ALL fields (deterministic order)
    v_record_hash := encode(
        sha256((
            COALESCE(v_previous_hash, 'CHAIN_START') ||
            v_event_id::text ||
            COALESCE(p_event_type, '') ||
            COALESCE(p_entity_type, '') ||
            COALESCE(p_entity_id::text, '') ||
            COALESCE(p_action, '') ||
            COALESCE(p_old_value::text, '') ||
            COALESCE(p_new_value::text, '') ||
            COALESCE(p_changes::text, '') ||
            v_user_id::text ||
            COALESCE(p_user_role, '') ||
            COALESCE(p_authority_code, '') ||
            COALESCE(p_ip_address::text, '') ||
            COALESCE(p_request_id, '') ||
            COALESCE(p_user_name, '') ||
            COALESCE(p_session_id, '') ||
            COALESCE(p_user_agent, '') ||
            COALESCE(p_source_module, '') ||
            v_occurred_at::text
        )::bytea),
        'hex'
    );

    -- Insert the audit record
    INSERT INTO audit_event (
        event_id, event_type, entity_type, entity_id, action,
        old_value, new_value, changes,
        user_id, user_name, user_role, session_id,
        authority_code, ip_address, user_agent, request_id,
        source_module, record_hash, previous_hash, occurred_at
    ) VALUES (
        v_event_id,
        COALESCE(p_event_type, 'OTHER'),
        COALESCE(p_entity_type, 'GENERAL'),
        p_entity_id,
        COALESCE(p_action, 'OTHER'),
        p_old_value,
        p_new_value,
        p_changes,
        v_user_id,
        p_user_name,
        p_user_role,
        p_session_id,
        p_authority_code,
        p_ip_address,
        p_user_agent,
        p_request_id,
        p_source_module,
        v_record_hash,
        v_previous_hash,
        v_occurred_at
    );

    RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION log_audit_event IS
'Central audit logging function. Writes to audit_event (immutable, '
'hash-chained). Every write operation, state change, and sensitive '
'read calls this function. Returns the event_id for reference. '
'Rebuilt in V66 to write to audit_event with full context capture.';

-- ---------------------------------------------------------------------
-- Helper: log_audit_login — Convenience for LOGIN events
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_audit_login(
    p_user_id UUID,
    p_user_name VARCHAR,
    p_user_role VARCHAR,
    p_authority_code VARCHAR DEFAULT NULL,
    p_ip_address INET DEFAULT NULL,
    p_user_agent TEXT DEFAULT NULL,
    p_session_id VARCHAR DEFAULT NULL,
    p_success BOOLEAN DEFAULT TRUE
) RETURNS UUID
LANGUAGE plpgsql AS $$
BEGIN
    RETURN log_audit_event(
        p_event_type := CASE WHEN p_success THEN 'LOGIN' ELSE 'LOGIN' END,
        p_entity_type := 'USER_SESSION',
        p_entity_id := p_user_id,
        p_action := 'LOGIN',
        p_old_value := NULL,
        p_new_value := jsonb_build_object(
            'success', p_success,
            'user_name', p_user_name,
            'user_role', p_user_role
        ),
        p_user_id := p_user_id,
        p_user_role := p_user_role,
        p_authority_code := p_authority_code,
        p_ip_address := p_ip_address,
        p_user_name := p_user_name,
        p_session_id := p_session_id,
        p_user_agent := p_user_agent,
        p_source_module := 'AUTH'
    );
END;
$$;

COMMENT ON FUNCTION log_audit_login IS
'Convenience function for logging LOGIN events. Captures success/failure, '
'user context, IP, and session.';

-- ---------------------------------------------------------------------
-- Helper: log_audit_logout — Convenience for LOGOUT events
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_audit_logout(
    p_user_id UUID,
    p_session_id VARCHAR DEFAULT NULL,
    p_authority_code VARCHAR DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql AS $$
BEGIN
    RETURN log_audit_event(
        p_event_type := 'LOGOUT',
        p_entity_type := 'USER_SESSION',
        p_entity_id := p_user_id,
        p_action := 'LOGOUT',
        p_user_id := p_user_id,
        p_authority_code := p_authority_code,
        p_session_id := p_session_id,
        p_source_module := 'AUTH'
    );
END;
$$;

COMMENT ON FUNCTION log_audit_logout IS
'Convenience function for logging LOGOUT events.';

-- ---------------------------------------------------------------------
-- Helper: log_audit_read — Convenience for sensitive READ events
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_audit_read(
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_user_id UUID,
    p_user_role VARCHAR DEFAULT NULL,
    p_authority_code VARCHAR DEFAULT NULL,
    p_ip_address INET DEFAULT NULL,
    p_source_module VARCHAR DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql AS $$
BEGIN
    RETURN log_audit_event(
        p_event_type := 'READ',
        p_entity_type := p_entity_type,
        p_entity_id := p_entity_id,
        p_action := 'READ',
        p_user_id := p_user_id,
        p_user_role := p_user_role,
        p_authority_code := p_authority_code,
        p_ip_address := p_ip_address,
        p_source_module := p_source_module
    );
END;
$$;

COMMENT ON FUNCTION log_audit_read IS
'Convenience function for logging sensitive READ events '
'(employee salaries, personal data, financial records).';

-- ---------------------------------------------------------------------
-- Helper: log_audit_export — Convenience for EXPORT events
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_audit_export(
    p_entity_type VARCHAR,
    p_user_id UUID,
    p_export_details JSONB,
    p_user_role VARCHAR DEFAULT NULL,
    p_authority_code VARCHAR DEFAULT NULL,
    p_ip_address INET DEFAULT NULL,
    p_source_module VARCHAR DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql AS $$
BEGIN
    RETURN log_audit_event(
        p_event_type := 'EXPORT',
        p_entity_type := p_entity_type,
        p_entity_id := NULL,
        p_action := 'EXPORT',
        p_new_value := p_export_details,
        p_user_id := p_user_id,
        p_user_role := p_user_role,
        p_authority_code := p_authority_code,
        p_ip_address := p_ip_address,
        p_source_module := p_source_module
    );
END;
$$;

COMMENT ON FUNCTION log_audit_export IS
'Convenience function for logging EXPORT events (payslips, financial '
'reports, audit reports). Captures export details as JSONB.';

-- ---------------------------------------------------------------------
-- Log the migration itself
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'rebuild_function',
        'function', 'log_audit_event',
        'migration', 'V66',
        'purpose', 'Rebuild to write to audit_event with hash chaining',
        'helper_functions', ARRAY[
            'log_audit_login',
            'log_audit_logout',
            'log_audit_read',
            'log_audit_export'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
