-- =====================================================================
-- V75__audit_query_interface.sql
-- OAG Query Interface for Audit Events
-- =====================================================================
-- This migration provides the Office of the Auditor General (OAG)
-- with a self-service query interface for the audit trail.
--
-- Functions:
--   query_audit()      — Structured query with many optional filters
--   search_audit()     — Free-text search across user, entity, and values
--   audit_entity_history() — Full history of a specific entity
--   audit_user_activity()  — All actions by a specific user
--   audit_timeline()   — Chronological events for a date range
--   audit_statistics() — Aggregate statistics for reporting
--
-- All functions are read-only, safe, and optimized with indexes.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. query_audit — Structured multi-filter query
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION query_audit(
    p_from TIMESTAMPTZ DEFAULT NULL,
    p_to TIMESTAMPTZ DEFAULT NULL,
    p_entity_type VARCHAR DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL,
    p_user_id UUID DEFAULT NULL,
    p_user_name VARCHAR DEFAULT NULL,
    p_action VARCHAR DEFAULT NULL,
    p_event_type VARCHAR DEFAULT NULL,
    p_authority_code VARCHAR DEFAULT NULL,
    p_source_module VARCHAR DEFAULT NULL,
    p_session_id VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 1000,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    event_id UUID,
    occurred_at TIMESTAMPTZ,
    event_type VARCHAR,
    entity_type VARCHAR,
    entity_id UUID,
    action VARCHAR,
    user_id UUID,
    user_name VARCHAR,
    user_role VARCHAR,
    session_id VARCHAR,
    authority_code VARCHAR,
    source_module VARCHAR,
    ip_address INET,
    old_value JSONB,
    new_value JSONB,
    changes JSONB,
    record_hash VARCHAR,
    previous_hash VARCHAR
)
LANGUAGE sql STABLE AS $$
    SELECT
        ae.event_id,
        ae.occurred_at,
        ae.event_type,
        ae.entity_type,
        ae.entity_id,
        ae.action,
        ae.user_id,
        ae.user_name,
        ae.user_role,
        ae.session_id,
        ae.authority_code,
        ae.source_module,
        ae.ip_address,
        ae.old_value,
        ae.new_value,
        ae.changes,
        ae.record_hash,
        ae.previous_hash
    FROM audit_event ae
    WHERE (p_from IS NULL OR ae.occurred_at >= p_from)
      AND (p_to IS NULL OR ae.occurred_at <= p_to)
      AND (p_entity_type IS NULL OR ae.entity_type = p_entity_type)
      AND (p_entity_id IS NULL OR ae.entity_id = p_entity_id)
      AND (p_user_id IS NULL OR ae.user_id = p_user_id)
      AND (p_user_name IS NULL OR ae.user_name = p_user_name)
      AND (p_action IS NULL OR ae.action = p_action)
      AND (p_event_type IS NULL OR ae.event_type = p_event_type)
      AND (p_authority_code IS NULL OR ae.authority_code = p_authority_code)
      AND (p_source_module IS NULL OR ae.source_module = p_source_module)
      AND (p_session_id IS NULL OR ae.session_id = p_session_id)
    ORDER BY ae.occurred_at DESC
    LIMIT p_limit
    OFFSET p_offset;
$$;

COMMENT ON FUNCTION query_audit IS
'OAG query interface. Multi-filter query for audit events. All filters '
'are optional. Returns full audit records sorted by occurred_at DESC. '
'Use p_limit and p_offset for pagination.
Example:
  SELECT * FROM query_audit(
      p_from := ''2026-01-01'',
      p_entity_type := ''JOURNAL_ENTRY'',
      p_action := ''POST''
  );';

-- ---------------------------------------------------------------------
-- 2. search_audit — Free-text search
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION search_audit(
    p_search_text TEXT,
    p_from TIMESTAMPTZ DEFAULT NULL,
    p_to TIMESTAMPTZ DEFAULT NULL,
    p_limit INTEGER DEFAULT 100
)
RETURNS TABLE (
    event_id UUID,
    occurred_at TIMESTAMPTZ,
    event_type VARCHAR,
    entity_type VARCHAR,
    action VARCHAR,
    user_name VARCHAR,
    authority_code VARCHAR,
    source_module VARCHAR,
    match_context TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT
        ae.event_id,
        ae.occurred_at,
        ae.event_type,
        ae.entity_type,
        ae.action,
        ae.user_name,
        ae.authority_code,
        ae.source_module,
        CASE
            WHEN ae.user_name ILIKE '%' || p_search_text || '%' THEN 'Matched user_name: ' || ae.user_name
            WHEN ae.entity_type ILIKE '%' || p_search_text || '%' THEN 'Matched entity_type: ' || ae.entity_type
            WHEN ae.new_value::text ILIKE '%' || p_search_text || '%' THEN 'Matched new_value'
            WHEN ae.old_value::text ILIKE '%' || p_search_text || '%' THEN 'Matched old_value'
            WHEN ae.source_module ILIKE '%' || p_search_text || '%' THEN 'Matched source_module: ' || ae.source_module
            ELSE 'Matched other field'
        END AS match_context
    FROM audit_event ae
    WHERE (p_from IS NULL OR ae.occurred_at >= p_from)
      AND (p_to IS NULL OR ae.occurred_at <= p_to)
      AND (
          ae.user_name ILIKE '%' || p_search_text || '%'
          OR ae.entity_type ILIKE '%' || p_search_text || '%'
          OR ae.new_value::text ILIKE '%' || p_search_text || '%'
          OR ae.old_value::text ILIKE '%' || p_search_text || '%'
          OR ae.source_module ILIKE '%' || p_search_text || '%'
          OR ae.authority_code ILIKE '%' || p_search_text || '%'
          OR ae.session_id ILIKE '%' || p_search_text || '%'
      )
    ORDER BY ae.occurred_at DESC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION search_audit IS
'Free-text search across the audit trail. Searches user_name, entity_type, '
'old/new values, source_module, authority_code, and session_id. '
'Example:
  SELECT * FROM search_audit(''journal_entry'');
  SELECT * FROM search_audit(''chilanga'');
  SELECT * FROM search_audit(''fund_name'');';

-- ---------------------------------------------------------------------
-- 3. audit_entity_history — Full history of a specific entity
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_entity_history(
    p_entity_type VARCHAR,
    p_entity_id UUID,
    p_limit INTEGER DEFAULT 1000
)
RETURNS TABLE (
    event_id UUID,
    occurred_at TIMESTAMPTZ,
    event_type VARCHAR,
    action VARCHAR,
    user_id UUID,
    user_name VARCHAR,
    session_id VARCHAR,
    source_module VARCHAR,
    old_value JSONB,
    new_value JSONB,
    changes JSONB
)
LANGUAGE sql STABLE AS $$
    SELECT
        ae.event_id,
        ae.occurred_at,
        ae.event_type,
        ae.action,
        ae.user_id,
        ae.user_name,
        ae.session_id,
        ae.source_module,
        ae.old_value,
        ae.new_value,
        ae.changes
    FROM audit_event ae
    WHERE ae.entity_type = p_entity_type
      AND ae.entity_id = p_entity_id
    ORDER BY ae.occurred_at ASC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION audit_entity_history IS
'Returns the complete history of a specific entity (identified by type + id). '
'Records are returned in chronological order (oldest to newest) so the OAG '
'can trace the full evolution of the entity.
Example:
  SELECT * FROM audit_entity_history(
      ''JOURNAL_ENTRY'',
      ''...uuid...''::UUID
  );';

-- ---------------------------------------------------------------------
-- 4. audit_user_activity — All actions by a specific user
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_user_activity(
    p_user_id UUID,
    p_from TIMESTAMPTZ DEFAULT NULL,
    p_to TIMESTAMPTZ DEFAULT NULL,
    p_limit INTEGER DEFAULT 1000
)
RETURNS TABLE (
    event_id UUID,
    occurred_at TIMESTAMPTZ,
    event_type VARCHAR,
    entity_type VARCHAR,
    entity_id UUID,
    action VARCHAR,
    authority_code VARCHAR,
    source_module VARCHAR,
    ip_address INET,
    session_id VARCHAR
)
LANGUAGE sql STABLE AS $$
    SELECT
        ae.event_id,
        ae.occurred_at,
        ae.event_type,
        ae.entity_type,
        ae.entity_id,
        ae.action,
        ae.authority_code,
        ae.source_module,
        ae.ip_address,
        ae.session_id
    FROM audit_event ae
    WHERE ae.user_id = p_user_id
      AND (p_from IS NULL OR ae.occurred_at >= p_from)
      AND (p_to IS NULL OR ae.occurred_at <= p_to)
    ORDER BY ae.occurred_at DESC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION audit_user_activity IS
'Returns all audit events attributed to a specific user. '
'Used by the OAG to review the actions of individual officers.
Example:
  SELECT * FROM audit_user_activity(
      ''...uuid...''::UUID,
      ''2026-01-01'',
      ''2026-12-31''
  );';

-- ---------------------------------------------------------------------
-- 5. audit_timeline — Chronological events for a date range
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_timeline(
    p_from TIMESTAMPTZ,
    p_to TIMESTAMPTZ,
    p_authority_code VARCHAR DEFAULT NULL,
    p_limit INTEGER DEFAULT 5000
)
RETURNS TABLE (
    occurred_at TIMESTAMPTZ,
    event_type VARCHAR,
    entity_type VARCHAR,
    action VARCHAR,
    user_name VARCHAR,
    authority_code VARCHAR,
    source_module VARCHAR,
    summary TEXT
)
LANGUAGE sql STABLE AS $$
    SELECT
        ae.occurred_at,
        ae.event_type,
        ae.entity_type,
        ae.action,
        ae.user_name,
        ae.authority_code,
        ae.source_module,
        ae.action || ' on ' || ae.entity_type ||
            CASE
                WHEN ae.user_name IS NOT NULL THEN ' by ' || ae.user_name
                ELSE ''
            END ||
            CASE
                WHEN ae.authority_code IS NOT NULL THEN ' at ' || ae.authority_code
                ELSE ''
            END AS summary
    FROM audit_event ae
    WHERE ae.occurred_at >= p_from
      AND ae.occurred_at <= p_to
      AND (p_authority_code IS NULL OR ae.authority_code = p_authority_code)
    ORDER BY ae.occurred_at ASC
    LIMIT p_limit;
$$;

COMMENT ON FUNCTION audit_timeline IS
'Chronological timeline of audit events within a date range. '
'Returns a human-readable summary line for each event. '
'Used by the OAG to review a period chronologically.
Example:
  SELECT * FROM audit_timeline(
      ''2026-01-01'',
      ''2026-12-31'',
      ''CHILANGA''
  );';

-- ---------------------------------------------------------------------
-- 6. audit_statistics — Aggregate statistics for reporting
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION audit_statistics(
    p_from TIMESTAMPTZ DEFAULT NULL,
    p_to TIMESTAMPTZ DEFAULT NULL,
    p_authority_code VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    metric VARCHAR,
    value BIGINT
)
LANGUAGE sql STABLE AS $$
    WITH filtered AS (
        SELECT *
        FROM audit_event
        WHERE (p_from IS NULL OR occurred_at >= p_from)
          AND (p_to IS NULL OR occurred_at <= p_to)
          AND (p_authority_code IS NULL OR authority_code = p_authority_code)
    )
    SELECT 'total_events', COUNT(*)::BIGINT FROM filtered
    UNION ALL
    SELECT 'distinct_users', COUNT(DISTINCT user_id)::BIGINT FROM filtered
    UNION ALL
    SELECT 'distinct_entities', COUNT(DISTINCT entity_type)::BIGINT FROM filtered
    UNION ALL
    SELECT 'distinct_sessions', COUNT(DISTINCT session_id)::BIGINT FROM filtered
    UNION ALL
    SELECT 'distinct_authorities', COUNT(DISTINCT authority_code)::BIGINT FROM filtered
    UNION ALL
    SELECT 'create_events', COUNT(*)::BIGINT FROM filtered WHERE action = 'CREATE'
    UNION ALL
    SELECT 'update_events', COUNT(*)::BIGINT FROM filtered WHERE action = 'UPDATE'
    UNION ALL
    SELECT 'delete_events', COUNT(*)::BIGINT FROM filtered WHERE action = 'DELETE'
    UNION ALL
    SELECT 'login_events', COUNT(*)::BIGINT FROM filtered WHERE action = 'LOGIN'
    UNION ALL
    SELECT 'export_events', COUNT(*)::BIGINT FROM filtered WHERE action = 'EXPORT'
    UNION ALL
    SELECT 'first_event_at', EXTRACT(EPOCH FROM MIN(occurred_at))::BIGINT FROM filtered
    UNION ALL
    SELECT 'last_event_at', EXTRACT(EPOCH FROM MAX(occurred_at))::BIGINT FROM filtered;
$$;

COMMENT ON FUNCTION audit_statistics IS
'Returns aggregate statistics for a date range and authority. '
'Metrics include total events, distinct users, distinct entities, '
'breakdown by action (CREATE, UPDATE, DELETE, LOGIN, EXPORT). '
'Used for OAG summary reports and management dashboards.
Example:
  SELECT * FROM audit_statistics(''2026-01-01'', ''2026-12-31'', ''CHILANGA'');';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'create_audit_query_interface',
        'migration', 'V75',
        'purpose', 'OAG self-service query interface',
        'functions_created', ARRAY[
            'query_audit',
            'search_audit',
            'audit_entity_history',
            'audit_user_activity',
            'audit_timeline',
            'audit_statistics'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
