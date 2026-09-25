-- =====================================================================
-- V69__fix_audit_event_type_constraint.sql
-- Fix: Expand allowed event_type values in chk_audit_event_type
-- =====================================================================
-- The V65 constraint did not include TRANSACTION and REVERSED.
-- The old log_audit_event (V63) used TRANSACTION as default.
-- This caused check constraint violations when legacy calls were made.
--
-- Fix: Expand allowed values to include TRANSACTION and REVERSED.
-- This is backward-compatible and more permissive.
-- =====================================================================

-- Drop the old constraint
ALTER TABLE audit_event
    DROP CONSTRAINT IF EXISTS chk_audit_event_type;

-- Add the expanded constraint
ALTER TABLE audit_event
    ADD CONSTRAINT chk_audit_event_type
    CHECK (event_type IN (
        'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE', 'POST',
        'REVERSE', 'REVERSED', 'APPROVE', 'REJECT', 'READ', 'EXPORT',
        'PRINT', 'CONFIG_CHANGE', 'CONFIG', 'SYSTEM', 'TRANSACTION',
        'OTHER'
    ));

COMMENT ON CONSTRAINT chk_audit_event_type ON audit_event IS
'Allowed event types. Expanded in V69 to include TRANSACTION, '
'REVERSED, and CONFIG for backward compatibility with earlier '
'log_audit_event versions.';

-- ---------------------------------------------------------------------
-- Log the migration
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'expand_audit_event_type_constraint',
        'migration', 'V69',
        'reason', 'Allow TRANSACTION, REVERSED, CONFIG for backward compatibility',
        'new_allowed_values', ARRAY[
            'LOGIN', 'LOGOUT', 'CREATE', 'UPDATE', 'DELETE', 'POST',
            'REVERSE', 'REVERSED', 'APPROVE', 'REJECT', 'READ', 'EXPORT',
            'PRINT', 'CONFIG_CHANGE', 'CONFIG', 'SYSTEM', 'TRANSACTION',
            'OTHER'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
