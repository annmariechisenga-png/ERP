-- =====================================================================
-- V1_0_4 — Create base authorities + council_types tables
-- =====================================================================
-- Both tables were previously created out-of-band on the dev database.
-- V99 (augment authorities + seed councils) assumes they exist. All
-- Finance Core tables with authority_code FKs reference authorities;
-- councils reference council_types.
--
-- This migration creates the base shape; V99 augments authorities with
-- registry fields (authority_code, province_code, council_seq, hardship,
-- audit metadata) and adds constraints and indexes.
--
-- CREATE TABLE IF NOT EXISTS keeps existing databases unaffected.
-- =====================================================================

-- ---------------------------------------------------------------------
-- council_types — master list of council classifications
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS council_types (
    council_type_id   SERIAL PRIMARY KEY,
    type_code         VARCHAR(20)  NOT NULL UNIQUE,
    type_name         VARCHAR(100) NOT NULL,
    description       TEXT,
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE council_types IS
'Master list of Local Authority classifications (City, Municipal, Town).
Referenced by authorities.council_type_id.';

INSERT INTO council_types (type_code, type_name, description)
VALUES
    ('CITY',      'City Council',      'Urban city council — highest tier'),
    ('MUNICIPAL', 'Municipal Council', 'Municipal council — mid tier'),
    ('TOWN',      'Town Council',      'Town council — lowest tier')
ON CONFLICT (type_code) DO NOTHING;

-- ---------------------------------------------------------------------
-- authorities — national registry of all 116 Local Authorities
-- ---------------------------------------------------------------------
-- Base columns only. V99 augments with authority_code, province_code,
-- council_seq, council_type_id, hardship_classification, and audit
-- metadata. V103 references the mofnp_* columns defined here.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS authorities (
    authority_prefix    TEXT,
    authority_name      TEXT,
    authority_type      TEXT,
    mofnp_province_code VARCHAR(2),
    mofnp_head_code     VARCHAR(4),
    mofnp_full_head     VARCHAR(6)
);

COMMENT ON TABLE authorities IS
'National registry of all 116 Zambian Local Authorities. Every
transactional table carries authority_code as the multi-tenancy key.
Authority_code itself is added by V99 (augment).';
