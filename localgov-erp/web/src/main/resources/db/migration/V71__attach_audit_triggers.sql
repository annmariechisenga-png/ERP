-- =====================================================================
-- V71__attach_audit_triggers.sql
-- Attach Auto-Logging Triggers to Business Tables
-- =====================================================================
-- This migration attaches the generic audit_trigger_func to every
-- business table in the Finance Department. From this point on,
-- every INSERT, UPDATE, or DELETE on these tables is automatically
-- logged to audit_event — no application code required.
--
-- Tables covered:
--   1. fund
--   2. cost_center
--   3. chart_of_accounts
--   4. fiscal_year
--   5. fiscal_period
--   6. journal_entry
--   7. journal_line
--
-- After this migration, the database is self-auditing.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. FUND
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_fund ON fund;
CREATE TRIGGER trg_audit_fund
    AFTER INSERT OR UPDATE OR DELETE ON fund
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 2. COST CENTER
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_cost_center ON cost_center;
CREATE TRIGGER trg_audit_cost_center
    AFTER INSERT OR UPDATE OR DELETE ON cost_center
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 3. CHART OF ACCOUNTS
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_chart_of_accounts ON chart_of_accounts;
CREATE TRIGGER trg_audit_chart_of_accounts
    AFTER INSERT OR UPDATE OR DELETE ON chart_of_accounts
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 4. FISCAL YEAR
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_fiscal_year ON fiscal_year;
CREATE TRIGGER trg_audit_fiscal_year
    AFTER INSERT OR UPDATE OR DELETE ON fiscal_year
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 5. FISCAL PERIOD
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_fiscal_period ON fiscal_period;
CREATE TRIGGER trg_audit_fiscal_period
    AFTER INSERT OR UPDATE OR DELETE ON fiscal_period
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 6. JOURNAL ENTRY
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_journal_entry ON journal_entry;
CREATE TRIGGER trg_audit_journal_entry
    AFTER INSERT OR UPDATE OR DELETE ON journal_entry
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- 7. JOURNAL LINE
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_audit_journal_line ON journal_line;
CREATE TRIGGER trg_audit_journal_line
    AFTER INSERT OR UPDATE OR DELETE ON journal_line
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- ---------------------------------------------------------------------
-- Log the migration itself
-- ---------------------------------------------------------------------
SELECT log_audit_event(
    p_event_type := 'SYSTEM',
    p_entity_type := 'AUDIT_TRAIL',
    p_entity_id := NULL,
    p_action := 'CONFIG',
    p_new_value := jsonb_build_object(
        'action', 'attach_audit_triggers',
        'migration', 'V71',
        'purpose', 'Auto-logging triggers attached to all business tables',
        'tables_covered', ARRAY[
            'fund',
            'cost_center',
            'chart_of_accounts',
            'fiscal_year',
            'fiscal_period',
            'journal_entry',
            'journal_line'
        ]
    ),
    p_user_id := '00000000-0000-0000-0000-000000000001'::UUID,
    p_user_name := 'SYSTEM',
    p_user_role := 'SYSTEM',
    p_source_module := 'MIGRATION'
);
