-- V1_0_3 — Immutable audit trail (hash-chained)
-- Referenced by V55–V66. Mirrors the live schema on the dev DB.
-- FK to legal_source intentionally omitted (legal_source has no creating
-- migration yet); add later if needed.

CREATE TABLE IF NOT EXISTS compliance_rule_change_log (
    change_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type      VARCHAR(50)  NOT NULL,
    entity_id        UUID         NOT NULL,
    change_type      VARCHAR(20)  NOT NULL,
    old_value        JSONB,
    new_value        JSONB,
    change_reason    TEXT         NOT NULL,
    legal_source_id  UUID,
    changed_by       UUID         NOT NULL,
    changed_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    ip_address       INET,
    previous_hash    VARCHAR(64),
    record_hash      VARCHAR(64)  NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_change_log_changed_at
    ON compliance_rule_change_log(changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_change_log_entity
    ON compliance_rule_change_log(entity_type, entity_id);
