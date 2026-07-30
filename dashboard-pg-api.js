const express = require('express');
const { Pool } = require('pg');
const app  = express();
const port = 3001;

app.use(require('cors')());
app.use(express.json());
app.use(express.static(__dirname));

const pool = new Pool({ host:'/var/run/postgresql', user:'chisenga', database:'hr_platform', port:5432 });
pool.connect((err,client,done)=>{ if(err) console.error('PG error:',err.message); else { console.log('Connected to PostgreSQL hr_platform'); done(); }});

const q = (sql,p=[]) => pool.query(sql,p);

app.get('/api/user-stats/:id', async (req,res) => {
  try {
    const {rows} = await q(`SELECT * FROM employees WHERE employee_id=$1 OR nrc_number=$1 LIMIT 1`,[req.params.id]);
    if(!rows.length) return res.status(404).json({success:false,error:'Employee not found'});
    const emp = rows[0];
    const notch = parseInt((emp.salary_scale_code||'').replace(/[^0-9]/g,''))||0;
    const division = notch<=7?'I':notch<=11?'II':notch<=14?'III':'IV';
    const sup = await q(`SELECT name FROM employees WHERE employee_id=$1 LIMIT 1`,[emp.supervisor_id]).catch(()=>({rows:[]}));
    const jd  = await q(`SELECT position_title,file_path FROM job_description_documents WHERE position_title ILIKE $1 LIMIT 1`,[emp.position]).catch(()=>({rows:[]}));
    const lb  = await q(`SELECT local_leave_balance,vacation_leave_balance FROM leave_balances WHERE employee_id=$1`,[emp.employee_id]).catch(()=>({rows:[]}));
    res.json({success:true,stats:{
      id:emp.employee_id, name:emp.name, position:emp.position,
      department:emp.establishment_department||emp.department,
      sex:emp.sex||emp.gender, division,
      leaveBalance: emp.leave_balance||0,
      localLeaveBalance: lb.rows[0]?.local_leave_balance??emp.leave_balance??0,
      vacationLeaveBalance: lb.rows[0]?.vacation_leave_balance??0,
      carriedForward: emp.carried_forward_leave||0,
      lastNetPay: 14250,
      supervisor: sup.rows[0]?.name||'Immediate Supervisor',
      jd: jd.rows[0]?{title:jd.rows[0].position_title,path:jd.rows[0].file_path}:null
    }});
  } catch(e){console.error(e);res.status(500).json({success:false,error:e.message});}
});

app.get('/api/leave-types', async (req,res) => {
  try {
    const {rows} = await q(`SELECT leave_type_code AS code, leave_type_name AS name FROM leave_types ORDER BY leave_type_code`);
    res.json({success:true,types:rows});
  } catch(e){res.status(500).json({success:false,error:e.message});}
});

app.post('/api/leave-request', async (req,res) => {
  const {employeeId,leaveType,startDate,endDate,reason} = req.body;
  if(!employeeId||!leaveType||!startDate||!endDate||!reason)
    return res.status(400).json({success:false,error:'employeeId, leaveType, startDate, endDate and reason are required.'});
  if(['ANNUAL','VACATION'].includes(leaveType)){
    const diff = Math.floor((new Date(startDate)-new Date())/(1000*60*60*24));
    if(diff<30) return res.status(422).json({success:false,error:'Annual/Vacation leave requires at least 30 days advance notice.'});
  }
  const days = Math.ceil((new Date(endDate)-new Date(startDate))/(1000*60*60*24))+1;
  try {
    const empRow = await q(`SELECT employee_id FROM employees WHERE employee_id=$1 LIMIT 1`,[employeeId]);
    if(!empRow.rows.length) return res.status(404).json({success:false,error:'Employee not found.'});
    // leave_requests.employee_id is INTEGER; use row number as surrogate
    const seqRow = await q(`SELECT (ROW_NUMBER() OVER (ORDER BY employee_id))::int AS rn FROM employees WHERE employee_id=$1`,[employeeId]);
    const empInt = seqRow.rows[0]?.rn||1;
    const result = await q(
      `INSERT INTO leave_requests (employee_id,leave_type,start_date,end_date,requested_days,status) VALUES ($1,$2,$3,$4,$5,'Pending') RETURNING request_id`,
      [empInt,leaveType,startDate,endDate,days]
    );
    res.json({success:true,message:`Leave request submitted. Reference: LV-${result.rows[0].request_id}`,referenceId:result.rows[0].request_id,daysRequested:days});
  } catch(e){console.error(e);res.status(500).json({success:false,error:e.message});}
});

app.get('/api/leave-status/:id', async (req,res) => {
  try {
    const seqRow = await q(`SELECT (ROW_NUMBER() OVER (ORDER BY employee_id))::int AS rn FROM employees WHERE employee_id=$1`,[req.params.id]);
    const empInt = seqRow.rows[0]?.rn||1;
    const {rows} = await q(`SELECT request_id AS id,leave_type,start_date,end_date,requested_days,status FROM leave_requests WHERE employee_id=$1 ORDER BY request_id DESC LIMIT 10`,[empInt]);
    res.json({success:true,requests:rows});
  } catch(e){res.status(500).json({success:false,error:e.message});}
});

app.post('/api/overtime-request', async (req,res) => {
  const employeeId   = req.body.employeeId;
  const overtimeDate = req.body.overtimeDate||req.body.date;
  const startTime    = req.body.startTime;
  const endTime      = req.body.endTime;
  const overtimeType = req.body.overtimeType||req.body.type;
  const reason       = req.body.reason;
  if(!employeeId||!overtimeDate||!startTime||!endTime||!overtimeType||!reason)
    return res.status(400).json({success:false,error:'All fields are required.'});
  const hours = Math.max(0,(new Date(`${overtimeDate}T${endTime}`)-new Date(`${overtimeDate}T${startTime}`))/(1000*60*60));
  if(hours<=0) return res.status(400).json({success:false,error:'End time must be after start time.'});
  try {
    const empRow = await q(`SELECT * FROM employees WHERE employee_id=$1 LIMIT 1`,[employeeId]);
    if(!empRow.rows.length) return res.status(404).json({success:false,error:'Employee not found.'});
    const emp = empRow.rows[0];
    const notch = parseInt((emp.salary_scale_code||'').replace(/[^0-9]/g,''))||0;
    if(notch<=7) return res.status(403).json({success:false,error:'Division I employees are not entitled to overtime. Applies to Divisions II, III and IV only.'});
    const division = notch<=11?'II':notch<=14?'III':'IV';
    const scaleRow = await q(`SELECT revised_monthly_k FROM salary_scales_2026 WHERE grade=$1 ORDER BY notch LIMIT 1`,[emp.salary_scale_code]).catch(()=>({rows:[]}));
    const monthly    = scaleRow.rows[0]?.revised_monthly_k||3724.67;
    const hourlyRate = monthly/176;
    const multiplier = ['sunday','holiday','public_holiday'].includes(overtimeType)?2.0:1.112;
    const amount     = Math.round(hours*hourlyRate*multiplier*100)/100;
    const result = await q(
      `INSERT INTO overtime_requests (employee_id,employee_name,salary_scale,division,overtime_date,start_time,end_time,hours_worked,overtime_type,hourly_rate,rate_multiplier,amount_earned,reason,status,created_at)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,'pending_supervisor',NOW()) RETURNING overtime_id`,
      [employeeId,emp.name,emp.salary_scale_code,division,overtimeDate,startTime,endTime,hours,overtimeType,hourlyRate,multiplier,amount,reason]
    );
    res.json({success:true,message:`Overtime request submitted. Reference: OT-${result.rows[0].overtime_id}`,referenceId:result.rows[0].overtime_id,hoursWorked:hours.toFixed(2),estimatedAmount:`ZMW ${amount.toFixed(2)}`});
  } catch(e){console.error(e);res.status(500).json({success:false,error:e.message});}
});

app.get('/api/finance-summary', (_,res) => res.json({success:true,revenueYTD:4250000,expenditureYTD:3120000,
  bankBalances:[
    {account:'Operating Account (Main)',bank:'Zanaco',balance:1250400.50},
    {account:'Payroll Account',bank:'Absa',balance:450200.00},
    {account:'Revenue Collection',bank:'Standard Chartered',balance:890150.75}
  ]}));

app.get('/api/ledger', (_,res) => res.json({success:true,entries:[
  {id:'L-001',date:'2026-05-15',description:'Monthly Revenue Collection',category:'Revenue',amount:450000,type:'CR'},
  {id:'L-002',date:'2026-05-16',description:'Salary Disbursement - May 2026',category:'Payroll',amount:1200000,type:'DR'},
  {id:'L-003',date:'2026-05-17',description:'Statutory Remittance (NAPSA)',category:'Obligation',amount:250000,type:'DR'},
  {id:'L-004',date:'2026-05-18',description:'Utility Payment (ZESCO)',category:'Utility',amount:12400,type:'DR'},
  {id:'L-005',date:'2026-05-19',description:'Settling-in Allowance',category:'Allowance',amount:15000,type:'DR'}
]}));

app.listen(port, () => console.log(`ERP Dashboard API (PostgreSQL) running on http://localhost:${port}`));
