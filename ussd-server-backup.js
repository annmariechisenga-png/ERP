const express = require('express');
const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Store user sessions
const sessions = {};

app.post('/usd', (req, res) => {
    console.log('📱 Request:', req.body.text);
    
    const { sessionId, text } = req.body;
    let response = '';
    
    // Get or create session
    if (!sessions[sessionId]) {
        sessions[sessionId] = { step: 'menu' };
    }
    const session = sessions[sessionId];
    
    // ============================================================
    // MAIN MENU
    // ============================================================
    if (text === '') {
        session.step = 'menu';
        response = 'CON Welcome to ERP Platform\n';
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
    
    // ============================================================
    // OPTION 1: Leave Balance
    // ============================================================
    if (text === '1' || text === '1*') {
        response = 'END Your leave balance is 15 days\nCarried forward from previous LA: 5 days';
        delete sessions[sessionId];
        res.send(response);
        return;
    }
    
    // ============================================================
    // OPTION 2: Submit Leave Request
    // ============================================================
    if (text === '2') {
        session.step = 'leave_days';
        response = 'CON Enter number of days:\n0. Back';
        res.send(response);
        return;
    }
    
    if (session.step === 'leave_days' && !isNaN(text) && text !== '') {
        const days = text;
        if (days === '0') {
            session.step = 'menu';
            response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
            res.send(response);
            return;
        }
        const ref = 'LV-' + Date.now();
        response = 'END Leave request for ' + days + ' days submitted.\nReference: ' + ref;
        delete sessions[sessionId];
        res.send(response);
        return;
    }
    
    // ============================================================
    // OPTION 3: Pending Leave Status
    // ============================================================
    if (text === '3') {
        response = 'END Your pending leave requests:\n1. Local Leave: 5 days | PENDING\n2. Vacation: 30 days | APPROVED';
        delete sessions[sessionId];
        res.send(response);
        return;
    }
    
    // ============================================================
    // OPTION 4: Salary Advance
    // ============================================================
    
    // Handle combined input like "4*2500" or "4*2500*6" or "4*2500*6*School fees"
    if (text.startsWith('4*')) {
        const parts = text.split('*');
        const amount = parts[1];
        const repaymentMonths = parts[2];
        const reason = parts.slice(3).join('*');
        
        // Case: User sent "4*2500" (amount only)
        if (amount && !repaymentMonths && !reason) {
            if (amount === '0') {
                session.step = 'menu';
                response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
                res.send(response);
                return;
            }
            session.amount = amount;
            session.step = 'ask_repayment';
            const amt = parseFloat(amount);
            response = 'CON Select Repayment Period (1-6 months):\n';
            response += '1. 1 month (' + (amt/1).toFixed(2) + ' Kwacha/month)\n';
            response += '2. 2 months (' + (amt/2).toFixed(2) + ' Kwacha/month)\n';
            response += '3. 3 months (' + (amt/3).toFixed(2) + ' Kwacha/month)\n';
            response += '4. 4 months (' + (amt/4).toFixed(2) + ' Kwacha/month)\n';
            response += '5. 5 months (' + (amt/5).toFixed(2) + ' Kwacha/month)\n';
            response += '6. 6 months (' + (amt/6).toFixed(2) + ' Kwacha/month)\n';
            response += '0. Cancel';
            res.send(response);
            return;
        }
        
        // Case: User sent "4*2500*6" (amount and repayment)
        if (amount && repaymentMonths && !reason) {
            if (repaymentMonths === '0') {
                session.step = 'menu';
                response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
                res.send(response);
                return;
            }
            session.amount = amount;
            session.repaymentMonths = repaymentMonths;
            session.step = 'ask_reason';
            response = 'CON Enter the reason for your salary advance request (Section 90):\n(Min 5 chars, max 160)\n0. Cancel';
            res.send(response);
            return;
        }
        
        // Case: User sent "4*2500*6*School fees" (all three)
        if (amount && repaymentMonths && reason && reason.length >= 5) {
            if (reason === '0') {
                session.step = 'menu';
                response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
                res.send(response);
                return;
            }
            const reference = 'SA-' + Date.now();
            const monthlyDeduction = (parseFloat(amount) / parseInt(repaymentMonths)).toFixed(2);
            response = 'END ✅ Salary advance request submitted!\n\n';
            response += 'Reference: ' + reference + '\n';
            response += 'Amount: ' + amount + ' Kwacha\n';
            response += 'Repayment: ' + repaymentMonths + ' months\n';
            response += 'Monthly: ' + monthlyDeduction + ' Kwacha\n\n';
            response += 'Reason: "' + (reason.length > 80 ? reason.substring(0, 80) + '...' : reason) + '"';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
    }
    
    // Step: User selects Option 4 from menu
    if (text === '4') {
        session.step = 'ask_amount';
        response = 'CON Enter amount you wish to apply for (Max: Your monthly salary):\n0. Back';
        res.send(response);
        return;
    }
    
    // Step: User enters amount (just "2500")
    if (session.step === 'ask_amount' && !isNaN(text) && text !== '') {
        const amount = text;
        if (amount === '0') {
            session.step = 'menu';
            response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
            res.send(response);
            return;
        }
        session.amount = amount;
        session.step = 'ask_repayment';
        const amt = parseFloat(amount);
        response = 'CON Select Repayment Period (1-6 months):\n';
        response += '1. 1 month (' + (amt/1).toFixed(2) + ' Kwacha/month)\n';
        response += '2. 2 months (' + (amt/2).toFixed(2) + ' Kwacha/month)\n';
        response += '3. 3 months (' + (amt/3).toFixed(2) + ' Kwacha/month)\n';
        response += '4. 4 months (' + (amt/4).toFixed(2) + ' Kwacha/month)\n';
        response += '5. 5 months (' + (amt/5).toFixed(2) + ' Kwacha/month)\n';
        response += '6. 6 months (' + (amt/6).toFixed(2) + ' Kwacha/month)\n';
        response += '0. Cancel';
        res.send(response);
        return;
    }
    
    // Step: User selects repayment period (just "6")
    if (session.step === 'ask_repayment' && !isNaN(text) && text !== '') {
        const repaymentMonths = text;
        if (repaymentMonths === '0') {
            session.step = 'menu';
            response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
            res.send(response);
            return;
        }
        session.repaymentMonths = repaymentMonths;
        session.step = 'ask_reason';
        response = 'CON Enter the reason for your salary advance request (Section 90):\n(Min 5 chars, max 160)\n0. Cancel';
        res.send(response);
        return;
    }
    
    // Step: User enters reason
    if (session.step === 'ask_reason' && text !== '') {
        const reason = text;
        if (reason === '0') {
            session.step = 'menu';
            response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
            res.send(response);
            return;
        }
        if (reason.length < 5) {
            response = 'END Reason too short (minimum 5 characters). Please try again.';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        if (reason.length > 160) {
            response = 'END Reason exceeds 160 characters. Please try again.';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        const reference = 'SA-' + Date.now();
        const monthlyDeduction = (parseFloat(session.amount) / parseInt(session.repaymentMonths)).toFixed(2);
        
        response = 'END ✅ Salary advance request submitted!\n\n';
        response += 'Reference: ' + reference + '\n';
        response += 'Amount: ' + session.amount + ' Kwacha\n';
        response += 'Repayment: ' + session.repaymentMonths + ' months\n';
        response += 'Monthly: ' + monthlyDeduction + ' Kwacha\n\n';
        response += 'Reason: "' + (reason.length > 80 ? reason.substring(0, 80) + '...' : reason) + '"';
        delete sessions[sessionId];
        res.send(response);
        return;
    }
    
    // ============================================================
    // OPTION 5: Introductory Letter
    // ============================================================
    if (text === '5') {
        session.step = 'letter_recipient';
        response = 'CON Enter recipient name/institution:\n0. Back';
        res.send(response);
        return;
    }
    
    if (session.step === 'letter_recipient' && text !== '') {
        const recipient = text;
        if (recipient === '0') {
            session.step = 'menu';
            response = 'CON Welcome to ERP Platform\n1. Check Leave Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary Advance\n5. Request Introductory Letter\n6. My Performance Score\n0. Exit';
            res.send(response);
            return;
        }
        const ref = 'IL-' + Date.now();
        response = 'END Introductory letter request submitted!\nAddressed to: ' + recipient + '\nReference: ' + ref;
        delete sessions[sessionId];
        res.send(response);
        return;
    }
    
    // ============================================================
    // OPTION 6: Performance Score
    // ============================================================
    if (text === '6') {
        response = 'END Your latest performance score: 4.2/5\nRating: Good - Meeting expectations';
        delete sessions[sessionId];
        res.send(response);
    // ============================================================
    // OPTION 7: OVERTIME REQUEST
    // ============================================================

    if (text === '7') {
        // Get employee details
        db.get(`SELECT employee_id, name, salary_scale FROM employees 
WHERE employee_id = ? OR phone = ?`, 
            [employeeId, phoneNumber], 
            (err, employee) => {
            if (err || !employee) {
                response = 'END Employee not found. Please contact HR.';
                res.send(response);
                return;
            }
            
            // Check if eligible (Division I excluded)
            const salaryScale = employee.salary_scale || '';
            if (salaryScale.match(/LGSS0[1-7]/i)) {
                response = 'END Overtime allowance is not applicable to 
Division I officers (Salary Scale LGSS01-LGSS07) as per Section 169.';
                res.send(response);
                return;
            }
            
            sessions[sessionId] = { 
                step: 'overtime_date',
                employee_id: employee.employee_id,
                employee_name: employee.name,
                salary_scale: salaryScale
            };
            
            response = 'CON Enter overtime date (YYYY-MM-DD):\n0. Back';
            res.send(response);
        });
        return;
    }

    // Capture overtime date
    if (sessions[sessionId]?.step === 'overtime_date' && text !== '') {
        const session = sessions[sessionId];
        
        if (text === '0') {
            response = 'CON Welcome to ERP Platform\n1. Check Leave 
Balance\n2. Submit Leave Request\n3. Check Pending Leave Status\n4. Salary 
Advance\n5. Request Introductory Letter\n6. My Performance Score\n7. 
Overtime Request\n0. Exit';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        if (!text.match(/^\d{4}-\d{2}-\d{2}$/)) {
            response = 'END Invalid date format. Please use YYYY-MM-DD.';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        session.overtime_date = text;
        session.step = 'overtime_start';
        response = 'CON Enter start time (HH:MM, 24-hour format):\n0. 
Back';
        res.send(response);
        return;
    }

    // Capture start time
    if (sessions[sessionId]?.step === 'overtime_start' && text !== '') {
        const session = sessions[sessionId];
        
        if (text === '0') {
            session.step = 'overtime_date';
            response = 'CON Enter overtime date (YYYY-MM-DD):\n0. Back';
            res.send(response);
            return;
        }
        
        if (!text.match(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/)) {
            response = 'END Invalid time format. Please use HH:MM 
(24-hour).';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        session.start_time = text;
        session.step = 'overtime_end';
        response = 'CON Enter end time (HH:MM, 24-hour format):\n0. Back';
        res.send(response);
        return;
    }

    // Capture end time
    if (sessions[sessionId]?.step === 'overtime_end' && text !== '') {
        const session = sessions[sessionId];
        
        if (text === '0') {
            session.step = 'overtime_start';
            response = 'CON Enter start time (HH:MM, 24-hour format):\n0. 
Back';
            res.send(response);
            return;
        }
        
        if (!text.match(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/)) {
            response = 'END Invalid time format. Please use HH:MM 
(24-hour).';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        session.end_time = text;
        session.step = 'overtime_type';
        response = 'CON Select Overtime Type:\n';
        response += '1. Normal (Weekday - 1.112x)\n';
        response += '2. Sunday (2.0x)\n';
        response += '3. Public Holiday (2.0x)\n';
        response += '0. Back';
        res.send(response);
        return;
    }

    // Capture overtime type
    if (sessions[sessionId]?.step === 'overtime_type' && text !== '') {
        const session = sessions[sessionId];
        
        if (text === '0') {
            session.step = 'overtime_end';
            response = 'CON Enter end time (HH:MM, 24-hour format):\n0. 
Back';
            res.send(response);
            return;
        }
        
        let overtimeType = '';
        let rateText = '';
        
        if (text === '1') {
            overtimeType = 'normal';
            rateText = '1.112x';
        } else if (text === '2') {
            overtimeType = 'sunday';
            rateText = '2.0x';
        } else if (text === '3') {
            overtimeType = 'public_holiday';
            rateText = '2.0x';
        } else {
            response = 'END Invalid option. Please select 1, 2, or 3.';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        session.overtime_type = overtimeType;
        session.rate_text = rateText;
        session.step = 'overtime_reason';
        
        response = `CON Selected: ${overtimeType.toUpperCase()} 
(${rateText})\n`;
        response += 'Enter the reason for working outside normal 
hours:\n';
        response += '(Minimum 5 characters, maximum 160 characters)\n';
        response += '0. Back';
        res.send(response);
        return;
    }

    // Capture reason and submit
    if (sessions[sessionId]?.step === 'overtime_reason' && text !== '') {
        const session = sessions[sessionId];
        
        if (text === '0') {
            session.step = 'overtime_type';
            response = 'CON Select Overtime Type:\n1. Normal (Weekday - 
1.112x)\n2. Sunday (2.0x)\n3. Public Holiday (2.0x)\n0. Back';
            res.send(response);
            return;
        }
        
        if (text.length < 5) {
            response = 'END Reason too short (minimum 5 characters). 
Please start over.';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        if (text.length > 160) {
            response = 'END Reason exceeds 160 character limit. Please try 
again.';
            delete sessions[sessionId];
            res.send(response);
            return;
        }
        
        // Calculate hours worked
        const startHour = parseInt(session.start_time.split(':')[0]);
        const startMin = parseInt(session.start_time.split(':')[1]);
        const endHour = parseInt(session.end_time.split(':')[0]);
        const endMin = parseInt(session.end_time.split(':')[1]);
        const hoursWorked = (endHour - startHour) + ((endMin - startMin) / 
60);
        
        // Get employee salary
        db.get(`
            SELECT snv.monthly_basic
            FROM employees e
            JOIN employee_salary_notch esn ON e.employee_id = 
esn.employee_id AND esn.is_active = 1
            JOIN salary_notch_values snv ON esn.scale_code = 
snv.scale_code AND esn.notch_no = snv.notch_no
            WHERE e.employee_id = ? AND snv.effective_from = '2025-01-01'
        `, [session.employee_id], (err, salaryData) => {
            
            if (err || !salaryData) {
                response = 'END Salary information not found. Please 
contact HR.';
                delete sessions[sessionId];
                res.send(response);
                return;
            }
            
            // Calculate amount
            const hourlyRate = salaryData.monthly_basic / 176;
            const rateMultiplier = (session.overtime_type === 'normal') ? 
1.112 : 2.0;
            const amount = Math.round((hoursWorked * rateMultiplier * 
hourlyRate) * 100) / 100;
            
            // Calculate payment month (15th cutoff)
            const day = parseInt(session.overtime_date.split('-')[2]);
            const year = parseInt(session.overtime_date.split('-')[0]);
            const month = parseInt(session.overtime_date.split('-')[1]);
            let paymentMsg = '';
            
            if (day <= 15) {
                const monthNames = ['January', 'February', 'March', 
'April', 'May', 'June', 'July', 'August', 'September', 'October', 
'November', 'December'];
                paymentMsg = `Payment will be processed in 
${monthNames[month-1]} ${year} (on/before 15th cutoff)`;
            } else {
                let nextMonth = month + 1;
                let nextYear = year;
                if (nextMonth > 12) {
                    nextMonth = 1;
                    nextYear++;
                }
                const monthNames = ['January', 'February', 'March', 
'April', 'May', 'June', 'July', 'August', 'September', 'October', 
'November', 'December'];
                paymentMsg = `⚠️ After 15th cutoff. Payment will be 
carried over to ${monthNames[nextMonth-1]} ${nextYear}`;
            }
            
            // Insert overtime request
            db.run(`
                INSERT INTO overtime_requests (
                    employee_id, employee_name, salary_scale, division,
                    overtime_date, start_time, end_time, hours_worked, 
overtime_type,
                    hourly_rate, rate_multiplier, amount_earned, reason,
                    requested_by_employee_id, requested_by_name, 
requested_by_role,
                    is_self_request, status, created_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 
?, 'pending_supervisor', CURRENT_TIMESTAMP)
            `, [
                session.employee_id,
                session.employee_name,
                session.salary_scale,
                'Eligible',
                session.overtime_date,
                session.start_time,
                session.end_time,
                hoursWorked,
                session.overtime_type,
                hourlyRate,
                rateMultiplier,
                amount,
                text,
                session.employee_id,
                session.employee_name,
                'employee',
                1
            ], function(err) {
                if (err) {
                    response = `END Error submitting request: 
${err.message}`;
                } else {
                    response = `END ✅ Overtime request submitted 
successfully!\n\n`;
                    response += `Date: ${session.overtime_date}\n`;
                    response += `Time: ${session.start_time} - 
${session.end_time} (${hoursWorked.toFixed(1)} hours)\n`;
                    response += `Type: 
${session.overtime_type.toUpperCase()} (${session.rate_text})\n`;
                    response += `Estimated Amount: 
K${amount.toFixed(2)}\n\n`;
                    response += `Reason: "${text.length > 80 ? 
text.substring(0, 80) + '...' : text}"\n\n`;
                    response += `${paymentMsg}\n\n`;
                    response += `Awaiting approval: Supervisor → HOD → 
Principal Officer → Audit`;
                }
                
                delete sessions[sessionId];
                res.send(response);
            });
        });
        return;
    }        
return;
    }
    
    // ============================================================
    // OPTION 0: Exit
    // ============================================================
    if (text === '0') {
        response = 'END Thank you for using ERP Platform. Goodbye!';
        delete sessions[sessionId];
        res.send(response);
        return;
    }
    
    // ============================================================
    // DEFAULT
    // ============================================================
    response = 'END Invalid option. Please start over with *384*3244#';
    delete sessions[sessionId];
    res.send(response);
});

app.get('/usd', (req, res) => {
    res.send('USSD Service is running');
});

const PORT = 80;
app.listen(PORT, '0.0.0.0', () => {
    console.log('✅ USSD Server running on port ' + PORT);
});
