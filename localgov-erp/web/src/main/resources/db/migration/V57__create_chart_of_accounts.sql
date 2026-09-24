-- =====================================================================
-- V57__create_chart_of_accounts.sql
-- Chart of Accounts — The Structure of Every Financial Entry
-- =====================================================================
-- The Chart of Accounts (COA) is the foundation of the General Ledger.
-- Every journal line references exactly one COA account.
--
-- Design principles:
--   1. IPSAS-compliant account classification
--   2. Hierarchical (parent → child → grandchild)
--   3. Supports sub-ledger control accounts (AR, AP, Payroll, etc.)
--   4. Effective dating (accounts can be opened and closed)
--   5. Control account flags (prevent manual posting to control accounts)
--
-- Account types:
--   ASSET      — what the council owns
--   LIABILITY  — what the council owes
--   EQUITY     — net assets (accumulated surplus, reserves)
--   REVENUE    — income
--   EXPENSE    — expenditure
--   MEMO       — statistical / off-balance-sheet
-- =====================================================================

CREATE TABLE chart_of_accounts (
    account_id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_code            VARCHAR(20) NOT NULL UNIQUE,
    account_name            VARCHAR(255) NOT NULL,
    account_type            VARCHAR(20) NOT NULL,
    account_class           VARCHAR(50) NOT NULL,
    normal_balance          VARCHAR(10) NOT NULL,
    parent_account_id       UUID REFERENCES chart_of_accounts(account_id),
    is_postable             BOOLEAN NOT NULL DEFAULT TRUE,
        -- FALSE if this is a header/parent account (cannot post directly)
    is_control_account      BOOLEAN NOT NULL DEFAULT FALSE,
        -- TRUE if this is a control account for a sub-ledger
    control_account_for     VARCHAR(20),
        -- AR, AP, PAYROLL, ASSETS, INVENTORY, CASH
        -- Only set if is_control_account = TRUE
    is_bank_account         BOOLEAN NOT NULL DEFAULT FALSE,
        -- TRUE if this account represents a specific bank account
    currency                VARCHAR(3) NOT NULL DEFAULT 'ZMW',
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from          DATE NOT NULL,
    effective_to            DATE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by              UUID,
    description             TEXT,
    CONSTRAINT chk_coa_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from),
    CONSTRAINT chk_coa_type
        CHECK (account_type IN (
            'ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE', 'MEMO'
        )),
    CONSTRAINT chk_coa_class
        CHECK (account_class IN (
            'CURRENT_ASSET', 'NON_CURRENT_ASSET',
            'CURRENT_LIABILITY', 'NON_CURRENT_LIABILITY',
            'EQUITY',
            'OPERATING_REVENUE', 'CAPITAL_REVENUE', 'OTHER_REVENUE',
            'OPERATING_EXPENSE', 'CAPITAL_EXPENSE', 'OTHER_EXPENSE',
            'MEMO'
        )),
    CONSTRAINT chk_coa_normal_balance
        CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    CONSTRAINT chk_coa_control_account
        CHECK (
            (is_control_account = FALSE AND control_account_for IS NULL)
            OR (is_control_account = TRUE AND control_account_for IS NOT NULL)
        ),
    CONSTRAINT chk_coa_control_type
        CHECK (control_account_for IS NULL OR control_account_for IN (
            'AR', 'AP', 'PAYROLL', 'ASSETS', 'INVENTORY', 'CASH'
        )),
    CONSTRAINT chk_coa_postable
        CHECK (
            (is_postable = FALSE)  -- header accounts have no balance
            OR (is_postable = TRUE) -- leaf accounts are postable
        )
);

-- Primary lookups
CREATE INDEX idx_coa_code ON chart_of_accounts(account_code);
CREATE INDEX idx_coa_type ON chart_of_accounts(account_type, account_class);
CREATE INDEX idx_coa_parent ON chart_of_accounts(parent_account_id);
CREATE INDEX idx_coa_active ON chart_of_accounts(account_code) WHERE is_active = TRUE;

-- Sub-ledger control account lookups
CREATE INDEX idx_coa_control ON chart_of_accounts(control_account_for)
    WHERE is_control_account = TRUE;

-- Bank account lookups
CREATE INDEX idx_coa_bank ON chart_of_accounts(account_code)
    WHERE is_bank_account = TRUE;

-- Full-text search on account names
CREATE INDEX idx_coa_name_search ON chart_of_accounts
    USING gin(to_tsvector('english', account_name));

COMMENT ON TABLE chart_of_accounts IS
'Chart of Accounts — the structure of every financial entry. '
'Every journal line references exactly one COA account. '
'Accounts are hierarchical, effective-dated, and IPSAS-classified.';

COMMENT ON COLUMN chart_of_accounts.is_postable IS
'FALSE for header/parent accounts (used only for grouping). '
'TRUE for leaf accounts (can receive journal lines).';

COMMENT ON COLUMN chart_of_accounts.is_control_account IS
'TRUE if this account is a control account for a sub-ledger. '
'Control accounts cannot be posted to directly — they are '
'updated only through the sub-ledger (AR, AP, Payroll, etc.).';

COMMENT ON COLUMN chart_of_accounts.control_account_for IS
'Identifies which sub-ledger this account controls: '
'AR (Accounts Receivable), AP (Accounts Payable), PAYROLL, '
'ASSETS, INVENTORY, or CASH. NULL if not a control account.';

COMMENT ON COLUMN chart_of_accounts.normal_balance IS
'DEBIT or CREDIT — which side increases the account balance. '
'Assets and Expenses: DEBIT. Liabilities, Equity, Revenue: CREDIT.';

-- ---------------------------------------------------------------------
-- HELPER FUNCTION — Look up an account by code
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_account_by_code(p_code VARCHAR)
RETURNS TABLE (
    account_id              UUID,
    account_code            VARCHAR,
    account_name            VARCHAR,
    account_type            VARCHAR,
    account_class           VARCHAR,
    normal_balance          VARCHAR,
    is_postable             BOOLEAN,
    is_control_account      BOOLEAN,
    control_account_for     VARCHAR,
    is_bank_account         BOOLEAN
)
LANGUAGE sql STABLE AS $$
    SELECT
        account_id, account_code, account_name, account_type,
        account_class, normal_balance, is_postable,
        is_control_account, control_account_for, is_bank_account
    FROM chart_of_accounts
    WHERE account_code = p_code
      AND is_active = TRUE
      AND (effective_to IS NULL OR effective_to >= CURRENT_DATE)
      AND effective_from <= CURRENT_DATE
    LIMIT 1;
$$;

COMMENT ON FUNCTION get_account_by_code IS
'Returns the active account matching a given code. '
'Fails safe (returns empty) if account is inactive or not yet effective.';

-- ---------------------------------------------------------------------
-- HELPER FUNCTION — Get all postable accounts
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_postable_accounts()
RETURNS TABLE (
    account_id              UUID,
    account_code            VARCHAR,
    account_name            VARCHAR,
    account_type            VARCHAR,
    account_class           VARCHAR,
    normal_balance          VARCHAR
)
LANGUAGE sql STABLE AS $$
    SELECT
        account_id, account_code, account_name, account_type,
        account_class, normal_balance
    FROM chart_of_accounts
    WHERE is_postable = TRUE
      AND is_active = TRUE
      AND (effective_to IS NULL OR effective_to >= CURRENT_DATE)
    ORDER BY account_code;
$$;

COMMENT ON FUNCTION get_postable_accounts IS
'Returns all postable (leaf) accounts, sorted by code. '
'Used for dropdown lists and validation.';

-- ---------------------------------------------------------------------
-- AUDIT — Record COA table creation (structure, not data)
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason, changed_by, record_hash)
VALUES (
    'CHART_OF_ACCOUNTS',
    gen_random_uuid(),
    'CREATE',
    jsonb_build_object(
        'action', 'create_table',
        'table', 'chart_of_accounts',
        'migration', 'V57',
        'purpose', 'Foundation of General Ledger'
    ),
    'Initial Chart of Accounts structure — foundation of GL',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256(('V57' || 'create_chart_of_accounts' || NOW()::text)::bytea), 'hex')
);
