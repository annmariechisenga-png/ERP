ALTER TABLE work_locations
    ADD COLUMN IF NOT EXISTS department_name VARCHAR(120);
