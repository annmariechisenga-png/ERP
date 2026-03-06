-- ============================================
-- COMPLETE ERP DATABASE IMPORT - ALL 137 TABLES
-- 11-LEVEL DEPENDENCY ORDER
-- ============================================

-- Disable triggers temporarily to speed up import
SET session_replication_role = 'replica';

BEGIN;

-- ============================================
-- LEVEL 1: CORE TABLES (NO DEPENDENCIES)
-- ============================================
\echo 'Importing Level 1: Core Tables...'

-- Councils
\i extracted_data/councils.sql

-- Council Types
\i extracted_data/council_types.sql

-- Departments
\i extracted_data/departments.sql

-- Salary Scales
\i extracted_data/salary_scales.sql

-- Authority Codes
\i extracted_data/authority_codes.sql

-- Position Role Codes
\i extracted_data/position_role_codes.sql

-- Calendar
\i extracted_data/calendar.sql

-- Holidays
\i extracted_data/holidays.sql

-- Leave Types
\i extracted_data/leave_types.sql

-- ============================================
-- LEVEL 2: BASIC STRUCTURE TABLES
-- ============================================
\echo 'Importing Level 2: Basic Structure...'

-- Sections (depends on councils)
\i extracted_data/sections.sql

-- Positions (depends on councils, departments)
\i extracted_data/positions.sql

-- Employees (depends on councils, salary_scales)
\i extracted_data/employees.sql

-- Position Standard ID Map (depends on positions)
\i extracted_data/position_standard_id_map.sql

-- ============================================
-- LEVEL 3: DEPARTMENT POSITION TABLES
-- ============================================
\echo 'Importing Level 3: Department Positions...'

-- HRA Positions
\i extracted_data/hra_positions.sql

-- Finance Positions
\i extracted_data/finance_positions.sql

-- Legal Positions
\i extracted_data/legal_positions.sql

-- Health Positions
\i extracted_data/health_positions.sql

-- Community Positions
\i extracted_data/community_positions.sql

-- Engineering Positions
\i extracted_data/eng_positions.sql

-- Planning Positions
\i extracted_data/planning_positions.sql

-- ICT Positions
\i extracted_data/ict_positions.sql

-- Audit Positions
\i extracted_data/audit_positions.sql

-- Procurement Positions
\i extracted_data/procurement_positions.sql

-- Commercial Positions
\i extracted_data/commercial_positions.sql

-- COS Positions (Council Secretary Office)
\i extracted_data/cos_positions.sql

-- TOC Positions (Town Clerk Office)
\i extracted_data/toc_positions.sql

-- Valuation City Positions
\i extracted_data/valuation_city_positions.sql

-- ICT City Positions
\i extracted_data/ict_city_positions.sql

-- Commercial City Positions
\i extracted_data/commercial_city_positions.sql

-- TOC City Positions
\i extracted_data/toc_city_positions.sql

-- Executive Positions
\i extracted_data/executive_positions.sql

-- ============================================
-- LEVEL 4: DEPARTMENT UNITS & SECTIONS
-- ============================================
\echo 'Importing Level 4: Department Units & Sections...'

-- Finance Sections & Units
\i extracted_data/finance_sections.sql
\i extracted_data/finance_units.sql

-- Legal Sections & Units
\i extracted_data/legal_sections.sql
\i extracted_data/legal_units.sql

-- Health Sections & Units
\i extracted_data/health_sections.sql
\i extracted_data/health_units.sql

-- Community Sections & Units
\i extracted_data/community_sections.sql
\i extracted_data/community_units.sql

-- Engineering Units
\i extracted_data/eng_units.sql

-- Planning Sections & Units
\i extracted_data/planning_sections.sql
\i extracted_data/planning_units.sql

-- ICT Units
\i extracted_data/ict_units.sql
\i extracted_data/ict_city_units.sql

-- Audit Units
\i extracted_data/audit_units.sql

-- Procurement Sections & Units
\i extracted_data/procurement_sections.sql
\i extracted_data/procurement_units.sql

-- Commercial Units
\i extracted_data/commercial_units.sql
\i extracted_data/commercial_city_units.sql

-- COS Units
\i extracted_data/cos_units.sql

-- TOC Units
\i extracted_data/toc_units.sql
\i extracted_data/toc_city_units.sql

-- ============================================
-- LEVEL 5: DEPARTMENT DETAIL TABLES
-- ============================================
\echo 'Importing Level 5: Department Details...'

-- HRA Details
\i extracted_data/hra_position_attributes.sql
\i extracted_data/hra_position_supervisors.sql
\i extracted_data/hra_reportinglines.sql

-- Finance Details
\i extracted_data/finance_positions_detailed.sql
\i extracted_data/finance_salary_distribution.sql

-- Legal Details
\i extracted_data/legal_positions_detailed.sql
\i extracted_data/legal_salary_distribution.sql

-- Health Details
\i extracted_data/health_positions_detailed.sql
\i extracted_data/health_salary_distribution.sql

-- Engineering Details
\i extracted_data/eng_positions_detailed.sql
\i extracted_data/eng_salary_scale_distribution.sql
\i extracted_data/eng_position_hierarchy.sql

-- Planning Details
\i extracted_data/planning_positions_detailed.sql
\i extracted_data/planning_salary_distribution.sql
\i extracted_data/planning_management_structure.sql

-- General Details
\i extracted_data/position_supervisors.sql
\i extracted_data/position_attributes.sql
\i extracted_data/duplicates_archive.sql
\i extracted_data/employee_sequence.sql

-- ============================================
-- LEVEL 6: SUPERVISION HIERARCHY TABLES
-- ============================================
\echo 'Importing Level 6: Supervision Hierarchies...'

-- General Supervision
\i extracted_data/position_supervision.sql

-- Department Supervision
\i extracted_data/hra_supervision.sql
\i extracted_data/finance_supervision.sql
\i extracted_data/legal_supervision.sql
\i extracted_data/health_supervision.sql
\i extracted_data/community_supervision.sql
\i extracted_data/eng_supervision.sql
\i extracted_data/planning_supervision.sql
\i extracted_data/ict_supervision.sql
\i extracted_data/audit_supervision.sql
\i extracted_data/procurement_supervision.sql
\i extracted_data/commercial_supervision.sql
\i extracted_data/cos_supervision.sql
\i extracted_data/toc_supervision.sql

-- City-Specific Supervision
\i extracted_data/valuation_city_supervision.sql
\i extracted_data/ict_city_supervision.sql
\i extracted_data/commercial_city_supervision.sql
\i extracted_data/toc_city_supervision.sql

-- ============================================
-- LEVEL 7: APPROVAL CHAINS
-- ============================================
\echo 'Importing Level 7: Approval Chains...'

-- General Approval Chains
\i extracted_data/leave_approval_chain.sql
\i extracted_data/leaveapprovalchains.sql

-- Department Approval Chains
\i extracted_data/hra_leave_approval_chain.sql
\i extracted_data/hra_leaveapprovalchains.sql
\i extracted_data/finance_leave_approval_chain.sql
\i extracted_data/legal_leave_approval_chain.sql
\i extracted_data/health_leave_approval_chain.sql
\i extracted_data/eng_leave_approval_chain.sql
\i extracted_data/planning_leave_approval_chain.sql
\i extracted_data/ict_leave_approval_chain.sql

-- ============================================
-- LEVEL 8: TRANSACTION TABLES
-- ============================================
\echo 'Importing Level 8: Transactions...'

-- Leave Management
\i extracted_data/leave_requests.sql
\i extracted_data/leave_balances.sql
\i extracted_data/leave_policy.sql
\i extracted_data/leave_resumption.sql
\i extracted_data/vacation_allowances.sql

-- Mothers Day Tracking
\i extracted_data/mothers_day_leave_tracking.sql
\i extracted_data/mothers_day_acknowledgments.sql
\i extracted_data/mothers_day_notification_log.sql

-- Notifications
\i extracted_data/notification_queue.sql
\i extracted_data/notification_history.sql
\i extracted_data/hr_recipients.sql

-- SMS Gateway
\i extracted_data/sms_gateway_config.sql
\i extracted_data/sms_message_parts.sql
\i extracted_data/sms_delivery_log.sql

-- Job Descriptions
\i extracted_data/job_description_documents.sql
\i extracted_data/jd_upload_queue.sql
\i extracted_data/jd_review_queue.sql

-- ============================================
-- LEVEL 9: VERIFICATION & FLOW TABLES
-- ============================================
\echo 'Importing Level 9: Verification & Flow...'

-- Leave Flow Verification
\i extracted_data/finance_leave_flow_verification.sql
\i extracted_data/legal_leave_flow_verification.sql
\i extracted_data/health_leave_flow_verification.sql
\i extracted_data/eng_leave_flow_verification.sql
\i extracted_data/planning_leave_flow_verification.sql
\i extracted_data/ict_leave_flow_verification.sql

-- Organization Charts
\i extracted_data/finance_org_chart.sql
\i extracted_data/legal_org_chart.sql
\i extracted_data/health_org_chart.sql
\i extracted_data/eng_org_chart.sql
\i extracted_data/eng_organization_chart.sql
\i extracted_data/planning_org_chart.sql

-- Staff Distribution
\i extracted_data/finance_staff_by_section.sql
\i extracted_data/legal_staff_by_section.sql
\i extracted_data/health_staff_by_unit.sql
\i extracted_data/eng_staff_by_unit.sql
\i extracted_data/planning_staff_by_unit.sql

-- Summary Tables
\i extracted_data/finance_summary_by_council.sql
\i extracted_data/legal_summary_by_council.sql
\i extracted_data/health_summary_by_council.sql
\i extracted_data/eng_summary_by_council.sql
\i extracted_data/planning_summary_by_council.sql

-- ============================================
-- LEVEL 10: AUDIT & LOGS
-- ============================================
\echo 'Importing Level 10: Audit & Logs...'

\i extracted_data/audit_log.sql
\i extracted_data/immutable_audit_log.sql

-- ============================================
-- LEVEL 11: VIEWS (ALWAYS LAST)
-- ============================================
\echo 'Importing Level 11: Views...'

\i extracted_data/vw_city_leave_approval_flow.sql
\i extracted_data/vw_city_organization_chart.sql
\i extracted_data/vw_city_positions_summary.sql
\i extracted_data/vw_council_community_services.sql
\i extracted_data/vw_eligible_female_employees.sql
\i extracted_data/vw_employee_eligibility.sql
\i extracted_data/vw_employee_leave_history.sql
\i extracted_data/vw_employee_mothers_day_history.sql
\i extracted_data/vw_eng_hierarchy_by_council.sql
\i extracted_data/vw_eng_org_chart.sql
\i extracted_data/vw_eng_summary_by_council.sql
\i extracted_data/vw_eng_supervisors.sql
\i extracted_data/vw_establishment_by_council.sql
\i extracted_data/vw_fire_service_hierarchy.sql
\i extracted_data/vw_hr_notifications.sql
\i extracted_data/vw_hr_recipients.sql
\i extracted_data/vw_kitwe_community_complete.sql
\i extracted_data/vw_mechanic_positions.sql
\i extracted_data/vw_monthly_leave_taken.sql
\i extracted_data/vw_monthly_mothers_day_report.sql
\i extracted_data/vw_mothers_day_engineering.sql
\i extracted_data/vw_mothers_day_engineering_approvers.sql
\i extracted_data/vw_mothers_day_hr_summary.sql
\i extracted_data/vw_mothers_day_monthly_report.sql
\i extracted_data/vw_mothers_day_notification_log.sql
\i extracted_data/vw_mothers_day_pending_acknowledgments.sql
\i extracted_data/vw_mothers_day_position_approvers.sql
\i extracted_data/vw_municipal_leave_approval_flow.sql
\i extracted_data/vw_municipal_organization_chart.sql
\i extracted_data/vw_municipal_positions_summary.sql
\i extracted_data/vw_notification_preferences.sql
\i extracted_data/vw_org_chart.sql
\i extracted_data/vw_org_chart_data.sql
\i extracted_data/vw_org_dna.sql
\i extracted_data/vw_pending_sms_notifications.sql
\i extracted_data/vw_pending_supervisor_approvals.sql
\i extracted_data/vw_position_hierarchy.sql
\i extracted_data/vw_position_migration_status.sql
\i extracted_data/vw_sms_ready_notifications.sql
\i extracted_data/vw_staff_by_level.sql
\i extracted_data/vw_supervisor_assignments.sql
\i extracted_data/vw_supervisor_workload.sql
\i extracted_data/vw_town_organization_chart.sql

COMMIT;

-- Re-enable triggers
SET session_replication_role = 'origin';

\echo '========================================'
\echo 'IMPORT COMPLETE!'
\echo '========================================'
\echo 'Total Tables Imported: 137'
\echo 'Total Views Created: 43'
\echo 'Total Database Objects: 180'
\echo '========================================'
