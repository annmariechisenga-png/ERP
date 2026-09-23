-- V17: Salary change audit table, auto-populate trigger, and suspicious-change detection
--
-- Schema corrections vs. design sketch:
--   officer_id UUID          → BIGINT      (FK → erp_employee.id, per V1/V14)
--   changed_by UUID          → VARCHAR(120) (application username string, same as created_by elsewhere)
--   officers.full_name       → erp_employee first_name || ' ' || last_name  (no full_name column)
--   local_authorities        → erp_authority_master.official_name  (join via employment_history.authority_id)
--
-- Auto-populate strategy:
--   An AFTER INSERT trigger on employment_history fires whenever a new placement
--   is committed.  It finds the immediately-preceding current placement for the same
--   officer, writes one audit row capturing old→new values and a computed risk_score,
--   then marks the old placement is_current = FALSE so only one row per officer is
--   ever is_current = TRUE.
--
--   Application-layer session metadata (ip_address, user_agent) cannot be set by the
--   trigger; those columns are NULLable so the UI can call a separate
--   PATCH /api/employment/audit/{id}/session after placement if needed.

-- -----------------------------------------------------------------------
-- 1. salary_change_audit table
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS salary_change_audit (
    audit_id           BIGSERIAL    PRIMARY KEY,   -- BIGSERIAL; UUID not used (consistent with project style)
    officer_id         BIGINT       NOT NULL,
    changed_by         VARCHAR(120) NOT NULL,       -- application username (not UUID)
    changed_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    old_scale          VARCHAR(30),
    old_notch          INTEGER,
    old_salary         NUMERIC(18,2),

    new_scale          VARCHAR(30)  NOT NULL,
    new_notch          INTEGER      NOT NULL,
    new_salary         NUMERIC(18,2) NOT NULL,

    change_reason      VARCHAR(50),                -- ANNUAL_INCREMENT | SKIP_INCREMENT | PROMOTION | DEMOTION | NEW_APPOINTMENT | CORRECTION
    approval_reference VARCHAR(100),

    -- Session metadata (set by application layer; NULLable here)
    ip_address         INET,
    user_agent         TEXT,

    -- Risk classification
    risk_score         INTEGER      NOT NULL DEFAULT 0 CHECK (risk_score BETWEEN 0 AND 100),
    flagged            BOOLEAN      NOT NULL DEFAULT FALSE,
    flag_reason        TEXT,

    CONSTRAINT fk_salary_audit_officer
        FOREIGN KEY (officer_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_salary_audit_officer_at
    ON salary_change_audit (officer_id, changed_at DESC);

CREATE INDEX IF NOT EXISTS idx_salary_audit_flagged
    ON salary_change_audit (flagged, changed_at DESC)
    WHERE flagged = TRUE;

-- -----------------------------------------------------------------------
-- 2. Trigger function: auto-populate salary_change_audit on new placement
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_audit_employment_placement()
RETURNS TRIGGER AS $$
DECLARE
    v_prev_scale    VARCHAR;
    v_prev_notch    INTEGER;
    v_prev_salary   NUMERIC(18,2);
    v_prev_id       BIGINT;
    v_reason        VARCHAR(50);
    v_risk          INTEGER := 0;
    v_flag          BOOLEAN := FALSE;
    v_flag_reason   TEXT;
BEGIN
    -- ------------------------------------------------------------------
    -- Find the previous current placement for this officer
    -- (effective_date < NEW.effective_date, ordered most-recent-first)
    -- ------------------------------------------------------------------
    SELECT id, salary_scale, notch_number, monthly_salary
      INTO v_prev_id, v_prev_scale, v_prev_notch, v_prev_salary
      FROM employment_history
     WHERE officer_id  = NEW.officer_id
       AND is_current  = TRUE
       AND id         <> NEW.id
     ORDER BY effective_date DESC
     LIMIT 1;

    -- ------------------------------------------------------------------
    -- Derive change_reason
    -- ------------------------------------------------------------------
    IF v_prev_scale IS NULL THEN
        v_reason := 'NEW_APPOINTMENT';
    ELSIF NEW.salary_scale <> v_prev_scale THEN
        -- Cross-scale: determine direction by numeric suffix
        DECLARE
            v_old_rank INTEGER;
            v_new_rank INTEGER;
        BEGIN
            v_old_rank := CAST(REGEXP_REPLACE(v_prev_scale, '[^0-9]', '', 'g') AS INTEGER);
            v_new_rank := CAST(REGEXP_REPLACE(NEW.salary_scale, '[^0-9]', '', 'g') AS INTEGER);
            v_reason := CASE WHEN v_new_rank >= v_old_rank THEN 'PROMOTION' ELSE 'DEMOTION' END;
        EXCEPTION WHEN OTHERS THEN
            v_reason := 'PROMOTION';   -- non-numeric suffix, default to promotion
        END;
    ELSIF NEW.notch_number > v_prev_notch + 1 THEN
        v_reason := 'SKIP_INCREMENT';
    ELSIF NEW.notch_number = v_prev_notch + 1 THEN
        v_reason := 'ANNUAL_INCREMENT';
    ELSIF NEW.notch_number = v_prev_notch THEN
        v_reason := 'CORRECTION';
    ELSIF NEW.notch_number < v_prev_notch THEN
        v_reason := 'DEMOTION';
    ELSE
        v_reason := 'CORRECTION';
    END IF;

    -- ------------------------------------------------------------------
    -- Risk scoring (additive, capped at 100)
    -- ------------------------------------------------------------------
    -- Demotion: high inherent risk
    IF v_reason = 'DEMOTION' THEN
        v_risk := v_risk + 50;
    END IF;

    -- Notch skip (remedial double-increment): medium risk
    IF v_reason = 'SKIP_INCREMENT' THEN
        v_risk := v_risk + 35;
    END IF;

    -- Cross-scale promotion: warrants review
    IF v_reason = 'PROMOTION' THEN
        v_risk := v_risk + 20;
    END IF;

    -- Large absolute salary increase (> ZMW 5 000 / month)
    IF v_prev_salary IS NOT NULL AND (NEW.monthly_salary - v_prev_salary) > 5000 THEN
        v_risk := v_risk + 25;
    END IF;

    -- Very large increase (> ZMW 10 000 / month) — additional penalty
    IF v_prev_salary IS NOT NULL AND (NEW.monthly_salary - v_prev_salary) > 10000 THEN
        v_risk := v_risk + 15;
    END IF;

    -- Cap at 100
    v_risk := LEAST(v_risk, 100);

    -- ------------------------------------------------------------------
    -- Flag and set flag_reason when risk_score >= 50
    -- ------------------------------------------------------------------
    IF v_risk >= 50 THEN
        v_flag := TRUE;
        v_flag_reason := format(
            'risk_score=%s reason=%s scale=%s→%s notch=%s→%s salary_delta=%.2f',
            v_risk, v_reason,
            COALESCE(v_prev_scale, 'N/A'), NEW.salary_scale,
            COALESCE(v_prev_notch::TEXT, 'N/A'), NEW.notch_number,
            COALESCE(NEW.monthly_salary - v_prev_salary, 0)
        );
    END IF;

    -- ------------------------------------------------------------------
    -- Write audit row
    -- ------------------------------------------------------------------
    INSERT INTO salary_change_audit (
        officer_id, changed_by, changed_at,
        old_scale, old_notch, old_salary,
        new_scale, new_notch, new_salary,
        change_reason, approval_reference,
        risk_score, flagged, flag_reason
    ) VALUES (
        NEW.officer_id, NEW.created_by, NEW.created_at,
        v_prev_scale, v_prev_notch, v_prev_salary,
        NEW.salary_scale, NEW.notch_number, NEW.monthly_salary,
        v_reason, NEW.approval_reference,
        v_risk, v_flag, v_flag_reason
    );

    -- ------------------------------------------------------------------
    -- Mark previous placement as no longer current
    -- ------------------------------------------------------------------
    IF v_prev_id IS NOT NULL THEN
        UPDATE employment_history
           SET is_current = FALSE,
               end_date   = NEW.effective_date - INTERVAL '1 day'
         WHERE id = v_prev_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS audit_employment_placement ON employment_history;

CREATE TRIGGER audit_employment_placement
    AFTER INSERT ON employment_history
    FOR EACH ROW
    EXECUTE FUNCTION trg_audit_employment_placement();

-- -----------------------------------------------------------------------
-- 3. detect_suspicious_salary_changes()
--
-- Corrected table references:
--   officers            → erp_employee  (first_name || ' ' || last_name)
--   la.authority_name   → am.official_name
--   join path           → employment_history.authority_id → erp_authority_master
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION detect_suspicious_salary_changes(
    p_days INTEGER DEFAULT 30
) RETURNS TABLE (
    officer_name       TEXT,
    authority_name     VARCHAR,
    changes_count      BIGINT,
    total_increase     NUMERIC,
    avg_risk_score     NUMERIC,
    flagged_count      BIGINT,
    risk_level         TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (e.first_name || ' ' || e.last_name)::TEXT          AS officer_name,
        am.official_name                                     AS authority_name,
        COUNT(*)                                             AS changes_count,
        COALESCE(SUM(sca.new_salary - COALESCE(sca.old_salary, sca.new_salary)), 0)
                                                             AS total_increase,
        ROUND(AVG(sca.risk_score), 1)                        AS avg_risk_score,
        COUNT(*) FILTER (WHERE sca.flagged = TRUE)           AS flagged_count,
        CASE
            WHEN COUNT(*) > 3                                                           THEN 'HIGH'
            WHEN COUNT(*) FILTER (WHERE sca.flagged = TRUE) > 0                        THEN 'HIGH'
            WHEN COALESCE(SUM(sca.new_salary - COALESCE(sca.old_salary, sca.new_salary)), 0) > 10000 THEN 'HIGH'
            WHEN COALESCE(SUM(sca.new_salary - COALESCE(sca.old_salary, sca.new_salary)), 0) > 5000  THEN 'MEDIUM'
            WHEN COUNT(*) > 1                                                           THEN 'MEDIUM'
            ELSE 'LOW'
        END::TEXT                                            AS risk_level
    FROM salary_change_audit sca
    JOIN erp_employee           e  ON sca.officer_id  = e.id
    -- authority comes from the most-recent employment_history row for the officer
    LEFT JOIN LATERAL (
        SELECT authority_id
          FROM employment_history eh
         WHERE eh.officer_id = sca.officer_id
         ORDER BY eh.effective_date DESC
         LIMIT 1
    ) latest_eh ON TRUE
    LEFT JOIN erp_authority_master am ON latest_eh.authority_id = am.authority_id
    WHERE sca.changed_at > CURRENT_TIMESTAMP - (p_days || ' days')::INTERVAL
    GROUP BY e.id, e.first_name, e.last_name, am.official_name
    HAVING COUNT(*) > 1
        OR COALESCE(SUM(sca.new_salary - COALESCE(sca.old_salary, sca.new_salary)), 0) > 5000
    ORDER BY
        CASE
            WHEN COUNT(*) > 3
              OR COUNT(*) FILTER (WHERE sca.flagged = TRUE) > 0
              OR COALESCE(SUM(sca.new_salary - COALESCE(sca.old_salary, sca.new_salary)), 0) > 10000
            THEN 1
            ELSE 2
        END,
        COALESCE(SUM(sca.new_salary - COALESCE(sca.old_salary, sca.new_salary)), 0) DESC;
END;
$$ LANGUAGE plpgsql;
