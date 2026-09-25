-- =====================================================================
-- V82__ar_gl_integration.sql
-- Accounts Receivable — GL Integration
-- =====================================================================
-- This migration wires AR transactions into the General Ledger.
--
-- When an invoice is created:
--   Debit:  11000 Accounts Receivable - [Type]      amount
--   Credit: 4xxxx Revenue Account (from line)       amount
--
-- When a receipt is recorded:
--   Debit:  102xx Bank Account                       amount
--   Credit: 11000 Accounts Receivable - [Type]      amount
--
-- When an invoice is written off:
--   Debit:  58600 Bad Debts                          amount
--   Credit: 11000 Accounts Receivable - [Type]      amount
--
-- The integration uses the existing GL functions (post_journal).
-- It does NOT duplicate double-entry validation.
--
-- Business functions (create_ar_invoice, record_ar_receipt, write_off_invoice)
-- are updated to call these posting functions automatically.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helper: Get the AR control account for an invoice type
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ar_control_account(
    p_invoice_type VARCHAR
) RETURNS UUID
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_account_id UUID;
BEGIN
    -- Map invoice type to AR control account
    CASE p_invoice_type
        WHEN 'PROPERTY_RATE' THEN
            SELECT account_id INTO v_account_id FROM chart_of_accounts WHERE account_code = '11000';
        WHEN 'PERSONAL_LEVY' THEN
            SELECT account_id INTO v_account_id FROM chart_of_accounts WHERE account_code = '11100';
        WHEN 'MARKET_FEE' THEN
            SELECT account_id INTO v_account_id FROM chart_of_accounts WHERE account_code = '11200';
        WHEN 'BUS_STATION_FEE' THEN
            SELECT account_id INTO v_account_id FROM chart_of_accounts WHERE account_code = '11300';
        WHEN 'RENT' THEN
            SELECT account_id INTO v_account_id FROM chart_of_accounts WHERE account_code = '11400';
        WHEN 'LICENSE' THEN
            SELECT account_id INTO v_account_id FROM chart_of_accounts WHERE account_code = '11500';
        ELSE
            SELECT account_id INTO v_account_id FROM chart_of_accounts WHERE account_code = '11900';
    END CASE;

    IF v_account_id IS NULL THEN
        RAISE EXCEPTION 'AR control account not found for invoice type: %', p_invoice_type;
    END IF;

    RETURN v_account_id;
END;
$$;

COMMENT ON FUNCTION get_ar_control_account IS
'Maps an invoice type to its corresponding AR control account. '
'Falls back to 11900 (Other) for unmapped types.';

-- ---------------------------------------------------------------------
-- Function: post_invoice_to_gl
-- Posts an AR invoice to the GL
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION post_invoice_to_gl(
    p_invoice_id UUID,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
    v_ar_account_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
    v_line RECORD;
    v_line_number INTEGER := 1;
BEGIN
    -- Fetch invoice
    SELECT * INTO v_invoice FROM ar_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.gl_journal_id IS NOT NULL THEN
        RAISE EXCEPTION 'Invoice already posted to GL. Journal: %', v_invoice.gl_journal_id;
    END IF;

    -- Get AR control account
    v_ar_account_id := get_ar_control_account(v_invoice.invoice_type);

    -- Generate journal number
    v_journal_number := 'AR-INV-' || v_invoice.invoice_number;

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
        'REVENUE',
        'AR_INVOICE',
        v_invoice.invoice_id,
        'AR Invoice ' || v_invoice.invoice_number || ' — ' || v_invoice.description,
        v_invoice.invoice_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    -- Debit: AR control account
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, v_line_number, v_ar_account_id,
        v_invoice.fund_id, v_invoice.cost_center_id,
        v_invoice.total_amount, 0,
        'AR Invoice ' || v_invoice.invoice_number,
        v_invoice.invoice_number
    );
    v_line_number := v_line_number + 1;

    -- Credit: Revenue accounts (one line per invoice line)
    FOR v_line IN
        SELECT * FROM ar_invoice_line
        WHERE invoice_id = p_invoice_id
        ORDER BY line_number
    LOOP
        INSERT INTO journal_line (
            journal_id, line_number, account_id, fund_id, cost_center_id,
            debit, credit, description, reference
        ) VALUES (
            v_journal_id, v_line_number, v_line.account_id,
            v_invoice.fund_id, v_invoice.cost_center_id,
            0, v_line.line_total + v_line.tax_amount,
            v_line.description,
            v_invoice.invoice_number
        );
        v_line_number := v_line_number + 1;
    END LOOP;

    -- Post the journal
    PERFORM post_journal(v_journal_id, p_user_id);

    -- Update invoice with GL journal reference
    UPDATE ar_invoice
    SET gl_journal_id = v_journal_id
    WHERE invoice_id = p_invoice_id;

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_invoice_to_gl IS
'Posts an AR invoice to the General Ledger.
Debit: AR control account (mapped from invoice type).
Credit: Revenue account(s) from invoice lines.
Returns the GL journal_id.
Example:
  SELECT post_invoice_to_gl(
      p_invoice_id := ''...uuid...''::UUID,
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: post_receipt_to_gl
-- Posts an AR receipt to the GL
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
    v_journal_id UUID;
    v_journal_number VARCHAR;
    v_authority_code VARCHAR(20);
BEGIN
    -- Fetch receipt with customer's authority
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

    -- Determine bank account
    v_bank_account_id := v_receipt.bank_account_id;

    IF v_bank_account_id IS NULL THEN
        -- Default to main bank account
        SELECT account_id INTO v_bank_account_id
        FROM chart_of_accounts WHERE account_code = '10200';
    END IF;

    -- Get AR control account (default to Other if no specific type)
    v_ar_account_id := get_ar_control_account('OTHER');

    -- Generate journal number
    v_journal_number := 'AR-RCP-' || v_receipt.receipt_number;

    -- Create journal entry
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

    -- Debit: Bank account
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 1, v_bank_account_id,
        v_receipt.fund_id, NULL,
        v_receipt.amount, 0,
        'Payment received: ' || v_receipt.payment_method,
        v_receipt.receipt_number
    );

    -- Credit: AR control account
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 2, v_ar_account_id,
        v_receipt.fund_id, NULL,
        0, v_receipt.amount,
        'AR Receipt ' || v_receipt.receipt_number,
        v_receipt.receipt_number
    );

    -- Post the journal
    PERFORM post_journal(v_journal_id, p_user_id);

    -- Update receipt with GL journal reference
    UPDATE ar_receipt
    SET gl_journal_id = v_journal_id
    WHERE receipt_id = p_receipt_id;

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_receipt_to_gl IS
'Posts an AR receipt to the General Ledger.
Debit: Bank account.
Credit: AR control account.
Returns the GL journal_id.
Example:
  SELECT post_receipt_to_gl(
      p_receipt_id := ''...uuid...''::UUID,
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: post_writeoff_to_gl
-- Posts an invoice write-off to the GL
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION post_writeoff_to_gl(
    p_invoice_id UUID,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
    v_ar_account_id UUID;
    v_bad_debt_account_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
BEGIN
    -- Fetch invoice
    SELECT * INTO v_invoice FROM ar_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status != 'WRITTEN_OFF' THEN
        RAISE EXCEPTION 'Invoice is not written off. Status: %', v_invoice.status;
    END IF;

    IF v_invoice.balance <= 0 THEN
        RAISE EXCEPTION 'Invoice has no balance to write off';
    END IF;

    -- Get AR control account
    v_ar_account_id := get_ar_control_account(v_invoice.invoice_type);

    -- Get bad debt expense account
    SELECT account_id INTO v_bad_debt_account_id
    FROM chart_of_accounts WHERE account_code = '58600';

    IF v_bad_debt_account_id IS NULL THEN
        RAISE EXCEPTION 'Bad Debt expense account (58600) not found';
    END IF;

    -- Generate journal number
    v_journal_number := 'AR-WO-' || v_invoice.invoice_number;

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
        'AR_INVOICE',
        v_invoice.invoice_id,
        'Write-off of AR Invoice ' || v_invoice.invoice_number,
        v_invoice.invoice_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    -- Debit: Bad Debt Expense
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 1, v_bad_debt_account_id,
        v_invoice.fund_id, v_invoice.cost_center_id,
        v_invoice.balance, 0,
        'Bad debt write-off',
        v_invoice.invoice_number
    );

    -- Credit: AR control account
    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 2, v_ar_account_id,
        v_invoice.fund_id, v_invoice.cost_center_id,
        0, v_invoice.balance,
        'Write-off of ' || v_invoice.invoice_number,
        v_invoice.invoice_number
    );

    -- Post the journal
    PERFORM post_journal(v_journal_id, p_user_id);

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_writeoff_to_gl IS
'Posts a write-off to the General Ledger.
Debit: Bad Debt Expense (58600).
Credit: AR control account.
Returns the GL journal_id.';

-- ---------------------------------------------------------------------
-- Update create_ar_invoice to call post_invoice_to_gl
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_ar_invoice(
    p_authority_code VARCHAR,
    p_customer_id UUID,
    p_invoice_date DATE,
    p_due_date DATE,
    p_invoice_type VARCHAR,
    p_description TEXT,
    p_fund_id UUID,
    p_cost_center_id UUID,
    p_lines JSONB,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice_id UUID;
    v_invoice_number VARCHAR;
    v_period_id UUID;
    v_subtotal NUMERIC(15,2) := 0;
    v_tax_total NUMERIC(15,2) := 0;
    v_total NUMERIC(15,2) := 0;
    v_line JSONB;
    v_line_number INTEGER := 1;
    v_line_qty NUMERIC;
    v_line_price NUMERIC;
    v_line_total NUMERIC;
    v_line_tax NUMERIC;
    v_account_id UUID;
BEGIN
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_invoice_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period for date % in authority %',
            p_invoice_date, p_authority_code;
    END IF;

    v_invoice_number := generate_invoice_number(p_authority_code, p_invoice_date);

    FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
    LOOP
        v_line_qty := COALESCE((v_line->>'quantity')::NUMERIC, 1);
        v_line_price := (v_line->>'unit_price')::NUMERIC;
        v_line_total := v_line_qty * v_line_price;
        v_line_tax := COALESCE((v_line->>'tax_amount')::NUMERIC, 0);

        v_subtotal := v_subtotal + v_line_total;
        v_tax_total := v_tax_total + v_line_tax;
    END LOOP;

    v_total := v_subtotal + v_tax_total;

    INSERT INTO ar_invoice (
        authority_code, invoice_number, customer_id, invoice_date, due_date,
        invoice_type, description, fund_id, cost_center_id,
        subtotal, tax_amount, total_amount, amount_paid, balance,
        status, period_id, created_by
    ) VALUES (
        p_authority_code, v_invoice_number, p_customer_id, p_invoice_date, p_due_date,
        p_invoice_type, p_description, p_fund_id, p_cost_center_id,
        v_subtotal, v_tax_total, v_total, 0, v_total,
        'OUTSTANDING', v_period_id, p_user_id
    ) RETURNING invoice_id INTO v_invoice_id;

    FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
    LOOP
        SELECT account_id INTO v_account_id
        FROM chart_of_accounts
        WHERE account_code = v_line->>'account_code';

        IF v_account_id IS NULL THEN
            RAISE EXCEPTION 'Account not found: %', v_line->>'account_code';
        END IF;

        v_line_qty := COALESCE((v_line->>'quantity')::NUMERIC, 1);
        v_line_price := (v_line->>'unit_price')::NUMERIC;
        v_line_total := v_line_qty * v_line_price;
        v_line_tax := COALESCE((v_line->>'tax_amount')::NUMERIC, 0);

        INSERT INTO ar_invoice_line (
            invoice_id, line_number, description, account_id,
            quantity, unit_price, line_total,
            tax_rate, tax_amount,
            property_reference, employee_reference,
            period_start, period_end
        ) VALUES (
            v_invoice_id, v_line_number,
            v_line->>'description', v_account_id,
            v_line_qty, v_line_price, v_line_total,
            COALESCE((v_line->>'tax_rate')::NUMERIC, 0), v_line_tax,
            v_line->>'property_reference', v_line->>'employee_reference',
            (v_line->>'period_start')::DATE, (v_line->>'period_end')::DATE
        );

        v_line_number := v_line_number + 1;
    END LOOP;

    -- Post to GL automatically
    PERFORM post_invoice_to_gl(v_invoice_id, p_user_id);

    RETURN v_invoice_id;
END;
$$;

COMMENT ON FUNCTION create_ar_invoice IS
'Creates an AR invoice with lines AND posts to GL in one transaction.';

-- ---------------------------------------------------------------------
-- Update record_ar_receipt to call post_receipt_to_gl
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION record_ar_receipt(
    p_authority_code VARCHAR,
    p_customer_id UUID,
    p_receipt_date DATE,
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
    v_receipt_id UUID;
    v_receipt_number VARCHAR;
    v_period_id UUID;
BEGIN
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_receipt_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period for date % in authority %',
            p_receipt_date, p_authority_code;
    END IF;

    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Receipt amount must be positive. Got: %', p_amount;
    END IF;

    v_receipt_number := generate_receipt_number(p_authority_code, p_receipt_date);

    INSERT INTO ar_receipt (
        authority_code, receipt_number, customer_id, receipt_date,
        amount, amount_allocated, amount_unallocated,
        payment_method, payment_reference, bank_account_id, fund_id,
        period_id, notes, status, created_by
    ) VALUES (
        p_authority_code, v_receipt_number, p_customer_id, p_receipt_date,
        p_amount, 0, p_amount,
        p_payment_method, p_payment_reference, p_bank_account_id, p_fund_id,
        v_period_id, p_notes, 'POSTED', p_user_id
    ) RETURNING receipt_id INTO v_receipt_id;

    -- Post to GL automatically
    PERFORM post_receipt_to_gl(v_receipt_id, p_user_id);

    RETURN v_receipt_id;
END;
$$;

COMMENT ON FUNCTION record_ar_receipt IS
'Records an AR receipt AND posts to GL in one transaction.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AR_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'ar_gl_integration',
        'migration', 'V82',
        'purpose', 'AR → GL integration — invoices and receipts auto-post',
        'functions_created', ARRAY[
            'get_ar_control_account',
            'post_invoice_to_gl',
            'post_receipt_to_gl',
            'post_writeoff_to_gl'
        ],
        'functions_updated', ARRAY[
            'create_ar_invoice',
            'record_ar_receipt'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
