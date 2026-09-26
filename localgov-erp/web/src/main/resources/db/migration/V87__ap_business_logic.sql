-- =====================================================================
-- V87__ap_business_logic.sql
-- Accounts Payable Business Logic Functions
-- =====================================================================
-- These functions encapsulate the business logic of AP operations:
--   - Generate unique invoice/payment numbers
--   - Create invoices with lines (starting in DRAFT/PENDING_APPROVAL)
--   - Approve invoices (DRAFT → PENDING_APPROVAL → APPROVED → OUTSTANDING)
--   - Record payments
--   - Allocate payments to invoices
--   - Cancel invoices
--   - Dispute invoices
--
-- All functions:
--   - Are transactional
--   - Auto-log via triggers (no explicit log_audit_event calls)
--   - Update invoice balances
--   - Enforce approval workflow
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helper: Generate next AP invoice number
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_ap_invoice_number(
    p_authority_code VARCHAR,
    p_invoice_date DATE
) RETURNS VARCHAR
LANGUAGE plpgsql AS $$
DECLARE
    v_count BIGINT;
    v_number VARCHAR(50);
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ap_invoice
    WHERE authority_code = p_authority_code
      AND invoice_date = p_invoice_date;

    v_number := 'AP-' || TO_CHAR(p_invoice_date, 'YYYYMMDD') || '-' ||
                LPAD((v_count + 1)::TEXT, 5, '0');

    RETURN v_number;
END;
$$;

COMMENT ON FUNCTION generate_ap_invoice_number IS
'Generates a unique AP invoice number in format AP-YYYYMMDD-NNNNN.';

-- ---------------------------------------------------------------------
-- Helper: Generate next AP payment number
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_ap_payment_number(
    p_authority_code VARCHAR,
    p_payment_date DATE
) RETURNS VARCHAR
LANGUAGE plpgsql AS $$
DECLARE
    v_count BIGINT;
    v_number VARCHAR(50);
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ap_payment
    WHERE authority_code = p_authority_code
      AND payment_date = p_payment_date;

    v_number := 'PAY-' || TO_CHAR(p_payment_date, 'YYYYMMDD') || '-' ||
                LPAD((v_count + 1)::TEXT, 5, '0');

    RETURN v_number;
END;
$$;

COMMENT ON FUNCTION generate_ap_payment_number IS
'Generates a unique AP payment number in format PAY-YYYYMMDD-NNNNN.';

-- ---------------------------------------------------------------------
-- Function: create_ap_invoice
-- Creates an AP invoice with lines in DRAFT status
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_ap_invoice(
    p_authority_code VARCHAR,
    p_vendor_id UUID,
    p_vendor_invoice_number VARCHAR,
    p_invoice_date DATE,
    p_received_date DATE,
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
    v_wht_total NUMERIC(15,2) := 0;
    v_total NUMERIC(15,2) := 0;
    v_line JSONB;
    v_line_number INTEGER := 1;
    v_line_qty NUMERIC;
    v_line_price NUMERIC;
    v_line_total NUMERIC;
    v_line_tax NUMERIC;
    v_line_wht_rate NUMERIC;
    v_line_wht NUMERIC;
    v_account_id UUID;
BEGIN
    -- Find fiscal period
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_invoice_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period for date % in authority %',
            p_invoice_date, p_authority_code;
    END IF;

    -- Generate AP invoice number
    v_invoice_number := generate_ap_invoice_number(p_authority_code, p_invoice_date);

    -- Calculate totals from lines
    FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
    LOOP
        v_line_qty := COALESCE((v_line->>'quantity')::NUMERIC, 1);
        v_line_price := (v_line->>'unit_price')::NUMERIC;
        v_line_total := v_line_qty * v_line_price;
        v_line_tax := COALESCE((v_line->>'tax_amount')::NUMERIC, 0);
        v_line_wht := COALESCE((v_line->>'withholding_tax')::NUMERIC, 0);

        v_subtotal := v_subtotal + v_line_total;
        v_tax_total := v_tax_total + v_line_tax;
        v_wht_total := v_wht_total + v_line_wht;
    END LOOP;

    v_total := v_subtotal + v_tax_total - v_wht_total;

    -- Create invoice in DRAFT status
    INSERT INTO ap_invoice (
        authority_code, invoice_number, vendor_invoice_number, vendor_id,
        invoice_date, received_date, due_date,
        invoice_type, description, fund_id, cost_center_id,
        subtotal, tax_amount, withholding_tax, total_amount,
        amount_paid, balance, status, period_id, created_by
    ) VALUES (
        p_authority_code, v_invoice_number, p_vendor_invoice_number, p_vendor_id,
        p_invoice_date, p_received_date, p_due_date,
        p_invoice_type, p_description, p_fund_id, p_cost_center_id,
        v_subtotal, v_tax_total, v_wht_total, v_total,
        0, v_total, 'DRAFT', v_period_id, p_user_id
    ) RETURNING invoice_id INTO v_invoice_id;

    -- Create invoice lines
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
        v_line_wht_rate := COALESCE((v_line->>'withholding_tax_rate')::NUMERIC, 0);
        v_line_wht := COALESCE((v_line->>'withholding_tax')::NUMERIC, 0);

        INSERT INTO ap_invoice_line (
            invoice_id, line_number, description, account_id,
            quantity, unit_price, line_total,
            tax_rate, tax_amount,
            withholding_tax_rate, withholding_tax,
            reference, purchase_order_id, goods_received_note_id
        ) VALUES (
            v_invoice_id, v_line_number,
            v_line->>'description', v_account_id,
            v_line_qty, v_line_price, v_line_total,
            COALESCE((v_line->>'tax_rate')::NUMERIC, 0), v_line_tax,
            v_line_wht_rate, v_line_wht,
            v_line->>'reference',
            NULLIF(v_line->>'purchase_order_id', '')::UUID,
            NULLIF(v_line->>'goods_received_note_id', '')::UUID
        );

        v_line_number := v_line_number + 1;
    END LOOP;

    RETURN v_invoice_id;
END;
$$;

COMMENT ON FUNCTION create_ap_invoice IS
'Creates an AP invoice with lines in DRAFT status. Validates period, '
'generates invoice number, calculates totals, creates lines.
Auto-audit trigger handles logging.
Example:
  SELECT create_ap_invoice(
      p_authority_code := ''CHILANGA'',
      p_vendor_id := ''...uuid...''::UUID,
      p_vendor_invoice_number := ''INV-VENDOR-001'',
      p_invoice_date := CURRENT_DATE,
      p_received_date := CURRENT_DATE,
      p_due_date := (CURRENT_DATE + INTERVAL ''30 days'')::DATE,
      p_invoice_type := ''GOODS'',
      p_description := ''Office supplies'',
      p_fund_id := (SELECT fund_id FROM fund WHERE fund_code = ''1000''),
      p_cost_center_id := (SELECT cost_center_id FROM cost_center WHERE cost_center_code = ''0200''),
      p_lines := ''[
          {"description": "A4 Paper", "account_code": "52000", "quantity": 10, "unit_price": 50.00}
      ]''::JSONB,
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: approve_ap_invoice
-- Moves an AP invoice through the approval workflow
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

    IF v_invoice.status = 'APPROVED' THEN
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

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION approve_ap_invoice IS
'Approves an AP invoice. Moves status from DRAFT/PENDING_APPROVAL to '
'OUTSTANDING (ready for payment). Auto-audit trigger logs the change.';

-- ---------------------------------------------------------------------
-- Function: record_ap_payment
-- Records a payment made to a vendor
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

    RETURN v_payment_id;
END;
$$;

COMMENT ON FUNCTION record_ap_payment IS
'Records a payment made to a vendor. Validates period, generates '
'payment number. Auto-audit trigger handles logging.
Example:
  SELECT record_ap_payment(
      p_authority_code := ''CHILANGA'',
      p_vendor_id := ''...uuid...''::UUID,
      p_payment_date := CURRENT_DATE,
      p_amount := 500.00,
      p_payment_method := ''BANK_TRANSFER'',
      p_payment_reference := ''BT-123456'',
      p_bank_account_id := (SELECT account_id FROM chart_of_accounts WHERE account_code = ''10200''),
      p_fund_id := NULL,
      p_notes := ''Payment for office supplies'',
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: allocate_payment_to_invoice
-- Matches an AP payment to an AP invoice
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION allocate_payment_to_invoice(
    p_payment_id UUID,
    p_invoice_id UUID,
    p_allocated_amount NUMERIC,
    p_notes TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_allocation_id UUID;
    v_payment RECORD;
    v_invoice RECORD;
    v_new_amount_paid NUMERIC;
    v_new_balance NUMERIC;
    v_new_status VARCHAR;
BEGIN
    SELECT * INTO v_payment FROM ap_payment WHERE payment_id = p_payment_id;
    IF v_payment IS NULL THEN
        RAISE EXCEPTION 'AP Payment not found: %', p_payment_id;
    END IF;

    IF v_payment.status != 'POSTED' THEN
        RAISE EXCEPTION 'Cannot allocate a % payment', v_payment.status;
    END IF;

    SELECT * INTO v_invoice FROM ap_invoice WHERE invoice_id = p_invoice_id;
    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'AP Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status IN ('CANCELLED', 'DISPUTED', 'PAID', 'DRAFT', 'PENDING_APPROVAL') THEN
        RAISE EXCEPTION 'Cannot allocate to an AP invoice in % status', v_invoice.status;
    END IF;

    IF v_payment.vendor_id != v_invoice.vendor_id THEN
        RAISE EXCEPTION 'Payment and invoice belong to different vendors';
    END IF;

    IF p_allocated_amount <= 0 THEN
        RAISE EXCEPTION 'Allocated amount must be positive. Got: %', p_allocated_amount;
    END IF;

    IF p_allocated_amount > v_payment.amount_unallocated THEN
        RAISE EXCEPTION 'Allocation exceeds payment unallocated amount. Requested: %, Available: %',
            p_allocated_amount, v_payment.amount_unallocated;
    END IF;

    IF p_allocated_amount > v_invoice.balance THEN
        RAISE EXCEPTION 'Allocation exceeds invoice balance. Requested: %, Available: %',
            p_allocated_amount, v_invoice.balance;
    END IF;

    -- Create allocation (auto-audit trigger handles logging)
    INSERT INTO ap_payment_allocation (
        payment_id, invoice_id, allocated_amount, allocated_by, notes
    ) VALUES (
        p_payment_id, p_invoice_id, p_allocated_amount, p_user_id, p_notes
    ) RETURNING allocation_id INTO v_allocation_id;

    -- Update payment
    UPDATE ap_payment
    SET amount_allocated = amount_allocated + p_allocated_amount,
        amount_unallocated = amount_unallocated - p_allocated_amount,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE payment_id = p_payment_id;

    -- Update invoice
    v_new_amount_paid := v_invoice.amount_paid + p_allocated_amount;
    v_new_balance := v_invoice.total_amount - v_new_amount_paid;

    IF v_new_balance <= 0 THEN
        v_new_status := 'PAID';
    ELSIF v_new_amount_paid > 0 THEN
        v_new_status := 'PARTIAL';
    ELSE
        v_new_status := 'OUTSTANDING';
    END IF;

    UPDATE ap_invoice
    SET amount_paid = v_new_amount_paid,
        balance = GREATEST(v_new_balance, 0),
        status = v_new_status,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE invoice_id = p_invoice_id;

    RETURN v_allocation_id;
END;
$$;

COMMENT ON FUNCTION allocate_payment_to_invoice IS
'Matches an AP payment to an AP invoice. Validates amounts, vendor match, '
'and updates both payment and invoice balances. Auto-updates invoice '
'status (OUTSTANDING → PARTIAL → PAID). Auto-audit handles logging.';

-- ---------------------------------------------------------------------
-- Function: cancel_ap_invoice
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cancel_ap_invoice(
    p_invoice_id UUID,
    p_reason TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
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
'Cancels an unpaid AP invoice. Raises exception if any payments have '
'been applied. Auto-audit trigger logs the change.';

-- ---------------------------------------------------------------------
-- Function: dispute_ap_invoice
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION dispute_ap_invoice(
    p_invoice_id UUID,
    p_reason TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
BEGIN
    SELECT * INTO v_invoice FROM ap_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'AP Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status IN ('CANCELLED', 'PAID') THEN
        RAISE EXCEPTION 'Cannot dispute a % AP invoice', v_invoice.status;
    END IF;

    UPDATE ap_invoice
    SET status = 'DISPUTED',
        notes = COALESCE(notes, '') || ' | DISPUTED: ' || p_reason,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE invoice_id = p_invoice_id;

    RETURN p_invoice_id;
END;
$$;

COMMENT ON FUNCTION dispute_ap_invoice IS
'Marks an AP invoice as DISPUTED. Used when there is a disagreement '
'with the vendor about the invoice. Auto-audit trigger logs the change.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AP_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_ap_business_logic',
        'migration', 'V87',
        'purpose', 'AP business logic functions',
        'functions_created', ARRAY[
            'generate_ap_invoice_number',
            'generate_ap_payment_number',
            'create_ap_invoice',
            'approve_ap_invoice',
            'record_ap_payment',
            'allocate_payment_to_invoice',
            'cancel_ap_invoice',
            'dispute_ap_invoice'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
