-- =====================================================================
-- V92__ap_structural_fixes.sql
-- AP Structural Fixes:
--   1. ap_payment.cost_center_id — let payments carry their own cost center
--   2. reverse_ap_invoice_to_gl() — reverse GL when an invoice is cancelled
--   3. cancel_ap_invoice() — auto-call the reversal
--   4. record_ap_payment() — accept and store cost_center_id
--   5. post_ap_payment_to_gl() — use payment cost center, fallback to default
-- =====================================================================
-- Why this matters:
--   - Right now every AP payment lands in cost center 0200 (Finance).
--     Multi-department councils need to attribute payments correctly.
--   - Right now cancelling an AP invoice flips the sub-ledger status but
--     leaves the GL journal posted. AP and GL disagree — audit red flag.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Add cost_center_id to ap_payment
-- ---------------------------------------------------------------------
ALTER TABLE ap_payment
    ADD COLUMN IF NOT EXISTS cost_center_id UUID
        REFERENCES cost_center(cost_center_id);

CREATE INDEX IF NOT EXISTS idx_ap_payment_cost_center
    ON ap_payment(cost_center_id)
    WHERE cost_center_id IS NOT NULL;

COMMENT ON COLUMN ap_payment.cost_center_id IS
'Optional cost center for the payment. If NULL, GL posting defaults to '
'the Finance Department (0200) via get_default_cost_center().';

-- ---------------------------------------------------------------------
-- 2. Record a GL reversal for a posted AP invoice
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reverse_ap_invoice_to_gl(
    p_invoice_id UUID,
    p_reason TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
    v_original_je RECORD;
    v_reversal_journal_id UUID;
    v_journal_number VARCHAR;
    v_reversal_date DATE;
    v_period_id UUID;
    v_line RECORD;
    v_line_number INTEGER := 1;
BEGIN
    SELECT * INTO v_invoice FROM ap_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'AP Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.gl_journal_id IS NULL THEN
        -- Nothing to reverse — invoice never posted
        RETURN NULL;
    END IF;

    -- Check the original journal is still POSTED (not already reversed)
    SELECT * INTO v_original_je
    FROM journal_entry
    WHERE journal_id = v_invoice.gl_journal_id;

    IF v_original_je.status = 'REVERSED' THEN
        RAISE EXCEPTION 'AP Invoice GL journal is already reversed. Journal: %',
            v_original_je.journal_number;
    END IF;

    -- Use today as reversal date; find the current open period
    v_reversal_date := CURRENT_DATE;
    v_period_id := get_fiscal_period_for_date(v_invoice.authority_code, v_reversal_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period for reversal date % in authority %',
            v_reversal_date, v_invoice.authority_code;
    END IF;

    v_journal_number := 'AP-REV-' || v_invoice.invoice_number;

    -- Create reversal journal
    INSERT INTO journal_entry (
        authority_code, journal_number, journal_date, period_id,
        journal_type, source_module, source_id, description,
        reference, status, created_by
    ) VALUES (
        v_invoice.authority_code,
        v_journal_number,
        v_reversal_date,
        v_period_id,
        'ADJUSTMENT',
        'AP_INVOICE',
        v_invoice.invoice_id,
        'Reversal of AP Invoice ' || v_invoice.invoice_number ||
            ' — ' || COALESCE(p_reason, 'cancelled'),
        v_invoice.invoice_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_reversal_journal_id;

    -- Mirror every original line, swapping debit and credit
    FOR v_line IN
        SELECT * FROM journal_line
        WHERE journal_id = v_invoice.gl_journal_id
        ORDER BY line_number
    LOOP
        INSERT INTO journal_line (
            journal_id, line_number, account_id, fund_id, cost_center_id,
            debit, credit, description, reference
        ) VALUES (
            v_reversal_journal_id, v_line_number, v_line.account_id,
            v_line.fund_id, v_line.cost_center_id,
            v_line.credit,   -- swapped
            v_line.debit,    -- swapped
            'Reversal: ' || COALESCE(v_line.description, ''),
            v_invoice.invoice_number
        );
        v_line_number := v_line_number + 1;
    END LOOP;

    -- Post the reversal
    PERFORM post_journal(v_reversal_journal_id, p_user_id);

    -- Mark original journal as REVERSED (if the column exists)
    BEGIN
        UPDATE journal_entry
        SET status = 'REVERSED'
        WHERE journal_id = v_invoice.gl_journal_id;
    EXCEPTION WHEN check_violation THEN
        -- If 'REVERSED' is not a valid status, ignore
        NULL;
    END;

    RETURN v_reversal_journal_id;
END;
$$;

COMMENT ON FUNCTION reverse_ap_invoice_to_gl IS
'Posts a reversal journal for an AP invoice that was already posted to '
'GL. Debits AP control and credits the original expense accounts — the '
'mirror image of the approval posting. Returns the reversal journal_id, '
'or NULL if the invoice was never posted.';

-- ---------------------------------------------------------------------
-- 3. Rebuild cancel_ap_invoice to auto-reverse the GL
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cancel_ap_invoice(
    p_invoice_id UUID,
    p_reason TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
    v_reversal_journal_id UUID;
BEGIN
    SELECT * INTO v_invoice FROM ap_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'AP Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status = 'CANCELLED' THEN
        RAISE EXCEPTION 'AP Invoice is already cancelled';
    END IF;

    IF v_invoice.amount_paid > 0 THEN
        RAISE EXCEPTION 'Cannot cancel an AP invoice with payments. Balance: %, Paid: %',
            v_invoice.balance, v_invoice.amount_paid;
    END IF;

    -- Reverse the GL before flipping status, so we can still see gl_journal_id
    v_reversal_journal_id := reverse_ap_invoice_to_gl(
        p_invoice_id, p_reason, p_user_id
    );

    UPDATE ap_invoice
    SET status = 'CANCELLED',
        cancelled_at = NOW(),
        cancelled_by = p_user_id,
        cancellation_reason = p_reason,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE invoice_id = p_invoice_id;

    RETURN p_invoice_id;
END;
$$;

COMMENT ON FUNCTION cancel_ap_invoice IS
'Cancels an unpaid AP invoice. If the invoice was already posted to GL, '
'posts a reversing journal (debit AP control, credit expense) so the '
'GL stays in sync with the AP sub-ledger.';

-- ---------------------------------------------------------------------
-- 4. record_ap_payment — accept a cost_center_id
-- ---------------------------------------------------------------------
DROP FUNCTION IF EXISTS record_ap_payment(
    VARCHAR, UUID, DATE, NUMERIC, VARCHAR, VARCHAR, UUID, UUID, TEXT, UUID
);

CREATE OR REPLACE FUNCTION record_ap_payment(
    p_authority_code VARCHAR,
    p_vendor_id UUID,
    p_payment_date DATE,
    p_amount NUMERIC,
    p_payment_method VARCHAR,
    p_payment_reference VARCHAR,
    p_bank_account_id UUID,
    p_fund_id UUID,
    p_cost_center_id UUID,
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
        cost_center_id,
        period_id, notes, status, created_by
    ) VALUES (
        p_authority_code, v_payment_number, p_vendor_id, p_payment_date,
        p_amount, 0, p_amount,
        p_payment_method, p_payment_reference, p_bank_account_id, p_fund_id,
        p_cost_center_id,
        v_period_id, p_notes, 'POSTED', p_user_id
    ) RETURNING payment_id INTO v_payment_id;

    PERFORM post_ap_payment_to_gl(v_payment_id, p_user_id);

    RETURN v_payment_id;
END;
$$;

COMMENT ON FUNCTION record_ap_payment IS
'Records an AP payment AND posts to GL in one transaction
(Debit AP control, Credit Bank). Accepts an optional cost_center_id — '
'if NULL, GL posting defaults to Finance Department (0200).';

-- ---------------------------------------------------------------------
-- 5. Rebuild post_ap_payment_to_gl to prefer payment cost center
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
    v_cost_center_id UUID;
    v_journal_id UUID;
    v_journal_number VARCHAR;
BEGIN
    SELECT * INTO v_payment FROM ap_payment WHERE payment_id = p_payment_id;

    IF v_payment IS NULL THEN
        RAISE EXCEPTION 'AP Payment not found: %', p_payment_id;
    END IF;

    IF v_payment.gl_journal_id IS NOT NULL THEN
        RAISE EXCEPTION 'AP Payment already posted to GL. Journal: %',
            v_payment.gl_journal_id;
    END IF;

    IF v_payment.status != 'POSTED' THEN
        RAISE EXCEPTION 'Cannot post AP Payment in % status to GL',
            v_payment.status;
    END IF;

    v_bank_account_id := v_payment.bank_account_id;
    IF v_bank_account_id IS NULL THEN
        SELECT account_id INTO v_bank_account_id
        FROM chart_of_accounts WHERE account_code = '10200';
    END IF;

    v_fund_id := COALESCE(v_payment.fund_id, get_default_fund());
    IF v_fund_id IS NULL THEN
        RAISE EXCEPTION 'No fund available — General Fund (1000) not found';
    END IF;

    -- Prefer the payment's own cost center; fall back to default
    v_cost_center_id := COALESCE(v_payment.cost_center_id, get_default_cost_center());
    IF v_cost_center_id IS NULL THEN
        RAISE EXCEPTION 'No cost center available — Finance Department (0200) not found';
    END IF;

    v_ap_account_id := get_ap_control_account();

    v_journal_number := 'AP-PAY-' || v_payment.payment_number;

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
        'AP Payment ' || v_payment.payment_number || ' — ' ||
            COALESCE(v_payment.notes, ''),
        v_payment.payment_number,
        'DRAFT',
        p_user_id
    ) RETURNING journal_id INTO v_journal_id;

    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 1, v_ap_account_id,
        v_fund_id, v_cost_center_id,
        v_payment.amount, 0,
        'AP Payment ' || v_payment.payment_number,
        v_payment.payment_number
    );

    INSERT INTO journal_line (
        journal_id, line_number, account_id, fund_id, cost_center_id,
        debit, credit, description, reference
    ) VALUES (
        v_journal_id, 2, v_bank_account_id,
        v_fund_id, v_cost_center_id,
        0, v_payment.amount,
        'Payment via ' || v_payment.payment_method,
        v_payment.payment_number
    );

    PERFORM post_journal(v_journal_id, p_user_id);

    UPDATE ap_payment
    SET gl_journal_id = v_journal_id
    WHERE payment_id = p_payment_id;

    RETURN v_journal_id;
END;
$$;

COMMENT ON FUNCTION post_ap_payment_to_gl IS
'Posts an AP payment to the GL. Uses the payment''s own fund and cost '
'center where set; otherwise defaults to General Fund (1000) and '
'Finance Department (0200). Returns journal_id.';

-- ---------------------------------------------------------------------
-- 6. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AP_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'ap_structural_fixes',
        'migration', 'V92',
        'changes', ARRAY[
            'ap_payment.cost_center_id added',
            'reverse_ap_invoice_to_gl() created',
            'cancel_ap_invoice() now reverses GL',
            'record_ap_payment() accepts cost_center_id',
            'post_ap_payment_to_gl() prefers payment cost center'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
