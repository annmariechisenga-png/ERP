-- =====================================================================
-- V110__ap_views_reports.sql
-- Accounts Payable — Views and Reports
-- =====================================================================
-- Provides:
--   Views:
--     ap_outstanding_invoices   — unpaid / partial invoices with aging
--     ap_payments_unallocated   — payments not yet matched
--     ap_vendor_balances        — net balance per vendor
--     ap_age_analysis           — aging buckets per vendor
--     ap_expense_summary        — expenditure by account/fund/period
--   Functions:
--     get_vendor_statement()    — running ledger per vendor
--     get_ap_age_analysis()     — aging as-of date
--     get_ap_expense_summary()  — expenditure roll-up
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. VIEW — Outstanding / partial invoices with aging
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ap_outstanding_invoices AS
SELECT
    i.invoice_id,
    i.authority_code,
    i.invoice_number,
    i.vendor_invoice_number,
    v.vendor_id,
    v.vendor_number,
    v.vendor_name,
    i.invoice_date,
    i.received_date,
    i.due_date,
    i.invoice_type,
    i.description,
    i.total_amount,
    i.amount_paid,
    i.balance,
    i.status,
    (CURRENT_DATE - i.due_date) AS days_overdue,
    CASE
        WHEN i.due_date >= CURRENT_DATE THEN 'CURRENT'
        WHEN i.due_date >= CURRENT_DATE - INTERVAL '30 days' THEN '1-30'
        WHEN i.due_date >= CURRENT_DATE - INTERVAL '60 days' THEN '31-60'
        WHEN i.due_date >= CURRENT_DATE - INTERVAL '90 days' THEN '61-90'
        ELSE '90+'
    END AS aging_bucket,
    i.fund_id,
    f.fund_code,
    f.fund_name,
    i.cost_center_id,
    cc.cost_center_code,
    cc.cost_center_name
FROM ap_invoice i
JOIN ap_vendor v ON i.vendor_id = v.vendor_id
LEFT JOIN fund f ON i.fund_id = f.fund_id
LEFT JOIN cost_center cc ON i.cost_center_id = cc.cost_center_id
WHERE i.status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE')
  AND i.balance > 0;

COMMENT ON VIEW ap_outstanding_invoices IS
'All AP invoices that are unpaid or partially paid, with aging bucket '
'and days overdue.';

-- ---------------------------------------------------------------------
-- 2. VIEW — Payments not yet allocated
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ap_payments_unallocated AS
SELECT
    p.payment_id,
    p.authority_code,
    p.payment_number,
    p.payment_date,
    p.vendor_id,
    v.vendor_number,
    v.vendor_name,
    p.payment_method,
    p.payment_reference,
    p.amount,
    p.amount_allocated,
    p.amount_unallocated,
    p.status,
    p.is_reconciled
FROM ap_payment p
JOIN ap_vendor v ON p.vendor_id = v.vendor_id
WHERE p.amount_unallocated > 0
  AND p.status = 'POSTED';

COMMENT ON VIEW ap_payments_unallocated IS
'AP payments that still have unallocated funds. Should usually be zero. '
'Non-zero results indicate advance payments or unmatched receipts.';

-- ---------------------------------------------------------------------
-- 3. VIEW — Vendor balances
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ap_vendor_balances AS
SELECT
    v.vendor_id,
    v.authority_code,
    v.vendor_number,
    v.vendor_name,
    v.vendor_type,
    v.tpin,
    v.is_active,
    v.is_blacklisted,
    COALESCE(SUM(i.total_amount) FILTER (
        WHERE i.status NOT IN ('CANCELLED', 'DRAFT', 'PENDING_APPROVAL')
    ), 0) AS total_invoiced,
    COALESCE(SUM(i.amount_paid) FILTER (
        WHERE i.status NOT IN ('CANCELLED', 'DRAFT', 'PENDING_APPROVAL')
    ), 0) AS total_paid,
    COALESCE(SUM(i.balance) FILTER (
        WHERE i.status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE')
    ), 0) AS outstanding_balance,
    COUNT(i.invoice_id) FILTER (
        WHERE i.status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE')
    ) AS open_invoices,
    MAX(i.invoice_date) AS last_invoice_date
FROM ap_vendor v
LEFT JOIN ap_invoice i ON v.vendor_id = i.vendor_id
GROUP BY
    v.vendor_id, v.authority_code, v.vendor_number, v.vendor_name,
    v.vendor_type, v.tpin, v.is_active, v.is_blacklisted;

COMMENT ON VIEW ap_vendor_balances IS
'Net AP position per vendor: total invoiced, total paid, outstanding '
'balance, open invoice count, and last invoice date.';

-- ---------------------------------------------------------------------
-- 4. VIEW — Aging summary per vendor
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ap_age_analysis AS
SELECT
    v.authority_code,
    v.vendor_id,
    v.vendor_number,
    v.vendor_name,
    SUM(CASE WHEN i.aging_bucket = 'CURRENT' THEN i.balance ELSE 0 END) AS current_amount,
    SUM(CASE WHEN i.aging_bucket = '1-30'    THEN i.balance ELSE 0 END) AS bucket_1_30,
    SUM(CASE WHEN i.aging_bucket = '31-60'   THEN i.balance ELSE 0 END) AS bucket_31_60,
    SUM(CASE WHEN i.aging_bucket = '61-90'   THEN i.balance ELSE 0 END) AS bucket_61_90,
    SUM(CASE WHEN i.aging_bucket = '90+'     THEN i.balance ELSE 0 END) AS bucket_90_plus,
    SUM(i.balance) AS total_outstanding
FROM ap_vendor v
JOIN ap_outstanding_invoices i ON v.vendor_id = i.vendor_id
GROUP BY v.authority_code, v.vendor_id, v.vendor_number, v.vendor_name;

COMMENT ON VIEW ap_age_analysis IS
'AP aging summary per vendor: current, 1-30, 31-60, 61-90, 90+ days.';

-- ---------------------------------------------------------------------
-- 5. VIEW — Expenditure summary by account / fund / cost center
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ap_expense_summary AS
SELECT
    i.authority_code,
    i.invoice_type,
    coa.account_code,
    coa.account_name,
    f.fund_code,
    f.fund_name,
    cc.cost_center_code,
    cc.cost_center_name,
    DATE_TRUNC('month', i.invoice_date)::DATE AS period_month,
    COUNT(DISTINCT i.invoice_id) AS invoice_count,
    SUM(l.line_total + l.tax_amount - l.withholding_tax) AS net_expense
FROM ap_invoice i
JOIN ap_invoice_line l ON i.invoice_id = l.invoice_id
JOIN chart_of_accounts coa ON l.account_id = coa.account_id
LEFT JOIN fund f ON i.fund_id = f.fund_id
LEFT JOIN cost_center cc ON i.cost_center_id = cc.cost_center_id
WHERE i.status NOT IN ('CANCELLED', 'DRAFT', 'PENDING_APPROVAL')
GROUP BY
    i.authority_code, i.invoice_type,
    coa.account_code, coa.account_name,
    f.fund_code, f.fund_name,
    cc.cost_center_code, cc.cost_center_name,
    DATE_TRUNC('month', i.invoice_date);

COMMENT ON VIEW ap_expense_summary IS
'AP expenditure roll-up by account, fund, cost center, and month.';

-- ---------------------------------------------------------------------
-- 6. FUNCTION — Vendor statement (running ledger)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_vendor_statement(
    p_vendor_id UUID,
    p_from_date DATE,
    p_to_date DATE
) RETURNS TABLE (
    entry_date DATE,
    entry_type VARCHAR,
    reference VARCHAR,
    description TEXT,
    debit NUMERIC,
    credit NUMERIC,
    running_balance NUMERIC
)
LANGUAGE sql STABLE AS $$
    WITH entries AS (
        -- Invoices increase what we owe → credit to AP
        SELECT
            i.invoice_date AS entry_date,
            'INVOICE'::VARCHAR AS entry_type,
            i.invoice_number::VARCHAR AS reference,
            ('Invoice: ' || COALESCE(i.description, ''))::TEXT AS description,
            0::NUMERIC AS debit,
            i.total_amount AS credit,
            i.created_at AS sort_ts
        FROM ap_invoice i
        WHERE i.vendor_id = p_vendor_id
          AND i.status NOT IN ('CANCELLED', 'DRAFT', 'PENDING_APPROVAL')
          AND i.invoice_date BETWEEN p_from_date AND p_to_date

        UNION ALL

        -- Payments decrease what we owe → debit to AP
        SELECT
            p.payment_date AS entry_date,
            'PAYMENT'::VARCHAR AS entry_type,
            p.payment_number::VARCHAR AS reference,
            ('Payment via ' || p.payment_method)::TEXT AS description,
            p.amount AS debit,
            0::NUMERIC AS credit,
            p.created_at AS sort_ts
        FROM ap_payment p
        WHERE p.vendor_id = p_vendor_id
          AND p.status = 'POSTED'
          AND p.payment_date BETWEEN p_from_date AND p_to_date
    )
    SELECT
        entry_date,
        entry_type,
        reference,
        description,
        debit,
        credit,
        SUM(credit - debit) OVER (
            ORDER BY entry_date, sort_ts
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_balance
    FROM entries
    ORDER BY entry_date, sort_ts;
$$;

COMMENT ON FUNCTION get_vendor_statement IS
'Vendor statement — invoices (credit) and payments (debit) with running '
'balance. Running balance is the amount owed to the vendor at each point.
Example:
  SELECT * FROM get_vendor_statement(
      p_vendor_id := ''...uuid...''::UUID,
      p_from_date := CURRENT_DATE - INTERVAL ''90 days'',
      p_to_date := CURRENT_DATE
  );';

-- ---------------------------------------------------------------------
-- 7. FUNCTION — Aging analysis as-of a specific date
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ap_age_analysis(
    p_authority_code VARCHAR,
    p_as_of_date DATE
) RETURNS TABLE (
    vendor_number VARCHAR,
    vendor_name VARCHAR,
    current_amount NUMERIC,
    bucket_1_30 NUMERIC,
    bucket_31_60 NUMERIC,
    bucket_61_90 NUMERIC,
    bucket_90_plus NUMERIC,
    total_outstanding NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT
        v.vendor_number,
        v.vendor_name,
        COALESCE(SUM(CASE
            WHEN i.due_date >= p_as_of_date THEN i.balance ELSE 0 END), 0) AS current_amount,
        COALESCE(SUM(CASE
            WHEN i.due_date < p_as_of_date
             AND i.due_date >= p_as_of_date - INTERVAL '30 days'
            THEN i.balance ELSE 0 END), 0) AS bucket_1_30,
        COALESCE(SUM(CASE
            WHEN i.due_date < p_as_of_date - INTERVAL '30 days'
             AND i.due_date >= p_as_of_date - INTERVAL '60 days'
            THEN i.balance ELSE 0 END), 0) AS bucket_31_60,
        COALESCE(SUM(CASE
            WHEN i.due_date < p_as_of_date - INTERVAL '60 days'
             AND i.due_date >= p_as_of_date - INTERVAL '90 days'
            THEN i.balance ELSE 0 END), 0) AS bucket_61_90,
        COALESCE(SUM(CASE
            WHEN i.due_date < p_as_of_date - INTERVAL '90 days'
            THEN i.balance ELSE 0 END), 0) AS bucket_90_plus,
        COALESCE(SUM(i.balance), 0) AS total_outstanding
    FROM ap_vendor v
    LEFT JOIN ap_invoice i
        ON v.vendor_id = i.vendor_id
       AND i.status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE')
       AND i.balance > 0
       AND i.invoice_date <= p_as_of_date
    WHERE v.authority_code = p_authority_code
      AND v.is_active = TRUE
    GROUP BY v.vendor_number, v.vendor_name
    HAVING COALESCE(SUM(i.balance), 0) > 0
    ORDER BY v.vendor_number;
$$;

COMMENT ON FUNCTION get_ap_age_analysis IS
'AP aging analysis as of a specific date, one row per vendor with '
'outstanding balance. Only includes invoices issued on or before the '
'as-of date.
Example:
  SELECT * FROM get_ap_age_analysis(''CHILANGA'', CURRENT_DATE);';

-- ---------------------------------------------------------------------
-- 8. FUNCTION — Expenditure summary
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ap_expense_summary(
    p_authority_code VARCHAR,
    p_from_date DATE,
    p_to_date DATE
) RETURNS TABLE (
    invoice_type VARCHAR,
    account_code VARCHAR,
    account_name VARCHAR,
    fund_code VARCHAR,
    cost_center_code VARCHAR,
    invoice_count BIGINT,
    net_expense NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT
        i.invoice_type,
        coa.account_code,
        coa.account_name,
        f.fund_code,
        cc.cost_center_code,
        COUNT(DISTINCT i.invoice_id) AS invoice_count,
        SUM(l.line_total + l.tax_amount - l.withholding_tax) AS net_expense
    FROM ap_invoice i
    JOIN ap_invoice_line l ON i.invoice_id = l.invoice_id
    JOIN chart_of_accounts coa ON l.account_id = coa.account_id
    LEFT JOIN fund f ON i.fund_id = f.fund_id
    LEFT JOIN cost_center cc ON i.cost_center_id = cc.cost_center_id
    WHERE i.authority_code = p_authority_code
      AND i.invoice_date BETWEEN p_from_date AND p_to_date
      AND i.status NOT IN ('CANCELLED', 'DRAFT', 'PENDING_APPROVAL')
    GROUP BY
        i.invoice_type,
        coa.account_code, coa.account_name,
        f.fund_code,
        cc.cost_center_code
    ORDER BY coa.account_code, f.fund_code, cc.cost_center_code;
$$;

COMMENT ON FUNCTION get_ap_expense_summary IS
'AP expenditure summary for a date range, grouped by invoice type, '
'account, fund, and cost center.
Example:
  SELECT * FROM get_ap_expense_summary(
      ''CHILANGA'',
      DATE_TRUNC(''month'', CURRENT_DATE)::DATE,
      CURRENT_DATE
  );';

-- ---------------------------------------------------------------------
-- 9. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AP_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'ap_views_and_reports',
        'migration', 'V93',
        'views_created', ARRAY[
            'ap_outstanding_invoices',
            'ap_payments_unallocated',
            'ap_vendor_balances',
            'ap_age_analysis',
            'ap_expense_summary'
        ],
        'functions_created', ARRAY[
            'get_vendor_statement',
            'get_ap_age_analysis',
            'get_ap_expense_summary'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
