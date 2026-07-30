CREATE TABLE IF NOT EXISTS employee_work_locations (
    id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    assignment_type VARCHAR(20) NOT NULL DEFAULT 'permanent',
    effective_from DATE NOT NULL,
    effective_to DATE,
    created_by BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_employee_work_locations_employee
        FOREIGN KEY (employee_id) REFERENCES erp_employee(id),
    CONSTRAINT fk_employee_work_locations_location
        FOREIGN KEY (location_id) REFERENCES work_locations(id),
    CONSTRAINT fk_employee_work_locations_created_by
        FOREIGN KEY (created_by) REFERENCES erp_employee(id),

    CONSTRAINT chk_employee_work_locations_assignment_type
        CHECK (assignment_type IN ('permanent', 'temporary', 'rotational')),
    CONSTRAINT chk_employee_work_locations_effective_range
        CHECK (effective_to IS NULL OR effective_to >= effective_from),

    CONSTRAINT uk_employee_work_location_active_assignment
        UNIQUE (employee_id, location_id, effective_from)
);

CREATE INDEX IF NOT EXISTS idx_employee_work_locations_employee
    ON employee_work_locations (employee_id);

CREATE INDEX IF NOT EXISTS idx_employee_work_locations_location
    ON employee_work_locations (location_id);
