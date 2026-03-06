CREATE TABLE employees (
    province TEXT,
    district TEXT,
    name TEXT,
    nrc_number TEXT,
    sex TEXT,
    date_of_birth TEXT,
    position TEXT,
    salary_scale TEXT,
    local_authority_service_number TEXT,
    date_of_first_appointment TEXT,
    date_confirmed TEXT,
    date_substantive_appointment TEXT,
    date_reported TEXT,  -- length of stay at current station
    academic_qualifications TEXT,
    professional_qualifications TEXT,
    acting_position TEXT,
    acting_date TEXT,
    department TEXT,
    phone_number TEXT,
    carried_forward_leave INTEGER,
CREATE TABLE duplicates_archive(
  province TEXT,
  district TEXT,
  name TEXT,
  nrc_number TEXT,
  sex TEXT,
  date_of_birth TEXT,
  position TEXT,
  salary_scale TEXT,
  local_authority_service_number TEXT,
  date_of_first_appointment TEXT,
  date_confirmed TEXT,
  date_substantive_appointment TEXT,
  date_reported TEXT,
  academic_qualifications TEXT,
  professional_qualifications TEXT,
  acting_position TEXT,
  acting_date TEXT,
  department TEXT,
  phone_number TEXT,
  carried_forward_leave INT,
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    action TEXT,                -- e.g. 'DELETE DUPLICATE', 'ARCHIVE DUPLICATE'
    table_name TEXT,            -- e.g. 'employees'
    record_name TEXT,           -- employee name
    record_nrc TEXT,            -- NRC number
    reason TEXT,                -- why it was flagged
    performed_by TEXT,          -- user or system account
    performed_at DATETIME DEFAULT CURRENT_TIMESTAMP
, local_authority TEXT);
CREATE TABLE leave_policy (
    leave_type TEXT,
    division TEXT,
    accrual_rate REAL,
    max_days INTEGER,
    carry_forward INTEGER,
    eligibility TEXT
, fixed_days INTEGER, max_accumulation INTEGER, max_duration INTEGER, advance_notice INTEGER);
INSERT INTO leave_policy VALUES('Annual Leave','Division I',3.5,NULL,NULL,NULL,NULL,230,NULL,0);
INSERT INTO leave_policy VALUES('Annual Leave','Division II',3.0,NULL,NULL,NULL,NULL,205,NULL,0);
INSERT INTO leave_policy VALUES('Annual Leave','Division III',2.5,NULL,NULL,NULL,NULL,160,NULL,0);
INSERT INTO leave_policy VALUES('Annual Leave','Division IV',2.0,NULL,NULL,NULL,NULL,160,NULL,0);
INSERT INTO leave_policy VALUES('Vacation Leave','Division I',NULL,NULL,NULL,NULL,NULL,NULL,120,30);
INSERT INTO leave_policy VALUES('Vacation Leave','Division II',NULL,NULL,NULL,NULL,NULL,NULL,110,30);
INSERT INTO leave_policy VALUES('Vacation Leave','Division III',NULL,NULL,NULL,NULL,NULL,NULL,100,30);
INSERT INTO leave_policy VALUES('Vacation Leave','Division IV',NULL,NULL,NULL,NULL,NULL,NULL,100,30);
INSERT INTO leave_policy VALUES('Maternity Leave',NULL,NULL,NULL,NULL,NULL,98,NULL,98,NULL);
INSERT INTO leave_policy VALUES('Paternity Leave',NULL,NULL,NULL,NULL,NULL,10,NULL,10,NULL);
INSERT INTO leave_policy VALUES('Compassionate Leave',NULL,NULL,NULL,NULL,NULL,14,NULL,14,NULL);
INSERT INTO leave_policy VALUES('Unpaid Leave',NULL,NULL,NULL,NULL,NULL,365,NULL,365,NULL);
INSERT INTO leave_policy VALUES('Sick Leave',NULL,NULL,NULL,NULL,NULL,3,NULL,3,0);
CREATE TABLE leave_requests (
    request_id SERIAL PRIMARY KEY,
    employee_id INTEGER,
    leave_type TEXT,
    requested_days INTEGER,
    start_date DATE,
    end_date DATE,
    status TEXT DEFAULT 'Pending',   -- Pending, Approved, Rejected
    current_approver_id INTEGER,     -- who needs to act next
    approved_by_supervisor INTEGER,
    approved_by_hod INTEGER,
    approved_by_secretary INTEGER,
    hr_processed INTEGER DEFAULT 0,  -- HR marks balance/resumption
    resumption_date DATE,            -- auto-calculated by ERP
    remaining_balance INTEGER,       -- auto-calculated by ERP
    certificate_path TEXT,           -- file path or URL for PDF/image
    certificate_received INTEGER DEFAULT 0 -- flag for physical copy
, allowance_granted INTEGER DEFAULT 0, last_allowance_date DATE);
INSERT INTO leave_requests VALUES(1,101,'Sick Leave',3,'2026-03-01',NULL,'Accepted',NULL,NULL,NULL,NULL,0,'2026-03-04',NULL,'scan_123.pdf',1,0,NULL);
CREATE TABLE holidays (
    holiday_date DATE PRIMARY KEY,
    description TEXT
);
INSERT INTO holidays VALUES('2026-01-01','New Year’s Day');
INSERT INTO holidays VALUES('2026-03-09','International Women’s Day (observed)');
INSERT INTO holidays VALUES('2026-03-12','Youth Day');
INSERT INTO holidays VALUES('2026-04-03','Good Friday');
INSERT INTO holidays VALUES('2026-04-04','Holy Saturday');
INSERT INTO holidays VALUES('2026-04-05','Easter Sunday');
INSERT INTO holidays VALUES('2026-04-06','Easter Monday');
INSERT INTO holidays VALUES('2026-04-28','Kenneth Kaunda Day');
INSERT INTO holidays VALUES('2026-05-01','Labour Day');
INSERT INTO holidays VALUES('2026-05-25','Africa Freedom Day');
INSERT INTO holidays VALUES('2026-07-06','Heroes’ Day');
INSERT INTO holidays VALUES('2026-07-07','Unity Day');
INSERT INTO holidays VALUES('2026-08-03','Farmers’ Day');
INSERT INTO holidays VALUES('2026-08-13','Election Day');
INSERT INTO holidays VALUES('2026-10-19','National Day of Prayer (observed)');
INSERT INTO holidays VALUES('2026-10-24','Independence Day');
INSERT INTO holidays VALUES('2026-12-25','Christmas Day');
CREATE TABLE calendar (
    day DATE PRIMARY KEY,
    is_working_day INTEGER
);
INSERT INTO calendar VALUES('2026-01-01',0);
INSERT INTO calendar VALUES('2026-01-02',1);
INSERT INTO calendar VALUES('2026-01-03',0);
INSERT INTO calendar VALUES('2026-01-04',0);
INSERT INTO calendar VALUES('2026-01-05',1);
INSERT INTO calendar VALUES('2026-01-06',1);
INSERT INTO calendar VALUES('2026-01-07',1);
INSERT INTO calendar VALUES('2026-01-08',1);
INSERT INTO calendar VALUES('2026-01-09',1);
INSERT INTO calendar VALUES('2026-01-10',0);
INSERT INTO calendar VALUES('2026-01-11',0);
INSERT INTO calendar VALUES('2026-01-12',1);
INSERT INTO calendar VALUES('2026-01-13',1);
INSERT INTO calendar VALUES('2026-01-14',1);
INSERT INTO calendar VALUES('2026-01-15',1);
INSERT INTO calendar VALUES('2026-01-16',1);
INSERT INTO calendar VALUES('2026-01-17',0);
CREATE TABLE leave_balances (
    employee_id INTEGER PRIMARY KEY,
    local_leave_balance INTEGER,
    vacation_leave_balance INTEGER
);
CREATE TABLE authority_codes (
    authority_name TEXT PRIMARY KEY,
    authority_code TEXT UNIQUE
);
INSERT INTO authority_codes VALUES('Chilanga','CHL');
INSERT INTO authority_codes VALUES('Chibombo','CBB');
INSERT INTO authority_codes VALUES('Chisamba','CSM');
INSERT INTO authority_codes VALUES('Chitambo','CTM');
INSERT INTO authority_codes VALUES('Kabwe','KBW');
INSERT INTO authority_codes VALUES('Kapiri Mposhi','KPM');
INSERT INTO authority_codes VALUES('Luano','LNO');
INSERT INTO authority_codes VALUES('Mkushi','MKU');
INSERT INTO authority_codes VALUES('Mumbwa','MBW');
INSERT INTO authority_codes VALUES('Ngabwe','NGB');
INSERT INTO authority_codes VALUES('Serenje','SRJ');
INSERT INTO authority_codes VALUES('Shibuyunji','SBY');
INSERT INTO authority_codes VALUES('Chingola','CHN');
INSERT INTO authority_codes VALUES('Kalulushi','KLS');
INSERT INTO authority_codes VALUES('Kitwe','KIT');
INSERT INTO authority_codes VALUES('Luanshya','LUN');
INSERT INTO authority_codes VALUES('Lufwanyama','LFW');
CREATE TABLE employee_sequence (
    authority_code TEXT,
    year INTEGER,
    next_number INTEGER,
    PRIMARY KEY (authority_code, year)
);
INSERT INTO employee_sequence VALUES('CHL',2026,2);
CREATE TABLE vacation_allowances (
    allowance_id INTEGER PRIMARY KEY,
    employee_id INTEGER,
    amount INTEGER,
    granted_date DATE
, processed INTEGER DEFAULT 0);
CREATE TABLE approval_chain (
    employee_id INTEGER PRIMARY KEY,
    supervisor_id INTEGER NOT NULL,
    hod_id INTEGER,
    council_secretary_id INTEGER NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (supervisor_id) REFERENCES employees(employee_id),
    FOREIGN KEY (hod_id) REFERENCES employees(employee_id),
    FOREIGN KEY (council_secretary_id) REFERENCES employees(employee_id)
);
INSERT INTO approval_chain VALUES(901,1,NULL,1);
CREATE TABLE departments (
    dept_code TEXT PRIMARY KEY,
    dept_name TEXT NOT NULL
);
INSERT INTO departments VALUES('ENG','Engineering');
CREATE TABLE position_attributes (
    position_id TEXT NOT NULL,
    authority_type TEXT NOT NULL,   -- Town, Municipal, City
    title TEXT NOT NULL,
    salary_scale TEXT NOT NULL,
    establishment_count INTEGER NOT NULL, position_standard_id TEXT,
    FOREIGN KEY (position_id) REFERENCES positions(position_id)
);
INSERT INTO position_attributes VALUES('ENG-DIR','Town','Director of Engineering','LGSS/05',1,NULL);
INSERT INTO position_attributes VALUES('ENG-DIR','Municipal','Director of Engineering','LGSS/04',1,NULL);
INSERT INTO position_attributes VALUES('ENG-DIR','City','Director of Engineering','LGSS/03',1,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-HEAD','Town','Electrical Engineer','LGSS/07',1,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-HEAD','Municipal','Chief Electrical Engineer','LGSS/06',1,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-HEAD','City','Electrical Engineering Unit Head','LGSS/06',1,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-ASST','Town','Assistant Electrical Engineer','LGSS/10',1,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-ASST','Municipal','Electrical Engineer – Design','LGSS/07',1,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-ASST','City','Electrical Engineer – Design','LGSS/07',1,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-WRK','Town','Electrician','LGSS/14',2,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-WRK','Municipal','Electrician','LGSS/14',5,NULL);
INSERT INTO position_attributes VALUES('ENG-ELEC-WRK','City','Electrician','LGSS/14',5,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-HEAD','Town','Divisional Fire Officer','LGSS/08',1,NULL);
CREATE TABLE authorities (
    authority_prefix TEXT PRIMARY KEY,
    authority_name TEXT NOT NULL,
    authority_type TEXT NOT NULL   -- Town, Municipal, City
);
CREATE TABLE position_supervisors (
    position_id TEXT NOT NULL,
    supervisor_id TEXT NOT NULL,
    authority_type TEXT NOT NULL, position_standard_id TEXT, supervisor_standard_id TEXT,
    FOREIGN KEY (position_id) REFERENCES positions(position_id),
    FOREIGN KEY (supervisor_id) REFERENCES positions(position_id)
);
INSERT INTO position_supervisors VALUES('ENG-FIRE-FF','ENG-FIRE-SUB','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-SUB','ENG-FIRE-STN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-STN','ENG-FIRE-HEAD','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-FF','ENG-FIRE-SUB','Municipal',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-SUB','ENG-FIRE-STN','Municipal',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-STN','ENG-FIRE-HEAD','Municipal',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-FF','ENG-FIRE-SUB','City',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-SUB','ENG-FIRE-STN','City',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-FIRE-STN','ENG-FIRE-HEAD','City',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-ELEC-WRK','ENG-ELEC-HEAD','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-ELEC-WRK','ENG-ELEC-HEAD','Municipal',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-ELEC-WRK','ENG-ELEC-HEAD','City',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-MECHNIC','ENG-MECH-HEAD','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('ENG-MECHNIC','ENG-MECH-HEAD','Municipal',NULL,NULL);
CREATE TABLE ReportingLines (
    id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    reports_to TEXT, position_standard_id TEXT, reports_to_standard_id TEXT,
    FOREIGN KEY (position_id) REFERENCES Positions(position_id),
    FOREIGN KEY (reports_to) REFERENCES Positions(position_id)
);
CREATE TABLE LeaveApprovalChains (
    id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    supervisor TEXT NOT NULL,
    hod TEXT NOT NULL,
    top_authority TEXT NOT NULL, position_standard_id TEXT, approver_standard_id TEXT,
    FOREIGN KEY (position_id) REFERENCES Positions(position_id)
);
CREATE TABLE Councils (
    council_id SERIAL PRIMARY KEY,
    council_name TEXT NOT NULL,
    top_authority TEXT NOT NULL
);
INSERT INTO Councils VALUES(1,'Town Council','Council Secretary');
INSERT INTO Councils VALUES(2,'Municipal Council','Town Clerk');
INSERT INTO Councils VALUES(3,'City Council','Town Clerk');
INSERT INTO Councils VALUES(4,'Ndola City Council','Town Clerk');
INSERT INTO Councils VALUES(5,'Kitwe City Council','Town Clerk');
INSERT INTO Councils VALUES(6,'Livingstone City Council','Town Clerk');
INSERT INTO Councils VALUES(7,'Chipata City Council','Town Clerk');
CREATE TABLE HRA_Positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER,
    council_id INTEGER, standard_id TEXT,
    FOREIGN KEY (council_id) REFERENCES Councils(council_id)
);
INSERT INTO HRA_Positions VALUES('HR-DIR-TOWN','Director of Human Resource & Administration','LGSS/05',1,1,'HRA-LEAD-DIR-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-CHRO-TOWN','Chief Human Resources Officer','LGSS/06',1,1,'HRA-HRM-CHIEF-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-SNR-HRO-TOWN','Senior Human Resource Officer','LGSS/07',1,1,'HRA-HRM-SNR-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-HRO-TOWN','Human Resources Officer','LGSS/08',3,1,'HRA-HRM-OFF-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-CH-ADMIN-TOWN','Chief Administrative & Committee Officer','LGSS/06',1,1,'HRA-ADM-CHIEF-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-ADMIN-TOWN','Administrative Officer','LGSS/10',1,1,'HRA-ADM-OFF-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-SEC-TOWN','Personal Secretary','LGSS/10',1,1,'HRA-ADM-SEC-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-STENO-TOWN','Stenographer','LGSS/12',1,1,'HRA-ADM-STEN-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-TYPIST-TOWN','Typist','LGSS/14',2,1,'HRA-ADM-TYP-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-ORDERLY-TOWN','Office Orderly','G3',6,1,'HRA-SUP-ORD-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-DRIVER-TOWN','Driver','G1',4,1,'HRA-SUP-DRV1-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-ADMIN-HEALTH-TOWN','Administrative Officer','LGSS/10',1,1,'HRA-ADM-OFF-TOW-02');
INSERT INTO HRA_Positions VALUES('HR-STENO-HEALTH-TOWN','Stenographer','LGSS/12',1,1,'HRA-ADM-STEN-TOW-02');
CREATE TABLE HRA_ReportingLines (
    id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    reports_to TEXT,
    FOREIGN KEY (position_id) REFERENCES HRA_Positions(position_id),
    FOREIGN KEY (reports_to) REFERENCES HRA_Positions(position_id)
);
CREATE TABLE HRA_LeaveApprovalChains (
    id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    supervisor TEXT NOT NULL,
    hod TEXT NOT NULL,
    top_authority TEXT NOT NULL,
    FOREIGN KEY (position_id) REFERENCES HRA_Positions(position_id)
);
CREATE TABLE hra_position_attributes (
    position_id TEXT PRIMARY KEY,
    authority_type TEXT NOT NULL,   -- Town, Municipal, City
    title TEXT NOT NULL,
    salary_scale TEXT NOT NULL,
    establishment_count INTEGER NOT NULL
);
CREATE TABLE hra_position_supervisors (
    position_id TEXT NOT NULL,
    supervisor_id TEXT NOT NULL,
    authority_type TEXT NOT NULL,
    FOREIGN KEY (position_id) REFERENCES hra_position_attributes(position_id),
    FOREIGN KEY (supervisor_id) REFERENCES hra_position_attributes(position_id)
);
INSERT INTO hra_position_supervisors VALUES('HR-DIR-TOWN','COUNC-SEC','Town');
INSERT INTO hra_position_supervisors VALUES('HR-CHRO-TOWN','HR-DIR-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SNR-HRO-TOWN','HR-CHRO-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-HRO-TOWN','HR-SNR-HRO-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-COMM-CLERK-TOWN','HR-CH-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-ASST-COMM-TOWN','HR-COMM-CLERK-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-REG-SUP-TOWN','HR-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-REG-CLERK-TOWN','HR-REG-SUP-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SNR-SEC-TOWN','HR-DIR-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SEC-OFFICER-TOWN','HR-SNR-SEC-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SERGEANT-TOWN','HR-SNR-SEC-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SUB-INSPECTOR-TOWN','HR-SNR-SEC-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-POLICE-TOWN','HR-SNR-SEC-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-DIR-TOWN','COUNC-SEC','Town');
CREATE TABLE hra_leave_approval_chain (
    position_id TEXT NOT NULL,
    approval_chain TEXT NOT NULL,
    authority_type TEXT NOT NULL,
    FOREIGN KEY (position_id) REFERENCES hra_position_attributes(position_id)
);
INSERT INTO hra_leave_approval_chain VALUES('HR-DIR-TOWN','Officer → Supervisor (Council Secretary) → HoD (Council Secretary) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-CHRO-TOWN','Officer → Supervisor (HR-DIR-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SNR-HRO-TOWN','Officer → Supervisor (HR-CHRO-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-HRO-TOWN','Officer → Supervisor (HR-SNR-HRO-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-COMM-CLERK-TOWN','Officer → Supervisor (HR-CH-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-ASST-COMM-TOWN','Officer → Supervisor (HR-COMM-CLERK-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-REG-SUP-TOWN','Officer → Supervisor (HR-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-REG-CLERK-TOWN','Officer → Supervisor (HR-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SNR-SEC-TOWN','Officer → Supervisor (HR-DIR-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SEC-OFFICER-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SERGEANT-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SUB-INSPECTOR-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-POLICE-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-DIR-TOWN','Officer → Supervisor (Council Secretary) → HoD (Council Secretary) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-CHRO-TOWN','Officer → Supervisor (HR-DIR-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
CREATE TABLE sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    description TEXT
);
INSERT INTO sections VALUES(1,'Leadership','LEAD-MC','Municipal Council Leadership');
INSERT INTO sections VALUES(2,'Human Resource Section','HR-MC','Human Resource Management - Municipal');
INSERT INTO sections VALUES(3,'Administration Section','ADMIN-MC','General Administration - Municipal');
INSERT INTO sections VALUES(4,'Registry Unit','REG-MC','Records Management - Municipal');
INSERT INTO sections VALUES(5,'Committee Section','COMM-MC','Committee Services - Municipal');
INSERT INTO sections VALUES(6,'Security Section','SEC-MC','Security Services - Municipal');
INSERT INTO sections VALUES(7,'Leadership','LEAD-CC','City Council Leadership');
INSERT INTO sections VALUES(8,'HR Management & Development','HRMD-CC','Human Resource Management and Development - City');
INSERT INTO sections VALUES(9,'Administration Section','ADMIN-SEC-CC','Administration Section - City');
INSERT INTO sections VALUES(10,'Administration Unit','ADMIN-UNIT-CC','Administration Unit - City');
INSERT INTO sections VALUES(11,'Registry Unit','REG-CC','Records Management - City');
INSERT INTO sections VALUES(12,'Committee Section','COMM-CC','Committee Services - City');
INSERT INTO sections VALUES(13,'Security Section','SEC-CC','Security Services - City');
CREATE TABLE positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    section_id INTEGER,
    salary_scale TEXT,
    proposed_establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    level INTEGER,
    is_head_of_section BOOLEAN DEFAULT 0,
    council_type_id INTEGER DEFAULT 2, -- Default to Municipal Council
    FOREIGN KEY (section_id) REFERENCES sections(section_id),
    FOREIGN KEY (reports_to) REFERENCES positions(position_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO positions VALUES('HRA-DIR-MUN','Director of Human Resource & Administration',1,'LGSS/04',1,NULL,1,1,2);
INSERT INTO positions VALUES('HRA-CHRO-MUN','Chief Human Resource Officer',2,'LGSS/06',1,'HRA-DIR-MUN',2,1,2);
INSERT INTO positions VALUES('HRA-SNR-HRO-MUN','Senior Human Resource Officer',2,'LGSS/07',2,'HRA-CHRO-MUN',3,0,2);
INSERT INTO positions VALUES('HRA-HRO-MUN','Human Resource Officer',2,'LGSS/08',7,'HRA-SNR-HRO-MUN',4,0,2);
INSERT INTO positions VALUES('HRA-CH-ADMIN-MUN','Chief Administrative Officer',3,'LGSS/06',1,'HRA-DIR-MUN',2,1,2);
INSERT INTO positions VALUES('HRA-SNR-ADMIN-MUN','Senior Administrative Officer',3,'LGSS/07',2,'HRA-CH-ADMIN-MUN',3,0,2);
INSERT INTO positions VALUES('HRA-ADMIN-MUN','Administrative Officer',3,'LGSS/08',6,'HRA-SNR-ADMIN-MUN',4,0,2);
CREATE TABLE leave_approval_chain (
    chain_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES positions(position_id)
);
INSERT INTO leave_approval_chain VALUES(1,'HRA-DIR-MUN',1,'Supervisor',NULL);
INSERT INTO leave_approval_chain VALUES(2,'HRA-DIR-MUN',2,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(3,'HRA-DIR-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(4,'HRA-DIR-MUN',4,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(5,'HRA-CHRO-MUN',1,'Supervisor','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(6,'HRA-CHRO-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(7,'HRA-CHRO-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(8,'HRA-SNR-HRO-MUN',1,'Supervisor','HRA-CHRO-MUN');
INSERT INTO leave_approval_chain VALUES(9,'HRA-SNR-HRO-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(10,'HRA-SNR-HRO-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(11,'HRA-HRO-MUN',1,'Supervisor','HRA-SNR-HRO-MUN');
INSERT INTO leave_approval_chain VALUES(12,'HRA-HRO-MUN',2,'HoD','HRA-DIR-MUN');
CREATE TABLE eng_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    parent_unit_id INTEGER,
    council_type_id INTEGER,
    FOREIGN KEY (parent_unit_id) REFERENCES eng_units(unit_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO eng_units VALUES(1,'Council Administration','TC-ADMIN',NULL,1);
INSERT INTO eng_units VALUES(2,'Engineering Section','TC-ENG',NULL,1);
INSERT INTO eng_units VALUES(3,'Electrical Unit','TC-ELEC',NULL,1);
INSERT INTO eng_units VALUES(4,'Maintenance Unit','TC-MAINT',NULL,1);
INSERT INTO eng_units VALUES(5,'Quantity Surveying Unit','TC-QS',NULL,1);
INSERT INTO eng_units VALUES(6,'Architecture Unit','TC-ARCH',NULL,1);
INSERT INTO eng_units VALUES(7,'Parks and Gardens Unit','TC-PARK',NULL,1);
INSERT INTO eng_units VALUES(8,'Roads and Drainages Unit','TC-ROADS',NULL,1);
INSERT INTO eng_units VALUES(9,'Mechanical Services Unit','TC-MECH',NULL,1);
INSERT INTO eng_units VALUES(10,'Vehicle Maintenance Services Sub-Unit','TC-VMS',NULL,1);
INSERT INTO eng_units VALUES(11,'Fire and Rescue Services Unit','TC-FIRE',NULL,1);
INSERT INTO eng_units VALUES(12,'Rural Water and Sanitation Unit','TC-WATSAN',NULL,1);
CREATE TABLE eng_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment_count INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER,
    level INTEGER,
    is_head_of_unit BOOLEAN DEFAULT 0, standard_id TEXT,
    FOREIGN KEY (unit_id) REFERENCES eng_units(unit_id),
    FOREIGN KEY (reports_to) REFERENCES eng_positions(position_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (salary_scale) REFERENCES salary_scales(scale_code)
);
INSERT INTO eng_positions VALUES('COUNC-SEC','Council Secretary','LGSS03',1,NULL,1,1,1,1,NULL);
INSERT INTO eng_positions VALUES('ENG-DIR-TC','Director - Engineering','LGSS05',1,'COUNC-SEC',2,1,2,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ASST-DIR-TC','Assistant Director - Engineering','LGSS06',1,'ENG-DIR-TC',2,1,3,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-CHIEF-TC','Chief Electrical Engineer','LGSS06',1,'ENG-ASST-DIR-TC',3,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-HEAD-TC','Electrical Engineer','LGSS07',1,'ENG-ASST-DIR-TC',3,1,4,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ASST-TC','Assistant Electrical Engineer','LGSS10',1,'ENG-ELEC-HEAD-TC',3,1,5,0,NULL);
CREATE TABLE eng_leave_approval_chain (
    chain_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES eng_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES eng_positions(position_id)
);
INSERT INTO eng_leave_approval_chain VALUES(1,'COUNCIL-SEC',1,'Supervisor',NULL);
INSERT INTO eng_leave_approval_chain VALUES(2,'COUNCIL-SEC',2,'Head of Council',NULL);
INSERT INTO eng_leave_approval_chain VALUES(3,'COUNCIL-SEC',3,'Head of Council',NULL);
INSERT INTO eng_leave_approval_chain VALUES(4,'ENG-DIR-TC',1,'Supervisor','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(5,'ENG-DIR-TC',2,'Head of Department','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(6,'ENG-DIR-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(7,'ENG-ASST-DIR-TC',1,'Supervisor','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(8,'ENG-ASST-DIR-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(9,'ENG-ASST-DIR-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(10,'ENG-ELEC-CHIEF-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(11,'ENG-ELEC-CHIEF-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(12,'ENG-ELEC-CHIEF-TC',3,'Head of Council','COUNCIL-SEC');
CREATE TABLE planning_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO planning_sections VALUES(1,'Council Administration','TC-ADMIN',1,NULL);
INSERT INTO planning_sections VALUES(2,'Planning Leadership','TC-LEAD',1,NULL);
INSERT INTO planning_sections VALUES(3,'Physical Planning','TC-PHYS',1,NULL);
INSERT INTO planning_sections VALUES(4,'Socio-Economic Planning','TC-SOC',1,NULL);
INSERT INTO planning_sections VALUES(5,'Specialized Units','TC-SPEC',1,NULL);
INSERT INTO planning_sections VALUES(6,'Council Administration','MC-ADMIN',2,NULL);
INSERT INTO planning_sections VALUES(7,'Planning Leadership','MC-LEAD',2,NULL);
INSERT INTO planning_sections VALUES(8,'Physical Planning','MC-PHYS',2,NULL);
INSERT INTO planning_sections VALUES(9,'Valuation Section','MC-VAL',2,NULL);
INSERT INTO planning_sections VALUES(10,'Socio-Economic Planning','MC-SOC',2,NULL);
INSERT INTO planning_sections VALUES(11,'Council Administration','CC-ADMIN',3,NULL);
INSERT INTO planning_sections VALUES(12,'Planning Leadership','CC-LEAD',3,NULL);
INSERT INTO planning_sections VALUES(13,'Physical Planning','CC-PHYS',3,NULL);
CREATE TABLE planning_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES planning_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES planning_units(unit_id)
);
INSERT INTO planning_units VALUES(1,'Town Planning Unit','TC-TOWN',3,1,NULL);
INSERT INTO planning_units VALUES(2,'Building Inspectorate','TC-BI',3,1,NULL);
INSERT INTO planning_units VALUES(3,'Land Survey Unit','TC-LS',3,1,NULL);
INSERT INTO planning_units VALUES(4,'Valuation Unit','TC-VAL',3,1,NULL);
INSERT INTO planning_units VALUES(5,'Town Planning Unit','MC-TOWN',8,2,NULL);
INSERT INTO planning_units VALUES(6,'Buildings Inspectorate','MC-BI',8,2,NULL);
INSERT INTO planning_units VALUES(7,'Land Survey Unit','MC-LS',8,2,NULL);
INSERT INTO planning_units VALUES(8,'Town Planning Unit','CC-TOWN',13,3,NULL);
INSERT INTO planning_units VALUES(9,'Buildings Inspectorate','CC-BI',13,3,NULL);
INSERT INTO planning_units VALUES(10,'Land Survey Unit','CC-LS',13,3,NULL);
CREATE TABLE planning_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_type_id INTEGER,
    level INTEGER,
    is_head_of_unit BOOLEAN DEFAULT 0,
    is_head_of_section BOOLEAN DEFAULT 0, standard_id TEXT,
    FOREIGN KEY (unit_id) REFERENCES planning_units(unit_id),
    FOREIGN KEY (section_id) REFERENCES planning_sections(section_id),
    FOREIGN KEY (reports_to) REFERENCES planning_positions(position_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (salary_scale) REFERENCES salary_scales(scale_code)
);
INSERT INTO planning_positions VALUES('PLAN-DIR-TOWN','Director of Planning','LGSS/05',1,'COUNCIL-SEC-TOWN',NULL,2,1,2,0,1,'PLN-LEAD-DIR-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-CH-PHY-TOWN','Chief Physical Planner','LGSS/06',1,'PLAN-DIR-TOWN',NULL,3,1,3,1,1,'PLN-PHY-CHIEF-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-TOWN-TOWN','Town Planner','LGSS/07',1,'PLAN-CH-PHY-TOWN',1,3,1,4,1,0,'PLN-PHY-TOWNPLN-TOW-01');
CREATE TABLE planning_leave_approval_chain (
    chain_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES planning_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES planning_positions(position_id)
);
INSERT INTO planning_leave_approval_chain VALUES(19,'COUNCIL-SEC-TOWN',1,'Supervisor',NULL);
INSERT INTO planning_leave_approval_chain VALUES(20,'COUNCIL-SEC-TOWN',2,'Head of Council',NULL);
INSERT INTO planning_leave_approval_chain VALUES(21,'COUNCIL-SEC-TOWN',3,'Head of Council',NULL);
INSERT INTO planning_leave_approval_chain VALUES(22,'PLAN-DIR-TOWN',1,'Supervisor','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(23,'PLAN-DIR-TOWN',2,'Head of Department','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(24,'PLAN-DIR-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(25,'PLAN-CH-PHY-TOWN',1,'Supervisor','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(26,'PLAN-CH-PHY-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(27,'PLAN-CH-PHY-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(28,'PLAN-TOWN-TOWN',1,'Supervisor','PLAN-CH-PHY-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(29,'PLAN-TOWN-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(30,'PLAN-TOWN-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
CREATE TABLE finance_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO finance_sections VALUES(1,'Finance Leadership','FIN-LEAD-TC',1,NULL);
INSERT INTO finance_sections VALUES(2,'Finance Section','FIN-SEC-TC',1,NULL);
INSERT INTO finance_sections VALUES(3,'Finance - Health Services','FIN-HEALTH-TC',1,NULL);
INSERT INTO finance_sections VALUES(4,'Commercial & Business Development','FIN-COMM-TC',1,NULL);
INSERT INTO finance_sections VALUES(5,'Stores Section','FIN-STORE-TC',1,NULL);
INSERT INTO finance_sections VALUES(6,'Finance Leadership','FIN-LEAD-MC',2,NULL);
INSERT INTO finance_sections VALUES(7,'Finance Section','FIN-SEC-MC',2,NULL);
INSERT INTO finance_sections VALUES(8,'Stores Section','FIN-STORE-MC',2,NULL);
INSERT INTO finance_sections VALUES(9,'Finance Leadership','FIN-LEAD-CC',3,NULL);
INSERT INTO finance_sections VALUES(10,'Revenue Section','FIN-REV-CC',3,NULL);
INSERT INTO finance_sections VALUES(11,'Expenditure Section','FIN-EXP-CC',3,NULL);
INSERT INTO finance_sections VALUES(12,'Stores Section','FIN-STORE-CC',3,NULL);
CREATE TABLE finance_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES finance_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES finance_units(unit_id)
);
INSERT INTO finance_units VALUES(1,'Finance Section','FIN-SEC-UNIT-TC',2,1,NULL);
INSERT INTO finance_units VALUES(2,'Health Services Finance','FIN-HEALTH-UNIT-TC',3,1,NULL);
INSERT INTO finance_units VALUES(3,'Commercial Services','FIN-COMM-UNIT-TC',4,1,NULL);
INSERT INTO finance_units VALUES(4,'Stores Section','FIN-STORE-UNIT-TC',5,1,NULL);
INSERT INTO finance_units VALUES(5,'Finance Section','FIN-SEC-UNIT-MC',7,2,NULL);
INSERT INTO finance_units VALUES(6,'Stores Section','FIN-STORE-UNIT-MC',8,2,NULL);
INSERT INTO finance_units VALUES(7,'Revenue Section','FIN-REV-UNIT-CC',10,3,NULL);
INSERT INTO finance_units VALUES(8,'Expenditure Section','FIN-EXP-UNIT-CC',11,3,NULL);
INSERT INTO finance_units VALUES(9,'Stores Section','FIN-STORE-UNIT-CC',12,3,NULL);
CREATE TABLE finance_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_type_id INTEGER,
    level INTEGER,
    is_head_of_section BOOLEAN DEFAULT 0,
    is_head_of_unit BOOLEAN DEFAULT 0, standard_id TEXT,
    FOREIGN KEY (unit_id) REFERENCES finance_units(unit_id),
    FOREIGN KEY (section_id) REFERENCES finance_sections(section_id),
    FOREIGN KEY (reports_to) REFERENCES finance_positions(position_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (salary_scale) REFERENCES salary_scales(scale_code)
);
INSERT INTO finance_positions VALUES('FIN-DIR-TOWN','Director of Finance','LGSS/05',1,'COUNCIL-SEC-TOWN',NULL,1,1,2,1,0,'FIN-LEAD-DIR-TOW-01');
INSERT INTO finance_positions VALUES('FIN-CHACC-TOWN','Chief Accountant','LGSS/06',1,'FIN-DIR-TOWN',1,2,1,3,0,1,'FIN-ACC-CHIEF-TOW-01');
INSERT INTO finance_positions VALUES('FIN-ACC-TOWN','Accountant','LGSS/08',1,'FIN-CHACC-TOWN',1,2,1,4,0,0,'FIN-ACC-OFF-TOW-01');
CREATE TABLE finance_leave_approval_chain (
    chain_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES finance_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES finance_positions(position_id)
);
INSERT INTO finance_leave_approval_chain VALUES(1,'COUNCIL-SEC-TOWN',1,'Supervisor',NULL);
INSERT INTO finance_leave_approval_chain VALUES(2,'COUNCIL-SEC-TOWN',2,'Head of Council',NULL);
INSERT INTO finance_leave_approval_chain VALUES(3,'COUNCIL-SEC-TOWN',3,'Head of Council',NULL);
INSERT INTO finance_leave_approval_chain VALUES(4,'FIN-DIR-TOWN',1,'Supervisor','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(5,'FIN-DIR-TOWN',2,'Head of Department','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(6,'FIN-DIR-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(7,'FIN-CHACC-TOWN',1,'Supervisor','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(8,'FIN-CHACC-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(9,'FIN-CHACC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(10,'FIN-ACC-TOWN',1,'Supervisor','FIN-CHACC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(11,'FIN-ACC-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(12,'FIN-ACC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
CREATE TABLE legal_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO legal_sections VALUES(1,'Legal Services','LEG-SERV-TC',1,NULL);
INSERT INTO legal_sections VALUES(2,'Legal Leadership','LEG-LEAD-MC',2,NULL);
INSERT INTO legal_sections VALUES(3,'Litigation and Deeds Section','LEG-LIT-MC',2,NULL);
INSERT INTO legal_sections VALUES(4,'Estates and Contracts & Licensing Section','LEG-EST-MC',2,NULL);
INSERT INTO legal_sections VALUES(5,'Legal Leadership','LEG-LEAD-CC',3,NULL);
INSERT INTO legal_sections VALUES(6,'Litigation and Deeds Section','LEG-LIT-CC',3,NULL);
INSERT INTO legal_sections VALUES(7,'Estates and Contracts & Licensing Section','LEG-EST-CC',3,NULL);
CREATE TABLE legal_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES legal_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES legal_units(unit_id)
);
INSERT INTO legal_units VALUES(1,'Legal Services','LEG-UNIT-TC',1,1,NULL);
INSERT INTO legal_units VALUES(2,'Litigation Unit','LEG-LIT-UNIT-MC',3,2,NULL);
INSERT INTO legal_units VALUES(3,'Deeds Unit','LEG-DEEDS-UNIT-MC',3,2,NULL);
INSERT INTO legal_units VALUES(4,'Prosecution Unit','LEG-PROSE-UNIT-MC',3,2,NULL);
INSERT INTO legal_units VALUES(5,'Contracts Unit','LEG-CONT-UNIT-MC',4,2,NULL);
INSERT INTO legal_units VALUES(6,'Licensing Unit','LEG-LIC-UNIT-MC',4,2,NULL);
INSERT INTO legal_units VALUES(7,'Estates Unit','LEG-EST-UNIT-MC',4,2,NULL);
INSERT INTO legal_units VALUES(8,'Litigation Unit','LEG-LIT-UNIT-CC',6,3,NULL);
INSERT INTO legal_units VALUES(9,'Deeds Unit','LEG-DEEDS-UNIT-CC',6,3,NULL);
INSERT INTO legal_units VALUES(10,'Contracts & Licensing Unit','LEG-CONT-UNIT-CC',7,3,NULL);
CREATE TABLE legal_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_type_id INTEGER,
    level INTEGER,
    is_head_of_section BOOLEAN DEFAULT 0,
    is_head_of_unit BOOLEAN DEFAULT 0, standard_id TEXT,
    FOREIGN KEY (unit_id) REFERENCES legal_units(unit_id),
    FOREIGN KEY (section_id) REFERENCES legal_sections(section_id),
    FOREIGN KEY (reports_to) REFERENCES legal_positions(position_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (salary_scale) REFERENCES salary_scales(scale_code)
);
INSERT INTO legal_positions VALUES('COUNCIL-SEC-TOWN','Council Secretary','LGSS/03',1,NULL,NULL,NULL,1,1,1,0,NULL);
INSERT INTO legal_positions VALUES('LEG-ADV-TOWN','Council Advocate','LGSS/05',1,'COUNCIL-SEC-TOWN',1,1,1,2,1,1,'LEG-LEAD-ADV-TOW-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-TOWN','Senior Legal Assistant','LGSS/07',2,'LEG-ADV-TOWN',1,1,1,3,0,0,'LEG-ADV-SRASST-TOW-01');
CREATE TABLE legal_leave_approval_chain (
    chain_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES legal_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES legal_positions(position_id)
);
INSERT INTO legal_leave_approval_chain VALUES(1,'COUNCIL-SEC-TOWN',1,'Supervisor',NULL);
INSERT INTO legal_leave_approval_chain VALUES(2,'COUNCIL-SEC-TOWN',2,'Head of Council',NULL);
INSERT INTO legal_leave_approval_chain VALUES(3,'COUNCIL-SEC-TOWN',3,'Head of Council',NULL);
INSERT INTO legal_leave_approval_chain VALUES(4,'LEG-ADV-TOWN',1,'Supervisor','COUNCIL-SEC-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(5,'LEG-ADV-TOWN',2,'Head of Department','COUNCIL-SEC-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(6,'LEG-ADV-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(7,'LEG-SRASST-TOWN',1,'Supervisor','LEG-ADV-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(8,'LEG-SRASST-TOWN',2,'Head of Department','COUNCIL-SEC-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(9,'LEG-SRASST-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(10,'LEG-REG-TOWN',1,'Supervisor','LEG-SRASST-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(11,'LEG-REG-TOWN',2,'Head of Department','COUNCIL-SEC-TOWN');
INSERT INTO legal_leave_approval_chain VALUES(12,'LEG-REG-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
CREATE TABLE council_types (
    council_type_id SERIAL PRIMARY KEY,
    council_type_code TEXT UNIQUE NOT NULL,
    council_type_name TEXT NOT NULL,
    head_of_council_title TEXT NOT NULL,
    head_of_council_scale TEXT NOT NULL
);
INSERT INTO council_types VALUES(1,'TC','Town Council','Council Secretary','LGSS/03');
INSERT INTO council_types VALUES(2,'MC','Municipal Council','Town Clerk','LGSS/02');
INSERT INTO council_types VALUES(3,'CC','City Council','Town Clerk','LGSS/01');
CREATE TABLE salary_scales (
    scale_id SERIAL PRIMARY KEY,
    scale_code TEXT UNIQUE NOT NULL,
    scale_name TEXT,
    level INTEGER,
    applicable_to TEXT
);
INSERT INTO salary_scales VALUES(1,'LGSS/01','Town Clerk - City Council',1,'City Council');
INSERT INTO salary_scales VALUES(2,'LGSS/02','Town Clerk - Municipal Council',2,'Municipal Council');
INSERT INTO salary_scales VALUES(3,'LGSS/03','Council Secretary - Town Council',3,'Town Council');
INSERT INTO salary_scales VALUES(4,'LGSS/05','Assistant Director - Public Health (Municipal/City)',5,'Municipal/City Council');
INSERT INTO salary_scales VALUES(5,'LGSS/06','Assistant Director - Public Health (Town) / Chief Officer',6,'All');
INSERT INTO salary_scales VALUES(6,'LGSS/07','Senior Officer Level',7,'All');
INSERT INTO salary_scales VALUES(7,'LGSS/08','Officer Level',8,'All');
INSERT INTO salary_scales VALUES(8,'LGSS/09','Superintendent Level',9,'All');
INSERT INTO salary_scales VALUES(9,'LGSS/10','Assistant Superintendent Level',10,'All');
INSERT INTO salary_scales VALUES(10,'LGSS/17','Support Staff Level',17,'All');
INSERT INTO salary_scales VALUES(11,'LGSS','General LGSS Scale',15,'All');
INSERT INTO salary_scales VALUES(12,'G1','General Staff Level 1',20,'All');
INSERT INTO salary_scales VALUES(13,'G3','General Staff Level 3',22,'All');
CREATE TABLE health_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO health_sections VALUES(1,'Health Leadership','HLTH-LEAD-TC',1,NULL);
INSERT INTO health_sections VALUES(2,'Health Leadership','HLTH-LEAD-MC',2,NULL);
INSERT INTO health_sections VALUES(3,'Health Leadership','HLTH-LEAD-CC',3,NULL);
CREATE TABLE health_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES health_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES health_units(unit_id)
);
INSERT INTO health_units VALUES(1,'Environmental Health Unit','HLTH-ENV-TC',1,1,NULL);
INSERT INTO health_units VALUES(2,'Health Inspectorate Unit','HLTH-HI-TC',1,1,NULL);
INSERT INTO health_units VALUES(3,'Cleansing and Pest Control Unit','HLTH-CLEAN-TC',1,1,NULL);
INSERT INTO health_units VALUES(4,'Funeral Services Unit','HLTH-FUN-TC',1,1,NULL);
INSERT INTO health_units VALUES(5,'Public Health Inspectorate Unit','HLTH-HI-MC',2,2,NULL);
INSERT INTO health_units VALUES(6,'Health Promotions Unit','HLTH-HP-MC',2,2,NULL);
INSERT INTO health_units VALUES(7,'Cleansing and Pest Control Unit','HLTH-CLEAN-MC',2,2,NULL);
INSERT INTO health_units VALUES(8,'Funeral and Burial Services Unit','HLTH-FUN-MC',2,2,NULL);
INSERT INTO health_units VALUES(9,'Health Information Systems Unit','HLTH-HIS-MC',2,2,NULL);
INSERT INTO health_units VALUES(10,'Environmental Health Unit','HLTH-ENV-CC',3,3,NULL);
CREATE TABLE health_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_type_id INTEGER,
    level INTEGER,
    is_head_of_section BOOLEAN DEFAULT 0,
    is_head_of_unit BOOLEAN DEFAULT 0, standard_id TEXT,
    FOREIGN KEY (unit_id) REFERENCES health_units(unit_id),
    FOREIGN KEY (section_id) REFERENCES health_sections(section_id),
    FOREIGN KEY (reports_to) REFERENCES health_positions(position_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (salary_scale) REFERENCES salary_scales(scale_code)
);
INSERT INTO health_positions VALUES('HLTH-ADIR-TOWN','Assistant Director - Public Health','LGSS/06',1,'COUNCIL-SEC-TOWN',NULL,1,1,2,1,0,'HLT-LEAD-ADIR-TOW-01');
INSERT INTO health_positions VALUES('HLTH-ENV-TECH-TOWN','Environmental Health Technologist','LGSS/09',2,'HLTH-ADIR-TOWN',1,1,1,3,0,1,'HLT-ENV-TECH-TOW-01');
INSERT INTO health_positions VALUES('HLTH-SNR-HIO-TOWN','Senior Health Inspection Officer','LGSS/07',1,'HLTH-ADIR-TOWN',2,1,1,3,0,1,'HLT-HIN-SNR-TOW-01');
CREATE TABLE health_leave_approval_chain (
    chain_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES health_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES health_positions(position_id)
);
INSERT INTO health_leave_approval_chain VALUES(1,'COUNCIL-SEC-TOWN',1,'Supervisor',NULL);
INSERT INTO health_leave_approval_chain VALUES(2,'COUNCIL-SEC-TOWN',2,'Head of Council',NULL);
INSERT INTO health_leave_approval_chain VALUES(3,'COUNCIL-SEC-TOWN',3,'Head of Council',NULL);
INSERT INTO health_leave_approval_chain VALUES(4,'HLTH-ADIR-TOWN',1,'Supervisor','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(5,'HLTH-ADIR-TOWN',2,'Head of Department','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(6,'HLTH-ADIR-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(7,'HLTH-ENV-TECH-TOWN',1,'Supervisor','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(8,'HLTH-ENV-TECH-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(9,'HLTH-ENV-TECH-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(10,'HLTH-SNR-HIO-TOWN',1,'Supervisor','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(11,'HLTH-SNR-HIO-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(12,'HLTH-SNR-HIO-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
CREATE TABLE leave_types (
    leave_type_id SERIAL PRIMARY KEY,
    leave_type_code TEXT UNIQUE NOT NULL,
    leave_type_name TEXT NOT NULL,
    description TEXT,
    requires_approval BOOLEAN DEFAULT 1,
    is_paid BOOLEAN DEFAULT 1,
    is_cumulative BOOLEAN DEFAULT 0,
    max_days_per_month INTEGER,
    max_days_per_year INTEGER,
    applicable_to TEXT, -- 'All', 'Female Only', 'Male Only', etc.
    requires_supervisor_notification BOOLEAN DEFAULT 1,
    requires_hr_notification BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO leave_types VALUES(1,'MOTHERS_DAY','Mother''s Day','One day off per month for female officers - non-cumulative. Notification to Supervisor and HR required.',0,1,0,1,12,'Female Only',1,1,'2026-02-23 22:26:25');
CREATE TABLE hr_recipients (
    recipient_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL UNIQUE,
    email TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
CREATE TABLE mothers_day_notification_log (
    notification_id SERIAL PRIMARY KEY,
    tracking_id INTEGER NOT NULL,
    recipient_type TEXT NOT NULL, -- 'Supervisor', 'HR'
    recipient_id INTEGER NOT NULL,
    recipient_name TEXT,
    recipient_email TEXT,
    notification_type TEXT DEFAULT 'Email',
    notification_subject TEXT,
    notification_body TEXT,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sent_by INTEGER, -- System or user ID who triggered
    status TEXT DEFAULT 'Sent', -- 'Sent', 'Failed', 'Delivered', 'Read'
    error_message TEXT,
    read_at TIMESTAMP,
    FOREIGN KEY (tracking_id) REFERENCES mothers_day_leave_tracking(tracking_id),
    FOREIGN KEY (recipient_id) REFERENCES employees(employee_id),
    FOREIGN KEY (sent_by) REFERENCES users(user_id)
);
CREATE TABLE mothers_day_acknowledgments (
    acknowledgment_id SERIAL PRIMARY KEY,
    tracking_id INTEGER NOT NULL,
    recipient_type TEXT NOT NULL, -- 'Supervisor', 'HR'
    recipient_id INTEGER NOT NULL,
    acknowledged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acknowledgment_method TEXT DEFAULT 'System', -- 'Email', 'Portal', 'Manual'
    ip_address TEXT,
    notes TEXT,
    FOREIGN KEY (tracking_id) REFERENCES mothers_day_leave_tracking(tracking_id),
    FOREIGN KEY (recipient_id) REFERENCES employees(employee_id)
);
CREATE TABLE notification_history (
    history_id SERIAL PRIMARY KEY,
    queue_id INTEGER,
    tracking_id INTEGER NOT NULL,
    recipient_type TEXT NOT NULL,
    recipient_id INTEGER NOT NULL,
    recipient_name TEXT,
    recipient_email TEXT,
    recipient_phone TEXT,
    notification_method TEXT NOT NULL,
    subject TEXT,
    message TEXT,
    sms_message TEXT,
    status TEXT,
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP,
    FOREIGN KEY (tracking_id) REFERENCES mothers_day_leave_tracking(tracking_id)
);
CREATE TABLE sms_gateway_config (
    config_id SERIAL PRIMARY KEY,
    gateway_name TEXT NOT NULL,
    gateway_url TEXT,
    api_key TEXT,
    sender_id TEXT DEFAULT 'COUNCIL',
    is_active INTEGER DEFAULT 1,
    max_sms_length INTEGER DEFAULT 160,
    supports_unicode INTEGER DEFAULT 0,
    cost_per_sms DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO sms_gateway_config VALUES(1,'Default SMS Gateway','http://sms-gateway.example.com/api/send',NULL,'COUNCIL',1,160,0,NULL,NULL,'2026-02-23 22:42:04','2026-02-23 22:42:04');
INSERT INTO sms_gateway_config VALUES(2,'Default SMS Gateway','http://sms-gateway.example.com/api/send',NULL,'COUNCIL',1,160,0,NULL,NULL,'2026-02-24 06:44:30','2026-02-24 06:44:30');
INSERT INTO sms_gateway_config VALUES(3,'Default SMS Gateway','http://sms-gateway.example.com/api/send',NULL,'COUNCIL',1,160,0,NULL,NULL,'2026-02-24 06:48:25','2026-02-24 06:48:25');
INSERT INTO sms_gateway_config VALUES(4,'Default SMS Gateway','http://sms-gateway.example.com/api/send',NULL,'COUNCIL',1,160,0,NULL,NULL,'2026-02-24 21:31:34','2026-02-24 21:31:34');
CREATE TABLE sms_delivery_log (
    sms_id SERIAL PRIMARY KEY,
    notification_queue_id INTEGER,
    phone_number TEXT NOT NULL,
    message TEXT,
    status TEXT DEFAULT 'Pending', -- 'Pending', 'Sent', 'Delivered', 'Failed'
    provider_message_id TEXT,
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    error_code TEXT,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (notification_queue_id) REFERENCES notification_queue(queue_id)
);
CREATE TABLE sms_message_parts (
    part_id SERIAL PRIMARY KEY,
    notification_queue_id INTEGER NOT NULL,
    part_number INTEGER NOT NULL,
    total_parts INTEGER NOT NULL,
    message_text TEXT NOT NULL,
    character_count INTEGER NOT NULL,
    status TEXT DEFAULT 'Pending',
    sent_at TIMESTAMP,
    FOREIGN KEY (notification_queue_id) REFERENCES notification_queue(queue_id)
);
CREATE TABLE mothers_day_leave_tracking (
    tracking_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    leave_date DATE NOT NULL,
    month_year TEXT NOT NULL,
    -- Supervisor (Approver)
    supervisor_id INTEGER,
    supervisor_notified INTEGER DEFAULT 0,
    supervisor_notification_date TIMESTAMP,
    supervisor_approved INTEGER DEFAULT 0,  -- Changed from acknowledged
    supervisor_approval_date TIMESTAMP,
    -- HR (Notification only)
    hr_notified INTEGER DEFAULT 0,
    hr_notification_date TIMESTAMP,
    hr_viewed INTEGER DEFAULT 0,  -- HR just needs to view/acknowledge receipt
    hr_viewed_date TIMESTAMP,
    status TEXT DEFAULT 'Pending', -- 'Pending', 'Approved', 'Completed'
    notification_method TEXT DEFAULT 'Both',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
CREATE TABLE notification_queue (
    queue_id SERIAL PRIMARY KEY,
    tracking_id INTEGER NOT NULL,
    recipient_type TEXT NOT NULL, -- 'Supervisor', 'HR'
    recipient_id INTEGER NOT NULL,
    recipient_name TEXT,
    recipient_email TEXT,
    recipient_phone TEXT,
    notification_type TEXT NOT NULL, -- 'Approval Request', 'Notification'
    subject TEXT,
    message TEXT,
    sms_message TEXT,
    status TEXT DEFAULT 'Pending',
    sent_at TIMESTAMP,
    viewed_at TIMESTAMP, -- For HR notifications
    action_taken_at TIMESTAMP, -- For Supervisor approval
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tracking_id) REFERENCES mothers_day_leave_tracking(tracking_id)
);
CREATE TABLE eng_position_hierarchy (
    hierarchy_id SERIAL PRIMARY KEY,
    position_id TEXT NOT NULL,
    position_title TEXT NOT NULL,
    unit TEXT,
    salary_scale TEXT,
    establishment_count INTEGER,
    reports_to_position_id TEXT,
    council_type TEXT,
    council_type_id INTEGER,
    level INTEGER, -- Will calculate later
    is_head_of_unit BOOLEAN DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, standard_id TEXT,
    FOREIGN KEY (reports_to_position_id) REFERENCES eng_position_hierarchy(position_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO eng_position_hierarchy VALUES(1,'COUNCIL-SEC','Council Secretary','Council Administration','LGSS03',1,NULL,'Town',1,1,1,'2026-02-25 13:37:54','ENG-ADM-COUNCSEC-TOW-ADMIN-01');
INSERT INTO eng_position_hierarchy VALUES(2,'ENG-DIR','Director - Engineering','Engineering Section','LGSS05',1,'COUNCIL-SEC','Town',1,2,1,'2026-02-25 13:37:54','ENG-GEN-DIRENG-TOW-GEN-01');
INSERT INTO eng_position_hierarchy VALUES(3,'ENG-ASST-DIR','Assistant Director - Engineering','Engineering Section','LGSS06',1,'ENG-DIR','Town',1,3,0,'2026-02-25 13:37:54','ENG-GEN-ADIRENG-TOW-GEN-01');
INSERT INTO eng_position_hierarchy VALUES(4,'ENG-ELEC-CHIEF','Chief Electrical Engineer','Electrical Unit','LGSS06',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-ELE-CHIEFELEC-TOW-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(5,'ENG-ELEC-HEAD','Electrical Engineer','Electrical Unit','LGSS07',1,'ENG-ASST-DIR','Town',1,4,0,'2026-02-25 13:37:54','ENG-ELE-ELECENG-TOW-ELEC-01');
CREATE TABLE position_standard_id_map(
  dept_code,
  old_id TEXT,
  position_title TEXT,
  council_type TEXT,
  unit_code,
  role_code,
  council_code,
  seq
);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH07','Architect','City','ARC','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH07','Architect','Municipal','ARC','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH','Architect','Town','ARC','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-ASSIST','Architectural Assistant','Municipal','ARC','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-ASST','Assistant Architect','City','ARC','ASST','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-ASST','Assistant Architect','Municipal','ARC','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-ASST','Assistant Architect','Town','ARC','ASST','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASST','Assistant Civil Engineer','City','GEN','ASSTENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASST','Assistant Civil Engineer','Municipal','GEN','ASSTENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASST','Assistant Civil Engineer','Town','GEN','ASSTENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CONSTR-ASSTDIR','Assistant Director - Construction & Maintenance','City','MTN','ADIR','CIT',1);
CREATE TABLE position_role_codes (
    position_title TEXT PRIMARY KEY,
    role_code TEXT UNIQUE,
    category TEXT
);
INSERT INTO position_role_codes VALUES('Council Secretary','COUNCSEC','Leadership');
INSERT INTO position_role_codes VALUES('Town Clerk','TOWNCLRK','Leadership');
INSERT INTO position_role_codes VALUES('Director - Engineering','DIRENG','Leadership');
INSERT INTO position_role_codes VALUES('Assistant Director - Engineering','ADIRENG','Leadership');
INSERT INTO position_role_codes VALUES('Assistant Director - Construction & Maintenance','ADIRCONST','Leadership');
INSERT INTO position_role_codes VALUES('Assistant Director - Roads & Drainages','ADIRROADS','Leadership');
INSERT INTO position_role_codes VALUES('Architect','ARCH','Architecture');
INSERT INTO position_role_codes VALUES('Assistant Architect','ASSTARCH','Architecture');
INSERT INTO position_role_codes VALUES('Chief Architect','CHIEFARCH','Architecture');
INSERT INTO position_role_codes VALUES('Architectural Assistant','ARCHASST','Architecture');
INSERT INTO position_role_codes VALUES('Draughtsman','DRAFT','Architecture');
INSERT INTO position_role_codes VALUES('Senior Clerk of Works','SNRCLRKWRK','Architecture');
INSERT INTO position_role_codes VALUES('Clerk of Works','CLRKWRK','Architecture');
INSERT INTO position_role_codes VALUES('Civil Engineer','CIVENG','Civil');
INSERT INTO position_role_codes VALUES('Chief Civil Engineer','CHIEFCIV','Civil');
INSERT INTO position_role_codes VALUES('Assistant Civil Engineer','ASSTCIV','Civil');
CREATE TABLE position_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,           -- Level 2: Direct supervisor
    hod_id TEXT,                            -- Level 3: Head of Department
    council_secretary_id TEXT,               -- Level 4: Council Secretary (final authority)
    council_type_id INTEGER NOT NULL,
    department TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (council_type_id) REFERENCES council_types(id)
);
INSERT INTO position_supervision VALUES(1,'FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(2,'FIN-ACC-CHIEF-TOW-01','FIN-LEAD-DIR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(3,'FIN-ACC-OFF-TOW-01','FIN-ACC-CHIEF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(4,'FIN-ACC-AST-TOW-01','FIN-ACC-OFF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(5,'FIN-HLT-ASTACC-TOW-01','FIN-ACC-CHIEF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(6,'FIN-HLT-AST-TOW-01','FIN-HLT-ASTACC-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(7,'FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(8,'FIN-COM-ASTMGR-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(9,'FIN-COM-CHIEFLIC-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
CREATE TABLE executive_positions (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    standard_id TEXT UNIQUE,
    council_type_id INTEGER,
    is_council_secretary BOOLEAN DEFAULT 0,
    is_head_of_department BOOLEAN DEFAULT 0,
    establishment INTEGER DEFAULT 1
);
INSERT INTO executive_positions VALUES(3,'Council Secretary','EXEC-SEC-TOW-01',1,1,1,1);
INSERT INTO executive_positions VALUES(4,'Town Clerk','EXEC-CLK-MUN-01',2,0,1,1);
INSERT INTO executive_positions VALUES(5,'Town Clerk','EXEC-CLK-CIT-01',3,0,1,1);
CREATE TABLE jd_upload_queue (
    id SERIAL PRIMARY KEY,
    filename TEXT,
    file_path TEXT,
    upload_status TEXT DEFAULT 'pending',  -- 'pending', 'processing', 'completed', 'error'
    extracted_title TEXT,
    suggested_standard_id TEXT,
    confidence_score INTEGER,
    needs_review BOOLEAN DEFAULT 1,
    uploaded_by TEXT,
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO jd_upload_queue VALUES(1,'JOB DESCRIPTION - DIRECTOR - FINANCE.docx','/uploads/town_finance/director.docx','completed','Director - Finance','FIN-LEAD-DIR-TOW-01',100,0,'HR_Admin','2026-02-27 22:36:12');
INSERT INTO jd_upload_queue VALUES(2,'JOB DESCRIPTION - CHIEF ACCOUNTANT.docx','/uploads/town_finance/chief_accountant.docx','completed','Chief Accountant','FIN-ACC-CHIEF-TOW-01',100,0,'HR_Admin','2026-02-27 22:36:12');
INSERT INTO jd_upload_queue VALUES(3,'JOB DESCRIPTION - DIRECTOR - FINANCE.docx','/uploads/town_finance/director_finance.docx','completed','Director - Finance','FIN-LEAD-DIR-TOW-01',100,0,'HR_Admin','2026-02-27 22:38:44');
INSERT INTO jd_upload_queue VALUES(4,'JOB DESCRIPTION - CHIEF ACCOUNTANT.docx','/uploads/town_finance/chief_accountant.docx','completed','Chief Accountant','FIN-ACC-CHIEF-TOW-01',100,0,'HR_Admin','2026-02-27 22:38:44');
CREATE TABLE job_description_documents (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT,
    original_filename TEXT,
    file_path TEXT,
    file_type TEXT,
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    position_title TEXT,
    grade TEXT,
    department TEXT,
    council_type_id INTEGER,
    reports_to_standard_id TEXT,
    is_current_version BOOLEAN DEFAULT 1,
    version INTEGER DEFAULT 1
, is_current BOOLEAN DEFAULT 1);
INSERT INTO job_description_documents VALUES(2,'FIN-LEAD-DIR-TOW-01','JOB DESCRIPTION - DIRECTOR - FINANCE.docx','/uploads/town_finance/director_finance.docx','.docx','2026-02-27 22:38:44','Director - Finance','LGSS/05','FIN',1,'EXEC-SEC-TOW-01',1,1,1);
INSERT INTO job_description_documents VALUES(4,'FIN-ACC-CHIEF-TOW-01','JOB DESCRIPTION - CHIEF ACCOUNTANT.docx','/Users/Work/Desktop/JD/Town/Finance/JOB DESCRIPTION - CHIEF ACCOUNTANT.docx','.docx','2026-02-27 22:38:44','Chief Accountant','LGSS/06','FIN',1,'FIN-LEAD-DIR-TOW-01',1,1,1);
CREATE TABLE jd_review_queue (
    id SERIAL PRIMARY KEY,
    jd_id INTEGER,
    suggested_standard_id TEXT,
    confidence_score INTEGER,
    needs_review BOOLEAN DEFAULT 1,
    reviewed_by TEXT,
    review_date DATETIME,
    approved BOOLEAN,
    notes TEXT,
    FOREIGN KEY (jd_id) REFERENCES job_description_documents(id)
);
CREATE TABLE hra_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_secretary_id TEXT,
    council_id INTEGER NOT NULL,
    department TEXT DEFAULT 'HRA',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO hra_supervision VALUES(1,'HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(2,'HRA-ADM-CHIEF-TOW-01','HRA-LEAD-DIR-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(3,'HRA-ADM-OFF-TOW-01','HRA-ADM-CHIEF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(4,'HRA-ADM-OFF-TOW-02','HRA-ADM-CHIEF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(5,'HRA-ADM-CLK-TOW-01','HRA-ADM-CHIEF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(6,'HRA-ADM-AST-TOW-01','HRA-ADM-CLK-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(7,'HRA-ADM-AST-TOW-02','HRA-ADM-CLK-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(8,'HRA-ADM-SUP-TOW-01','HRA-ADM-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(9,'HRA-ADM-REG-TOW-01','HRA-ADM-SUP-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(10,'HRA-HRM-CHIEF-TOW-01','HRA-LEAD-DIR-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
CREATE TABLE legal_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_secretary_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'LEG',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO legal_supervision VALUES(1,'LEG-LEAD-ADV-TOW-01','EXEC-SEC-TOW-01','LEG-LEAD-ADV-TOW-01','EXEC-SEC-TOW-01',1,'LEG',1,'2026-03-01 21:39:12');
INSERT INTO legal_supervision VALUES(2,'LEG-ADV-SRASST-TOW-01','LEG-LEAD-ADV-TOW-01','LEG-LEAD-ADV-TOW-01','EXEC-SEC-TOW-01',1,'LEG',1,'2026-03-01 21:39:12');
INSERT INTO legal_supervision VALUES(3,'LEG-ADM-REG-TOW-01','LEG-ADV-SRASST-TOW-01','LEG-LEAD-ADV-TOW-01','EXEC-SEC-TOW-01',1,'LEG',1,'2026-03-01 21:39:13');
INSERT INTO legal_supervision VALUES(4,'LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(5,'LEG-LEAD-ADV-ESTCON-MUN-01','LEG-LEAD-DIR-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(6,'LEG-LEAD-ADV-LIT-MUN-01','LEG-LEAD-DIR-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(7,'LEG-ESTCON-OFF-CONT-MUN-01','LEG-LEAD-ADV-ESTCON-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(8,'LEG-ESTCON-OFF-EST-MUN-01','LEG-LEAD-ADV-ESTCON-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(9,'LEG-ESTCON-OFF-LIC-MUN-01','LEG-LEAD-ADV-ESTCON-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(10,'LEG-LIT-OFF-LIT-MUN-01','LEG-LEAD-ADV-LIT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
CREATE TABLE health_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_secretary_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'HLT',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO health_supervision VALUES(1,'HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:46');
INSERT INTO health_supervision VALUES(2,'HLT-ENV-TECH-TOW-01','HLT-LEAD-ADIR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:46');
INSERT INTO health_supervision VALUES(3,'HLT-HIN-SNR-TOW-01','HLT-LEAD-ADIR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:46');
INSERT INTO health_supervision VALUES(4,'HLT-HIN-EDU-TOW-01','HLT-HIN-SNR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:46');
INSERT INTO health_supervision VALUES(5,'HLT-HIN-INSP-TOW-01','HLT-HIN-SNR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:46');
INSERT INTO health_supervision VALUES(6,'HLT-HIN-FUN-TOW-01','HLT-HIN-SNR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:46');
INSERT INTO health_supervision VALUES(7,'HLT-HIN-GEN-TOW-01','HLT-HIN-SNR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:46');
INSERT INTO health_supervision VALUES(8,'HLT-CLE-SUP-TOW-01','HLT-LEAD-ADIR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:47');
INSERT INTO health_supervision VALUES(9,'HLT-CLE-ASST-TOW-01','HLT-CLE-SUP-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:47');
INSERT INTO health_supervision VALUES(10,'HLT-CLE-DRV-TOW-01','HLT-CLE-SUP-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:47');
CREATE TABLE community_positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    section_id INTEGER,
    council_type_id INTEGER,
    level INTEGER,
    is_head_of_section BOOLEAN DEFAULT 0,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
, is_special_unit BOOLEAN DEFAULT 0, specific_council_id INTEGER, special_unit_name TEXT);
INSERT INTO community_positions VALUES(NULL,'Director - Community Services','LGSS/05',1,NULL,NULL,NULL,1,NULL,1,0,'COM-LEAD-DIR-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Director - Social Services','LGSS/06',1,'COM-LEAD-DIR-TOW-01',NULL,1,1,NULL,1,0,'COM-SOC-ADIR-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Director - Bus Stations, Markets & Housing','LGSS/06',1,'COM-LEAD-DIR-TOW-01',NULL,2,1,NULL,1,0,'COM-BSM-ADIR-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Community Development Officer','LGSS/07',1,'COM-SOC-ADIR-TOW-01',1,1,1,NULL,0,1,'COM-DEV-OFF-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Community Development Officer','LGSS/10',2,'COM-DEV-OFF-TOW-01',1,1,1,NULL,0,0,'COM-DEV-AST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Community Development Assistant','LGSS/17',4,'COM-DEV-OFF-TOW-01',1,1,1,NULL,0,0,'COM-DEV-ASST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Library Officer','LGSS/09',1,'COM-SOC-ADIR-TOW-01',2,1,1,NULL,0,1,'COM-LIB-OFF-TOW-01',0,NULL,NULL);
CREATE TABLE community_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO community_sections VALUES(1,'Social Services','SOC-SERV-TOW',1,NULL);
INSERT INTO community_sections VALUES(2,'Bus Stations, Markets & Housing','BSM-HOUS-TOW',1,NULL);
INSERT INTO community_sections VALUES(3,'Social Services','SOC-SERV-MUN',2,NULL);
INSERT INTO community_sections VALUES(4,'Bus Stations, Markets & Housing','BSM-HOUS-MUN',2,NULL);
INSERT INTO community_sections VALUES(5,'Social Services','SOC-SERV-CIT',3,NULL);
INSERT INTO community_sections VALUES(6,'Bus Stations, Markets & Housing','BSM-HOUS-CIT',3,NULL);
INSERT INTO community_sections VALUES(7,'Buchi Youth Vocational Training Centre','BYVTC-CIT',3,NULL);
CREATE TABLE community_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_type_id INTEGER,
    head_position_id TEXT, is_special_unit BOOLEAN DEFAULT 0, specific_council_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES community_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO community_units VALUES(1,'Community Development Unit','COM-DEV-TOW',1,1,NULL,0,NULL);
INSERT INTO community_units VALUES(2,'Library and Archiving Services Unit','LIB-ARC-TOW',1,1,NULL,0,NULL);
INSERT INTO community_units VALUES(3,'Housing Unit','HOUS-TOW',2,1,NULL,0,NULL);
INSERT INTO community_units VALUES(4,'Bus Stations Unit','BUS-TOW',2,1,NULL,0,NULL);
INSERT INTO community_units VALUES(5,'Markets Unit','MKT-TOW',2,1,NULL,0,NULL);
INSERT INTO community_units VALUES(6,'Community Development Unit','COM-DEV-MUN',3,2,NULL,0,NULL);
INSERT INTO community_units VALUES(7,'Library and Archiving Services Unit','LIB-ARC-MUN',3,2,NULL,0,NULL);
INSERT INTO community_units VALUES(8,'Housing Unit','HOUS-MUN',4,2,NULL,0,NULL);
INSERT INTO community_units VALUES(9,'Bus Stations Unit','BUS-MUN',4,2,NULL,0,NULL);
INSERT INTO community_units VALUES(10,'Markets Unit','MKT-MUN',4,2,NULL,0,NULL);
INSERT INTO community_units VALUES(11,'Community Development Unit','COM-DEV-CIT',5,3,NULL,0,NULL);
CREATE TABLE community_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_secretary_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO community_supervision VALUES(1,'COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(2,'COM-SOC-ADIR-TOW-01','COM-LEAD-DIR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(3,'COM-BSM-ADIR-TOW-01','COM-LEAD-DIR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(4,'COM-DEV-OFF-TOW-01','COM-SOC-ADIR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(5,'COM-LIB-OFF-TOW-01','COM-SOC-ADIR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(6,'COM-HOUS-OFF-TOW-01','COM-BSM-ADIR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(7,'COM-BUS-MGR-TOW-01','COM-BSM-ADIR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(8,'COM-MKT-MGR-TOW-01','COM-BSM-ADIR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:50');
INSERT INTO community_supervision VALUES(9,'COM-DEV-AST-TOW-01','COM-DEV-OFF-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
CREATE TABLE procurement_sections (
    section_id SERIAL PRIMARY KEY,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE procurement_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_type_id INTEGER,
    head_position_id TEXT,
    FOREIGN KEY (section_id) REFERENCES procurement_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO procurement_units VALUES(1,'Procurement Unit','PRO-UNIT-TOW',NULL,1,NULL);
INSERT INTO procurement_units VALUES(2,'Procurement Unit','PRO-UNIT-MUN',NULL,2,NULL);
INSERT INTO procurement_units VALUES(3,'Procurement Unit','PRO-UNIT-CIT',NULL,3,NULL);
CREATE TABLE procurement_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,  -- This will store the standard_id of the supervisor
    unit_id INTEGER,
    section_id INTEGER,
    council_type_id INTEGER DEFAULT 1,  -- 1 = Town Council, 2 = Municipal, 3 = City
    is_head_of_unit BOOLEAN DEFAULT 0,
    is_head_of_section BOOLEAN DEFAULT 0,
    is_specialist BOOLEAN DEFAULT 0,  -- For Health Services, etc.
    standard_id TEXT UNIQUE,
    FOREIGN KEY (unit_id) REFERENCES procurement_units(unit_id),
    FOREIGN KEY (section_id) REFERENCES procurement_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO procurement_positions VALUES(1,'Chief Procurement and Supplies Officer','LGSS/06',1,'EXEC-SEC-TOW-01',1,NULL,1,1,0,0,'PRO-CHIEF-TOW-01');
INSERT INTO procurement_positions VALUES(2,'Senior Procurement and Supplies Officer','LGSS/07',1,'PRO-CHIEF-TOW-01',1,NULL,1,0,0,0,'PRO-SNR-TOW-01');
INSERT INTO procurement_positions VALUES(3,'Procurement and Supplies Officer','LGSS/08',1,'PRO-SNR-TOW-01',1,NULL,1,0,0,0,'PRO-OFF-TOW-01');
INSERT INTO procurement_positions VALUES(4,'Assistant Procurement and Supplies Officer','LGSS/10',2,'PRO-OFF-TOW-01',1,NULL,1,0,0,0,'PRO-AST-TOW-01');
CREATE TABLE procurement_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,  -- Head of Department/Unit
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'PRO',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
INSERT INTO procurement_supervision VALUES(1,'PRO-CHIEF-TOW-01','EXEC-SEC-TOW-01','PRO-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'PRO',1,'2026-03-02 21:49:47');
INSERT INTO procurement_supervision VALUES(2,'PRO-SNR-TOW-01','PRO-CHIEF-TOW-01','PRO-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'PRO',1,'2026-03-02 21:49:47');
INSERT INTO procurement_supervision VALUES(3,'PRO-OFF-TOW-01','PRO-SNR-TOW-01','PRO-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'PRO',1,'2026-03-02 21:49:47');
INSERT INTO procurement_supervision VALUES(4,'PRO-AST-TOW-01','PRO-OFF-TOW-01','PRO-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'PRO',1,'2026-03-02 21:49:47');
INSERT INTO procurement_supervision VALUES(5,'PRO-HLTH-TOW-01','PRO-CHIEF-TOW-01','PRO-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'PRO',1,'2026-03-02 21:49:47');
INSERT INTO procurement_supervision VALUES(6,'PRO-HEAD-CIT-01','EXEC-CLK-CIT-01','PRO-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'PRO',1,'2026-03-02 22:10:13');
INSERT INTO procurement_supervision VALUES(7,'PRO-CHIEF-CIT-01','PRO-HEAD-CIT-01','PRO-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'PRO',1,'2026-03-02 22:10:13');
INSERT INTO procurement_supervision VALUES(8,'PRO-SNR-CIT-01','PRO-CHIEF-CIT-01','PRO-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'PRO',1,'2026-03-02 22:10:13');
INSERT INTO procurement_supervision VALUES(9,'PRO-AST-CIT-01','PRO-SNR-CIT-01','PRO-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'PRO',1,'2026-03-02 22:10:13');
CREATE TABLE audit_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 1,
    is_head_of_unit BOOLEAN DEFAULT 0,
    is_vacant BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
INSERT INTO audit_positions VALUES(1,'Chief Internal Auditor','LGSS/06',1,'EXEC-SEC-TOW-01',1,1,1,0,'AUD-CHIEF-TOW-01');
INSERT INTO audit_positions VALUES(2,'Senior Internal Auditor','LGSS/07',1,'AUD-CHIEF-TOW-01',1,1,0,0,'AUD-SNR-TOW-01');
INSERT INTO audit_positions VALUES(3,'Internal Auditor','LGSS/08',2,'AUD-SNR-TOW-01',1,1,0,0,'AUD-OFF-TOW-01');
INSERT INTO audit_positions VALUES(4,'Assistant Internal Auditor','LGSS/10',2,'AUD-OFF-TOW-01',1,1,0,0,'AUD-AST-TOW-01');
INSERT INTO audit_positions VALUES(5,'Head - Internal Audit','LGSS/05',1,'EXEC-CLK-MUN-01',2,2,1,0,'AUD-HEAD-MUN-01');
INSERT INTO audit_positions VALUES(6,'Senior Internal Auditor','LGSS/07',1,'AUD-HEAD-MUN-01',2,2,0,0,'AUD-SNR-MUN-01');
INSERT INTO audit_positions VALUES(7,'Internal Auditor','LGSS/08',2,'AUD-SNR-MUN-01',2,2,0,0,'AUD-OFF-MUN-01');
INSERT INTO audit_positions VALUES(8,'Assistant Internal Auditor','LGSS/10',8,'AUD-OFF-MUN-01',2,2,0,0,'AUD-AST-MUN-01');
INSERT INTO audit_positions VALUES(9,'Internal Audit Assistant','LGSS/13',4,'AUD-OFF-MUN-01',2,2,0,0,'AUD-ASST-MUN-01');
CREATE TABLE audit_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
INSERT INTO audit_units VALUES(1,'Internal Audit Unit','AUD-UNIT-TOW',1,NULL);
INSERT INTO audit_units VALUES(2,'Internal Audit Unit','AUD-UNIT-MUN',2,NULL);
INSERT INTO audit_units VALUES(3,'Internal Audit Unit','AUD-UNIT-CIT',3,NULL);
CREATE TABLE audit_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'AUD',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO audit_supervision VALUES(1,'AUD-CHIEF-TOW-01','EXEC-SEC-TOW-01','AUD-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'AUD',1,'2026-03-02 22:24:10');
INSERT INTO audit_supervision VALUES(2,'AUD-SNR-TOW-01','AUD-CHIEF-TOW-01','AUD-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'AUD',1,'2026-03-02 22:24:10');
INSERT INTO audit_supervision VALUES(3,'AUD-OFF-TOW-01','AUD-SNR-TOW-01','AUD-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'AUD',1,'2026-03-02 22:24:10');
INSERT INTO audit_supervision VALUES(4,'AUD-AST-TOW-01','AUD-OFF-TOW-01','AUD-CHIEF-TOW-01','EXEC-SEC-TOW-01',1,'AUD',1,'2026-03-02 22:24:10');
INSERT INTO audit_supervision VALUES(5,'AUD-HEAD-MUN-01','EXEC-CLK-MUN-01','AUD-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'AUD',1,'2026-03-02 22:28:34');
INSERT INTO audit_supervision VALUES(6,'AUD-SNR-MUN-01','AUD-HEAD-MUN-01','AUD-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'AUD',1,'2026-03-02 22:28:34');
INSERT INTO audit_supervision VALUES(7,'AUD-OFF-MUN-01','AUD-SNR-MUN-01','AUD-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'AUD',1,'2026-03-02 22:28:34');
INSERT INTO audit_supervision VALUES(8,'AUD-AST-MUN-01','AUD-OFF-MUN-01','AUD-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'AUD',1,'2026-03-02 22:28:34');
INSERT INTO audit_supervision VALUES(9,'AUD-ASST-MUN-01','AUD-OFF-MUN-01','AUD-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'AUD',1,'2026-03-02 22:28:34');
INSERT INTO audit_supervision VALUES(10,'AUD-HEAD-CIT-01','EXEC-CLK-CIT-01','AUD-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'AUD',1,'2026-03-02 22:32:11');
CREATE TABLE cos_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
INSERT INTO cos_units VALUES(1,'Office of the Council Secretary','COS-OFFICE-TOW',1,NULL);
INSERT INTO cos_units VALUES(2,'Public Relations Unit','COS-PR-TOW',1,NULL);
INSERT INTO cos_units VALUES(3,'ICT Unit','COS-ICT-TOW',1,NULL);
CREATE TABLE cos_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 1,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE,
    FOREIGN KEY (unit_id) REFERENCES cos_units(unit_id)
);
INSERT INTO cos_positions VALUES(1,'Council Secretary','LGSS/03',1,NULL,1,1,1,'COS-SEC-TOW-01');
INSERT INTO cos_positions VALUES(2,'Personal Secretary','LGSS/10',2,'COS-SEC-TOW-01',1,1,0,'COS-PERSEC-TOW-01');
INSERT INTO cos_positions VALUES(3,'Driver','G1',1,'COS-SEC-TOW-01',1,1,0,'COS-DRIVER-TOW-01');
INSERT INTO cos_positions VALUES(4,'Office Orderly','G3',1,'COS-SEC-TOW-01',1,1,0,'COS-ORD-TOW-01');
INSERT INTO cos_positions VALUES(5,'Public Relations Officer','LGSS/08',1,'COS-SEC-TOW-01',2,1,1,'COS-PRO-TOW-01');
INSERT INTO cos_positions VALUES(6,'Assistant Public Relations Officer','LGSS/10',1,'COS-PRO-TOW-01',2,1,0,'COS-APRO-TOW-01');
INSERT INTO cos_positions VALUES(7,'System Analyst','LGSS/08',1,'COS-SEC-TOW-01',3,1,1,'COS-SYS-TOW-01');
INSERT INTO cos_positions VALUES(8,'Programmer','LGSS/10',2,'COS-SYS-TOW-01',3,1,0,'COS-PROG-TOW-01');
CREATE TABLE cos_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'COS',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO cos_supervision VALUES(1,'COS-SEC-TOW-01',NULL,'COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
INSERT INTO cos_supervision VALUES(2,'COS-PERSEC-TOW-01','COS-SEC-TOW-01','COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
INSERT INTO cos_supervision VALUES(3,'COS-DRIVER-TOW-01','COS-SEC-TOW-01','COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
INSERT INTO cos_supervision VALUES(4,'COS-ORD-TOW-01','COS-SEC-TOW-01','COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
INSERT INTO cos_supervision VALUES(5,'COS-PRO-TOW-01','COS-SEC-TOW-01','COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
INSERT INTO cos_supervision VALUES(6,'COS-APRO-TOW-01','COS-PRO-TOW-01','COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
INSERT INTO cos_supervision VALUES(7,'COS-SYS-TOW-01','COS-SEC-TOW-01','COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
INSERT INTO cos_supervision VALUES(8,'COS-PROG-TOW-01','COS-SYS-TOW-01','COS-SEC-TOW-01',1,'COS',1,'2026-03-02 22:48:44');
CREATE TABLE toc_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
INSERT INTO toc_units VALUES(1,'Office of the Town Clerk','TOC-OFFICE-MUN',2,NULL);
INSERT INTO toc_units VALUES(2,'Public Relations Unit','TOC-PR-MUN',2,NULL);
CREATE TABLE toc_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 2,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE,
    FOREIGN KEY (unit_id) REFERENCES toc_units(unit_id)
);
INSERT INTO toc_positions VALUES(1,'Town Clerk','LGSS/02',1,NULL,1,2,1,'TOC-CLK-MUN-01');
INSERT INTO toc_positions VALUES(2,'Personal Assistant','LGSS/10',1,'TOC-CLK-MUN-01',1,2,0,'TOC-PA-MUN-01');
INSERT INTO toc_positions VALUES(3,'Driver','G1',1,'TOC-CLK-MUN-01',1,2,0,'TOC-DRIVER-MUN-01');
INSERT INTO toc_positions VALUES(4,'Office Orderly','G3',1,'TOC-CLK-MUN-01',1,2,0,'TOC-ORD-MUN-01');
INSERT INTO toc_positions VALUES(5,'Public Relations Manager','LGSS/06',1,'TOC-CLK-MUN-01',2,2,1,'TOC-PRMGR-MUN-01');
INSERT INTO toc_positions VALUES(6,'Senior Public Relations Officer','LGSS/07',1,'TOC-PRMGR-MUN-01',2,2,0,'TOC-SRPRO-MUN-01');
INSERT INTO toc_positions VALUES(7,'Public Relations Officer','LGSS/08',1,'TOC-SRPRO-MUN-01',2,2,0,'TOC-PRO-MUN-01');
CREATE TABLE toc_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'TOC',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO toc_supervision VALUES(1,'TOC-CLK-MUN-01',NULL,'TOC-CLK-MUN-01',2,'TOC',1,'2026-03-02 23:02:37');
INSERT INTO toc_supervision VALUES(2,'TOC-PA-MUN-01','TOC-CLK-MUN-01','TOC-CLK-MUN-01',2,'TOC',1,'2026-03-02 23:02:37');
INSERT INTO toc_supervision VALUES(3,'TOC-DRIVER-MUN-01','TOC-CLK-MUN-01','TOC-CLK-MUN-01',2,'TOC',1,'2026-03-02 23:02:37');
INSERT INTO toc_supervision VALUES(4,'TOC-ORD-MUN-01','TOC-CLK-MUN-01','TOC-CLK-MUN-01',2,'TOC',1,'2026-03-02 23:02:37');
INSERT INTO toc_supervision VALUES(5,'TOC-PRMGR-MUN-01','TOC-CLK-MUN-01','TOC-CLK-MUN-01',2,'TOC',1,'2026-03-02 23:02:37');
INSERT INTO toc_supervision VALUES(6,'TOC-SRPRO-MUN-01','TOC-PRMGR-MUN-01','TOC-CLK-MUN-01',2,'TOC',1,'2026-03-02 23:02:37');
INSERT INTO toc_supervision VALUES(7,'TOC-PRO-MUN-01','TOC-SRPRO-MUN-01','TOC-CLK-MUN-01',2,'TOC',1,'2026-03-02 23:02:37');
CREATE TABLE toc_city_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
INSERT INTO toc_city_units VALUES(1,'Office of the Town Clerk','TOC-OFFICE-CIT',3,NULL);
INSERT INTO toc_city_units VALUES(2,'Public Relations Unit','TOC-PR-CIT',3,NULL);
CREATE TABLE toc_city_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 3,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE,
    FOREIGN KEY (unit_id) REFERENCES toc_city_units(unit_id)
);
INSERT INTO toc_city_positions VALUES(1,'Town Clerk','LGSS/01',1,NULL,1,3,1,'TOC-CLK-CIT-01');
INSERT INTO toc_city_positions VALUES(2,'Personal Secretary','LGSS/10',1,'TOC-CLK-CIT-01',1,3,0,'TOC-PERSEC-CIT-01');
INSERT INTO toc_city_positions VALUES(3,'Driver','G1',1,'TOC-CLK-CIT-01',1,3,0,'TOC-DRIVER-CIT-01');
INSERT INTO toc_city_positions VALUES(4,'Office Orderly','G3',1,'TOC-CLK-CIT-01',1,3,0,'TOC-ORD-CIT-01');
INSERT INTO toc_city_positions VALUES(5,'Public Relations Manager','LGSS/05',1,'TOC-CLK-CIT-01',2,3,1,'TOC-PRMGR-CIT-01');
INSERT INTO toc_city_positions VALUES(6,'Assistant Public Relations Manager','LGSS/06',1,'TOC-PRMGR-CIT-01',2,3,0,'TOC-APRMGR-CIT-01');
INSERT INTO toc_city_positions VALUES(7,'Public Relations Officer','LGSS/08',3,'TOC-APRMGR-CIT-01',2,3,0,'TOC-PRO-CIT-01');
CREATE TABLE toc_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'TOC',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO toc_city_supervision VALUES(1,'TOC-CLK-CIT-01',NULL,'TOC-CLK-CIT-01',3,'TOC',1,'2026-03-02 23:07:00');
INSERT INTO toc_city_supervision VALUES(2,'TOC-PERSEC-CIT-01','TOC-CLK-CIT-01','TOC-CLK-CIT-01',3,'TOC',1,'2026-03-02 23:07:00');
INSERT INTO toc_city_supervision VALUES(3,'TOC-DRIVER-CIT-01','TOC-CLK-CIT-01','TOC-CLK-CIT-01',3,'TOC',1,'2026-03-02 23:07:00');
INSERT INTO toc_city_supervision VALUES(4,'TOC-ORD-CIT-01','TOC-CLK-CIT-01','TOC-CLK-CIT-01',3,'TOC',1,'2026-03-02 23:07:00');
INSERT INTO toc_city_supervision VALUES(5,'TOC-PRMGR-CIT-01','TOC-CLK-CIT-01','TOC-CLK-CIT-01',3,'TOC',1,'2026-03-02 23:07:00');
INSERT INTO toc_city_supervision VALUES(6,'TOC-APRMGR-CIT-01','TOC-PRMGR-CIT-01','TOC-CLK-CIT-01',3,'TOC',1,'2026-03-02 23:07:00');
INSERT INTO toc_city_supervision VALUES(7,'TOC-PRO-CIT-01','TOC-APRMGR-CIT-01','TOC-CLK-CIT-01',3,'TOC',1,'2026-03-02 23:07:00');
CREATE TABLE ict_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 2,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
INSERT INTO ict_positions VALUES(1,'Head - ICT','LGSS/05',1,'EXEC-CLK-MUN-01',1,2,1,'ICT-HEAD-MUN-01');
INSERT INTO ict_positions VALUES(2,'Senior System Analyst','LGSS/07',1,'ICT-HEAD-MUN-01',1,2,0,'ICT-SSA-MUN-01');
INSERT INTO ict_positions VALUES(3,'Programmer','LGSS/10',3,'ICT-SSA-MUN-01',1,2,0,'ICT-PROG-MUN-01');
INSERT INTO ict_positions VALUES(4,'Data Entry Operator','LGSS/13',2,'ICT-PROG-MUN-01',1,2,0,'ICT-DEO-MUN-01');
CREATE TABLE ict_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
INSERT INTO ict_units VALUES(1,'ICT Unit','ICT-UNIT-MUN',2);
CREATE TABLE ict_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'ICT',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO ict_supervision VALUES(1,'ICT-HEAD-MUN-01','EXEC-CLK-MUN-01','ICT-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'ICT',1,'2026-03-02 23:15:14');
INSERT INTO ict_supervision VALUES(2,'ICT-SSA-MUN-01','ICT-HEAD-MUN-01','ICT-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'ICT',1,'2026-03-02 23:15:14');
INSERT INTO ict_supervision VALUES(3,'ICT-PROG-MUN-01','ICT-SSA-MUN-01','ICT-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'ICT',1,'2026-03-02 23:15:14');
INSERT INTO ict_supervision VALUES(4,'ICT-DEO-MUN-01','ICT-PROG-MUN-01','ICT-HEAD-MUN-01','EXEC-CLK-MUN-01',2,'ICT',1,'2026-03-02 23:15:14');
CREATE TABLE ict_city_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 3,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
INSERT INTO ict_city_positions VALUES(1,'Head - ICT','LGSS/05',1,'EXEC-CLK-CIT-01',1,3,1,'ICT-HEAD-CIT-01');
INSERT INTO ict_city_positions VALUES(2,'Principal Systems Analyst','LGSS/06',1,'ICT-HEAD-CIT-01',1,3,0,'ICT-PSA-CIT-01');
INSERT INTO ict_city_positions VALUES(3,'Senior Systems Analyst','LGSS/07',1,'ICT-PSA-CIT-01',1,3,0,'ICT-SSA-CIT-01');
INSERT INTO ict_city_positions VALUES(4,'Systems Analyst','LGSS/08',1,'ICT-SSA-CIT-01',1,3,0,'ICT-SA-CIT-01');
INSERT INTO ict_city_positions VALUES(5,'Network Engineer','LGSS/08',2,'ICT-SSA-CIT-01',1,3,0,'ICT-NE-CIT-01');
INSERT INTO ict_city_positions VALUES(6,'Senior Programmer','LGSS/08',1,'ICT-SSA-CIT-01',1,3,0,'ICT-SPROG-CIT-01');
INSERT INTO ict_city_positions VALUES(7,'Programmer','LGSS/10',4,'ICT-SPROG-CIT-01',1,3,0,'ICT-PROG-CIT-01');
INSERT INTO ict_city_positions VALUES(8,'IT Support Officer','LGSS/13',7,'ICT-SPROG-CIT-01',1,3,0,'ICT-ITSO-CIT-01');
CREATE TABLE ict_city_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
INSERT INTO ict_city_units VALUES(1,'ICT Unit','ICT-UNIT-CIT',3);
CREATE TABLE ict_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'ICT',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO ict_city_supervision VALUES(1,'ICT-HEAD-CIT-01','EXEC-CLK-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
INSERT INTO ict_city_supervision VALUES(2,'ICT-PSA-CIT-01','ICT-HEAD-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
INSERT INTO ict_city_supervision VALUES(3,'ICT-SSA-CIT-01','ICT-PSA-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
INSERT INTO ict_city_supervision VALUES(4,'ICT-SA-CIT-01','ICT-SSA-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
INSERT INTO ict_city_supervision VALUES(5,'ICT-NE-CIT-01','ICT-SSA-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
INSERT INTO ict_city_supervision VALUES(6,'ICT-SPROG-CIT-01','ICT-SSA-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
INSERT INTO ict_city_supervision VALUES(7,'ICT-PROG-CIT-01','ICT-SPROG-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
INSERT INTO ict_city_supervision VALUES(8,'ICT-ITSO-CIT-01','ICT-SPROG-CIT-01','ICT-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'ICT',1,'2026-03-02 23:19:23');
CREATE TABLE commercial_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 2,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
INSERT INTO commercial_positions VALUES(1,'Commercial Manager','LGSS/06',1,'EXEC-CLK-MUN-01',1,2,1,'COM-MGR-MUN-01');
INSERT INTO commercial_positions VALUES(2,'Assistant Commercial Manager','LGSS/07',1,'COM-MGR-MUN-01',1,2,0,'COM-AMGR-MUN-01');
INSERT INTO commercial_positions VALUES(3,'House Keeper','G3',1,'COM-AMGR-MUN-01',1,2,0,'COM-HK-MUN-01');
INSERT INTO commercial_positions VALUES(4,'Receptionist','G1',4,'COM-AMGR-MUN-01',1,2,0,'COM-REC-MUN-01');
INSERT INTO commercial_positions VALUES(5,'Laundryman','G3',3,'COM-AMGR-MUN-01',1,2,0,'COM-LAUN-MUN-01');
INSERT INTO commercial_positions VALUES(6,'Chef','G1',2,'COM-AMGR-MUN-01',1,2,0,'COM-CHEF-MUN-01');
INSERT INTO commercial_positions VALUES(7,'Cook','G1',2,'COM-AMGR-MUN-01',1,2,0,'COM-COOK-MUN-01');
INSERT INTO commercial_positions VALUES(8,'Barman','G2',3,'COM-AMGR-MUN-01',1,2,0,'COM-BAR-MUN-01');
INSERT INTO commercial_positions VALUES(9,'Waiter','G2',2,'COM-AMGR-MUN-01',1,2,0,'COM-WAIT-MUN-01');
CREATE TABLE commercial_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
INSERT INTO commercial_units VALUES(1,'Commercial and Business Development Unit','COM-UNIT-MUN',2);
CREATE TABLE commercial_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO commercial_supervision VALUES(1,'COM-MGR-MUN-01','EXEC-CLK-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(2,'COM-AMGR-MUN-01','COM-MGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(3,'COM-HK-MUN-01','COM-AMGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(4,'COM-REC-MUN-01','COM-AMGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(5,'COM-LAUN-MUN-01','COM-AMGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(6,'COM-CHEF-MUN-01','COM-AMGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(7,'COM-COOK-MUN-01','COM-AMGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(8,'COM-BAR-MUN-01','COM-AMGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
INSERT INTO commercial_supervision VALUES(9,'COM-WAIT-MUN-01','COM-AMGR-MUN-01','COM-MGR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 23:29:46');
CREATE TABLE commercial_city_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 3,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
INSERT INTO commercial_city_positions VALUES(1,'Senior Manager - Commercial & Business Development','LGSS/05',1,'EXEC-CLK-CIT-01',1,3,1,'COM-SMGR-CIT-01');
INSERT INTO commercial_city_positions VALUES(2,'Manager - Commercial & Business Development','LGSS/06',1,'COM-SMGR-CIT-01',1,3,0,'COM-MGR-CIT-01');
INSERT INTO commercial_city_positions VALUES(3,'Assistant Manager - Commercial & Business Development','LGSS/07',2,'COM-MGR-CIT-01',1,3,0,'COM-AMGR-CIT-01');
CREATE TABLE commercial_city_units (
    unit_id SERIAL PRIMARY KEY,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
INSERT INTO commercial_city_units VALUES(1,'Commercial and Business Development Unit','COM-UNIT-CIT',3);
CREATE TABLE commercial_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO commercial_city_supervision VALUES(1,'COM-SMGR-CIT-01','EXEC-CLK-CIT-01','COM-SMGR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 23:32:34');
INSERT INTO commercial_city_supervision VALUES(2,'COM-MGR-CIT-01','COM-SMGR-CIT-01','COM-SMGR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 23:32:34');
INSERT INTO commercial_city_supervision VALUES(3,'COM-AMGR-CIT-01','COM-MGR-CIT-01','COM-SMGR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 23:32:34');
CREATE TABLE valuation_city_positions (
    position_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    stream TEXT,
    council_type_id INTEGER DEFAULT 3,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
INSERT INTO valuation_city_positions VALUES(1,'Director','LGSS/03',1,'EXEC-CLK-CIT-01','Leadership',3,1,'VAL-DIR-CIT-01');
INSERT INTO valuation_city_positions VALUES(2,'Chief Valuation Officer','LGSS/05',1,'VAL-DIR-CIT-01','Leadership',3,0,'VAL-CHIEF-CIT-01');
INSERT INTO valuation_city_positions VALUES(3,'Senior Valuation Officer - Property Management','LGSS/06',1,'VAL-CHIEF-CIT-01','Property Management',3,0,'VAL-SRPM-CIT-01');
INSERT INTO valuation_city_positions VALUES(4,'Valuation Officer - Property Management','LGSS/07',2,'VAL-SRPM-CIT-01','Property Management',3,0,'VAL-VOPM-CIT-01');
INSERT INTO valuation_city_positions VALUES(5,'Assistant Valuation Officer - Property Management','LGSS/10',4,'VAL-VOPM-CIT-01','Property Management',3,0,'VAL-AVOPM-CIT-01');
INSERT INTO valuation_city_positions VALUES(6,'Field Inspector','LGSS/13',5,'VAL-VOPM-CIT-01','Property Management',3,0,'VAL-FI-PM-CIT-01');
INSERT INTO valuation_city_positions VALUES(7,'Senior Valuation Officer - Property Taxation and Rating','LGSS/06',1,'VAL-CHIEF-CIT-01','Taxation & Rating',3,0,'VAL-SRTR-CIT-01');
INSERT INTO valuation_city_positions VALUES(8,'Valuation Officer - Property Taxation and Rating','LGSS/07',2,'VAL-SRTR-CIT-01','Taxation & Rating',3,0,'VAL-VOTR-CIT-01');
INSERT INTO valuation_city_positions VALUES(9,'Assistant Valuation Officer - Property Taxation and Rating','LGSS/10',4,'VAL-VOTR-CIT-01','Taxation & Rating',3,0,'VAL-AVOTR-CIT-01');
INSERT INTO valuation_city_positions VALUES(10,'Field Inspector','LGSS/13',5,'VAL-VOTR-CIT-01','Taxation & Rating',3,0,'VAL-FI-TR-CIT-01');
CREATE TABLE valuation_city_supervision (
    id SERIAL PRIMARY KEY,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'VAL',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO valuation_city_supervision VALUES(1,'VAL-DIR-CIT-01','EXEC-CLK-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(2,'VAL-CHIEF-CIT-01','VAL-DIR-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(3,'VAL-SRPM-CIT-01','VAL-CHIEF-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(4,'VAL-VOPM-CIT-01','VAL-SRPM-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(5,'VAL-AVOPM-CIT-01','VAL-VOPM-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(6,'VAL-FI-PM-CIT-01','VAL-VOPM-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(7,'VAL-SRTR-CIT-01','VAL-CHIEF-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(8,'VAL-VOTR-CIT-01','VAL-SRTR-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(9,'VAL-AVOTR-CIT-01','VAL-VOTR-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
INSERT INTO valuation_city_supervision VALUES(10,'VAL-FI-TR-CIT-01','VAL-VOTR-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
CREATE TABLE immutable_audit_log (
    log_id SERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    council_id INTEGER NOT NULL,
    period_date TEXT NOT NULL,  -- Store as 'YYYY-MM-DD'
    approved_by TEXT NOT NULL,
    approved_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_hash TEXT NOT NULL,
    payload TEXT,  -- SQLite doesn't have JSONB, use TEXT and store JSON
    previous_hash TEXT,
    signature TEXT
);
CREATE VIEW leave_resumption AS
WITH working_days AS (
    SELECT c.day,
           lr.request_id,
           lr.employee_id,
           lr.leave_type,
           lr.requested_days,
           lr.start_date,
           ROW_NUMBER() OVER (
