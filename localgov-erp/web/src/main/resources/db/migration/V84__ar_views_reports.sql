-- =====================================================================
-- V84__ar_views_reports.sql
-- Accounts Receivable — Views and Reports
-- =====================================================================
-- This is the final migration for the Accounts Receivable module.
-- It provides:
--   1. Views for common AR queries
--   2. Functions for customer statements and age analysis
--   3. Revenue summary reports
--
-- Views:
--   - ar_age_analysis        — Aging buckets per customer
--   - ar_outstanding_invoices — All unpaid and partially paid
--   - ar_receipts_unallocated — Receipts not yet applied
--   - ar_revenue_summary     — Revenue by type, fund, period
--   - ar_customer_balances   — Net balance per customer
--
-- Functions:
--   - get_customer_statement(customer_id, from_date, to_date)
--   - get_age_analysis(authority_code, as_of_date)
--   - get_ar_revenue_summary(authority_code, from_date, to_date)
-- =====================================================================

-- ---------------------------------------------------------------------
-- VIEW 1: ar_age_analysis
-- Aging buckets per invoice: current, 0-30, 31-60, 61-90, 90+ days
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ar_age_analysis AS
SELECT
    i.authority_code,
    i.invoice_id,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.invoice_type,
    i.total_amount,
    i.amount_paid,
    i.balance,
    i.status,
    c.customer_id,
    c.customer_number,
    c.customer_name,
    -- Days overdue (negative = not yet due)
    (CURRENT_DATE - i.due_date) AS days_overdue,
    -- Aging bucket
    CASE
        WHEN i.balance <= 0 THEN 'PAID'
        WHEN CURRENT_DATE <= i.due_date THEN 'CURRENT'
        WHEN CURRENT_DATE - i.due_date BETWEEN 1 AND 30 THEN '0-30_DAYS'
        WHEN CURRENT_DATE - i.due_date BETWEEN 31 AND 60 THEN '31-60_DAYS'
        WHEN CURRENT_DATE - i.due_date BETWEEN 61 AND 90 THEN '61-90_DAYS'
        ELSE '90+_DAYS'
    END AS aging_bucket
FROM ar_invoice i
JOIN ar_customer c ON i.customer_id = c.customer_id
WHERE i.status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE');

COMMENT ON VIEW ar_age_analysis IS
'AR aging analysis. Shows each unpaid invoice with its age and aging bucket. '
'Buckets: CURRENT, 0-30, 31-60, 61-90, 90+ days.';

-- ---------------------------------------------------------------------
-- VIEW 2: ar_outstanding_invoices
-- All unpaid and partially paid invoices
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ar_outstanding_invoices AS
SELECT
    i.authority_code,
    i.invoice_id,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    i.invoice_type,
    i.description,
    i.total_amount,
    i.amount_paid,
    i.balance,
    i.status,
    c.customer_number,
    c.customer_name,
    c.phone,
    c.email,
    f.fund_code,
    f.fund_name,
    cc.cost_center_code,
    cc.cost_center_name,
    CASE
        WHEN CURRENT_DATE > i.due_date THEN TRUE
        ELSE FALSE
    END AS is_overdue,
    CASE
        WHEN CURRENT_DATE > i.due_date THEN (CURRENT_DATE - i.due_date)
        ELSE 0
    END AS days_overdue
FROM ar_invoice i
JOIN ar_customer c ON i.customer_id = c.customer_id
LEFT JOIN fund f ON i.fund_id = f.fund_id
LEFT JOIN cost_center cc ON i.cost_center_id = cc.cost_center_id
WHERE i.status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE')
ORDER BY i.due_date ASC, i.invoice_date ASC;

COMMENT ON VIEW ar_outstanding_invoices IS
'All unpaid or partially paid AR invoices. Includes customer, fund, '
'cost center, and overdue status.';

-- ---------------------------------------------------------------------
-- VIEW 3: ar_receipts_unallocated
-- Receipts not yet allocated to invoices
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ar_receipts_unallocated AS
SELECT
    r.authority_code,
    r.receipt_id,
    r.receipt_number,
    r.receipt_date,
    r.amount,
    r.amount_allocated,
    r.amount_unallocated,
    r.payment_method,
    r.payment_reference,
    r.status,
    c.customer_number,
    c.customer_name,
    c.phone,
    c.email,
    -- Days since receipt (for follow-up)
    (CURRENT_DATE - r.receipt_date) AS days_since_receipt
FROM ar_receipt r
JOIN ar_customer c ON r.customer_id = c.customer_id
WHERE r.amount_unallocated > 0
  AND r.status = 'POSTED'
ORDER BY r.receipt_date ASC;

COMMENT ON VIEW ar_receipts_unallocated IS
'AR receipts with unallocated amounts. These need to be matched to '
'outstanding invoices.';

-- ---------------------------------------------------------------------
-- VIEW 4: ar_revenue_summary
-- Revenue by invoice type, fund, and period
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ar_revenue_summary AS
SELECT
    i.authority_code,
    i.invoice_type,
    f.fund_code,
    f.fund_name,
    fy.year_number,
    fp.period_number,
    fp.period_name,
    COUNT(DISTINCT i.invoice_id) AS invoice_count,
    SUM(i.subtotal) AS total_subtotal,
    SUM(i.tax_amount) AS total_tax,
    SUM(i.total_amount) AS total_invoiced,
    SUM(i.amount_paid) AS total_collected,
    SUM(i.balance) AS total_outstanding
FROM ar_invoice i
LEFT JOIN fund f ON i.fund_id = f.fund_id
LEFT JOIN fiscal_period fp ON i.period_id = fp.period_id
LEFT JOIN fiscal_year fy ON fp.fiscal_year_id = fy.fiscal_year_id
WHERE i.status NOT IN ('CANCELLED', 'WRITTEN_OFF')
GROUP BY
    i.authority_code, i.invoice_type,
    f.fund_code, f.fund_name,
    fy.year_number, fp.period_number, fp.period_name;

COMMENT ON VIEW ar_revenue_summary IS
'AR revenue summary grouped by invoice type, fund, and period. '
'Shows invoiced, collected, and outstanding amounts.';

-- ---------------------------------------------------------------------
-- VIEW 5: ar_customer_balances
-- Net balance per customer
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW ar_customer_balances AS
SELECT
    c.authority_code,
    c.customer_id,
    c.customer_number,
    c.customer_name,
    c.customer_type,
    c.phone,
    c.email,
    COALESCE(inv.total_invoiced, 0) AS total_invoiced,
    COALESCE(inv.total_paid, 0) AS total_paid,
    COALESCE(inv.total_outstanding, 0) AS total_outstanding,
    COALESCE(inv.invoice_count, 0) AS invoice_count,
    COALESCE(rcp.unallocated_credits, 0) AS unallocated_credits,
    COALESCE(inv.oldest_due_date, NULL) AS oldest_due_date
FROM ar_customer c
LEFT JOIN (
    SELECT
        customer_id,
        COUNT(*) AS invoice_count,
        SUM(total_amount) AS total_invoiced,
        SUM(amount_paid) AS total_paid,
        SUM(balance) AS total_outstanding,
        MIN(CASE WHEN balance > 0 THEN due_date ELSE NULL END) AS oldest_due_date
    FROM ar_invoice
    WHERE status NOT IN ('CANCELLED', 'WRITTEN_OFF')
    GROUP BY customer_id
) inv ON c.customer_id = inv.customer_id
LEFT JOIN (
    SELECT
        customer_id,
        SUM(amount_unallocated) AS unallocated_credits
    FROM ar_receipt
    WHERE amount_unallocated > 0 AND status = 'POSTED'
    GROUP BY customer_id
) rcp ON c.customer_id = rcp.customer_id
WHERE c.is_active = TRUE;

COMMENT ON VIEW ar_customer_balances IS
'Net balance per active customer. Shows total invoiced, total paid, '
'outstanding balance, and unallocated credits.';

-- ---------------------------------------------------------------------
-- FUNCTION: get_customer_statement
-- Full statement of account for a customer
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_customer_statement(
    p_customer_id UUID,
    p_from_date DATE DEFAULT NULL,
    p_to_date DATE DEFAULT NULL
)
RETURNS TABLE (
    entry_date DATE,
    entry_type VARCHAR,
    reference VARCHAR,
    description TEXT,
    debit NUMERIC,
    credit NUMERIC,
    running_balance NUMERIC
)
LANGUAGE sql STABLE AS $$
    WITH transactions AS (
        -- Invoices (debits to customer)
        SELECT
            i.invoice_date AS entry_date,
            'INVOICE' AS entry_type,
            i.invoice_number AS reference,
            COALESCE(i.description, i.invoice_type) AS description,
            i.total_amount AS debit,
            0::NUMERIC AS credit
        FROM ar_invoice i
        WHERE i.customer_id = p_customer_id
          AND i.status NOT IN ('CANCELLED', 'WRITTEN_OFF')
          AND (p_from_date IS NULL OR i.invoice_date >= p_from_date)
          AND (p_to_date IS NULL OR i.invoice_date <= p_to_date)

        UNION ALL

        -- Receipts (credits to customer)
        SELECT
            r.receipt_date AS entry_date,
            'RECEIPT' AS entry_type,
            r.receipt_number AS reference,
            'Payment via ' || r.payment_method AS description,
            0::NUMERIC AS debit,
            r.amount AS credit
        FROM ar_receipt r
        WHERE r.customer_id = p_customer_id
          AND r.status = 'POSTED'
          AND (p_from_date IS NULL OR r.receipt_date >= p_from_date)
          AND (p_to_date IS NULL OR r.receipt_date <= p_to_date)
    )
    SELECT
        entry_date,
        entry_type,
        reference,
        description,
        debit,
        credit,
        SUM(debit - credit) OVER (ORDER BY entry_date, entry_type, reference)
            AS running_balance
    FROM transactions
    ORDER BY entry_date, entry_type, reference;
$$;

COMMENT ON FUNCTION get_customer_statement IS
'Returns a full statement of account for a customer: invoices (debits), '
'receipts (credits), and running balance. Filter by date range.
Example:
  SELECT * FROM get_customer_statement(
      p_customer_id := ''...uuid...''::UUID,
      p_from_date := ''2026-01-01'',
      p_to_date := ''2026-12-31''
  );';

-- ---------------------------------------------------------------------
-- FUNCTION: get_age_analysis
-- Aging summary per customer
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_age_analysis(
    p_authority_code VARCHAR,
    p_as_of_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    customer_id UUID,
    customer_number VARCHAR,
    customer_name VARCHAR,
    current_amount NUMERIC,
    days_0_30 NUMERIC,
    days_31_60 NUMERIC,
    days_61_90 NUMERIC,
    days_90_plus NUMERIC,
    total_outstanding NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT
        c.customer_id,
        c.customer_number,
        c.customer_name,
        COALESCE(SUM(CASE WHEN p_as_of_date <= i.due_date THEN i.balance ELSE 0 END), 0) AS current_amount,
        COALESCE(SUM(CASE WHEN p_as_of_date - i.due_date BETWEEN 1 AND 30 THEN i.balance ELSE 0 END), 0) AS days_0_30,
        COALESCE(SUM(CASE WHEN p_as_of_date - i.due_date BETWEEN 31 AND 60 THEN i.balance ELSE 0 END), 0) AS days_31_60,
        COALESCE(SUM(CASE WHEN p_as_of_date - i.due_date BETWEEN 61 AND 90 THEN i.balance ELSE 0 END), 0) AS days_61_90,
        COALESCE(SUM(CASE WHEN p_as_of_date - i.due_date > 90 THEN i.balance ELSE 0 END), 0) AS days_90_plus,
        COALESCE(SUM(i.balance), 0) AS total_outstanding
    FROM ar_customer c
    LEFT JOIN ar_invoice i ON c.customer_id = i.customer_id
        AND i.status IN ('OUTSTANDING', 'PARTIAL', 'OVERDUE')
        AND i.balance > 0
    WHERE c.authority_code = p_authority_code
      AND c.is_active = TRUE
    GROUP BY c.customer_id, c.customer_number, c.customer_name
    HAVING COALESCE(SUM(i.balance), 0) > 0
    ORDER BY total_outstanding DESC;
$$;

COMMENT ON FUNCTION get_age_analysis IS
'Returns aging analysis per customer: current, 0-30, 31-60, 61-90, 90+ days.
Only includes customers with an outstanding balance.
Example:
  SELECT * FROM get_age_analysis(''CHILANGA'', CURRENT_DATE);';

-- ---------------------------------------------------------------------
-- FUNCTION: get_ar_revenue_summary
-- Revenue summary for a period
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ar_revenue_summary(
    p_authority_code VARCHAR,
    p_from_date DATE,
    p_to_date DATE
)
RETURNS TABLE (
    invoice_type VARCHAR,
    fund_code VARCHAR,
    fund_name VARCHAR,
    invoice_count BIGINT,
    total_invoiced NUMERIC,
    total_collected NUMERIC,
    total_outstanding NUMERIC,
    collection_rate NUMERIC
)
LANGUAGE sql STABLE AS $$
    SELECT
        i.invoice_type,
        f.fund_code,
        f.fund_name,
        COUNT(DISTINCT i.invoice_id) AS invoice_count,
        COALESCE(SUM(i.total_amount), 0) AS total_invoiced,
        COALESCE(SUM(i.amount_paid), 0) AS total_collected,
        COALESCE(SUM(i.balance), 0) AS total_outstanding,
        CASE
            WHEN SUM(i.total_amount) > 0
            THEN ROUND((SUM(i.amount_paid) / SUM(i.total_amount)) * 100, 2)
            ELSE 0
        END AS collection_rate
    FROM ar_invoice i
    LEFT JOIN fund f ON i.fund_id = f.fund_id
    WHERE i.authority_code = p_authority_code
      AND i.invoice_date BETWEEN p_from_date AND p_to_date
      AND i.status NOT IN ('CANCELLED', 'WRITTEN_OFF')
    GROUP BY i.invoice_type, f.fund_code, f.fund_name
    ORDER BY i.invoice_type, f.fund_code;
$$;

COMMENT ON FUNCTION get_ar_revenue_summary IS
'Returns AR revenue summary by invoice type and fund, with collection rate.
Example:
  SELECT * FROM get_ar_revenue_summary(
      ''CHILANGA'',
      ''2026-01-01'',
      ''2026-12-31''
  );';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AR_MODULE',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_ar_views_reports',
        'migration', 'V84',
        'purpose', 'AR views and reports — FINAL AR migration',
        'views_created', ARRAY[
            'ar_age_analysis',
            'ar_outstanding_invoices',
            'ar_receipts_unallocated',
            'ar_revenue_summary',
            'ar_customer_balances'
        ],
        'functions_created', ARRAY[
            'get_customer_statement',
            'get_age_analysis',
            'get_ar_revenue_summary'
        ],
        'ar_module_complete', TRUE
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
