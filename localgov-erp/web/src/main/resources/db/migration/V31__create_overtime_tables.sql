-- Overtime infrastructure: public holidays, commuted overtime, overtime sessions

-- ── Public holidays ───────────────────────────────────────────────────────────
CREATE TABLE public_holidays (
    id           BIGSERIAL   PRIMARY KEY,
    holiday_date DATE        NOT NULL,
    name         VARCHAR(120) NOT NULL,
    authority_code VARCHAR(10),           -- NULL = national; set for authority-specific
    created_at   TIMESTAMP   NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_public_holiday_date_authority UNIQUE (holiday_date, authority_code)
);

CREATE INDEX idx_public_holidays_date           ON public_holidays (holiday_date);
CREATE INDEX idx_public_holidays_authority_date ON public_holidays (authority_code, holiday_date);

-- ── Commuted overtime (pre-approved lump-sum OT arrangement) ─────────────────
CREATE TABLE commuted_overtime (
    id             BIGSERIAL   PRIMARY KEY,
    employee_id    BIGINT      NOT NULL,
    effective_from DATE        NOT NULL,
    effective_to   DATE,                  -- NULL = open-ended
    monthly_amount NUMERIC(18,2) NOT NULL,
    approved_by    BIGINT,
    approval_date  DATE,
    notes          TEXT,
    status         VARCHAR(20) NOT NULL DEFAULT 'active',
    created_at     TIMESTAMP   NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_commuted_ot_employee  FOREIGN KEY (employee_id) REFERENCES erp_employee (id),
    CONSTRAINT fk_commuted_ot_approver  FOREIGN KEY (approved_by) REFERENCES erp_employee (id),
    CONSTRAINT chk_commuted_ot_status   CHECK (status IN ('active','expired','cancelled'))
);

CREATE INDEX idx_commuted_ot_employee ON commuted_overtime (employee_id);
CREATE INDEX idx_commuted_ot_dates    ON commuted_overtime (employee_id, effective_from, effective_to);

-- ── Overtime sessions (auto-triggered or manually entered) ───────────────────
CREATE TABLE overtime_sessions (
    id               BIGSERIAL     PRIMARY KEY,
    employee_id      BIGINT        NOT NULL,
    session_date     DATE          NOT NULL,
    overtime_start   TIMESTAMP     NOT NULL,
    overtime_end     TIMESTAMP     NOT NULL,
    overtime_hours   NUMERIC(8,2)  NOT NULL,
    overtime_type    VARCHAR(20)   NOT NULL,   -- weekday|saturday|sunday|public_holiday|night_work
    rate_multiplier  NUMERIC(4,2)  NOT NULL,
    hourly_rate      NUMERIC(18,2) NOT NULL,
    amount_due       NUMERIC(18,2) NOT NULL,
    source           VARCHAR(20)   NOT NULL DEFAULT 'auto_clock_out',  -- auto_clock_out|manual
    status           VARCHAR(25)   NOT NULL DEFAULT 'pending_supervisor',
    supervisor_id    BIGINT,
    rejection_reason TEXT,
    approved_at      TIMESTAMP,
    created_at       TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_ot_session_employee   FOREIGN KEY (employee_id)   REFERENCES erp_employee (id),
    CONSTRAINT fk_ot_session_supervisor FOREIGN KEY (supervisor_id) REFERENCES erp_employee (id),
    CONSTRAINT chk_ot_session_type      CHECK (overtime_type   IN ('weekday','saturday','sunday','public_holiday','night_work')),
    CONSTRAINT chk_ot_session_source    CHECK (source          IN ('auto_clock_out','manual')),
    CONSTRAINT chk_ot_session_status    CHECK (status          IN ('pending_supervisor','approved','rejected','paid','cancelled')),
    CONSTRAINT chk_ot_session_hours     CHECK (overtime_hours  > 0),
    CONSTRAINT chk_ot_session_multiplier CHECK (rate_multiplier > 0)
);

CREATE INDEX idx_ot_session_employee ON overtime_sessions (employee_id);
CREATE INDEX idx_ot_session_date     ON overtime_sessions (session_date);
CREATE INDEX idx_ot_session_status   ON overtime_sessions (status);
CREATE INDEX idx_ot_session_supervisor ON overtime_sessions (supervisor_id);
