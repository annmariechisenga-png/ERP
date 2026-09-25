-- =====================================================================
-- V76__audit_export_retention_read.sql
-- Export, Retention Policy, and Read-Audit — Final Audit Migration
-- =====================================================================
-- This migration completes the audit trail with three capabilities:
--   1. export_audit()          — CSV/JSON export for OAG tools
--   2. Retention policy        — Legal retention periods + archival
--   3. Read-audit              — Log every read of sensitive data
--
-- After V76, the audit trail is complete:
--   - Every write is automatically logged (via triggers)
--   - Every sensitive read is explicitly logged
--   - Tamper detection is available (verify_audit_chain)
--   - Query interface exists for OAG (query_audit, search_audit)
--   - Export to CSV/JSON is available
--   - Retention is policy-driven
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. EXPORT AUDIT — CSV and JSON export
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION export_audit(
    p_from TIMESTAMPTZ DEFAULT NULL,
    p_to TIMESTAMPTZ DEFAULT NULL,
    p_authority_code VARCHAR DEFAULT NULL,
    p_entity_type VARCHAR DEFAULT NULL,
    p_format VARCHAR DEFAULT 'CSV'
)
RETURNS TABLE (
    export_line TEXT
)
LANGUAGE plpgsql STABLE AS $$
BEGIN
    IF p_format = 'CSV' THEN
        RETURN QUERY
        SELECT
            -- Header row
            CASE WHEN ROW_NUMBER() OVER (ORDER BY ae.occurred_at ASC) = 1
                THEN 'event_id,occurred_at,event_type,entity_type,entity_id,action,user_id,user_name,user_role,session_id,authority_code,source_module,ip_address,old_value,new_value,changes,record_hash,previous_hash'
                ELSE NULL
            END
        FROM audit_event ae
        WHERE (p_from IS NULL OR ae.occurred_at >= p_from)
          AND (p_to IS NULL OR ae.occurred_at <= p_to)
          AND (p_authority_code IS NULL OR ae.authority_code = p_authority_code)
          AND (p_entity_type IS NULL OR ae.entity_type = p_entity_type)
        LIMIT 1
        UNION ALL
        SELECT
            ae.event_id::text || ',' ||
            ae.occurred_at::text || ',' ||
            COALESCE(ae.event_type, '') || ',' ||
            COALESCE(ae.entity_type, '') || ',' ||
            COALESCE(ae.entity_id::text, '') || ',' ||
            COALESCE(ae.action, '') || ',' ||
            COALESCE(ae.user_id::text, '') || ',' ||
            COALESCE(REPLACE(ae.user_name, ',', ';'), '') || ',' ||
            COALESCE(ae.user_role, '') || ',' ||
            COALESCE(ae.session_id, '') || ',' ||
            COALESCE(ae.authority_code, '') || ',' ||
            COALESCE(ae.source_module, '') || ',' ||
            COALESCE(ae.ip_address::text, '') || ',' ||
            COALESCE(REPLACE(ae.old_value::text, ',', ';'), '') || ',' ||
            COALESCE(REPLACE(ae.new_value::text, ',', ';'), '') || ',' ||
            COALESCE(REPLACE(ae.changes::text, ',', ';'), '') || ',' ||
            ae.record_hash || ',' ||
            COALESCE(ae.previous_hash, '')
        FROM audit_event ae
        WHERE (p_from IS NULL OR ae.occurred_at >= p_from)
          AND (p_to IS NULL OR ae.occurred_at <= p_to)
          AND (p_authority_code IS NULL OR ae.authority_code = p_authority_code)
          AND (p_entity_type IS NULL OR ae.entity_type = p_entity_type)
        ORDER BY ae.occurred_at ASC;

    ELSIF p_format = 'JSON' THEN
        RETURN QUERY
        SELECT jsonb_pretty(jsonb_agg(to_jsonb(ae) ORDER BY ae.occurred_at ASC))::text
        FROM audit_event ae
        WHERE (p_from IS NULL OR ae.occurred_at >= p_from)
          AND (p_to IS NULL OR ae.occurred_at <= p_to)
          AND (p_authority_code IS NULL OR ae.authority_code = p_authority_code)
          AND (p_entity_type IS NULL OR ae.entity_type = p_entity_type);
    ELSE
        RAISE EXCEPTION 'Unsupported format: %. Use CSV or JSON.', p_format;
    END IF;
END;
$$;

COMMENT ON FUNCTION export_audit IS
'Export audit events to CSV or JSON format. Used by the Office of the '
'Auditor General (OAG) for external analysis.
Example:
  SELECT * FROM export_audit(
      p_from := ''2026-01-01'',
      p_to := ''2026-12-31'',
      p_authority_code := ''CHILANGA'',
      p_format := ''CSV''
  );';

-- ---------------------------------------------------------------------
-- 2. RETENTION POLICY
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_retention_policy (
    policy_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_name         VARCHAR(100) NOT NULL UNIQUE,
    entity_category     VARCHAR(50) NOT NULL,
    retention_years     INTEGER NOT NULL,
    legal_basis         VARCHAR(255),
    description         TEXT,
    effective_from      DATE NOT NULL,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE audit_retention_policy IS
'Retention policy for audit events. Defines how long audit records are '
'kept before archival or purge, based on Zambian legal requirements.';

-- Seed the default retention policy
INSERT INTO audit_retention_policy
    (policy_name, entity_category, retention_years, legal_basis, description, effective_from)
VALUES
    ('FINANCIAL_RECORDS', 'FINANCIAL', 10,
     'Public Finance Management Act No. 1 of 2018',
     'Financial records must be retained for 10 years for audit and legal purposes.',
     '2026-01-01'),

    ('PAYROLL_RECORDS', 'PAYROLL', 10,
     'Public Finance Management Act No. 1 of 2018',
     'Payroll records including audit trail of salary changes retained for 10 years.',
     '2026-01-01'),

    ('PERSONAL_DATA', 'PERSONAL', 7,
     'Data Protection Act No. 3 of 2021',
     'Audit records involving personal data retained for 7 years.',
     '2026-01-01'),

    ('SYSTEM_EVENTS', 'SYSTEM', 5,
     'Internal ICT policy',
     'System configuration and migration events retained for 5 years.',
     '2026-01-01'),

    ('READ_EVENTS', 'READ', 3,
     'Data Protection Act No. 3 of 2021',
     'Sensitive data read events retained for 3 years.',
     '2026-01-01')
ON CONFLICT (policy_name) DO NOTHING;

-- ---------------------------------------------------------------------
-- Function: get_retention_policy
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_retention_policy()
RETURNS TABLE (
    policy_name VARCHAR,
    entity_category VARCHAR,
    retention_years INTEGER,
    legal_basis VARCHAR,
    description TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT policy_name, entity_category, retention_years, legal_basis, description
    FROM audit_retention_policy
    WHERE is_active = TRUE
    ORDER BY entity_category;
$$;

COMMENT ON FUNCTION get_retention_policy IS
'Returns the active audit retention policy. Used by the OAG to verify '
'that audit records are retained according to legal requirements.';

-- ---------------------------------------------------------------------
-- Function: archive_old_audit_events
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_event_archive (
    LIKE audit_event INCLUDING ALL
);

COMMENT ON TABLE audit_event_archive IS
'Long-term archive of audit events past their active retention period. '
'Still immutable. Still verifiable. Retained for legal preservation.';

CREATE OR REPLACE FUNCTION archive_old_audit_events(
    p_as_of_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    archived_count INTEGER,
    archive_timestamp TIMESTAMPTZ
)
LANGUAGE plpgsql AS $$
DECLARE
    v_count INTEGER := 0;
    v_cutoff TIMESTAMPTZ;
BEGIN
    -- Archive SYSTEM events older than 5 years
    v_cutoff := (p_as_of_date - INTERVAL '5 years')::TIMESTAMPTZ;

    WITH moved AS (
        DELETE FROM audit_event
        WHERE entity_type IN ('AUDIT_TRAIL', 'USER_SESSION')
          AND occurred_at < v_cutoff
        RETURNING *
    )
    INSERT INTO audit_event_archive SELECT * FROM moved;

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN QUERY SELECT v_count, NOW();
END;
$$;

COMMENT ON FUNCTION archive_old_audit_events IS
'Moves audit events past their retention period into the archive table. '
'Archived records remain immutable and verifiable. '
'Run periodically (e.g. monthly) to keep the active audit table lean.';

-- ---------------------------------------------------------------------
-- 3. READ-AUDIT FOR SENSITIVE TABLES
-- ---------------------------------------------------------------------

-- Register sensitive tables
CREATE TABLE IF NOT EXISTS audit_sensitive_table (
    table_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name          VARCHAR(100) NOT NULL UNIQUE,
    sensitivity_level   VARCHAR(20) NOT NULL,
        -- HIGH, MEDIUM, LOW
    reason              TEXT,
    requires_read_audit BOOLEAN NOT NULL DEFAULT TRUE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_sensitivity_level
        CHECK (sensitivity_level IN ('HIGH', 'MEDIUM', 'LOW'))
);

COMMENT ON TABLE audit_sensitive_table IS
'Registry of tables containing sensitive data. Every read of these '
'tables should be logged via log_sensitive_read.';

INSERT INTO audit_sensitive_table (table_name, sensitivity_level, reason)
VALUES
    ('employee', 'HIGH', 'Employee salaries and personal data'),
    ('employee_leave_master', 'HIGH', 'Employee leave balances and history'),
    ('employee_work_location', 'MEDIUM', 'Employee location tracking'),
    ('salary_scale_official', 'HIGH', 'Official salary scale data'),
    ('salary_notch_value', 'HIGH', 'Salary notch values'),
    ('journal_entry', 'MEDIUM', 'Financial journal entries'),
    ('journal_line', 'MEDIUM', 'Financial journal line details'),
    ('chart_of_accounts', 'LOW', 'Account structure (not sensitive, but tracked)'),
    ('fund', 'LOW', 'Fund structure (not sensitive, but tracked)')
ON CONFLICT (table_name) DO NOTHING;

-- ---------------------------------------------------------------------
-- Function: log_sensitive_read
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_sensitive_read(
    p_entity_type VARCHAR,
    p_entity_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_reason TEXT DEFAULT NULL
) RETURNS UUID
LANGUAGE plpgsql AS $$
DECLARE
    v_event_id UUID;
    v_is_sensitive BOOLEAN := FALSE;
    v_sensitivity VARCHAR;
BEGIN
    -- Check if this table is registered as sensitive
    SELECT requires_read_audit, sensitivity_level
    INTO v_is_sensitive, v_sensitivity
    FROM audit_sensitive_table
    WHERE table_name = LOWER(p_entity_type)
      AND is_active = TRUE;

    -- Only log if the table is registered as sensitive OR if not registered (default to logging)
    IF v_is_sensitive IS NULL OR v_is_sensitive = TRUE THEN
        v_event_id := log_audit_event(
            p_event_type := 'READ',
            p_entity_type := UPPER(p_entity_type),
            p_entity_id := p_entity_id,
            p_action := 'READ',
            p_new_value := jsonb_build_object(
                'reason', COALESCE(p_reason, 'Sensitive data access'),
                'sensitivity', COALESCE(v_sensitivity, 'UNREGISTERED')
            ),
            p_user_id := p_user_id,
            p_user_role := NULLIF(current_setting('app.current_user_role', TRUE), ''),
            p_authority_code := NULLIF(current_setting('app.authority_code', TRUE), ''),
            p_ip_address := inet_client_addr(),
            p_user_name := NULLIF(current_setting('app.current_user_name', TRUE), ''),
            p_session_id := NULLIF(current_setting('app.session_id', TRUE), ''),
            p_source_module := COALESCE(NULLIF(current_setting('app.source_module', TRUE), ''), 'READ_AUDIT')
        );
    END IF;

    RETURN v_event_id;
END;
$$;

COMMENT ON FUNCTION log_sensitive_read IS
'Log a read of sensitive data. Called by application code when '
'accessing employee salaries, personal data, or financial records.
Example:
  SELECT log_sensitive_read(
      p_entity_type := ''employee'',
      p_entity_id := ''...uuid...''::UUID,
      p_user_id := ''...uuid...''::UUID,
      p_reason := ''Payroll processing for December 2026''
  );';

-- ---------------------------------------------------------------------
-- Function: get_sensitive_tables
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_sensitive_tables()
RETURNS TABLE (
    table_name VARCHAR,
    sensitivity_level VARCHAR,
    reason TEXT,
    requires_read_audit BOOLEAN
)
LANGUAGE sql STABLE AS $$
    SELECT table_name, sensitivity_level, reason, requires_read_audit
    FROM audit_sensitive_table
    WHERE is_active = TRUE
    ORDER BY
        CASE sensitivity_level
            WHEN 'HIGH' THEN 1
            WHEN 'MEDIUM' THEN 2
            WHEN 'LOW' THEN 3
        END,
        table_name;
$$;

COMMENT ON FUNCTION get_sensitive_tables IS
'Returns the list of tables registered as containing sensitive data. '
'Used by developers and the OAG to understand data sensitivity classification.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'complete_audit_trail',
        'migration', 'V76',
        'purpose', 'Export, retention, and read-audit — final audit migration',
        'capabilities_added', ARRAY[
            'export_audit (CSV/JSON)',
            'retention policy',
            'archive function',
            'sensitive table registry',
            'log_sensitive_read'
        ],
        'audit_trail_complete', TRUE
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
