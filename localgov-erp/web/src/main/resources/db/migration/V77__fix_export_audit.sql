-- =====================================================================
-- V77__fix_export_audit.sql
-- Fix: export_audit() UNION syntax error
-- =====================================================================
-- The original V76 export_audit() used UNION ALL between a SELECT
-- with LIMIT and a SELECT with ORDER BY, which PostgreSQL rejects.
--
-- Fix: Split into two separate queries controlled by IF/ELSE. Return
-- the header row separately from the data rows.
--
-- Also improves CSV escaping (quotes fields containing commas).
-- =====================================================================

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
        -- Header row
        RETURN QUERY
        SELECT 'event_id,occurred_at,event_type,entity_type,entity_id,action,user_id,user_name,user_role,session_id,authority_code,source_module,ip_address,old_value,new_value,changes,record_hash,previous_hash'::TEXT;

        -- Data rows
        RETURN QUERY
        SELECT
            '"' || ae.event_id::text || '",' ||
            '"' || ae.occurred_at::text || '",' ||
            '"' || COALESCE(ae.event_type, '') || '",' ||
            '"' || COALESCE(ae.entity_type, '') || '",' ||
            '"' || COALESCE(ae.entity_id::text, '') || '",' ||
            '"' || COALESCE(ae.action, '') || '",' ||
            '"' || COALESCE(ae.user_id::text, '') || '",' ||
            '"' || COALESCE(ae.user_name, '') || '",' ||
            '"' || COALESCE(ae.user_role, '') || '",' ||
            '"' || COALESCE(ae.session_id, '') || '",' ||
            '"' || COALESCE(ae.authority_code, '') || '",' ||
            '"' || COALESCE(ae.source_module, '') || '",' ||
            '"' || COALESCE(ae.ip_address::text, '') || '",' ||
            '"' || COALESCE(REPLACE(ae.old_value::text, '"', '""'), '') || '",' ||
            '"' || COALESCE(REPLACE(ae.new_value::text, '"', '""'), '') || '",' ||
            '"' || COALESCE(REPLACE(ae.changes::text, '"', '""'), '') || '",' ||
            '"' || ae.record_hash || '",' ||
            '"' || COALESCE(ae.previous_hash, '') || '"'
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

    ELSIF p_format = 'TSV' THEN
        -- Tab-Separated Values — useful when data contains commas
        RETURN QUERY
        SELECT 'event_id' || chr(9) || 'occurred_at' || chr(9) || 'event_type' || chr(9) ||
               'entity_type' || chr(9) || 'entity_id' || chr(9) || 'action' || chr(9) ||
               'user_id' || chr(9) || 'user_name' || chr(9) || 'user_role' || chr(9) ||
               'session_id' || chr(9) || 'authority_code' || chr(9) || 'source_module' || chr(9) ||
               'ip_address' || chr(9) || 'old_value' || chr(9) || 'new_value' || chr(9) ||
               'changes' || chr(9) || 'record_hash' || chr(9) || 'previous_hash'::TEXT;

        RETURN QUERY
        SELECT
            ae.event_id::text || chr(9) ||
            ae.occurred_at::text || chr(9) ||
            COALESCE(ae.event_type, '') || chr(9) ||
            COALESCE(ae.entity_type, '') || chr(9) ||
            COALESCE(ae.entity_id::text, '') || chr(9) ||
            COALESCE(ae.action, '') || chr(9) ||
            COALESCE(ae.user_id::text, '') || chr(9) ||
            COALESCE(ae.user_name, '') || chr(9) ||
            COALESCE(ae.user_role, '') || chr(9) ||
            COALESCE(ae.session_id, '') || chr(9) ||
            COALESCE(ae.authority_code, '') || chr(9) ||
            COALESCE(ae.source_module, '') || chr(9) ||
            COALESCE(ae.ip_address::text, '') || chr(9) ||
            COALESCE(ae.old_value::text, '') || chr(9) ||
            COALESCE(ae.new_value::text, '') || chr(9) ||
            COALESCE(ae.changes::text, '') || chr(9) ||
            ae.record_hash || chr(9) ||
            COALESCE(ae.previous_hash, '')
        FROM audit_event ae
        WHERE (p_from IS NULL OR ae.occurred_at >= p_from)
          AND (p_to IS NULL OR ae.occurred_at <= p_to)
          AND (p_authority_code IS NULL OR ae.authority_code = p_authority_code)
          AND (p_entity_type IS NULL OR ae.entity_type = p_entity_type)
        ORDER BY ae.occurred_at ASC;

    ELSE
        RAISE EXCEPTION 'Unsupported format: %. Use CSV, JSON, or TSV.', p_format;
    END IF;
END;
$$;

COMMENT ON FUNCTION export_audit IS
'Export audit events to CSV, JSON, or TSV format. Used by the Office '
'of the Auditor General (OAG) for external analysis.
Fixed in V77: UNION syntax error + added TSV format + improved escaping.
Example:
  SELECT * FROM export_audit(
      p_from := ''2026-01-01'',
      p_to := ''2026-12-31'',
      p_authority_code := ''CHILANGA'',
      p_format := ''CSV''
  );';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_export_audit',
        'migration', 'V77',
        'bug', 'UNION syntax error between LIMIT and ORDER BY selects',
        'fix', 'Split into separate RETURN QUERY statements; added TSV format; improved CSV escaping'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
