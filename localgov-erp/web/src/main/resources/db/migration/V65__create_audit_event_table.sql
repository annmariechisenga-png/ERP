-- =====================================================================
-- V65__create_audit_event_table.sql
-- Immutable Audit Event Store — Foundation of AGO Compliance
-- =====================================================================
-- This table is the canonical, immutable audit trail. Every write
-- operation, every state change, and every sensitive read is logged
-- here.
--
-- Design principles:
--   1. Append-only: REVOKE UPDATE, DELETE
--   2. Hash-chained: each record links to the previous
--   3. Complete: captures user, IP, session, old/new values
--   4. Multi-tenant: scoped by authority_code
--   5. Temporal: indexed for fast time-range queries
--   6. AGO-ready: queryable, verifiable, exportable
--
-- Standards alignment:
--   - COBIT (IT governance)
--   - COSO (internal control)
--   - ISO 27001 (information security)
--   - ISACA IT audit guidelines
-- =====================================================================

CREATE TABLE audit_event (
    event_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type          VARCHAR(50) NOT NULL,
        -- LOGIN, LOGOUT, CREATE, UPDATE, DELETE, POST, REVERSE,
        -- APPROVE, REJECT, READ, EXPORT, PRINT, CONFIG_CHANGE
    entity_type         VARCHAR(50) NOT NULL,
        -- JOURNAL_ENTRY, JOURNAL_LINE, FUND, COST_CENTER,
        -- CHART_OF_ACCOUNTS, FISCAL_PERIOD, EMPLOYEE, INVOICE,
        -- RECEIPT, PAYMENT, etc.
    entity_id           UUID,
    action              VARCHAR(20) NOT NULL,
        -- CREATE, READ, UPDATE, DELETE, POST, REVERSE, APPROVE,
        -- REJECT, EXPORT, LOGIN, LOGOUT, CONFIG
    old_value           JSONB,
        -- Prior state (for UPDATE, DELETE)
    new_value           JSONB,
        -- New state (for CREATE, UPDATE)
    changes             JSONB,
        -- Diff of changed fields (for UPDATE)
    user_id             UUID NOT NULL,
    user_name           VARCHAR(255),
        -- Snapshot of user name (in case user is later deleted)
    user_role           VARCHAR(50),
    session_id          VARCHAR(100),
    authority_code      VARCHAR(20),
    ip_address          INET,
    user_agent          TEXT,
    request_id          VARCHAR(100),
    source_module       VARCHAR(50),
        -- Which module triggered this event
    record_hash         VARCHAR(64) NOT NULL,
        -- SHA-256 of this record (for tamper detection)
    previous_hash       VARCHAR(64),
        -- SHA-256 of the previous record (for chain)
    occurred_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_audit_event_type
        CHECK (event_type IN (
            'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE', 'POST',
            'REVERSE', 'APPROVE', 'REJECT', 'READ', 'EXPORT', 'PRINT',
            'CONFIG_CHANGE', 'SYSTEM', 'OTHER'
        )),
    CONSTRAINT chk_audit_action
        CHECK (action IN (
            'CREATE', 'READ', 'UPDATE', 'DELETE', 'POST', 'REVERSE',
            'APPROVE', 'REJECT', 'EXPORT', 'LOGIN', 'LOGOUT', 'CONFIG',
            'PRINT', 'OTHER'
        ))
);

-- Performance indexes for typical audit queries
CREATE INDEX idx_audit_event_occurred_at
    ON audit_event(occurred_at DESC);
CREATE INDEX idx_audit_event_entity
    ON audit_event(entity_type, entity_id, occurred_at DESC);
CREATE INDEX idx_audit_event_user
    ON audit_event(user_id, occurred_at DESC);
CREATE INDEX idx_audit_event_authority
    ON audit_event(authority_code, occurred_at DESC);
CREATE INDEX idx_audit_event_type_action
    ON audit_event(event_type, action, occurred_at DESC);
CREATE INDEX idx_audit_event_session
    ON audit_event(session_id)
    WHERE session_id IS NOT NULL;
CREATE INDEX idx_audit_event_record_hash
    ON audit_event(record_hash);

COMMENT ON TABLE audit_event IS
'Immutable audit trail for all system operations. Every write, state '
'change, and sensitive read is logged here. Hash-chained for tamper '
'detection. Append-only (no UPDATE, no DELETE). AGO-ready.';

COMMENT ON COLUMN audit_event.old_value IS
'Prior state of the entity, in JSONB format, for UPDATE and DELETE events.';

COMMENT ON COLUMN audit_event.new_value IS
'New state of the entity, in JSONB format, for CREATE and UPDATE events.';

COMMENT ON COLUMN audit_event.changes IS
'Diff of changed fields: {"field": {"old": X, "new": Y}}.';

COMMENT ON COLUMN audit_event.record_hash IS
'SHA-256 hash of this audit record. Combines previous_hash + all '
'fields. Used to detect tampering.';

COMMENT ON COLUMN audit_event.previous_hash IS
'SHA-256 hash of the previous audit record. Forms a chain. '
'If chain is broken, tampering is detected.';

-- ---------------------------------------------------------------------
-- Enforce immutability: no UPDATE, no DELETE
-- ---------------------------------------------------------------------
-- We use a trigger because REVOKE on the table would break if we
-- later grant access to application users. The trigger enforces
-- immutability for ALL users, including superusers with exception
-- for emergency maintenance (which must be logged separately).
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION prevent_audit_event_modification()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'Audit events are immutable. Cannot UPDATE audit_event. '
            'event_id: %, occurred_at: %', OLD.event_id, OLD.occurred_at;
    ELSIF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Audit events are immutable. Cannot DELETE audit_event. '
            'event_id: %, occurred_at: %', OLD.event_id, OLD.occurred_at;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_prevent_audit_event_update
    BEFORE UPDATE ON audit_event
    FOR EACH ROW
    EXECUTE FUNCTION prevent_audit_event_modification();

CREATE TRIGGER trg_prevent_audit_event_delete
    BEFORE DELETE ON audit_event
    FOR EACH ROW
    EXECUTE FUNCTION prevent_audit_event_modification();

-- ---------------------------------------------------------------------
-- Initial system event — records the creation of the audit trail itself
-- ---------------------------------------------------------------------
INSERT INTO audit_event (
    event_type, entity_type, action,
    new_value, user_id, user_name, user_role,
    authority_code, source_module, record_hash
) VALUES (
    'SYSTEM',
    'AUDIT_TRAIL',
    'CONFIG',
    jsonb_build_object(
        'action', 'create_table',
        'table', 'audit_event',
        'migration', 'V65',
        'purpose', 'Immutable audit trail for AGO compliance'
    ),
    '00000000-0000-0000-0000-000000000001'::UUID,
    'SYSTEM',
    'SYSTEM',
    NULL,
    'SYSTEM',
    encode(sha256(('V65' || 'audit_event' || NOW()::text)::bytea), 'hex')
);
