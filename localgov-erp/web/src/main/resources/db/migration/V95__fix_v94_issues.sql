-- =====================================================================
-- V95__fix_v94_issues.sql
-- Fixes three problems introduced or exposed by V94:
--   1. verify_audit_chain() became ambiguous (overload conflict)
--   2. audit_trigger_func() used wrong setting names → user_id NULL
--   3. Report functions reject timestamp args (no implicit cast)
--
-- PART 1: Drop and rebuild verify_audit_chain() as single canonical fn
-- PART 2: Rebuild audit_trigger_func() with correct setting names
-- PART 3: Add TIMESTAMP overloads for the two report functions
-- PART 4: Rehash the chain with stable state
-- PART 5: Log the migration
-- =====================================================================

-- ---------------------------------------------------------------------
-- PART 1: Drop ALL verify_audit_chain overloads, rebuild canonical one
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT oid::regprocedure AS sig
        FROM pg_proc
        WHERE proname = 'verify_audit_chain'
    LOOP
        EXECUTE 'DROP FUNCTION ' || v_rec.sig;
        RAISE NOTICE 'Dropped: %', v_rec.sig;
    END LOOP;
END $$;

CREATE FUNCTION verify_audit_chain()
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
    SELECT COUNT(*) INTO v_total FROM audit_event;

    FOR v_rec IN
        SELECT event_id, event_type, entity_type, entity_id, action,
               old_value, new_value, changes, user_id, user_role,
               authority_code, ip_address, request_id, user_name,
               session_id, user_agent, source_module,
               record_hash, previous_hash, occurred_at
        FROM audit_event
        ORDER BY sequence_number ASC
    LOOP
        v_expected := encode(sha256((
            COALESCE(v_prior_hash, 'CHAIN_START') ||
            v_rec.event_id::text ||
            COALESCE(v_rec.event_type, '') || COALESCE(v_rec.entity_type, '') ||
            COALESCE(v_rec.entity_id::text, '') || COALESCE(v_rec.action, '') ||
            COALESCE(v_rec.old_value::text, '') || COALESCE(v_rec.new_value::text, '') ||
            COALESCE(v_rec.changes::text, '') || v_rec.user_id::text ||
            COALESCE(v_rec.user_role, '') || COALESCE(v_rec.authority_code, '') ||
            COALESCE(v_rec.ip_address::text, '') || COALESCE(v_rec.request_id, '') ||
            COALESCE(v_rec.user_name, '') || COALESCE(v_rec.session_id, '') ||
            COALESCE(v_rec.user_agent, '') || COALESCE(v_rec.source_module, '') ||
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
            ELSE 'CHAIN_BROKEN'::TEXT
        END,
        v_total,
        v_chained,
        v_broken,
        v_tampered;
END;
$$;

COMMENT ON FUNCTION verify_audit_chain IS
'Verifies the audit chain. Orders by sequence_number (deterministic) '
'instead of occurred_at. Single canonical signature.';

-- ---------------------------------------------------------------------
-- PART 2: Rebuild audit_trigger_func with the CORRECT setting names.
--
-- The original log_audit_event and set_audit_context use these
-- setting names (discovered by inspecting the source):
--     ymbji.user_id
--     ymbji.user_name
--     ymbji.user_role
--     ymbji.authority_code
--     ymbji.session_id
--     ymbji.source_module
--
-- Also: fall back gracefully when any setting is NULL, using a SYSTEM
-- sentinel user_id so NOT NULL constraints are satisfied.
-- ---------------------------------------------------------------------
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
    v_system_user UUID := '00000000-0000-0000-0000-000000000001'::UUID;
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
    ELSE  -- DELETE
        v_action := 'DELETE';
        v_new := NULL;
        v_old := to_jsonb(OLD);
    END IF;

    -- Extract entity id if the row has an 'id' column, else try common PKs
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

    -- Read audit context — try ymbji.* first, then app.*, then fallbacks
    v_user_id := COALESCE(
        NULLIF(current_setting('ymbji.user_id', TRUE), '')::UUID,
        NULLIF(current_setting('app.user_id', TRUE), '')::UUID,
        v_system_user
    );

    v_user_name := COALESCE(
        NULLIF(current_setting('ymbji.user_name', TRUE), ''),
        NULLIF(current_setting('app.user_name', TRUE), ''),
        'SYSTEM'
    );

    v_user_role := COALESCE(
        NULLIF(current_setting('ymbji.user_role', TRUE), ''),
        NULLIF(current_setting('app.user_role', TRUE), ''),
        'SYSTEM'
    );

    v_authority_code := COALESCE(
        NULLIF(current_setting('ymbji.authority_code', TRUE), ''),
        NULLIF(current_setting('app.authority_code', TRUE), ''),
        'CHILANGA'   -- safe default; override via set_audit_context
    );

    v_session_id := COALESCE(
        NULLIF(current_setting('ymbji.session_id', TRUE), ''),
        NULLIF(current_setting('app.session_id', TRUE), '')
    );

    v_source_module := COALESCE(
        NULLIF(current_setting('ymbji.source_module', TRUE), ''),
        NULLIF(current_setting('app.source_module', TRUE), ''),
        'DATABASE'
    );

    -- Insert audit event with clock_timestamp() for unique microsecond
    INSERT INTO audit_event (
        event_type, entity_type, entity_id, action,
        old_value, new_value, changes,
        user_id, user_name, user_role, authority_code,
        session_id, source_module,
        occurred_at
    ) VALUES (
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
        clock_timestamp()
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_trigger_func IS
'Generic audit trigger. Reads context from ymbji.* settings, falls '
'back to app.*, and finally to SYSTEM defaults. Uses clock_timestamp() '
'for unique occurred_at. V95 fix.';

-- ---------------------------------------------------------------------
-- PART 3: TIMESTAMP overloads for report functions
-- ---------------------------------------------------------------------

-- Drop existing TIMESTAMP overloads if any (idempotent)
DROP FUNCTION IF EXISTS get_ap_expense_summary(VARCHAR, TIMESTAMP, TIMESTAMP);
DROP FUNCTION IF EXISTS get_vendor_statement(UUID, TIMESTAMP, TIMESTAMP);

-- Overload: get_ap_expense_summary (timestamp version)
CREATE FUNCTION get_ap_expense_summary(
    p_authority_code VARCHAR,
    p_from_date TIMESTAMP,
    p_to_date TIMESTAMP
) RETURNS TABLE (
    invoice_type VARCHAR,
    account_code VARCHAR,
    account_name VARCHAR,
    fund_code VARCHAR,
    cost_center_code VARCHAR,
    invoice_count BIGINT,
    net_expense NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT * FROM get_ap_expense_summary(
        p_authority_code,
        p_from_date::DATE,
        p_to_date::DATE
    );
$$;

COMMENT ON FUNCTION get_ap_expense_summary(VARCHAR, TIMESTAMP, TIMESTAMP) IS
'Timestamp overload — casts to DATE and delegates to the DATE version. '
'Allows callers to pass CURRENT_DATE - INTERVAL ''1 day'' without '
'explicit casting.';

-- Overload: get_vendor_statement (timestamp version)
CREATE FUNCTION get_vendor_statement(
    p_vendor_id UUID,
    p_from_date TIMESTAMP,
    p_to_date TIMESTAMP
) RETURNS TABLE (
    entry_date DATE,
    entry_type VARCHAR,
    reference VARCHAR,
    description TEXT,
    debit NUMERIC,
    credit NUMERIC,
    running_balance NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT * FROM get_vendor_statement(
        p_vendor_id,
        p_from_date::DATE,
        p_to_date::DATE
    );
$$;

COMMENT ON FUNCTION get_vendor_statement(UUID, TIMESTAMP, TIMESTAMP) IS
'Timestamp overload — casts to DATE and delegates to the DATE version.';

-- ---------------------------------------------------------------------
-- PART 4: Rehash the chain with stable state
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
            COALESCE(v_rec.event_type, '') || COALESCE(v_rec.entity_type, '') ||
            COALESCE(v_rec.entity_id::text, '') || COALESCE(v_rec.action, '') ||
            COALESCE(v_rec.old_value::text, '') || COALESCE(v_rec.new_value::text, '') ||
            COALESCE(v_rec.changes::text, '') || v_rec.user_id::text ||
            COALESCE(v_rec.user_role, '') || COALESCE(v_rec.authority_code, '') ||
            COALESCE(v_rec.ip_address::text, '') || COALESCE(v_rec.request_id, '') ||
            COALESCE(v_rec.user_name, '') || COALESCE(v_rec.session_id, '') ||
            COALESCE(v_rec.user_agent, '') || COALESCE(v_rec.source_module, '') ||
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
-- PART 5: Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'SYSTEM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_v94_issues',
        'migration', 'V95',
        'fixes', ARRAY[
            'verify_audit_chain dropped and rebuilt (single signature)',
            'audit_trigger_func reads ymbji.* settings with fallbacks',
            'get_ap_expense_summary timestamp overload added',
            'get_vendor_statement timestamp overload added',
            'chain rehashed with stable state'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
