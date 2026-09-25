-- =====================================================================
-- V70__create_audit_trigger_func.sql
-- Automatic Audit Logging Trigger Function
-- =====================================================================
-- This is a GENERIC trigger function that can be attached to any
-- business table. When a row is INSERTED, UPDATED, or DELETED, the
-- function automatically logs the event to the audit_event table.
--
-- Why this matters:
--   - Developers cannot "forget" to log
--   - Every write to the table is captured
--   - Works regardless of write method (Java, SQL, batch, manual)
--   - Complete audit coverage
--
-- How to use:
--   CREATE TRIGGER trg_audit_<table>
--       AFTER INSERT OR UPDATE OR DELETE ON <table>
--       FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
--
-- Design:
--   - Captures OLD and NEW row states
--   - Computes changes JSONB for UPDATE
--   - Maps INSERT → CREATE, UPDATE → UPDATE, DELETE → DELETE
--   - Calls log_audit_event with all context
--   - Does not modify the underlying data
-- =====================================================================

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
    v_changes JSONB;
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

    -- Extract authority_code if the column exists
    v_authority_code := NULL;
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        BEGIN
            v_authority_code := NEW.authority_code;
        EXCEPTION WHEN OTHERS THEN
            v_authority_code := NULL;
        END;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            v_authority_code := OLD.authority_code;
        EXCEPTION WHEN OTHERS THEN
            v_authority_code := NULL;
        END;
    END IF;

    -- Extract entity_id if the table has an id column
    -- (tries common primary key column names)
    v_entity_id := NULL;
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        BEGIN
            v_entity_id := NEW.journal_id;
        EXCEPTION WHEN OTHERS THEN
            BEGIN
                v_entity_id := NEW.fund_id;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    v_entity_id := NEW.cost_center_id;
                EXCEPTION WHEN OTHERS THEN
                    BEGIN
                        v_entity_id := NEW.account_id;
                    EXCEPTION WHEN OTHERS THEN
                        BEGIN
                            v_entity_id := NEW.period_id;
                        EXCEPTION WHEN OTHERS THEN
                            v_entity_id := NULL;
                        END;
                    END;
                END;
            END;
        END;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            v_entity_id := OLD.journal_id;
        EXCEPTION WHEN OTHERS THEN
            BEGIN
                v_entity_id := OLD.fund_id;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    v_entity_id := OLD.cost_center_id;
                EXCEPTION WHEN OTHERS THEN
                    BEGIN
                        v_entity_id := OLD.account_id;
                    EXCEPTION WHEN OTHERS THEN
                        BEGIN
                            v_entity_id := OLD.period_id;
                        EXCEPTION WHEN OTHERS THEN
                            v_entity_id := NULL;
                        END;
                    END;
                END;
            END;
        END;
    END IF;

    -- Capture row states as JSONB
    IF TG_OP IN ('INSERT', 'UPDATE') THEN
        v_new_value := to_jsonb(NEW);
    END IF;

    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        v_old_value := to_jsonb(OLD);
    END IF;

    -- Compute changes diff (only for UPDATE)
    IF TG_OP = 'UPDATE' THEN
        SELECT jsonb_object_agg(key, jsonb_build_object('old', old_val, 'new', new_val))
        INTO v_changes
        FROM (
            SELECT
                key,
                (OLD_JSON -> key) AS old_val,
                (NEW_JSON -> key) AS new_val
            FROM jsonb_each(to_jsonb(NEW)) AS NEW_JSON(key, new_value),
                 LATERAL (SELECT to_jsonb(OLD)) AS OLD_JSON
            WHERE to_jsonb(OLD) -> key IS DISTINCT FROM to_jsonb(NEW) -> key
        ) AS diff;
    END IF;

    -- User context: use session variables if set, otherwise system defaults
    v_user_id := COALESCE(
        current_setting('app.current_user_id', TRUE)::UUID,
        '00000000-0000-0000-0000-000000000001'::UUID
    );

    -- Determine trigger source from session variable
    v_trigger_source := COALESCE(
        current_setting('app.source_module', TRUE),
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
        p_user_role := NULL,
        p_authority_code := v_authority_code,
        p_ip_address := inet_client_addr(),
        p_request_id := COALESCE(current_setting('app.request_id', TRUE), NULL),
        p_changes := v_changes,
        p_user_name := COALESCE(current_setting('app.current_user_name', TRUE), NULL),
        p_session_id := COALESCE(current_setting('app.session_id', TRUE), NULL),
        p_user_agent := NULL,
        p_source_module := v_trigger_source
    );

    -- Return the row (for AFTER triggers, this is ignored; for BEFORE triggers, this matters)
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_trigger_func IS
'Generic auto-audit trigger. Attach to any table with:
  CREATE TRIGGER trg_audit_<table>
      AFTER INSERT OR UPDATE OR DELETE ON <table>
      FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

Automatically logs INSERT → CREATE, UPDATE → UPDATE, DELETE → DELETE
to audit_event. Captures OLD/NEW row states, changes diff, and user
context (from session variables app.current_user_id, app.session_id, etc.).

Fully automatic — developers cannot forget to log.';

-- ---------------------------------------------------------------------
-- Helper function: set_audit_context
-- Used by the application to set session context before write operations.
-- Then all subsequent writes are attributed to that user.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_audit_context(
    p_user_id UUID,
    p_user_name VARCHAR DEFAULT NULL,
    p_user_role VARCHAR DEFAULT NULL,
    p_session_id VARCHAR DEFAULT NULL,
    p_source_module VARCHAR DEFAULT NULL
) RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM set_config('app.current_user_id', p_user_id::TEXT, FALSE);
    IF p_user_name IS NOT NULL THEN
        PERFORM set_config('app.current_user_name', p_user_name, FALSE);
    END IF;
    IF p_user_role IS NOT NULL THEN
        PERFORM set_config('app.current_user_role', p_user_role, FALSE);
    END IF;
    IF p_session_id IS NOT NULL THEN
        PERFORM set_config('app.session_id', p_session_id, FALSE);
    END IF;
    IF p_source_module IS NOT NULL THEN
        PERFORM set_config('app.source_module', p_source_module, FALSE);
    END IF;
END;
$$;

COMMENT ON FUNCTION set_audit_context IS
'Sets session context for audit logging. Call this at the start of a
user session or before a batch of operations. Subsequent writes will
be attributed to this user in the audit trail.
Example:
  SELECT set_audit_context(
      p_user_id := ''...''::UUID,
      p_user_name := ''john.doe'',
      p_user_role := ''ACCOUNTANT'',
      p_session_id := ''sess-abc-123'',
      p_source_module := ''PAYROLL''
  );';

-- ---------------------------------------------------------------------
-- Helper function: clear_audit_context
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION clear_audit_context()
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    PERFORM set_config('app.current_user_id', '', FALSE);
    PERFORM set_config('app.current_user_name', '', FALSE);
    PERFORM set_config('app.current_user_role', '', FALSE);
    PERFORM set_config('app.session_id', '', FALSE);
    PERFORM set_config('app.source_module', '', FALSE);
END;
$$;

COMMENT ON FUNCTION clear_audit_context IS
'Clears session context for audit logging. Call at the end of a user
session or batch operation.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_audit_trigger_func',
        'migration', 'V70',
        'purpose', 'Auto-logging trigger for all business tables',
        'functions_created', ARRAY[
            'audit_trigger_func',
            'set_audit_context',
            'clear_audit_context'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
