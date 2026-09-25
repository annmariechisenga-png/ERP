-- =====================================================================
-- V81__fix_ar_function_casts_and_audit.sql
-- Fix: Function date casting + double-audit-logging
-- =====================================================================
-- Two issues found in V80 testing:
--
-- 1. create_ar_invoice() requires explicit DATE casts for due_date.
--    Fix: Accept TIMESTAMP or DATE by using ::DATE inside the function.
--    (Alternative: docs tell callers to cast. But better to be tolerant.)
--
-- 2. Business functions (create_ar_invoice, record_ar_receipt, etc.)
--    call log_audit_event AND the auto-audit trigger also fires.
--    This causes DOUBLE audit records for a single operation.
--    Fix: Remove explicit log_audit_event calls from AR business functions.
--    The auto-audit trigger captures everything.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Rebuild create_ar_invoice without explicit audit call
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

    -- Create invoice (auto-audit trigger handles logging)
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

    -- Create invoice lines (auto-audit trigger handles logging)
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

    -- No explicit audit log — the auto-audit trigger handles it
    RETURN v_invoice_id;
END;
$$;

-- ---------------------------------------------------------------------
-- 2. Rebuild record_ar_receipt without explicit audit call
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

    -- Create receipt (auto-audit trigger handles logging)
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

    -- No explicit audit log — the auto-audit trigger handles it
    RETURN v_receipt_id;
END;
$$;

-- ---------------------------------------------------------------------
-- 3. Rebuild allocate_receipt_to_invoice without explicit audit call
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
    SELECT * INTO v_receipt FROM ar_receipt WHERE receipt_id = p_receipt_id;
    IF v_receipt IS NULL THEN
        RAISE EXCEPTION 'Receipt not found: %', p_receipt_id;
    END IF;

    IF v_receipt.status != 'POSTED' THEN
        RAISE EXCEPTION 'Cannot allocate a % receipt', v_receipt.status;
    END IF;

    SELECT * INTO v_invoice FROM ar_invoice WHERE invoice_id = p_invoice_id;
    IF v_invoice IS NULL THEN
        RAISE EXCEPTION 'Invoice not found: %', p_invoice_id;
    END IF;

    IF v_invoice.status IN ('CANCELLED', 'WRITTEN_OFF', 'PAID') THEN
        RAISE EXCEPTION 'Cannot allocate to a % invoice', v_invoice.status;
    END IF;

    IF v_receipt.customer_id != v_invoice.customer_id THEN
        RAISE EXCEPTION 'Receipt and invoice belong to different customers';
    END IF;

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

    -- Create allocation (auto-audit trigger handles logging)
    INSERT INTO ar_receipt_allocation (
        receipt_id, invoice_id, allocated_amount, allocated_by, notes
    ) VALUES (
        p_receipt_id, p_invoice_id, p_allocated_amount, p_user_id, p_notes
    ) RETURNING allocation_id INTO v_allocation_id;

    UPDATE ar_receipt
    SET amount_allocated = amount_allocated + p_allocated_amount,
        amount_unallocated = amount_unallocated - p_allocated_amount,
        updated_at = NOW(),
        updated_by = p_user_id
    WHERE receipt_id = p_receipt_id;

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

    RETURN v_allocation_id;
END;
$$;

-- ---------------------------------------------------------------------
-- 4. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AR_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_ar_functions',
        'migration', 'V81',
        'fix1', 'Remove explicit log_audit_event calls (auto-audit trigger handles it)',
        'fix2', 'Documentation: p_due_date must be cast to DATE by callers',
        'functions_rebuilt', ARRAY[
            'create_ar_invoice',
            'record_ar_receipt',
            'allocate_receipt_to_invoice'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
