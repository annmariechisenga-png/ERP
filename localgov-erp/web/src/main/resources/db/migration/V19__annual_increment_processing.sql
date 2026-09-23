-- V19: Annual increment processing (Notch 1 entry -> Notch 7 maximum)
--
-- Corrected to current ERP schema:
--   officer_id         BIGINT (not UUID)
--   authority_id       VARCHAR(40) (not UUID)
--   officers table     -> erp_employee
--   salary_notch_values -> erp_salary_notch_value (canonical table)
--   employment_history PK column is id (not employment_id)
--
-- Notes:
--   1) This migration adds increment_log and functions for single + batch processing.
--   2) Positive appraisal checks are optional and dynamic; if performance_appraisals table
--      is absent, batch processing reports NO_INCREMENT with explanatory message.
--   3) Existing V15 trigger still enforces official salary amount on employment insert/update.

-- ---------------------------------------------------------------------
-- 1) TABLE: increment_log
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS increment_log (
    log_id           BIGSERIAL PRIMARY KEY,
    officer_id       BIGINT         NOT NULL,
    previous_notch   INTEGER        NOT NULL,
    new_notch        INTEGER        NOT NULL,
    previous_salary  NUMERIC(18,2)  NOT NULL,
    new_salary       NUMERIC(18,2)  NOT NULL,
    increase_amount  NUMERIC(18,2)  NOT NULL,
    appraisal_id     UUID,
    effective_date   DATE           NOT NULL,
    processed_by     VARCHAR(120),
    processed_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    is_verified      BOOLEAN        NOT NULL DEFAULT FALSE,
    verified_by      VARCHAR(120),
    verified_at      TIMESTAMP,

    CONSTRAINT fk_increment_log_officer
        FOREIGN KEY (officer_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_increment_log_notch_up
        CHECK (new_notch = previous_notch + 1),

    CONSTRAINT chk_increment_log_positive_increase
        CHECK (increase_amount >= 0)
);

CREATE INDEX IF NOT EXISTS idx_increment_log_officer_effective
    ON increment_log (officer_id, effective_date DESC);

CREATE INDEX IF NOT EXISTS idx_increment_log_processed_at
    ON increment_log (processed_at DESC);

-- ---------------------------------------------------------------------
-- 2) FUNCTION: process_annual_increment
--    Moves officer up exactly one notch after positive appraisal.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION process_annual_increment(
    p_officer_id      BIGINT,
    p_appraisal_id    UUID,
    p_effective_date  DATE DEFAULT CURRENT_DATE
) RETURNS JSONB AS $$
DECLARE
    v_current          employment_history%ROWTYPE;
    v_new_notch        INTEGER;
    v_prev_salary      NUMERIC(18,2);
    v_new_salary       NUMERIC(18,2);
    v_inserted_id      BIGINT;
BEGIN
    -- Current placement
    SELECT *
      INTO v_current
      FROM employment_history
     WHERE officer_id = p_officer_id
       AND is_current = TRUE
     ORDER BY effective_date DESC, id DESC
     LIMIT 1;

    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'error', 'Officer not currently employed'
        );
    END IF;

    -- Prevent duplicate increment on same effective date
    IF EXISTS (
        SELECT 1
          FROM employment_history eh
         WHERE eh.officer_id = p_officer_id
           AND eh.effective_date = p_effective_date
    ) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'error', format('Placement already exists for effective_date %s', p_effective_date)
        );
    END IF;

    -- Max notch check (from current scale definition)
    IF v_current.notch_number >= 7 THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'error', 'Officer already at maximum notch',
            'current_notch', v_current.notch_number
        );
    END IF;

    v_new_notch := v_current.notch_number + 1;
    v_prev_salary := v_current.monthly_salary;

    -- Official salary for next notch at effective date
    SELECT snv.monthly_salary
      INTO v_new_salary
      FROM erp_salary_notch_value snv
     WHERE snv.salary_scale = v_current.salary_scale
       AND snv.notch_no = v_new_notch
       AND snv.effective_from <= p_effective_date
     ORDER BY snv.effective_from DESC
     LIMIT 1;

    IF v_new_salary IS NULL THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'error', format(
                'No official notch salary found for scale=%s notch=%s effective_date=%s',
                v_current.salary_scale, v_new_notch, p_effective_date
            )
        );
    END IF;

    -- Insert new placement; V15 trigger enforces official salary and V17 trigger handles
    -- current-record rollover + salary change audit.
    INSERT INTO employment_history (
        officer_id,
        authority_id,
        salary_scale,
        notch_number,
        monthly_salary,
        approved_by,
        approval_date,
        approval_reference,
        appointment_letter_url,
        effective_date,
        is_current,
        created_by,
        created_at
    ) VALUES (
        v_current.officer_id,
        v_current.authority_id,
        v_current.salary_scale,
        v_new_notch,
        v_new_salary,
        v_current.approved_by,
        COALESCE(v_current.approval_date, p_effective_date),
        COALESCE(v_current.approval_reference, 'ANNUAL_INCREMENT') || '_' || COALESCE(p_appraisal_id::TEXT, 'NO_APPRAISAL_ID'),
        v_current.appointment_letter_url,
        p_effective_date,
        TRUE,
        COALESCE(v_current.created_by, current_user),
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO v_inserted_id;

    -- Increment log
    INSERT INTO increment_log (
        officer_id,
        previous_notch,
        new_notch,
        previous_salary,
        new_salary,
        increase_amount,
        appraisal_id,
        effective_date,
        processed_by,
        processed_at
    ) VALUES (
        p_officer_id,
        v_current.notch_number,
        v_new_notch,
        v_prev_salary,
        v_new_salary,
        (v_new_salary - v_prev_salary),
        p_appraisal_id,
        p_effective_date,
        current_user,
        CURRENT_TIMESTAMP
    );

    RETURN jsonb_build_object(
        'success', TRUE,
        'officer_id', p_officer_id,
        'previous_notch', v_current.notch_number,
        'new_notch', v_new_notch,
        'increase_amount', (v_new_salary - v_prev_salary),
        'new_salary', v_new_salary,
        'effective_date', p_effective_date,
        'employment_id', v_inserted_id
    );
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------
-- 3) FUNCTION: process_batch_increments
--    End-of-year batch run for officers below max notch.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION process_batch_increments(
    p_authority_id VARCHAR(40) DEFAULT NULL,
    p_year INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) RETURNS TABLE (
    officer_name TEXT,
    current_notch INTEGER,
    new_notch INTEGER,
    status VARCHAR,
    message TEXT
) AS $$
DECLARE
    v_officer RECORD;
    v_has_appraisal BOOLEAN;
    v_result JSONB;
BEGIN
    FOR v_officer IN
        SELECT
            e.id AS officer_id,
            (e.first_name || ' ' || e.last_name) AS full_name,
            eh.salary_scale,
            eh.notch_number,
            eh.authority_id
        FROM erp_employee e
        JOIN employment_history eh
          ON e.id = eh.officer_id
         AND eh.is_current = TRUE
        WHERE (p_authority_id IS NULL OR eh.authority_id = p_authority_id)
          AND eh.notch_number < 7
        ORDER BY full_name
    LOOP
        officer_name := v_officer.full_name;
        current_notch := v_officer.notch_number;
        new_notch := v_officer.notch_number;

        -- Dynamic appraisal check to avoid compile/runtime hard dependency
        -- when performance_appraisals table is not present.
        IF to_regclass('public.performance_appraisals') IS NOT NULL THEN
            EXECUTE
                $dyn$
                SELECT EXISTS (
                    SELECT 1
                    FROM performance_appraisals pa
                    WHERE pa.officer_id = $1
                      AND pa.appraisal_year = $2
                      AND UPPER(pa.rating) = 'POSITIVE'
                )
                $dyn$
                INTO v_has_appraisal
                USING v_officer.officer_id, p_year;
        ELSE
            v_has_appraisal := FALSE;
        END IF;

        IF v_has_appraisal THEN
            v_result := process_annual_increment(
                v_officer.officer_id,
                NULL,
                make_date(p_year, 12, 31)
            );

            IF COALESCE((v_result->>'success')::BOOLEAN, FALSE) THEN
                new_notch := COALESCE((v_result->>'new_notch')::INTEGER, v_officer.notch_number + 1);
                status := 'INCREMENTED';
                message := 'Moved to notch ' || new_notch;
            ELSE
                status := 'FAILED';
                message := COALESCE(v_result->>'error', 'Increment failed');
            END IF;
        ELSE
            status := 'NO_INCREMENT';
            IF to_regclass('public.performance_appraisals') IS NULL THEN
                message := 'performance_appraisals table not found; appraisal check skipped';
            ELSE
                message := 'No positive appraisal for year ' || p_year;
            END IF;
        END IF;

        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
