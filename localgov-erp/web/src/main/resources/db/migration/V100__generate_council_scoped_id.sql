-- =====================================================================
-- V100__generate_council_scoped_id.sql
-- Layer 1 — National Registry: Shared council-scoped ID generator
-- =====================================================================
-- Creates the platform-level function that every module uses to
-- generate council-scoped identifiers:
--
--     {province}-{council_seq}-{prefix}{sequence}
--
-- Examples:
--     generate_council_scoped_id('CHILANGA', 'EMPLOYEE', NULL, 6)
--         → '09-01-000001'
--
--     generate_council_scoped_id('CHILANGA', 'VENDOR', 'V', 5)
--         → '09-01-V00001'
--
--     generate_council_scoped_id('CHILANGA', 'AP_INVOICE', 'INV', 5)
--         → '09-01-INV00001'
--
-- The sequence is per (authority_code, entity_type), stored in
-- id_sequence. Never renumbered. Concurrency-safe via ON CONFLICT.
--
-- This is the "cut across" function. Every module that produces
-- council-scoped IDs builds a thin wrapper on top of it:
--   - generate_employee_number() → HR module
--   - generate_vendor_number()   → AP module
--   - generate_customer_number() → AR module
--   - generate_ap_invoice_number() → AP module
--   - etc.
-- =====================================================================

CREATE OR REPLACE FUNCTION generate_council_scoped_id(
    p_authority_code  VARCHAR,
    p_entity_type     VARCHAR,
    p_entity_prefix   VARCHAR DEFAULT NULL,
    p_sequence_width  INTEGER DEFAULT 6
) RETURNS VARCHAR
LANGUAGE plpgsql AS $$
DECLARE
    v_province   VARCHAR(2);
    v_council    INTEGER;
    v_next       BIGINT;
    v_prefix     VARCHAR(10);
BEGIN
    -- Validate width
    IF p_sequence_width < 1 OR p_sequence_width > 12 THEN
        RAISE EXCEPTION 'p_sequence_width must be between 1 and 12. Got: %',
            p_sequence_width;
    END IF;

    -- Look up province + council_seq from the national registry
    SELECT province_code, council_seq
    INTO v_province, v_council
    FROM authorities
    WHERE authority_code = p_authority_code
      AND is_active = TRUE;

    IF v_province IS NULL THEN
        RAISE EXCEPTION 'Unknown or inactive authority_code: %', p_authority_code;
    END IF;

    -- Atomically increment the counter for this council + entity type
    INSERT INTO id_sequence (authority_code, entity_type, next_value, updated_at)
    VALUES (p_authority_code, p_entity_type, 1, NOW())
    ON CONFLICT (authority_code, entity_type)
    DO UPDATE SET
        next_value = id_sequence.next_value + 1,
        updated_at = NOW()
    RETURNING next_value INTO v_next;

    -- Sanity: the returned value is what was JUST written (either 1 on
    -- first insert, or incremented value on update). This is the number
    -- this call "owns" and will never be issued again.
    v_prefix := COALESCE(p_entity_prefix, '');

    RETURN v_province || '-' ||
           LPAD(v_council::TEXT, 2, '0') || '-' ||
           v_prefix ||
           LPAD(v_next::TEXT, p_sequence_width, '0');
END;
$$;

COMMENT ON FUNCTION generate_council_scoped_id IS
'Platform ID generator. Produces {province}-{council_seq}-{prefix}{seq}.
Looks up province + council_seq from authorities. Increments
id_sequence(authority_code, entity_type) atomically. Never renumbers.
Every council-scoped ID in every module flows through this function.';

-- ---------------------------------------------------------------------
-- Helper: peek at the next value WITHOUT incrementing
-- Useful for preview/reporting — must NOT be used to actually reserve
-- an ID. Only generate_council_scoped_id() reserves.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION peek_council_scoped_id(
    p_authority_code  VARCHAR,
    p_entity_type     VARCHAR,
    p_entity_prefix   VARCHAR DEFAULT NULL,
    p_sequence_width  INTEGER DEFAULT 6
) RETURNS VARCHAR
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_province   VARCHAR(2);
    v_council    INTEGER;
    v_next       BIGINT;
    v_prefix     VARCHAR(10);
BEGIN
    SELECT province_code, council_seq
    INTO v_province, v_council
    FROM authorities
    WHERE authority_code = p_authority_code AND is_active = TRUE;

    IF v_province IS NULL THEN
        RAISE EXCEPTION 'Unknown or inactive authority_code: %', p_authority_code;
    END IF;

    SELECT COALESCE(next_value, 1)
    INTO v_next
    FROM id_sequence
    WHERE authority_code = p_authority_code
      AND entity_type = p_entity_type;

    IF v_next IS NULL THEN
        v_next := 1;
    END IF;

    v_prefix := COALESCE(p_entity_prefix, '');

    RETURN v_province || '-' ||
           LPAD(v_council::TEXT, 2, '0') || '-' ||
           v_prefix ||
           LPAD(v_next::TEXT, p_sequence_width, '0');
END;
$$;

COMMENT ON FUNCTION peek_council_scoped_id IS
'Returns the NEXT id that generate_council_scoped_id() would produce, '
'WITHOUT incrementing the counter. For previews only.';

-- ---------------------------------------------------------------------
-- Entity type registry — documented values for p_entity_type
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS id_entity_type (
    entity_type     VARCHAR(50) PRIMARY KEY,
    description     TEXT NOT NULL,
    default_prefix  VARCHAR(10),
    default_width   INTEGER NOT NULL DEFAULT 6,
    owning_module   VARCHAR(50) NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO id_entity_type (entity_type, description, default_prefix, default_width, owning_module) VALUES
    ('EMPLOYEE',       'Payroll employee master', 'NULL', 6, 'HR'),
    ('VENDOR',         'AP vendor (supplier)',    'V',    5, 'AP'),
    ('CUSTOMER',       'AR customer',             'C',    5, 'AR'),
    ('AP_INVOICE',     'AP invoice (bill received from vendor)', 'INV', 5, 'AP'),
    ('AR_INVOICE',     'AR invoice (bill issued to customer)',   'INV', 5, 'AR'),
    ('AP_PAYMENT',     'AP payment to vendor',    'PAY',  5, 'AP'),
    ('AR_RECEIPT',     'AR receipt from customer','RCT',  5, 'AR'),
    ('JOURNAL',        'GL journal entry',        'JE',   5, 'GL'),
    ('PURCHASE_ORDER', 'Procurement purchase order', 'PO', 5, 'PROCUREMENT'),
    ('GOODS_RECEIPT',  'Goods received note',     'GRN',  5, 'STORES'),
    ('ASSET',          'Fixed asset register',    'FA',   5, 'ASSETS'),
    ('PAYROLL_RUN',    'Monthly payroll run',     'PR',   5, 'PAYROLL'),
    ('PAYSLIP',        'Employee payslip',        'PS',   6, 'PAYROLL')
ON CONFLICT (entity_type) DO NOTHING;

COMMENT ON TABLE id_entity_type IS
'Registry of valid p_entity_type values for generate_council_scoped_id(). '
'Documents which module owns each entity type and the default prefix/width.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'PLATFORM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_council_scoped_id_generator',
        'migration', 'V100',
        'functions_created', ARRAY[
            'generate_council_scoped_id',
            'peek_council_scoped_id'
        ],
        'tables_created', ARRAY['id_entity_type']
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
