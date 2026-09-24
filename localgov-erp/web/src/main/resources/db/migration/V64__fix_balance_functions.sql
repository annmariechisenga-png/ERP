-- =====================================================================
-- V64__fix_balance_functions.sql
-- Fix: Balance functions must include REVERSED journals
-- =====================================================================
-- Bug: get_account_balance and similar functions only counted
-- POSTED journals. When a journal is reversed, its status changes
-- to REVERSED, and it dropped out of the balance calculation.
-- This caused balances to be wrong after reversals.
--
-- Fix: Include both POSTED and REVERSED journals in all balance
-- calculations. The reversal journal (POSTED) cancels the original
-- journal (REVERSED), producing the correct net balance.
--
-- Affects:
--   - get_account_balance
--   - get_fund_balance
--   - get_cost_center_balance
--   - get_account_balance_by_type
--   - get_trial_balance
--   - trial_balance (view)
--   - account_balances (view)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Fix get_account_balance
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_account_balance(
    p_account_code VARCHAR,
    p_fund_code VARCHAR DEFAULT NULL,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
    LEFT JOIN fund f ON jl.fund_id = f.fund_id
    WHERE coa.account_code = p_account_code
      AND (p_fund_code IS NULL OR f.fund_code = p_fund_code)
      AND je.status IN ('POSTED', 'REVERSED')
      AND je.journal_date <= p_as_of_date;
$$;

-- ---------------------------------------------------------------------
-- 2. Fix get_fund_balance
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_fund_balance(
    p_fund_code VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN fund f ON jl.fund_id = f.fund_id
    WHERE f.fund_code = p_fund_code
      AND je.status IN ('POSTED', 'REVERSED')
      AND je.journal_date <= p_as_of_date;
$$;

-- ---------------------------------------------------------------------
-- 3. Fix get_cost_center_balance
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_cost_center_balance(
    p_cost_center_code VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN cost_center cc ON jl.cost_center_id = cc.cost_center_id
    WHERE cc.cost_center_code = p_cost_center_code
      AND je.status IN ('POSTED', 'REVERSED')
      AND je.journal_date <= p_as_of_date;
$$;

-- ---------------------------------------------------------------------
-- 4. Fix get_account_balance_by_type
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_account_balance_by_type(
    p_account_type VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
) RETURNS NUMERIC
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(SUM(jl.debit - jl.credit), 0)
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
    WHERE coa.account_type = p_account_type
      AND je.status IN ('POSTED', 'REVERSED')
      AND je.journal_date <= p_as_of_date;
$$;

-- ---------------------------------------------------------------------
-- 5. Fix get_trial_balance
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_trial_balance(
    p_authority_code VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    account_code VARCHAR,
    account_name VARCHAR,
    account_type VARCHAR,
    account_class VARCHAR,
    normal_balance VARCHAR,
    total_debit NUMERIC,
    total_credit NUMERIC,
    net_balance NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT
        coa.account_code,
        coa.account_name,
        coa.account_type,
        coa.account_class,
        coa.normal_balance,
        SUM(jl.debit) AS total_debit,
        SUM(jl.credit) AS total_credit,
        SUM(jl.debit - jl.credit) AS net_balance
    FROM journal_line jl
    JOIN journal_entry je ON jl.journal_id = je.journal_id
    JOIN chart_of_accounts coa ON jl.account_id = coa.account_id
    WHERE je.authority_code = p_authority_code
      AND je.status IN ('POSTED', 'REVERSED')
      AND je.journal_date <= p_as_of_date
    GROUP BY
        coa.account_code, coa.account_name, coa.account_type,
        coa.account_class, coa.normal_balance
    HAVING SUM(jl.debit) != 0 OR SUM(jl.credit) != 0
    ORDER BY coa.account_code;
$$;

-- ---------------------------------------------------------------------
-- 6. Fix trial_balance view
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
WHERE je.status IN ('POSTED', 'REVERSED')
GROUP BY
    je.authority_code, jl.account_id, coa.account_code, coa.account_name,
    coa.account_type, coa.account_class, coa.normal_balance,
    jl.fund_id, f.fund_code, f.fund_name,
    jl.cost_center_id, cc.cost_center_code, cc.cost_center_name,
    fy.year_number, fp.period_number, fp.period_name;

-- ---------------------------------------------------------------------
-- 7. Fix account_balances view
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
WHERE je.status IN ('POSTED', 'REVERSED')
GROUP BY
    je.authority_code, jl.account_id, coa.account_code, coa.account_name,
    coa.account_type, coa.normal_balance, jl.fund_id, f.fund_code;

-- ---------------------------------------------------------------------
-- AUDIT LOG
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, old_value, new_value, change_reason,
     changed_by, record_hash)
VALUES (
    'GENERAL_LEDGER',
    gen_random_uuid(),
    'UPDATE',
    jsonb_build_object(
        'bug', 'Balance functions excluded REVERSED journals',
        'impact', 'Balances wrong after reversal'
    ),
    jsonb_build_object(
        'fix', 'Include POSTED and REVERSED journals in all balance calculations',
        'migration', 'V64',
        'functions_updated', ARRAY[
            'get_account_balance',
            'get_fund_balance',
            'get_cost_center_balance',
            'get_account_balance_by_type',
            'get_trial_balance',
            'trial_balance (view)',
            'account_balances (view)'
        ]
    ),
    'Bug fix — include REVERSED journals in balance calculations',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256(('V64' || 'fix_balance_functions' || NOW()::text)::bytea), 'hex')
);
