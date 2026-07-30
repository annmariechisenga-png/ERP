-- Create work locations table adapted for PostgreSQL/Flyway
-- department_id is kept as a nullable scalar for now because no departments table exists yet

CREATE TABLE IF NOT EXISTS work_locations (
    id BIGSERIAL PRIMARY KEY,
    location_code VARCHAR(20) NOT NULL UNIQUE,
    location_name VARCHAR(100) NOT NULL,
    location_type VARCHAR(30) NOT NULL,
    latitude NUMERIC(10,8) NOT NULL,
    longitude NUMERIC(11,8) NOT NULL,
    geofence_radius_meters INTEGER DEFAULT 100,
    address TEXT,
    opens_at TIME,
    closes_at TIME,
    applicable_divisions JSONB,
    applicable_role_categories JSONB,
    department_id BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    is_primary BOOLEAN DEFAULT FALSE,
    created_by BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_work_locations_type'
    ) THEN
        ALTER TABLE work_locations
            ADD CONSTRAINT chk_work_locations_type
            CHECK (
                location_type IN (
                    'headquarters',
                    'satellite_office',
                    'depot',
                    'cemetery',
                    'refuse_bay',
                    'workshop',
                    'market',
                    'street_zone',
                    'other'
                )
            );
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_work_locations_created_by'
    ) THEN
        ALTER TABLE work_locations
            ADD CONSTRAINT fk_work_locations_created_by
            FOREIGN KEY (created_by) REFERENCES erp_employee(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_work_locations_updated_by'
    ) THEN
        ALTER TABLE work_locations
            ADD CONSTRAINT fk_work_locations_updated_by
            FOREIGN KEY (updated_by) REFERENCES erp_employee(id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_erp_employee_primary_location'
    ) THEN
        ALTER TABLE erp_employee
            ADD CONSTRAINT fk_erp_employee_primary_location
            FOREIGN KEY (primary_location_id) REFERENCES work_locations(id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_work_locations_type
    ON work_locations(location_type);

CREATE INDEX IF NOT EXISTS idx_work_locations_active
    ON work_locations(is_active);

CREATE INDEX IF NOT EXISTS idx_work_locations_code_active
    ON work_locations(location_code, is_active);
