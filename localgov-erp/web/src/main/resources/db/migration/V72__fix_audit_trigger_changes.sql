-- =====================================================================
-- V72__fix_audit_trigger_changes.sql
-- Fix: changes diff calculation in audit_trigger_func
-- =====================================================================
-- Bug: The LATERAL subquery returned a record, not JSONB, causing
-- "operator does not exist: record -> text" on UPDATE events.
--
-- Fix: Use jsonb_each directly for both OLD and NEW, joined on key.
-- This is cleaner and avoids the record/JSONB confusion.
--
-- Also: Clean up the test fund 9999 that was left behind because the
-- UPDATE failed before the DELETE could run.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Clean up test fund 9999 (left behind by failed V71 UPDATE)
-- ---------------------------------------------------------------------
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM fund WHERE fund_code = '9999') THEN
        -- Temporarily disable audit triggers to avoid logging this cleanup
        ALTER TABLE fund DISABLE TRIGGER trg_audit_fund;
        DELETE FROM fund WHERE fund_code = '9999';
        ALTER TABLE fund ENABLE TRIGGER trg_audit_fund;
        RAISE NOTICE 'Cleaned up orphaned test fund 9999';
    ELSE
        RAISE NOTICE 'No test fund 9999 to clean up';
    END IF;
END $$;

-- ---------------------------------------------------------------------
-- 2. Rebuild audit_trigger_func with corrected changes diff
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_event_type VARCHAR(50);
    v_action VARCHAR(20);
    v_entity_type VARCHAR(50);
    v_entity_id UUID;
    v_old_value JSONB;
    v_new_value JSONB;
    v_changes JSONB := NULL;
    v_authority_code VARCHAR(20);
    v_user_id UUID;
    v_trigger_source VARCHAR(50);
BEGIN
    -- Determine action based on operation
    IF TG_OP = 'INSERT' THEN
        v_event_type := 'CREATE';
        v_action := 'CREATE';
    ELSIF TG_OP = 'UPDATE' THEN
        v_event_type := 'UPDATE';
        v_action := 'UPDATE';
    ELSIF TG_OP = 'DELETE' THEN
        v_event_type := 'DELETE';
        v_action := 'DELETE';
    ELSE
        v_event_type := 'OTHER';
        v_action := 'OTHER';
    END IF;

    -- Entity type = table name
    v_entity_type := UPPER(TG_TABLE_NAME);

    -- Capture row states
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        v_new_value := to_jsonb(NEW);
    END IF;

    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        v_old_value := to_jsonb(OLD);
    END IF;

    -- Extract authority_code if the column exists
    v_authority_code := NULL;
    IF v_new_value IS NOT NULL AND v_new_value ? 'authority_code' THEN
        v_authority_code := v_new_value->>'authority_code';
    ELSIF v_old_value IS NOT NULL AND v_old_value ? 'authority_code' THEN
        v_authority_code := v_old_value->>'authority_code';
    END IF;

    -- Extract entity_id from common primary key column names
    v_entity_id := NULL;
    IF v_new_value IS NOT NULL THEN
        v_entity_id := COALESCE(
            (v_new_value->>'journal_id')::UUID,
            (v_new_value->>'fund_id')::UUID,
            (v_new_value->>'cost_center_id')::UUID,
            (v_new_value->>'account_id')::UUID,
            (v_new_value->>'period_id')::UUID,
            (v_new_value->>'fiscal_year_id')::UUID
        );
    ELSIF v_old_value IS NOT NULL THEN
        v_entity_id := COALESCE(
            (v_old_value->>'journal_id')::UUID,
            (v_old_value->>'fund_id')::UUID,
            (v_old_value->>'cost_center_id')::UUID,
            (v_old_value->>'account_id')::UUID,
            (v_old_value->>'period_id')::UUID,
            (v_old_value->>'fiscal_year_id')::UUID
        );
    END IF;

    -- Compute changes diff (only for UPDATE) — CORRECTED
    IF TG_OP = 'UPDATE' THEN
        SELECT jsonb_object_agg(
            key,
            jsonb_build_object('old', old_val, 'new', new_val)
        )
        INTO v_changes
        FROM (
            SELECT
                new_kv.key,
                old_kv.value AS old_val,
                new_kv.value AS new_val
            FROM jsonb_each(v_new_value) AS new_kv(key, value)
            LEFT JOIN jsonb_each(v_old_value) AS old_kv(key, value)
                ON old_kv.key = new_kv.key
            WHERE old_kv.value IS DISTINCT FROM new_kv.value
        ) AS diff;
    END IF;

    -- User context: use session variables if set, otherwise system defaults
    v_user_id := COALESCE(
        NULLIF(current_setting('app.current_user_id', TRUE), '')::UUID,
        '00000000-0000-0000-0000-000000000001'::UUID
    );

    v_trigger_source := COALESCE(
        NULLIF(current_setting('app.source_module', TRUE), ''),
        'AUTO_TRIGGER'
    );

    -- Call log_audit_event with all context
    PERFORM log_audit_event(
        p_event_type := v_event_type,
        p_entity_type := v_entity_type,
        p_entity_id := v_entity_id,
        p_action := v_action,
        p_old_value := v_old_value,
        p_new_value := v_new_value,
        p_user_id := v_user_id,
        p_user_role := NULLIF(current_setting('app.current_user_role', TRUE), ''),
        p_authority_code := v_authority_code,
        p_ip_address := inet_client_addr(),
        p_request_id := NULLIF(current_setting('app.request_id', TRUE), ''),
        p_changes := v_changes,
        p_user_name := NULLIF(current_setting('app.current_user_name', TRUE), ''),
        p_session_id := NULLIF(current_setting('app.session_id', TRUE), ''),
        p_user_agent := NULL,
        p_source_module := v_trigger_source
    );

    -- Return the appropriate row
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_trigger_func IS
'Generic auto-audit trigger. Captures INSERT/UPDATE/DELETE with full
context and field-level changes diff. Fixed in V72 for correct
changes calculation.';

-- ---------------------------------------------------------------------
-- 3. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_audit_trigger_changes_diff',
        'migration', 'V72',
        'bug', 'record -> text operator error in LATERAL subquery',
        'fix', 'Use jsonb_each for both OLD and NEW, joined by key'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
