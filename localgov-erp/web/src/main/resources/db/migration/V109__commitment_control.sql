-- ============================================================================
-- V109: Commitment Control Module (MoFNP Section 14.4)
-- ----------------------------------------------------------------------------
-- Implements the commitment control system as per the MoFNP Local Government
-- Accounting and Financial Procedures Manual (Dec 2023), Section 14.4.
--
-- Idempotent: safe to run on a fresh DB, a partially-migrated DB, or a fully
-- migrated DB.
--
-- Depends on: V59 (fiscal_periods), V85/V87 (AP module),
--             V103 (MoFNP reference tables), V105 (MoFNP chart),
--             V108 (budget module)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- PART 1: Tables
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS commitment_requisition (
    requisition_id              UUID DEFAULT gen_random_uuid() NOT NULL,
    authority_code              VARCHAR(20) NOT NULL,
    requisition_number          VARCHAR(50) NOT NULL,
    fiscal_year_id              UUID NOT NULL,
    fiscal_period_id            UUID,
    requisition_date            DATE DEFAULT CURRENT_DATE NOT NULL,
    department_code             VARCHAR(10) NOT NULL,
    unit_code                   VARCHAR(10),
    budget_line_id              UUID NOT NULL,
    programme_id                UUID,
    account_id                  UUID NOT NULL,
    payee_name                  VARCHAR(200),
    vendor_id                   UUID,
    purchase_order_id           UUID,
    description                 TEXT NOT NULL,
    estimated_amount            NUMERIC(18,2) NOT NULL,
    currency                    VARCHAR(3) DEFAULT 'ZMW',
    status                      VARCHAR(30) DEFAULT 'DRAFT' NOT NULL,
    availability_check_result   JSONB,
    availability_checked_at     TIMESTAMPTZ,
    availability_checked_by     UUID,
    submitted_at                TIMESTAMPTZ,
    submitted_by                UUID,
    approved_at                 TIMESTAMPTZ,
    approved_by                 UUID,
    rejection_reason            TEXT,
    created_at                  TIMESTAMPTZ DEFAULT now(),
    created_by                  UUID,
    updated_at                  TIMESTAMPTZ,
    updated_by                  UUID,
    notes                       TEXT,
    CONSTRAINT commitment_requisition_estimated_amount_check CHECK (estimated_amount > 0),
    CONSTRAINT commitment_requisition_status_check CHECK (
        status IN ('DRAFT','SUBMITTED','AVAILABILITY_CHECKED','APPROVED','REJECTED',
                   'COMMITTED','PARTIALLY_PAID','FULLY_PAID','CANCELLED')
    )
);

CREATE TABLE IF NOT EXISTS commitment (
    commitment_id           UUID DEFAULT gen_random_uuid() NOT NULL,
    authority_code          VARCHAR(20) NOT NULL,
    requisition_id          UUID NOT NULL,
    commitment_number       VARCHAR(50) NOT NULL,
    fiscal_year_id          UUID NOT NULL,
    budget_line_id          UUID NOT NULL,
    commitment_amount       NUMERIC(18,2) NOT NULL,
    paid_amount             NUMERIC(18,2) DEFAULT 0 NOT NULL,
    released_amount         NUMERIC(18,2) DEFAULT 0 NOT NULL,
    balance_amount          NUMERIC(18,2) GENERATED ALWAYS AS (
        commitment_amount - paid_amount - released_amount
    ) STORED,
    committed_date          DATE DEFAULT CURRENT_DATE NOT NULL,
    expected_payment_date   DATE,
    status                  VARCHAR(30) DEFAULT 'ACTIVE' NOT NULL,
    released_at             TIMESTAMPTZ,
    released_by             UUID,
    release_reason          TEXT,
    cancelled_at            TIMESTAMPTZ,
    cancelled_by            UUID,
    cancellation_reason     TEXT,
    created_at              TIMESTAMPTZ DEFAULT now(),
    created_by              UUID,
    updated_at              TIMESTAMPTZ,
    updated_by              UUID,
    notes                   TEXT,
    CONSTRAINT commitment_commitment_amount_check CHECK (commitment_amount > 0),
    CONSTRAINT commitment_status_check CHECK (
        status IN ('ACTIVE','PARTIALLY_PAID','FULLY_PAID','RELEASED','CANCELLED')
    )
);

CREATE TABLE IF NOT EXISTS commitment_invoice_link (
    link_id                 UUID DEFAULT gen_random_uuid() NOT NULL,
    commitment_id           UUID NOT NULL,
    ap_invoice_id           UUID NOT NULL,
    ap_invoice_line_id      UUID,
    linked_amount           NUMERIC(18,2) NOT NULL,
    linked_at               TIMESTAMPTZ DEFAULT now(),
    linked_by               UUID,
    notes                   TEXT,
    CONSTRAINT commitment_invoice_link_linked_amount_check CHECK (linked_amount > 0)
);

CREATE TABLE IF NOT EXISTS commitment_workflow_event (
    event_id        UUID DEFAULT gen_random_uuid() NOT NULL,
    requisition_id  UUID,
    commitment_id   UUID,
    event_type      VARCHAR(50) NOT NULL,
    event_at        TIMESTAMPTZ DEFAULT now(),
    actor_id        UUID,
    actor_role      VARCHAR(50),
    payload         JSONB,
    notes           TEXT
);

-- ---------------------------------------------------------------------------
-- PART 2: Primary keys
-- ---------------------------------------------------------------------------
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_pkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_pkey PRIMARY KEY (requisition_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_pkey') THEN ALTER TABLE commitment ADD CONSTRAINT commitment_pkey PRIMARY KEY (commitment_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_invoice_link_pkey') THEN ALTER TABLE commitment_invoice_link ADD CONSTRAINT commitment_invoice_link_pkey PRIMARY KEY (link_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_workflow_event_pkey') THEN ALTER TABLE commitment_workflow_event ADD CONSTRAINT commitment_workflow_event_pkey PRIMARY KEY (event_id); END IF; END $$;

-- ---------------------------------------------------------------------------
-- PART 3: Unique constraints
-- ---------------------------------------------------------------------------
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_authority_code_requisition_number_key') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_authority_code_requisition_number_key UNIQUE (authority_code, requisition_number); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_authority_code_commitment_number_key') THEN ALTER TABLE commitment ADD CONSTRAINT commitment_authority_code_commitment_number_key UNIQUE (authority_code, commitment_number); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_id_key') THEN ALTER TABLE commitment ADD CONSTRAINT commitment_requisition_id_key UNIQUE (requisition_id); END IF; END $$;

-- ---------------------------------------------------------------------------
-- PART 4: Foreign keys
-- ---------------------------------------------------------------------------
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_authority_code_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_authority_code_fkey FOREIGN KEY (authority_code) REFERENCES authorities(authority_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_fiscal_year_id_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_fiscal_period_id_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_fiscal_period_id_fkey FOREIGN KEY (fiscal_period_id) REFERENCES fiscal_period(period_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_department_code_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_department_code_fkey FOREIGN KEY (department_code) REFERENCES mofnp_department(department_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_unit_code_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_unit_code_fkey FOREIGN KEY (unit_code) REFERENCES mofnp_unit(unit_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_budget_line_id_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_budget_line_id_fkey FOREIGN KEY (budget_line_id) REFERENCES budget_line(line_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_programme_id_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_programme_id_fkey FOREIGN KEY (programme_id) REFERENCES mofnp_programme(programme_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_account_id_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_account_id_fkey FOREIGN KEY (account_id) REFERENCES mofnp_chart_of_accounts(account_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_vendor_id_fkey') THEN ALTER TABLE commitment_requisition ADD CONSTRAINT commitment_requisition_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES ap_vendor(vendor_id); END IF; END $$;

DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_authority_code_fkey') THEN ALTER TABLE commitment ADD CONSTRAINT commitment_authority_code_fkey FOREIGN KEY (authority_code) REFERENCES authorities(authority_code); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_requisition_id_fkey') THEN ALTER TABLE commitment ADD CONSTRAINT commitment_requisition_id_fkey FOREIGN KEY (requisition_id) REFERENCES commitment_requisition(requisition_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_fiscal_year_id_fkey') THEN ALTER TABLE commitment ADD CONSTRAINT commitment_fiscal_year_id_fkey FOREIGN KEY (fiscal_year_id) REFERENCES fiscal_year(fiscal_year_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_budget_line_id_fkey') THEN ALTER TABLE commitment ADD CONSTRAINT commitment_budget_line_id_fkey FOREIGN KEY (budget_line_id) REFERENCES budget_line(line_id); END IF; END $$;

DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_invoice_link_commitment_id_fkey') THEN ALTER TABLE commitment_invoice_link ADD CONSTRAINT commitment_invoice_link_commitment_id_fkey FOREIGN KEY (commitment_id) REFERENCES commitment(commitment_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_invoice_link_ap_invoice_id_fkey') THEN ALTER TABLE commitment_invoice_link ADD CONSTRAINT commitment_invoice_link_ap_invoice_id_fkey FOREIGN KEY (ap_invoice_id) REFERENCES ap_invoice(invoice_id); END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_invoice_link_ap_invoice_line_id_fkey') THEN ALTER TABLE commitment_invoice_link ADD CONSTRAINT commitment_invoice_link_ap_invoice_line_id_fkey FOREIGN KEY (ap_invoice_line_id) REFERENCES ap_invoice_line(line_id); END IF; END $$;

DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_workflow_event_requisition_id_fkey') THEN ALTER TABLE commitment_workflow_event ADD CONSTRAINT commitment_workflow_event_requisition_id_fkey FOREIGN KEY (requisition_id) REFERENCES commitment_requisition(requisition_id) ON DELETE CASCADE; END IF; END $$;
DO $$ BEGIN IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'commitment_workflow_event_commitment_id_fkey') THEN ALTER TABLE commitment_workflow_event ADD CONSTRAINT commitment_workflow_event_commitment_id_fkey FOREIGN KEY (commitment_id) REFERENCES commitment(commitment_id) ON DELETE CASCADE; END IF; END $$;

-- ---------------------------------------------------------------------------
-- PART 5: Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_commitment_auth        ON commitment (authority_code);
CREATE INDEX IF NOT EXISTS idx_commitment_budget_line ON commitment (budget_line_id);
CREATE INDEX IF NOT EXISTS idx_commitment_date        ON commitment (committed_date);
CREATE INDEX IF NOT EXISTS idx_commitment_fy          ON commitment (fiscal_year_id);
CREATE INDEX IF NOT EXISTS idx_commitment_status      ON commitment (status);

CREATE INDEX IF NOT EXISTS idx_commit_link_commitment ON commitment_invoice_link (commitment_id);
CREATE INDEX IF NOT EXISTS idx_commit_link_invoice    ON commitment_invoice_link (ap_invoice_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_commit_link_unique ON commitment_invoice_link (
    commitment_id, ap_invoice_id,
    COALESCE(ap_invoice_line_id, '00000000-0000-0000-0000-000000000000'::uuid)
);

CREATE INDEX IF NOT EXISTS idx_commit_req_auth        ON commitment_requisition (authority_code);
CREATE INDEX IF NOT EXISTS idx_commit_req_budget_line ON commitment_requisition (budget_line_id);
CREATE INDEX IF NOT EXISTS idx_commit_req_date        ON commitment_requisition (requisition_date);
CREATE INDEX IF NOT EXISTS idx_commit_req_dept        ON commitment_requisition (department_code);
CREATE INDEX IF NOT EXISTS idx_commit_req_fy          ON commitment_requisition (fiscal_year_id);
CREATE INDEX IF NOT EXISTS idx_commit_req_status      ON commitment_requisition (status);

CREATE INDEX IF NOT EXISTS idx_commit_wf_commit ON commitment_workflow_event (commitment_id);
CREATE INDEX IF NOT EXISTS idx_commit_wf_date   ON commitment_workflow_event (event_at);
CREATE INDEX IF NOT EXISTS idx_commit_wf_req    ON commitment_workflow_event (requisition_id);
CREATE INDEX IF NOT EXISTS idx_commit_wf_type   ON commitment_workflow_event (event_type);

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
        'commitment','commitment_requisition',
        'commitment_invoice_link','commitment_workflow_event'
      );

    IF table_count < 4 THEN
        RAISE EXCEPTION 'V109 FAILED: Expected 4 commitment tables, found %', table_count;
    END IF;

    RAISE NOTICE 'V109 PASSED: Commitment control module ready (% of 4 tables present)', table_count;
END $$;
