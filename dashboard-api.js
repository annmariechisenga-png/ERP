const express = require('express');
const { Pool } = require('pg');
const app = express();
const port = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'localgov_erp',
    password: '',
    port: 5432,
});

// GET /api/pending-approvals
app.get('/api/pending-approvals', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT 
                sa.advance_id,
                sa.reference_number,
                sa.employee_id,
                e.name AS employee_name,
                sa.amount_requested,
                sa.repayment_months,
                sa.monthly_deduction,
                sa.reason,
                sa.application_date,
                sa.status
            FROM salary_advances sa
            JOIN employees e ON sa.employee_id = e.employee_id
            WHERE sa.status = 'pending'
            ORDER BY sa.application_date ASC
        `);
        
        res.json({
            success: true,
            count: result.rows.length,
            approvals: result.rows
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: error.message });
    }
});

// GET /api/notifications
app.get('/api/notifications', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT id, type, title, message, link, reference_id, is_read, created_at
            FROM notifications
            ORDER BY created_at DESC
        `);
        
        res.json({
            success: true,
            count: result.rows.length,
            notifications: result.rows
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: error.message });
    }
});

// GET /api/dashboard-summary
app.get('/api/dashboard-summary', async (req, res) => {
    try {
        const pendingResult = await pool.query("SELECT COUNT(*) as count FROM salary_advances WHERE status = 'pending'");
        const activeResult = await pool.query("SELECT COUNT(*) as count, COALESCE(SUM(remaining_balance), 0) as total FROM salary_advances WHERE status = 'active'");
        
        res.json({
            success: true,
            pending_approvals: parseInt(pendingResult.rows[0].count),
            active_advances: parseInt(activeResult.rows[0].count),
            total_outstanding: parseFloat(activeResult.rows[0].total)
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: error.message });
    }
});

// POST /api/approve-salary-advance
app.post('/api/approve-salary-advance', async (req, res) => {
    const { advance_id, approved_amount, approver_notes } = req.body;
    
    if (!advance_id) {
        return res.status(400).json({ error: 'advance_id is required' });
    }
    
    try {
        const advanceResult = await pool.query(
            'SELECT * FROM salary_advances WHERE advance_id = $1 AND status = $2',
            [advance_id, 'pending']
        );
        
        if (advanceResult.rows.length === 0) {
            return res.status(404).json({ error: 'Advance request not found' });
        }
        
        const advance = advanceResult.rows[0];
        const finalAmount = approved_amount || advance.amount_requested;
        
        const today = new Date();
        const dayOfMonth = today.getDate();
        let deductionStartMonth;
        
        if (dayOfMonth <= 15) {
            deductionStartMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        } else {
            deductionStartMonth = new Date(today.getFullYear(), today.getMonth() + 1, 1);
        }
        
        await pool.query(
            `UPDATE salary_advances
             SET amount_approved = $1, status = 'approved', approver_notes = $2,
                 approved_at = NOW(), deduction_start_month = $3, updated_at = NOW()
             WHERE advance_id = $4`,
            [finalAmount, approver_notes, deductionStartMonth, advance_id]
        );
        
        res.json({
            success: true,
            message: 'Salary advance approved successfully',
            advance_id: advance_id,
            reference: advance.reference_number
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: error.message });
    }
});

// POST /api/reject-salary-advance
app.post('/api/reject-salary-advance', async (req, res) => {
    const { advance_id, rejection_reason } = req.body;
    
    if (!advance_id || !rejection_reason) {
        return res.status(400).json({ error: 'advance_id and rejection_reason are required' });
    }
    
    try {
        const advanceResult = await pool.query(
            'SELECT * FROM salary_advances WHERE advance_id = $1 AND status = $2',
            [advance_id, 'pending']
        );
        
        if (advanceResult.rows.length === 0) {
            return res.status(404).json({ error: 'Advance request not found' });
        }
        
        const advance = advanceResult.rows[0];
        
        await pool.query(
            `UPDATE salary_advances
             SET status = 'rejected', rejection_reason = $1, approved_at = NOW(), updated_at = NOW()
             WHERE advance_id = $2`,
            [rejection_reason, advance_id]
        );
        
        res.json({
            success: true,
            message: 'Salary advance rejected',
            advance_id: advance_id,
            reference: advance.reference_number
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({ error: error.message });
    }
});

app.listen(port, () => {
    console.log('Dashboard API running on http://localhost:' + port);
});

// GET /api/leave-types
app.get('/api/leave-types', (req, res) => {
    res.json({
        success: true,
        types: [
            { code: 'ANNUAL',        name: 'Annual Leave (30-day notice required)' },
            { code: 'VACATION',      name: 'Vacation Leave (30-day notice required)' },
            { code: 'LOCAL',         name: 'Local Leave' },
            { code: 'SICK',          name: 'Sick Leave' },
            { code: 'MATERNITY',     name: 'Maternity Leave (98 days fixed)' },
            { code: 'PATERNITY',     name: 'Paternity Leave (10 days fixed)' },
            { code: 'COMPASSIONATE', name: 'Compassionate Leave' },
            { code: 'FAMILY_CARE',   name: 'Family Care Leave (max 3 days/year)' },
            { code: 'MOTHERS_DAY',   name: "Mother's Day Leave (1 day/month, female only)" },
            { code: 'UNPAID',        name: 'Unpaid Leave (max 1 year)' }
        ]
    });
});

// POST /api/leave-request
app.post('/api/leave-request', async (req, res) => {
    const { employeeId, leaveType, startDate, endDate, reason, compassionateRelation } = req.body;
    if (!employeeId || !leaveType || !startDate || !endDate || !reason) {
        return res.status(400).json({ success: false, error: 'employeeId, leaveType, startDate, endDate and reason are required.' });
    }
    const ADVANCE_NOTICE_TYPES = ['ANNUAL', 'VACATION'];
    if (ADVANCE_NOTICE_TYPES.includes(leaveType)) {
        const today = new Date(); today.setHours(0, 0, 0, 0);
        const start = new Date(startDate);
        const diffDays = Math.floor((start - today) / (1000 * 60 * 60 * 24));
        if (diffDays < 30) {
            return res.status(422).json({ success: false, error: 'Annual/Vacation leave requires at least 30 days advance notice before the start date.' });
        }
    }
    try {
        const empResult = await pool.query(
            `SELECT e.id FROM erp_employee e
             JOIN employees emp ON emp.employee_id::text = e.employee_code
             WHERE emp.employee_id = $1`,
            [employeeId]
        );
        if (!empResult.rows[0]) return res.status(404).json({ success: false, error: 'Employee not found.' });
        const erpEmployeeId = empResult.rows[0].id;
        const result = await pool.query(
            `INSERT INTO erp_leave_request
                (employee_id, leave_type, status, start_date, end_date, reason, compassionate_relation,
                 days_requested, created_at)
             VALUES ($1, $2, 'PENDING', $3, $4, $5, $6,
                 (SELECT COUNT(*) FROM generate_series($3::date, $4::date, '1 day'::interval) g
                  WHERE EXTRACT(DOW FROM g) NOT IN (0,6)),
                 NOW())
             RETURNING id, days_requested`,
            [erpEmployeeId, leaveType, startDate, endDate, reason, compassionateRelation || null]
        );
        const row = result.rows[0];
        res.json({ success: true, message: `Leave request submitted. Reference: LV-${row.id}`, referenceId: row.id, daysRequested: row.days_requested });
    } catch (err) {
        console.error('Leave request error:', err);
        res.status(500).json({ success: false, error: err.message });
    }
});

// GET /api/leave-status/:employeeId
app.get('/api/leave-status/:employeeId', async (req, res) => {
    try {
        const empResult = await pool.query(
            `SELECT e.id FROM erp_employee e
             JOIN employees emp ON emp.employee_id::text = e.employee_code
             WHERE emp.employee_id = $1`,
            [req.params.employeeId]
        );
        if (!empResult.rows[0]) return res.status(404).json({ success: false, error: 'Employee not found.' });
        const result = await pool.query(
            `SELECT id, leave_type, start_date, end_date, days_requested, status, created_at
             FROM erp_leave_request WHERE employee_id = $1 ORDER BY created_at DESC LIMIT 10`,
            [empResult.rows[0].id]
        );
        res.json({ success: true, requests: result.rows });
    } catch (err) {
        res.status(500).json({ success: false, error: err.message });
    }
});

// POST /api/overtime-request
app.post('/api/overtime-request', async (req, res) => {
    const { employeeId, overtimeDate, startTime, endTime, overtimeType, reason } = req.body;
    if (!employeeId || !overtimeDate || !startTime || !endTime || !overtimeType || !reason) {
        return res.status(400).json({ success: false, error: 'All fields are required.' });
    }
    const multipliers = { normal: 1.112, sunday: 2.0, holiday: 2.0 };
    const multiplier = multipliers[overtimeType];
    if (!multiplier) return res.status(400).json({ success: false, error: 'Invalid overtime type.' });
    try {
        const salaryResult = await pool.query(
            `SELECT e.employee_id, e.name, snv.monthly_basic, ee.division
             FROM employees e
             JOIN employee_salary_notch esn ON e.employee_id = esn.employee_id AND esn.is_active = true
             JOIN salary_notch_values snv ON esn.scale_code = snv.scale_code AND esn.notch_no = snv.notch_no AND esn.effective_from = snv.effective_from
             LEFT JOIN erp_employee ee ON ee.employee_code = e.employee_id::text
             WHERE e.employee_id = $1`,
            [employeeId]
        );
        if (!salaryResult.rows[0]) return res.status(404).json({ success: false, error: 'Employee salary record not found.' });
        const s = salaryResult.rows[0];

        // Division I employees are not eligible for overtime
        if (s.division === 'I') {
            return res.status(403).json({ success: false, error: 'Division I employees are not entitled to overtime. Overtime applies to Divisions II, III and IV only.' });
        }

        const hourlyRate = s.monthly_basic / 176;
        const [sh, sm] = startTime.split(':').map(Number);
        const [eh, em] = endTime.split(':').map(Number);
        const hoursWorked = ((eh * 60 + em) - (sh * 60 + sm)) / 60;
        if (hoursWorked <= 0) return res.status(400).json({ success: false, error: 'End time must be after start time.' });
        const amountEarned = Math.round(hoursWorked * multiplier * hourlyRate * 100) / 100;
        const insert = await pool.query(
            `INSERT INTO overtime_requests
                (employee_id, employee_name, division, overtime_date, start_time, end_time,
                 hours_worked, overtime_type, hourly_rate, rate_multiplier, amount_earned,
                 reason, is_self_request, status, created_at)
             VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,1,'pending_supervisor',NOW())
             RETURNING id`,
            [employeeId, s.name, s.division || 'Unknown', overtimeDate, startTime, endTime,
             hoursWorked, overtimeType, hourlyRate, multiplier, amountEarned, reason]
        );
        res.json({
            success: true,
            message: `Overtime request submitted. Reference: OT-${insert.rows[0].id}`,
            referenceId: insert.rows[0].id,
            hoursWorked: hoursWorked.toFixed(2),
            estimatedAmount: `ZMW ${amountEarned.toFixed(2)}`
        });
    } catch (err) {
        console.error('Overtime request error:', err);
        res.status(500).json({ success: false, error: err.message });
    }
});
