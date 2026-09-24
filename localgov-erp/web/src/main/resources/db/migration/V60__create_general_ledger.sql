-- =====================================================================
-- V60__create_general_ledger.sql
-- General Ledger — The Heart of the Accounting System
-- =====================================================================
-- The GL is the source of truth for all financial reporting. Every
-- financial transaction passes through here. Every other module feeds
-- it: Revenue, Expenditure, Payroll, Assets, Inventory, Treasury.
--
-- Design principles:
--   1. Double-entry: Debits = Credits for every journal
--   2. Every line has account + fund + cost center
--   3. Journals belong to a fiscal period (from V59)
--   4. Status workflow: DRAFT → SUBMITTED → APPROVED → POSTED → REVERSED
--   5. Posted journals are immutable (cannot edit, only reverse)
--   6. Audit logging on all state changes
--   7. Enforced integrity: no posting to closed periods
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. JOURNAL ENTRY (Header)
-- ---------------------------------------------------------------------
CREATE TABLE journal_entry (
    journal_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    journal_number      VARCHAR(50) NOT NULL,
    journal_date        DATE NOT NULL,
    period_id           UUID NOT NULL REFERENCES fiscal_period(period_id),
    journal_type        VARCHAR(50) NOT NULL,
    source_module       VARCHAR(50),
    source_id           UUID,
    description         TEXT NOT NULL,
    reference           VARCHAR(100),
    status              VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    total_debit         NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_credit        NUMERIC(15,2) NOT NULL DEFAULT 0,
    is_reversal         BOOLEAN NOT NULL DEFAULT FALSE,
    reversed_journal_id UUID REFERENCES journal_entry(journal_id),
    created_by          UUID NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    submitted_by        UUID,
    submitted_at        TIMESTAMPTZ,
    approved_by         UUID,
    approved_at         TIMESTAMPTZ,
    posted_by           UUID,
    posted_at           TIMESTAMPTZ,
    CONSTRAINT uq_journal_number
        UNIQUE (authority_code, journal_number),
    CONSTRAINT chk_journal_status
        CHECK (status IN (
            'DRAFT', 'SUBMITTED', 'APPROVED', 'POSTED', 'REVERSED', 'CANCELLED'
        )),
    CONSTRAINT chk_journal_type
        CHECK (journal_type IN (
            'MANUAL', 'PAYROLL', 'REVENUE', 'EXPENDITURE', 'DEPRECIATION',
            'ACCRUAL', 'ADJUSTMENT', 'REVERSAL', 'OPENING_BALANCE',
            'INTER_FUND_TRANSFER', 'CDF_PROJECT', 'LGEF_RECEIPT', 'OTHER'
        )),
    CONSTRAINT chk_journal_totals
        CHECK (total_debit >= 0 AND total_credit >= 0),
    CONSTRAINT chk_journal_reversal
        CHECK (
            (is_reversal = FALSE AND reversed_journal_id IS NULL)
            OR (is_reversal = TRUE AND reversed_journal_id IS NOT NULL)
        )
);

-- ---------------------------------------------------------------------
-- 2. JOURNAL LINE (Details)
-- ---------------------------------------------------------------------
CREATE TABLE journal_line (
    line_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_id      UUID NOT NULL REFERENCES journal_entry(journal_id) ON DELETE CASCADE,
    line_number     INTEGER NOT NULL,
    account_id      UUID NOT NULL REFERENCES chart_of_accounts(account_id),
    fund_id         UUID NOT NULL REFERENCES fund(fund_id),
    cost_center_id  UUID NOT NULL REFERENCES cost_center(cost_center_id),
    debit           NUMERIC(15,2) NOT NULL DEFAULT 0,
    credit          NUMERIC(15,2) NOT NULL DEFAULT 0,
    description     TEXT,
    reference       VARCHAR(100),
    CONSTRAINT uq_journal_line_number
        UNIQUE (journal_id, line_number),
    CONSTRAINT chk_journal_line_amounts
        CHECK (debit >= 0 AND credit >= 0),
    CONSTRAINT chk_journal_line_exclusive
        CHECK (
            (debit > 0 AND credit = 0)
            OR (credit > 0 AND debit = 0)
        ),
    CONSTRAINT chk_journal_line_not_zero
        CHECK (debit > 0 OR credit > 0)
);

-- ---------------------------------------------------------------------
-- 3. INDEXES
-- ---------------------------------------------------------------------
CREATE INDEX idx_je_authority_date ON journal_entry(authority_code, journal_date DESC);
CREATE INDEX idx_je_period ON journal_entry(period_id);
CREATE INDEX idx_je_status ON journal_entry(status) WHERE status NOT IN ('POSTED', 'REVERSED');
CREATE INDEX idx_je_type ON journal_entry(journal_type, journal_date DESC);
CREATE INDEX idx_je_source ON journal_entry(source_module, source_id)
    WHERE source_module IS NOT NULL;
CREATE INDEX idx_je_reversal ON journal_entry(reversed_journal_id)
    WHERE reversed_journal_id IS NOT NULL;

CREATE INDEX idx_jl_journal ON journal_line(journal_id);
CREATE INDEX idx_jl_account ON journal_line(account_id);
CREATE INDEX idx_jl_fund ON journal_line(fund_id);
CREATE INDEX idx_jl_cost_center ON journal_line(cost_center_id);
CREATE INDEX idx_jl_account_fund_cc ON journal_line(account_id, fund_id, cost_center_id);

-- ---------------------------------------------------------------------
-- 4. TRIGGER — Validate journal before posting
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION validate_journal_before_post()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_total_debit NUMERIC;
    v_total_credit NUMERIC;
    v_line_count INTEGER;
    v_period_closed BOOLEAN;
BEGIN
    -- Only validate on transition to POSTED
    IF NEW.status = 'POSTED' AND OLD.status != 'POSTED' THEN
        -- Check period is open
        SELECT is_closed INTO v_period_closed
        FROM fiscal_period
        WHERE period_id = NEW.period_id;

        IF v_period_closed THEN
            RAISE EXCEPTION 'Cannot post to a closed fiscal period. Period ID: %',
                NEW.period_id;
        END IF;

        -- Count lines
        SELECT COUNT(*) INTO v_line_count
        FROM journal_line
        WHERE journal_id = NEW.journal_id;

        IF v_line_count < 2 THEN
            RAISE EXCEPTION 'Journal must have at least 2 lines (double-entry). Found: %',
                v_line_count;
        END IF;

        -- Verify debits = credits
        SELECT
            COALESCE(SUM(debit), 0),
            COALESCE(SUM(credit), 0)
        INTO v_total_debit, v_total_credit
        FROM journal_line
        WHERE journal_id = NEW.journal_id;

        IF v_total_debit != v_total_credit THEN
            RAISE EXCEPTION 'Journal is not balanced. Debits: %, Credits: %',
                v_total_debit, v_total_credit;
        END IF;

        IF v_total_debit = 0 THEN
            RAISE EXCEPTION 'Journal total is zero';
        END IF;

        -- Set the totals
        NEW.total_debit := v_total_debit;
        NEW.total_credit := v_total_credit;
    END IF;

    -- Prevent modification of POSTED journals
    IF OLD.status = 'POSTED' AND NEW.status != 'REVERSED' THEN
        RAISE EXCEPTION 'Posted journals are immutable. Only reversal is allowed.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validate_journal_before_post
    BEFORE UPDATE ON journal_entry
    FOR EACH ROW
    EXECUTE FUNCTION validate_journal_before_post();

-- ---------------------------------------------------------------------
-- 5. TRIGGER — Prevent modification of lines on posted journals
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION prevent_journal_line_change()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_status VARCHAR;
    v_journal_id UUID;
BEGIN
    v_journal_id := COALESCE(NEW.journal_id, OLD.journal_id);

    SELECT status INTO v_status
    FROM journal_entry
    WHERE journal_id = v_journal_id;

    IF v_status IN ('POSTED', 'REVERSED') THEN
        RAISE EXCEPTION 'Cannot modify lines of a % journal (journal_id: %)',
            v_status, v_journal_id;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_prevent_journal_line_change
    BEFORE INSERT OR UPDATE OR DELETE ON journal_line
    FOR EACH ROW
    EXECUTE FUNCTION prevent_journal_line_change();

-- ---------------------------------------------------------------------
-- 6. TRIAL BALANCE VIEW
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW trial_balance AS
SELECT
    je.authority_code,
    jl.account_id,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    coa.account_class,
    coa.normal_balance,
    jl.fund_id,
    f.fund_code,
    f.fund_name,
    jl.cost_center_id,
    cc.cost_center_code,
    cc.cost_center_name,
    fy.year_number,
    fp.period_number,
    fp.period_name,
    SUM(jl.debit) AS total_debit,
    SUM(jl.credit) AS total_credit,
    SUM(jl.debit - jl.credit) AS net_balance
FROM journal_line jl
JOIN journal_entry je ON jl.journal_id = je.journal_id
JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
JOIN fund f ON jl.fund_id = f.fund_id
JOIN cost_center cc ON jl.cost_center_id = cc.cost_center_id
JOIN fiscal_period fp ON je.period_id = fp.period_id
JOIN fiscal_year fy ON fp.fiscal_year_id = fy.fiscal_year_id
WHERE je.status = 'POSTED'
GROUP BY
    je.authority_code, jl.account_id, coa.account_code, coa.account_name,
    coa.account_type, coa.account_class, coa.normal_balance,
    jl.fund_id, f.fund_code, f.fund_name,
    jl.cost_center_id, cc.cost_center_code, cc.cost_center_name,
    fy.year_number, fp.period_number, fp.period_name;

COMMENT ON VIEW trial_balance IS
'Trial balance — aggregates all posted journal lines by account, fund, '
'cost center, and period. Shows debits, credits, and net balance.';

-- ---------------------------------------------------------------------
-- 7. ACCOUNT BALANCE VIEW (current balances)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW account_balances AS
SELECT
    je.authority_code,
    jl.account_id,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    coa.normal_balance,
    jl.fund_id,
    f.fund_code,
    SUM(jl.debit) AS total_debit,
    SUM(jl.credit) AS total_credit,
    SUM(jl.debit - jl.credit) AS net_balance
FROM journal_line jl
JOIN journal_entry je ON jl.journal_id = je.journal_id
JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
JOIN fund f ON jl.fund_id = f.fund_id
WHERE je.status = 'POSTED'
GROUP BY
    je.authority_code, jl.account_id, coa.account_code, coa.account_name,
    coa.account_type, coa.normal_balance, jl.fund_id, f.fund_code;

COMMENT ON VIEW account_balances IS
'Current balance per account per fund. Sum of all posted debits and '
'credits. Used for real-time account balance queries.';

-- ---------------------------------------------------------------------
-- 8. JOURNAL ENTRY SUMMARY VIEW
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW journal_entry_summary AS
SELECT
    je.journal_id,
    je.authority_code,
    je.journal_number,
    je.journal_date,
    je.journal_type,
    je.source_module,
    je.description,
    je.status,
    je.total_debit,
    je.total_credit,
    COUNT(jl.line_id) AS line_count,
    je.created_by,
    je.created_at,
    je.posted_at
FROM journal_entry je
LEFT JOIN journal_line jl ON je.journal_id = jl.journal_id
GROUP BY
    je.journal_id, je.authority_code, je.journal_number, je.journal_date,
    je.journal_type, je.source_module, je.description, je.status,
    je.total_debit, je.total_credit, je.created_by, je.created_at, je.posted_at;

COMMENT ON VIEW journal_entry_summary IS
'Journal entries with line count summary. Used for journal listings.';

-- ---------------------------------------------------------------------
-- 9. AUDIT LOG — Record GL table creation
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason, changed_by, record_hash)
VALUES (
    'GENERAL_LEDGER',
    gen_random_uuid(),
    'CREATE',
    jsonb_build_object(
        'action', 'create_tables',
        'tables', ARRAY['journal_entry', 'journal_line'],
        'migration', 'V60',
        'purpose', 'Double-entry General Ledger'
    ),
    'Initial General Ledger structure — source of truth for financial reporting',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256(('V60' || 'create_general_ledger' || NOW()::text)::bytea), 'hex')
);
