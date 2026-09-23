-- Add division (I–IV) and supervisor FK to erp_employee

ALTER TABLE erp_employee
    ADD COLUMN division    VARCHAR(5),
    ADD COLUMN supervisor_id BIGINT,
    ADD CONSTRAINT chk_employee_division CHECK (division IN ('I','II','III','IV')),
    ADD CONSTRAINT fk_employee_supervisor FOREIGN KEY (supervisor_id) REFERENCES erp_employee (id);

CREATE INDEX idx_employee_division    ON erp_employee (division);
CREATE INDEX idx_employee_supervisor  ON erp_employee (supervisor_id);
