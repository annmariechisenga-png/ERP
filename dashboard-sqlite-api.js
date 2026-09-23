const express = require('express');
const cors = require('cors');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

const dbPath = path.resolve(__dirname, 'hr_platform.db');
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) console.error('Database connection error:', err);
    else console.log('Connected to hr_platform.db');
});

// Robust query wrapper
const query = (sql, params = []) => new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => { 
        if (err) {
            console.error(`Query Error [${sql}]:`, err);
            reject(err);
        } else resolve(rows); 
    });
});

const getOne = (sql, params = []) => new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => { 
        if (err) {
            console.error(`GetOne Error [${sql}]:`, err);
            reject(err);
        } else resolve(row); 
    });
});

// Seed demo data for the prototype
async function seedDemoData() {
    try {
        // Use basic SQL to ensure tables exist
        db.serialize(() => {
            db.run(`CREATE TABLE IF NOT EXISTS leave_balances (employee_id TEXT PRIMARY KEY, local_leave_balance REAL, vacation_leave_balance REAL)`);
            db.run(`CREATE TABLE IF NOT EXISTS leave_requests (request_id INTEGER PRIMARY KEY AUTOINCREMENT, employee_id TEXT, leave_type TEXT, requested_days INTEGER, start_date DATE, end_date DATE, resumption_date DATE, status TEXT DEFAULT 'Pending', current_approver_id TEXT)`);
            
            // Check leave types
            db.get(`SELECT count(*) as count FROM leave_types`, [], (err, row) => {
                if (err) {
                    console.error('Error checking leave_types, creating table...');
                    db.run(`CREATE TABLE IF NOT EXISTS leave_types (leave_type_id INTEGER PRIMARY KEY AUTOINCREMENT, leave_type_code TEXT UNIQUE NOT NULL, leave_type_name TEXT NOT NULL, applicable_to TEXT)`);
                } else if (row.count <= 1) {
                    console.log('Inserting default leave types...');
                    const stmt = db.prepare(`INSERT OR IGNORE INTO leave_types (leave_type_code, leave_type_name, applicable_to) VALUES (?, ?, ?)`);
                    stmt.run('ANNUAL', 'Annual Leave', 'All');
                    stmt.run('SICK', 'Sick Leave', 'All');
                    stmt.run('COMPASSIONATE', 'Compassionate Leave', 'All');
                    stmt.run('MATERNITY', 'Maternity Leave', 'Female Only');
                    stmt.run('PATERNITY', 'Paternity Leave', 'Male Only');
                    stmt.run('STUDY', 'Study Leave', 'All');
                    stmt.finalize();
                }
            });

            db.run(`INSERT OR IGNORE INTO leave_balances (employee_id, local_leave_balance, vacation_leave_balance) VALUES ('ZM09-CHL-2024-000001', 24.5, 10.0)`);
        });
    } catch (e) {
        console.error('Seed error:', e);
    }
}

seedDemoData();

// GET /api/user-stats/:employeeId
app.get('/api/user-stats/:employeeId', async (req, res) => {
    const { employeeId } = req.params;
    try {
        const emp = await getOne(`SELECT * FROM employees WHERE employee_id = ? OR nrc_number = ?`, [employeeId, employeeId]);
        if (!emp) return res.status(404).json({ success: false, error: 'Employee not found' });

        const leave = await getOne(`SELECT * FROM leave_balances WHERE employee_id = ?`, [emp.employee_id]);
        const supervisor = await getOne(`
            SELECT e.name FROM approval_chain ac 
            JOIN employees e ON ac.supervisor_id = e.employee_id 
            WHERE ac.employee_id = ?`, [emp.employee_id]);

        const jd = await getOne(`SELECT * FROM job_description_documents WHERE position_title = ? OR position_standard_id = ?`, [emp.position, emp.establishment_position_code]);

        res.json({
            success: true,
            stats: {
                id: emp.employee_id,
                name: emp.name,
                position: emp.position,
                department: emp.establishment_department || emp.department,
                leaveBalance: leave ? leave.local_leave_balance : 0,
                lastNetPay: 14250.00,
                division: emp.salary_scale_code && emp.salary_scale_code.startsWith('LGSS') ? 
                          (parseInt(emp.salary_scale_code.substring(4)) <= 7 ? 'I' : 'II') : 'III',
                jd: jd ? { title: jd.position_title, path: jd.file_path } : null,
                supervisor: supervisor ? supervisor.name : 'Immediate Supervisor'
            }
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/leave-types
app.get('/api/leave-types', async (req, res) => {
    try {
        const rows = await query(`SELECT leave_type_code as code, leave_type_name as name FROM leave_types`);
        res.json({ success: true, types: rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/leave-request
app.post('/api/leave-request', async (req, res) => {
    const { employeeId, leaveType, startDate, endDate } = req.body;
    const days = Math.ceil((new Date(endDate) - new Date(startDate)) / (1000 * 60 * 60 * 24)) + 1;
    try {
        db.run(`INSERT INTO leave_requests (employee_id, leave_type, start_date, end_date, requested_days, status) VALUES (?, ?, ?, ?, ?, 'Pending')`,
            [employeeId, leaveType, startDate, endDate, days], function(err) {
                if (err) res.status(500).json({ success: false, error: err.message });
                else res.json({ success: true, message: `Request for ${days} days submitted.`, days });
            });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// POST /api/overtime-request
app.post('/api/overtime-request', async (req, res) => {
    const { employeeId, date, startTime, endTime, reason, type } = req.body;
    const start = new Date(`${date}T${startTime}`);
    const end = new Date(`${date}T${endTime}`);
    const hours = Math.max(0, (end - start) / (1000 * 60 * 60));
    
    try {
        const emp = await getOne(`SELECT * FROM employees WHERE employee_id = ?`, [employeeId]);
        const scale = await getOne(`SELECT revised_monthly_k FROM salary_scales_2026 WHERE grade = ?`, [emp.salary_scale_code]);
        const monthlySalary = scale ? scale.revised_monthly_k : 3724.67;
        const hourlyRate = (monthlySalary / 208);
        const multiplier = type === 'sunday' || type === 'public_holiday' ? 2.0 : 1.5;
        const amount = hours * hourlyRate * multiplier;

        db.run(`INSERT INTO overtime_requests (employee_id, employee_name, overtime_date, start_time, end_time, hours_worked, overtime_type, hourly_rate, rate_multiplier, amount_earned, reason, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending_supervisor')`,
            [employeeId, emp.name, date, startTime, endTime, hours, type, hourlyRate, multiplier, amount, reason], function(err) {
                if (err) res.status(500).json({ success: false, error: err.message });
                else res.json({ success: true, message: `Overtime request for ${hours.toFixed(1)} hours (ZMW ${amount.toFixed(2)}) submitted.`, hours, amount });
            });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// GET /api/finance-summary
app.get('/api/finance-summary', (req, res) => {
    res.json({
        success: true,
        revenueYTD: 4250000.00,
        expenditureYTD: 3120000.00,
        bankBalances: [
            { account: 'Operating Account (Main)', bank: 'Zanaco', balance: 1250400.50, status: 'Active' },
            { account: 'Payroll Account', bank: 'Absa', balance: 450200.00, status: 'Active' },
            { account: 'Revenue Collection', bank: 'Standard Chartered', balance: 890150.75, status: 'Active' }
        ],
        indebtedness: {
            retirees: 850000.00,
            statutoryObligations: 1200500.00,
            settlingInAllowances: 150000.00
        }
    });
});

// GET /api/ledger
app.get('/api/ledger', (req, res) => {
    res.json({
        success: true,
        entries: [
            { id: 'L-001', date: '2026-05-15', description: 'Monthly Revenue Collection', category: 'Revenue', amount: 450000.00, type: 'CR' },
            { id: 'L-002', date: '2026-05-16', description: 'Salary Disbursement - May 2026', category: 'Payroll', amount: 1200000.00, type: 'DR' },
            { id: 'L-003', date: '2026-05-17', description: 'Statutory Remittance (NAPSA)', category: 'Obligation', amount: 250000.00, type: 'DR' },
            { id: 'L-004', date: '2026-05-18', description: 'Utility Payment (ZESCO)', category: 'Utility', amount: 12400.00, type: 'DR' },
            { id: 'L-005', date: '2026-05-19', description: 'Settling-in Allowance - New Staff', category: 'Allowance', amount: 15000.00, type: 'DR' }
        ]
    });
});

app.listen(port, () => { console.log(`ERP Dashboard API running on http://localhost:${port}`); });
