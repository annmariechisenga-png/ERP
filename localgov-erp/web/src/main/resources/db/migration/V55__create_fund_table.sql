-- =====================================================================
-- V55__create_fund_table.sql
-- Fund Accounting — Foundation of Public Sector Finance
-- =====================================================================
-- Every transaction in a Local Authority must be tagged with a fund.
-- Funds are legally segregated. A council cannot spend CDF money on
-- General Fund obligations, and vice versa.
--
-- This table is the foundation of:
--   - Fund-level reporting
--   - Inter-fund transfers
--   - Fund balance tracking
--   - Compliance with PFM Act 2018
--   - IPSAS 1 (Presentation of Financial Statements)
-- =====================================================================

CREATE TABLE fund (
    fund_id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fund_code           VARCHAR(10) NOT NULL UNIQUE,
    fund_name           VARCHAR(255) NOT NULL,
    fund_type           VARCHAR(50) NOT NULL,
        -- GENERAL, CDF, LGEF, WATER_SANITATION, HEALTH, EDUCATION,
        -- COMMERCIAL, DONOR, CAPITAL, TRUST, OTHER
    fund_description    TEXT,
    is_restricted       BOOLEAN NOT NULL DEFAULT FALSE,
        -- TRUE if fund has legal restriction on use
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from      DATE NOT NULL,
    effective_to        DATE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID,
    legal_source_id     UUID,
        -- References legal_source if a specific law created the fund
    CONSTRAINT chk_fund_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from),
    CONSTRAINT chk_fund_type
        CHECK (fund_type IN (
            'GENERAL', 'CDF', 'LGEF', 'WATER_SANITATION', 'HEALTH',
            'EDUCATION', 'COMMERCIAL', 'DONOR', 'CAPITAL', 'TRUST', 'OTHER'
        ))
);

CREATE INDEX idx_fund_code ON fund(fund_code);
CREATE INDEX idx_fund_type ON fund(fund_type);
CREATE INDEX idx_fund_active ON fund(fund_code) WHERE is_active = TRUE;

COMMENT ON TABLE fund IS
'Fund accounting table. Every journal line is tagged with a fund. '
'Funds are legally segregated. Enables fund-level reporting and '
'inter-fund transfers as required by PFM Act 2018 and IPSAS.';

COMMENT ON COLUMN fund.is_restricted IS
'TRUE if the fund has a legal restriction on use (e.g. CDF, LGEF, '
'donor funds). Unrestricted funds (General Fund) can be used for any '
'lawful council purpose.';

-- ---------------------------------------------------------------------
-- SEED DATA — Standard Zambian Local Authority Funds
-- ---------------------------------------------------------------------
INSERT INTO fund
    (fund_code, fund_name, fund_type, fund_description, is_restricted, effective_from)
VALUES
    ('1000', 'General Fund', 'GENERAL',
     'Unrestricted fund for general council operations. Receives property rates, personal levy, market fees, licenses and other own-source revenue.',
     FALSE, '2026-01-01'),

    ('2000', 'Constituency Development Fund', 'CDF',
     'Restricted fund from Central Government for community projects. Governed by the Constituency Development Fund Act.',
     TRUE, '2026-01-01'),

    ('3000', 'Local Government Equalisation Fund', 'LGEF',
     'Restricted fund from Central Government for local government operations. Governed by the Local Government Equalisation Fund Act.',
     TRUE, '2026-01-01'),

    ('4000', 'Water and Sanitation Fund', 'WATER_SANITATION',
     'Restricted fund for water supply and sanitation services.',
     TRUE, '2026-01-01'),

    ('5000', 'Health Fund', 'HEALTH',
     'Restricted fund for health services (devolved function).',
     TRUE, '2026-01-01'),

    ('6000', 'Education Fund', 'EDUCATION',
     'Restricted fund for education services.',
     TRUE, '2026-01-01'),

    ('7000', 'Commercial Ventures Fund', 'COMMERCIAL',
     'Fund for council commercial ventures (guest houses, transport, markets, abattoirs).',
     FALSE, '2026-01-01'),

    ('8000', 'Donor Fund', 'DONOR',
     'Restricted fund for donor-funded projects. Governed by individual donor agreements.',
     TRUE, '2026-01-01'),

    ('9000', 'Capital Projects Fund', 'CAPITAL',
     'Fund for capital projects (roads, buildings, infrastructure).',
     TRUE, '2026-01-01');

-- ---------------------------------------------------------------------
-- AUDIT LOG — Record fund creation
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason, changed_by, record_hash)
SELECT
    'FUND',
    f.fund_id,
    'CREATE',
    jsonb_build_object(
        'fund_code', f.fund_code,
        'fund_name', f.fund_name,
        'fund_type', f.fund_type,
        'is_restricted', f.is_restricted
    ),
    'Initial fund accounting setup — 9 standard Local Authority funds',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256((f.fund_id::text || f.fund_code || NOW()::text)::bytea), 'hex')
FROM fund f;
