-- =====================================================================
-- V61__gl_functions.sql
-- General Ledger Functions — Operational Layer
-- =====================================================================
-- These functions make the GL usable from the application layer.
-- They encapsulate the business logic of posting, reversing, and
-- querying the General Ledger.
--
-- All functions are:
--   - Transactional (atomic)
--   - Auditable (log to compliance_rule_change_log)
--   - Permission-checked (user_id required)
--   - Fail-safe (RAISE EXCEPTION on error)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. post_journal — Post a journal to the GL
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
    -- Fetch journal
    SELECT * INTO v_journal FROM journal_entry WHERE journal_id = p_journal_id;

    IF v_journal IS NULL THEN
        RAISE EXCEPTION 'Journal not found: %', p_journal_id;
    END IF;

    -- Verify status
    IF v_journal.status = 'POSTED' THEN
        RAISE EXCEPTION 'Journal is already posted: %', v_journal.journal_number;
    END IF;

    IF v_journal.status = 'REVERSED' THEN
        RAISE EXCEPTION 'Journal is reversed and cannot be posted: %', v_journal.journal_number;
    END IF;

    -- Check period is open
    SELECT is_closed INTO v_period_closed
    FROM fiscal_period
    WHERE period_id = v_journal.period_id;

    IF v_period_closed THEN
        RAISE EXCEPTION 'Cannot post to a closed fiscal period';
    END IF;

    -- Count lines
    SELECT COUNT(*) INTO v_line_count
    FROM journal_line
    WHERE journal_id = p_journal_id;

    IF v_line_count < 2 THEN
        RAISE EXCEPTION 'Journal must have at least 2 lines. Found: %', v_line_count;
    END IF;

    -- Verify double-entry balance
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

    -- Post
    UPDATE journal_entry
    SET status = 'POSTED',
        posted_by = p_user_id,
        posted_at = NOW(),
        total_debit = v_total_debit,
        total_credit = v_total_credit
    WHERE journal_id = p_journal_id;

    -- Audit
    PERFORM log_audit_event(
        'TRANSACTION', 'JOURNAL_ENTRY', p_journal_id, 'POST',
        NULL,
        jsonb_build_object(
            'journal_number', v_journal.journal_number,
            'total_debit', v_total_debit,
            'total_credit', v_total_credit
        ),
        p_user_id, NULL, v_journal.authority_code, inet_client_addr(), NULL
    );

    RETURN p_journal_id;
END;
$$;

COMMENT ON FUNCTION post_journal IS
'Posts a journal to the General Ledger. Validates: journal exists, '
'status is DRAFT or SUBMITTED, period is open, has 2+ lines, debits '
'equal credits, total is non-zero. Logs to audit trail.';

-- ---------------------------------------------------------------------
-- 2. reverse_journal — Reverse a posted journal
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
    -- Fetch original journal
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

    -- Generate reversal journal number
    SELECT 'REV-' || v_original.journal_number
    INTO v_new_journal_number;

    -- Create reversal journal (same date, same period)
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

    -- Copy lines with debits/credits swapped
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
            v_line.credit,  -- swap: original credit becomes debit
            v_line.debit,   -- swap: original debit becomes credit
            'Reversal: ' || COALESCE(v_line.description, ''),
            v_line.reference
        );
        v_line_number := v_line_number + 1;
    END LOOP;

    -- Post the reversal
    PERFORM post_journal(v_reversal_id, p_user_id);

    -- Mark original as reversed
    UPDATE journal_entry
    SET status = 'REVERSED'
    WHERE journal_id = p_journal_id;

    -- Audit
    PERFORM log_audit_event(
        'TRANSACTION', 'JOURNAL_ENTRY', p_journal_id, 'REVERSE',
        jsonb_build_object('status', 'POSTED'),
        jsonb_build_object(
            'status', 'REVERSED',
            'reversal_journal_id', v_reversal_id,
            'reason', p_reason
        ),
        p_user_id, NULL, v_original.authority_code, inet_client_addr(), NULL
    );

    RETURN v_reversal_id;
END;
$$;

COMMENT ON FUNCTION reverse_journal IS
'Reverses a posted journal by creating a new journal with debits and '
'credits swapped. The original journal is marked REVERSED. Both journals '
'remain in the GL, preserving the audit trail.';

-- ---------------------------------------------------------------------
-- 3. get_account_balance — Balance for account + fund
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_account_balance(
    p_account_code VARCHAR,
    p_fund_code VARCHAR DEFAULT NULL,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
    LEFT JOIN fund f ON jl.fund_id = f.fund_id
    WHERE coa.account_code = p_account_code
      AND (p_fund_code IS NULL OR f.fund_code = p_fund_code)
      AND je.status = 'POSTED'
      AND je.journal_date <= p_as_of_date;
$$;

COMMENT ON FUNCTION get_account_balance IS
'Returns the net balance for an account (optionally filtered by fund) '
'as of a specific date. Uses SUM(debit - credit) from posted journals only.';

-- ---------------------------------------------------------------------
-- 4. get_fund_balance — Total balance for a fund
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_fund_balance(
    p_fund_code VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN fund f ON jl.fund_id = f.fund_id
    WHERE f.fund_code = p_fund_code
      AND je.status = 'POSTED'
      AND je.journal_date <= p_as_of_date;
$$;

COMMENT ON FUNCTION get_fund_balance IS
'Returns the net balance for a fund as of a specific date.';

-- ---------------------------------------------------------------------
-- 5. get_cost_center_balance — Total for a cost center
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_cost_center_balance(
    p_cost_center_code VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN cost_center cc ON jl.cost_center_id = cc.cost_center_id
    WHERE cc.cost_center_code = p_cost_center_code
      AND je.status = 'POSTED'
      AND je.journal_date <= p_as_of_date;
$$;

COMMENT ON FUNCTION get_cost_center_balance IS
'Returns the net balance for a cost center as of a specific date.';

-- ---------------------------------------------------------------------
-- 6. get_account_balance_by_type — Balance by account type
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_account_balance_by_type(
    p_account_type VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
    WHERE coa.account_type = p_account_type
      AND je.status = 'POSTED'
      AND je.journal_date <= p_as_of_date;
$$;

COMMENT ON FUNCTION get_account_balance_by_type IS
'Returns the net balance for all accounts of a specific type '
'(ASSET, LIABILITY, EQUITY, REVENUE, EXPENSE) as of a date.';

-- ---------------------------------------------------------------------
-- 7. get_trial_balance — Full trial balance for an authority
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_trial_balance(
    p_authority_code VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    account_code VARCHAR,
    account_name VARCHAR,
    account_type VARCHAR,
    account_class VARCHAR,
    normal_balance VARCHAR,
    total_debit NUMERIC,
    total_credit NUMERIC,
    net_balance NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT
        coa.account_code,
        coa.account_name,
        coa.account_type,
        coa.account_class,
        coa.normal_balance,
        SUM(jl.debit) AS total_debit,
        SUM(jl.credit) AS total_credit,
        SUM(jl.debit - jl.credit) AS net_balance
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
    WHERE je.authority_code = p_authority_code
      AND je.status = 'POSTED'
      AND je.journal_date <= p_as_of_date
    GROUP BY
        coa.account_code, coa.account_name, coa.account_type,
        coa.account_class, coa.normal_balance
    HAVING SUM(jl.debit) != 0 OR SUM(jl.credit) != 0
    ORDER BY coa.account_code;
$$;

COMMENT ON FUNCTION get_trial_balance IS
'Returns the full trial balance for an authority as of a date. '
'Only includes accounts with activity. Debits and credits are summed.';

-- ---------------------------------------------------------------------
-- 8. get_period_activity — Summary of a fiscal period
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_period_activity(p_period_id UUID)
RETURNS TABLE (
    journal_count BIGINT,
    total_debit NUMERIC,
    total_credit NUMERIC,
    total_transactions NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT
        COUNT(DISTINCT je.journal_id) AS journal_count,
        COALESCE(SUM(jl.debit), 0) AS total_debit,
        COALESCE(SUM(jl.credit), 0) AS total_credit,
        COALESCE(SUM(jl.debit), 0) AS total_transactions
    FROM journal_entry je
    LEFT JOIN journal_line jl ON je.journal_id = jl.journal_id
    WHERE je.period_id = p_period_id
      AND je.status = 'POSTED';
$$;

COMMENT ON FUNCTION get_period_activity IS
'Returns activity summary for a fiscal period: journal count, '
'total debits, total credits, and total transactions.';

-- ---------------------------------------------------------------------
-- 9. create_manual_journal — Convenience function to create + post
-- ---------------------------------------------------------------------
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
BEGIN
    -- Find period
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_journal_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No fiscal period found for date % and authority %',
            p_journal_date, p_authority_code;
    END IF;

    -- Generate journal number
    SELECT 'JV-' || TO_CHAR(p_journal_date, 'YYYYMMDD') || '-' ||
           LPAD(COUNT(*) + 1, 5, '0')
    INTO v_journal_number
    FROM journal_entry
    WHERE authority_code = p_authority_code
      AND journal_date = p_journal_date;

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
        INSERT INTO journal_line (
            journal_id, line_number, account_id, fund_id, cost_center_id,
            debit, credit, description
        ) VALUES (
            v_journal_id,
            v_line_number,
            (SELECT account_id FROM chart_of_accounts WHERE account_code = v_line->>'account_code'),
            (SELECT fund_id FROM fund WHERE fund_code = v_line->>'fund_code'),
            (SELECT cost_center_id FROM cost_center WHERE cost_center_code = v_line->>'cost_center_code'),
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
'p_lines is a JSONB array like: '
'[{"account_code":"10100","fund_code":"1000","cost_center_code":"0200","debit":1000,"credit":0,"description":"..."}]';

-- ---------------------------------------------------------------------
-- 10. AUDIT LOG — Record function creation
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason, changed_by, record_hash)
VALUES (
    'GENERAL_LEDGER',
    gen_random_uuid(),
    'CREATE',
    jsonb_build_object(
        'action', 'create_functions',
        'functions', ARRAY[
            'post_journal',
            'reverse_journal',
            'get_account_balance',
            'get_fund_balance',
            'get_cost_center_balance',
            'get_account_balance_by_type',
            'get_trial_balance',
            'get_period_activity',
            'create_manual_journal'
        ],
        'migration', 'V61',
        'purpose', 'Operational layer for General Ledger'
    ),
    'GL operational functions — posting, reversing, querying',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256(('V61' || 'gl_functions' || NOW()::text)::bytea), 'hex')
);
