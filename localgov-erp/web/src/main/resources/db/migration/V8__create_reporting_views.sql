DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'eng_summary_by_council'
          AND n.nspname = current_schema()
          AND c.relkind IN ('r', 'p')
    ) THEN
        EXECUTE 'DROP TABLE eng_summary_by_council CASCADE';
    ELSIF EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'eng_summary_by_council'
          AND n.nspname = current_schema()
          AND c.relkind = 'v'
    ) THEN
        EXECUTE 'DROP VIEW eng_summary_by_council CASCADE';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'eng_staff_by_unit'
          AND n.nspname = current_schema()
          AND c.relkind IN ('r', 'p')
    ) THEN
        EXECUTE 'DROP TABLE eng_staff_by_unit CASCADE';
    ELSIF EXISTS (
        SELECT 1
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'eng_staff_by_unit'
          AND n.nspname = current_schema()
          AND c.relkind = 'v'
    ) THEN
        EXECUTE 'DROP VIEW eng_staff_by_unit CASCADE';
    END IF;
END $$;

CREATE VIEW eng_summary_by_council AS
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(base_salary) AS average_salary,
    MIN(base_salary) AS min_salary,
    MAX(base_salary) AS max_salary
FROM erp_employee
GROUP BY department;

CREATE VIEW eng_staff_by_unit AS
SELECT
    department,
    position_title,
    COUNT(*) AS staff_count
FROM erp_employee
GROUP BY department, position_title;
