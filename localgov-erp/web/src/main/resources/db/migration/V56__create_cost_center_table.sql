-- =====================================================================
-- V56__create_cost_center_table.sql
-- Cost Centers — Organisational Structure for Financial Accountability
-- =====================================================================
-- Every journal line is tagged with a cost center. This maps financial
-- activity to the organisational unit responsible for it.
--
-- Enables:
--   - Departmental reporting (Finance, Engineering, Health, etc.)
--   - Section-level analysis (Revenue, Expenditure, Payroll)
--   - Budget vs actual by cost center
--   - Cost allocation across funds
--   - AGO traceability (who spent what)
--
-- Aligned with the Local Authority organisational structure defined
-- in the Restructuring Reports (MDD/Cabinet Office 2023/2024).
-- =====================================================================

CREATE TABLE cost_center (
    cost_center_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cost_center_code        VARCHAR(10) NOT NULL UNIQUE,
    cost_center_name        VARCHAR(255) NOT NULL,
    cost_center_type        VARCHAR(50) NOT NULL,
        -- DEPARTMENT, SECTION, UNIT, SUB_UNIT, PROJECT, VENTURE
    parent_cost_center_id   UUID REFERENCES cost_center(cost_center_id),
    department_code         VARCHAR(20),
        -- Short code for the department (COS, FIN, ENG, etc.)
    description             TEXT,
    manager_user_id         UUID,
        -- Optional: the user responsible for this cost center
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from          DATE NOT NULL,
    effective_to            DATE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by              UUID,
    CONSTRAINT chk_cost_center_dates
        CHECK (effective_to IS NULL OR effective_to >= effective_from),
    CONSTRAINT chk_cost_center_type
        CHECK (cost_center_type IN (
            'DEPARTMENT', 'SECTION', 'UNIT', 'SUB_UNIT', 'PROJECT', 'VENTURE'
        ))
);

CREATE INDEX idx_cost_center_code ON cost_center(cost_center_code);
CREATE INDEX idx_cost_center_parent ON cost_center(parent_cost_center_id);
CREATE INDEX idx_cost_center_department ON cost_center(department_code);
CREATE INDEX idx_cost_center_type ON cost_center(cost_center_type);
CREATE INDEX idx_cost_center_active ON cost_center(cost_center_code) WHERE is_active = TRUE;

COMMENT ON TABLE cost_center IS
'Organisational cost centers. Every journal line is tagged with one. '
'Maps financial activity to responsible departments, sections, and units. '
'Enables departmental reporting and budget control by organisation.';

COMMENT ON COLUMN cost_center.cost_center_type IS
'DEPARTMENT (top-level), SECTION (within department), UNIT (within section), '
'SUB_UNIT (within unit), PROJECT (temporary), VENTURE (commercial activity).';

-- ---------------------------------------------------------------------
-- SEED DATA — Top-Level Departments (from Restructuring Reports)
-- ---------------------------------------------------------------------
INSERT INTO cost_center
    (cost_center_code, cost_center_name, cost_center_type, department_code,
     description, effective_from)
VALUES
    ('0100', 'Office of the Council Secretary', 'DEPARTMENT', 'COS',
     'Office of the Town Clerk / Council Secretary. Provides overall policy guidance and oversight.',
     '2026-01-01'),

    ('0200', 'Finance Department', 'DEPARTMENT', 'FIN',
     'Manages financial resources, revenue, expenditure, budget, payroll, and stores.',
     '2026-01-01'),

    ('0300', 'Engineering Department', 'DEPARTMENT', 'ENG',
     'Provides engineering services, roads, drainages, buildings, parks, fire and rescue, water and sanitation.',
     '2026-01-01'),

    ('0400', 'Community Services Department', 'DEPARTMENT', 'CSD',
     'Provides community development, social welfare, sports, culture, library services, bus stations, markets and housing.',
     '2026-01-01'),

    ('0500', 'Planning Department', 'DEPARTMENT', 'PLN',
     'Responsible for development control, land use regulation, survey, valuation, and socio-economic planning.',
     '2026-01-01'),

    ('0600', 'Health Services Department', 'DEPARTMENT', 'HLT',
     'Provides preventive and curative health services, public health, and health information systems.',
     '2026-01-01'),

    ('0700', 'Fisheries, Livestock & Veterinary Services', 'DEPARTMENT', 'FLV',
     'Implements livestock development, veterinary services, and fisheries programmes.',
     '2026-01-01'),

    ('0800', 'Human Resource & Administration Department', 'DEPARTMENT', 'HRA',
     'Manages human resources, administration, committees, security, and registry.',
     '2026-01-01'),

    ('0900', 'Legal Services Department', 'DEPARTMENT', 'LEG',
     'Provides legal advice, litigation, contracts, deeds, and licensing services.',
     '2026-01-01'),

    ('1000', 'Internal Audit Unit', 'UNIT', 'AUD',
     'Conducts audit assignments, reviews risk management, and reports to the Audit Committee.',
     '2026-01-01'),

    ('1100', 'Procurement Unit', 'UNIT', 'PRC',
     'Manages procurement of works, goods, and services for the Council.',
     '2026-01-01'),

    ('1200', 'ICT Unit', 'UNIT', 'ICT',
     'Provides ICT services, management of information systems, and digital infrastructure.',
     '2026-01-01'),

    ('1300', 'Commercial & Business Development Unit', 'UNIT', 'CBD',
     'Manages commercial ventures including guest houses, transport, abattoir, and business development.',
     '2026-01-01');

-- ---------------------------------------------------------------------
-- SEED DATA — Sections under Finance Department (Example Depth)
-- ---------------------------------------------------------------------
INSERT INTO cost_center
    (cost_center_code, cost_center_name, cost_center_type, parent_cost_center_id,
     department_code, description, effective_from)
SELECT
    cc_code, cc_name, 'SECTION', pcc.cost_center_id, 'FIN', cc_desc, '2026-01-01'
FROM (VALUES
    ('0201', 'Finance Section',   'Revenue, expenditure, budget, and payroll functions.'),
    ('0202', 'Stores Section',    'Receipt, storage, and issue of goods.'),
    ('0203', 'Commercial Section','Commercial ventures within Finance.'),
    ('0204', 'Treasury Section',  'Cash and bank management.')
) AS t(cc_code, cc_name, cc_desc)
CROSS JOIN (
    SELECT cost_center_id FROM cost_center WHERE cost_center_code = '0200'
) AS pcc;

-- ---------------------------------------------------------------------
-- AUDIT LOG — Record cost center creation
-- ---------------------------------------------------------------------
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason, changed_by, record_hash)
SELECT
    'COST_CENTER',
    cc.cost_center_id,
    'CREATE',
    jsonb_build_object(
        'cost_center_code', cc.cost_center_code,
        'cost_center_name', cc.cost_center_name,
        'cost_center_type', cc.cost_center_type,
        'department_code', cc.department_code
    ),
    'Initial cost center structure — ' || cc.cost_center_type,
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256((cc.cost_center_id::text || cc.cost_center_code || NOW()::text)::bytea), 'hex')
FROM cost_center cc;
