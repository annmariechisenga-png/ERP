-- V15: Prevent manual salary overrides on employment_history
--      and create fraud_alert_log for audit trail.
--
-- Corrected column references vs. design sketch:
--   salary_notch_values  →  erp_salary_notch_value  (V9 table name)
--   snv.notch_number     →  snv.notch_no            (V9 column name)
--   snv.monthly_amount   →  snv.monthly_salary       (V9 column name)

-- ----------------------------------------------------------------
-- 1. Fraud / override alert log
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fraud_alert_log (
    id              BIGSERIAL PRIMARY KEY,
    officer_id      BIGINT          NOT NULL,
    alert_type      VARCHAR(80)     NOT NULL,
    old_value       NUMERIC(18,2),
    new_value       NUMERIC(18,2),
    attempted_by    VARCHAR(120)    NOT NULL,
    attempted_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detail          VARCHAR(500),
    CONSTRAINT fk_fraud_alert_officer
        FOREIGN KEY (officer_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_fraud_alert_officer_type
    ON fraud_alert_log (officer_id, alert_type, attempted_at DESC);

-- ----------------------------------------------------------------
-- 2. Function: enforce official notch salary, log override attempts
-- ----------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_prevent_salary_override()
RETURNS TRIGGER AS $$
DECLARE
    v_official_salary NUMERIC(18,2);
    v_attempted       NUMERIC(18,2);
BEGIN
    -- Capture what the caller originally attempted to store
    v_attempted := NEW.monthly_salary;

    -- Look up the correct salary from the official notch table
    -- (erp_salary_notch_value, V9 schema: notch_no, monthly_salary)
    SELECT snv.monthly_salary
      INTO v_official_salary
      FROM erp_salary_notch_value snv
     WHERE snv.salary_scale  = NEW.salary_scale
       AND snv.notch_no      = NEW.notch_number
       AND snv.effective_from <= NEW.effective_date
     ORDER BY snv.effective_from DESC
     LIMIT 1;

    IF v_official_salary IS NULL THEN
        RAISE EXCEPTION
            'No official salary found for scale=% notch=% effective_date=%',
            NEW.salary_scale, NEW.notch_number, NEW.effective_date;
    END IF;

    -- Always enforce the official value (silently corrects or blocks overrides)
    NEW.monthly_salary := v_official_salary;

    -- Log if the caller supplied a value that differs from the official one
    IF v_attempted IS DISTINCT FROM v_official_salary THEN
        INSERT INTO fraud_alert_log (
            officer_id,
            alert_type,
            old_value,
            new_value,
            attempted_by,
            attempted_at,
            detail
        ) VALUES (
            NEW.officer_id,
            'SALARY_OVERRIDE_ATTEMPT',
            v_attempted,
            v_official_salary,
            current_user,
            CURRENT_TIMESTAMP,
            format(
                'scale=%s notch=%s effective_date=%s',
                NEW.salary_scale,
                NEW.notch_number,
                NEW.effective_date
            )
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------------------------------
-- 3. Trigger: fire before every INSERT or UPDATE on employment_history
-- ----------------------------------------------------------------
DROP TRIGGER IF EXISTS enforce_official_salary ON employment_history;

CREATE TRIGGER enforce_official_salary
    BEFORE INSERT OR UPDATE ON employment_history
    FOR EACH ROW
    EXECUTE FUNCTION trg_prevent_salary_override();
