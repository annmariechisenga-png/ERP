-- =====================================================================
-- V80__ar_business_logic.sql
-- Accounts Receivable Business Logic Functions
-- =====================================================================
-- These functions encapsulate the business logic of AR operations:
--   - Generate unique invoice/receipt numbers
--   - Create invoices with lines
--   - Record payments
--   - Allocate payments to invoices
--   - Cancel invoices
--   - Write off bad debts
--
-- All functions:
--   - Are transactional
--   - Auto-log to audit trail
--   - Update invoice balances
--   - Prepare GL postings
-- =====================================================================

-- ---------------------------------------------------------------------
-- Helper: Generate next invoice number
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_invoice_number(
    p_authority_code VARCHAR,
    p_invoice_date DATE
) RETURNS VARCHAR
LANGUAGE plpgsql AS $$
DECLARE
    v_count BIGINT;
    v_number VARCHAR(50);
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ar_invoice
    WHERE authority_code = p_authority_code
      AND invoice_date = p_invoice_date;

    v_number := 'INV-' || TO_CHAR(p_invoice_date, 'YYYYMMDD') || '-' ||
                LPAD((v_count + 1)::TEXT, 5, '0');

    RETURN v_number;
END;
$$;

COMMENT ON FUNCTION generate_invoice_number IS
'Generates a unique invoice number in format INV-YYYYMMDD-NNNNN.';

-- ---------------------------------------------------------------------
-- Helper: Generate next receipt number
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION generate_receipt_number(
    p_authority_code VARCHAR,
    p_receipt_date DATE
) RETURNS VARCHAR
LANGUAGE plpgsql AS $$
DECLARE
    v_count BIGINT;
    v_number VARCHAR(50);
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM ar_receipt
    WHERE authority_code = p_authority_code
      AND receipt_date = p_receipt_date;

    v_number := 'RCP-' || TO_CHAR(p_receipt_date, 'YYYYMMDD') || '-' ||
                LPAD((v_count + 1)::TEXT, 5, '0');

    RETURN v_number;
END;
$$;

COMMENT ON FUNCTION generate_receipt_number IS
'Generates a unique receipt number in format RCP-YYYYMMDD-NNNNN.';

-- ---------------------------------------------------------------------
-- Function: create_ar_invoice
-- Creates an invoice with lines in one transaction
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
    -- Find fiscal period
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_invoice_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period for date % in authority %',
            p_invoice_date, p_authority_code;
    END IF;

    -- Generate invoice number
    v_invoice_number := generate_invoice_number(p_authority_code, p_invoice_date);

    -- Calculate totals from lines
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

    -- Create invoice
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

    -- Create invoice lines
    FOR v_line IN SELECT * FROM jsonb_array_elements(p_lines)
    LOOP
        -- Look up the revenue account
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

    -- Log to audit trail
    PERFORM log_audit_event(
        p_event_type := 'CREATE',
        p_entity_type := 'AR_INVOICE',
        p_entity_id := v_invoice_id,
        p_action := 'CREATE',
        p_new_value := jsonb_build_object(
            'invoice_number', v_invoice_number,
            'customer_id', p_customer_id,
            'total_amount', v_total,
            'invoice_type', p_invoice_type
        ),
        p_user_id := p_user_id,
        p_authority_code := p_authority_code,
        p_source_module := 'AR'
    );

    RETURN v_invoice_id;
END;
$$;

COMMENT ON FUNCTION create_ar_invoice IS
'Creates an AR invoice with lines in one transaction. Validates period, '
'generates invoice number, calculates totals, creates lines, logs to '
'audit trail. Returns invoice_id.
Example:
  SELECT create_ar_invoice(
      p_authority_code := ''CHILANGA'',
      p_customer_id := ''...uuid...''::UUID,
      p_invoice_date := CURRENT_DATE,
      p_due_date := CURRENT_DATE + INTERVAL ''30 days'',
      p_invoice_type := ''PROPERTY_RATE'',
      p_description := ''Annual property rate'',
      p_fund_id := (SELECT fund_id FROM fund WHERE fund_code = ''1000''),
      p_cost_center_id := (SELECT cost_center_id FROM cost_center WHERE cost_center_code = ''0201''),
      p_lines := ''[
          {"description": "Property rate for plot 1234", "account_code": "40100", "quantity": 1, "unit_price": 1500.00}
      ]''::JSONB,
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: record_ar_receipt
-- Records a payment received from a customer
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
    -- Find fiscal period
    v_period_id := get_fiscal_period_for_date(p_authority_code, p_receipt_date);

    IF v_period_id IS NULL THEN
        RAISE EXCEPTION 'No open fiscal period for date % in authority %',
            p_receipt_date, p_authority_code;
    END IF;

    -- Validate amount
    IF p_amount <= 0 THEN
        RAISE EXCEPTION 'Receipt amount must be positive. Got: %', p_amount;
    END IF;

    -- Generate receipt number
    v_receipt_number := generate_receipt_number(p_authority_code, p_receipt_date);

    -- Create receipt
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

    -- Log to audit trail
    PERFORM log_audit_event(
        p_event_type := 'CREATE',
        p_entity_type := 'AR_RECEIPT',
        p_entity_id := v_receipt_id,
        p_action := 'CREATE',
        p_new_value := jsonb_build_object(
            'receipt_number', v_receipt_number,
            'customer_id', p_customer_id,
            'amount', p_amount,
            'payment_method', p_payment_method
        ),
        p_user_id := p_user_id,
        p_authority_code := p_authority_code,
        p_source_module := 'AR'
    );

    RETURN v_receipt_id;
END;
$$;

COMMENT ON FUNCTION record_ar_receipt IS
'Records a payment received from a customer. Validates period, '
'generates receipt number, creates receipt, logs to audit trail. '
'Returns receipt_id.
Example:
  SELECT record_ar_receipt(
      p_authority_code := ''CHILANGA'',
      p_customer_id := ''...uuid...''::UUID,
      p_receipt_date := CURRENT_DATE,
      p_amount := 1500.00,
      p_payment_method := ''MOBILE_MONEY'',
      p_payment_reference := ''MM-123456'',
      p_bank_account_id := (SELECT account_id FROM chart_of_accounts WHERE account_code = ''10210''),
      p_fund_id := NULL,
      p_notes := ''Payment received via mobile money'',
      p_user_id := ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- Function: allocate_receipt_to_invoice
-- Matches a receipt to an invoice
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION allocate_receipt_to_invoice(
    p_receipt_id UUID,
    p_invoice_id UUID,
    p_allocated_amount NUMERIC,
    p_notes TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_allocation_id UUID;
    v_receipt RECORD;
    v_invoice RECORD;
    v_new_amount_paid NUMERIC;
    v_new_balance NUMERIC;
    v_new_status VARCHAR;
BEGIN
    -- Fetch receipt
    SELECT * INTO v_receipt FROM ar_receipt WHERE receipt_id = p_receipt_id;
    IF v_receipt IS NULL THEN
        RAISE EXCEPTION 'Receipt not found: %', p_receipt_id;
    END IF;

    IF v_receipt.status != 'POSTED' THEN
        RAISE EXCEPTION 'Cannot allocate a % receipt', v_receipt.status;
    END IF;

    -- Fetch invoice
    SELECT * INTO v_invoice FROM ar_invoice WHERE invoice_id = p_invoice_id;
    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status IN ('CANCELLED', 'WRITTEN_OFF', 'PAID') THEN
        RAISE EXCEPTION 'Cannot allocate to a % invoice', v_invoice.status;
    END IF;

    -- Verify customer match
    IF v_receipt.customer_id != v_invoice.customer_id THEN
        RAISE EXCEPTION 'Receipt and invoice belong to different customers';
    END IF;

    -- Validate amount
    IF p_allocated_amount <= 0 THEN
        RAISE EXCEPTION 'Allocated amount must be positive. Got: %', p_allocated_amount;
    END IF;

    IF p_allocated_amount > v_receipt.amount_unallocated THEN
        RAISE EXCEPTION 'Allocation exceeds receipt unallocated amount. Requested: %, Available: %',
            p_allocated_amount, v_receipt.amount_unallocated;
    END IF;

    IF p_allocated_amount > v_invoice.balance THEN
        RAISE EXCEPTION 'Allocation exceeds invoice balance. Requested: %, Available: %',
            p_allocated_amount, v_invoice.balance;
    END IF;

    -- Create allocation
    INSERT INTO ar_receipt_allocation (
        receipt_id, invoice_id, allocated_amount, allocated_by, notes
    ) VALUES (
        p_receipt_id, p_invoice_id, p_allocated_amount, p_user_id, p_notes
    ) RETURNING allocation_id INTO v_allocation_id;

    -- Update receipt
    UPDATE ar_receipt
    SET amount_allocated = amount_allocated + p_allocated_amount,
        amount_unallocated = amount_unallocated - p_allocated_amount,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE receipt_id = p_receipt_id;

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

    UPDATE ar_invoice
    SET amount_paid = v_new_amount_paid,
        balance = GREATEST(v_new_balance, 0),
        status = v_new_status,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE invoice_id = p_invoice_id;

    -- Log to audit trail
    PERFORM log_audit_event(
        p_event_type := 'UPDATE',
        p_entity_type := 'AR_RECEIPT_ALLOCATION',
        p_entity_id := v_allocation_id,
        p_action := 'CREATE',
        p_new_value := jsonb_build_object(
            'receipt_id', p_receipt_id,
            'invoice_id', p_invoice_id,
            'allocated_amount', p_allocated_amount,
            'invoice_new_status', v_new_status
        ),
        p_user_id := p_user_id,
        p_authority_code := v_receipt.authority_code,
        p_source_module := 'AR'
    );

    RETURN v_allocation_id;
END;
$$;

COMMENT ON FUNCTION allocate_receipt_to_invoice IS
'Matches a receipt to an invoice. Validates amounts, customer match, '
'and updates both receipt and invoice balances. Auto-updates invoice '
'status (OUTSTANDING → PARTIAL → PAID). Logs to audit trail.';

-- ---------------------------------------------------------------------
-- Function: cancel_ar_invoice
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cancel_ar_invoice(
    p_invoice_id UUID,
    p_reason TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
BEGIN
    SELECT * INTO v_invoice FROM ar_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status = 'CANCELLED' THEN
        RAISE EXCEPTION 'Invoice is already cancelled';
    END IF;

    IF v_invoice.amount_paid > 0 THEN
        RAISE EXCEPTION 'Cannot cancel an invoice with payments. Balance: %, Paid: %',
            v_invoice.balance, v_invoice.amount_paid;
    END IF;

    UPDATE ar_invoice
    SET status = 'CANCELLED',
        cancelled_at = NOW(),
        cancelled_by = p_user_id,
        cancellation_reason = p_reason,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE invoice_id = p_invoice_id;

    PERFORM log_audit_event(
        p_event_type := 'UPDATE',
        p_entity_type := 'AR_INVOICE',
        p_entity_id := p_invoice_id,
        p_action := 'CANCEL',
        p_old_value := jsonb_build_object('status', v_invoice.status),
        p_new_value := jsonb_build_object('status', 'CANCELLED', 'reason', p_reason),
        p_user_id := p_user_id,
        p_authority_code := v_invoice.authority_code,
        p_source_module := 'AR'
    );

    RETURN p_invoice_id;
END;
$$;

COMMENT ON FUNCTION cancel_ar_invoice IS
'Cancels an unpaid invoice. Raises exception if any payments have been '
'applied. Logs to audit trail with reason.';

-- ---------------------------------------------------------------------
-- Function: write_off_invoice
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION write_off_invoice(
    p_invoice_id UUID,
    p_reason TEXT,
    p_user_id UUID
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice RECORD;
BEGIN
    SELECT * INTO v_invoice FROM ar_invoice WHERE invoice_id = p_invoice_id;

    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status IN ('PAID', 'CANCELLED', 'WRITTEN_OFF') THEN
        RAISE EXCEPTION 'Cannot write off a % invoice', v_invoice.status;
    END IF;

    IF v_invoice.balance <= 0 THEN
        RAISE EXCEPTION 'Invoice has no balance to write off';
    END IF;

    UPDATE ar_invoice
    SET status = 'WRITTEN_OFF',
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE invoice_id = p_invoice_id;

    PERFORM log_audit_event(
        p_event_type := 'UPDATE',
        p_entity_type := 'AR_INVOICE',
        p_entity_id := p_invoice_id,
        p_action := 'WRITE_OFF',
        p_old_value := jsonb_build_object('status', v_invoice.status, 'balance', v_invoice.balance),
        p_new_value := jsonb_build_object('status', 'WRITTEN_OFF', 'reason', p_reason),
        p_user_id := p_user_id,
        p_authority_code := v_invoice.authority_code,
        p_source_module := 'AR'
    );

    RETURN p_invoice_id;
END;
$$;

COMMENT ON FUNCTION write_off_invoice IS
'Writes off an unpaid invoice balance as bad debt. Records reason in '
'audit trail. Does not modify GL (post_writeoff_to_gl handles that).';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AR_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_ar_business_logic',
        'migration', 'V80',
        'purpose', 'AR business logic functions',
        'functions_created', ARRAY[
            'generate_invoice_number',
            'generate_receipt_number',
            'create_ar_invoice',
            'record_ar_receipt',
            'allocate_receipt_to_invoice',
            'cancel_ar_invoice',
            'write_off_invoice'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
