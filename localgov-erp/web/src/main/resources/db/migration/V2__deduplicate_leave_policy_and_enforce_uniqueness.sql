CREATE TABLE IF NOT EXISTS leave_policy_dedup_backup (
    backup_id BIGSERIAL PRIMARY KEY,
    leave_type TEXT,
    division TEXT,
    accrual_rate REAL,
    max_days INTEGER,
    carry_forward INTEGER,
    eligibility TEXT,
    fixed_days INTEGER,
    max_accumulation INTEGER,
    max_duration INTEGER,
    advance_notice INTEGER,
    dedup_batch_tag TEXT NOT NULL,
    backed_up_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public'
          AND table_name = 'leave_policy'
    ) THEN
        WITH ranked AS (
            SELECT
                ctid,
                leave_type,
                division,
                accrual_rate,
                max_days,
                carry_forward,
                eligibility,
                fixed_days,
                max_accumulation,
                max_duration,
                advance_notice,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        COALESCE(NULLIF(LOWER(BTRIM(leave_type)), ''), '__no_type__'),
                        COALESCE(NULLIF(LOWER(BTRIM(division)), ''), '__no_division__')
                    ORDER BY ctid
                ) AS rn
            FROM leave_policy
        ), duplicates AS (
            SELECT *
            FROM ranked
            WHERE rn > 1
        )
        INSERT INTO leave_policy_dedup_backup (
            leave_type,
            division,
            accrual_rate,
            max_days,
            carry_forward,
            eligibility,
            fixed_days,
            max_accumulation,
            max_duration,
            advance_notice,
            dedup_batch_tag
        )
        SELECT
            leave_type,
            division,
            accrual_rate,
            max_days,
            carry_forward,
            eligibility,
            fixed_days,
            max_accumulation,
            max_duration,
            advance_notice,
            'V2_leave_policy_dedup'
        FROM duplicates;

        WITH ranked AS (
            SELECT
                ctid,
                ROW_NUMBER() OVER (
                    PARTITION BY
                        COALESCE(NULLIF(LOWER(BTRIM(leave_type)), ''), '__no_type__'),
                        COALESCE(NULLIF(LOWER(BTRIM(division)), ''), '__no_division__')
                    ORDER BY ctid
                ) AS rn
            FROM leave_policy
        )
        DELETE FROM leave_policy lp
        USING ranked r
        WHERE lp.ctid = r.ctid
          AND r.rn > 1;

        CREATE UNIQUE INDEX IF NOT EXISTS ux_leave_policy_leave_type_division
            ON leave_policy (
                COALESCE(NULLIF(LOWER(BTRIM(leave_type)), ''), '__no_type__'),
                COALESCE(NULLIF(LOWER(BTRIM(division)), ''), '__no_division__')
            );
    END IF;
END $$;