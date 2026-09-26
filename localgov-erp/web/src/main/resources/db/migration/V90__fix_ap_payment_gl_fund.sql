-- =====================================================================
-- V90__fix_ap_payment_gl_fund.sql
-- Fix: AP payment GL posting requires fund_id
-- =====================================================================
-- The journal_line table requires fund_id (NOT NULL). AP payments can
-- be created without a fund (general payments). This fix defaults to
-- the General Fund (1000) when no fund is specified.
--
-- Also: The invoice side of post_ap_invoice_to_gl works correctly.
-- Only the payment side needs fixing.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helper: Get the default fund (General Fund)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_default_fund()
RETURNS UUID
LANGUAGE sql STABLE AS $$
    SELECT fund_id
    FROM fund
    WHERE fund_code = '1000'
    LIMIT 1;
$$;

COMMENT ON FUNCTION get_default_fund IS
'Returns the General Fund (1000). Used as default when a payment or '
'journal line does not specify a fund.';

-- ---------------------------------------------------------------------
-- Rebuild post_ap_payment_to_gl with default fund handling
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION post_ap_payment_to_gl(
    p_payment_id UUID,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_payment RECORD;
    v_ap_account_id UUID;
    v_bank_account_id UUID;
    v_fund_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
BEGIN
    -- Fetch payment
    SELECT * INTO v_payment FROM ap_payment WHERE payment_id = p_payment_id;

    IF v_payment IS NULL THEN
        RAISE EXCEPTION 'AP Payment not found: %', p_payment_id;
    END IF;

    IF v_payment.gl_journal_id IS NOT NULL THEN
        RAISE EXCEPTION 'AP Payment already posted to GL. Journal: %', v_payment.gl_journal_id;
    END IF;

    IF v_payment.status != 'POSTED' THEN
        RAISE EXCEPTION 'Cannot post AP Payment in % status to GL', v_payment.status;
    END IF;

    -- Determine bank account
    v_bank_account_id := v_payment.bank_account_id;

    IF v_bank_account_id IS NULL THEN
        SELECT account_id INTO v_bank_account_id
        FROM chart_of_accounts WHERE account_code = '10200';
    END IF;

    -- Determine fund: use payment's fund, or default to General Fund
    v_fund_id := COALESCE(v_payment.fund_id, get_default_fund());

    IF v_fund_id IS NULL THEN
        RAISE EXCEPTION 'No fund available — General Fund (1000) not found';
    END IF;

    -- Get AP control account
    v_ap_account_id := get_ap_control_account();

    -- Generate journal number
    v_journal_number := 'AP-PAY-' || v_payment.payment_number;

    -- Create journal entry
    INSERT INTO journal_entry (
        authority_code, journal_number, journal_date, period_id,
        journal_type, source_module, source_id, description,
        reference, status, created_by
    ) VALUES (
        v_payment.authority_code,
        v_journal_number,
        v_payment.payment_date,
        v_payment.period_id,
        'EXPENDITURE',
        'AP_PAYMENT',
        v_payment.payment_id,
        'AP Payment ' || v_payment.payment_number || ' — ' || COALESCE(v_payment.notes, ''),
        v_payment.payment_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    -- Debit: AP control account (liability decreases)
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 1, v_ap_account_id,
        v_fund_id, NULL,
        v_payment.amount, 0,
        'AP Payment ' || v_payment.payment_number,
        v_payment.payment_number
    );

    -- Credit: Bank account
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 2, v_bank_account_id,
        v_fund_id, NULL,
        0, v_payment.amount,
        'Payment via ' || v_payment.payment_method,
        v_payment.payment_number
    );

    -- Post the journal
    PERFORM post_journal(v_journal_id, p_user_id);

    -- Update payment with GL journal reference
    UPDATE ap_payment
    SET gl_journal_id = v_journal_id
    WHERE payment_id = p_payment_id;

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_ap_payment_to_gl IS
'Posts an AP payment to the General Ledger.
Debit: AP control account (20100).
Credit: Bank account.
Uses the payment''s fund, or defaults to General Fund (1000) if NULL.
Returns the GL journal_id.';

-- ---------------------------------------------------------------------
-- Also fix post_ap_invoice_to_gl in case a line has no fund
-- (defensive — should not happen since invoice requires fund_id)
-- ---------------------------------------------------------------------

-- ---------------------------------------------------------------------
-- Fix the AR post_receipt_to_gl similarly (same issue could occur)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION post_receipt_to_gl(
    p_receipt_id UUID,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_receipt RECORD;
    v_ar_account_id UUID;
    v_bank_account_id UUID;
    v_fund_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
BEGIN
    SELECT r.*, c.authority_code AS customer_authority
    INTO v_receipt
    FROM ar_receipt r
    JOIN ar_customer c ON r.customer_id = c.customer_id
    WHERE r.receipt_id = p_receipt_id;

    IF v_receipt IS NULL THEN
        RAISE EXCEPTION 'Receipt not found: %', p_receipt_id;
    END IF;

    IF v_receipt.gl_journal_id IS NOT NULL THEN
        RAISE EXCEPTION 'Receipt already posted to GL. Journal: %', v_receipt.gl_journal_id;
    END IF;

    v_bank_account_id := v_receipt.bank_account_id;

    IF v_bank_account_id IS NULL THEN
        SELECT account_id INTO v_bank_account_id
        FROM chart_of_accounts WHERE account_code = '10200';
    END IF;

    -- Determine fund: use receipt's fund, or default to General Fund
    v_fund_id := COALESCE(v_receipt.fund_id, get_default_fund());

    IF v_fund_id IS NULL THEN
        RAISE EXCEPTION 'No fund available — General Fund (1000) not found';
    END IF;

    v_ar_account_id := get_ar_control_account('OTHER');

    v_journal_number := 'AR-RCP-' || v_receipt.receipt_number;

    INSERT INTO journal_entry (
        authority_code, journal_number, journal_date, period_id,
        journal_type, source_module, source_id, description,
        reference, status, created_by
    ) VALUES (
        v_receipt.customer_authority,
        v_journal_number,
        v_receipt.receipt_date,
        v_receipt.period_id,
        'REVENUE',
        'AR_RECEIPT',
        v_receipt.receipt_id,
        'AR Receipt ' || v_receipt.receipt_number || ' — ' || COALESCE(v_receipt.notes, ''),
        v_receipt.receipt_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 1, v_bank_account_id,
        v_fund_id, NULL,
        v_receipt.amount, 0,
        'Payment received: ' || v_receipt.payment_method,
        v_receipt.receipt_number
    );

    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 2, v_ar_account_id,
        v_fund_id, NULL,
        0, v_receipt.amount,
        'AR Receipt ' || v_receipt.receipt_number,
        v_receipt.receipt_number
    );

    PERFORM post_journal(v_journal_id, p_user_id);

    UPDATE ar_receipt
    SET gl_journal_id = v_journal_id
    WHERE receipt_id = p_receipt_id;

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_receipt_to_gl IS
'Posts an AR receipt to the General Ledger. Uses the receipt''s fund, '
'or defaults to General Fund (1000) if NULL. Fixed in V90.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AP_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_ap_payment_gl_fund',
        'migration', 'V90',
        'bug', 'fund_id NOT NULL constraint violated when payment fund is NULL',
        'fix', 'Default to General Fund (1000) when payment fund is NULL',
        'functions_updated', ARRAY[
            'post_ap_payment_to_gl',
            'post_receipt_to_gl'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
