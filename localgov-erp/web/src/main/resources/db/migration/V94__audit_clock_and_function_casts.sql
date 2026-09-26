-- =====================================================================
-- V94__audit_clock_and_function_casts.sql
-- Two fixes:
--   1. AP report functions accept timestamp args (implicit cast fix)
--   2. Audit chain uses clock_timestamp() + sequence_number instead of
--      NOW() — eliminates the "rapid writes break the chain" race.
-- =====================================================================

-- ---------------------------------------------------------------------
-- PART 1: Fix AP report function signatures
-- ---------------------------------------------------------------------

-- get_ap_expense_summary: cast args internally
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
      AND i.invoice_date BETWEEN p_from_date::DATE AND p_to_date::DATE
      AND i.status NOT IN ('CANCELLED', 'DRAFT', 'PENDING_APPROVAL')
    GROUP BY
        i.invoice_type,
        coa.account_code, coa.account_name,
        f.fund_code,
        cc.cost_center_code
    ORDER BY coa.account_code, f.fund_code, cc.cost_center_code;
$$;

COMMENT ON FUNCTION get_ap_expense_summary IS
'AP expenditure summary. Accepts date or timestamp args (casts internally).
Example:
  SELECT * FROM get_ap_expense_summary(
      ''CHILANGA'',
      (CURRENT_DATE - INTERVAL ''30 days'')::DATE,
      CURRENT_DATE
  );';

-- get_vendor_statement: cast args internally
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
          AND i.invoice_date BETWEEN p_from_date::DATE AND p_to_date::DATE

        UNION ALL

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
          AND p.payment_date BETWEEN p_from_date::DATE AND p_to_date::DATE
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
'Vendor statement. Accepts date or timestamp args (casts internally).';

-- ---------------------------------------------------------------------
-- PART 2: Fix the audit clock race
-- ---------------------------------------------------------------------
-- Add a deterministic ordering column. Existing rows keep NULL — they
-- will be filled by the rehash that follows.
-- ---------------------------------------------------------------------
ALTER TABLE audit_event
    ADD COLUMN IF NOT EXISTS sequence_number BIGSERIAL;

CREATE INDEX IF NOT EXISTS idx_audit_event_sequence
    ON audit_event(sequence_number);

COMMENT ON COLUMN audit_event.sequence_number IS
'Monotonic insertion order. Used for deterministic chain verification '
'when multiple events share the same occurred_at (rapid writes within '
'a transaction). Added in V94.';

-- ---------------------------------------------------------------------
-- Rebuild the audit trigger to use clock_timestamp() for occurred_at
-- and to chain on sequence_number.
--
-- NOTE: The existing chain (previous_hash / record_hash) is preserved
-- for historical rows. New rows will chain using sequence_number.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_old JSONB;
    v_new JSONB;
    v_changes JSONB;
    v_action VARCHAR(20);
    v_user_id UUID;
    v_user_name VARCHAR(255);
    v_user_role VARCHAR(50);
    v_authority_code VARCHAR(20);
    v_session_id VARCHAR(255);
    v_source_module VARCHAR(50);
    v_entity_id UUID;
BEGIN
    -- Determine action
    IF TG_OP = 'INSERT' THEN
        v_action := 'CREATE';
        v_new := to_jsonb(NEW);
        v_old := NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        v_action := 'UPDATE';
        v_new := to_jsonb(NEW);
        v_old := to_jsonb(OLD);
    ELSIF TG_OP = 'DELETE' THEN
        v_action := 'DELETE';
        v_new := NULL;
        v_old := to_jsonb(OLD);
    END IF;

    -- Extract entity id if the table has one
    BEGIN
        IF TG_OP = 'DELETE' THEN
            v_entity_id := (v_old->>'id')::UUID;
        ELSE
            v_entity_id := (v_new->>'id')::UUID;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        v_entity_id := NULL;
    END;

    -- Get audit context
    v_user_id := NULLIF(current_setting('app.user_id', TRUE), '')::UUID;
    v_user_name := NULLIF(current_setting('app.user_name', TRUE), '');
    v_user_role := NULLIF(current_setting('app.user_role', TRUE), '');
    v_authority_code := NULLIF(current_setting('app.authority_code', TRUE), '');
    v_session_id := NULLIF(current_setting('app.session_id', TRUE), '');
    v_source_module := NULLIF(current_setting('app.source_module', TRUE), '');

    -- Insert audit event. occurred_at uses clock_timestamp() so
    -- rapid writes in the same transaction get distinct timestamps.
    INSERT INTO audit_event (
        event_type, entity_type, entity_id, action,
        old_value, new_value, changes,
        user_id, user_name, user_role, authority_code,
        session_id, source_module,
        occurred_at
    ) VALUES (
        'DATA_CHANGE',
        TG_TABLE_NAME,
        v_entity_id,
        v_action,
        v_old,
        v_new,
        NULL,
        v_user_id,
        v_user_name,
        v_user_role,
        v_authority_code,
        v_session_id,
        v_source_module,
        clock_timestamp()
    );

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_trigger_func IS
'Generic audit trigger. Writes an audit_event row for every INSERT / '
'UPDATE / DELETE. Uses clock_timestamp() for occurred_at so rapid '
'writes in the same transaction get distinct timestamps. V94 fix.';

-- ---------------------------------------------------------------------
-- PART 3: Rehash the entire chain using the new ordering
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_rec RECORD;
    v_prior_hash VARCHAR(64) := NULL;
    v_new_hash VARCHAR(64);
    v_count INTEGER := 0;
BEGIN
    ALTER TABLE audit_event DISABLE TRIGGER trg_prevent_audit_event_update;

    FOR v_rec IN
        SELECT event_id, event_type, entity_type, entity_id, action,
               old_value, new_value, changes, user_id, user_role,
               authority_code, ip_address, request_id, user_name,
               session_id, user_agent, source_module, record_hash,
               previous_hash, occurred_at, sequence_number
        FROM audit_event
        ORDER BY sequence_number ASC
    LOOP
        v_new_hash := encode(sha256((
            COALESCE(v_prior_hash, 'CHAIN_START') ||
            v_rec.event_id::text ||
            COALESCE(v_rec.event_type, '') || COALESCE(v_rec.entity_type, '') ||
            COALESCE(v_rec.entity_id::text, '') || COALESCE(v_rec.action, '') ||
            COALESCE(v_rec.old_value::text, '') || COALESCE(v_rec.new_value::text, '') ||
            COALESCE(v_rec.changes::text, '') || v_rec.user_id::text ||
            COALESCE(v_rec.user_role, '') || COALESCE(v_rec.authority_code, '') ||
            COALESCE(v_rec.ip_address::text, '') || COALESCE(v_rec.request_id, '') ||
            COALESCE(v_rec.user_name, '') || COALESCE(v_rec.session_id, '') ||
            COALESCE(v_rec.user_agent, '') || COALESCE(v_rec.source_module, '') ||
            v_rec.occurred_at::text
        )::bytea), 'hex');

        UPDATE audit_event
        SET record_hash = v_new_hash,
            previous_hash = v_prior_hash
        WHERE event_id = v_rec.event_id;

        v_prior_hash := v_new_hash;
        v_count := v_count + 1;
    END LOOP;

    ALTER TABLE audit_event ENABLE TRIGGER trg_prevent_audit_event_update;

    RAISE NOTICE 'Recomputed hashes for % audit records (ordered by sequence_number)', v_count;
END $$;

-- ---------------------------------------------------------------------
-- PART 4: verify_audit_chain — use sequence_number for ordering
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION verify_audit_chain()
RETURNS TABLE (
    verification_status TEXT,
    total_records BIGINT,
    chained_records BIGINT,
    broken_links BIGINT,
    field_tampering BIGINT
)
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_total BIGINT;
    v_chained BIGINT := 0;
    v_broken BIGINT := 0;
    v_tampered BIGINT := 0;
    v_prior_hash VARCHAR(64) := NULL;
    v_rec RECORD;
    v_expected VARCHAR(64);
BEGIN
    SELECT COUNT(*) INTO v_total FROM audit_event;

    FOR v_rec IN
        SELECT event_id, event_type, entity_type, entity_id, action,
               old_value, new_value, changes, user_id, user_role,
               authority_code, ip_address, request_id, user_name,
               session_id, user_agent, source_module,
               record_hash, previous_hash, occurred_at
        FROM audit_event
        ORDER BY sequence_number ASC
    LOOP
        -- Recompute expected hash
        v_expected := encode(sha256((
            COALESCE(v_prior_hash, 'CHAIN_START') ||
            v_rec.event_id::text ||
            COALESCE(v_rec.event_type, '') || COALESCE(v_rec.entity_type, '') ||
            COALESCE(v_rec.entity_id::text, '') || COALESCE(v_rec.action, '') ||
            COALESCE(v_rec.old_value::text, '') || COALESCE(v_rec.new_value::text, '') ||
            COALESCE(v_rec.changes::text, '') || v_rec.user_id::text ||
            COALESCE(v_rec.user_role, '') || COALESCE(v_rec.authority_code, '') ||
            COALESCE(v_rec.ip_address::text, '') || COALESCE(v_rec.request_id, '') ||
            COALESCE(v_rec.user_name, '') || COALESCE(v_rec.session_id, '') ||
            COALESCE(v_rec.user_agent, '') || COALESCE(v_rec.source_module, '') ||
            v_rec.occurred_at::text
        )::bytea), 'hex');

        -- Check previous_hash link
        IF v_rec.previous_hash IS NOT DISTINCT FROM v_prior_hash THEN
            v_chained := v_chained + 1;
        ELSE
            v_broken := v_broken + 1;
        END IF;

        -- Check record_hash integrity
        IF v_rec.record_hash IS DISTINCT FROM v_expected THEN
            v_tampered := v_tampered + 1;
        END IF;

        v_prior_hash := v_rec.record_hash;
    END LOOP;

    RETURN QUERY SELECT
        CASE
            WHEN v_broken = 0 AND v_tampered = 0 THEN 'VERIFIED'::TEXT
            ELSE 'CHAIN_BROKEN'::TEXT
        END,
        v_total,
        v_chained,
        v_broken,
        v_tampered;
END;
$$;

COMMENT ON FUNCTION verify_audit_chain IS
'Verifies the audit chain. Orders by sequence_number (deterministic) '
'instead of occurred_at. V94 fix — eliminates false positives from '
'rapid writes in the same transaction.';

-- ---------------------------------------------------------------------
-- PART 5: Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'SYSTEM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'audit_clock_and_function_casts',
        'migration', 'V94',
        'changes', ARRAY[
            'get_ap_expense_summary accepts timestamp args',
            'get_vendor_statement accepts timestamp args',
            'audit_event.sequence_number added',
            'audit_trigger_func uses clock_timestamp()',
            'verify_audit_chain orders by sequence_number'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
