-- =====================================================================
-- V78__create_ar_customer_invoice.sql
-- Accounts Receivable — Customer, Invoice, Invoice Line
-- =====================================================================
-- AR (Accounts Receivable) tracks what ratepayers, tenants, and other
-- debtors owe the council. This migration creates the master data
-- (customers) and billing tables (invoices, invoice lines).
--
-- Design principles:
--   1. Multi-tenant: authority_code on every table
--   2. Auto-logged: every write triggers an audit event
--   3. GL-integrated: invoices post to AR control + revenue accounts
--   4. IPSAS-compliant: accrual accounting
--   5. Effective dating: customers and invoices have timestamps
--   6. Extensible: customer_type supports INDIVIDUAL, BUSINESS, GOVT, EMPLOYEE
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. AR CUSTOMER — Master data for all debtors
-- ---------------------------------------------------------------------
CREATE TABLE ar_customer (
    customer_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    customer_number     VARCHAR(50) NOT NULL,
    customer_type       VARCHAR(20) NOT NULL,
        -- INDIVIDUAL, BUSINESS, GOVERNMENT, EMPLOYEE, OTHER
    customer_name       VARCHAR(255) NOT NULL,
        -- Full name for individuals, business name for companies
    trading_name        VARCHAR(255),
        -- Business trading name (if different from legal name)
    nrc                 VARCHAR(20),
        -- National Registration Card (individuals)
    tpin                VARCHAR(20),
        -- Taxpayer Identification Number (businesses)
    vat_number          VARCHAR(20),
    phone               VARCHAR(20),
    email               VARCHAR(255),
    physical_address    TEXT,
    postal_address      TEXT,
    contact_person      VARCHAR(255),
    contact_phone       VARCHAR(20),
    credit_limit        NUMERIC(15,2) DEFAULT 0,
    payment_terms_days  INTEGER DEFAULT 30,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    is_blacklisted      BOOLEAN NOT NULL DEFAULT FALSE,
    blacklist_reason    TEXT,
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    CONSTRAINT uq_ar_customer_number
        UNIQUE (authority_code, customer_number),
    CONSTRAINT chk_ar_customer_type
        CHECK (customer_type IN (
            'INDIVIDUAL', 'BUSINESS', 'GOVERNMENT', 'EMPLOYEE', 'OTHER'
        )),
    CONSTRAINT chk_ar_customer_credit_limit
        CHECK (credit_limit >= 0)
);

CREATE INDEX idx_ar_customer_authority ON ar_customer(authority_code);
CREATE INDEX idx_ar_customer_number ON ar_customer(customer_number);
CREATE INDEX idx_ar_customer_type ON ar_customer(authority_code, customer_type);
CREATE INDEX idx_ar_customer_name ON ar_customer(customer_name);
CREATE INDEX idx_ar_customer_active ON ar_customer(authority_code, is_active)
    WHERE is_active = TRUE;

COMMENT ON TABLE ar_customer IS
'AR Customer master. Every ratepayer, tenant, debtor is a customer. '
'Supports individuals, businesses, government entities, and employees.';

-- ---------------------------------------------------------------------
-- 2. AR INVOICE — Bills issued to customers
-- ---------------------------------------------------------------------
CREATE TABLE ar_invoice (
    invoice_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    invoice_number      VARCHAR(50) NOT NULL,
    customer_id         UUID NOT NULL REFERENCES ar_customer(customer_id),
    invoice_date        DATE NOT NULL,
    due_date            DATE NOT NULL,
    invoice_type        VARCHAR(50) NOT NULL,
        -- PROPERTY_RATE, PERSONAL_LEVY, MARKET_FEE, BUS_STATION_FEE,
        -- PARKING_FEE, LICENSE, PERMIT, RENT, SERVICE_CHARGE,
        -- COMMERCIAL_VENTURE, FINE, PENALTY, OTHER
    description         TEXT,
    fund_id             UUID NOT NULL REFERENCES fund(fund_id),
        -- Which fund receives the revenue
    cost_center_id      UUID NOT NULL REFERENCES cost_center(cost_center_id),
        -- Which cost center is responsible
    subtotal            NUMERIC(15,2) NOT NULL,
    tax_amount          NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_amount        NUMERIC(15,2) NOT NULL,
    amount_paid         NUMERIC(15,2) NOT NULL DEFAULT 0,
    balance             NUMERIC(15,2) NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'OUTSTANDING',
        -- DRAFT, OUTSTANDING, PARTIAL, PAID, OVERDUE, CANCELLED, WRITTEN_OFF
    gl_journal_id       UUID REFERENCES journal_entry(journal_id),
        -- The GL journal created for this invoice
    period_id           UUID REFERENCES fiscal_period(period_id),
        -- The fiscal period for the invoice
    cancelled_at        TIMESTAMPTZ,
    cancelled_by        UUID,
    cancellation_reason TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID NOT NULL,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    CONSTRAINT uq_ar_invoice_number
        UNIQUE (authority_code, invoice_number),
    CONSTRAINT chk_ar_invoice_type
        CHECK (invoice_type IN (
            'PROPERTY_RATE', 'PERSONAL_LEVY', 'MARKET_FEE', 'BUS_STATION_FEE',
            'PARKING_FEE', 'LICENSE', 'PERMIT', 'RENT', 'SERVICE_CHARGE',
            'COMMERCIAL_VENTURE', 'FINE', 'PENALTY', 'OTHER'
        )),
    CONSTRAINT chk_ar_invoice_status
        CHECK (status IN (
            'DRAFT', 'OUTSTANDING', 'PARTIAL', 'PAID', 'OVERDUE',
            'CANCELLED', 'WRITTEN_OFF'
        )),
    CONSTRAINT chk_ar_invoice_amounts
        CHECK (
            subtotal >= 0
            AND tax_amount >= 0
            AND total_amount >= 0
            AND amount_paid >= 0
            AND balance >= 0
        ),
    CONSTRAINT chk_ar_invoice_dates
        CHECK (due_date >= invoice_date),
    CONSTRAINT chk_ar_invoice_total
        CHECK (total_amount = subtotal + tax_amount),
    CONSTRAINT chk_ar_invoice_balance
        CHECK (balance = total_amount - amount_paid)
);

CREATE INDEX idx_ar_invoice_authority ON ar_invoice(authority_code);
CREATE INDEX idx_ar_invoice_number ON ar_invoice(invoice_number);
CREATE INDEX idx_ar_invoice_customer ON ar_invoice(customer_id);
CREATE INDEX idx_ar_invoice_date ON ar_invoice(authority_code, invoice_date DESC);
CREATE INDEX idx_ar_invoice_due_date ON ar_invoice(due_date)
    WHERE status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE');
CREATE INDEX idx_ar_invoice_status ON ar_invoice(authority_code, status);
CREATE INDEX idx_ar_invoice_type ON ar_invoice(authority_code, invoice_type);
CREATE INDEX idx_ar_invoice_fund ON ar_invoice(fund_id);
CREATE INDEX idx_ar_invoice_journal ON ar_invoice(gl_journal_id)
    WHERE gl_journal_id IS NOT NULL;

COMMENT ON TABLE ar_invoice IS
'AR Invoice — a bill issued to a customer. Posts to GL (debit AR '
'control account, credit revenue account). Tracks payment status.';

-- ---------------------------------------------------------------------
-- 3. AR INVOICE LINE — Individual line items on an invoice
-- ---------------------------------------------------------------------
CREATE TABLE ar_invoice_line (
    line_id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id          UUID NOT NULL REFERENCES ar_invoice(invoice_id) ON DELETE CASCADE,
    line_number         INTEGER NOT NULL,
    description         TEXT NOT NULL,
    account_id          UUID NOT NULL REFERENCES chart_of_accounts(account_id),
        -- Revenue account (e.g. 40100 Property Rates)
    quantity            NUMERIC(15,4) NOT NULL DEFAULT 1,
    unit_price          NUMERIC(15,2) NOT NULL,
    line_total          NUMERIC(15,2) NOT NULL,
    tax_rate            NUMERIC(5,2) NOT NULL DEFAULT 0,
    tax_amount          NUMERIC(15,2) NOT NULL DEFAULT 0,
    reference           VARCHAR(100),
    -- Extended fields for property rates
    property_reference  VARCHAR(50),
    -- Extended fields for personal levy
    employee_reference  VARCHAR(50),
    period_start        DATE,
    period_end          DATE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_ar_invoice_line_number
        UNIQUE (invoice_id, line_number),
    CONSTRAINT chk_ar_invoice_line_amounts
        CHECK (
            quantity > 0
            AND unit_price >= 0
            AND line_total >= 0
            AND tax_rate >= 0
            AND tax_amount >= 0
        )
);

CREATE INDEX idx_ar_invoice_line_invoice ON ar_invoice_line(invoice_id);
CREATE INDEX idx_ar_invoice_line_account ON ar_invoice_line(account_id);
CREATE INDEX idx_ar_invoice_line_property ON ar_invoice_line(property_reference)
    WHERE property_reference IS NOT NULL;
CREATE INDEX idx_ar_invoice_line_employee ON ar_invoice_line(employee_reference)
    WHERE employee_reference IS NOT NULL;

COMMENT ON TABLE ar_invoice_line IS
'AR Invoice Line — individual line items on an invoice. Each line '
'has its own revenue account and can reference a property or employee.';

-- ---------------------------------------------------------------------
-- 4. AUTO-AUDIT TRIGGERS
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_ar_customer ON ar_customer;
CREATE TRIGGER trg_audit_ar_customer
    AFTER INSERT OR UPDATE OR DELETE ON ar_customer
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS trg_audit_ar_invoice ON ar_invoice;
CREATE TRIGGER trg_audit_ar_invoice
    AFTER INSERT OR UPDATE OR DELETE ON ar_invoice
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

DROP TRIGGER IF EXISTS trg_audit_ar_invoice_line ON ar_invoice_line;
CREATE TRIGGER trg_audit_ar_invoice_line
    AFTER INSERT OR UPDATE OR DELETE ON ar_invoice_line
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 5. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AR_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_ar_customer_invoice_tables',
        'migration', 'V78',
        'purpose', 'Accounts Receivable — master data and billing',
        'tables_created', ARRAY[
            'ar_customer',
            'ar_invoice',
            'ar_invoice_line'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
