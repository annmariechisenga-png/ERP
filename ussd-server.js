const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const app = express();
const db = new sqlite3.Database('./hr_platform.db');

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

const sessions = {};

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

function submitOvertimeRequest(session, reasonValue, res, sessionId) {
    session.step = 'overtime_submit';
    sessions[sessionId] = session;

    db.get(
        `SELECT e.employee_id, e.name, e.salary_scale, esn.notch_no, snv.monthly_basic
         FROM employees e
         JOIN employee_salary_notch esn ON e.employee_id = esn.employee_id AND esn.is_active = 1
         JOIN salary_notch_values snv ON esn.scale_code = snv.scale_code AND esn.notch_no = snv.notch_no AND esn.effective_from = snv.effective_from
         WHERE e.employee_id = ?`,
        [session.employee_id],
        (err, salaryData) => {
            let response = '';
            if (err || !salaryData) {
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

            db.run(
                `INSERT INTO overtime_requests (
                    employee_id, employee_name, salary_scale, division, notch_no, monthly_salary,
                    overtime_date, start_time, end_time, hours_worked, overtime_type,
                    hourly_rate, rate_multiplier, amount_earned, reason,
                    requested_by_employee_id, requested_by_name, requested_by_role,
                    is_self_request, status, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
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
                ],
                function (err) {
                    if (err) {
                        console.error('DB Error:', err);
                        response = 'END Error submitting overtime request. Please try again.';
                        delete sessions[sessionId];
                        console.log('Sending response at step: overtime_submit_error');
                        if (res.headersSent) return;
                        res.set('Content-Type', 'text/plain');
                        res.send(response);
                        return;
                    }

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
                    response += 'Reference: OT-' + this.lastID;

                    delete sessions[sessionId];
                    console.log('Sending response at step: overtime_submit_success');
                    if (res.headersSent) return;
                    res.set('Content-Type', 'text/plain');
                    res.send(response);
                    return;
                }
            );
        }
    );
}

app.post('/usd', (req, res) => {
    console.log('Request:', req.body);

    const { sessionId, phoneNumber, text } = req.body;
    let response = '';
    const rawText = (text || '').trim();
    const inputParts = rawText === '' ? [''] : rawText.split('*').map(part => part.trim());
    while (inputParts.length > 1 && inputParts[inputParts.length - 1] === '') {
        inputParts.pop();
    }

    if (!sessions[sessionId]) {
        sessions[sessionId] = { step: 'menu' };
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
        response = 'END Your leave balance is 15 days.';
        res.send(response);
        return;
    }

    // ========== OPTION 2: Leave Request ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '2') {
        sessions[sessionId].step = 'leave_days';
        response = 'CON Enter number of days:\n0. Back';
        res.send(response);
        return;
    }

    if (sessions[sessionId].step === 'leave_days' && currentInput !== '') {
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
        const ref = 'LV-' + Date.now();
        response = 'END Leave request for ' + currentInput + ' days submitted. Reference: ' + ref;
        delete sessions[sessionId];
        res.send(response);
        return;
    }

    // ========== OPTION 3: Pending Leave ==========
    if (sessions[sessionId].step === 'menu' && menuInput === '3') {
        response = 'END No pending leave requests.';
        res.send(response);
        return;
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
    db.get('SELECT employee_id, name FROM employees WHERE phone = ?', [phoneNumber], (err, employee) => {
        if (err || !employee) {
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

            db.get('SELECT employee_id, name FROM employees WHERE employee_id = ?', [subordinateId], (err, sub) => {
                if (err || !sub) {
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
                submitOvertimeRequest(session, subReasonInput, res, sessionId);
            });
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
        submitOvertimeRequest(session, reasonInput, res, sessionId);
    });
    return;
}

// Step: Overtime date
let session = sessions[sessionId] || {};
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

    db.get('SELECT employee_id, name FROM employees WHERE employee_id = ?', [subordinateId], (err, sub) => {
        if (err || !sub) {
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
            submitOvertimeRequest(session, reasonInput, res, sessionId);
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

// Step: Overtime subordinate lookup (Duplicate Handler)
session = sessions[sessionId] || {};
if (session.step === 'overtime_subordinate') {
    const subordinateId = currentInput;
    if (subordinateId === '0' || subordinateId === '') {
        session.step = 'overtime_date';
        sessions[sessionId] = session;
        response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back\n9. Request on behalf of subordinate';
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

    db.get('SELECT employee_id, name FROM employees WHERE employee_id = ?', [subordinateId], (err, sub) => {
        if (err || !sub) {
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
        // requested_by_id and requested_by_name are already in the session
        
        session.step = 'overtime_date';
        sessions[sessionId] = session;
        response = 'CON Enter overtime date (DD.MM.YYYY):\nExample: 06.05.2026\n0. Back';
        console.log('Sending response at step:', session.step);
        if (res.headersSent) return;
        res.set('Content-Type', 'text/plain');
        res.send(response);
        return;
    });
    return;
}

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
});

app.get('/usd', (req, res) => {
    res.send('USSD Service is running');
});

const PORT = 8080; // Changed to 8080 for easier testing
app.listen(PORT, '0.0.0.0', () => {
    console.log('USSD Server running on port ' + PORT);
});
