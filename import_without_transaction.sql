-- ============================================
-- IMPORT WITHOUT TRANSACTION (ERRORS WON'T STOP)
-- ============================================

-- Disable triggers (optional)
SET session_replication_role = 'replica';

-- LEVEL 1: CORE TABLES
\echo 'Importing Level 1: Core Tables...'
\i extracted_data/councils.sql
\i extracted_data/council_types.sql
\i extracted_data/departments.sql
\i extracted_data/salary_scales.sql
\i extracted_data/authority_codes.sql
\i extracted_data/position_role_codes.sql
\i extracted_data/calendar.sql
\i extracted_data/holidays.sql
\i extracted_data/leave_types.sql

-- LEVEL 2: BASIC STRUCTURE TABLES
\echo 'Importing Level 2: Basic Structure...'
\i extracted_data/sections.sql
\i extracted_data/positions.sql
\i extracted_data/employees.sql
\i extracted_data/position_standard_id_map.sql

-- LEVEL 3: DEPARTMENT POSITIONS
\echo 'Importing Level 3: Department Positions...'
\i extracted_data/hra_positions.sql
\i extracted_data/finance_positions.sql
\i extracted_data/legal_positions.sql
\i extracted_data/health_positions.sql
\i extracted_data/community_positions.sql
\i extracted_data/eng_positions.sql
\i extracted_data/planning_positions.sql
\i extracted_data/ict_positions.sql
\i extracted_data/audit_positions.sql
\i extracted_data/procurement_positions.sql
\i extracted_data/commercial_positions.sql
\i extracted_data/cos_positions.sql
\i extracted_data/toc_positions.sql
\i extracted_data/valuation_city_positions.sql
\i extracted_data/ict_city_positions.sql
\i extracted_data/commercial_city_positions.sql
\i extracted_data/toc_city_positions.sql
\i extracted_data/executive_positions.sql

-- Continue with all other levels...
-- (rest of the file continues with all 11 levels)

-- Re-enable triggers
SET session_replication_role = 'origin';

\echo '========================================'
\echo 'IMPORT COMPLETE (with possible errors)'
\echo '========================================'
