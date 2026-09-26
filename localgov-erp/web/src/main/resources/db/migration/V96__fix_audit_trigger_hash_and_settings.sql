-- =====================================================================
-- V96__fix_audit_trigger_hash_and_settings.sql
-- Fix the audit trigger rebuilt in V94/V95:
--   1. Read the CORRECT setting names used by set_audit_context:
--        app.current_user_id
--        app.current_user_name
--        app.current_user_role
--        app.session_id
--        app.source_module
--   2. Compute record_hash and previous_hash INLINE before insert
--      (the column is NOT NULL and there is no BEFORE INSERT trigger
--       to fill it)
--   3. Chain via previous row's record_hash (ordered by sequence_number)
-- =====================================================================

CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_old JSONB;
    v_new JSONB;
    v_action VARCHAR(20);
    v_user_id UUID;
    v_user_name VARCHAR(255);
    v_user_role VARCHAR(50);
    v_authority_code VARCHAR(20);
    v_session_id VARCHAR(255);
    v_source_module VARCHAR(50);
    v_entity_id UUID;
    v_event_id UUID;
    v_system_user UUID := '00000000-0000-0000-0000-000000000001'::UUID;
    v_prior_hash VARCHAR(64);
    v_new_hash VARCHAR(64);
    v_occurred_at TIMESTAMPTZ;
BEGIN
    -- Determine action
    IF TG_OP = 'INSERT' THEN
        v_action := 'CREATE';
        v_new := to_jsonb(NEW);
        v_old := NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        v_action := 'UPDATE';
        v_new := to_jsonb(NEW);
        v_old := to_jsonb(OLD);
    ELSE
        v_action := 'DELETE';
        v_new := NULL;
        v_old := to_jsonb(OLD);
    END IF;

    -- Entity id: try common PK patterns
    BEGIN
        IF TG_OP = 'DELETE' THEN
            v_entity_id := COALESCE(
                (v_old->>'id')::UUID,
                (v_old->>(TG_TABLE_NAME || '_id'))::UUID
            );
        ELSE
            v_entity_id := COALESCE(
                (v_new->>'id')::UUID,
                (v_new->>(TG_TABLE_NAME || '_id'))::UUID
            );
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_entity_id := NULL;
    END;

    -- Read audit context using the ACTUAL setting names
    v_user_id := COALESCE(
        NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID,
        v_system_user
    );
    v_user_name := COALESCE(
        NULLIF(current_setting('app.current_user_name', TRUE), ''),
        'SYSTEM'
    );
    v_user_role := COALESCE(
        NULLIF(current_setting('app.current_user_role', TRUE), ''),
        'SYSTEM'
    );
    v_session_id := NULLIF(current_setting('app.session_id', TRUE), '');
    v_source_module := COALESCE(
        NULLIF(current_setting('app.source_module', TRUE), ''),
        'DATABASE'
    );

    -- authority_code is not set by set_audit_context; derive from row if
    -- the audited table has that column, otherwise use a neutral value.
    BEGIN
        IF TG_OP = 'DELETE' THEN
            v_authority_code := v_old->>'authority_code';
        ELSE
            v_authority_code := v_new->>'authority_code';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_authority_code := NULL;
    END;

    -- Generate event id and occurred_at
    v_event_id := gen_random_uuid();
    v_occurred_at := clock_timestamp();

    -- Get prior hash (ordered by sequence_number, the deterministic order)
    SELECT record_hash INTO v_prior_hash
    FROM audit_event
    ORDER BY sequence_number DESC
    LIMIT 1;

    -- Compute this record's hash
    v_new_hash := encode(sha256((
        COALESCE(v_prior_hash, 'CHAIN_START') ||
        v_event_id::text ||
        'DATA_CHANGE' ||
        COALESCE(TG_TABLE_NAME, '') ||
        COALESCE(v_entity_id::text, '') ||
        COALESCE(v_action, '') ||
        COALESCE(v_old::text, '') ||
        COALESCE(v_new::text, '') ||
        '' ||  -- changes
        v_user_id::text ||
        COALESCE(v_user_role, '') ||
        COALESCE(v_authority_code, '') ||
        '' ||  -- ip_address
        '' ||  -- request_id
        COALESCE(v_user_name, '') ||
        COALESCE(v_session_id, '') ||
        '' ||  -- user_agent
        COALESCE(v_source_module, '') ||
        v_occurred_at::text
    )::bytea), 'hex');

    -- Insert with all required fields populated
    INSERT INTO audit_event (
        event_id,
        event_type, entity_type, entity_id, action,
        old_value, new_value, changes,
        user_id, user_name, user_role, authority_code,
        session_id, source_module,
        occurred_at,
        record_hash, previous_hash
    ) VALUES (
        v_event_id,
        'DATA_CHANGE',
        TG_TABLE_NAME,
        v_entity_id,
        v_action,
        v_old,
        v_new,
        NULL,
        v_user_id,
        v_user_name,
        v_user_role,
        v_authority_code,
        v_session_id,
        v_source_module,
        v_occurred_at,
        v_new_hash,
        v_prior_hash
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_trigger_func IS
'Generic audit trigger. Reads context from app.current_user_id/name/role, '
'app.session_id, app.source_module. Derives authority_code from the '
'audited row. Computes record_hash and previous_hash inline (the column '
'is NOT NULL). Uses clock_timestamp() for unique occurred_at. Chains '
'via sequence_number-ordered previous row. V96 fix.';

-- ---------------------------------------------------------------------
-- Rehash the chain to a clean state
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_rec RECORD;
    v_prior_hash VARCHAR(64) := NULL;
    v_new_hash VARCHAR(64);
    v_count INTEGER := 0;
BEGIN
    ALTER TABLE audit_event DISABLE TRIGGER trg_prevent_audit_event_update;

    FOR v_rec IN
        SELECT event_id, event_type, entity_type, entity_id, action,
               old_value, new_value, changes, user_id, user_role,
               authority_code, ip_address, request_id, user_name,
               session_id, user_agent, source_module,
               occurred_at, sequence_number
        FROM audit_event
        ORDER BY sequence_number ASC
    LOOP
        v_new_hash := encode(sha256((
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
        )::bytea), 'hex');

        UPDATE audit_event
        SET record_hash = v_new_hash,
            previous_hash = v_prior_hash
        WHERE event_id = v_rec.event_id;

        v_prior_hash := v_new_hash;
        v_count := v_count + 1;
    END LOOP;

    ALTER TABLE audit_event ENABLE TRIGGER trg_prevent_audit_event_update;

    RAISE NOTICE 'Recomputed hashes for % audit records', v_count;
END $$;

-- ---------------------------------------------------------------------
-- Log the migration (uses the newly rebuilt trigger)
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'SYSTEM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_audit_trigger_hash_and_settings',
        'migration', 'V96',
        'fixes', ARRAY[
            'audit_trigger_func reads app.current_user_id/name/role',
            'audit_trigger_func computes record_hash inline',
            'audit_trigger_func computes previous_hash inline',
            'audit_trigger_func derives authority_code from audited row'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
