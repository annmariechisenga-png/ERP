-- =====================================================================
-- V68__fix_v67_audit_log.sql
-- Fix: V67 used PERFORM at top level (invalid in SQL scripts)
-- =====================================================================
-- PERFORM is a PL/pgSQL construct. It works inside functions and DO
-- blocks but fails at the top level of a SQL script.
-- Fix: Use SELECT log_audit_event(...) instead.
--
-- Also logs the correction itself.
-- =====================================================================

-- Log the V67 migration (which failed to log itself due to PERFORM syntax)
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_audit_function_overload',
        'migration', 'V67',
        'dropped_versions', ARRAY['log_audit_event (11 params)'],
        'kept_versions', ARRAY['log_audit_event (16 params)'],
        'rebuilt_functions', ARRAY['post_journal', 'reverse_journal'],
        'note', 'V67 migration itself failed to log due to PERFORM syntax error; logged by V68'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);

-- Log this correction migration
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'fix_migration_syntax',
        'migration', 'V68',
        'issue', 'PERFORM used at top level of SQL script',
        'fix', 'Replaced with SELECT'
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
