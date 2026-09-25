-- =====================================================================
-- V62__fix_gl_functions_lpad.sql
-- Fix LPAD type casting bug in GL functions
-- =====================================================================
-- Bug: LPAD(BIGINT, INTEGER, TEXT) does not exist in PostgreSQL.
-- COUNT(*) returns BIGINT. LPAD requires TEXT as first argument.
-- Fix: cast (COUNT(*) + 1) to TEXT before passing to LPAD.
--
-- Affects: create_manual_journal()
-- =====================================================================

CREATE OR REPLACE FUNCTION create_manual_journal(
    p_authority_code VARCHAR,
    p_journal_date DATE,
    p_description TEXT,
    p_reference VARCHAR,
    p_lines JSONB,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_period_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
    v_line JSONB;
    v_line_number INTEGER := 1;
    v_journal_count BIGINT;
    v_account_id UUID;
    v_fund_id UUID;
    v_cost_center_id UUID;
BEGIN
    -- Find period
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_journal_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No fiscal period found for date % and authority %',
            p_journal_date, p_authority_code;
    END IF;

    -- Count existing journals for the day (BIGINT)
    SELECT COUNT(*) INTO v_journal_count
    FROM journal_entry
    WHERE authority_code = p_authority_code
      AND journal_date = p_journal_date;

    -- Generate journal number (cast to TEXT for LPAD)
    v_journal_number := 'JV-' || TO_CHAR(p_journal_date, 'YYYYMMDD') || '-' ||
                        LPAD((v_journal_count + 1)::TEXT, 5, '0');

    -- Create journal
    INSERT INTO journal_entry (
        authority_code, journal_number, journal_date, period_id,
        journal_type, description, reference, status, created_by
    ) VALUES (
        p_authority_code, v_journal_number, p_journal_date, v_period_id,
        'MANUAL', p_description, p_reference, 'DRAFT', p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    -- Insert lines from JSONB array
    FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
    LOOP
        -- Look up account
        SELECT account_id INTO v_account_id
        FROM chart_of_accounts
        WHERE account_code = v_line->>'account_code';

        IF v_account_id IS NULL THEN
            RAISE EXCEPTION 'Account not found: %', v_line->>'account_code';
        END IF;

        -- Look up fund
        SELECT fund_id INTO v_fund_id
        FROM fund
        WHERE fund_code = v_line->>'fund_code';

        IF v_fund_id IS NULL THEN
            RAISE EXCEPTION 'Fund not found: %', v_line->>'fund_code';
        END IF;

        -- Look up cost center
        SELECT cost_center_id INTO v_cost_center_id
        FROM cost_center
        WHERE cost_center_code = v_line->>'cost_center_code';

        IF v_cost_center_id IS NULL THEN
            RAISE EXCEPTION 'Cost center not found: %', v_line->>'cost_center_code';
        END IF;

        -- Insert line
        INSERT INTO journal_line (
            journal_id, line_number, account_id, fund_id, cost_center_id,
            debit, credit, description
        ) VALUES (
            v_journal_id,
            v_line_number,
            v_account_id,
            v_fund_id,
            v_cost_center_id,
            COALESCE((v_line->>'debit')::NUMERIC, 0),
            COALESCE((v_line->>'credit')::NUMERIC, 0),
            v_line->>'description'
        );
        v_line_number := v_line_number + 1;
    END LOOP;

    -- Post the journal
    PERFORM post_journal(v_journal_id, p_user_id);

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION create_manual_journal IS
'Creates and posts a manual journal in one call. '
'p_lines is a JSONB array. Validates account, fund, and cost center codes. '
'Fixed in V62: LPAD type casting (BIGINT → TEXT).';

-- ---------------------------------------------------------------------
-- AUDIT LOG
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, old_value, new_value, change_reason,
     changed_by, record_hash)
VALUES (
    'GENERAL_LEDGER',
    gen_random_uuid(),
    'UPDATE',
    jsonb_build_object(
        'function', 'create_manual_journal',
        'bug', 'LPAD(BIGINT, INTEGER, TEXT) does not exist'
    ),
    jsonb_build_object(
        'function', 'create_manual_journal',
        'fix', 'CAST (COUNT(*) + 1) AS TEXT before LPAD',
        'migration', 'V62'
    ),
    'Bug fix — LPAD type casting in journal number generation',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256(('V62' || 'fix_lpad' || NOW()::text)::bytea), 'hex')
);
