-- =====================================================================
-- V1_0_2 — Create base leave_policy table
-- =====================================================================
-- The leave_policy table was previously created out-of-band (manually) on
-- development databases. Migrations V2 (dedup), V43 (seed), V44 (engine
-- consolidation), V45 (calculation engine), V50–V52 (constraints/columns),
-- and V54 (indexes) all assume it exists. On a fresh database Flyway
-- reached V43 and failed with "relation leave_policy does not exist".
--
-- This migration creates the base shape matching what was hand-built on
-- localgov_erp: 10 columns, no primary key (V44 adds `id` and a PK).
-- Columns added later by V44–V52 are not included here.
--
-- CREATE TABLE IF NOT EXISTS keeps existing databases unaffected.
-- =====================================================================

CREATE TABLE IF NOT EXISTS leave_policy (
    leave_type        TEXT,
    division          TEXT,
    accrual_rate      REAL,
    max_days          BIGINT,
    carry_forward     BIGINT,
    eligibility       TEXT,
    fixed_days        BIGINT,
    max_accumulation  BIGINT,
    max_duration      BIGINT,
    advance_notice    BIGINT
);
