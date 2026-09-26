-- =====================================================================
-- V85__create_ap_vendor_invoice.sql
-- Accounts Payable — Vendor, Invoice, Invoice Line
-- =====================================================================
-- AP (Accounts Payable) tracks what the council owes to suppliers,
-- contractors, and service providers. This migration creates the
-- master data (vendors) and billing tables (invoices, invoice lines).
--
-- Design principles:
--   1. Multi-tenant: authority_code on every table
--   2. Auto-logged: every write triggers an audit event
--   3. GL-integrated: invoices post to AP control + expense accounts
--   4. IPSAS-compliant: accrual accounting
--   5. Approval workflow: invoices go through approval
--   6. Vendor management: TIN, VAT, bank details captured
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. AP VENDOR — Master data for all suppliers
-- ---------------------------------------------------------------------
CREATE TABLE ap_vendor (
    vendor_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    vendor_number       VARCHAR(50) NOT NULL,
    vendor_type         VARCHAR(20) NOT NULL,
        -- INDIVIDUAL, BUSINESS, GOVERNMENT, NGO, OTHER
    vendor_name         VARCHAR(255) NOT NULL,
    trading_name        VARCHAR(255),
    tpin                VARCHAR(20),
        -- Taxpayer Identification Number
    vat_number          VARCHAR(20),
    nrc                 VARCHAR(20),
    phone               VARCHAR(20),
    email               VARCHAR(255),
    physical_address    TEXT,
    postal_address      TEXT,
    contact_person      VARCHAR(255),
    contact_phone       VARCHAR(20),
    bank_name           VARCHAR(100),
    bank_branch         VARCHAR(100),
    bank_account        VARCHAR(50),
    bank_account_name   VARCHAR(255),
    payment_terms_days  INTEGER DEFAULT 30,
    credit_limit        NUMERIC(15,2) DEFAULT 0,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_blacklisted      BOOLEAN NOT NULL DEFAULT FALSE,
    blacklist_reason    TEXT,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    CONSTRAINT uq_ap_vendor_number
        UNIQUE (authority_code, vendor_number),
    CONSTRAINT chk_ap_vendor_type
        CHECK (vendor_type IN (
            'INDIVIDUAL', 'BUSINESS', 'GOVERNMENT', 'NGO', 'OTHER'
        )),
    CONSTRAINT chk_ap_vendor_credit_limit
        CHECK (credit_limit >= 0)
);

CREATE INDEX idx_ap_vendor_authority ON ap_vendor(authority_code);
CREATE INDEX idx_ap_vendor_number ON ap_vendor(vendor_number);
CREATE INDEX idx_ap_vendor_type ON ap_vendor(authority_code, vendor_type);
CREATE INDEX idx_ap_vendor_name ON ap_vendor(vendor_name);
CREATE INDEX idx_ap_vendor_tpin ON ap_vendor(tpin) WHERE tpin IS NOT NULL;
CREATE INDEX idx_ap_vendor_active ON ap_vendor(authority_code, is_active)
    WHERE is_active = TRUE;

COMMENT ON TABLE ap_vendor IS
'AP Vendor master. Every supplier, contractor, service provider is a vendor. '
'Captures TIN, VAT, bank details for payment processing.';

-- ---------------------------------------------------------------------
-- 2. AP INVOICE — Bills received from vendors
-- ---------------------------------------------------------------------
CREATE TABLE ap_invoice (
    invoice_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    invoice_number      VARCHAR(50) NOT NULL,
        -- Internal AP number (system-generated)
    vendor_invoice_number VARCHAR(100),
        -- The vendor's own invoice number
    vendor_id           UUID NOT NULL REFERENCES ap_vendor(vendor_id),
    invoice_date        DATE NOT NULL,
        -- Date on the vendor's invoice
    received_date       DATE NOT NULL,
        -- Date the council received the invoice
    due_date            DATE NOT NULL,
    invoice_type        VARCHAR(50) NOT NULL,
        -- GOODS, SERVICES, WORKS, UTILITIES, RENT, PROFESSIONAL_FEES,
        -- CAPITAL, TRANSFER, STATUTORY, LOAN_REPAYMENT, OTHER
    description         TEXT,
    fund_id             UUID NOT NULL REFERENCES fund(fund_id),
    cost_center_id      UUID NOT NULL REFERENCES cost_center(cost_center_id),
    subtotal            NUMERIC(15,2) NOT NULL,
    tax_amount          NUMERIC(15,2) NOT NULL DEFAULT 0,
    withholding_tax     NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_amount        NUMERIC(15,2) NOT NULL,
    amount_paid         NUMERIC(15,2) NOT NULL DEFAULT 0,
    balance             NUMERIC(15,2) NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
        -- DRAFT, PENDING_APPROVAL, APPROVED, OUTSTANDING, PARTIAL,
        -- PAID, OVERDUE, CANCELLED, DISPUTED
    gl_journal_id       UUID REFERENCES journal_entry(journal_id),
    period_id           UUID REFERENCES fiscal_period(period_id),
    approved_at         TIMESTAMPTZ,
    approved_by         UUID,
    cancelled_at        TIMESTAMPTZ,
    cancelled_by        UUID,
    cancellation_reason TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID NOT NULL,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    CONSTRAINT uq_ap_invoice_number
        UNIQUE (authority_code, invoice_number),
    CONSTRAINT chk_ap_invoice_type
        CHECK (invoice_type IN (
            'GOODS', 'SERVICES', 'WORKS', 'UTILITIES', 'RENT',
            'PROFESSIONAL_FEES', 'CAPITAL', 'TRANSFER', 'STATUTORY',
            'LOAN_REPAYMENT', 'OTHER'
        )),
    CONSTRAINT chk_ap_invoice_status
        CHECK (status IN (
            'DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'OUTSTANDING',
            'PARTIAL', 'PAID', 'OVERDUE', 'CANCELLED', 'DISPUTED'
        )),
    CONSTRAINT chk_ap_invoice_amounts
        CHECK (
            subtotal >= 0
            AND tax_amount >= 0
            AND withholding_tax >= 0
            AND total_amount >= 0
            AND amount_paid >= 0
            AND balance >= 0
        ),
    CONSTRAINT chk_ap_invoice_dates
        CHECK (due_date >= invoice_date),
    CONSTRAINT chk_ap_invoice_total
        CHECK (total_amount = subtotal + tax_amount - withholding_tax),
    CONSTRAINT chk_ap_invoice_balance
        CHECK (balance = total_amount - amount_paid)
);

CREATE INDEX idx_ap_invoice_authority ON ap_invoice(authority_code);
CREATE INDEX idx_ap_invoice_number ON ap_invoice(invoice_number);
CREATE INDEX idx_ap_invoice_vendor_number ON ap_invoice(vendor_invoice_number)
    WHERE vendor_invoice_number IS NOT NULL;
CREATE INDEX idx_ap_invoice_vendor ON ap_invoice(vendor_id);
CREATE INDEX idx_ap_invoice_date ON ap_invoice(authority_code, invoice_date DESC);
CREATE INDEX idx_ap_invoice_due_date ON ap_invoice(due_date)
    WHERE status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE');
CREATE INDEX idx_ap_invoice_status ON ap_invoice(authority_code, status);
CREATE INDEX idx_ap_invoice_type ON ap_invoice(authority_code, invoice_type);
CREATE INDEX idx_ap_invoice_fund ON ap_invoice(fund_id);
CREATE INDEX idx_ap_invoice_journal ON ap_invoice(gl_journal_id)
    WHERE gl_journal_id IS NOT NULL;

COMMENT ON TABLE ap_invoice IS
'AP Invoice — a bill received from a vendor. Posts to GL (debit expense '
'account, credit AP control). Tracks payment status and approval workflow.';

-- ---------------------------------------------------------------------
-- 3. AP INVOICE LINE — Individual line items on an invoice
-- ---------------------------------------------------------------------
CREATE TABLE ap_invoice_line (
    line_id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id          UUID NOT NULL REFERENCES ap_invoice(invoice_id) ON DELETE CASCADE,
    line_number         INTEGER NOT NULL,
    description         TEXT NOT NULL,
    account_id          UUID NOT NULL REFERENCES chart_of_accounts(account_id),
        -- Expense or asset account
    quantity            NUMERIC(15,4) NOT NULL DEFAULT 1,
    unit_price          NUMERIC(15,2) NOT NULL,
    line_total          NUMERIC(15,2) NOT NULL,
    tax_rate            NUMERIC(5,2) NOT NULL DEFAULT 0,
    tax_amount          NUMERIC(15,2) NOT NULL DEFAULT 0,
    withholding_tax_rate NUMERIC(5,2) NOT NULL DEFAULT 0,
    withholding_tax     NUMERIC(15,2) NOT NULL DEFAULT 0,
    reference           VARCHAR(100),
    -- Extended fields for procurement linkage
    purchase_order_id   UUID,
    goods_received_note_id UUID,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_ap_invoice_line_number
        UNIQUE (invoice_id, line_number),
    CONSTRAINT chk_ap_invoice_line_amounts
        CHECK (
            quantity > 0
            AND unit_price >= 0
            AND line_total >= 0
            AND tax_rate >= 0
            AND tax_amount >= 0
            AND withholding_tax_rate >= 0
            AND withholding_tax >= 0
        )
);

CREATE INDEX idx_ap_invoice_line_invoice ON ap_invoice_line(invoice_id);
CREATE INDEX idx_ap_invoice_line_account ON ap_invoice_line(account_id);
CREATE INDEX idx_ap_invoice_line_po ON ap_invoice_line(purchase_order_id)
    WHERE purchase_order_id IS NOT NULL;
CREATE INDEX idx_ap_invoice_line_grn ON ap_invoice_line(goods_received_note_id)
    WHERE goods_received_note_id IS NOT NULL;

COMMENT ON TABLE ap_invoice_line IS
'AP Invoice Line — individual line items on an AP invoice. Each line '
'has its own expense account. Can be linked to a PO and GRN for '
'three-way match.';

-- ---------------------------------------------------------------------
-- 4. AUTO-AUDIT TRIGGERS
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_ap_vendor ON ap_vendor;
CREATE TRIGGER trg_audit_ap_vendor
    AFTER INSERT OR UPDATE OR DELETE ON ap_vendor
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS trg_audit_ap_invoice ON ap_invoice;
CREATE TRIGGER trg_audit_ap_invoice
    AFTER INSERT OR UPDATE OR DELETE ON ap_invoice
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS trg_audit_ap_invoice_line ON ap_invoice_line;
CREATE TRIGGER trg_audit_ap_invoice_line
    AFTER INSERT OR UPDATE OR DELETE ON ap_invoice_line
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
        'action', 'create_ap_vendor_invoice_tables',
        'migration', 'V85',
        'purpose', 'Accounts Payable — vendor master, invoice, invoice line',
        'tables_created', ARRAY[
            'ap_vendor',
            'ap_invoice',
            'ap_invoice_line'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
