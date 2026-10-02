-- ============================================================================
-- V108: Budget Module (MTBP / OBB / MoFNP Section 11)
-- ----------------------------------------------------------------------------
-- Implements the Medium-Term Budget Plan (MTBP), Output-Based Budgeting (OBB),
-- and budget cycle management as per the MoFNP Local Government Accounting
-- and Financial Procedures Manual (Dec 2023), Section 11.
--
-- Idempotent: safe to run on a fresh DB, a partially-migrated DB, or a fully
-- migrated DB. Uses IF NOT EXISTS / DO blocks throughout.
--
-- Depends on: V59 (fiscal_periods), V103 (MoFNP reference tables),
--             V105 (MoFNP chart of accounts)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- PART 1: Tables (in dependency order)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS budget_cycle (
    cycle_id                    UUID DEFAULT gen_random_uuid() NOT NULL,
    cycle_name                  VARCHAR(50) NOT NULL,
    authority_code              VARCHAR(20) NOT NULL,
    start_fiscal_year_id        UUID NOT NULL,
    end_fiscal_year_id          UUID NOT NULL,
    status                      VARCHAR(30) DEFAULT 'DRAFT' NOT NULL,
    guidelines_received_at      TIMESTAMPTZ,
    submitted_to_ministry_at    TIMESTAMPTZ,
    approved_by_ministry_at     TIMESTAMPTZ,
    closed_at                   TIMESTAMPTZ,
    created_at                  TIMESTAMPTZ DEFAULT now(),
    created_by                  UUID,
    updated_at                  TIMESTAMPTZ,
    updated_by                  UUID,
    notes                       TEXT,
    CONSTRAINT budget_cycle_status_check CHECK (
        status IN ('DRAFT','GUIDELINES_ISSUED','DEPARTMENTAL_INPUT',
                   'BMT_REVIEW','COUNCIL_ADOPTED','MINISTRY_SUBMITTED',
                   'MINISTRY_APPROVED','ACTIVE','CLOSED')
    )
);

CREATE TABLE IF NOT EXISTS budget_version (
    version_id          UUID DEFAULT gen_random_uuid() NOT NULL,
    cycle_id            UUID NOT NULL,
    version_number      INTEGER NOT NULL,
    version_name        VARCHAR(100) NOT NULL,
    version_type        VARCHAR(30) DEFAULT 'ORIGINAL' NOT NULL,
    status              VARCHAR(30) DEFAULT 'WORKING' NOT NULL,
    is_current          BOOLEAN DEFAULT false NOT NULL,
    approved_at         TIMESTAMPTZ,
    approved_by         UUID,
    created_at          TIMESTAMPTZ DEFAULT now(),
    created_by          UUID,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    notes               TEXT,
    CONSTRAINT budget_version_status_check CHECK (
        status IN ('WORKING','SUBMITTED','BMT_REVIEW','COUNCIL_ADOPTED',
                   'MINISTRY_SUBMITTED','MINISTRY_APPROVED','ACTIVE','SUPERSEDED')
    ),
    CONSTRAINT budget_version_version_type_check CHECK (
        version_type IN ('ORIGINAL','SUPPLEMENTARY','REVISED','REALLOCATION')
    )
);

CREATE TABLE IF NOT EXISTS budget_bfp (
    bfp_id              UUID DEFAULT gen_random_uuid() NOT NULL,
    version_id          UUID NOT NULL,
    fiscal_year_id      UUID NOT NULL,
    department_code     VARCHAR(10) NOT NULL,
    status              VARCHAR(30) DEFAULT 'DRAFT' NOT NULL,
    goals               TEXT,
    outcomes            TEXT,
    submitted_at        TIMESTAMPTZ,
    submitted_by        UUID,
    reviewed_at         TIMESTAMPTZ,
    reviewed_by         UUID,
    review_notes        TEXT,
    created_at          TIMESTAMPTZ DEFAULT now(),
    created_by          UUID,
    updated_at          TIMESTAMPTZ,
    updated_by          UUID,
    CONSTRAINT budget_bfp_status_check CHECK (
        status IN ('DRAFT','SUBMITTED','UNDER_REVIEW','ACCEPTED','RETURNED','REJECTED')
    )
);

CREATE TABLE IF NOT EXISTS budget_ceiling (
    ceiling_id                      UUID DEFAULT gen_random_uuid() NOT NULL,
    version_id                      UUID NOT NULL,
    fiscal_year_id                  UUID NOT NULL,
    department_code                 VARCHAR(10) NOT NULL,
    recurrent_ceiling               NUMERIC(18,2) DEFAULT 0 NOT NULL,
    capital_ceiling                 NUMERIC(18,2) DEFAULT 0 NOT NULL,
    personal_emoluments_ceiling     NUMERIC(18,2) DEFAULT 0 NOT NULL,
    total_ceiling                   NUMERIC(18,2) GENERATED ALWAYS AS (
        recurrent_ceiling + capital_ceiling + personal_emoluments_ceiling
    ) STORED,
    created_at                      TIMESTAMPTZ DEFAULT now(),
    created_by                      UUID,
    updated_at                      TIMESTAMPTZ,
    updated_by                      UUID,
    notes                           TEXT
);

CREATE TABLE IF NOT EXISTS budget_line (
    line_id                     UUID DEFAULT gen_random_uuid() NOT NULL,
    version_id                  UUID NOT NULL,
    fiscal_year_id              UUID NOT NULL,
    authority_code              VARCHAR(20) NOT NULL,
    department_code             VARCHAR(10) NOT NULL,
    unit_code                   VARCHAR(10),
    function_code               VARCHAR(10),
    programme_id                UUID,
    commitment_type_code        VARCHAR(10),
    account_id                  UUID NOT NULL,
    original_budget             NUMERIC(18,2) DEFAULT 0 NOT NULL,
    supplementary_budget        NUMERIC(18,2) DEFAULT 0 NOT NULL,
    revised_budget              NUMERIC(18,2) GENERATED ALWAYS AS (
        original_budget + supplementary_budget
    ) STORED,
    released_amount             NUMERIC(18,2) DEFAULT 0 NOT NULL,
    committed_amount            NUMERIC(18,2) DEFAULT 0 NOT NULL,
    actual_amount               NUMERIC(18,2) DEFAULT 0 NOT NULL,
    available_balance           NUMERIC(18,2) GENERATED ALWAYS AS (
        (original_budget + supplementary_budget) - committed_amount - actual_amount
    ) STORED,
    output_description          TEXT,
    output_indicator            VARCHAR(200),
    output_target               NUMERIC(18,2),
    output_achieved             NUMERIC(18,2),
    bfp_id                      UUID,
    bfp_reference               VARCHAR(100),
    created_at                  TIMESTAMPTZ DEFAULT now(),
    created_by                  UUID,
    updated_at                  TIMESTAMPTZ,
    updated_by                  UUID,
    notes                       TEXT
);

CREATE TABLE IF NOT EXISTS budget_release (
    release_id          UUID DEFAULT gen_random_uuid() NOT NULL,
    version_id          UUID NOT NULL,
    line_id             UUID NOT NULL,
    fiscal_year_id      UUID NOT NULL,
    fiscal_period_id    UUID,
    release_date        DATE NOT NULL,
    release_amount      NUMERIC(18,2) NOT NULL,
    release_type        VARCHAR(30) DEFAULT 'QUARTERLY' NOT NULL,
    reference           VARCHAR(100),
    created_at          TIMESTAMPTZ DEFAULT now(),
    created_by          UUID,
    notes               TEXT,
    CONSTRAINT budget_release_release_amount_check CHECK (release_amount > 0),
    CONSTRAINT budget_release_release_type_check CHECK (
        release_type IN ('QUARTERLY','MONTHLY','SPECIAL','SUPPLEMENTARY')
    )
);

CREATE TABLE IF NOT EXISTS budget_variance (
    variance_id         UUID DEFAULT gen_random_uuid() NOT NULL,
    line_id             UUID NOT NULL,
    fiscal_year_id      UUID NOT NULL,
    fiscal_period_id    UUID,
    snapshot_date       DATE DEFAULT CURRENT_DATE NOT NULL,
    budget_amount       NUMERIC(18,2) NOT NULL,
    released_amount     NUMERIC(18,2) NOT NULL,
    committed_amount    NUMERIC(18,2) NOT NULL,
    actual_amount       NUMERIC(18,2) NOT NULL,
    variance_amount     NUMERIC(18,2) GENERATED ALWAYS AS (
        budget_amount - actual_amount
    ) STORED,
    variance_pct        NUMERIC(8,2),
    created_at          TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS budget_workflow_event (
    event_id        UUID DEFAULT gen_random_uuid() NOT NULL,
    cycle_id        UUID,
    version_id      UUID,
    event_type      VARCHAR(50) NOT NULL,
    event_date      TIMESTAMPTZ DEFAULT now() NOT NULL,
    actor_id        UUID,
    actor_role      VARCHAR(50),
    payload         JSONB,
    notes           TEXT
);

-- ---------------------------------------------------------------------------
-- PART 2: Primary keys
-- ---------------------------------------------------------------------------
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_cycle_pkey') THEN ALTER TABLE budget_cycle ADD CONSTRAINT budget_cycle_pkey PRIMARY KEY (cycle_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_version_pkey') THEN ALTER TABLE budget_version ADD CONSTRAINT budget_version_pkey PRIMARY KEY (version_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_bfp_pkey') THEN ALTER TABLE budget_bfp ADD CONSTRAINT budget_bfp_pkey PRIMARY KEY (bfp_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_ceiling_pkey') THEN ALTER TABLE budget_ceiling ADD CONSTRAINT budget_ceiling_pkey PRIMARY KEY (ceiling_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_pkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_pkey PRIMARY KEY (line_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_release_pkey') THEN ALTER TABLE budget_release ADD CONSTRAINT budget_release_pkey PRIMARY KEY (release_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_variance_pkey') THEN ALTER TABLE budget_variance ADD CONSTRAINT budget_variance_pkey PRIMARY KEY (variance_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_workflow_event_pkey') THEN ALTER TABLE budget_workflow_event ADD CONSTRAINT budget_workflow_event_pkey PRIMARY KEY (event_id); END IF; END $$;

-- ---------------------------------------------------------------------------
-- PART 3: Unique constraints
-- ---------------------------------------------------------------------------
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_cycle_authority_code_cycle_name_key') THEN ALTER TABLE budget_cycle ADD CONSTRAINT budget_cycle_authority_code_cycle_name_key UNIQUE (authority_code, cycle_name); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_version_cycle_id_version_number_key') THEN ALTER TABLE budget_version ADD CONSTRAINT budget_version_cycle_id_version_number_key UNIQUE (cycle_id, version_number); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_bfp_version_id_fiscal_year_id_department_code_key') THEN ALTER TABLE budget_bfp ADD CONSTRAINT budget_bfp_version_id_fiscal_year_id_department_code_key UNIQUE (version_id, fiscal_year_id, department_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_ceiling_version_id_fiscal_year_id_department_code_key') THEN ALTER TABLE budget_ceiling ADD CONSTRAINT budget_ceiling_version_id_fiscal_year_id_department_code_key UNIQUE (version_id, fiscal_year_id, department_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_variance_line_id_snapshot_date_key') THEN ALTER TABLE budget_variance ADD CONSTRAINT budget_variance_line_id_snapshot_date_key UNIQUE (line_id, snapshot_date); END IF; END $$;

-- ---------------------------------------------------------------------------
-- PART 4: Foreign keys
-- ---------------------------------------------------------------------------
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_cycle_start_fiscal_year_id_fkey') THEN ALTER TABLE budget_cycle ADD CONSTRAINT budget_cycle_start_fiscal_year_id_fkey FOREIGN KEY (start_fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_cycle_end_fiscal_year_id_fkey') THEN ALTER TABLE budget_cycle ADD CONSTRAINT budget_cycle_end_fiscal_year_id_fkey FOREIGN KEY (end_fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_cycle_authority_code_fkey') THEN ALTER TABLE budget_cycle ADD CONSTRAINT budget_cycle_authority_code_fkey FOREIGN KEY (authority_code) REFERENCES authorities(authority_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_version_cycle_id_fkey') THEN ALTER TABLE budget_version ADD CONSTRAINT budget_version_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES budget_cycle(cycle_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_bfp_version_id_fkey') THEN ALTER TABLE budget_bfp ADD CONSTRAINT budget_bfp_version_id_fkey FOREIGN KEY (version_id) REFERENCES budget_version(version_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_bfp_fiscal_year_id_fkey') THEN ALTER TABLE budget_bfp ADD CONSTRAINT budget_bfp_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_bfp_department_code_fkey') THEN ALTER TABLE budget_bfp ADD CONSTRAINT budget_bfp_department_code_fkey FOREIGN KEY (department_code) REFERENCES mofnp_department(department_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_ceiling_version_id_fkey') THEN ALTER TABLE budget_ceiling ADD CONSTRAINT budget_ceiling_version_id_fkey FOREIGN KEY (version_id) REFERENCES budget_version(version_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_ceiling_fiscal_year_id_fkey') THEN ALTER TABLE budget_ceiling ADD CONSTRAINT budget_ceiling_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_ceiling_department_code_fkey') THEN ALTER TABLE budget_ceiling ADD CONSTRAINT budget_ceiling_department_code_fkey FOREIGN KEY (department_code) REFERENCES mofnp_department(department_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_version_id_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_version_id_fkey FOREIGN KEY (version_id) REFERENCES budget_version(version_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_fiscal_year_id_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_authority_code_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_authority_code_fkey FOREIGN KEY (authority_code) REFERENCES authorities(authority_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_department_code_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_department_code_fkey FOREIGN KEY (department_code) REFERENCES mofnp_department(department_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_unit_code_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_unit_code_fkey FOREIGN KEY (unit_code) REFERENCES mofnp_unit(unit_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_function_code_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_function_code_fkey FOREIGN KEY (function_code) REFERENCES mofnp_function(function_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_programme_id_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_programme_id_fkey FOREIGN KEY (programme_id) REFERENCES mofnp_programme(programme_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_commitment_type_code_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_commitment_type_code_fkey FOREIGN KEY (commitment_type_code) REFERENCES mofnp_commitment_type(commitment_type_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_account_id_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_account_id_fkey FOREIGN KEY (account_id) REFERENCES mofnp_chart_of_accounts(account_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_line_bfp_id_fkey') THEN ALTER TABLE budget_line ADD CONSTRAINT budget_line_bfp_id_fkey FOREIGN KEY (bfp_id) REFERENCES budget_bfp(bfp_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_release_version_id_fkey') THEN ALTER TABLE budget_release ADD CONSTRAINT budget_release_version_id_fkey FOREIGN KEY (version_id) REFERENCES budget_version(version_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_release_line_id_fkey') THEN ALTER TABLE budget_release ADD CONSTRAINT budget_release_line_id_fkey FOREIGN KEY (line_id) REFERENCES budget_line(line_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_release_fiscal_year_id_fkey') THEN ALTER TABLE budget_release ADD CONSTRAINT budget_release_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_release_fiscal_period_id_fkey') THEN ALTER TABLE budget_release ADD CONSTRAINT budget_release_fiscal_period_id_fkey FOREIGN KEY (fiscal_period_id) REFERENCES fiscal_period(period_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_variance_line_id_fkey') THEN ALTER TABLE budget_variance ADD CONSTRAINT budget_variance_line_id_fkey FOREIGN KEY (line_id) REFERENCES budget_line(line_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_variance_fiscal_year_id_fkey') THEN ALTER TABLE budget_variance ADD CONSTRAINT budget_variance_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_variance_fiscal_period_id_fkey') THEN ALTER TABLE budget_variance ADD CONSTRAINT budget_variance_fiscal_period_id_fkey FOREIGN KEY (fiscal_period_id) REFERENCES fiscal_period(period_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_workflow_event_cycle_id_fkey') THEN ALTER TABLE budget_workflow_event ADD CONSTRAINT budget_workflow_event_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES budget_cycle(cycle_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'budget_workflow_event_version_id_fkey') THEN ALTER TABLE budget_workflow_event ADD CONSTRAINT budget_workflow_event_version_id_fkey FOREIGN KEY (version_id) REFERENCES budget_version(version_id); END IF; END $$;

-- ---------------------------------------------------------------------------
-- PART 5: Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_budget_bfp_dept     ON budget_bfp (department_code);
CREATE INDEX IF NOT EXISTS idx_budget_bfp_status   ON budget_bfp (status);
CREATE INDEX IF NOT EXISTS idx_budget_bfp_version  ON budget_bfp (version_id);
CREATE INDEX IF NOT EXISTS idx_budget_ceiling_dept    ON budget_ceiling (department_code);
CREATE INDEX IF NOT EXISTS idx_budget_ceiling_version ON budget_ceiling (version_id);
CREATE INDEX IF NOT EXISTS idx_budget_cycle_auth   ON budget_cycle (authority_code);
CREATE INDEX IF NOT EXISTS idx_budget_cycle_status ON budget_cycle (status);
CREATE INDEX IF NOT EXISTS idx_budget_line_acct    ON budget_line (account_id);
CREATE INDEX IF NOT EXISTS idx_budget_line_auth    ON budget_line (authority_code);
CREATE INDEX IF NOT EXISTS idx_budget_line_commit  ON budget_line (commitment_type_code);
CREATE INDEX IF NOT EXISTS idx_budget_line_dept    ON budget_line (department_code);
CREATE INDEX IF NOT EXISTS idx_budget_line_fy      ON budget_line (fiscal_year_id);
CREATE INDEX IF NOT EXISTS idx_budget_line_prog    ON budget_line (programme_id);
CREATE INDEX IF NOT EXISTS idx_budget_line_version ON budget_line (version_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_budget_line_unique_coding ON budget_line (
    version_id, fiscal_year_id, authority_code, department_code,
    COALESCE(unit_code, ''),
    COALESCE(function_code, ''),
    COALESCE(programme_id, '00000000-0000-0000-0000-000000000000'::uuid),
    COALESCE(commitment_type_code, ''),
    account_id
);

CREATE INDEX IF NOT EXISTS idx_budget_release_date   ON budget_release (release_date);
CREATE INDEX IF NOT EXISTS idx_budget_release_line   ON budget_release (line_id);
CREATE INDEX IF NOT EXISTS idx_budget_release_period ON budget_release (fiscal_period_id);
CREATE INDEX IF NOT EXISTS idx_budget_variance_date ON budget_variance (snapshot_date);
CREATE INDEX IF NOT EXISTS idx_budget_variance_line ON budget_variance (line_id);
CREATE INDEX IF NOT EXISTS idx_budget_version_current ON budget_version (is_current) WHERE is_current = true;
CREATE INDEX IF NOT EXISTS idx_budget_version_cycle   ON budget_version (cycle_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_budget_version_one_current ON budget_version (cycle_id) WHERE is_current = true;
CREATE INDEX IF NOT EXISTS idx_budget_wf_cycle   ON budget_workflow_event (cycle_id);
CREATE INDEX IF NOT EXISTS idx_budget_wf_date    ON budget_workflow_event (event_date);
CREATE INDEX IF NOT EXISTS idx_budget_wf_type    ON budget_workflow_event (event_type);
CREATE INDEX IF NOT EXISTS idx_budget_wf_version ON budget_workflow_event (version_id);

-- ---------------------------------------------------------------------------
-- PART 6: Verification
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    table_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name IN (
        'budget_cycle','budget_version','budget_bfp','budget_ceiling',
        'budget_line','budget_release','budget_variance','budget_workflow_event'
      );

    IF table_count < 8 THEN
        RAISE EXCEPTION 'V108 FAILED: Expected 8 budget tables, found %', table_count;
    END IF;

    RAISE NOTICE 'V108 PASSED: Budget module ready (% of 8 tables present)', table_count;
END $$;
