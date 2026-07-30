-- Extend employees with compliance/work-schedule fields adapted from requested employees table
-- PostgreSQL-safe migration for existing production table

ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS national_id VARCHAR(20),
    ADD COLUMN IF NOT EXISTS phone VARCHAR(15),
    ADD COLUMN IF NOT EXISTS division VARCHAR(4) DEFAULT 'II',
    ADD COLUMN IF NOT EXISTS role_category VARCHAR(30) DEFAULT 'office',
    ADD COLUMN IF NOT EXISTS salary_scale VARCHAR(10),
    ADD COLUMN IF NOT EXISTS monthly_basic_salary NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS normal_start_time TIME,
    ADD COLUMN IF NOT EXISTS normal_end_time TIME,
    ADD COLUMN IF NOT EXISTS normal_lunch_start TIME,
    ADD COLUMN IF NOT EXISTS normal_lunch_end TIME,
    ADD COLUMN IF NOT EXISTS health_break_type VARCHAR(20) DEFAULT 'two_10min',
    ADD COLUMN IF NOT EXISTS is_nursing_mother BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS nursing_breaks_entitled VARCHAR(20) DEFAULT 'two_30min',
    ADD COLUMN IF NOT EXISTS nursing_breaks_until DATE,
    ADD COLUMN IF NOT EXISTS mother_day_taken_current_month BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS mother_day_last_taken DATE,
    ADD COLUMN IF NOT EXISTS working_days_per_week INTEGER DEFAULT 5,
    ADD COLUMN IF NOT EXISTS rest_days_per_week INTEGER DEFAULT 2,
    ADD COLUMN IF NOT EXISTS preferred_break_times JSONB,
    ADD COLUMN IF NOT EXISTS team_id BIGINT,
    ADD COLUMN IF NOT EXISTS supervisor_id BIGINT,
    ADD COLUMN IF NOT EXISTS hod_id BIGINT,
    ADD COLUMN IF NOT EXISTS primary_location_id BIGINT,
    ADD COLUMN IF NOT EXISTS qr_code VARCHAR(100),
    ADD COLUMN IF NOT EXISTS qr_code_issued_date DATE,
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS employment_date DATE,
    ADD COLUMN IF NOT EXISTS gender VARCHAR(10) DEFAULT 'other',
    ADD COLUMN IF NOT EXISTS probation_end_date DATE,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

UPDATE employees
SET monthly_basic_salary = base_salary
WHERE monthly_basic_salary IS NULL;

ALTER TABLE employees
    ADD COLUMN IF NOT EXISTS hourly_rate NUMERIC(10,2)
    GENERATED ALWAYS AS (monthly_basic_salary / 176.0) STORED;

ALTER TABLE employees
    ALTER COLUMN monthly_basic_salary SET NOT NULL,
    ALTER COLUMN normal_start_time SET DEFAULT TIME '08:00:00',
    ALTER COLUMN normal_end_time SET DEFAULT TIME '17:00:00',
    ALTER COLUMN normal_lunch_start SET DEFAULT TIME '13:00:00',
    ALTER COLUMN normal_lunch_end SET DEFAULT TIME '14:00:00',
    ALTER COLUMN normal_start_time SET NOT NULL,
    ALTER COLUMN normal_end_time SET NOT NULL,
    ALTER COLUMN normal_lunch_start SET NOT NULL,
    ALTER COLUMN normal_lunch_end SET NOT NULL,
    ALTER COLUMN division SET NOT NULL,
    ALTER COLUMN role_category SET NOT NULL,
    ALTER COLUMN gender SET NOT NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_employees_division'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT chk_employees_division
            CHECK (division IN ('I', 'II', 'III', 'IV'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_employees_role_category'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT chk_employees_role_category
            CHECK (role_category IN ('office', 'operator', 'artisan', 'driver', 'cleaner', 'gravedigger', 'sweeper', 'garbage_collector'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_employees_health_break_type'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT chk_employees_health_break_type
            CHECK (health_break_type IN ('single_20min', 'two_10min'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_employees_nursing_breaks_entitled'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT chk_employees_nursing_breaks_entitled
            CHECK (nursing_breaks_entitled IN ('two_30min', 'one_60min'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_employees_gender'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT chk_employees_gender
            CHECK (gender IN ('male', 'female', 'other'));
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_employees_national_id'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT uq_employees_national_id UNIQUE (national_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'uq_employees_qr_code'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT uq_employees_qr_code UNIQUE (qr_code);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_employees_supervisor'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT fk_employees_supervisor
            FOREIGN KEY (supervisor_id) REFERENCES employees(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_employees_hod'
    ) THEN
        ALTER TABLE employees
            ADD CONSTRAINT fk_employees_hod
            FOREIGN KEY (hod_id) REFERENCES employees(id);
    END IF;
END $$;

CREATE OR REPLACE FUNCTION fn_set_employees_work_hours()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.division = 'I' THEN
        NEW.normal_start_time := TIME '08:00:00';
        NEW.normal_end_time := TIME '17:00:00';
        NEW.normal_lunch_start := TIME '13:00:00';
        NEW.normal_lunch_end := TIME '14:00:00';
    ELSIF NEW.role_category = 'driver' THEN
        NEW.normal_start_time := TIME '08:00:00';
        NEW.normal_end_time := TIME '17:00:00';
        NEW.normal_lunch_start := TIME '13:00:00';
        NEW.normal_lunch_end := TIME '14:00:00';
    ELSIF NEW.division = 'IV' THEN
        NEW.normal_start_time := TIME '07:00:00';
        NEW.normal_end_time := TIME '16:00:00';
        NEW.normal_lunch_start := TIME '12:00:00';
        NEW.normal_lunch_end := TIME '13:00:00';
    ELSE
        NEW.normal_start_time := TIME '08:00:00';
        NEW.normal_end_time := TIME '17:00:00';
        NEW.normal_lunch_start := TIME '13:00:00';
        NEW.normal_lunch_end := TIME '14:00:00';
    END IF;

    IF NEW.health_break_type IS NULL THEN
        NEW.health_break_type := 'two_10min';
    END IF;

    IF NEW.working_days_per_week IS NULL THEN
        NEW.working_days_per_week := 5;
    END IF;

    IF NEW.rest_days_per_week IS NULL THEN
        NEW.rest_days_per_week := 2;
    END IF;

    NEW.updated_at := CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_employees_work_hours ON employees;

CREATE TRIGGER trg_set_employees_work_hours
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION fn_set_employees_work_hours();
