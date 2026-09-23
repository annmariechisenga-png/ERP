-- Align overtime_sessions with full multi-level approval workflow design.
-- PostgreSQL adaptation of the provided MySQL table design.

ALTER TABLE overtime_sessions
    ADD COLUMN IF NOT EXISTS vehicle_id BIGINT,
    ADD COLUMN IF NOT EXISTS justification TEXT,
    ADD COLUMN IF NOT EXISTS supervisor_approved BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS supervisor_approved_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS supervisor_comment TEXT,
    ADD COLUMN IF NOT EXISTS hod_id BIGINT,
    ADD COLUMN IF NOT EXISTS hod_approved BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS hod_approved_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS hod_comment TEXT,
    ADD COLUMN IF NOT EXISTS responsible_officer_id BIGINT,
    ADD COLUMN IF NOT EXISTS ro_approved BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS ro_approved_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS ro_comment TEXT,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS created_by BIGINT;

-- Existing FK for supervisor_id already exists from V31.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_ot_session_hod'
    ) THEN
        ALTER TABLE overtime_sessions
            ADD CONSTRAINT fk_ot_session_hod
            FOREIGN KEY (hod_id) REFERENCES erp_employee (id);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_ot_session_responsible_officer'
    ) THEN
        ALTER TABLE overtime_sessions
            ADD CONSTRAINT fk_ot_session_responsible_officer
            FOREIGN KEY (responsible_officer_id) REFERENCES erp_employee (id);
    END IF;
END $$;

-- If a vehicle table exists later, add FK separately (table not present in current schema).

-- Extend source values to include GPS-derived overtime.
ALTER TABLE overtime_sessions DROP CONSTRAINT IF EXISTS chk_ot_session_source;
ALTER TABLE overtime_sessions
    ADD CONSTRAINT chk_ot_session_source
    CHECK (source IN ('auto_clock_out','gps','sms','manual'));

-- Extend status workflow. Keep approved_level3 for backward compatibility with existing payroll logic.
ALTER TABLE overtime_sessions DROP CONSTRAINT IF EXISTS chk_ot_session_status;
ALTER TABLE overtime_sessions
    ADD CONSTRAINT chk_ot_session_status
    CHECK (status IN (
        'pending_supervisor',
        'pending_hod',
        'pending_ro',
        'approved',
        'approved_level3',
        'rejected',
        'paid',
        'cancelled'
    ));

CREATE INDEX IF NOT EXISTS idx_status_paid ON overtime_sessions (status, paid);
CREATE INDEX IF NOT EXISTS idx_session_date ON overtime_sessions (session_date);
CREATE INDEX IF NOT EXISTS idx_employee ON overtime_sessions (employee_id);

CREATE INDEX IF NOT EXISTS idx_ot_session_hod ON overtime_sessions (hod_id);
CREATE INDEX IF NOT EXISTS idx_ot_session_responsible_officer ON overtime_sessions (responsible_officer_id);
CREATE INDEX IF NOT EXISTS idx_ot_session_supervisor_approved ON overtime_sessions (supervisor_approved);
CREATE INDEX IF NOT EXISTS idx_ot_session_hod_approved ON overtime_sessions (hod_approved);
CREATE INDEX IF NOT EXISTS idx_ot_session_ro_approved ON overtime_sessions (ro_approved);

-- Maintain updated_at automatically on updates.
CREATE OR REPLACE FUNCTION fn_set_overtime_sessions_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_overtime_sessions_updated_at ON overtime_sessions;
CREATE TRIGGER trg_set_overtime_sessions_updated_at
BEFORE UPDATE ON overtime_sessions
FOR EACH ROW
EXECUTE FUNCTION fn_set_overtime_sessions_updated_at();
