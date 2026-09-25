-- =====================================================================
-- V73__verify_audit_chain.sql
-- Tamper Detection — Verify Audit Trail Integrity
-- =====================================================================
-- This function is the formal proof of audit trail integrity for the
-- Office of the Auditor General (OAG).
--
-- It recomputes each audit record's hash from its stored fields and
-- compares it to the stored record_hash. It also verifies that each
-- record's previous_hash matches the prior record's record_hash.
--
-- If any mismatch is found, tampering has occurred.
--
-- The OAG can run this function at any time to verify:
--   1. All audit records are intact (no field was modified)
--   2. The chain is unbroken (no record was deleted or inserted)
--   3. The audit trail is authentic and trustworthy
--
-- Design:
--   - Recomputes record_hash using the SAME algorithm as log_audit_event
--   - Detects field tampering (record_hash mismatch)
--   - Detects chain tampering (previous_hash mismatch)
--   - Detects deletions (missing links in the chain)
--   - Returns a comprehensive verification report
-- =====================================================================

CREATE OR REPLACE FUNCTION verify_audit_chain(
    p_from TIMESTAMPTZ DEFAULT NULL,
    p_to TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE (
    total_records INTEGER,
    chained_records INTEGER,
    broken_links INTEGER,
    field_tampering INTEGER,
    first_broken_id UUID,
    first_broken_at TIMESTAMPTZ,
    first_tampered_id UUID,
    first_tampered_at TIMESTAMPTZ,
    verification_status VARCHAR(20),
    verification_timestamp TIMESTAMPTZ
)
LANGUAGE plpgsql AS $$
DECLARE
    v_total INTEGER := 0;
    v_chained INTEGER := 0;
    v_broken INTEGER := 0;
    v_tampered INTEGER := 0;
    v_first_broken_id UUID;
    v_first_broken_at TIMESTAMPTZ;
    v_first_tampered_id UUID;
    v_first_tampered_at TIMESTAMPTZ;
    v_status VARCHAR(20);
    v_rec RECORD;
    v_prior_hash VARCHAR(64) := NULL;
    v_recomputed VARCHAR(64);
BEGIN
    -- Iterate through all audit events in the requested range
    FOR v_rec IN
        SELECT
            event_id,
            event_type,
            entity_type,
            entity_id,
            action,
            old_value,
            new_value,
            changes,
            user_id,
            user_role,
            authority_code,
            ip_address,
            request_id,
            user_name,
            session_id,
            user_agent,
            source_module,
            record_hash,
            previous_hash,
            occurred_at
        FROM audit_event
        WHERE (p_from IS NULL OR occurred_at >= p_from)
          AND (p_to IS NULL OR occurred_at <= p_to)
        ORDER BY occurred_at ASC, event_id ASC
    LOOP
        v_total := v_total + 1;

        -- Recompute the record hash from stored fields (same algorithm as log_audit_event)
        v_recomputed := encode(
            sha256((
                COALESCE(v_rec.previous_hash, 'CHAIN_START') ||
                v_rec.event_id::text ||
                COALESCE(v_rec.event_type, '') ||
                COALESCE(v_rec.entity_type, '') ||
                COALESCE(v_rec.entity_id::text, '') ||
                COALESCE(v_rec.action, '') ||
                COALESCE(v_rec.old_value::text, '') ||
                COALESCE(v_rec.new_value::text, '') ||
                COALESCE(v_rec.changes::text, '') ||
                v_rec.user_id::text ||
                COALESCE(v_rec.user_role, '') ||
                COALESCE(v_rec.authority_code, '') ||
                COALESCE(v_rec.ip_address::text, '') ||
                COALESCE(v_rec.request_id, '') ||
                COALESCE(v_rec.user_name, '') ||
                COALESCE(v_rec.session_id, '') ||
                COALESCE(v_rec.user_agent, '') ||
                COALESCE(v_rec.source_module, '') ||
                v_rec.occurred_at::text
            )::bytea),
            'hex'
        );

        -- Verify the recomputed hash matches the stored hash (field tampering check)
        IF v_recomputed != v_rec.record_hash THEN
            v_tampered := v_tampered + 1;
            IF v_first_tampered_id IS NULL THEN
                v_first_tampered_id := v_rec.event_id;
                v_first_tampered_at := v_rec.occurred_at;
            END IF;
        END IF;

        -- Verify the chain: previous_hash should match prior record's record_hash
        IF v_prior_hash IS NULL THEN
            -- First record should have NULL or 'CHAIN_START' previous_hash
            IF v_rec.previous_hash IS NULL OR v_rec.previous_hash = 'CHAIN_START' THEN
                v_chained := v_chained + 1;
            ELSE
                v_broken := v_broken + 1;
                IF v_first_broken_id IS NULL THEN
                    v_first_broken_id := v_rec.event_id;
                    v_first_broken_at := v_rec.occurred_at;
                END IF;
            END IF;
        ELSE
            -- Subsequent records should chain to the prior record's hash
            IF v_rec.previous_hash = v_prior_hash THEN
                v_chained := v_chained + 1;
            ELSE
                v_broken := v_broken + 1;
                IF v_first_broken_id IS NULL THEN
                    v_first_broken_id := v_rec.event_id;
                    v_first_broken_at := v_rec.occurred_at;
                END IF;
            END IF;
        END IF;

        v_prior_hash := v_rec.record_hash;
    END LOOP;

    -- Determine overall status
    IF v_broken = 0 AND v_tampered = 0 THEN
        v_status := 'VERIFIED';
    ELSIF v_tampered > 0 THEN
        v_status := 'TAMPERED';
    ELSIF v_broken > 0 THEN
        v_status := 'CHAIN_BROKEN';
    ELSE
        v_status := 'UNKNOWN';
    END IF;

    -- Return the report
    RETURN QUERY SELECT
        v_total,
        v_chained,
        v_broken,
        v_tampered,
        v_first_broken_id,
        v_first_broken_at,
        v_first_tampered_id,
        v_first_tampered_at,
        v_status,
        NOW();
END;
$$;

COMMENT ON FUNCTION verify_audit_chain IS
'OAG-facing tamper detection function. Recomputes every audit record hash '
'from stored fields and verifies the hash chain. Returns VERIFIED if '
'no tampering or broken links are found; TAMPERED if any record field '
'has been modified; CHAIN_BROKEN if any link is missing. '
'The OAG can call this at any time to prove audit trail integrity.';

-- ---------------------------------------------------------------------
-- Simple verification function (no arguments, whole chain)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION verify_audit_chain_simple()
RETURNS TABLE (
    total_records INTEGER,
    chained_records INTEGER,
    broken_links INTEGER,
    field_tampering INTEGER,
    verification_status VARCHAR(20),
    verification_timestamp TIMESTAMPTZ
)
LANGUAGE plpgsql AS $$
DECLARE
    v_result RECORD;
BEGIN
    SELECT * INTO v_result FROM verify_audit_chain(NULL, NULL);

    RETURN QUERY SELECT
        v_result.total_records,
        v_result.chained_records,
        v_result.broken_links,
        v_result.field_tampering,
        v_result.verification_status,
        v_result.verification_timestamp;
END;
$$;

COMMENT ON FUNCTION verify_audit_chain_simple IS
'Simplified version of verify_audit_chain that verifies the entire '
'audit trail. Returns only the summary fields.';

-- ---------------------------------------------------------------------
-- Health check — returns a single-line status string
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_health_check()
RETURNS VARCHAR(100)
LANGUAGE plpgsql AS $$
DECLARE
    v_result RECORD;
BEGIN
    SELECT * INTO v_result FROM verify_audit_chain(NULL, NULL);

    IF v_result.verification_status = 'VERIFIED' THEN
        RETURN 'AUDIT TRAIL HEALTHY — ' || v_result.total_records || ' records, chain intact';
    ELSIF v_result.verification_status = 'TAMPERED' THEN
        RETURN 'AUDIT TRAIL TAMPERED — ' || v_result.field_tampering || ' records modified';
    ELSIF v_result.verification_status = 'CHAIN_BROKEN' THEN
        RETURN 'AUDIT CHAIN BROKEN — ' || v_result.broken_links || ' broken links';
    ELSE
        RETURN 'AUDIT STATUS UNKNOWN';
    END IF;
END;
$$;

COMMENT ON FUNCTION audit_health_check IS
'Returns a single-line health status for the audit trail. '
'Used for dashboards and monitoring.';

-- ---------------------------------------------------------------------
-- Audit trail summary — event counts by type
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_summary(
    p_from TIMESTAMPTZ DEFAULT NULL,
    p_to TIMESTAMPTZ DEFAULT NULL
)
RETURNS TABLE (
    entity_type VARCHAR,
    action VARCHAR,
    event_count BIGINT,
    distinct_users BIGINT,
    first_event TIMESTAMPTZ,
    last_event TIMESTAMPTZ
)
LANGUAGE sql STABLE AS $$
    SELECT
        entity_type,
        action,
        COUNT(*) AS event_count,
        COUNT(DISTINCT user_id) AS distinct_users,
        MIN(occurred_at) AS first_event,
        MAX(occurred_at) AS last_event
    FROM audit_event
    WHERE (p_from IS NULL OR occurred_at >= p_from)
      AND (p_to IS NULL OR occurred_at <= p_to)
    GROUP BY entity_type, action
    ORDER BY entity_type, action;
$$;

COMMENT ON FUNCTION audit_summary IS
'Summary of audit events grouped by entity type and action. '
'Used for OAG reports and management dashboards.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_verify_audit_chain',
        'migration', 'V73',
        'purpose', 'OAG tamper detection',
        'functions_created', ARRAY[
            'verify_audit_chain',
            'verify_audit_chain_simple',
            'audit_health_check',
            'audit_summary'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
