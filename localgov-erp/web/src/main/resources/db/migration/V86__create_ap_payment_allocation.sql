-- =====================================================================
-- V86__create_ap_payment_allocation.sql
-- Accounts Payable — Payment and Payment Allocation
-- =====================================================================
-- AP Payments record money paid out to vendors.
-- AP Payment Allocations match those payments to specific invoices.
--
-- Design principles:
--   1. One payment can pay multiple invoices (allocation table)
--   2. One invoice can be paid by multiple payments (many-to-many)
--   3. Every write triggers auto-audit
--   4. Payments post to GL (debit AP control, credit bank)
--   5. Multi-tenant: authority_code on every table
--   6. Over-allocation prevention on both sides
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. AP PAYMENT — Money paid out to vendors
-- ---------------------------------------------------------------------
CREATE TABLE ap_payment (
    payment_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    payment_number      VARCHAR(50) NOT NULL,
    vendor_id           UUID NOT NULL REFERENCES ap_vendor(vendor_id),
    payment_date        DATE NOT NULL,
    amount              NUMERIC(15,2) NOT NULL,
    amount_allocated    NUMERIC(15,2) NOT NULL DEFAULT 0,
    amount_unallocated  NUMERIC(15,2) NOT NULL,
    payment_method      VARCHAR(50) NOT NULL,
        -- CASH, BANK_TRANSFER, CHEQUE, MOBILE_MONEY, EFT, OTHER
    payment_reference   VARCHAR(100),
        -- Bank transaction ID, cheque number, EFT reference
    bank_account_id     UUID REFERENCES chart_of_accounts(account_id),
        -- Which bank account funds came from
    fund_id             UUID REFERENCES fund(fund_id),
        -- Which fund payment applies to (NULL for general payments)
    gl_journal_id       UUID REFERENCES journal_entry(journal_id),
        -- The GL journal created for this payment
    period_id           UUID REFERENCES fiscal_period(period_id),
    is_reconciled       BOOLEAN NOT NULL DEFAULT FALSE,
    reconciled_at       TIMESTAMPTZ,
    reconciled_by       UUID,
    notes               TEXT,
    status              VARCHAR(20) NOT NULL DEFAULT 'POSTED',
        -- DRAFT, POSTED, REVERSED, CANCELLED
    approved_at         TIMESTAMPTZ,
    approved_by         UUID,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID NOT NULL,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    CONSTRAINT uq_ap_payment_number
        UNIQUE (authority_code, payment_number),
    CONSTRAINT chk_ap_payment_method
        CHECK (payment_method IN (
            'CASH', 'BANK_TRANSFER', 'CHEQUE', 'MOBILE_MONEY', 'EFT', 'OTHER'
        )),
    CONSTRAINT chk_ap_payment_status
        CHECK (status IN (
            'DRAFT', 'POSTED', 'REVERSED', 'CANCELLED'
        )),
    CONSTRAINT chk_ap_payment_amounts
        CHECK (
            amount > 0
            AND amount_allocated >= 0
            AND amount_unallocated >= 0
            AND amount = amount_allocated + amount_unallocated
        )
);

CREATE INDEX idx_ap_payment_authority ON ap_payment(authority_code);
CREATE INDEX idx_ap_payment_number ON ap_payment(payment_number);
CREATE INDEX idx_ap_payment_vendor ON ap_payment(vendor_id);
CREATE INDEX idx_ap_payment_date ON ap_payment(authority_code, payment_date DESC);
CREATE INDEX idx_ap_payment_status ON ap_payment(authority_code, status);
CREATE INDEX idx_ap_payment_method ON ap_payment(authority_code, payment_method);
CREATE INDEX idx_ap_payment_unallocated ON ap_payment(authority_code, amount_unallocated)
    WHERE amount_unallocated > 0;
CREATE INDEX idx_ap_payment_bank ON ap_payment(bank_account_id)
    WHERE bank_account_id IS NOT NULL;
CREATE INDEX idx_ap_payment_journal ON ap_payment(gl_journal_id)
    WHERE gl_journal_id IS NOT NULL;

COMMENT ON TABLE ap_payment IS
'AP Payment — money paid out to a vendor. Posts to GL (debit AP control, '
'credit bank). Can be allocated to one or more invoices. Tracks '
'reconciliation status for bank reconciliation.';

-- ---------------------------------------------------------------------
-- 2. AP PAYMENT ALLOCATION — Match payments to invoices
-- ---------------------------------------------------------------------
CREATE TABLE ap_payment_allocation (
    allocation_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id          UUID NOT NULL REFERENCES ap_payment(payment_id) ON DELETE CASCADE,
    invoice_id          UUID NOT NULL REFERENCES ap_invoice(invoice_id),
    allocated_amount    NUMERIC(15,2) NOT NULL,
    allocated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    allocated_by        UUID NOT NULL,
    notes               TEXT,
    CONSTRAINT chk_ap_allocation_amount
        CHECK (allocated_amount > 0)
);

CREATE INDEX idx_ap_allocation_payment ON ap_payment_allocation(payment_id);
CREATE INDEX idx_ap_allocation_invoice ON ap_payment_allocation(invoice_id);
CREATE INDEX idx_ap_allocation_date ON ap_payment_allocation(allocated_at DESC);

-- ---------------------------------------------------------------------
-- 3. Over-Allocation Prevention Triggers
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_ap_payment_allocation()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_payment_amount NUMERIC;
    v_total_allocated NUMERIC;
BEGIN
    -- Get the payment amount
    SELECT amount INTO v_payment_amount
    FROM ap_payment
    WHERE payment_id = NEW.payment_id;

    -- Get total allocated (including this new allocation)
    SELECT COALESCE(SUM(allocated_amount), 0) + NEW.allocated_amount
    INTO v_total_allocated
    FROM ap_payment_allocation
    WHERE payment_id = NEW.payment_id;

    IF v_total_allocated > v_payment_amount THEN
        RAISE EXCEPTION 'AP allocation would exceed payment amount. Payment: %, Total allocated: %',
            v_payment_amount, v_total_allocated;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_ap_payment_allocation
    BEFORE INSERT OR UPDATE ON ap_payment_allocation
    FOR EACH ROW
    EXECUTE FUNCTION check_ap_payment_allocation();

CREATE OR REPLACE FUNCTION check_ap_invoice_allocation()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_invoice_total NUMERIC;
    v_total_allocated NUMERIC;
BEGIN
    -- Get the invoice total
    SELECT total_amount INTO v_invoice_total
    FROM ap_invoice
    WHERE invoice_id = NEW.invoice_id;

    -- Get total allocated (including this new allocation)
    SELECT COALESCE(SUM(allocated_amount), 0) + NEW.allocated_amount
    INTO v_total_allocated
    FROM ap_payment_allocation
    WHERE invoice_id = NEW.invoice_id;

    IF v_total_allocated > v_invoice_total THEN
        RAISE EXCEPTION 'AP allocation would exceed invoice total. Invoice: %, Total allocated: %',
            v_invoice_total, v_total_allocated;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_ap_invoice_allocation
    BEFORE INSERT OR UPDATE ON ap_payment_allocation
    FOR EACH ROW
    EXECUTE FUNCTION check_ap_invoice_allocation();

COMMENT ON FUNCTION check_ap_payment_allocation IS
'Trigger: prevents allocating more than the payment amount across all invoices.';

COMMENT ON FUNCTION check_ap_invoice_allocation IS
'Trigger: prevents allocating more than the invoice total across all payments.';

-- ---------------------------------------------------------------------
-- 4. AUTO-AUDIT TRIGGERS
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_ap_payment ON ap_payment;
CREATE TRIGGER trg_audit_ap_payment
    AFTER INSERT OR UPDATE OR DELETE ON ap_payment
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS trg_audit_ap_payment_allocation ON ap_payment_allocation;
CREATE TRIGGER trg_audit_ap_payment_allocation
    AFTER INSERT OR UPDATE OR DELETE ON ap_payment_allocation
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 5. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AP_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_ap_payment_allocation_tables',
        'migration', 'V86',
        'purpose', 'Accounts Payable — payment tracking and allocation',
        'tables_created', ARRAY[
            'ap_payment',
            'ap_payment_allocation'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
