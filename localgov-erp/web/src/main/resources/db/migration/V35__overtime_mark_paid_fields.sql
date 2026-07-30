-- Fields required to finalize overtime after payroll processing

ALTER TABLE overtime_sessions
    ADD COLUMN IF NOT EXISTS paid_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS payroll_reference VARCHAR(80),
    ADD COLUMN IF NOT EXISTS payroll_processed_in DATE;

CREATE INDEX IF NOT EXISTS idx_ot_session_payroll_reference ON overtime_sessions (payroll_reference);
CREATE INDEX IF NOT EXISTS idx_ot_session_payroll_processed_in ON overtime_sessions (payroll_processed_in);
