-- V18: Corrected salary notch logic (Notch 1 = lowest, Notch 7 = highest)
--
-- This migration applies the user's corrected progression model to the EXISTING ERP schema.
-- Existing canonical tables are retained:
--   - salary_scales_official
--   - erp_salary_notch_value
--
-- Why not recreate new UUID-based tables:
--   1) Existing APIs/services already depend on current table names and PK/FK types.
--   2) The proposed generated columns use window functions (LAG) and cross-table references,
--      which are not valid in PostgreSQL stored generated columns.
--
-- Instead, this migration:
--   - Extends salary_scales_official with progression metadata.
--   - Enforces strictly increasing monthly salary by notch (per scale/effective_from).
--   - Provides a compatibility VIEW named salary_notch_values with requested column names.
--   - Seeds corrected INCREASING LGSS05 and LGSS08 values.

-- ---------------------------------------------------------------------
-- 1) Extend salary_scales_official with progression metadata
-- ---------------------------------------------------------------------
ALTER TABLE salary_scales_official
    ADD COLUMN IF NOT EXISTS progression_direction VARCHAR(10) NOT NULL DEFAULT 'INCREASING',
    ADD COLUMN IF NOT EXISTS notch_increment NUMERIC(10,2);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
          FROM pg_constraint
         WHERE conname = 'chk_salary_scales_official_progression_direction'
           AND conrelid = 'salary_scales_official'::regclass
    ) THEN
        ALTER TABLE salary_scales_official
            ADD CONSTRAINT chk_salary_scales_official_progression_direction
            CHECK (progression_direction IN ('INCREASING'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM pg_constraint
         WHERE conname = 'chk_salary_scales_official_min_notch_is_one'
           AND conrelid = 'salary_scales_official'::regclass
    ) THEN
        ALTER TABLE salary_scales_official
            ADD CONSTRAINT chk_salary_scales_official_min_notch_is_one
            CHECK (min_notch = 1);
    END IF;
END $$;

-- ---------------------------------------------------------------------
-- 2) Validation trigger: enforce increasing notch amounts
--    Notch 1 < Notch 2 < ... < Notch N for each (salary_scale, effective_from)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_validate_increasing_notch_values()
RETURNS TRIGGER AS $$
DECLARE
    v_prev_salary NUMERIC(18,2);
    v_next_salary NUMERIC(18,2);
BEGIN
    IF NEW.notch_no < 1 THEN
        RAISE EXCEPTION 'notch_no must be >= 1';
    END IF;

    IF NEW.monthly_salary <= 0 THEN
        RAISE EXCEPTION 'monthly_salary must be > 0';
    END IF;

    SELECT n.monthly_salary
      INTO v_prev_salary
      FROM erp_salary_notch_value n
     WHERE n.salary_scale = NEW.salary_scale
       AND n.effective_from = NEW.effective_from
       AND n.notch_no = NEW.notch_no - 1
       AND (TG_OP = 'INSERT' OR n.id <> NEW.id)
     ORDER BY n.id DESC
     LIMIT 1;

    IF v_prev_salary IS NOT NULL AND NEW.monthly_salary <= v_prev_salary THEN
        RAISE EXCEPTION
            'Invalid progression for scale % effective %: notch % monthly_salary (%%) must be greater than notch % (%%)',
            NEW.salary_scale,
            NEW.effective_from,
            NEW.notch_no,
            NEW.notch_no - 1
        USING DETAIL = format('new=%.2f prev=%.2f', NEW.monthly_salary, v_prev_salary);
    END IF;

    SELECT n.monthly_salary
      INTO v_next_salary
      FROM erp_salary_notch_value n
     WHERE n.salary_scale = NEW.salary_scale
       AND n.effective_from = NEW.effective_from
       AND n.notch_no = NEW.notch_no + 1
       AND (TG_OP = 'INSERT' OR n.id <> NEW.id)
     ORDER BY n.id DESC
     LIMIT 1;

    IF v_next_salary IS NOT NULL AND NEW.monthly_salary >= v_next_salary THEN
        RAISE EXCEPTION
            'Invalid progression for scale % effective %: notch % monthly_salary (%%) must be less than notch % (%%)',
            NEW.salary_scale,
            NEW.effective_from,
            NEW.notch_no,
            NEW.notch_no + 1
        USING DETAIL = format('new=%.2f next=%.2f', NEW.monthly_salary, v_next_salary);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS validate_increasing_notch_values ON erp_salary_notch_value;

CREATE TRIGGER validate_increasing_notch_values
    BEFORE INSERT OR UPDATE OF salary_scale, notch_no, monthly_salary, effective_from
    ON erp_salary_notch_value
    FOR EACH ROW
    EXECUTE FUNCTION trg_validate_increasing_notch_values();

-- ---------------------------------------------------------------------
-- 3) Ensure scales exist and carry corrected progression metadata
-- ---------------------------------------------------------------------
INSERT INTO salary_scales_official (
    salary_scale, division, min_notch, max_notch,
    progression_direction, notch_increment,
    effective_from, is_active
)
VALUES
    ('LGSS05', 'DIVISION_I',  1, 7, 'INCREASING', 291.00, DATE '2025-01-01', TRUE),
    ('LGSS08', 'DIVISION_II', 1, 7, 'INCREASING', 239.00, DATE '2025-01-01', TRUE)
ON CONFLICT (salary_scale, effective_from)
DO UPDATE SET
    division = EXCLUDED.division,
    min_notch = EXCLUDED.min_notch,
    max_notch = EXCLUDED.max_notch,
    progression_direction = EXCLUDED.progression_direction,
    notch_increment = EXCLUDED.notch_increment,
    is_active = EXCLUDED.is_active;

-- ---------------------------------------------------------------------
-- 4) Seed corrected INCREASING notch values (from collective agreement)
--    Canonical storage table: erp_salary_notch_value
-- ---------------------------------------------------------------------
INSERT INTO erp_salary_notch_value (salary_scale, notch_no, annual_salary, monthly_salary, effective_from)
VALUES
    -- LGSS05: Notch 1 lowest, Notch 7 highest
    ('LGSS05', 1, 126665.00, 10555.00, DATE '2025-01-01'),
    ('LGSS05', 2, 130159.00, 10847.00, DATE '2025-01-01'),
    ('LGSS05', 3, 133653.00, 11138.00, DATE '2025-01-01'),
    ('LGSS05', 4, 137147.00, 11429.00, DATE '2025-01-01'),
    ('LGSS05', 5, 140641.00, 11720.00, DATE '2025-01-01'),
    ('LGSS05', 6, 144135.00, 12011.00, DATE '2025-01-01'),
    ('LGSS05', 7, 147629.00, 12302.00, DATE '2025-01-01'),

    -- LGSS08: Notch 1 lowest, Notch 7 highest
    ('LGSS08', 1, 106075.00,  8840.00, DATE '2025-01-01'),
    ('LGSS08', 2, 108942.00,  9079.00, DATE '2025-01-01'),
    ('LGSS08', 3, 111809.00,  9317.00, DATE '2025-01-01'),
    ('LGSS08', 4, 114676.00,  9556.00, DATE '2025-01-01'),
    ('LGSS08', 5, 117543.00,  9795.00, DATE '2025-01-01'),
    ('LGSS08', 6, 120410.00, 10034.00, DATE '2025-01-01'),
    ('LGSS08', 7, 123277.00, 10273.00, DATE '2025-01-01')
ON CONFLICT (salary_scale, notch_no, effective_from)
DO UPDATE SET
    annual_salary  = EXCLUDED.annual_salary,
    monthly_salary = EXCLUDED.monthly_salary,
    effective_to   = NULL;

-- ---------------------------------------------------------------------
-- 5) Compatibility view with requested naming and derived fields
--    (replaces unsupported generated-column logic using LAG/cross-table refs)
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW salary_notch_values AS
SELECT
    n.id AS notch_value_id,
    n.salary_scale,
    n.notch_no AS notch_number,
    n.annual_salary AS annual_amount,
    n.monthly_salary AS monthly_amount,

    -- Derived increment per scale and effective date
    (n.monthly_salary - LAG(n.monthly_salary) OVER (
        PARTITION BY n.salary_scale, n.effective_from
        ORDER BY n.notch_no
    ))::NUMERIC(10,2) AS notch_increment,

    CASE
        WHEN n.notch_no = 1 THEN 'ENTRY_LEVEL'
        WHEN n.notch_no = COALESCE(s.max_notch, 7) THEN 'MAXIMUM'
        WHEN n.notch_no <= 3 THEN 'JUNIOR'
        WHEN n.notch_no <= 5 THEN 'MID-LEVEL'
        ELSE 'SENIOR'
    END AS career_stage,

    n.effective_from,
    n.effective_to
FROM erp_salary_notch_value n
LEFT JOIN salary_scales_official s
       ON s.salary_scale = n.salary_scale
      AND s.effective_from = (
            SELECT MAX(ss.effective_from)
              FROM salary_scales_official ss
             WHERE ss.salary_scale = n.salary_scale
               AND ss.effective_from <= n.effective_from
      );

-- Helpful index for reads/validations
CREATE INDEX IF NOT EXISTS idx_erp_salary_notch_value_scale_notch_effective
    ON erp_salary_notch_value (salary_scale, notch_no, effective_from DESC);
