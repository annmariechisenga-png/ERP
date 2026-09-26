-- =====================================================================
-- V89__ap_gl_integration.sql
-- Accounts Payable — GL Integration
-- =====================================================================
-- This migration wires AP transactions into the General Ledger.
--
-- When an AP invoice is APPROVED:
--   Debit:  5xxxx Expense Account (from line)       amount
--   Credit: 20100 Accounts Payable - Vendors        amount
--
-- When an AP payment is recorded:
--   Debit:  20100 Accounts Payable - Vendors        amount
--   Credit: 102xx Bank Account                       amount
--
-- When an AP invoice is written off:
--   Debit:  20100 Accounts Payable - Vendors        amount
--   Credit: 4xxxx Other Income                       amount
--
-- The integration uses the existing GL functions (post_journal).
-- It does NOT duplicate double-entry validation.
--
-- Business functions are updated to call posting functions:
--   - approve_ap_invoice → post_ap_invoice_to_gl
--   - record_ap_payment → post_ap_payment_to_gl
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helper: Get the AP control account
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ap_control_account()
RETURNS UUID
LANGUAGE sql STABLE AS $$
    SELECT account_id
    FROM chart_of_accounts
    WHERE account_code = '20100';
$$;

COMMENT ON FUNCTION get_ap_control_account IS
'Returns the AP control account (20100 — Accounts Payable - Vendors). '
'All AP invoices and payments post to this control account.';

-- ---------------------------------------------------------------------
-- Function: post_ap_invoice_to_gl
-- Posts an approved AP invoice to the GL
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION post_ap_invoice_to_gl(
    p_invoice_id UUID,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
    v_ap_account_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
    v_line RECORD;
    v_line_number INTEGER := 1;
BEGIN
    -- Fetch invoice
    SELECT * INTO v_invoice FROM ap_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'AP Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.gl_journal_id IS NOT NULL THEN
        RAISE EXCEPTION 'AP Invoice already posted to GL. Journal: %', v_invoice.gl_journal_id;
    END IF;

    IF v_invoice.status NOT IN ('OUTSTANDING', 'PARTIAL', 'PAID') THEN
        RAISE EXCEPTION 'Cannot post AP Invoice in % status to GL', v_invoice.status;
    END IF;

    -- Get AP control account
    v_ap_account_id := get_ap_control_account();

    IF v_ap_account_id IS NULL THEN
        RAISE EXCEPTION 'AP control account (20100) not found';
    END IF;

    -- Generate journal number
    v_journal_number := 'AP-INV-' || v_invoice.invoice_number;

    -- Create journal entry
    INSERT INTO journal_entry (
        authority_code, journal_number, journal_date, period_id,
        journal_type, source_module, source_id, description,
        reference, status, created_by
    ) VALUES (
        v_invoice.authority_code,
        v_journal_number,
        v_invoice.invoice_date,
        v_invoice.period_id,
        'EXPENDITURE',
        'AP_INVOICE',
        v_invoice.invoice_id,
        'AP Invoice ' || v_invoice.invoice_number || ' — ' || COALESCE(v_invoice.description, ''),
        v_invoice.invoice_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    -- Credit: AP control account (liability increases)
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, v_line_number, v_ap_account_id,
        v_invoice.fund_id, v_invoice.cost_center_id,
        0, v_invoice.total_amount,
        'AP Invoice ' || v_invoice.invoice_number,
        v_invoice.invoice_number
    );
    v_line_number := v_line_number + 1;

    -- Debit: Expense accounts (one line per invoice line)
    FOR v_line IN
        SELECT * FROM ap_invoice_line
        WHERE invoice_id = p_invoice_id
        ORDER BY line_number
    LOOP
        INSERT INTO journal_line (
            journal_id, line_number, account_id, fund_id, cost_center_id,
            debit, credit, description, reference
        ) VALUES (
            v_journal_id, v_line_number, v_line.account_id,
            v_invoice.fund_id, v_invoice.cost_center_id,
            v_line.line_total + v_line.tax_amount - v_line.withholding_tax, 0,
            v_line.description,
            v_invoice.invoice_number
        );
        v_line_number := v_line_number + 1;
    END LOOP;

    -- Post the journal
    PERFORM post_journal(v_journal_id, p_user_id);

    -- Update invoice with GL journal reference
    UPDATE ap_invoice
    SET gl_journal_id = v_journal_id
    WHERE invoice_id = p_invoice_id;

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_ap_invoice_to_gl IS
'Posts an approved AP invoice to the General Ledger.
Debit: Expense account(s) from invoice lines.
Credit: AP control account (20100).
Returns the GL journal_id.
Example:
  SELECT post_ap_invoice_to_gl(
      p_invoice_id := ''...uuid...''::UUID,
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: post_ap_payment_to_gl
-- Posts an AP payment to the GL
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
        v_payment.fund_id, NULL,
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
        v_payment.fund_id, NULL,
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
Returns the GL journal_id.
Example:
  SELECT post_ap_payment_to_gl(
      p_payment_id := ''...uuid...''::UUID,
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: post_ap_writeoff_to_gl
-- Posts an AP invoice write-off to the GL
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION post_ap_writeoff_to_gl(
    p_invoice_id UUID,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
    v_ap_account_id UUID;
    v_other_income_account_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
BEGIN
    -- Fetch invoice
    SELECT * INTO v_invoice FROM ap_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'AP Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status != 'CANCELLED' THEN
        RAISE EXCEPTION 'AP Invoice is not cancelled. Status: %', v_invoice.status;
    END IF;

    IF v_invoice.balance <= 0 THEN
        RAISE EXCEPTION 'AP Invoice has no balance to write off';
    END IF;

    -- Get AP control account
    v_ap_account_id := get_ap_control_account();

    -- Get Other Income account (for the gain)
    SELECT account_id INTO v_other_income_account_id
    FROM chart_of_accounts WHERE account_code = '41400';

    IF v_other_income_account_id IS NULL THEN
        RAISE EXCEPTION 'Other Income account (41400) not found';
    END IF;

    -- Generate journal number
    v_journal_number := 'AP-WO-' || v_invoice.invoice_number;

    -- Create journal entry
    INSERT INTO journal_entry (
        authority_code, journal_number, journal_date, period_id,
        journal_type, source_module, source_id, description,
        reference, status, created_by
    ) VALUES (
        v_invoice.authority_code,
        v_journal_number,
        CURRENT_DATE,
        get_fiscal_period_for_date(v_invoice.authority_code, CURRENT_DATE),
        'ADJUSTMENT',
        'AP_INVOICE',
        v_invoice.invoice_id,
        'Write-off of AP Invoice ' || v_invoice.invoice_number,
        v_invoice.invoice_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    -- Debit: AP control account (liability decreases)
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 1, v_ap_account_id,
        v_invoice.fund_id, v_invoice.cost_center_id,
        v_invoice.balance, 0,
        'Write-off of ' || v_invoice.invoice_number,
        v_invoice.invoice_number
    );

    -- Credit: Other Income account (gain)
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 2, v_other_income_account_id,
        v_invoice.fund_id, v_invoice.cost_center_id,
        0, v_invoice.balance,
        'Write-off gain',
        v_invoice.invoice_number
    );

    -- Post the journal
    PERFORM post_journal(v_journal_id, p_user_id);

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_ap_writeoff_to_gl IS
'Posts an AP invoice write-off to the General Ledger.
Debit: AP control account (20100).
Credit: Other Income account (41400).
Returns the GL journal_id.';

-- ---------------------------------------------------------------------
-- Update approve_ap_invoice to call post_ap_invoice_to_gl
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION approve_ap_invoice(
    p_invoice_id UUID,
    p_user_id UUID
) RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
BEGIN
    SELECT * INTO v_invoice FROM ap_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'AP Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status = 'APPROVED' OR v_invoice.status = 'OUTSTANDING' THEN
        RAISE EXCEPTION 'AP Invoice already approved';
    END IF;

    IF v_invoice.status NOT IN ('DRAFT', 'PENDING_APPROVAL') THEN
        RAISE EXCEPTION 'Cannot approve an AP invoice in % status', v_invoice.status;
    END IF;

    -- Approve and move to OUTSTANDING (ready for payment)
    UPDATE ap_invoice
    SET status = 'OUTSTANDING',
        approved_at = NOW(),
        approved_by = p_user_id,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE invoice_id = p_invoice_id;

    -- Post to GL automatically
    PERFORM post_ap_invoice_to_gl(p_invoice_id, p_user_id);

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION approve_ap_invoice IS
'Approves an AP invoice. Moves status from DRAFT/PENDING_APPROVAL to '
'OUTSTANDING and auto-posts to GL (Debit Expense, Credit AP control).';

-- ---------------------------------------------------------------------
-- Update record_ap_payment to call post_ap_payment_to_gl
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION record_ap_payment(
    p_authority_code VARCHAR,
    p_vendor_id UUID,
    p_payment_date DATE,
    p_amount NUMERIC,
    p_payment_method VARCHAR,
    p_payment_reference VARCHAR,
    p_bank_account_id UUID,
    p_fund_id UUID,
    p_notes TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_payment_id UUID;
    v_payment_number VARCHAR;
    v_period_id UUID;
BEGIN
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_payment_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period for date % in authority %',
            p_payment_date, p_authority_code;
    END IF;

    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Payment amount must be positive. Got: %', p_amount;
    END IF;

    v_payment_number := generate_ap_payment_number(p_authority_code, p_payment_date);

    INSERT INTO ap_payment (
        authority_code, payment_number, vendor_id, payment_date,
        amount, amount_allocated, amount_unallocated,
        payment_method, payment_reference, bank_account_id, fund_id,
        period_id, notes, status, created_by
    ) VALUES (
        p_authority_code, v_payment_number, p_vendor_id, p_payment_date,
        p_amount, 0, p_amount,
        p_payment_method, p_payment_reference, p_bank_account_id, p_fund_id,
        v_period_id, p_notes, 'POSTED', p_user_id
    ) RETURNING payment_id INTO v_payment_id;

    -- Post to GL automatically
    PERFORM post_ap_payment_to_gl(v_payment_id, p_user_id);

    RETURN v_payment_id;
END;
$$;

COMMENT ON FUNCTION record_ap_payment IS
'Records an AP payment AND posts to GL in one transaction
(Debit AP control, Credit Bank).';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AP_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'ap_gl_integration',
        'migration', 'V89',
        'purpose', 'AP → GL integration — invoices and payments auto-post',
        'functions_created', ARRAY[
            'get_ap_control_account',
            'post_ap_invoice_to_gl',
            'post_ap_payment_to_gl',
            'post_ap_writeoff_to_gl'
        ],
        'functions_updated', ARRAY[
            'approve_ap_invoice',
            'record_ap_payment'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
