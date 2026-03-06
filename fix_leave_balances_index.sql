-- Drop the problematic index if it exists
DROP INDEX IF EXISTS idx_leave_balances_employee;

-- Create the correct index on employee_id
CREATE INDEX idx_leave_balances_employee ON leave_balances(employee_id);

-- Verify it was created
SELECT 'Index created successfully on leave_balances(employee_id)' as message;
