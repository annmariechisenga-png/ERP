-- Align commuted_overtime to requested design while keeping backward compatibility.

ALTER TABLE commuted_overtime
    ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- Backfill from existing model semantics.
UPDATE commuted_overtime
SET approved_at = COALESCE(approved_at, approval_date::timestamp, created_at)
WHERE approved_at IS NULL;

UPDATE commuted_overtime
SET is_active = CASE WHEN status = 'active' THEN TRUE ELSE FALSE END
WHERE is_active IS DISTINCT FROM (status = 'active');

CREATE INDEX IF NOT EXISTS idx_commuted_ot_active_period
    ON commuted_overtime (is_active, effective_from, effective_to);

-- Optional strictness from requested DDL is not enforced here to avoid breaking existing data:
-- approved_by remains nullable for legacy records.
