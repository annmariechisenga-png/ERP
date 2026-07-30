const express = require('express');
const { Pool } = require('pg');
const app = express();

// PostgreSQL connection with environment variables
const pool = new Pool({
    host: process.env.POSTGRES_HOST || 'localhost',
    port: process.env.POSTGRES_PORT || 5432,
    database: process.env.POSTGRES_DB || 'hr_platform',
    user: process.env.POSTGRES_USER || 'postgres',
    password: process.env.POSTGRES_PASSWORD || 'marshaerp2026'
});

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const sessions = {};

// Session cleanup - remove sessions older than 30 minutes
setInterval(() => {
    const now = Date.now();
    const thirtyMinutes = 30 * 60 * 1000;
    for (const sessionId in sessions) {
        if (sessions[sessionId].timestamp && (now - sessions[sessionId].timestamp > thirtyMinutes)) {
            delete sessions[sessionId];
            console.log('Cleaned up expired session:', sessionId);
        }
    }
}, 5 * 60 * 1000); // Run every 5 minutes

function normalizeDateDMY(dateStr) {
    const normalized = (dateStr || '').trim().replace(/[.\/\-]/g, '');
    return /^\d{8}$/.test(normalized) ? normalized : null;
}

function isValidDateDMY(dateStr) {
    const normalized = normalizeDateDMY(dateStr);
    if (!normalized) return false;
    const day = parseInt(normalized.slice(0, 2), 10);
    const month = parseInt(normalized.slice(2, 4), 10);
    const year = parseInt(normalized.slice(4, 8), 10);
    const date = new Date(`${year.toString().padStart(4, '0')}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`);
    return date.getFullYear() === year && date.getMonth() + 1 === month && date.getDate() === day;
}

function normalizeTimeHHMM(timeStr) {
    const normalized = (timeStr || '').trim().replace(':', '');
    return /^\d{4}$/.test(normalized) ? normalized : null;
}

function isValidTimeHHMM(timeStr) {
    const normalized = normalizeTimeHHMM(timeStr);
    if (!normalized) return false;
    const hours = parseInt(normalized.slice(0, 2), 10);
    const minutes = parseInt(normalized.slice(2, 4), 10);
    return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59;
}

function timeToMinutes(timeStr) {
    const normalized = normalizeTimeHHMM(timeStr);
    return parseInt(normalized.slice(0, 2), 10) * 60 + parseInt(normalized.slice(2, 4), 10);
}

function getOvertimeTypeDetails(typeKey) {
    const types = {
        '1': { type: 'normal', multiplier: 1.112, text: 'Weekday (1.112x)' },
        '2': { type: 'sunday', multiplier: 2.0, text: 'Sunday (2x)' },
        '3': { type: 'holiday', multiplier: 2.0, text: 'Public Holiday (2x)' }
    };
    return types[typeKey] || null;
}

function getMainMenuText() {
    return 'CON Local Authority Employee\n' +
           '1. Check Leave Balance\n' +
           '2. Submit Leave Request\n' +
           '3. Check Pending Leave Status\n' +
           '4. Salary Advance\n' +
           '5. Request Introductory Letter\n' +
           '6. My Performance Score\n' +
           '7. Overtime Request\n' +
           '0. Exit';
}

async function submitOvertimeRequest(session, reasonValue, res, sessionId) {
    session.step = 'overtime_submit';
    sessions[sessionId] = session;

    try {
        const salaryResult = await pool.query(
            `SELECT e.employee_id, e.name, e.salary_scale, esn.notch_no, snv.monthly_basic
             FROM employees e
             JOIN employee_salary_notch esn ON e.employee_id = esn.employee_id AND esn.is_active = true
             JOIN salary_notch_values snv ON esn.scale_code = snv.scale_code AND esn.notch_no = snv.notch_no AND esn.effective_from = snv.effective_from
             WHERE e.employee_id = $1`,
            [session.employee_id]
        );

        const salaryData = salaryResult.rows[0];
        let response = '';
        if (!salaryData) {
            response = 'END Salary information not found. Please contact HR.';
            delete sessions[sessionId];
            console.log('Sending response at step: salary_lookup_error');
            if (res.headersSent) return;
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        const hourlyRate = salaryData.monthly_basic / 176;
        const startMinutes = timeToMinutes(session.start_time);
        const endMinutes = timeToMinutes(session.end_time);
        const durationMinutes = endMinutes - startMinutes;
        const hoursWorked = durationMinutes / 60;
        session.hours_worked = hoursWorked;
        const amountEarned = Math.round(hoursWorked * session.rate_multiplier * hourlyRate * 100) / 100;

        const overtimeDate = new Date(session.overtime_date.replace(/(\d{2})(\d{2})(\d{4})/, '$3-$2-$1'));
        const day = overtimeDate.getDate();
        const month = overtimeDate.getMonth() + 1;
        const year = overtimeDate.getFullYear();
        const monthNames = ['January','February','March','April','May','June','July','August','September','October','November','December'];

        let paymentMsg = '';
        if (day <= 15) {
            paymentMsg = 'Payment will be processed in ' + monthNames[month-1] + ' ' + year + ' (on/before 15th cutoff)';
        } else {
            let nextMonth = month + 1;
            let nextYear = year;
            if (nextMonth > 12) {
                nextMonth = 1;
                nextYear++;
            }
            paymentMsg = 'After 15th cutoff. Payment will be carried over to ' + monthNames[nextMonth-1] + ' ' + nextYear;
        }

        let division = 'Unknown';
        if (salaryData.salary_scale && salaryData.salary_scale.match(/G[1-3]/i)) {
            division = 'Division IV';
        } else if (salaryData.salary_scale && salaryData.salary_scale.match(/LGSS1[3-9]/i)) {
            division = 'Division III';
        } else if (salaryData.salary_scale && salaryData.salary_scale.match(/LGSS0[8-9]|LGSS1[0-2]/i)) {
            division = 'Division II';
        }

        const insertResult = await pool.query(
            `INSERT INTO overtime_requests (
                employee_id, employee_name, salary_scale, division, notch_no, monthly_salary,
                overtime_date, start_time, end_time, hours_worked, overtime_type,
                hourly_rate, rate_multiplier, amount_earned, reason,
                requested_by_employee_id, requested_by_name, requested_by_role,
                is_self_request, status, created_at
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21) RETURNING id`,
            [
                session.employee_id,
                salaryData.name,
                salaryData.salary_scale,
                division,
                salaryData.notch_no,
                salaryData.monthly_basic,
                session.overtime_date,
                session.start_time,
                session.end_time,
                hoursWorked,
                session.overtime_type,
                hourlyRate,
                session.rate_multiplier,
                amountEarned,
                reasonValue,
                session.requested_by_id,
                session.requested_by_name,
                session.requested_by_role,
                (session.requested_by_role === 'employee') ? 1 : 0,
                'pending_supervisor',
                new Date().toISOString()
            ]
        );

        response = 'END ✅ Overtime request submitted successfully!\n\n';
        response += 'Employee: ' + salaryData.name + '\n';
        response += 'Date: ' + session.overtime_date + '\n';
        response += 'Time: ' + session.start_time + ' - ' + session.end_time + ' (' + hoursWorked.toFixed(1) + ' hrs)\n';
        response += 'Type: ' + session.overtime_type.toUpperCase() + ' (' + session.rate_text + ')\n';
        response += 'Hourly Rate: K' + hourlyRate.toFixed(2) + '\n';
        response += 'Rate Multiplier: ' + session.rate_multiplier + 'x\n';
        response += 'Estimated Amount: K' + amountEarned.toFixed(2) + '\n\n';
        response += 'Reason: ' + reasonValue + '\n\n';
        response += paymentMsg + '\n\n';
        response += 'Awaiting approval: Supervisor -> HOD -> Principal Officer -> Audit\n\n';
        response += 'Reference: OT-' + insertResult.rows[0].id;

        delete sessions[sessionId];
        console.log('Sending response at step: overtime_submit_success');
        if (res.headersSent) return;
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    } catch (err) {
        console.error('DB Error:', err);
        const response = 'END Error submitting overtime request. Please try again.';
        delete sessions[sessionId];
        console.log('Sending response at step: overtime_submit_error');
        if (res.headersSent) return;
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
}

app.post('/usd', async (req, res) => {
    try {
        console.log('Request:', req.body);

        const { sessionId, phoneNumber, text } = req.body;
        let response = '';
        const rawText = (text || '').trim();
        const inputParts = rawText === '' ? [''] : rawText.split('*').map(part => part.trim());
        while (inputParts.length > 1 && inputParts[inputParts.length - 1] === '') {
            inputParts.pop();
        }

        if (!sessions[sessionId]) {
            sessions[sessionId] = { step: 'menu', timestamp: Date.now() };
        } else {
            sessions[sessionId].timestamp = Date.now();
        }

        const overtimeStates = ['overtime_date', 'overtime_subordinate', 'overtime_start_time', 'overtime_end_time', 'overtime_type', 'overtime_reason'];
        const isOngoingOvertime = overtimeStates.includes(sessions[sessionId].step);
        const flowParts = isOngoingOvertime && inputParts[0] === '7' && inputParts.length > 1 ? inputParts.slice(1) : inputParts;
        const currentInput = flowParts[flowParts.length - 1];
        const menuInput = flowParts[0];

        console.log('USSD request', {
            sessionId,
            phoneNumber,
            rawText,
            flowParts,
            menuInput,
            currentInput,
            step: sessions[sessionId].step || 'none'
        });

    // ========== MAIN MENU ==========
    if (rawText === '') {
        response = 'CON ';
        response += 'Local Authority Employee\n';
        response += '1. Check Leave Balance\n';
        response += '2. Submit Leave Request\n';
        response += '3. Check Pending Leave Status\n';
        response += '4. Salary Advance\n';
        response += '5. Request Introductory Letter\n';
        response += '6. My Performance Score\n';
        response += '7. Overtime Request\n';
        response += '0. Exit';
        res.send(response);
        return;
    }

    // ========== OPTION 1: Leave Balance ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '1') {
        try {
            const empResult = await pool.query(
                `SELECT e.id, e.division
                 FROM erp_employee e
                 JOIN employees emp ON emp.employee_id::text = e.employee_code
                 WHERE emp.phone = $1`,
                [phoneNumber]
            );
            const emp = empResult.rows[0];
            if (!emp) {
                response = 'END Employee record not found. Contact HR.';
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            const balResult = await pool.query(
                `SELECT local_leave_balance, vacation_leave_balance
                 FROM leave_balances WHERE employee_id = $1`,
                [emp.id]
            );
            const bal = balResult.rows[0];
            const local = bal ? (bal.local_leave_balance || 0) : 30;
            const vacation = bal ? (bal.vacation_leave_balance || 0) : 30;
            const division = emp.division ? 'Division ' + emp.division : 'Unknown';
            response = 'END Leave Balances (' + division + ')\n';
            response += 'Local Leave:   ' + local + ' days\n';
            response += 'Vacation Leave: ' + vacation + ' days';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        } catch (err) {
            console.error('Leave balance error:', err);
            response = 'END Error fetching balance. Try again.';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
    }

    // ========== OPTION 2: Leave Request ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '2') {
        sessions[sessionId].step = 'leave_type';
        response = 'CON Select Leave Type:\n';
        response += '1. Annual Leave\n';
        response += '2. Vacation Leave\n';
        response += '3. Local Leave\n';
        response += '4. Sick Leave\n';
        response += '5. Maternity Leave\n';
        response += '6. Paternity Leave\n';
        response += '7. Compassionate Leave\n';
        response += '8. Family Care Leave\n';
        response += '9. Mother\'s Day Leave\n';
        response += '0. Back';
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    if (sessions[sessionId].step === 'leave_type' && currentInput !== '') {
        if (currentInput === '0') {
            sessions[sessionId].step = 'menu';
            response = getMainMenuText();
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        const leaveTypeMap = {
            '1': 'ANNUAL', '2': 'VACATION', '3': 'LOCAL',
            '4': 'SICK', '5': 'MATERNITY', '6': 'PATERNITY',
            '7': 'COMPASSIONATE', '8': 'FAMILY_CARE', '9': 'MOTHERS_DAY'
        };
        const leaveTypeNames = {
            'ANNUAL': 'Annual', 'VACATION': 'Vacation', 'LOCAL': 'Local',
            'SICK': 'Sick', 'MATERNITY': 'Maternity', 'PATERNITY': 'Paternity',
            'COMPASSIONATE': 'Compassionate', 'FAMILY_CARE': 'Family Care', 'MOTHERS_DAY': "Mother's Day"
        };
        const selectedType = leaveTypeMap[currentInput];
        if (!selectedType) {
            response = 'CON Invalid selection. Select Leave Type:\n';
            response += '1. Annual  2. Vacation  3. Local\n';
            response += '4. Sick    5. Maternity 6. Paternity\n';
            response += '7. Compassionate  8. Family Care\n';
            response += '9. Mother\'s Day\n0. Back';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        sessions[sessionId].leave_type = selectedType;
        sessions[sessionId].leave_type_name = leaveTypeNames[selectedType];
        sessions[sessionId].step = 'leave_start_date';
        response = 'CON ' + leaveTypeNames[selectedType] + ' Leave\n';
        response += 'Enter start date (DD.MM.YYYY):\n';
        response += 'Example: 01.07.2026\n0. Back';
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    if (sessions[sessionId].step === 'leave_start_date' && currentInput !== '') {
        if (currentInput === '0') {
            sessions[sessionId].step = 'leave_type';
            response = 'CON Select Leave Type:\n';
            response += '1. Annual  2. Vacation  3. Local\n';
            response += '4. Sick    5. Maternity 6. Paternity\n';
            response += '7. Compassionate  8. Family Care\n';
            response += '9. Mother\'s Day\n0. Back';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        if (!isValidDateDMY(currentInput)) {
            response = 'CON Invalid date. Enter start date (DD.MM.YYYY):\nExample: 01.07.2026\n0. Back';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        const toISO = d => d.replace(/(\d{2})(\d{2})(\d{4})/, '$3-$2-$1');
        const startDateObj = new Date(toISO(normalizeDateDMY(currentInput)));
        const today = new Date(); today.setHours(0, 0, 0, 0);
        const diffDays = Math.floor((startDateObj - today) / (1000 * 60 * 60 * 24));
        if (['VACATION', 'ANNUAL'].includes(sessions[sessionId].leave_type) && diffDays < 30) {
            response = 'CON Annual/Vacation Leave requires\nat least 30 days advance notice.\n';
            response += 'Earliest start: ' + (() => {
                const d = new Date(today); d.setDate(d.getDate() + 30);
                return d.getDate().toString().padStart(2,'0') + '.' +
                       (d.getMonth()+1).toString().padStart(2,'0') + '.' + d.getFullYear();
            })() + '\nEnter start date (DD.MM.YYYY):\n0. Back';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        sessions[sessionId].leave_start = normalizeDateDMY(currentInput);
        sessions[sessionId].step = 'leave_end_date';
        response = 'CON Enter end date (DD.MM.YYYY):\nExample: 05.07.2026\n0. Back';
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    if (sessions[sessionId].step === 'leave_end_date' && currentInput !== '') {
        if (currentInput === '0') {
            sessions[sessionId].step = 'leave_start_date';
            response = 'CON Enter start date (DD.MM.YYYY):\nExample: 01.07.2026\n0. Back';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        if (!isValidDateDMY(currentInput)) {
            response = 'CON Invalid date. Enter end date (DD.MM.YYYY):\nExample: 05.07.2026\n0. Back';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        const endNorm = normalizeDateDMY(currentInput);
        const startNorm = sessions[sessionId].leave_start;
        const toISO = d => d.replace(/(\d{2})(\d{2})(\d{4})/, '$3-$2-$1');
        if (new Date(toISO(endNorm)) < new Date(toISO(startNorm))) {
            response = 'CON End date cannot be before start date.\nEnter end date (DD.MM.YYYY):\n0. Back';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        sessions[sessionId].leave_end = endNorm;
        sessions[sessionId].step = 'leave_reason';
        response = 'CON Enter reason for leave:\n(Min 5 chars, max 160)\n0. Cancel';
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    if (sessions[sessionId].step === 'leave_reason' && currentInput !== '') {
        if (currentInput === '0') {
            delete sessions[sessionId];
            response = 'END Leave request cancelled.';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        if (currentInput.length < 5) {
            response = 'CON Reason too short (min 5 chars).\nEnter reason:\n0. Cancel';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        if (currentInput.length > 160) {
            response = 'CON Reason too long (max 160 chars).\nEnter reason:\n0. Cancel';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        const session = sessions[sessionId];
        try {
            const empResult = await pool.query(
                `SELECT e.id, e.division
                 FROM erp_employee e
                 JOIN employees emp ON emp.employee_id::text = e.employee_code
                 WHERE emp.phone = $1`,
                [phoneNumber]
            );
            const emp = empResult.rows[0];
            if (!emp) {
                delete sessions[sessionId];
                response = 'END Employee record not found. Contact HR.';
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            const toISO = d => d.replace(/(\d{2})(\d{2})(\d{4})/, '$3-$2-$1');
            const startISO = toISO(session.leave_start);
            const endISO = toISO(session.leave_end);
            const insertResult = await pool.query(
                `INSERT INTO erp_leave_request
                    (employee_id, leave_type, status, start_date, end_date, reason, days_requested, created_at)
                 VALUES ($1, $2, 'PENDING', $3, $4, $5,
                     (SELECT COUNT(*) FROM generate_series($3::date, $4::date, '1 day'::interval) g
                      WHERE EXTRACT(DOW FROM g) NOT IN (0,6)),
                     NOW())
                 RETURNING id, days_requested`,
                [emp.id, session.leave_type, startISO, endISO, currentInput]
            );
            const row = insertResult.rows[0];
            delete sessions[sessionId];
            response = 'END Leave request submitted!\n';
            response += 'Type: ' + session.leave_type_name + '\n';
            response += 'From: ' + session.leave_start + '\n';
            response += 'To:   ' + session.leave_end + '\n';
            response += 'Days: ' + row.days_requested + ' working days\n';
            response += 'Status: PENDING\n';
            response += 'Ref: LV-' + row.id;
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        } catch (err) {
            console.error('Leave submit error:', err);
            delete sessions[sessionId];
            response = 'END Error submitting leave. Try again.';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
    }

    // ========== OPTION 3: Pending Leave ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '3') {
        try {
            const empResult = await pool.query(
                `SELECT e.id FROM erp_employee e
                 JOIN employees emp ON emp.employee_id::text = e.employee_code
                 WHERE emp.phone = $1`,
                [phoneNumber]
            );
            const emp = empResult.rows[0];
            if (!emp) {
                response = 'END Employee record not found. Contact HR.';
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            const pendResult = await pool.query(
                `SELECT id, leave_type, start_date, end_date, days_requested, status
                 FROM erp_leave_request
                 WHERE employee_id = $1 AND status IN ('PENDING','APPROVED')
                 ORDER BY created_at DESC LIMIT 5`,
                [emp.id]
            );
            if (pendResult.rows.length === 0) {
                response = 'END No pending or approved leave requests.';
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            const leaveTypeLabels = {
                'ANNUAL': 'Annual', 'VACATION': 'Vacation', 'LOCAL': 'Local',
                'SICK': 'Sick', 'MATERNITY': 'Maternity', 'PATERNITY': 'Paternity',
                'COMPASSIONATE': 'Compassionate', 'FAMILY_CARE': 'Family Care',
                'MOTHERS_DAY': "Mother's Day", 'UNPAID': 'Unpaid'
            };
            const fmtDate = d => {
                const dt = new Date(d);
                return dt.getDate().toString().padStart(2,'0') + '.' +
                       (dt.getMonth()+1).toString().padStart(2,'0') + '.' +
                       dt.getFullYear();
            };
            response = 'END Recent Leave Requests:\n';
            pendResult.rows.forEach((r, i) => {
                const typeName = leaveTypeLabels[r.leave_type] || r.leave_type;
                response += (i+1) + '. ' + typeName + ' - ' + r.days_requested + 'd\n';
                response += '   ' + fmtDate(r.start_date) + ' to ' + fmtDate(r.end_date) + '\n';
                response += '   Status: ' + r.status + ' (Ref:LV-' + r.id + ')\n';
            });
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        } catch (err) {
            console.error('Pending leave error:', err);
            response = 'END Error fetching leave requests. Try again.';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
    }

    // ========== OPTION 4: Salary Advance ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '4') {
        response = 'CON Salary Advance Options:\n1. Apply\n2. Check Status\n0. Back';
        res.send(response);
        return;
    }

    // ========== OPTION 5: Introductory Letter ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '5') {
        sessions[sessionId].step = 'letter_recipient';
        response = 'CON Enter recipient name:\n0. Back';
        res.send(response);
        return;
    }

    if (sessions[sessionId].step === 'letter_recipient' && currentInput !== '') {
        if (currentInput === '0') {
            response = 'CON ';
            response += 'Local Authority Employee\n';
            response += '1. Check Leave Balance\n';
            response += '2. Submit Leave Request\n';
            response += '3. Check Pending Leave Status\n';
            response += '4. Salary Advance\n';
            response += '5. Request Introductory Letter\n';
            response += '6. My Performance Score\n';
            response += '7. Overtime Request\n';
            response += '0. Exit';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        const ref = 'IL-' + Date.now();
        response = 'END Letter request submitted to: ' + currentInput + '\nReference: ' + ref;
        delete sessions[sessionId];
        res.send(response);
        return;
    }

    // ========== OPTION 6: Performance Score ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '6') {
        response = 'END Your performance score: 4.2/5';
        res.send(response);
        return;
    }

    // ========= OPTION 7: OVERTIME =========
if (menuInput === '7' && sessions[sessionId].step === 'menu') {
    try {
        const employeeResult = await pool.query('SELECT employee_id, name FROM employees WHERE phone = $1', [phoneNumber]);
        const employee = employeeResult.rows[0];
        
        if (!employee) {
            response = 'END Employee not found. Please contact HR.';
            console.log('Sending response at step: employee_lookup_error');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        let session = {
            step: 'overtime_date',
            employee_id: employee.employee_id,
            employee_name: employee.name,
            requested_by_role: 'employee',
            requested_by_id: employee.employee_id,
            requested_by_name: employee.name
        };
        sessions[sessionId] = session;

        const overtimeInputs = inputParts.slice(1);
        const dateInput = overtimeInputs[0] || '';

        if (overtimeInputs.length === 0) {
            response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back\n9. Request on behalf of subordinate';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (dateInput === '0') {
            session.step = 'menu';
            sessions[sessionId] = session;
            response = 'CON Local Authority Employee\n';
            response += '1. Check Leave Balance\n';
            response += '2. Submit Leave Request\n';
            response += '3. Check Pending Leave Status\n';
            response += '4. Salary Advance\n';
            response += '5. Request Introductory Letter\n';
            response += '6. My Performance Score\n';
            response += '7. Overtime Request\n';
            response += '0. Exit';
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (dateInput === '9') {
            const subordinateInputs = overtimeInputs.slice(1);
            if (subordinateInputs.length === 0) {
                session.step = 'overtime_subordinate';
                sessions[sessionId] = session;
                response = 'CON Enter subordinate Employee ID:\nExample: CHL-2025-000007\n0. Back';
                console.log('Sending response at step:', session.step);
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            const subordinateId = subordinateInputs[0];
            if (subordinateId === '0') {
                session.step = 'overtime_date';
                sessions[sessionId] = session;
                response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back\n9. Request on behalf of subordinate';
                console.log('Sending response at step:', session.step);
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (subordinateId === employee.employee_id) {
                response = 'END You cannot request subordinate overtime for yourself. Please use the regular overtime option.';
                console.log('Sending response at step: subordinate_self_request');
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            const subResult = await pool.query('SELECT employee_id, name FROM employees WHERE employee_id = $1', [subordinateId]);
            const sub = subResult.rows[0];
            
            if (!sub) {
                response = 'END Subordinate not found. Please contact HR.';
                console.log('Sending response at step: subordinate_lookup_error');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            session.employee_id = sub.employee_id;
            session.employee_name = sub.name;
            session.requested_by_role = 'supervisor';
            session.requested_by_id = employee.employee_id;
            session.requested_by_name = employee.name;

            const subDateInput = subordinateInputs[1] || '';
            if (subordinateInputs.length === 1) {
                session.step = 'overtime_date';
                sessions[sessionId] = session;
                response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (subDateInput === '0') {
                session.step = 'overtime_subordinate';
                sessions[sessionId] = session;
                response = 'CON Enter subordinate Employee ID:\nExample: CHL-2025-000007\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (!isValidDateDMY(subDateInput)) {
                response = 'CON Invalid date format. Enter overtime date as DD.MM.YYYY:\nExample: 06.05.2026\n0. Back';
                console.log('Sending response at step: overtime_date_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            session.overtime_date = normalizeDateDMY(subDateInput);
            if (subordinateInputs.length === 2) {
                session.step = 'overtime_start_time';
                sessions[sessionId] = session;
                response = 'CON Enter overtime start time (HH:MM):\nExample: 18:00 for 6:00 PM\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            const subStartInput = subordinateInputs[2] || '';
            if (subStartInput === '0') {
                session.step = 'overtime_date';
                sessions[sessionId] = session;
                response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (!isValidTimeHHMM(subStartInput)) {
                response = 'CON Invalid start time format. Enter HH:MM:\nExample: 18:00 for 6:00 PM\n0. Back';
                console.log('Sending response at step: overtime_start_time_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            session.start_time = normalizeTimeHHMM(subStartInput);
            if (subordinateInputs.length === 3) {
                session.step = 'overtime_end_time';
                sessions[sessionId] = session;
                response = 'CON Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            const subEndInput = subordinateInputs[3] || '';
            if (subEndInput === '0') {
                session.step = 'overtime_start_time';
                sessions[sessionId] = session;
                response = 'CON Enter overtime start time (HH:MM):\nExample: 18:00 for 6:00 PM\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (!isValidTimeHHMM(subEndInput)) {
                response = 'CON Invalid end time format. Enter HH:MM:\nExample: 20:00 for 8:00 PM\n0. Back';
                console.log('Sending response at step: overtime_end_time_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (timeToMinutes(subEndInput) <= timeToMinutes(session.start_time)) {
                response = 'CON End time must be later than start time. Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
                console.log('Sending response at step: overtime_end_time_before_start');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            session.end_time = normalizeTimeHHMM(subEndInput);
            const subTypeInput = subordinateInputs[4] || '';
            const subReasonInput = subordinateInputs.slice(5).join('*').trim();

            const subTypeDetails = getOvertimeTypeDetails(subTypeInput);
            if (!subTypeInput) {
                session.step = 'overtime_type';
                sessions[sessionId] = session;
                response = 'CON Select overtime type:\n1. Normal (Weekday - 1.112x)\n2. Sunday (2.0x)\n3. Public Holiday (2.0x)\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (subTypeInput === '0') {
                session.step = 'overtime_end_time';
                sessions[sessionId] = session;
                response = 'CON Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (!subTypeDetails) {
                session.step = 'overtime_type';
                sessions[sessionId] = session;
                response = 'CON Invalid selection. Select overtime type:\n1. Normal (Weekday - 1.112x)\n2. Sunday (2x)\n3. Public Holiday (2x)\n0. Back';
                console.log('Sending response at step: overtime_type_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            session.overtime_type = subTypeDetails.type;
            session.rate_multiplier = subTypeDetails.multiplier;
            session.rate_text = subTypeDetails.text;

            if (!subReasonInput) {
                session.step = 'overtime_reason';
                sessions[sessionId] = session;
                response = 'CON Selected: ' + session.rate_text + '\nEnter reason for overtime:\n(Min 5 chars, max 160)\n0. Cancel';
                console.log('Sending response at step:', session.step);
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (subReasonInput === '0') {
                response = 'END Overtime request cancelled.';
                delete sessions[sessionId];
                console.log('Sending response at step: overtime_cancelled');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (subReasonInput.length < 5) {
                response = 'END Reason too short (minimum 5 characters). Please try again.';
                delete sessions[sessionId];
                console.log('Sending response at step: overtime_reason_too_short');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            if (subReasonInput.length > 160) {
                response = 'END Reason exceeds 160 characters. Please try again.';
                delete sessions[sessionId];
                console.log('Sending response at step: overtime_reason_too_long');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }

            session.step = 'overtime_submit';
            sessions[sessionId] = session;
            await submitOvertimeRequest(session, subReasonInput, res, sessionId);
            return;
        }

        if (!isValidDateDMY(dateInput)) {
            response = 'CON Invalid date format. Enter overtime date as DD.MM.YYYY:\nExample: 06.05.2026\n0. Back';
            console.log('Sending response at step: overtime_date_invalid');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        session.overtime_date = normalizeDateDMY(dateInput);
        if (overtimeInputs.length === 1) {
            session.step = 'overtime_start_time';
            sessions[sessionId] = session;
            response = 'CON Enter overtime start time (HH:MM):\nExample: 18:00 for 6:00 PM\n0. Back';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        const startInput = overtimeInputs[1] || '';
        if (startInput === '0') {
            session.step = 'overtime_date';
            sessions[sessionId] = session;
            response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (!isValidTimeHHMM(startInput)) {
            response = 'CON Invalid start time format. Enter HH:MM:\nExample: 18:00 for 6:00 PM\n0. Back';
            console.log('Sending response at step: overtime_start_time_invalid');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        session.start_time = normalizeTimeHHMM(startInput);
        if (overtimeInputs.length === 2) {
            session.step = 'overtime_end_time';
            sessions[sessionId] = session;
            response = 'CON Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        const endInput = overtimeInputs[2] || '';
        if (endInput === '0') {
            session.step = 'overtime_start_time';
            sessions[sessionId] = session;
            response = 'CON Enter overtime start time (HH:MM):\nExample: 18:00 for 6:00 PM\n0. Back';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (!isValidTimeHHMM(endInput)) {
            response = 'CON Invalid end time format. Enter HH:MM:\nExample: 20:00 for 8:00 PM\n0. Back';
            console.log('Sending response at step: overtime_end_time_invalid');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (timeToMinutes(endInput) <= timeToMinutes(session.start_time)) {
            response = 'CON End time must be later than start time. Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
            console.log('Sending response at step: overtime_end_time_before_start');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        session.end_time = normalizeTimeHHMM(endInput);
        const typeInput = overtimeInputs[3] || '';
        const reasonInput = overtimeInputs.slice(4).join('*').trim();

        const typeDetails = getOvertimeTypeDetails(typeInput);
        if (!typeInput) {
            session.step = 'overtime_type';
            sessions[sessionId] = session;
            response = 'CON Select overtime type:\n1. Normal (Weekday - 1.112x)\n2. Sunday (2.0x)\n3. Public Holiday (2.0x)\n0. Back';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (typeInput === '0') {
            session.step = 'overtime_end_time';
            sessions[sessionId] = session;
            response = 'CON Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (!typeDetails) {
            session.step = 'overtime_type';
            sessions[sessionId] = session;
            response = 'CON Invalid selection. Select overtime type:\n1. Normal (Weekday - 1.112x)\n2. Sunday (2.0x)\n3. Public Holiday (2.0x)\n0. Back';
            console.log('Sending response at step: overtime_type_invalid');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        session.overtime_type = typeDetails.type;
        session.rate_multiplier = typeDetails.multiplier;
        session.rate_text = typeDetails.text;

        if (!reasonInput) {
            session.step = 'overtime_reason';
            sessions[sessionId] = session;
            response = 'CON Selected: ' + session.rate_text + '\nEnter reason for overtime:\n(Min 5 chars, max 160)\n0. Cancel';
            console.log('Sending response at step:', session.step);
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (reasonInput === '0') {
            response = 'END Overtime request cancelled.';
            delete sessions[sessionId];
            console.log('Sending response at step: overtime_cancelled');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (reasonInput.length < 5) {
            response = 'END Reason too short (minimum 5 characters). Please try again.';
            delete sessions[sessionId];
            console.log('Sending response at step: overtime_reason_too_short');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (reasonInput.length > 160) {
            response = 'END Reason exceeds 160 characters. Please try again.';
            delete sessions[sessionId];
            console.log('Sending response at step: overtime_reason_too_long');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        session.overtime_type = typeDetails.type;
        session.rate_multiplier = typeDetails.multiplier;
        session.rate_text = typeDetails.text;
        session.step = 'overtime_submit';
        sessions[sessionId] = session;
        await submitOvertimeRequest(session, reasonInput, res, sessionId);
    } catch (err) {
        console.error('Database error:', err);
        response = 'END Error processing request. Please try again.';
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
}

// Step: Overtime date
session = sessions[sessionId] || {};
if (session.step === 'overtime_date' && currentInput !== '') {
    if (currentInput === '0') {
        session.step = 'menu';
        sessions[sessionId] = session;
        response = getMainMenuText();

        console.log('Sending response at step:', session.step);
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    if (currentInput === '9') {
        session.step = 'overtime_subordinate';
        sessions[sessionId] = session;
        response = 'CON Enter subordinate Employee ID:\nExample: CHL-2025-000007\n0. Back';
        console.log('Sending response at step:', session.step);
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    if (!isValidDateDMY(currentInput)) {
        response = 'CON Invalid date format. Enter overtime date as DD.MM.YYYY:\nExample: 06.05.2026\n0. Back';
        console.log('Sending response at step: overtime_date_invalid');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    session.overtime_date = normalizeDateDMY(currentInput);
    session.step = 'overtime_start_time';
    sessions[sessionId] = session;
    response = 'CON Enter overtime start time (HH:MM):\nExample: 18:00 for 6:00 PM\n0. Back';
    console.log('Sending response at step:', session.step);
    res.set('Content-Type', 'text/plain');
    res.send(response);
    return;
}

// Step: Overtime subordinate lookup
session = sessions[sessionId] || {};
if (session.step === 'overtime_subordinate') {
    const subordinateId = flowParts.length > 1 ? flowParts[1] : currentInput;
    if (subordinateId === '0' || subordinateId === '') {
        session.step = 'overtime_date';
        sessions[sessionId] = session;
        response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back';
        console.log('Sending response at step:', session.step);
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    if (subordinateId === session.employee_id) {
        response = 'END You cannot request subordinate overtime for yourself. Please use the regular overtime option.';
        console.log('Sending response at step: subordinate_self_request');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    pool.query('SELECT employee_id, name FROM employees WHERE employee_id = $1', [subordinateId], async (err, result) => {
        if (err || !result.rows[0]) {
            response = 'END Subordinate not found. Please contact HR.';
            console.log('Sending response at step: subordinate_lookup_error');
            if (res.headersSent) return;
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        const sub = result.rows[0];
        session.employee_id = sub.employee_id;
        session.employee_name = sub.name;
        session.requested_by_role = 'supervisor';
        // session.requested_by_id and session.requested_by_name are already in the session
        // from the initial employee lookup in the first step.
        
        // Process additional inputs if provided
        let nextIndex = 2; // after '9' and subordinateId
        if (flowParts.length > nextIndex) {
            const dateInput = flowParts[nextIndex];
            if (!isValidDateDMY(dateInput)) {
                response = 'CON Invalid date format. Enter overtime date as DD.MM.YYYY:\nExample: 06.05.2026\n0. Back';
                console.log('Sending response at step: overtime_date_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            session.overtime_date = normalizeDateDMY(dateInput);
            nextIndex++;
        } else {
            session.step = 'overtime_date';
            sessions[sessionId] = session;
            response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back';
            console.log('Sending response at step:', session.step);
            if (res.headersSent) return;
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (flowParts.length > nextIndex) {
            const startInput = flowParts[nextIndex];
            if (!isValidTimeHHMM(startInput)) {
                response = 'CON Invalid start time format. Enter HH:MM:\nExample: 18:00 for 6:00 PM\n0. Back';
                console.log('Sending response at step: overtime_start_time_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            session.start_time = normalizeTimeHHMM(startInput);
            nextIndex++;
        } else {
            session.step = 'overtime_start_time';
            sessions[sessionId] = session;
            response = 'CON Enter overtime start time (HH:MM):\nExample: 18:00 for 6:00 PM\n0. Back';
            console.log('Sending response at step:', session.step);
            if (res.headersSent) return;
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (flowParts.length > nextIndex) {
            const endInput = flowParts[nextIndex];
            if (!isValidTimeHHMM(endInput)) {
                response = 'CON Invalid end time format. Enter HH:MM:\nExample: 20:00 for 8:00 PM\n0. Back';
                console.log('Sending response at step: overtime_end_time_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            if (timeToMinutes(endInput) <= timeToMinutes(session.start_time)) {
                response = 'CON End time must be later than start time. Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
                console.log('Sending response at step: overtime_end_time_before_start');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            session.end_time = normalizeTimeHHMM(endInput);
            nextIndex++;
        } else {
            session.step = 'overtime_end_time';
            sessions[sessionId] = session;
            response = 'CON Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
            console.log('Sending response at step:', session.step);
            if (res.headersSent) return;
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (flowParts.length > nextIndex) {
            const typeInput = flowParts[nextIndex];
            const typeDetails = getOvertimeTypeDetails(typeInput);
            if (!typeDetails) {
                response = 'CON Invalid selection. Select overtime type:\n1. Normal (Weekday - 1.112x)\n2. Sunday (2x)\n3. Public Holiday (2x)\n0. Back';
                console.log('Sending response at step: overtime_type_invalid');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            session.overtime_type = typeDetails.type;
            session.rate_multiplier = typeDetails.multiplier;
            session.rate_text = typeDetails.text;
            nextIndex++;
        } else {
            session.step = 'overtime_type';
            sessions[sessionId] = session;
            response = 'CON Select overtime type:\n1. Normal (Weekday - 1.112x)\n2. Sunday (2x)\n3. Public Holiday (2x)\n0. Back';
            console.log('Sending response at step:', session.step);
            if (res.headersSent) return;
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }

        if (flowParts.length > nextIndex) {
            const reasonInput = flowParts.slice(nextIndex).join('*').trim();
            if (reasonInput === '0') {
                response = 'END Overtime request cancelled.';
                delete sessions[sessionId];
                console.log('Sending response at step: overtime_cancelled');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            if (reasonInput.length < 5) {
                response = 'END Reason too short (minimum 5 characters). Please try again.';
                delete sessions[sessionId];
                console.log('Sending response at step: overtime_reason_too_short');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            if (reasonInput.length > 160) {
                response = 'END Reason exceeds 160 characters. Please try again.';
                delete sessions[sessionId];
                console.log('Sending response at step: overtime_reason_too_long');
                if (res.headersSent) return;
                res.set('Content-Type', 'text/plain');
                res.send(response);
                return;
            }
            session.step = 'overtime_submit';
            sessions[sessionId] = session;
            await submitOvertimeRequest(session, reasonInput, res, sessionId);
        } else {
            session.step = 'overtime_reason';
            sessions[sessionId] = session;
            response = 'CON Selected: ' + session.rate_text + '\nEnter reason for overtime:\n(Min 5 chars, max 160)\n0. Cancel';
            console.log('Sending response at step:', session.step);
            if (res.headersSent) return;
            res.set('Content-Type', 'text/plain');
            res.send(response);
        }
    });
    return;
}


// OLD SUBORDINATE HANDLER INTEGRATED INTO OPTION 7 FULL-CHAIN FLOW
// (Lines below kept for reference, but subordinate requests now handled above)

// Step: Overtime start time
session = sessions[sessionId] || {};
if (session.step === 'overtime_start_time' && currentInput !== '') {
    if (currentInput === '0') {
        session.step = 'overtime_date';
        sessions[sessionId] = session;
        response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back';
        console.log('Sending response at step:', session.step);
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    if (!isValidTimeHHMM(currentInput)) {
        response = 'CON Invalid start time format. Enter HH:MM:\nExample: 18:00 for 6:00 PM\n0. Back';
        console.log('Sending response at step: overtime_start_time_invalid');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    session.start_time = normalizeTimeHHMM(currentInput);
    session.step = 'overtime_end_time';
    sessions[sessionId] = session;
    response = 'CON Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
    console.log('Sending response at step:', session.step);
    res.set('Content-Type', 'text/plain');
    res.send(response);
    return;
}

// Step: Overtime end time
session = sessions[sessionId] || {};
if (session.step === 'overtime_end_time' && currentInput !== '') {
    if (currentInput === '0') {
        session.step = 'overtime_start_time';
        sessions[sessionId] = session;
        response = 'CON Enter overtime start time (HH:MM):\nExample: 18:00 for 6:00 PM\n0. Back';
        console.log('Sending response at step:', session.step);
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    // For subordinate cumulative inputs, set start_time if not set
    if (menuInput === '9' && flowParts.length >= 4 && !session.start_time) {
        session.start_time = normalizeTimeHHMM(flowParts[3]);
    }

    if (!isValidTimeHHMM(currentInput)) {
        response = 'CON Invalid end time format. Enter HH:MM:\nExample: 20:00 for 8:00 PM\n0. Back';
        console.log('Sending response at step: overtime_end_time_invalid');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    if (!session.start_time || !isValidTimeHHMM(session.start_time)) {
        response = 'END Stored start time is invalid. Please restart the overtime request.';
        delete sessions[sessionId];
        console.log('Sending response at step: overtime_state_error');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    if (timeToMinutes(currentInput) <= timeToMinutes(session.start_time)) {
        response = 'CON End time must be later than start time. Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
        console.log('Sending response at step: overtime_end_time_before_start');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    session.end_time = normalizeTimeHHMM(currentInput);
    session.step = 'overtime_type';
    sessions[sessionId] = session;
    response = 'CON Select overtime type:\n1. Normal (Weekday - 1.112x)\n2. Sunday (2.0x)\n3. Public Holiday (2.0x)\n0. Back';
    console.log('Sending response at step:', session.step);
    res.set('Content-Type', 'text/plain');
    res.send(response);
    return;
}

// Step: Overtime type
session = sessions[sessionId] || {};
if (session.step === 'overtime_type' && currentInput !== '') {
    if (currentInput === '0') {
        session.step = 'overtime_end_time';
        sessions[sessionId] = session;
        response = 'CON Enter overtime end time (HH:MM):\nExample: 20:00 for 8:00 PM\n0. Back';
        console.log('Sending response at step:', session.step);
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    const types = { '1': 'normal', '2': 'sunday', '3': 'holiday' };
    session.overtime_type = types[currentInput] || 'normal';
    session.rate_multiplier = (currentInput === '1') ? 1.112 : 2.0;
    session.rate_text = (currentInput === '1') ? 'Weekday (1.112x)' : (currentInput === '2') ? 'Sunday (2x)' : 'Public Holiday (2x)';

    // For subordinate cumulative inputs, check if reason is provided
    if (menuInput === '9' && flowParts.length > 6) {
        const reasonInput = flowParts.slice(6).join('*').trim();
        if (reasonInput === '0') {
            response = 'END Overtime request cancelled.';
            delete sessions[sessionId];
            console.log('Sending response at step: overtime_cancelled');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        if (reasonInput.length < 5) {
            response = 'END Reason too short (minimum 5 characters). Please try again.';
            delete sessions[sessionId];
            console.log('Sending response at step: overtime_reason_too_short');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        if (reasonInput.length > 160) {
            response = 'END Reason exceeds 160 characters. Please try again.';
            delete sessions[sessionId];
            console.log('Sending response at step: overtime_reason_too_long');
            res.set('Content-Type', 'text/plain');
            res.send(response);
            return;
        }
        session.step = 'overtime_submit';
        sessions[sessionId] = session;
        submitOvertimeRequest(session, reasonInput, res, sessionId);
    } else {
        session.step = 'overtime_reason';
        sessions[sessionId] = session;
        response = 'CON Selected: ' + session.rate_text + '\nEnter reason for overtime:\n(Min 5 chars, max 160)\n0. Cancel';
        console.log('Sending response at step:', session.step);
        res.set('Content-Type', 'text/plain');
        res.send(response);
    }
    return;
}

    // Step: Overtime reason and submission
session = sessions[sessionId] || {};
if (session.step === 'overtime_reason' && currentInput !== '') {
    if (currentInput === '0') {
        response = 'END Overtime request cancelled.';
        delete sessions[sessionId];
        console.log('Sending response at step: overtime_cancelled');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    if (currentInput.length < 5) {
        response = 'END Reason too short (minimum 5 characters). Please try again.';
        delete sessions[sessionId];
        console.log('Sending response at step: overtime_reason_too_short');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }
    if (currentInput.length > 160) {
        response = 'END Reason exceeds 160 characters. Please try again.';
        delete sessions[sessionId];
        console.log('Sending response at step: overtime_reason_too_long');
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    }

    const reasonValue = currentInput;
    session.step = 'overtime_submit';
    sessions[sessionId] = session;
    submitOvertimeRequest(session, reasonValue, res, sessionId);
    return;
}

// Duplicate subordinate handler removed - now handled in main flow above

    // ========== OPTION 0: Exit ==========
    if (sessions[sessionId].step === 'menu' && text === '0') {
        response = 'END Thank you. Goodbye!';
        delete sessions[sessionId];
        res.send(response);
        return;
    }

    // ========== DEFAULT ==========
    response = 'END Invalid option. Please try again.';
    res.send(response);
    } catch (err) {
        console.error('Unexpected error in USSD handler:', err);
        response = 'END System error. Please try again.';
        res.set('Content-Type', 'text/plain');
        res.send(response);
    }
});

app.get('/usd', (req, res) => {
    res.send('USSD Service is running');
});

const PORT = 8080; // Changed to 8080 for easier testing
app.listen(PORT, '0.0.0.0', () => {
    console.log('USSD Server running on port ' + PORT);
});
