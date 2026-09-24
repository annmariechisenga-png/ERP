-- =====================================================================
-- V59__create_fiscal_periods.sql
-- Fiscal Years and Periods — The Calendar of Financial Reporting
-- =====================================================================
-- Every journal entry belongs to exactly one fiscal period. Periods
-- are opened and closed according to the fiscal calendar. Closed
-- periods cannot receive new postings.
--
-- Design principles:
--   1. One fiscal year per authority per calendar year
--   2. 12 monthly periods + 1 adjustment period per year
--   3. Periods can be opened/closed independently
--   4. Closing is logged and auditable
--   5. Multi-tenant: every year and period is scoped to an authority
--
-- Zambian Local Authority fiscal year: 1 January – 31 December
-- =====================================================================

CREATE TABLE fiscal_year (
    fiscal_year_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    authority_code      VARCHAR(20) NOT NULL,
    year_number         INTEGER NOT NULL,
    year_start          DATE NOT NULL,
    year_end            DATE NOT NULL,
    is_closed           BOOLEAN NOT NULL DEFAULT FALSE,
    closed_at           TIMESTAMPTZ,
    closed_by           UUID,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID,
    CONSTRAINT uq_fiscal_year
        UNIQUE (authority_code, year_number),
    CONSTRAINT chk_fiscal_year_dates
        CHECK (year_end > year_start),
    CONSTRAINT chk_fiscal_year_span
        CHECK (year_end - year_start BETWEEN 360 AND 370)
);

CREATE TABLE fiscal_period (
    period_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fiscal_year_id      UUID NOT NULL REFERENCES fiscal_year(fiscal_year_id),
    period_number       INTEGER NOT NULL,
    period_name         VARCHAR(50) NOT NULL,
    period_start        DATE NOT NULL,
    period_end          DATE NOT NULL,
    period_type         VARCHAR(20) NOT NULL DEFAULT 'REGULAR',
    is_closed           BOOLEAN NOT NULL DEFAULT FALSE,
    closed_at           TIMESTAMPTZ,
    closed_by           UUID,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_fiscal_period
        UNIQUE (fiscal_year_id, period_number),
    CONSTRAINT chk_fiscal_period_dates
        CHECK (period_end >= period_start),
    CONSTRAINT chk_fiscal_period_type
        CHECK (period_type IN ('REGULAR', 'ADJUSTMENT', 'CLOSING'))
);

CREATE INDEX idx_fiscal_year_authority ON fiscal_year(authority_code, year_number);
CREATE INDEX idx_fiscal_year_dates ON fiscal_year(year_start, year_end);
CREATE INDEX idx_fiscal_period_year ON fiscal_period(fiscal_year_id, period_number);
CREATE INDEX idx_fiscal_period_dates ON fiscal_period(period_start, period_end);
CREATE INDEX idx_fiscal_period_open
    ON fiscal_period(period_start, period_end)
    WHERE is_closed = FALSE;

COMMENT ON TABLE fiscal_year IS
'Fiscal years for each authority. A fiscal year defines the 12-month '
'accounting period and owns 12 monthly periods + 1 adjustment period.';

COMMENT ON TABLE fiscal_period IS
'Monthly fiscal periods within a fiscal year. Every journal entry must '
'belong to exactly one period. Closed periods cannot receive postings.';

COMMENT ON COLUMN fiscal_period.period_type IS
'REGULAR (monthly), ADJUSTMENT (year-end corrections), '
'CLOSING (final closing entries).';

-- ---------------------------------------------------------------------
-- HELPER FUNCTION — Find the fiscal period for a date
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_fiscal_period_for_date(
    p_authority_code VARCHAR,
    p_date DATE
) RETURNS UUID
LANGUAGE sql STABLE AS $$
    SELECT fp.period_id
    FROM fiscal_period fp
    JOIN fiscal_year fy ON fp.fiscal_year_id = fy.fiscal_year_id
    WHERE fy.authority_code = p_authority_code
      AND fp.period_start <= p_date
      AND fp.period_end >= p_date
      AND fp.period_type = 'REGULAR'
    ORDER BY fp.period_number
    LIMIT 1;
$$;

COMMENT ON FUNCTION get_fiscal_period_for_date IS
'Returns the fiscal period ID for a given date and authority. '
'Used by journal posting to determine which period to book to.';

-- ---------------------------------------------------------------------
-- HELPER FUNCTION — Check if a period is open
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION is_period_open(p_period_id UUID)
RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT NOT is_closed
    FROM fiscal_period
    WHERE period_id = p_period_id;
$$;

COMMENT ON FUNCTION is_period_open IS
'Returns TRUE if the period is open for posting. FALSE if closed.';

-- ---------------------------------------------------------------------
-- HELPER FUNCTION — Close a fiscal period
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION close_fiscal_period(
    p_period_id UUID,
    p_user_id UUID
) RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    v_period RECORD;
BEGIN
    SELECT * INTO v_period FROM fiscal_period WHERE period_id = p_period_id;

    IF v_period IS NULL THEN
        RAISE EXCEPTION 'Fiscal period not found: %', p_period_id;
    END IF;

    IF v_period.is_closed THEN
        RAISE EXCEPTION 'Fiscal period is already closed: %', v_period.period_name;
    END IF;

    UPDATE fiscal_period
    SET is_closed = TRUE,
        closed_at = NOW(),
        closed_by = p_user_id
    WHERE period_id = p_period_id;

    PERFORM log_audit_event(
        'FISCAL_PERIOD', 'FISCAL_PERIOD', p_period_id, 'CLOSE',
        jsonb_build_object('is_closed', FALSE),
        jsonb_build_object('is_closed', TRUE, 'closed_by', p_user_id),
        p_user_id, NULL, NULL, inet_client_addr(), NULL
    );

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION close_fiscal_period IS
'Closes a fiscal period. After closing, no new journal entries can be posted.';

-- ---------------------------------------------------------------------
-- SEED — Fiscal Year 2026 and 2027 for Chilanga
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_year_id UUID;
    v_authority VARCHAR := 'CHILANGA';
    v_year INTEGER;
BEGIN
    FOR v_year IN 2026..2027 LOOP
        -- Create fiscal year
        INSERT INTO fiscal_year
            (authority_code, year_number, year_start, year_end)
        VALUES
            (v_authority, v_year,
             make_date(v_year, 1, 1),
             make_date(v_year, 12, 31))
        RETURNING fiscal_year_id INTO v_year_id;

        -- Create 12 monthly periods
        FOR i IN 1..12 LOOP
            INSERT INTO fiscal_period
                (fiscal_year_id, period_number, period_name,
                 period_start, period_end, period_type)
            VALUES (
                v_year_id,
                i,
                TO_CHAR(make_date(v_year, i, 1), 'Month YYYY'),
                make_date(v_year, i, 1),
                (make_date(v_year, i, 1) + INTERVAL '1 month' - INTERVAL '1 day')::DATE,
                'REGULAR'
            );
        END LOOP;

        -- Create adjustment period (period 13)
        INSERT INTO fiscal_period
            (fiscal_year_id, period_number, period_name,
             period_start, period_end, period_type)
        VALUES (
            v_year_id,
            13,
            'Adjustment Period ' || v_year,
            make_date(v_year, 12, 31),
            make_date(v_year, 12, 31),
            'ADJUSTMENT'
        );
    END LOOP;
END $$;

-- ---------------------------------------------------------------------
-- AUDIT LOG — Record fiscal year creation
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason, changed_by, record_hash)
SELECT
    'FISCAL_YEAR',
    fy.fiscal_year_id,
    'CREATE',
    jsonb_build_object(
        'authority_code', fy.authority_code,
        'year_number', fy.year_number,
        'year_start', fy.year_start,
        'year_end', fy.year_end
    ),
    'Initial fiscal year setup for Local Authority',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256((fy.fiscal_year_id::text || fy.year_number::text || NOW()::text)::bytea), 'hex')
FROM fiscal_year fy;
