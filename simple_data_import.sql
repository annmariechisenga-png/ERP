-- Simple data import - no transaction, continue on error
\set ON_ERROR_STOP 0

-- Import all data files
\i extracted_data/councils.sql
\i extracted_data/council_types.sql
\i extracted_data/departments.sql
\i extracted_data/salary_scales.sql
\i extracted_data/authority_codes.sql
\i extracted_data/position_role_codes.sql
\i extracted_data/calendar.sql
\i extracted_data/holidays.sql
\i extracted_data/leave_types.sql
\i extracted_data/sections.sql
\i extracted_data/positions.sql
\i extracted_data/employees.sql
\i extracted_data/position_standard_id_map.sql
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
\i extracted_data/finance_sections.sql
\i extracted_data/finance_units.sql
\i extracted_data/legal_sections.sql
\i extracted_data/legal_units.sql
\i extracted_data/health_sections.sql
\i extracted_data/health_units.sql
\i extracted_data/community_sections.sql
\i extracted_data/community_units.sql
\i extracted_data/eng_units.sql
\i extracted_data/planning_sections.sql
\i extracted_data/planning_units.sql
\i extracted_data/ict_units.sql
\i extracted_data/ict_city_units.sql
\i extracted_data/audit_units.sql
\i extracted_data/procurement_units.sql
\i extracted_data/commercial_units.sql
\i extracted_data/commercial_city_units.sql
\i extracted_data/cos_units.sql
\i extracted_data/toc_units.sql
\i extracted_data/toc_city_units.sql
\i extracted_data/hra_position_supervisors.sql
\i extracted_data/eng_position_hierarchy.sql
\i extracted_data/position_supervisors.sql
\i extracted_data/position_attributes.sql
\i extracted_data/employee_sequence.sql
\i extracted_data/position_supervision.sql
\i extracted_data/hra_supervision.sql
\i extracted_data/legal_supervision.sql
\i extracted_data/health_supervision.sql
\i extracted_data/community_supervision.sql
\i extracted_data/ict_supervision.sql
\i extracted_data/audit_supervision.sql
\i extracted_data/procurement_supervision.sql
\i extracted_data/commercial_supervision.sql
\i extracted_data/cos_supervision.sql
\i extracted_data/toc_supervision.sql
\i extracted_data/valuation_city_supervision.sql
\i extracted_data/ict_city_supervision.sql
\i extracted_data/commercial_city_supervision.sql
\i extracted_data/toc_city_supervision.sql
\i extracted_data/leave_approval_chain.sql
\i extracted_data/hra_leave_approval_chain.sql
\i extracted_data/finance_leave_approval_chain.sql
\i extracted_data/legal_leave_approval_chain.sql
\i extracted_data/health_leave_approval_chain.sql
\i extracted_data/eng_leave_approval_chain.sql
\i extracted_data/planning_leave_approval_chain.sql
\i extracted_data/leave_requests.sql
\i extracted_data/leave_policy.sql
\i extracted_data/mothers_day_leave_tracking.sql
\i extracted_data/sms_gateway_config.sql
\i extracted_data/job_description_documents.sql
\i extracted_data/jd_upload_queue.sql
\i extracted_data/jd_review_queue.sql

-- Show counts after import
SELECT 'Councils' as table_name, COUNT(*) FROM councils
UNION ALL
SELECT 'Employees', COUNT(*) FROM employees
UNION ALL
SELECT 'HRA_Positions', COUNT(*) FROM hra_positions
UNION ALL
SELECT 'Finance_Positions', COUNT(*) FROM finance_positions
ORDER BY 1;
