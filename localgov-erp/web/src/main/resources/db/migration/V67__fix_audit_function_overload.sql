-- =====================================================================
-- V67__fix_audit_function_overload.sql
-- Fix: Drop old log_audit_event overload (11 params)
-- =====================================================================
-- V63 created log_audit_event with 11 parameters.
-- V66 created a new version with 16 parameters.
-- PostgreSQL kept BOTH as overloads, causing "not unique" errors.
--
-- Fix: Drop the old 11-parameter version.
-- The new 16-parameter version has DEFAULT values for its extra
-- parameters, so 11-argument calls will resolve to it unambiguously.
--
-- Also updates post_journal and reverse_journal to use the new
-- function signature explicitly.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Drop the OLD 11-parameter version
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS log_audit_event(
    VARCHAR, VARCHAR, UUID, VARCHAR, JSONB, JSONB,
    UUID, VARCHAR, VARCHAR, INET, VARCHAR
);

-- ---------------------------------------------------------------------
-- 2. Verify only ONE version of log_audit_event remains
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM information_schema.routines
    WHERE routine_schema = 'public'
      AND routine_name = 'log_audit_event';

    IF v_count != 1 THEN
        RAISE EXCEPTION 'Expected 1 log_audit_event function, found %', v_count;
    END IF;

    RAISE NOTICE 'Confirmed: exactly 1 log_audit_event function remains';
END $$;

-- ---------------------------------------------------------------------
-- 3. Rebuild post_journal to use new signature explicitly
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION post_journal(
    p_journal_id UUID,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_journal RECORD;
    v_period_closed BOOLEAN;
    v_line_count INTEGER;
    v_total_debit NUMERIC;
    v_total_credit NUMERIC;
BEGIN
    SELECT * INTO v_journal FROM journal_entry WHERE journal_id = p_journal_id;

    IF v_journal IS NULL THEN
        RAISE EXCEPTION 'Journal not found: %', p_journal_id;
    END IF;

    IF v_journal.status = 'POSTED' THEN
        RAISE EXCEPTION 'Journal is already posted: %', v_journal.journal_number;
    END IF;

    IF v_journal.status = 'REVERSED' THEN
        RAISE EXCEPTION 'Journal is reversed and cannot be posted: %', v_journal.journal_number;
    END IF;

    SELECT is_closed INTO v_period_closed
    FROM fiscal_period
    WHERE period_id = v_journal.period_id;

    IF v_period_closed THEN
        RAISE EXCEPTION 'Cannot post to a closed fiscal period';
    END IF;

    SELECT COUNT(*) INTO v_line_count
    FROM journal_line
    WHERE journal_id = p_journal_id;

    IF v_line_count < 2 THEN
        RAISE EXCEPTION 'Journal must have at least 2 lines. Found: %', v_line_count;
    END IF;

    SELECT
        COALESCE(SUM(debit), 0),
        COALESCE(SUM(credit), 0)
    INTO v_total_debit, v_total_credit
    FROM journal_line
    WHERE journal_id = p_journal_id;

    IF v_total_debit != v_total_credit THEN
        RAISE EXCEPTION 'Journal is not balanced. Debits: %, Credits: %',
            v_total_debit, v_total_credit;
    END IF;

    IF v_total_debit = 0 THEN
        RAISE EXCEPTION 'Journal total is zero';
    END IF;

    UPDATE journal_entry
    SET status = 'POSTED',
        posted_by = p_user_id,
        posted_at = NOW(),
        total_debit = v_total_debit,
        total_credit = v_total_credit
    WHERE journal_id = p_journal_id;

    -- Call new log_audit_event with explicit parameters
    PERFORM log_audit_event(
        p_event_type := 'POST',
        p_entity_type := 'JOURNAL_ENTRY',
        p_entity_id := p_journal_id,
        p_action := 'POST',
        p_old_value := NULL,
        p_new_value := jsonb_build_object(
            'journal_number', v_journal.journal_number,
            'total_debit', v_total_debit,
            'total_credit', v_total_credit
        ),
        p_user_id := p_user_id,
        p_user_role := NULL,
        p_authority_code := v_journal.authority_code,
        p_ip_address := inet_client_addr(),
        p_request_id := NULL,
        p_changes := NULL,
        p_user_name := NULL,
        p_session_id := NULL,
        p_user_agent := NULL,
        p_source_module := 'GL'
    );

    RETURN p_journal_id;
END;
$$;

-- ---------------------------------------------------------------------
-- 4. Rebuild reverse_journal to use new signature explicitly
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reverse_journal(
    p_journal_id UUID,
    p_user_id UUID,
    p_reason TEXT
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_original RECORD;
    v_reversal_id UUID;
    v_new_journal_number VARCHAR;
    v_line RECORD;
    v_line_number INTEGER := 1;
BEGIN
    SELECT * INTO v_original FROM journal_entry WHERE journal_id = p_journal_id;

    IF v_original IS NULL THEN
        RAISE EXCEPTION 'Journal not found: %', p_journal_id;
    END IF;

    IF v_original.status != 'POSTED' THEN
        RAISE EXCEPTION 'Only POSTED journals can be reversed. Status: %', v_original.status;
    END IF;

    IF v_original.is_reversal THEN
        RAISE EXCEPTION 'Cannot reverse a reversal';
    END IF;

    v_new_journal_number := 'REV-' || v_original.journal_number;

    INSERT INTO journal_entry (
        authority_code, journal_number, journal_date, period_id,
        journal_type, source_module, source_id, description,
        status, is_reversal, reversed_journal_id, created_by
    ) VALUES (
        v_original.authority_code,
        v_new_journal_number,
        v_original.journal_date,
        v_original.period_id,
        'REVERSAL',
        v_original.source_module,
        v_original.source_id,
        'Reversal of ' || v_original.journal_number || ': ' || p_reason,
        'DRAFT',
        TRUE,
        v_original.journal_id,
        p_user_id
    ) RETURNING journal_id INTO v_reversal_id;

    FOR v_line IN
        SELECT * FROM journal_line
        WHERE journal_id = p_journal_id
        ORDER BY line_number
    LOOP
        INSERT INTO journal_line (
            journal_id, line_number, account_id, fund_id, cost_center_id,
            debit, credit, description, reference
        ) VALUES (
            v_reversal_id,
            v_line_number,
            v_line.account_id,
            v_line.fund_id,
            v_line.cost_center_id,
            v_line.credit,
            v_line.debit,
            'Reversal: ' || COALESCE(v_line.description, ''),
            v_line.reference
        );
        v_line_number := v_line_number + 1;
    END LOOP;

    PERFORM post_journal(v_reversal_id, p_user_id);

    UPDATE journal_entry
    SET status = 'REVERSED'
    WHERE journal_id = p_journal_id;

    PERFORM log_audit_event(
        p_event_type := 'REVERSE',
        p_entity_type := 'JOURNAL_ENTRY',
        p_entity_id := p_journal_id,
        p_action := 'REVERSE',
        p_old_value := jsonb_build_object('status', 'POSTED'),
        p_new_value := jsonb_build_object(
            'status', 'REVERSED',
            'reversal_journal_id', v_reversal_id,
            'reason', p_reason
        ),
        p_user_id := p_user_id,
        p_user_role := NULL,
        p_authority_code := v_original.authority_code,
        p_ip_address := inet_client_addr(),
        p_request_id := NULL,
        p_changes := NULL,
        p_user_name := NULL,
        p_session_id := NULL,
        p_user_agent := NULL,
        p_source_module := 'GL'
    );

    RETURN v_reversal_id;
END;
$$;

COMMENT ON FUNCTION post_journal IS
'Posts a journal. Logs to audit_event with source_module = GL.';

COMMENT ON FUNCTION reverse_journal IS
'Reverses a posted journal. Logs to audit_event with source_module = GL.';

-- ---------------------------------------------------------------------
-- 5. Log the migration
-- ---------------------------------------------------------------------
PERFORM log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_audit_function_overload',
        'migration', 'V67',
        'dropped_versions', ARRAY['log_audit_event (11 params)'],
        'kept_versions', ARRAY['log_audit_event (16 params)'],
        'rebuilt_functions', ARRAY['post_journal', 'reverse_journal']
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
