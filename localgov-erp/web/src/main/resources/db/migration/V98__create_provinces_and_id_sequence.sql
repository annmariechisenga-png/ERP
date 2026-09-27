-- =====================================================================
-- V98__create_provinces_and_id_sequence.sql
-- Layer 1 — National Registry: Provinces + ID Sequence
-- =====================================================================
-- Creates:
--   1. provinces      — 10 Zambian provinces, ISO 3166-2 codes
--   2. id_sequence    — per-council per-entity counter table
--
-- These are platform-level tables. Every module that generates
-- council-scoped IDs uses id_sequence via generate_council_scoped_id().
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. PROVINCES
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS provinces (
    province_code   VARCHAR(2) PRIMARY KEY,
    province_name   VARCHAR(50) NOT NULL,
    iso_code        VARCHAR(10) NOT NULL UNIQUE,
    sort_order      INTEGER NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE provinces IS
'Zambian provinces. province_code is the ISO 3166-2 numeric part '
'(01=Western, 02=Central, ...). Used as the first segment of all '
'council-scoped IDs.';

INSERT INTO provinces (province_code, province_name, iso_code, sort_order) VALUES
    ('01', 'Western',       'ZM-01',  1),
    ('02', 'Central',       'ZM-02',  2),
    ('03', 'Eastern',       'ZM-03',  3),
    ('04', 'Luapula',       'ZM-04',  4),
    ('05', 'Northern',      'ZM-05',  5),
    ('06', 'North-Western', 'ZM-06',  6),
    ('07', 'Southern',      'ZM-07',  7),
    ('08', 'Copperbelt',    'ZM-08',  8),
    ('09', 'Lusaka',        'ZM-09',  9),
    ('10', 'Muchinga',      'ZM-10', 10)
ON CONFLICT (province_code) DO NOTHING;

-- ---------------------------------------------------------------------
-- 2. ID SEQUENCE
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS id_sequence (
    authority_code  VARCHAR(30) NOT NULL,
    entity_type     VARCHAR(50) NOT NULL,
    next_value      BIGINT NOT NULL DEFAULT 1,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (authority_code, entity_type)
);

CREATE INDEX IF NOT EXISTS idx_id_sequence_authority
    ON id_sequence(authority_code);

COMMENT ON TABLE id_sequence IS
'Per-council, per-entity-type counter for auto-generated identifiers. '
'One row per (authority_code, entity_type). Incremented atomically '
'via generate_council_scoped_id(). Never renumbered.';

COMMENT ON COLUMN id_sequence.entity_type IS
'Entity kind: EMPLOYEE, VENDOR, CUSTOMER, AP_INVOICE, AR_INVOICE, '
'AP_PAYMENT, AR_RECEIPT, JOURNAL, etc. Each has its own sequence.';

-- ---------------------------------------------------------------------
-- 3. Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'PLATFORM',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_provinces_and_id_sequence',
        'migration', 'V98',
        'tables_created', ARRAY['provinces', 'id_sequence'],
        'provinces_seeded', 10
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
