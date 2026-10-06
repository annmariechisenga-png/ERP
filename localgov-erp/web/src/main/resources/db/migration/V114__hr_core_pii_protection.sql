-- ============================================================================
-- V114: HR Core — PII Protection
-- ----------------------------------------------------------------------------
-- Adds hash/masked/encrypted columns for all Personally Identifiable
-- Information (PII) and financial identifiers on the employees table.
--
-- Design:
--   * _hash       — SHA-256 with per-tenant salt. Deterministic. Used for
--                   lookups and to enforce global uniqueness of identifiers
--                   like NRC, phone number, TIN.
--   * _masked     — Masked display value. Safe to show in lists, reports,
--                   UI. No key required to derive.
--   * _encrypted  — AES-256-GCM ciphertext. Authorized users only. Key lives
--                   in the Java application (PiiEncryptionService), never in
--                   the database.
--
-- This migration ONLY adds columns, indexes, and comments. It does NOT
-- backfill existing plaintext values into the new columns — that requires
-- the Java PiiEncryptionService and the encryption key. Backfill happens
-- as a separate operation after this migration is applied.
--
-- The plaintext columns (nrc_number, phone_number, etc.) are retained until
-- backfill is verified. A later migration (V114.x) will drop them.
--
-- Compliance:
--   * Data Protection Act No. 3 of 2021 (privacy, integrity, confidentiality)
--   * Electronic Government Act No. 41 of 2021 (secure digital government)
--   * IPSAS / IFRS (financial data protection)
--
-- Depends on: V112 (employees schema alignment)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- PART 1: Add PII protection columns
-- ---------------------------------------------------------------------------

-- NRC (National Registration Card)
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS nrc_hash TEXT,
    ADD COLUMN IF NOT EXISTS nrc_masked TEXT,
    ADD COLUMN IF NOT EXISTS nrc_encrypted TEXT;

-- Phone number
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS phone_hash TEXT,
    ADD COLUMN IF NOT EXISTS phone_masked TEXT,
    ADD COLUMN IF NOT EXISTS phone_encrypted TEXT;

-- TIN (Zambia Revenue Authority Tax Identification Number)
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS tpin_hash TEXT,
    ADD COLUMN IF NOT EXISTS tpin_masked TEXT,
    ADD COLUMN IF NOT EXISTS tpin_encrypted TEXT;

-- NAPSA number
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS napsa_hash TEXT,
    ADD COLUMN IF NOT EXISTS napsa_masked TEXT,
    ADD COLUMN IF NOT EXISTS napsa_encrypted TEXT;

-- NHIMA number
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS nhima_hash TEXT,
    ADD COLUMN IF NOT EXISTS nhima_masked TEXT,
    ADD COLUMN IF NOT EXISTS nhima_encrypted TEXT;

-- LASF number
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS lasf_hash TEXT,
    ADD COLUMN IF NOT EXISTS lasf_masked TEXT,
    ADD COLUMN IF NOT EXISTS lasf_encrypted TEXT;

-- Bank account number
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS bank_account_hash TEXT,
    ADD COLUMN IF NOT EXISTS bank_account_masked TEXT,
    ADD COLUMN IF NOT EXISTS bank_account_encrypted TEXT;

-- Email
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS email_hash TEXT,
    ADD COLUMN IF NOT EXISTS email_masked TEXT,
    ADD COLUMN IF NOT EXISTS email_encrypted TEXT;

-- Date of Birth (no hash — not a lookup key, only masked + encrypted)
ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS dob_masked TEXT,
    ADD COLUMN IF NOT EXISTS dob_encrypted TEXT;

-- ---------------------------------------------------------------------------
-- PART 2: Unique indexes on hash columns (global uniqueness per authority)
-- ---------------------------------------------------------------------------
-- These enforce that no two active employees in the same authority share an
-- NRC, phone number, TIN, etc. Multi-tenant scoped via authority_code.

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_nrc_hash 
    ON employees(authority_code, nrc_hash) 
    WHERE nrc_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_phone_hash 
    ON employees(authority_code, phone_hash) 
    WHERE phone_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_tpin_hash 
    ON employees(authority_code, tpin_hash) 
    WHERE tpin_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_napsa_hash 
    ON employees(authority_code, napsa_hash) 
    WHERE napsa_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_nhima_hash 
    ON employees(authority_code, nhima_hash) 
    WHERE nhima_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_lasf_hash 
    ON employees(authority_code, lasf_hash) 
    WHERE lasf_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_bank_hash 
    ON employees(authority_code, bank_account_hash) 
    WHERE bank_account_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

CREATE UNIQUE INDEX IF NOT EXISTS idx_employees_email_hash 
    ON employees(authority_code, email_hash) 
    WHERE email_hash IS NOT NULL AND employment_status IN ('ACTIVE', 'SUSPENDED');

-- ---------------------------------------------------------------------------
-- PART 3: Performance indexes on masked columns (for search/UI)
-- ---------------------------------------------------------------------------
-- Masked values are used for display and filtering. Index them lightly.

CREATE INDEX IF NOT EXISTS idx_employees_nrc_masked 
    ON employees(authority_code, nrc_masked) WHERE nrc_masked IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_employees_phone_masked 
    ON employees(authority_code, phone_masked) WHERE phone_masked IS NOT NULL;

-- ---------------------------------------------------------------------------
-- PART 4: Documentation (column comments)
-- ---------------------------------------------------------------------------

COMMENT ON COLUMN employees.nrc_hash IS 
    'SHA-256(NRC + tenant salt). Deterministic. Used for uniqueness check and lookup. Never displayed.';

COMMENT ON COLUMN employees.nrc_masked IS 
    'Masked NRC for display. Format: ******/NN/N (shows last 4 characters). No key required.';

COMMENT ON COLUMN employees.nrc_encrypted IS 
    'AES-256-GCM ciphertext of full NRC. Decrypted only by PiiEncryptionService for authorized users.';

COMMENT ON COLUMN employees.phone_hash IS 
    'SHA-256(phone + tenant salt). Used for USSD lookup by MSISDN. Never displayed.';

COMMENT ON COLUMN employees.phone_masked IS 
    'Masked phone for display. Format: +260 97* **NN (shows first 6, last 2).';

COMMENT ON COLUMN employees.phone_encrypted IS 
    'AES-256-GCM ciphertext of full phone. Decrypted only for authorized operations (payment, SMS delivery).';

COMMENT ON COLUMN employees.tpin_hash IS 
    'SHA-256(TPIN + tenant salt). TIN is unique per taxpayer per authority.';

COMMENT ON COLUMN employees.tpin_masked IS 
    'Masked TPIN. Format: ****NNNN (shows last 4).';

COMMENT ON COLUMN employees.tpin_encrypted IS 
    'AES-256-GCM ciphertext of full TPIN.';

COMMENT ON COLUMN employees.napsa_hash IS 
    'SHA-256(NAPSA number + tenant salt).';

COMMENT ON COLUMN employees.napsa_masked IS 
    'Masked NAPSA number. Format: ****NNNN.';

COMMENT ON COLUMN employees.napsa_encrypted IS 
    'AES-256-GCM ciphertext of full NAPSA number.';

COMMENT ON COLUMN employees.nhima_hash IS 
    'SHA-256(NHIMA number + tenant salt).';

COMMENT ON COLUMN employees.nhima_masked IS 
    'Masked NHIMA number. Format: ****NNNN.';

COMMENT ON COLUMN employees.nhima_encrypted IS 
    'AES-256-GCM ciphertext of full NHIMA number.';

COMMENT ON COLUMN employees.lasf_hash IS 
    'SHA-256(LASF number + tenant salt).';

COMMENT ON COLUMN employees.lasf_masked IS 
    'Masked LASF number. Format: ****NNNN.';

COMMENT ON COLUMN employees.lasf_encrypted IS 
    'AES-256-GCM ciphertext of full LASF number.';

COMMENT ON COLUMN employees.bank_account_hash IS 
    'SHA-256(bank account number + tenant salt).';

COMMENT ON COLUMN employees.bank_account_masked IS 
    'Masked bank account. Format: ****NNNN (shows last 4).';

COMMENT ON COLUMN employees.bank_account_encrypted IS 
    'AES-256-GCM ciphertext of full bank account number. Decrypted only during payment file generation.';

COMMENT ON COLUMN employees.email_hash IS 
    'SHA-256(lowercase(email) + tenant salt).';

COMMENT ON COLUMN employees.email_masked IS 
    'Masked email. Format: f****@domain.com.';

COMMENT ON COLUMN employees.email_encrypted IS 
    'AES-256-GCM ciphertext of full email.';

COMMENT ON COLUMN employees.dob_masked IS 
    'Masked date of birth. Format: YYYY-**-**. Shows year only.';

COMMENT ON COLUMN employees.dob_encrypted IS 
    'AES-256-GCM ciphertext of full date of birth.';

COMMENT ON TABLE employees IS 
    'Employee master data. PII fields (NRC, phone, TIN, NAPSA, NHIMA, LASF, bank account, email, DOB) have three protection columns each: _hash for lookup, _masked for display, _encrypted for authorized decryption. See V114 for details. Multi-tenant scoped via authority_code.';

-- ---------------------------------------------------------------------------
-- PART 5: Helper view — masked-only employee list (safe for general UI)
-- ---------------------------------------------------------------------------
-- This view exposes ONLY masked PII. Use it for:
--   * Employee directories
--   * Reports that don't need full PII
--   * Any UI where full PII isn't required
--
-- For authorized access to full PII, use the base table with PiiEncryptionService.

DROP VIEW IF EXISTS v_employee_masked;

CREATE VIEW v_employee_masked AS
SELECT 
    -- Identifiers
    e.employee_id,
    e.employee_uuid,
    e.authority_code,
    e.province,
    e.district,
    e.department,
    e.position,
    e.salary_scale,
    e.employment_status,
    e.contract_type,

    -- Name
    COALESCE(
        NULLIF(TRIM(BOTH ' ' FROM 
            COALESCE(e.first_name,'') || ' ' || 
            COALESCE(e.middle_name,'') || ' ' || 
            COALESCE(e.last_name,'')), ''),
        e.name
    ) AS full_name,

    -- Sex
    e.sex,

    -- Dates (masked where applicable)
    e.date_of_first_appointment,
    e.date_confirmed,
    e.date_substantive_appointment,
    e.date_reported,
    e.dob_masked,

    -- Division (derived)
    CASE
        WHEN e.salary_scale ~ '^LGSS/0[1-7]$' THEN 'I'
        WHEN e.salary_scale ~ '^LGSS/0[8-9]$' OR e.salary_scale ~ '^LGSS/1[0-2]$' THEN 'II'
        WHEN e.salary_scale ~ '^LGSS/1[3-8]$' THEN 'III'
        WHEN e.salary_scale IN ('G1','G2','G3','Grade 1','Grade 2','Grade 3') THEN 'IV'
        ELSE NULL
    END AS division,

    -- Masked PII
    e.nrc_masked,
    e.phone_masked,
    e.tpin_masked,
    e.napsa_masked,
    e.nhima_masked,
    e.lasf_masked,
    e.bank_account_masked,
    e.email_masked,

    -- Other non-PII fields
    e.academic_qualifications,
    e.professional_qualifications,
    e.acting_position,
    e.acting_date,
    e.default_fund_id,
    e.default_cost_center_id,
    e.supervisor_id,
    e.remarks,
    e.lgsc_comment,
    e.created_at,
    e.updated_at
FROM employees e;

COMMENT ON VIEW v_employee_masked IS 
    'Employee list with PII masked. Safe for general UI use. For full PII, use employees table with PiiEncryptionService. Multi-tenant: filter by authority_code.';

-- ---------------------------------------------------------------------------
-- PART 6: Verification
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    total_columns INTEGER;
    expected_columns INTEGER := 26;  -- 8 fields × 3 + 1 DOB × 2 = 26
    missing TEXT[];
BEGIN
    -- Check that all columns exist
    SELECT ARRAY_AGG(col) INTO missing
    FROM (
        SELECT unnest(ARRAY[
            'nrc_hash','nrc_masked','nrc_encrypted',
            'phone_hash','phone_masked','phone_encrypted',
            'tpin_hash','tpin_masked','tpin_encrypted',
            'napsa_hash','napsa_masked','napsa_encrypted',
            'nhima_hash','nhima_masked','nhima_encrypted',
            'lasf_hash','lasf_masked','lasf_encrypted',
            'bank_account_hash','bank_account_masked','bank_account_encrypted',
            'email_hash','email_masked','email_encrypted',
            'dob_masked','dob_encrypted'
        ]) AS col
    ) required
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'employees' AND column_name = required.col
    );

    IF array_length(missing, 1) > 0 THEN
        RAISE EXCEPTION 'V114 FAILED: Missing columns: %', missing;
    END IF;

    -- Count total PII protection columns
    SELECT COUNT(*) INTO total_columns
    FROM information_schema.columns
    WHERE table_name = 'employees'
      AND (column_name LIKE '%_hash' OR column_name LIKE '%_masked' OR column_name LIKE '%_encrypted');

    RAISE NOTICE 'V114 PASSED: % PII protection columns added (expected 26)', total_columns;
    RAISE NOTICE 'V114 NEXT STEPS:';
    RAISE NOTICE '  1. Build PiiEncryptionService in Java';
    RAISE NOTICE '  2. Backfill: hash + encrypt existing plaintext values';
    RAISE NOTICE '  3. Verify: decrypted values match originals';
    RAISE NOTICE '  4. V114.1: drop plaintext columns';
END $$;
