-- Payroll cut-off support for overtime payout selection

ALTER TABLE overtime_sessions
    ADD COLUMN IF NOT EXISTS paid BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE overtime_sessions DROP CONSTRAINT IF EXISTS chk_ot_session_status;
ALTER TABLE overtime_sessions
    ADD CONSTRAINT chk_ot_session_status
    CHECK (status IN (
        'pending_supervisor',
        'pending_hod',
        'approved',
        'approved_level3',
        'rejected',
        'paid',
        'cancelled'
    ));

CREATE INDEX IF NOT EXISTS idx_ot_session_paid ON overtime_sessions (paid);
CREATE INDEX IF NOT EXISTS idx_ot_session_status_paid_date ON overtime_sessions (status, paid, session_date);
