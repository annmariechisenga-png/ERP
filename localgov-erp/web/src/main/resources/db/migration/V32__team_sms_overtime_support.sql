-- Team registry and SMS-trigger overtime support for Division IV workflows

CREATE TABLE IF NOT EXISTS overtime_team (
    id          BIGSERIAL PRIMARY KEY,
    team_code   VARCHAR(30)  NOT NULL UNIQUE,
    team_name   VARCHAR(120) NOT NULL,
    hod_id      BIGINT,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_overtime_team_hod FOREIGN KEY (hod_id) REFERENCES erp_employee (id)
);

CREATE INDEX IF NOT EXISTS idx_overtime_team_code   ON overtime_team (team_code);
CREATE INDEX IF NOT EXISTS idx_overtime_team_active ON overtime_team (is_active);

ALTER TABLE overtime_sessions
    ADD COLUMN IF NOT EXISTS team_id BIGINT,
    ADD COLUMN IF NOT EXISTS work_description TEXT;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_ot_session_team'
    ) THEN
        ALTER TABLE overtime_sessions
            ADD CONSTRAINT fk_ot_session_team
            FOREIGN KEY (team_id) REFERENCES overtime_team (id);
    END IF;
END $$;

-- Extend enum-like checks to include SMS team-trigger flow.
ALTER TABLE overtime_sessions DROP CONSTRAINT IF EXISTS chk_ot_session_source;
ALTER TABLE overtime_sessions
    ADD CONSTRAINT chk_ot_session_source
    CHECK (source IN ('auto_clock_out','manual','sms'));

ALTER TABLE overtime_sessions DROP CONSTRAINT IF EXISTS chk_ot_session_status;
ALTER TABLE overtime_sessions
    ADD CONSTRAINT chk_ot_session_status
    CHECK (status IN ('pending_supervisor','pending_hod','approved','rejected','paid','cancelled'));

CREATE INDEX IF NOT EXISTS idx_ot_session_team ON overtime_sessions (team_id);

-- Optional seed for the example SMS: OT SWEEP3 2 Market cleanup
INSERT INTO overtime_team (team_code, team_name)
SELECT 'SWEEP3', 'Sweep Team 3'
WHERE NOT EXISTS (SELECT 1 FROM overtime_team WHERE team_code = 'SWEEP3');
