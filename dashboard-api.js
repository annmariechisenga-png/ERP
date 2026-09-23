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
