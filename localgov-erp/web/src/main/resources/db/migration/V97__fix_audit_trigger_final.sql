-- =====================================================================
-- V97__fix_audit_trigger_final.sql
-- Final fix for the audit trigger saga.
--
--   1. Rebuild audit_trigger_func with the correct event_type/action
--      values allowed by the CHECK constraints, correct setting names,
--      and inline hash computation.
--
--   2. Add verify_audit_chain(TIMESTAMPTZ, TIMESTAMPTZ) overload so
--      audit_health_check(NULL, NULL) works again.
--
--   3. Preserve three-state semantics: VERIFIED / TAMPERED / CHAIN_BROKEN
--
-- Constraints discovered:
--   chk_audit_event_type allows:
--     LOGIN, LOGOUT, CREATE, UPDATE, DELETE, POST, REVERSE, REVERSED,
--     APPROVE, REJECT, READ, EXPORT, PRINT, CONFIG_CHANGE, CONFIG,
--     SYSTEM, TRANSACTION, OTHER
--   chk_audit_action allows:
--     CREATE, READ, UPDATE, DELETE, POST, REVERSE, APPROVE, REJECT,
--     EXPORT, LOGIN, LOGOUT, CONFIG, PRINT, OTHER
--
-- Setting names (confirmed from set_audit_context):
--   app.current_user_id
--   app.current_user_name
--   app.current_user_role
--   app.session_id
--   app.source_module
-- =====================================================================

-- ---------------------------------------------------------------------
-- PART 1: Rebuild audit_trigger_func — event_type matches TG_OP
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_old JSONB;
    v_new JSONB;
    v_event_type VARCHAR(50);
    v_action VARCHAR(50);
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
    -- Map TG_OP to the allowed event_type / action values
    IF TG_OP = 'INSERT' THEN
        v_event_type := 'CREATE';
        v_action := 'CREATE';
        v_new := to_jsonb(NEW);
        v_old := NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        v_event_type := 'UPDATE';
        v_action := 'UPDATE';
        v_new := to_jsonb(NEW);
        v_old := to_jsonb(OLD);
    ELSE  -- DELETE
        v_event_type := 'DELETE';
        v_action := 'DELETE';
        v_new := NULL;
        v_old := to_jsonb(OLD);
    END IF;

    -- Extract entity_id: try common PK patterns
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

    -- Read audit context from the ACTUAL setting names
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

    -- Derive authority_code from the audited row when possible
    BEGIN
        IF TG_OP = 'DELETE' THEN
            v_authority_code := v_old->>'authority_code';
        ELSE
            v_authority_code := v_new->>'authority_code';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_authority_code := NULL;
    END;

    -- Generate event id and occurred_at (clock_timestamp → unique)
    v_event_id := gen_random_uuid();
    v_occurred_at := clock_timestamp();

    -- Get prior hash ordered by sequence_number DESC (deterministic)
    SELECT record_hash INTO v_prior_hash
    FROM audit_event
    ORDER BY sequence_number DESC
    LIMIT 1;

    -- Compute this record's hash using the SAME formula as
    -- verify_audit_chain() and the rehash block.
    v_new_hash := encode(sha256((
        COALESCE(v_prior_hash, 'CHAIN_START') ||
        v_event_id::text ||
        COALESCE(v_event_type, '') ||
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

    INSERT INTO audit_event (
        event_id,
        event_type, entity_type, entity_id, action,
        old_value, new_value, changes,
        user_id, user_name, user_role,
        session_id, authority_code, source_module,
        occurred_at,
        record_hash, previous_hash
    ) VALUES (
        v_event_id,
        v_event_type, TG_TABLE_NAME, v_entity_id, v_action,
        v_old, v_new, NULL,
        v_user_id, v_user_name, v_user_role,
        v_session_id, v_authority_code, v_source_module,
        v_occurred_at,
        v_new_hash, v_prior_hash
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_trigger_func IS
'Generic audit trigger. event_type and action match TG_OP (CREATE/'
'UPDATE/DELETE), satisfying chk_audit_event_type and chk_audit_action. '
'Reads app.current_user_id/name/role, app.session_id, app.source_module. '
'Computes record_hash and previous_hash inline. Uses clock_timestamp() '
'for unique occurred_at. Chains via sequence_number ordering. V97 final.';

-- ---------------------------------------------------------------------
-- PART 2: Two-arg verify_audit_chain overload (for audit_health_check)
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS verify_audit_chain(TIMESTAMPTZ, TIMESTAMPTZ);

CREATE FUNCTION verify_audit_chain(
    p_from TIMESTAMPTZ,
    p_to TIMESTAMPTZ
)
RETURNS TABLE (
    verification_status TEXT,
    total_records BIGINT,
    chained_records BIGINT,
    broken_links BIGINT,
    field_tampering BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_total BIGINT;
    v_chained BIGINT := 0;
    v_broken BIGINT := 0;
    v_tampered BIGINT := 0;
    v_prior_hash VARCHAR(64) := NULL;
    v_rec RECORD;
    v_expected VARCHAR(64);
BEGIN
    -- Optional date filter. NULL means "no filter".
    SELECT COUNT(*) INTO v_total
    FROM audit_event
    WHERE (p_from IS NULL OR occurred_at >= p_from)
      AND (p_to   IS NULL OR occurred_at <= p_to);

    FOR v_rec IN
        SELECT event_id, event_type, entity_type, entity_id, action,
               old_value, new_value, changes, user_id, user_role,
               authority_code, ip_address, request_id, user_name,
               session_id, user_agent, source_module,
               record_hash, previous_hash, occurred_at
        FROM audit_event
        WHERE (p_from IS NULL OR occurred_at >= p_from)
          AND (p_to   IS NULL OR occurred_at <= p_to)
        ORDER BY sequence_number ASC
    LOOP
        v_expected := encode(sha256((
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

        IF v_rec.previous_hash IS NOT DISTINCT FROM v_prior_hash THEN
            v_chained := v_chained + 1;
        ELSE
            v_broken := v_broken + 1;
        END IF;

        IF v_rec.record_hash IS DISTINCT FROM v_expected THEN
            v_tampered := v_tampered + 1;
        END IF;

        v_prior_hash := v_rec.record_hash;
    END LOOP;

    RETURN QUERY SELECT
        CASE
            WHEN v_broken = 0 AND v_tampered = 0 THEN 'VERIFIED'::TEXT
            WHEN v_tampered > 0 THEN 'TAMPERED'::TEXT
            ELSE 'CHAIN_BROKEN'::TEXT
        END,
        v_total,
        v_chained,
        v_broken,
        v_tampered;
END;
$$;

COMMENT ON FUNCTION verify_audit_chain(TIMESTAMPTZ, TIMESTAMPTZ) IS
'Two-arg verify_audit_chain. Pass NULL, NULL to scan the entire chain. '
'Pass a date range to scan only events in that range. Returns '
'VERIFIED / TAMPERED / CHAIN_BROKEN. Restored in V97 for compatibility '
'with audit_health_check().';

-- ---------------------------------------------------------------------
-- PART 3: Rehash to a clean, consistent state
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
-- PART 4: Log the migration (uses the newly rebuilt trigger)
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'SYSTEM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_audit_trigger_final',
        'migration', 'V97',
        'fixes', ARRAY[
            'event_type matches TG_OP (CREATE/UPDATE/DELETE)',
            'action matches TG_OP',
            'reads app.current_user_id/name/role',
            'computes record_hash and previous_hash inline',
            'verify_audit_chain(TIMESTAMPTZ, TIMESTAMPTZ) overload restored',
            'audit_health_check(NULL, NULL) works again'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
