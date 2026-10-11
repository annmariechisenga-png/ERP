-- V54 -- Add employee hierarchy and policy resolution indexes.

CREATE INDEX IF NOT EXISTS idx_erp_employee_supervisor_id ON erp_employee(supervisor_id);
-- idx_erp_employee_hod_id removed: erp_employee.hod_id does not exist in current schema
-- idx_erp_employee_team_id removed: erp_employee.team_id does not exist in current schema
CREATE INDEX IF NOT EXISTS idx_erp_employee_salary_scale ON erp_employee(salary_scale);
CREATE INDEX IF NOT EXISTS idx_leave_policy_leave_type_division ON leave_policy(leave_type, division);
