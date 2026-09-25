-- =====================================================================
-- V79__create_ar_receipt_allocation.sql
-- Accounts Receivable — Receipt and Receipt Allocation
-- =====================================================================
-- AR Receipts record payments received from customers.
-- AR Receipt Allocations match those receipts to specific invoices.
--
-- Design principles:
--   1. One receipt can pay multiple invoices (allocation table)
--   2. One invoice can be paid by multiple receipts (many-to-many)
--   3. Every write triggers auto-audit
--   4. Receipts post to GL (debit bank, credit AR control)
--   5. Multi-tenant: authority_code on every table
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. AR RECEIPT — Payments received from customers
-- ---------------------------------------------------------------------
CREATE TABLE ar_receipt (
    receipt_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    receipt_number      VARCHAR(50) NOT NULL,
    customer_id         UUID NOT NULL REFERENCES ar_customer(customer_id),
    receipt_date        DATE NOT NULL,
    amount              NUMERIC(15,2) NOT NULL,
    amount_allocated    NUMERIC(15,2) NOT NULL DEFAULT 0,
    amount_unallocated  NUMERIC(15,2) NOT NULL,
    payment_method      VARCHAR(50) NOT NULL,
        -- CASH, MOBILE_MONEY, BANK_TRANSFER, CHEQUE, POS, OTHER
    payment_reference   VARCHAR(100),
        -- External reference (bank transaction ID, mobile money ref, cheque number)
    bank_account_id     UUID REFERENCES chart_of_accounts(account_id),
        -- Which bank account received the money
    fund_id             UUID REFERENCES fund(fund_id),
        -- Which fund the payment applies to (NULL for general receipts)
    gl_journal_id       UUID REFERENCES journal_entry(journal_id),
        -- The GL journal created for this receipt
    period_id           UUID REFERENCES fiscal_period(period_id),
    is_reconciled       BOOLEAN NOT NULL DEFAULT FALSE,
    reconciled_at       TIMESTAMPTZ,
    reconciled_by       UUID,
    notes               TEXT,
    status              VARCHAR(20) NOT NULL DEFAULT 'POSTED',
        -- DRAFT, POSTED, REVERSED, CANCELLED
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID NOT NULL,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    CONSTRAINT uq_ar_receipt_number
        UNIQUE (authority_code, receipt_number),
    CONSTRAINT chk_ar_receipt_method
        CHECK (payment_method IN (
            'CASH', 'MOBILE_MONEY', 'BANK_TRANSFER', 'CHEQUE', 'POS', 'OTHER'
        )),
    CONSTRAINT chk_ar_receipt_status
        CHECK (status IN (
            'DRAFT', 'POSTED', 'REVERSED', 'CANCELLED'
        )),
    CONSTRAINT chk_ar_receipt_amounts
        CHECK (
            amount > 0
            AND amount_allocated >= 0
            AND amount_unallocated >= 0
            AND amount = amount_allocated + amount_unallocated
        )
);

CREATE INDEX idx_ar_receipt_authority ON ar_receipt(authority_code);
CREATE INDEX idx_ar_receipt_number ON ar_receipt(receipt_number);
CREATE INDEX idx_ar_receipt_customer ON ar_receipt(customer_id);
CREATE INDEX idx_ar_receipt_date ON ar_receipt(authority_code, receipt_date DESC);
CREATE INDEX idx_ar_receipt_status ON ar_receipt(authority_code, status);
CREATE INDEX idx_ar_receipt_method ON ar_receipt(authority_code, payment_method);
CREATE INDEX idx_ar_receipt_unallocated ON ar_receipt(authority_code, amount_unallocated)
    WHERE amount_unallocated > 0;
CREATE INDEX idx_ar_receipt_bank ON ar_receipt(bank_account_id)
    WHERE bank_account_id IS NOT NULL;
CREATE INDEX idx_ar_receipt_journal ON ar_receipt(gl_journal_id)
    WHERE gl_journal_id IS NOT NULL;

COMMENT ON TABLE ar_receipt IS
'AR Receipt — a payment received from a customer. Posts to GL (debit '
'bank account, credit AR control). Can be allocated to one or more '
'invoices. Tracks reconciliation status for bank reconciliation.';

-- ---------------------------------------------------------------------
-- 2. AR RECEIPT ALLOCATION — Match receipts to invoices
-- ---------------------------------------------------------------------
CREATE TABLE ar_receipt_allocation (
    allocation_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receipt_id          UUID NOT NULL REFERENCES ar_receipt(receipt_id) ON DELETE CASCADE,
    invoice_id          UUID NOT NULL REFERENCES ar_invoice(invoice_id),
    allocated_amount    NUMERIC(15,2) NOT NULL,
    allocated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    allocated_by        UUID NOT NULL,
    notes               TEXT,
    CONSTRAINT chk_ar_allocation_amount
        CHECK (allocated_amount > 0)
);

CREATE INDEX idx_ar_allocation_receipt ON ar_receipt_allocation(receipt_id);
CREATE INDEX idx_ar_allocation_invoice ON ar_receipt_allocation(invoice_id);
CREATE INDEX idx_ar_allocation_date ON ar_receipt_allocation(allocated_at DESC);

-- Prevent over-allocation: the sum of all allocations for a receipt
-- cannot exceed the receipt amount.
CREATE OR REPLACE FUNCTION check_receipt_allocation()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_receipt_amount NUMERIC;
    v_total_allocated NUMERIC;
BEGIN
    -- Get the receipt amount
    SELECT amount INTO v_receipt_amount
    FROM ar_receipt
    WHERE receipt_id = NEW.receipt_id;

    -- Get total allocated (including this new allocation)
    SELECT COALESCE(SUM(allocated_amount), 0) + NEW.allocated_amount
    INTO v_total_allocated
    FROM ar_receipt_allocation
    WHERE receipt_id = NEW.receipt_id;

    IF v_total_allocated > v_receipt_amount THEN
        RAISE EXCEPTION 'Allocation would exceed receipt amount. Receipt: %, Total allocated: %',
            v_receipt_amount, v_total_allocated;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_receipt_allocation
    BEFORE INSERT OR UPDATE ON ar_receipt_allocation
    FOR EACH ROW
    EXECUTE FUNCTION check_receipt_allocation();

-- Prevent over-allocation: the sum of all allocations for an invoice
-- cannot exceed the invoice total amount.
CREATE OR REPLACE FUNCTION check_invoice_allocation()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice_total NUMERIC;
    v_total_allocated NUMERIC;
BEGIN
    -- Get the invoice total
    SELECT total_amount INTO v_invoice_total
    FROM ar_invoice
    WHERE invoice_id = NEW.invoice_id;

    -- Get total allocated (including this new allocation)
    SELECT COALESCE(SUM(allocated_amount), 0) + NEW.allocated_amount
    INTO v_total_allocated
    FROM ar_receipt_allocation
    WHERE invoice_id = NEW.invoice_id;

    IF v_total_allocated > v_invoice_total THEN
        RAISE EXCEPTION 'Allocation would exceed invoice total. Invoice: %, Total allocated: %',
            v_invoice_total, v_total_allocated;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_invoice_allocation
    BEFORE INSERT OR UPDATE ON ar_receipt_allocation
    FOR EACH ROW
    EXECUTE FUNCTION check_invoice_allocation();

COMMENT ON TABLE ar_receipt_allocation IS
'AR Receipt Allocation — matches a receipt to specific invoices. '
'One receipt can be allocated to multiple invoices; one invoice can '
'receive allocations from multiple receipts. Triggers prevent '
'over-allocation on both sides.';

COMMENT ON FUNCTION check_receipt_allocation IS
'Trigger: prevents allocating more than the receipt amount across '
'all invoices. Raises exception if over-allocation is attempted.';

COMMENT ON FUNCTION check_invoice_allocation IS
'Trigger: prevents allocating more than the invoice total across '
'all receipts. Raises exception if over-allocation is attempted.';

-- ---------------------------------------------------------------------
-- 3. AUTO-AUDIT TRIGGERS
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_ar_receipt ON ar_receipt;
CREATE TRIGGER trg_audit_ar_receipt
    AFTER INSERT OR UPDATE OR DELETE ON ar_receipt
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS trg_audit_ar_receipt_allocation ON ar_receipt_allocation;
CREATE TRIGGER trg_audit_ar_receipt_allocation
    AFTER INSERT OR UPDATE OR DELETE ON ar_receipt_allocation
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 4. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AR_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_ar_receipt_allocation_tables',
        'migration', 'V79',
        'purpose', 'Accounts Receivable — payment tracking and allocation',
        'tables_created', ARRAY[
            'ar_receipt',
            'ar_receipt_allocation'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
