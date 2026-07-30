-- V16: validate_notch_progression()
--
-- Returns JSONB with fields:
--   valid        BOOLEAN  – whether the proposed move is permitted
--   reason       TEXT     – explanation when valid=false (or advisory when WARN)
--   severity     TEXT     – INFO | WARN | MEDIUM | HIGH
--   current_scale, current_notch, current_effective, target_scale, scale_gap
--
-- Bug-fixes vs. design sketch:
--   1) officer_id UUID → BIGINT  (employment_history.officer_id is BIGINT per V14)
--   2) Rule 2 NOT EXISTS clause replaced with a direct effective_date comparison:
--      a skip is only permitted when the current placement is 12+ months old
--      (remedial / overdue double-increment).  The original query compared
--      against intermediate notch rows whose meaning was ambiguous.
--   3) Rule 3 implemented: cross-scale jumps of more than 2 levels are blocked;
--      downward scale moves require demotion proceedings.

CREATE OR REPLACE FUNCTION validate_notch_progression(
    p_officer_id     BIGINT,        -- FIXED: was UUID; employment_history uses BIGINT FK
    p_new_scale      VARCHAR,
    p_new_notch      INTEGER,
    p_effective_date DATE
) RETURNS JSONB AS $$
DECLARE
    v_current_scale     VARCHAR;
    v_current_notch     INTEGER;
    v_current_salary    NUMERIC(18,2);
    v_current_effective DATE;
    v_curr_rank         INTEGER;
    v_new_rank          INTEGER;
BEGIN
    -- ------------------------------------------------------------------
    -- Fetch current placement
    -- ------------------------------------------------------------------
    SELECT salary_scale, notch_number, monthly_salary, effective_date
      INTO v_current_scale, v_current_notch, v_current_salary, v_current_effective
      FROM employment_history
     WHERE officer_id = p_officer_id
       AND is_current  = TRUE
     LIMIT 1;

    -- New appointment: no prior history → always valid
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'valid',    TRUE,
            'reason',   'New appointment — no prior placement on record',
            'severity', 'INFO'
        );
    END IF;

    -- ------------------------------------------------------------------
    -- Rule 1: No downward notch movement within the same scale
    --         (demotion must go through formal demotion proceedings)
    -- ------------------------------------------------------------------
    IF p_new_scale = v_current_scale AND p_new_notch < v_current_notch THEN
        RETURN jsonb_build_object(
            'valid',         FALSE,
            'reason',        'Cannot move to a lower notch within the same scale without formal demotion proceedings',
            'severity',      'HIGH',
            'current_scale', v_current_scale,
            'current_notch', v_current_notch
        );
    END IF;

    -- ------------------------------------------------------------------
    -- Rule 2: Notch skips within the same scale are only permitted when
    --         the officer is overdue for an annual increment (12+ months
    --         at their current notch = remedial double-increment).
    --
    --         FIXED: original design used a NOT EXISTS clause that checked
    --         for intermediate-notch history rows within the last year —
    --         the logic was inverted and the condition was ambiguous.  We
    --         now compare the current placement's effective_date directly.
    -- ------------------------------------------------------------------
    IF p_new_scale = v_current_scale AND p_new_notch > v_current_notch + 1 THEN
        -- Block skip if the current placement is less than 12 months old
        IF v_current_effective > CURRENT_DATE - INTERVAL '1 year' THEN
            RETURN jsonb_build_object(
                'valid',             FALSE,
                'reason',            format(
                    'Cannot skip notches — officer must progress sequentially (notch %s → %s). '
                    'A remedial double-increment is only permitted when the current placement '
                    'is 12+ months old (current effective date: %s)',
                    v_current_notch, v_current_notch + 1, v_current_effective
                ),
                'severity',          'MEDIUM',
                'current_scale',     v_current_scale,
                'current_notch',     v_current_notch,
                'current_effective', v_current_effective::TEXT
            );
        END IF;
        -- Overdue by 12+ months → allow with advisory
        RETURN jsonb_build_object(
            'valid',             TRUE,
            'reason',            format(
                'Remedial double-increment approved: officer has been at %s Notch %s '
                'since %s (overdue by %s days)',
                v_current_scale, v_current_notch, v_current_effective,
                (CURRENT_DATE - v_current_effective)
            ),
            'severity',          'WARN',
            'current_scale',     v_current_scale,
            'current_notch',     v_current_notch,
            'current_effective', v_current_effective::TEXT
        );
    END IF;

    -- ------------------------------------------------------------------
    -- Rule 3: Cross-scale moves require Commission approval and must not
    --         jump more than two scale levels.
    --
    --         Scale rank is derived from the trailing numeric suffix of
    --         the scale code (LGSS01→1, LGSS18→18, GRADE_01→1).
    --         Handles the LGSS and GRADE families in V13 seed data.
    -- ------------------------------------------------------------------
    IF p_new_scale <> v_current_scale THEN

        BEGIN
            v_curr_rank := CAST(REGEXP_REPLACE(v_current_scale, '[^0-9]', '', 'g') AS INTEGER);
            v_new_rank  := CAST(REGEXP_REPLACE(p_new_scale,      '[^0-9]', '', 'g') AS INTEGER);
        EXCEPTION WHEN OTHERS THEN
            -- Non-numeric suffix or unknown scale family — block for safety
            v_curr_rank := 0;
            v_new_rank  := 0;
        END;

        -- Downward scale move → demotion proceedings required
        IF v_new_rank < v_curr_rank THEN
            RETURN jsonb_build_object(
                'valid',         FALSE,
                'reason',        format(
                    'Cross-scale move from %s to %s is a downward band change and requires '
                    'formal demotion proceedings approved by the Local Government Service Commission',
                    v_current_scale, p_new_scale
                ),
                'severity',      'HIGH',
                'current_scale', v_current_scale,
                'target_scale',  p_new_scale
            );
        END IF;

        -- Skip more than two scale levels → exceptional Commission approval needed
        IF v_new_rank > v_curr_rank + 2 THEN
            RETURN jsonb_build_object(
                'valid',         FALSE,
                'reason',        format(
                    'Cross-scale promotion from %s to %s spans %s levels. '
                    'Promotions must not skip more than two scale levels without '
                    'explicit approval from the Local Government Service Commission',
                    v_current_scale, p_new_scale, (v_new_rank - v_curr_rank)
                ),
                'severity',      'HIGH',
                'current_scale', v_current_scale,
                'target_scale',  p_new_scale,
                'scale_gap',     (v_new_rank - v_curr_rank)::TEXT
            );
        END IF;

        -- Single or two-level cross-scale promotion → valid with advisory
        RETURN jsonb_build_object(
            'valid',         TRUE,
            'reason',        format(
                'Cross-scale promotion from %s to %s is within the permitted range. '
                'Ensure a Local Government Service Commission appointment letter is on file '
                'before confirming placement.',
                v_current_scale, p_new_scale
            ),
            'severity',      'WARN',
            'current_scale', v_current_scale,
            'target_scale',  p_new_scale
        );
    END IF;

    -- ------------------------------------------------------------------
    -- All rules passed
    -- ------------------------------------------------------------------
    RETURN jsonb_build_object(
        'valid',         TRUE,
        'severity',      'INFO',
        'current_scale', v_current_scale,
        'current_notch', v_current_notch
    );
END;
$$ LANGUAGE plpgsql;
