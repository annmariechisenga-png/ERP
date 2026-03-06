CREATE TABLE sqlite_sequence(name,seq);
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
    days_availed INTEGER,
    leave_taken INTEGER,
    leave_commuted INTEGER,
    leave_transferred_out INTEGER,
    leave_balance INTEGER
, employee_id TEXT, gender TEXT CHECK(gender IN ('Male', 'Female', 'Other')), is_active BOOLEAN DEFAULT 1, hire_date DATE, email TEXT, phone TEXT, supervisor_id INTEGER REFERENCES employees(employee_id), notification_preference TEXT DEFAULT 'Both');
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
  days_availed INT,
  leave_taken INT,
  leave_commuted INT,
  leave_transferred_out INT,
  leave_balance INT
, reason TEXT);
CREATE TABLE audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE leave_requests (
    request_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE holidays (
    holiday_date DATE PRIMARY KEY,
    description TEXT
);
CREATE TABLE calendar (
    day DATE PRIMARY KEY,
    is_working_day INTEGER
);
CREATE TABLE leave_balances (
    employee_id INTEGER PRIMARY KEY,
    local_leave_balance INTEGER,
    vacation_leave_balance INTEGER
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
               PARTITION BY lr.request_id 
               ORDER BY c.day
           ) AS rn
    FROM leave_requests lr
    JOIN calendar c
      ON c.day >= lr.start_date
     AND c.is_working_day = 1
)
SELECT 
    lr.request_id,
    lr.employee_id,
    lr.leave_type,
    lr.requested_days,
    lr.start_date,
    -- last leave day
    (SELECT day 
     FROM working_days w2
     WHERE w2.request_id = lr.request_id
       AND w2.rn = lr.requested_days) AS last_leave_day,
    -- resumption date
    (SELECT day 
     FROM calendar c2
     WHERE c2.day > (
         SELECT day 
         FROM working_days w3
         WHERE w3.request_id = lr.request_id
           AND w3.rn = lr.requested_days
     )
       AND c2.is_working_day = 1
     ORDER BY c2.day ASC
     LIMIT 1) AS resumption_date
FROM leave_requests lr
/* leave_resumption(request_id,employee_id,leave_type,requested_days,start_date,last_leave_day,resumption_date) */;
CREATE TABLE authority_codes (
    authority_name TEXT PRIMARY KEY,
    authority_code TEXT UNIQUE
);
CREATE TABLE employee_sequence (
    authority_code TEXT,
    year INTEGER,
    next_number INTEGER,
    PRIMARY KEY (authority_code, year)
);
CREATE TRIGGER generate_employee_id
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Increment sequence
    UPDATE employee_sequence
    SET next_number = next_number + 1
    WHERE authority_code = 'CHL'
      AND year = strftime('%Y', NEW.date_of_first_appointment);

    -- Assign ID
    SELECT NEW.employee_id =
        'CHL-' || strftime('%Y', NEW.date_of_first_appointment) || '-' ||
        printf('%06d', (
            SELECT next_number
            FROM employee_sequence
            WHERE authority_code = 'CHL'
              AND year = strftime('%Y', NEW.date_of_first_appointment)
        ));
END;
CREATE TRIGGER enforce_continuous_leave
BEFORE UPDATE OF approved_by_supervisor ON leave_requests
FOR EACH ROW
WHEN NEW.approved_by_supervisor = 1
BEGIN
    SELECT CASE
        WHEN NEW.salary_scale BETWEEN 'LGSS/01' AND 'LGSS/07' AND NEW.requested_days > 120
            THEN RAISE(ABORT, 'Exceeds 120-day limit for Division I')
        WHEN NEW.salary_scale BETWEEN 'LGSS/08' AND 'LGSS/12' AND NEW.requested_days > 110
            THEN RAISE(ABORT, 'Exceeds 110-day limit for Division II')
        WHEN NEW.salary_scale BETWEEN 'LGSS/13' AND 'LGSS/18' AND NEW.requested_days > 100
            THEN RAISE(ABORT, 'Exceeds 100-day limit for Division III')
        WHEN NEW.salary_scale IN ('G1','G2','G3') AND NEW.requested_days > 100
            THEN RAISE(ABORT, 'Exceeds 100-day limit for Division IV')
    END;
END;
CREATE TRIGGER enforce_accumulated_leave
BEFORE UPDATE OF remaining_balance ON leave_requests
FOR EACH ROW
BEGIN
    SELECT CASE
        WHEN NEW.salary_scale BETWEEN 'LGSS/01' AND 'LGSS/07' AND NEW.remaining_balance > 230
            THEN RAISE(ABORT, 'Exceeds 230-day balance for Division I')
        WHEN NEW.salary_scale BETWEEN 'LGSS/08' AND 'LGSS/12' AND NEW.remaining_balance > 205
            THEN RAISE(ABORT, 'Exceeds 205-day balance for Division II')
        WHEN NEW.salary_scale BETWEEN 'LGSS/13' AND 'LGSS/18' AND NEW.remaining_balance > 160
            THEN RAISE(ABORT, 'Exceeds 160-day balance for Division III')
        WHEN NEW.salary_scale IN ('G1','G2','G3') AND NEW.remaining_balance > 160
            THEN RAISE(ABORT, 'Exceeds 160-day balance for Division IV')
    END;
END;
CREATE TRIGGER grant_vacation_allowance
AFTER UPDATE OF approved_by_supervisor ON leave_requests
FOR EACH ROW
WHEN NEW.approved_by_supervisor = 1 AND NEW.leave_type = 'Vacation'
BEGIN
    -- Check 24-month interval
    SELECT CASE
        WHEN NEW.last_allowance_date IS NOT NULL 
             AND julianday('now') - julianday(NEW.last_allowance_date) < (24*30)
        THEN RAISE(ABORT, 'Vacation Leave Allowance only granted once every 24 months')
    END;

    -- Grant allowance based on division
    UPDATE leave_requests
    SET allowance_granted = CASE
        WHEN NEW.salary_scale BETWEEN 'LGSS/01' AND 'LGSS/07' THEN 3500
        WHEN NEW.salary_scale BETWEEN 'LGSS/08' AND 'LGSS/12' THEN 3000
        WHEN NEW.salary_scale BETWEEN 'LGSS/13' AND 'LGSS/18' THEN 2500
        WHEN NEW.salary_scale IN ('G1','G2','G3') THEN 2000
        ELSE 0
    END,
    last_allowance_date = DATE('now')
    WHERE request_id = NEW.request_id;
END;
CREATE TABLE vacation_allowances (
    allowance_id INTEGER PRIMARY KEY,
    employee_id INTEGER,
    amount INTEGER,
    granted_date DATE
, processed INTEGER DEFAULT 0);
CREATE TRIGGER validate_leave_approval
BEFORE UPDATE OF approved_by_supervisor, approved_by_hod, approved_by_secretary ON leave_requests
FOR EACH ROW
BEGIN
    -- Supervisor check
    SELECT CASE
        WHEN NEW.approved_by_supervisor = 1 AND
             NEW.current_approver_id != (SELECT supervisor_id FROM approval_chain WHERE employee_id = NEW.employee_id)
        THEN RAISE(ABORT, 'Invalid supervisor approval')
    END;

    -- HOD check (only if hod_id is not null)
    SELECT CASE
        WHEN NEW.approved_by_hod = 1 AND
             (SELECT hod_id FROM approval_chain WHERE employee_id = NEW.employee_id) IS NOT NULL AND
             NEW.current_approver_id != (SELECT hod_id FROM approval_chain WHERE employee_id = NEW.employee_id)
        THEN RAISE(ABORT, 'Invalid HOD approval')
    END;

    -- CS check
    SELECT CASE
        WHEN NEW.approved_by_secretary = 1 AND
             NEW.current_approver_id != (SELECT council_secretary_id FROM approval_chain WHERE employee_id = NEW.employee_id)
        THEN RAISE(ABORT, 'Invalid Council Secretary approval')
    END;
END;
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
CREATE TABLE departments (
    dept_code TEXT PRIMARY KEY,
    dept_name TEXT NOT NULL
);
CREATE TABLE position_attributes (
    position_id TEXT NOT NULL,
    authority_type TEXT NOT NULL,   -- Town, Municipal, City
    title TEXT NOT NULL,
    salary_scale TEXT NOT NULL,
    establishment_count INTEGER NOT NULL, position_standard_id TEXT,
    FOREIGN KEY (position_id) REFERENCES positions(position_id)
);
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
CREATE TABLE ReportingLines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    reports_to TEXT, position_standard_id TEXT, reports_to_standard_id TEXT,
    FOREIGN KEY (position_id) REFERENCES Positions(position_id),
    FOREIGN KEY (reports_to) REFERENCES Positions(position_id)
);
CREATE TABLE LeaveApprovalChains (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    supervisor TEXT NOT NULL,
    hod TEXT NOT NULL,
    top_authority TEXT NOT NULL, position_standard_id TEXT, approver_standard_id TEXT,
    FOREIGN KEY (position_id) REFERENCES Positions(position_id)
);
CREATE TABLE Councils (
    council_id INTEGER PRIMARY KEY AUTOINCREMENT,
    council_name TEXT NOT NULL,
    top_authority TEXT NOT NULL
);
CREATE TABLE HRA_Positions (
    position_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER,
    council_id INTEGER, standard_id TEXT,
    FOREIGN KEY (council_id) REFERENCES Councils(council_id)
);
CREATE TABLE HRA_ReportingLines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    reports_to TEXT,
    FOREIGN KEY (position_id) REFERENCES HRA_Positions(position_id),
    FOREIGN KEY (reports_to) REFERENCES HRA_Positions(position_id)
);
CREATE TABLE HRA_LeaveApprovalChains (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE hra_leave_approval_chain (
    position_id TEXT NOT NULL,
    approval_chain TEXT NOT NULL,
    authority_type TEXT NOT NULL,
    FOREIGN KEY (position_id) REFERENCES hra_position_attributes(position_id)
);
CREATE TABLE sections (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    description TEXT
);
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
CREATE TABLE leave_approval_chain (
    chain_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES positions(position_id)
);
CREATE VIEW vw_municipal_organization_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        position_id,
        title,
        reports_to,
        1 as level,
        title as path
    FROM positions
    WHERE reports_to IS NULL 
    AND council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'MC')
    
    UNION ALL
    
    SELECT 
        p.position_id,
        p.title,
        p.reports_to,
        ot.level + 1,
        ot.path || ' -> ' || p.title
    FROM positions p
    INNER JOIN org_tree ot ON p.reports_to = ot.position_id
    WHERE p.council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'MC')
)
SELECT * FROM org_tree ORDER BY level, title
/* vw_municipal_organization_chart(position_id,title,reports_to,level,path) */;
CREATE VIEW vw_municipal_positions_summary AS
SELECT 
    p.position_id,
    p.title,
    s.section_name,
    p.salary_scale,
    p.proposed_establishment,
    supervisor.title as reports_to_title,
    p.is_head_of_section,
    CASE WHEN p.is_head_of_section THEN 'Yes' ELSE 'No' END as is_head,
    ct.council_type_name
FROM positions p
LEFT JOIN sections s ON p.section_id = s.section_id
LEFT JOIN positions supervisor ON p.reports_to = supervisor.position_id
JOIN council_types ct ON p.council_type_id = ct.council_type_id
WHERE p.council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'MC')
ORDER BY s.section_name, p.level
/* vw_municipal_positions_summary(position_id,title,section_name,salary_scale,proposed_establishment,reports_to_title,is_head_of_section,is_head,council_type_name) */;
CREATE VIEW vw_municipal_leave_approval_flow AS
SELECT 
    p.title as position_title,
    lac.step_number,
    lac.approver_role,
    approver.title as approver_title
FROM leave_approval_chain lac
JOIN positions p ON lac.position_id = p.position_id
LEFT JOIN positions approver ON lac.approver_position_id = approver.position_id
WHERE p.council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'MC')
ORDER BY p.title, lac.step_number
/* vw_municipal_leave_approval_flow(position_title,step_number,approver_role,approver_title) */;
CREATE VIEW vw_city_organization_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        position_id,
        title,
        reports_to,
        1 as level,
        title as path
    FROM positions
    WHERE reports_to IS NULL 
    AND council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'CC')
    
    UNION ALL
    
    SELECT 
        p.position_id,
        p.title,
        p.reports_to,
        ot.level + 1,
        ot.path || ' -> ' || p.title
    FROM positions p
    INNER JOIN org_tree ot ON p.reports_to = ot.position_id
    WHERE p.council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'CC')
)
SELECT * FROM org_tree ORDER BY level, title
/* vw_city_organization_chart(position_id,title,reports_to,level,path) */;
CREATE VIEW vw_city_positions_summary AS
SELECT 
    p.position_id,
    p.title,
    s.section_name,
    p.salary_scale,
    p.proposed_establishment,
    supervisor.title as reports_to_title,
    p.is_head_of_section,
    CASE WHEN p.is_head_of_section THEN 'Yes' ELSE 'No' END as is_head,
    ct.council_type_name
FROM positions p
LEFT JOIN sections s ON p.section_id = s.section_id
LEFT JOIN positions supervisor ON p.reports_to = supervisor.position_id
JOIN council_types ct ON p.council_type_id = ct.council_type_id
WHERE p.council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'CC')
ORDER BY s.section_name, p.level
/* vw_city_positions_summary(position_id,title,section_name,salary_scale,proposed_establishment,reports_to_title,is_head_of_section,is_head,council_type_name) */;
CREATE VIEW vw_city_leave_approval_flow AS
SELECT 
    p.title as position_title,
    lac.step_number,
    lac.approver_role,
    approver.title as approver_title
FROM leave_approval_chain lac
JOIN positions p ON lac.position_id = p.position_id
LEFT JOIN positions approver ON lac.approver_position_id = approver.position_id
WHERE p.council_type_id = (SELECT council_type_id FROM council_types WHERE council_type_code = 'CC')
ORDER BY p.title, lac.step_number
/* vw_city_leave_approval_flow(position_title,step_number,approver_role,approver_title) */;
CREATE TABLE eng_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    parent_unit_id INTEGER,
    council_type_id INTEGER,
    FOREIGN KEY (parent_unit_id) REFERENCES eng_units(unit_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
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
CREATE TABLE eng_leave_approval_chain (
    chain_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES eng_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES eng_positions(position_id)
);
CREATE VIEW eng_summary_by_council AS
SELECT 
    ct.council_type_name,
    COUNT(DISTINCT ep.position_id) as total_positions,
    SUM(ep.establishment_count) as total_staff,
    COUNT(DISTINCT eu.unit_id) as total_units,
    MIN(ss.level) as highest_grade_level,
    MAX(ss.level) as lowest_grade_level
FROM eng_positions ep
JOIN council_types ct ON ep.council_type_id = ct.council_type_id
JOIN salary_scales ss ON ep.salary_scale = ss.scale_code
GROUP BY ct.council_type_name;
CREATE VIEW eng_organization_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        ep.position_id,
        ep.title,
        ep.reports_to,
        ep.council_type_id,
        1 as level,
        ep.title as path,
        ep.establishment_count
    FROM eng_positions ep
    WHERE ep.reports_to IS NULL
    
    UNION ALL
    
    SELECT 
        ep.position_id,
        ep.title,
        ep.reports_to,
        ep.council_type_id,
        ot.level + 1,
        ot.path || ' -> ' || ep.title,
        ep.establishment_count
    FROM eng_positions ep
    INNER JOIN org_tree ot ON ep.reports_to = ot.position_id
)
SELECT 
    ct.council_type_name,
    ot.level,
    ot.position_id,
    ot.title,
    ot.reports_to,
    ot.establishment_count,
    ot.path
FROM org_tree ot
JOIN council_types ct ON ot.council_type_id = ct.council_type_id
ORDER BY ct.council_type_name, ot.level, ot.title
/* eng_organization_chart(council_type_name,level,position_id,title,reports_to,establishment_count,path) */;
CREATE VIEW eng_positions_detailed AS
SELECT 
    ct.council_type_name,
    eu.unit_name,
    eu.unit_code,
    ep.position_id,
    ep.title,
    ep.salary_scale,
    ss.level as grade_level,
    ep.establishment_count,
    supervisor.title as reports_to_title,
    CASE WHEN ep.is_head_of_unit = 1 THEN 'Yes' ELSE 'No' END as is_unit_head
FROM eng_positions ep
JOIN council_types ct ON ep.council_type_id = ct.council_type_id
JOIN eng_units eu ON ep.unit_id = eu.unit_id
LEFT JOIN salary_scales ss ON ep.salary_scale = ss.scale_code
LEFT JOIN eng_positions supervisor ON ep.reports_to = supervisor.position_id
ORDER BY ct.council_type_name, eu.unit_name, ss.level
/* eng_positions_detailed(council_type_name,unit_name,unit_code,position_id,title,salary_scale,grade_level,establishment_count,reports_to_title,is_unit_head) */;
CREATE VIEW eng_staff_by_unit AS
SELECT 
    ct.council_type_name,
    eu.unit_name,
    COUNT(DISTINCT ep.position_id) as unique_roles,
    SUM(ep.establishment_count) as total_staff,
    GROUP_CONCAT(DISTINCT ep.salary_scale) as salary_scales_used
FROM eng_positions ep
JOIN council_types ct ON ep.council_type_id = ct.council_type_id
JOIN eng_units eu ON ep.unit_id = eu.unit_id
GROUP BY ct.council_type_name, eu.unit_name
ORDER BY ct.council_type_name, total_staff DESC
/* eng_staff_by_unit(council_type_name,unit_name,unique_roles,total_staff,salary_scales_used) */;
CREATE VIEW eng_salary_scale_distribution AS
SELECT 
    ct.council_type_name,
    ep.salary_scale,
    ss.level,
    COUNT(DISTINCT ep.position_id) as position_count,
    SUM(ep.establishment_count) as employee_count,
    ROUND(AVG(ep.establishment_count), 1) as avg_per_position
FROM eng_positions ep
JOIN council_types ct ON ep.council_type_id = ct.council_type_id
JOIN salary_scales ss ON ep.salary_scale = ss.scale_code
GROUP BY ct.council_type_name, ep.salary_scale
ORDER BY ct.council_type_name, ss.level
/* eng_salary_scale_distribution(council_type_name,salary_scale,level,position_count,employee_count,avg_per_position) */;
CREATE TABLE planning_sections (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE planning_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES planning_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES planning_units(unit_id)
);
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
CREATE TABLE planning_leave_approval_chain (
    chain_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES planning_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES planning_positions(position_id)
);
CREATE VIEW planning_summary_by_council AS
SELECT 
    ct.council_type_name,
    COUNT(DISTINCT ps.section_id) as total_sections,
    COUNT(DISTINCT pu.unit_id) as total_units,
    COUNT(DISTINCT pp.position_id) as unique_positions,
    SUM(pp.establishment) as total_staff
FROM planning_positions pp
JOIN council_types ct ON pp.council_type_id = ct.council_type_id
LEFT JOIN planning_units pu ON pp.unit_id = pu.unit_id
LEFT JOIN planning_sections ps ON pp.section_id = ps.section_id
GROUP BY ct.council_type_name
/* planning_summary_by_council(council_type_name,total_sections,total_units,unique_positions,total_staff) */;
CREATE VIEW planning_org_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        pp.position_id,
        pp.title,
        pp.reports_to,
        pp.council_type_id,
        1 as level,
        pp.title as path,
        pp.establishment,
        pp.salary_scale
    FROM planning_positions pp
    WHERE pp.reports_to IS NULL
    
    UNION ALL
    
    SELECT 
        pp.position_id,
        pp.title,
        pp.reports_to,
        pp.council_type_id,
        ot.level + 1,
        ot.path || ' -> ' || pp.title,
        pp.establishment,
        pp.salary_scale
    FROM planning_positions pp
    INNER JOIN org_tree ot ON pp.reports_to = ot.position_id
)
SELECT 
    ct.council_type_name,
    ot.level,
    ot.position_id,
    ot.title,
    ot.salary_scale,
    ot.establishment,
    ot.reports_to,
    ot.path
FROM org_tree ot
JOIN council_types ct ON ot.council_type_id = ct.council_type_id
ORDER BY ct.council_type_name, ot.level, ot.title
/* planning_org_chart(council_type_name,level,position_id,title,salary_scale,establishment,reports_to,path) */;
CREATE VIEW planning_positions_detailed AS
SELECT 
    ct.council_type_name,
    ps.section_name,
    pu.unit_name,
    pp.position_id,
    pp.title,
    pp.salary_scale,
    ss.level as grade_level,
    pp.establishment,
    supervisor.title as reports_to_title,
    CASE WHEN pp.is_head_of_section = 1 THEN 'Yes' ELSE 'No' END as is_section_head,
    CASE WHEN pp.is_head_of_unit = 1 THEN 'Yes' ELSE 'No' END as is_unit_head
FROM planning_positions pp
JOIN council_types ct ON pp.council_type_id = ct.council_type_id
LEFT JOIN planning_sections ps ON pp.section_id = ps.section_id
LEFT JOIN planning_units pu ON pp.unit_id = pu.unit_id
LEFT JOIN salary_scales ss ON pp.salary_scale = ss.scale_code
LEFT JOIN planning_positions supervisor ON pp.reports_to = supervisor.position_id
ORDER BY ct.council_type_name, ps.section_name, pu.unit_name, ss.level
/* planning_positions_detailed(council_type_name,section_name,unit_name,position_id,title,salary_scale,grade_level,establishment,reports_to_title,is_section_head,is_unit_head) */;
CREATE VIEW planning_staff_by_unit AS
SELECT 
    ct.council_type_name,
    ps.section_name,
    pu.unit_name,
    COUNT(DISTINCT pp.position_id) as unique_roles,
    SUM(pp.establishment) as total_staff,
    GROUP_CONCAT(DISTINCT pp.salary_scale) as salary_scales
FROM planning_positions pp
JOIN council_types ct ON pp.council_type_id = ct.council_type_id
LEFT JOIN planning_sections ps ON pp.section_id = ps.section_id
LEFT JOIN planning_units pu ON pp.unit_id = pu.unit_id
GROUP BY ct.council_type_name, ps.section_name, pu.unit_name
ORDER BY ct.council_type_name, total_staff DESC
/* planning_staff_by_unit(council_type_name,section_name,unit_name,unique_roles,total_staff,salary_scales) */;
CREATE VIEW planning_salary_distribution AS
SELECT 
    ct.council_type_name,
    pp.salary_scale,
    ss.level,
    COUNT(DISTINCT pp.position_id) as position_count,
    SUM(pp.establishment) as employee_count
FROM planning_positions pp
JOIN council_types ct ON pp.council_type_id = ct.council_type_id
JOIN salary_scales ss ON pp.salary_scale = ss.scale_code
GROUP BY ct.council_type_name, pp.salary_scale
ORDER BY ct.council_type_name, ss.level
/* planning_salary_distribution(council_type_name,salary_scale,level,position_count,employee_count) */;
CREATE VIEW planning_management_structure AS
SELECT 
    ct.council_type_name,
    pp.title as position_title,
    pp.salary_scale,
    (SELECT COUNT(*) FROM planning_positions sub WHERE sub.reports_to = pp.position_id) as direct_reports,
    (SELECT SUM(establishment) FROM planning_positions sub WHERE sub.reports_to = pp.position_id) as total_team_size
FROM planning_positions pp
JOIN council_types ct ON pp.council_type_id = ct.council_type_id
WHERE pp.is_head_of_section = 1 OR pp.is_head_of_unit = 1
ORDER BY ct.council_type_name, pp.level
/* planning_management_structure(council_type_name,position_title,salary_scale,direct_reports,total_team_size) */;
CREATE VIEW planning_leave_flow_verification AS
SELECT 
    ct.council_type_name,
    p.title as position_title,
    lac.step_number,
    lac.approver_role,
    a.title as approver_title,
    CASE 
        WHEN lac.step_number = 1 AND lac.approver_role = 'Supervisor' AND 
             (lac.approver_position_id IS NULL OR EXISTS (
                SELECT 1 FROM planning_positions p2 
                WHERE p2.position_id = lac.approver_position_id
             )) THEN '✓ Valid'
        WHEN lac.step_number = 2 AND lac.approver_role = 'Head of Department' AND
             EXISTS (SELECT 1 FROM planning_positions p2 WHERE p2.position_id = lac.approver_position_id)
             THEN '✓ Valid'
        WHEN lac.step_number = 3 AND lac.approver_role = 'Head of Council' AND
             EXISTS (SELECT 1 FROM planning_positions p2 WHERE p2.position_id = lac.approver_position_id)
             THEN '✓ Valid'
        ELSE '⚠ Check'
    END as validation_status
FROM planning_leave_approval_chain lac
JOIN planning_positions p ON lac.position_id = p.position_id
JOIN council_types ct ON p.council_type_id = ct.council_type_id
LEFT JOIN planning_positions a ON lac.approver_position_id = a.position_id
ORDER BY ct.council_type_name, p.title, lac.step_number
/* planning_leave_flow_verification(council_type_name,position_title,step_number,approver_role,approver_title,validation_status) */;
CREATE VIEW eng_leave_flow_verification AS
SELECT 
    ct.council_type_name,
    p.title as position_title,
    p.position_id,
    lac.step_number,
    lac.approver_role,
    a.title as approver_title,
    a.position_id as approver_id,
    CASE 
        WHEN lac.step_number = 1 AND lac.approver_role = 'Supervisor' AND 
             (lac.approver_position_id IS NULL OR 
              (lac.approver_position_id IS NOT NULL AND 
               EXISTS (SELECT 1 FROM eng_positions p2 WHERE p2.position_id = lac.approver_position_id)))
            THEN '✓ Valid'
        WHEN lac.step_number = 2 AND lac.approver_role = 'Head of Department' AND
             EXISTS (SELECT 1 FROM eng_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        WHEN lac.step_number = 3 AND lac.approver_role = 'Head of Council' AND
             EXISTS (SELECT 1 FROM eng_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        ELSE '⚠ Check'
    END as validation_status
FROM eng_leave_approval_chain lac
JOIN eng_positions p ON lac.position_id = p.position_id
JOIN council_types ct ON p.council_type_id = ct.council_type_id
LEFT JOIN eng_positions a ON lac.approver_position_id = a.position_id
ORDER BY ct.council_type_name, p.title, lac.step_number
/* eng_leave_flow_verification(council_type_name,position_title,position_id,step_number,approver_role,approver_title,approver_id,validation_status) */;
CREATE TABLE finance_sections (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE finance_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES finance_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES finance_units(unit_id)
);
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
CREATE TABLE finance_leave_approval_chain (
    chain_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES finance_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES finance_positions(position_id)
);
CREATE VIEW finance_summary_by_council AS
SELECT 
    ct.council_type_name,
    ct.head_of_council_title,
    COUNT(DISTINCT fs.section_id) as total_sections,
    COUNT(DISTINCT fu.unit_id) as total_units,
    COUNT(DISTINCT fp.position_id) as unique_positions,
    SUM(fp.establishment) as total_staff
FROM finance_positions fp
JOIN council_types ct ON fp.council_type_id = ct.council_type_id
LEFT JOIN finance_units fu ON fp.unit_id = fu.unit_id
LEFT JOIN finance_sections fs ON fp.section_id = fs.section_id
GROUP BY ct.council_type_name
/* finance_summary_by_council(council_type_name,head_of_council_title,total_sections,total_units,unique_positions,total_staff) */;
CREATE VIEW finance_org_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        fp.position_id,
        fp.title,
        fp.reports_to,
        fp.council_type_id,
        1 as level,
        fp.title as path,
        fp.establishment,
        fp.salary_scale
    FROM finance_positions fp
    WHERE fp.reports_to IS NULL
    
    UNION ALL
    
    SELECT 
        fp.position_id,
        fp.title,
        fp.reports_to,
        fp.council_type_id,
        ot.level + 1,
        ot.path || ' -> ' || fp.title,
        fp.establishment,
        fp.salary_scale
    FROM finance_positions fp
    INNER JOIN org_tree ot ON fp.reports_to = ot.position_id
)
SELECT 
    ct.council_type_name,
    ot.level,
    ot.position_id,
    ot.title,
    ot.salary_scale,
    ot.establishment,
    ot.reports_to,
    ot.path
FROM org_tree ot
JOIN council_types ct ON ot.council_type_id = ct.council_type_id
ORDER BY ct.council_type_name, ot.level, ot.title
/* finance_org_chart(council_type_name,level,position_id,title,salary_scale,establishment,reports_to,path) */;
CREATE VIEW finance_positions_detailed AS
SELECT 
    ct.council_type_name,
    fs.section_name,
    fu.unit_name,
    fp.position_id,
    fp.title,
    fp.salary_scale,
    ss.level as grade_level,
    fp.establishment,
    supervisor.title as reports_to_title,
    hoc.title as head_of_council,
    CASE WHEN fp.is_head_of_section = 1 THEN 'Yes' ELSE 'No' END as is_section_head
FROM finance_positions fp
JOIN council_types ct ON fp.council_type_id = ct.council_type_id
LEFT JOIN finance_sections fs ON fp.section_id = fs.section_id
LEFT JOIN finance_units fu ON fp.unit_id = fu.unit_id
LEFT JOIN salary_scales ss ON fp.salary_scale = ss.scale_code
LEFT JOIN finance_positions supervisor ON fp.reports_to = supervisor.position_id
LEFT JOIN finance_positions hoc ON 
    (ct.council_type_code = 'TC' AND hoc.position_id = 'COUNCIL-SEC-TOWN') OR
    (ct.council_type_code = 'MC' AND hoc.position_id = 'TOWN-CLERK-MUN') OR
    (ct.council_type_code = 'CC' AND hoc.position_id = 'TOWN-CLERK-CITY')
ORDER BY ct.council_type_name, fs.section_name, fu.unit_name, ss.level
/* finance_positions_detailed(council_type_name,section_name,unit_name,position_id,title,salary_scale,grade_level,establishment,reports_to_title,head_of_council,is_section_head) */;
CREATE VIEW finance_staff_by_section AS
SELECT 
    ct.council_type_name,
    fs.section_name,
    COUNT(DISTINCT fp.position_id) as unique_roles,
    SUM(fp.establishment) as total_staff,
    GROUP_CONCAT(DISTINCT fp.salary_scale) as salary_scales
FROM finance_positions fp
JOIN council_types ct ON fp.council_type_id = ct.council_type_id
LEFT JOIN finance_sections fs ON fp.section_id = fs.section_id
GROUP BY ct.council_type_name, fs.section_name
ORDER BY ct.council_type_name, total_staff DESC
/* finance_staff_by_section(council_type_name,section_name,unique_roles,total_staff,salary_scales) */;
CREATE VIEW finance_leave_flow_verification AS
SELECT 
    ct.council_type_name,
    p.title as position_title,
    p.position_id,
    lac.step_number,
    lac.approver_role,
    a.title as approver_title,
    a.position_id as approver_id,
    CASE 
        WHEN lac.step_number = 1 AND lac.approver_role = 'Supervisor' AND 
             (lac.approver_position_id IS NULL OR 
              (lac.approver_position_id IS NOT NULL AND 
               EXISTS (SELECT 1 FROM finance_positions p2 WHERE p2.position_id = lac.approver_position_id)))
            THEN '✓ Valid'
        WHEN lac.step_number = 2 AND lac.approver_role = 'Head of Department' AND
             EXISTS (SELECT 1 FROM finance_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        WHEN lac.step_number = 3 AND lac.approver_role = 'Head of Council' AND
             EXISTS (SELECT 1 FROM finance_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        ELSE '⚠ Check'
    END as validation_status
FROM finance_leave_approval_chain lac
JOIN finance_positions p ON lac.position_id = p.position_id
JOIN council_types ct ON p.council_type_id = ct.council_type_id
LEFT JOIN finance_positions a ON lac.approver_position_id = a.position_id
ORDER BY ct.council_type_name, p.title, lac.step_number
/* finance_leave_flow_verification(council_type_name,position_title,position_id,step_number,approver_role,approver_title,approver_id,validation_status) */;
CREATE VIEW finance_salary_distribution AS
SELECT 
    ct.council_type_name,
    fp.salary_scale,
    ss.level,
    COUNT(DISTINCT fp.position_id) as position_count,
    SUM(fp.establishment) as employee_count
FROM finance_positions fp
JOIN council_types ct ON fp.council_type_id = ct.council_type_id
JOIN salary_scales ss ON fp.salary_scale = ss.scale_code
GROUP BY ct.council_type_name, fp.salary_scale
ORDER BY ct.council_type_name, ss.level
/* finance_salary_distribution(council_type_name,salary_scale,level,position_count,employee_count) */;
CREATE TABLE legal_sections (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE legal_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES legal_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES legal_units(unit_id)
);
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
CREATE TABLE legal_leave_approval_chain (
    chain_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES legal_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES legal_positions(position_id)
);
CREATE VIEW legal_summary_by_council AS
SELECT 
    ct.council_type_name,
    ct.head_of_council_title,
    COUNT(DISTINCT ls.section_id) as total_sections,
    COUNT(DISTINCT lu.unit_id) as total_units,
    COUNT(DISTINCT lp.position_id) as unique_positions,
    SUM(lp.establishment) as total_staff
FROM legal_positions lp
JOIN council_types ct ON lp.council_type_id = ct.council_type_id
LEFT JOIN legal_units lu ON lp.unit_id = lu.unit_id
LEFT JOIN legal_sections ls ON lp.section_id = ls.section_id
GROUP BY ct.council_type_name
/* legal_summary_by_council(council_type_name,head_of_council_title,total_sections,total_units,unique_positions,total_staff) */;
CREATE VIEW legal_org_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        lp.position_id,
        lp.title,
        lp.reports_to,
        lp.council_type_id,
        1 as level,
        lp.title as path,
        lp.establishment,
        lp.salary_scale
    FROM legal_positions lp
    WHERE lp.reports_to IS NULL
    
    UNION ALL
    
    SELECT 
        lp.position_id,
        lp.title,
        lp.reports_to,
        lp.council_type_id,
        ot.level + 1,
        ot.path || ' -> ' || lp.title,
        lp.establishment,
        lp.salary_scale
    FROM legal_positions lp
    INNER JOIN org_tree ot ON lp.reports_to = ot.position_id
)
SELECT 
    ct.council_type_name,
    ot.level,
    ot.position_id,
    ot.title,
    ot.salary_scale,
    ot.establishment,
    ot.reports_to,
    ot.path
FROM org_tree ot
JOIN council_types ct ON ot.council_type_id = ct.council_type_id
ORDER BY ct.council_type_name, ot.level, ot.title
/* legal_org_chart(council_type_name,level,position_id,title,salary_scale,establishment,reports_to,path) */;
CREATE VIEW legal_positions_detailed AS
SELECT 
    ct.council_type_name,
    ls.section_name,
    lu.unit_name,
    lp.position_id,
    lp.title,
    lp.salary_scale,
    ss.level as grade_level,
    lp.establishment,
    supervisor.title as reports_to_title,
    hoc.title as head_of_council,
    CASE WHEN lp.is_head_of_section = 1 THEN 'Yes' ELSE 'No' END as is_section_head,
    CASE WHEN lp.is_head_of_unit = 1 THEN 'Yes' ELSE 'No' END as is_unit_head
FROM legal_positions lp
JOIN council_types ct ON lp.council_type_id = ct.council_type_id
LEFT JOIN legal_sections ls ON lp.section_id = ls.section_id
LEFT JOIN legal_units lu ON lp.unit_id = lu.unit_id
LEFT JOIN salary_scales ss ON lp.salary_scale = ss.scale_code
LEFT JOIN legal_positions supervisor ON lp.reports_to = supervisor.position_id
LEFT JOIN legal_positions hoc ON 
    (ct.council_type_code = 'TC' AND hoc.position_id = 'COUNCIL-SEC-TOWN') OR
    (ct.council_type_code = 'MC' AND hoc.position_id = 'TOWN-CLERK-MUN') OR
    (ct.council_type_code = 'CC' AND hoc.position_id = 'TOWN-CLERK-CITY')
ORDER BY ct.council_type_name, ls.section_name, lu.unit_name, ss.level
/* legal_positions_detailed(council_type_name,section_name,unit_name,position_id,title,salary_scale,grade_level,establishment,reports_to_title,head_of_council,is_section_head,is_unit_head) */;
CREATE VIEW legal_staff_by_section AS
SELECT 
    ct.council_type_name,
    ls.section_name,
    COUNT(DISTINCT lp.position_id) as unique_roles,
    SUM(lp.establishment) as total_staff,
    GROUP_CONCAT(DISTINCT lp.salary_scale) as salary_scales
FROM legal_positions lp
JOIN council_types ct ON lp.council_type_id = ct.council_type_id
LEFT JOIN legal_sections ls ON lp.section_id = ls.section_id
GROUP BY ct.council_type_name, ls.section_name
ORDER BY ct.council_type_name, total_staff DESC
/* legal_staff_by_section(council_type_name,section_name,unique_roles,total_staff,salary_scales) */;
CREATE VIEW legal_leave_flow_verification AS
SELECT 
    ct.council_type_name,
    p.title as position_title,
    p.position_id,
    lac.step_number,
    lac.approver_role,
    a.title as approver_title,
    a.position_id as approver_id,
    CASE 
        WHEN lac.step_number = 1 AND lac.approver_role = 'Supervisor' AND 
             (lac.approver_position_id IS NULL OR 
              (lac.approver_position_id IS NOT NULL AND 
               EXISTS (SELECT 1 FROM legal_positions p2 WHERE p2.position_id = lac.approver_position_id)))
            THEN '✓ Valid'
        WHEN lac.step_number = 2 AND lac.approver_role = 'Head of Department' AND
             EXISTS (SELECT 1 FROM legal_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        WHEN lac.step_number = 3 AND lac.approver_role = 'Head of Council' AND
             EXISTS (SELECT 1 FROM legal_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        ELSE '⚠ Check'
    END as validation_status
FROM legal_leave_approval_chain lac
JOIN legal_positions p ON lac.position_id = p.position_id
JOIN council_types ct ON p.council_type_id = ct.council_type_id
LEFT JOIN legal_positions a ON lac.approver_position_id = a.position_id
ORDER BY ct.council_type_name, p.title, lac.step_number
/* legal_leave_flow_verification(council_type_name,position_title,position_id,step_number,approver_role,approver_title,approver_id,validation_status) */;
CREATE VIEW legal_salary_distribution AS
SELECT 
    ct.council_type_name,
    lp.salary_scale,
    ss.level,
    COUNT(DISTINCT lp.position_id) as position_count,
    SUM(lp.establishment) as employee_count
FROM legal_positions lp
JOIN council_types ct ON lp.council_type_id = ct.council_type_id
JOIN salary_scales ss ON lp.salary_scale = ss.scale_code
GROUP BY ct.council_type_name, lp.salary_scale
ORDER BY ct.council_type_name, ss.level
/* legal_salary_distribution(council_type_name,salary_scale,level,position_count,employee_count) */;
CREATE TABLE council_types (
    council_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
    council_type_code TEXT UNIQUE NOT NULL,
    council_type_name TEXT NOT NULL,
    head_of_council_title TEXT NOT NULL,
    head_of_council_scale TEXT NOT NULL
);
CREATE TABLE salary_scales (
    scale_id INTEGER PRIMARY KEY AUTOINCREMENT,
    scale_code TEXT UNIQUE NOT NULL,
    scale_name TEXT,
    level INTEGER,
    applicable_to TEXT
);
CREATE TABLE health_sections (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_name TEXT NOT NULL,
    section_code TEXT,
    council_type_id INTEGER,
    description TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE health_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT,
    section_id INTEGER,
    council_type_id INTEGER,
    parent_unit_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES health_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id),
    FOREIGN KEY (parent_unit_id) REFERENCES health_units(unit_id)
);
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
CREATE TABLE health_leave_approval_chain (
    chain_id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id TEXT NOT NULL,
    step_number INTEGER NOT NULL,
    approver_role TEXT NOT NULL,
    approver_position_id TEXT,
    FOREIGN KEY (position_id) REFERENCES health_positions(position_id),
    FOREIGN KEY (approver_position_id) REFERENCES health_positions(position_id)
);
CREATE VIEW health_summary_by_council AS
SELECT 
    ct.council_type_name,
    ct.head_of_council_title,
    COUNT(DISTINCT hu.unit_id) as total_units,
    COUNT(DISTINCT hp.position_id) as unique_positions,
    SUM(hp.establishment) as total_staff
FROM health_positions hp
JOIN council_types ct ON hp.council_type_id = ct.council_type_id
LEFT JOIN health_units hu ON hp.unit_id = hu.unit_id
GROUP BY ct.council_type_name
/* health_summary_by_council(council_type_name,head_of_council_title,total_units,unique_positions,total_staff) */;
CREATE VIEW health_org_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        hp.position_id,
        hp.title,
        hp.reports_to,
        hp.council_type_id,
        1 as level,
        hp.title as path,
        hp.establishment,
        hp.salary_scale
    FROM health_positions hp
    WHERE hp.reports_to IS NULL
    
    UNION ALL
    
    SELECT 
        hp.position_id,
        hp.title,
        hp.reports_to,
        hp.council_type_id,
        ot.level + 1,
        ot.path || ' -> ' || hp.title,
        hp.establishment,
        hp.salary_scale
    FROM health_positions hp
    INNER JOIN org_tree ot ON hp.reports_to = ot.position_id
)
SELECT 
    ct.council_type_name,
    ot.level,
    ot.position_id,
    ot.title,
    ot.salary_scale,
    ot.establishment,
    ot.reports_to,
    ot.path
FROM org_tree ot
JOIN council_types ct ON ot.council_type_id = ct.council_type_id
ORDER BY ct.council_type_name, ot.level, ot.title
/* health_org_chart(council_type_name,level,position_id,title,salary_scale,establishment,reports_to,path) */;
CREATE VIEW health_positions_detailed AS
SELECT 
    ct.council_type_name,
    hu.unit_name,
    hp.position_id,
    hp.title,
    hp.salary_scale,
    ss.level as grade_level,
    hp.establishment,
    supervisor.title as reports_to_title,
    hoc.title as head_of_council,
    CASE WHEN hp.is_head_of_unit = 1 THEN 'Yes' ELSE 'No' END as is_unit_head
FROM health_positions hp
JOIN council_types ct ON hp.council_type_id = ct.council_type_id
LEFT JOIN health_units hu ON hp.unit_id = hu.unit_id
LEFT JOIN salary_scales ss ON hp.salary_scale = ss.scale_code
LEFT JOIN health_positions supervisor ON hp.reports_to = supervisor.position_id
LEFT JOIN health_positions hoc ON 
    (ct.council_type_code = 'TC' AND hoc.position_id = 'COUNCIL-SEC-TOWN') OR
    (ct.council_type_code = 'MC' AND hoc.position_id = 'TOWN-CLERK-MUN') OR
    (ct.council_type_code = 'CC' AND hoc.position_id = 'TOWN-CLERK-CITY')
ORDER BY ct.council_type_name, hu.unit_name, ss.level
/* health_positions_detailed(council_type_name,unit_name,position_id,title,salary_scale,grade_level,establishment,reports_to_title,head_of_council,is_unit_head) */;
CREATE VIEW health_staff_by_unit AS
SELECT 
    ct.council_type_name,
    hu.unit_name,
    COUNT(DISTINCT hp.position_id) as unique_roles,
    SUM(hp.establishment) as total_staff,
    GROUP_CONCAT(DISTINCT hp.salary_scale) as salary_scales
FROM health_positions hp
JOIN council_types ct ON hp.council_type_id = ct.council_type_id
LEFT JOIN health_units hu ON hp.unit_id = hu.unit_id
WHERE hu.unit_name IS NOT NULL
GROUP BY ct.council_type_name, hu.unit_name
ORDER BY ct.council_type_name, total_staff DESC
/* health_staff_by_unit(council_type_name,unit_name,unique_roles,total_staff,salary_scales) */;
CREATE VIEW health_leave_flow_verification AS
SELECT 
    ct.council_type_name,
    p.title as position_title,
    p.position_id,
    lac.step_number,
    lac.approver_role,
    a.title as approver_title,
    a.position_id as approver_id,
    CASE 
        WHEN lac.step_number = 1 AND lac.approver_role = 'Supervisor' AND 
             (lac.approver_position_id IS NULL OR 
              (lac.approver_position_id IS NOT NULL AND 
               EXISTS (SELECT 1 FROM health_positions p2 WHERE p2.position_id = lac.approver_position_id)))
            THEN '✓ Valid'
        WHEN lac.step_number = 2 AND lac.approver_role = 'Head of Department' AND
             EXISTS (SELECT 1 FROM health_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        WHEN lac.step_number = 3 AND lac.approver_role = 'Head of Council' AND
             EXISTS (SELECT 1 FROM health_positions p2 WHERE p2.position_id = lac.approver_position_id)
            THEN '✓ Valid'
        ELSE '⚠ Check'
    END as validation_status
FROM health_leave_approval_chain lac
JOIN health_positions p ON lac.position_id = p.position_id
JOIN council_types ct ON p.council_type_id = ct.council_type_id
LEFT JOIN health_positions a ON lac.approver_position_id = a.position_id
ORDER BY ct.council_type_name, p.title, lac.step_number
/* health_leave_flow_verification(council_type_name,position_title,position_id,step_number,approver_role,approver_title,approver_id,validation_status) */;
CREATE VIEW health_salary_distribution AS
SELECT 
    ct.council_type_name,
    hp.salary_scale,
    ss.level,
    COUNT(DISTINCT hp.position_id) as position_count,
    SUM(hp.establishment) as employee_count
FROM health_positions hp
JOIN council_types ct ON hp.council_type_id = ct.council_type_id
JOIN salary_scales ss ON hp.salary_scale = ss.scale_code
GROUP BY ct.council_type_name, hp.salary_scale
ORDER BY ct.council_type_name, ss.level
/* health_salary_distribution(council_type_name,salary_scale,level,position_count,employee_count) */;
CREATE TABLE leave_types (
    leave_type_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE hr_recipients (
    recipient_id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL UNIQUE,
    email TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
CREATE TABLE mothers_day_notification_log (
    notification_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE INDEX idx_notification_tracking ON mothers_day_notification_log(tracking_id);
CREATE INDEX idx_notification_recipient ON mothers_day_notification_log(recipient_id);
CREATE INDEX idx_notification_status ON mothers_day_notification_log(status);
CREATE TABLE mothers_day_acknowledgments (
    acknowledgment_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE VIEW vw_mothers_day_notification_log AS
SELECT 
    mnl.notification_id,
    mnl.tracking_id,
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    mnl.recipient_type,
    mnl.recipient_name,
    mnl.recipient_email,
    mnl.notification_subject,
    mnl.sent_at,
    mnl.status,
    mnl.read_at,
    CASE WHEN mnl.read_at IS NOT NULL THEN 'Read' ELSE 'Unread' END as read_status
FROM mothers_day_notification_log mnl
JOIN mothers_day_leave_tracking mdt ON mnl.tracking_id = mdt.tracking_id
JOIN employees e ON mdt.employee_id = e.employee_id
ORDER BY mnl.sent_at DESC;
CREATE VIEW vw_mothers_day_monthly_notification_summary AS
SELECT 
    strftime('%Y-%m', mdt.leave_date) as month,
    COUNT(DISTINCT mdt.tracking_id) as total_leaves,
    COUNT(DISTINCT mnl.notification_id) as total_notifications,
    COUNT(DISTINCT CASE WHEN mnl.recipient_type = 'Supervisor' THEN mnl.notification_id END) as supervisor_notifications,
    COUNT(DISTINCT CASE WHEN mnl.recipient_type = 'HR' THEN mnl.notification_id END) as hr_notifications,
    COUNT(DISTINCT CASE WHEN mnl.status = 'Sent' THEN mnl.notification_id END) as sent,
    COUNT(DISTINCT CASE WHEN mnl.status = 'Delivered' THEN mnl.notification_id END) as delivered,
    COUNT(DISTINCT CASE WHEN mnl.status = 'Read' THEN mnl.notification_id END) as read,
    COUNT(DISTINCT CASE WHEN mnl.status = 'Failed' THEN mnl.notification_id END) as failed
FROM mothers_day_leave_tracking mdt
LEFT JOIN mothers_day_notification_log mnl ON mdt.tracking_id = mnl.tracking_id
GROUP BY strftime('%Y-%m', mdt.leave_date)
ORDER BY month DESC
/* vw_mothers_day_monthly_notification_summary(month,total_leaves,total_notifications,supervisor_notifications,hr_notifications,sent,delivered,read,failed) */;
CREATE TABLE notification_history (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE INDEX idx_notification_history_tracking ON notification_history(tracking_id);
CREATE INDEX idx_notification_history_recipient ON notification_history(recipient_id);
CREATE TABLE sms_gateway_config (
    config_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE sms_delivery_log (
    sms_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE INDEX idx_sms_delivery_status ON sms_delivery_log(status);
CREATE INDEX idx_sms_delivery_phone ON sms_delivery_log(phone_number);
CREATE TABLE sms_message_parts (
    part_id INTEGER PRIMARY KEY AUTOINCREMENT,
    notification_queue_id INTEGER NOT NULL,
    part_number INTEGER NOT NULL,
    total_parts INTEGER NOT NULL,
    message_text TEXT NOT NULL,
    character_count INTEGER NOT NULL,
    status TEXT DEFAULT 'Pending',
    sent_at TIMESTAMP,
    FOREIGN KEY (notification_queue_id) REFERENCES notification_queue(queue_id)
);
CREATE VIEW vw_sms_ready_notifications AS
SELECT 
    nq.queue_id,
    nq.tracking_id,
    nq.recipient_type,
    nq.recipient_id,
    nq.recipient_name,
    nq.recipient_phone,
    nq.sms_message,
    LENGTH(nq.sms_message) AS sms_length,
    CASE 
        WHEN LENGTH(nq.sms_message) <= 160 THEN 1
        ELSE CEIL(LENGTH(nq.sms_message) / 153.0) -- 153 chars per part for multi-part SMS
    END AS sms_parts,
    scg.gateway_url,
    scg.api_key,
    scg.sender_id
FROM notification_queue nq
CROSS JOIN sms_gateway_config scg
WHERE nq.notification_method IN ('SMS', 'Both')
AND nq.status = 'Pending'
AND nq.recipient_phone IS NOT NULL
AND scg.is_active = 1;
CREATE INDEX idx_acknowledgments_tracking ON mothers_day_acknowledgments(tracking_id);
CREATE TRIGGER trg_update_acknowledgment_status
AFTER INSERT ON mothers_day_acknowledgments
BEGIN
    UPDATE mothers_day_leave_tracking 
    SET 
        supervisor_acknowledged = CASE 
            WHEN NEW.recipient_type = 'Supervisor' THEN 1 
            ELSE supervisor_acknowledged 
        END,
        supervisor_acknowledgment_date = CASE 
            WHEN NEW.recipient_type = 'Supervisor' THEN NEW.acknowledged_at 
            ELSE supervisor_acknowledgment_date 
        END,
        hr_acknowledged = CASE 
            WHEN NEW.recipient_type = 'HR' THEN 1 
            ELSE hr_acknowledged 
        END,
        hr_acknowledgment_date = CASE 
            WHEN NEW.recipient_type = 'HR' THEN NEW.acknowledged_at 
            ELSE hr_acknowledgment_date 
        END,
        status = CASE 
            WHEN (CASE WHEN NEW.recipient_type = 'Supervisor' THEN 1 ELSE supervisor_acknowledged END) = 1
                 AND (CASE WHEN NEW.recipient_type = 'HR' THEN 1 ELSE hr_acknowledged END) = 1
            THEN 'Fully Acknowledged'
            WHEN (CASE WHEN NEW.recipient_type = 'Supervisor' THEN 1 ELSE supervisor_acknowledged END) = 1
                  OR (CASE WHEN NEW.recipient_type = 'HR' THEN 1 ELSE hr_acknowledged END) = 1
            THEN 'Partially Acknowledged'
            ELSE status
        END
    WHERE tracking_id = NEW.tracking_id;
END;
CREATE VIEW vw_employee_eligibility AS
SELECT 
    e.employee_id,
    e.name AS employee_name,
    e.sex,  -- Using sex column
    e.supervisor_id,
    e.email,
    e.phone_number,
    e.notification_preference,
    e.is_active,
    CASE 
        WHEN e.sex = 'F' AND e.is_active = 1 THEN 1 
        ELSE 0 
    END AS is_eligible,
    strftime('%Y-%m', 'now') AS current_month
FROM employees e
/* vw_employee_eligibility(employee_id,employee_name,sex,supervisor_id,email,phone_number,notification_preference,is_active,is_eligible,current_month) */;
CREATE VIEW vw_monthly_leave_taken AS
SELECT 
    employee_id,
    month_year,
    COUNT(*) AS days_taken
FROM mothers_day_leave_tracking
GROUP BY employee_id, month_year
/* vw_monthly_leave_taken(employee_id,month_year,days_taken) */;
CREATE VIEW vw_eligibility_with_status AS
SELECT 
    e.*,
    COALESCE(mlt.days_taken, 0) AS days_taken_this_month,
    CASE 
        WHEN e.is_eligible = 1 AND COALESCE(mlt.days_taken, 0) = 0 THEN 1
        ELSE 0
    END AS can_take_leave
FROM vw_employee_eligibility e
LEFT JOIN vw_monthly_leave_taken mlt ON e.employee_id = mlt.employee_id AND mlt.month_year = e.current_month
/* vw_eligibility_with_status(employee_id,employee_name,sex,supervisor_id,email,phone_number,notification_preference,is_active,is_eligible,current_month,days_taken_this_month,can_take_leave) */;
CREATE VIEW vw_employee_mothers_day_history AS
SELECT 
    e.employee_id,
    e.name AS employee_name,
    e.sex,
    e.phone_number,
    e.email,
    e.notification_preference,
    e.department,
    s.name AS supervisor_name,
    COUNT(mdt.tracking_id) as total_days_taken,
    GROUP_CONCAT(mdt.month_year) as months_taken,
    MAX(mdt.leave_date) as last_taken_date
FROM employees e
LEFT JOIN employees s ON e.supervisor_id = s.employee_id
LEFT JOIN mothers_day_leave_tracking mdt ON e.employee_id = mdt.employee_id
WHERE e.sex = 'F' AND e.is_active = 1
GROUP BY e.employee_id
ORDER BY total_days_taken DESC
/* vw_employee_mothers_day_history(employee_id,employee_name,sex,phone_number,email,notification_preference,department,supervisor_name,total_days_taken,months_taken,last_taken_date) */;
CREATE VIEW vw_mothers_day_pending_acknowledgments AS
SELECT 
    mdt.tracking_id,
    e.employee_id,
    e.name AS employee_name,
    e.department,
    mdt.leave_date,
    mdt.month_year,
    mdt.created_at as notification_date,
    CASE 
        WHEN NOT mdt.supervisor_acknowledged AND mdt.supervisor_id IS NOT NULL 
            THEN 'Pending Supervisor: ' || (SELECT name FROM employees WHERE employee_id = mdt.supervisor_id)
        WHEN NOT mdt.hr_acknowledged THEN 'Pending HR'
        ELSE 'No Pending'
    END as pending_with,
    mdt.supervisor_acknowledged,
    mdt.hr_acknowledged,
    s.phone_number as pending_recipient_phone,
    s.email as pending_recipient_email
FROM mothers_day_leave_tracking mdt
JOIN employees e ON mdt.employee_id = e.employee_id
LEFT JOIN employees s ON s.employee_id = mdt.supervisor_id
WHERE NOT (mdt.supervisor_acknowledged AND mdt.hr_acknowledged)
ORDER BY mdt.created_at;
CREATE VIEW vw_pending_sms_notifications AS
SELECT 
    nq.*,
    e.name AS employee_name,
    e.department
FROM notification_queue nq
JOIN mothers_day_leave_tracking mdt ON nq.tracking_id = mdt.tracking_id
JOIN employees e ON mdt.employee_id = e.employee_id
WHERE nq.status = 'Pending'
AND nq.notification_method IN ('SMS', 'Both')
AND nq.recipient_phone IS NOT NULL
ORDER BY nq.created_at;
CREATE VIEW vw_mothers_day_monthly_report AS
SELECT 
    strftime('%Y-%m', leave_date) as month,
    COUNT(*) as total_taken,
    COUNT(DISTINCT employee_id) as unique_employees,
    SUM(CASE WHEN supervisor_notified THEN 1 ELSE 0 END) as supervisor_notified,
    SUM(CASE WHEN supervisor_acknowledged THEN 1 ELSE 0 END) as supervisor_acknowledged,
    SUM(CASE WHEN hr_notified THEN 1 ELSE 0 END) as hr_notified,
    SUM(CASE WHEN hr_acknowledged THEN 1 ELSE 0 END) as hr_acknowledged
FROM mothers_day_leave_tracking
GROUP BY strftime('%Y-%m', leave_date)
ORDER BY month DESC;
CREATE TABLE mothers_day_leave_tracking (
    tracking_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    FOREIGN KEY (supervisor_id) REFERENCES employees(employee_id)
);
CREATE INDEX idx_mothers_day_employee ON mothers_day_leave_tracking(employee_id);
CREATE INDEX idx_mothers_day_month ON mothers_day_leave_tracking(month_year);
CREATE INDEX idx_mothers_day_status ON mothers_day_leave_tracking(status);
CREATE TABLE notification_queue (
    queue_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE VIEW vw_pending_supervisor_approvals AS
SELECT 
    mdt.tracking_id,
    e.name AS employee_name,
    e.department,
    mdt.leave_date,
    mdt.month_year,
    mdt.created_at as request_date,
    s.name AS supervisor_name,
    s.email AS supervisor_email,
    s.phone_number AS supervisor_phone
FROM mothers_day_leave_tracking mdt
JOIN employees e ON mdt.employee_id = e.employee_id
JOIN employees s ON mdt.supervisor_id = s.employee_id
WHERE mdt.supervisor_approved = 0
AND mdt.status = 'Pending'
ORDER BY mdt.created_at
/* vw_pending_supervisor_approvals(tracking_id,employee_name,department,leave_date,month_year,request_date,supervisor_name,supervisor_email,supervisor_phone) */;
CREATE VIEW vw_hr_notifications AS
SELECT 
    mdt.tracking_id,
    e.name AS employee_name,
    e.department,
    mdt.leave_date,
    mdt.month_year,
    s.name AS supervisor_name,
    mdt.supervisor_approved,
    mdt.supervisor_approval_date,
    mdt.hr_viewed,
    mdt.created_at as submitted_date,
    CASE 
        WHEN mdt.hr_viewed = 0 THEN 'New'
        ELSE 'Viewed'
    END as notification_status
FROM mothers_day_leave_tracking mdt
JOIN employees e ON mdt.employee_id = e.employee_id
LEFT JOIN employees s ON mdt.supervisor_id = s.employee_id
WHERE mdt.supervisor_approved = 1  -- Only show approved leaves
ORDER BY mdt.supervisor_approval_date DESC
/* vw_hr_notifications(tracking_id,employee_name,department,leave_date,month_year,supervisor_name,supervisor_approved,supervisor_approval_date,hr_viewed,submitted_date,notification_status) */;
CREATE VIEW vw_employee_leave_history AS
SELECT 
    e.employee_id,
    e.name AS employee_name,
    e.department,
    COUNT(mdt.tracking_id) as total_days_taken,
    GROUP_CONCAT(mdt.month_year) as months_taken,
    SUM(CASE WHEN mdt.supervisor_approved = 1 THEN 1 ELSE 0 END) as approved_days,
    SUM(CASE WHEN mdt.status = 'Pending' THEN 1 ELSE 0 END) as pending_days,
    MAX(mdt.leave_date) as last_leave_date
FROM employees e
LEFT JOIN mothers_day_leave_tracking mdt ON e.employee_id = mdt.employee_id
WHERE e.sex = 'F' AND e.is_active = 1
GROUP BY e.employee_id
/* vw_employee_leave_history(employee_id,employee_name,department,total_days_taken,months_taken,approved_days,pending_days,last_leave_date) */;
CREATE VIEW vw_monthly_mothers_day_report AS
SELECT 
    strftime('%Y-%m', leave_date) as month,
    COUNT(*) as total_requests,
    SUM(CASE WHEN supervisor_approved = 1 THEN 1 ELSE 0 END) as approved,
    SUM(CASE WHEN supervisor_approved = 0 AND status = 'Pending' THEN 1 ELSE 0 END) as pending,
    COUNT(DISTINCT employee_id) as unique_employees,
    GROUP_CONCAT(DISTINCT department) as departments
FROM mothers_day_leave_tracking
GROUP BY strftime('%Y-%m', leave_date)
ORDER BY month DESC;
CREATE INDEX idx_mothers_day_supervisor ON mothers_day_leave_tracking(supervisor_id);
CREATE INDEX idx_notification_queue_status ON notification_queue(status);
CREATE INDEX idx_notification_queue_tracking ON notification_queue(tracking_id);
CREATE VIEW vw_eligible_female_employees AS
SELECT 
    employee_id,
    name,
    department,
    position,
    phone_number,
    email,
    supervisor_id,
    notification_preference
FROM employees
WHERE sex = 'F' AND is_active = 1
/* vw_eligible_female_employees(employee_id,name,department,position,phone_number,email,supervisor_id,notification_preference) */;
CREATE VIEW vw_supervisor_assignments AS
SELECT 
    e.name AS employee_name,
    e.department,
    e.position,
    s.name AS supervisor_name,
    s.position AS supervisor_position,
    s.phone_number AS supervisor_phone,
    s.email AS supervisor_email
FROM employees e
LEFT JOIN employees s ON e.supervisor_id = s.employee_id
WHERE e.sex = 'F'
ORDER BY e.department, e.name
/* vw_supervisor_assignments(employee_name,department,position,supervisor_name,supervisor_position,supervisor_phone,supervisor_email) */;
CREATE VIEW vw_hr_recipients AS
SELECT 
    e.name,
    e.position,
    e.department,
    hr.email,
    e.phone_number,
    CASE WHEN hr.is_primary = 1 THEN 'Primary' ELSE 'Secondary' END as role
FROM hr_recipients hr
JOIN employees e ON hr.employee_id = e.employee_id
WHERE hr.is_active = 1
/* vw_hr_recipients(name,position,department,email,phone_number,role) */;
CREATE VIEW vw_supervisor_workload AS
SELECT 
    s.name AS supervisor_name,
    s.position,
    s.department,
    COUNT(e.employee_id) as direct_reports,
    GROUP_CONCAT(e.name) as staff_list
FROM employees s
JOIN employees e ON s.employee_id = e.supervisor_id
GROUP BY s.employee_id
ORDER BY direct_reports DESC
/* vw_supervisor_workload(supervisor_name,position,department,direct_reports,staff_list) */;
CREATE VIEW vw_notification_preferences AS
SELECT 
    notification_preference,
    COUNT(*) as employee_count,
    GROUP_CONCAT(name) as employees
FROM employees
WHERE sex = 'F' AND is_active = 1
GROUP BY notification_preference
/* vw_notification_preferences(notification_preference,employee_count,employees) */;
CREATE TRIGGER trg_prevent_duplicate_monthly
BEFORE INSERT ON mothers_day_leave_tracking
BEGIN
    SELECT CASE
        WHEN EXISTS (
            SELECT 1 FROM mothers_day_leave_tracking 
            WHERE employee_id = NEW.employee_id 
            AND month_year = NEW.month_year
        ) THEN RAISE(ABORT, 'Employee has already taken Mother''s Day leave this month')
    END;
END;
CREATE TRIGGER trg_validate_employee_gender
BEFORE INSERT ON mothers_day_leave_tracking
BEGIN
    SELECT CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM employees 
            WHERE employee_id = NEW.employee_id 
            AND sex = 'F' 
            AND is_active = 1
        ) THEN RAISE(ABORT, 'Mother''s Day leave is only for female employees')
    END;
END;
CREATE TRIGGER trg_validate_supervisor_exists
BEFORE INSERT ON mothers_day_leave_tracking
BEGIN
    SELECT CASE
        WHEN NEW.supervisor_id IS NULL AND NOT EXISTS (
            SELECT 1 FROM employees 
            WHERE employee_id = NEW.employee_id 
            AND supervisor_id IS NOT NULL
        ) THEN RAISE(ABORT, 'Employee has no supervisor assigned. Please assign a supervisor first.')
    END;
END;
CREATE TRIGGER trg_set_month_year
BEFORE INSERT ON mothers_day_leave_tracking
BEGIN
    SELECT CASE
        WHEN NEW.month_year IS NULL THEN
            NEW.month_year = strftime('%Y-%m', NEW.leave_date)
    END;
END;
CREATE TABLE eng_position_hierarchy (
    hierarchy_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE INDEX idx_eng_position_id ON eng_position_hierarchy(position_id);
CREATE INDEX idx_eng_reports_to ON eng_position_hierarchy(reports_to_position_id);
CREATE INDEX idx_eng_council ON eng_position_hierarchy(council_type);
CREATE VIEW vw_eng_hierarchy_by_council AS
SELECT 
    ph.council_type,
    ph.level,
    ph.position_id,
    ph.position_title,
    ph.unit,
    ph.salary_scale,
    ph.establishment_count,
    supervisor.position_title AS reports_to_title,
    supervisor.position_id AS reports_to_id,
    CASE WHEN ph.is_head_of_unit THEN 'Yes' ELSE 'No' END AS is_unit_head
FROM eng_position_hierarchy ph
LEFT JOIN eng_position_hierarchy supervisor ON ph.reports_to_position_id = supervisor.position_id
ORDER BY ph.council_type, ph.level, ph.unit
/* vw_eng_hierarchy_by_council(council_type,level,position_id,position_title,unit,salary_scale,establishment_count,reports_to_title,reports_to_id,is_unit_head) */;
CREATE VIEW vw_eng_org_chart AS
WITH RECURSIVE org_tree AS (
    SELECT 
        position_id,
        position_title,
        reports_to_position_id,
        council_type,
        1 as level,
        position_title as path
    FROM eng_position_hierarchy
    WHERE reports_to_position_id IS NULL
    
    UNION ALL
    
    SELECT 
        ph.position_id,
        ph.position_title,
        ph.reports_to_position_id,
        ph.council_type,
        ot.level + 1,
        ot.path || ' → ' || ph.position_title
    FROM eng_position_hierarchy ph
    INNER JOIN org_tree ot ON ph.reports_to_position_id = ot.position_id
)
SELECT 
    council_type,
    level,
    position_id,
    position_title,
    path
FROM org_tree
ORDER BY council_type, level, position_title
/* vw_eng_org_chart(council_type,level,position_id,position_title,path) */;
CREATE VIEW vw_eng_supervisors AS
SELECT 
    ph.position_id AS employee_position_id,
    ph.position_title AS employee_title,
    ph.council_type,
    ph.unit,
    sup.position_id AS supervisor_position_id,
    sup.position_title AS supervisor_title,
    sup.unit AS supervisor_unit
FROM eng_position_hierarchy ph
LEFT JOIN eng_position_hierarchy sup ON ph.reports_to_position_id = sup.position_id
WHERE ph.reports_to_position_id IS NOT NULL
ORDER BY ph.council_type, ph.unit, ph.level
/* vw_eng_supervisors(employee_position_id,employee_title,council_type,unit,supervisor_position_id,supervisor_title,supervisor_unit) */;
CREATE VIEW vw_eng_summary_by_council AS
SELECT 
    council_type,
    COUNT(*) as total_positions,
    COUNT(DISTINCT unit) as total_units,
    MAX(level) as max_depth,
    SUM(establishment_count) as total_establishment
FROM eng_position_hierarchy
GROUP BY council_type
ORDER BY council_type
/* vw_eng_summary_by_council(council_type,total_positions,total_units,max_depth,total_establishment) */;
CREATE VIEW vw_mothers_day_engineering_all_councils AS
SELECT 
    'Engineering' as department,
    vs.council_type,
    vs.employee_title,
    vs.unit,
    vs.supervisor_title AS immediate_supervisor,
    vs.supervisor_unit,
    CASE 
        WHEN vs.council_type = 'Town' THEN 'Council Secretary'
        WHEN vs.council_type = 'Municipal' THEN 'Town Clerk'
        WHEN vs.council_type = 'City' THEN 'Town Clerk'
    END AS council_head,
    'HR Department' AS notification_recipient,
    'Supervisor Only' AS approval_chain
FROM vw_eng_supervisors vs
WHERE vs.reports_to_position_id IS NOT NULL  -- Exclude top-level positions
ORDER BY vs.council_type, vs.unit, vs.employee_title;
CREATE VIEW vw_mothers_day_engineering AS
SELECT 
    'Engineering' as department,
    council_type,
    employee_title,
    unit as employee_unit,
    supervisor_title AS immediate_supervisor,
    supervisor_unit,
    CASE 
        WHEN council_type = 'Town' THEN 'Council Secretary'
        WHEN council_type = 'Municipal' THEN 'Town Clerk'
        WHEN council_type = 'City' THEN 'Town Clerk'
    END AS council_head,
    'HR Department' AS notification_recipient
FROM vw_eng_supervisors
WHERE supervisor_title IS NOT NULL  -- Only positions with supervisors
  AND employee_title IS NOT NULL
ORDER BY council_type, unit, employee_title
/* vw_mothers_day_engineering(department,council_type,employee_title,employee_unit,immediate_supervisor,supervisor_unit,council_head,notification_recipient) */;
CREATE VIEW vw_mothers_day_hr_summary AS
SELECT 
    council_type,
    immediate_supervisor,
    supervisor_unit,
    COUNT(*) as staff_count,
    GROUP_CONCAT(employee_title, ', ') as staff_list
FROM vw_mothers_day_engineering
GROUP BY council_type, immediate_supervisor
ORDER BY council_type, staff_count DESC
/* vw_mothers_day_hr_summary(council_type,immediate_supervisor,supervisor_unit,staff_count,staff_list) */;
CREATE VIEW vw_fire_service_hierarchy AS
SELECT 
    e.name AS employee_name,
    e.position,
    s1.name AS supervisor_name,
    s1.position AS supervisor_position,
    s2.name AS sub_officer_name,
    s2.position AS sub_officer_position,
    s3.name AS station_officer_name,
    s3.position AS station_officer_position,
    s4.name AS divisional_officer_name,
    s4.position AS divisional_officer_position,
    s5.name AS assistant_director_name,
    s5.position AS assistant_director_position,
    s6.name AS director_name,
    s6.position AS director_position
FROM employees e
LEFT JOIN employees s1 ON e.supervisor_id = s1.employee_id
LEFT JOIN employees s2 ON s1.supervisor_id = s2.employee_id
LEFT JOIN employees s3 ON s2.supervisor_id = s3.employee_id
LEFT JOIN employees s4 ON s3.supervisor_id = s4.employee_id
LEFT JOIN employees s5 ON s4.supervisor_id = s5.employee_id
LEFT JOIN employees s6 ON s5.supervisor_id = s6.employee_id
WHERE e.department = 'Engineering' 
  AND (e.position LIKE '%Fire%' OR e.position LIKE '%Station%' OR e.position LIKE '%Sub-%' OR e.position LIKE '%Divisional%')
ORDER BY 
    CASE 
        WHEN e.position = 'Divisional Fire Officer' THEN 1
        WHEN e.position = 'Station Officer' THEN 2
        WHEN e.position = 'Sub-Officer' THEN 3
        WHEN e.position = 'Leading Firefighter' THEN 4
        WHEN e.position = 'Firefighter' THEN 5
        ELSE 6
    END
/* vw_fire_service_hierarchy(employee_name,position,supervisor_name,supervisor_position,sub_officer_name,sub_officer_position,station_officer_name,station_officer_position,divisional_officer_name,divisional_officer_position,assistant_director_name,assistant_director_position,director_name,director_position) */;
CREATE VIEW vw_mothers_day_engineering_approvers AS
SELECT 
    e.employee_id,
    e.name AS employee_name,
    e.position,
    e.department,
    s.employee_id AS approver_id,
    s.name AS approver_name,
    s.position AS approver_position,
    'HR Department' AS notification_recipient
FROM employees e
LEFT JOIN employees s ON e.supervisor_id = s.employee_id
WHERE e.department = 'Engineering' 
  AND e.sex = 'F'
  AND e.is_active = 1
/* vw_mothers_day_engineering_approvers(employee_id,employee_name,position,department,approver_id,approver_name,approver_position,notification_recipient) */;
CREATE VIEW vw_position_hierarchy AS
SELECT 
    ph.position_id,
    ph.position_title,
    ph.unit,
    ph.salary_scale,
    ph.establishment_count,
    ph.council_type,
    sup.position_id AS supervisor_position_id,
    sup.position_title AS supervisor_position,
    sup.unit AS supervisor_unit,
    sup.salary_scale AS supervisor_salary_scale,
    ph.level
FROM eng_position_hierarchy ph
LEFT JOIN eng_position_hierarchy sup ON ph.reports_to_position_id = sup.position_id
ORDER BY ph.council_type, ph.level, ph.position_title
/* vw_position_hierarchy(position_id,position_title,unit,salary_scale,establishment_count,council_type,supervisor_position_id,supervisor_position,supervisor_unit,supervisor_salary_scale,level) */;
CREATE VIEW vw_mothers_day_position_approvers AS
SELECT 
    ph.position_title AS employee_position,
    ph.council_type,
    ph.salary_scale AS employee_scale,
    sup.position_title AS approver_position,
    sup.salary_scale AS approver_scale,
    'HR Department' AS notification_recipient
FROM eng_position_hierarchy ph
LEFT JOIN eng_position_hierarchy sup ON ph.reports_to_position_id = sup.position_id
WHERE ph.position_title IN ('Firefighter', 'Firefighter Driver', 
                           'Assistant Civil Engineer', 'Assistant Electrical Engineer',
                           'Administrative Officer', 'Clerical Officer')
   OR ph.position_title LIKE '%Assistant%'
ORDER BY ph.council_type, ph.position_title
/* vw_mothers_day_position_approvers(employee_position,council_type,employee_scale,approver_position,approver_scale,notification_recipient) */;
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
CREATE VIEW vw_position_migration_status AS
SELECT 
    'eng_position_hierarchy' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN standard_id IS NOT NULL THEN 1 ELSE 0 END) AS migrated,
    ROUND(SUM(CASE WHEN standard_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS percentage
FROM eng_position_hierarchy

UNION ALL

SELECT 
    'eng_positions',
    COUNT(*),
    SUM(CASE WHEN standard_id IS NOT NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN standard_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1)
FROM eng_positions

UNION ALL

SELECT 
    'planning_positions',
    COUNT(*),
    SUM(CASE WHEN standard_id IS NOT NULL THEN 1 ELSE 0 END),
    ROUND(SUM(CASE WHEN standard_id IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1)
FROM planning_positions
/* vw_position_migration_status(table_name,total_records,migrated,percentage) */;
CREATE TABLE position_role_codes (
    position_title TEXT PRIMARY KEY,
    role_code TEXT UNIQUE,
    category TEXT
);
CREATE VIEW vw_mechanic_positions AS
SELECT 
    standard_id,
    position_title,
    council_type,
    unit,
    CASE 
        WHEN unit LIKE '%Vehicle%' THEN 'Vehicle Maintenance'
        WHEN unit LIKE '%Mechanical%' THEN 'Mechanical Services'
        ELSE 'General Maintenance'
    END as work_area,
    establishment_count,
    level
FROM eng_position_hierarchy
WHERE position_title = 'Mechanic'
ORDER BY council_type
/* vw_mechanic_positions(standard_id,position_title,council_type,unit,work_area,establishment_count,level) */;
CREATE VIEW vw_establishment_by_council AS
SELECT 
    council_type,
    COUNT(DISTINCT position_title) as unique_positions,
    SUM(establishment_count) as total_staff,
    AVG(establishment_count) as avg_per_position
FROM eng_position_hierarchy
GROUP BY council_type
ORDER BY council_type
/* vw_establishment_by_council(council_type,unique_positions,total_staff,avg_per_position) */;
CREATE VIEW vw_staff_by_level AS
SELECT 
    council_type,
    level,
    COUNT(DISTINCT position_title) as positions,
    SUM(establishment_count) as staff_count,
    ROUND(SUM(establishment_count) * 100.0 / SUM(SUM(establishment_count)) OVER (PARTITION BY council_type), 1) as percentage
FROM eng_position_hierarchy
GROUP BY council_type, level
ORDER BY council_type, level
/* vw_staff_by_level(council_type,level,positions,staff_count,percentage) */;
CREATE VIEW vw_council_comparison AS
SELECT 
    'Management (L1-3)' as staff_category,
    SUM(CASE WHEN council_type = 'City' AND level <= 3 THEN staff_count ELSE 0 END) as City,
    SUM(CASE WHEN council_type = 'Municipal' AND level <= 3 THEN staff_count ELSE 0 END) as Municipal,
    SUM(CASE WHEN council_type = 'Town' AND level <= 3 THEN staff_count ELSE 0 END) as Town
FROM vw_staff_by_level

UNION ALL

SELECT 
    'Supervisory (L4)',
    SUM(CASE WHEN council_type = 'City' AND level = 4 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Municipal' AND level = 4 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Town' AND level = 4 THEN staff_count ELSE 0 END)
FROM vw_staff_by_level

UNION ALL

SELECT 
    'Technical (L5)',
    SUM(CASE WHEN council_type = 'City' AND level = 5 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Municipal' AND level = 5 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Town' AND level = 5 THEN staff_count ELSE 0 END)
FROM vw_staff_by_level

UNION ALL

SELECT 
    'Skilled (L6)',
    SUM(CASE WHEN council_type = 'City' AND level = 6 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Municipal' AND level = 6 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Town' AND level = 6 THEN staff_count ELSE 0 END)
FROM vw_staff_by_level

UNION ALL

SELECT 
    'Entry/General (L7-8)',
    SUM(CASE WHEN council_type = 'City' AND level >= 7 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Municipal' AND level >= 7 THEN staff_count ELSE 0 END),
    SUM(CASE WHEN council_type = 'Town' AND level >= 7 THEN staff_count ELSE 0 END)
FROM vw_staff_by_level
/* vw_council_comparison(staff_category,City,Municipal,Town) */;
CREATE VIEW vw_org_chart_data AS
SELECT 
    council_type,
    level,
    CASE level
        WHEN 1 THEN 'Executive'
        WHEN 2 THEN 'Director'
        WHEN 3 THEN 'Assistant Director'
        WHEN 4 THEN 'Supervisory'
        WHEN 5 THEN 'Technical'
        WHEN 6 THEN 'Skilled Technical'
        WHEN 7 THEN 'Entry Level'
        WHEN 8 THEN 'General Staff'
    END as level_name,
    SUM(staff_count) as staff_count,
    ROUND(SUM(staff_count) * 100.0 / SUM(SUM(staff_count)) OVER (PARTITION BY council_type), 1) as percentage
FROM vw_staff_by_level
GROUP BY council_type, level
ORDER BY council_type, level
/* vw_org_chart_data(council_type,level,level_name,staff_count,percentage) */;
CREATE VIEW vw_org_dna AS
SELECT 
    council_type,
    ROUND(100.0 * SUM(CASE WHEN level <= 3 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_management,
    ROUND(100.0 * SUM(CASE WHEN level = 4 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_supervisory,
    ROUND(100.0 * SUM(CASE WHEN level = 5 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_technical,
    ROUND(100.0 * SUM(CASE WHEN level = 6 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_skilled,
    ROUND(100.0 * SUM(CASE WHEN level >= 7 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_entry
FROM vw_org_chart_data
GROUP BY council_type
/* vw_org_dna(council_type,pct_management,pct_supervisory,pct_technical,pct_skilled,pct_entry) */;
CREATE TABLE position_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE INDEX idx_supervision_position ON position_supervision(position_standard_id);
CREATE INDEX idx_supervision_supervisor ON position_supervision(immediate_supervisor_id);
CREATE INDEX idx_supervision_hod ON position_supervision(hod_id);
CREATE TABLE executive_positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    standard_id TEXT UNIQUE,
    council_type_id INTEGER,
    is_council_secretary BOOLEAN DEFAULT 0,
    is_head_of_department BOOLEAN DEFAULT 0,
    establishment INTEGER DEFAULT 1
);
CREATE INDEX idx_supervision_council ON position_supervision(council_type_id);
CREATE TABLE jd_upload_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE job_description_documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE jd_review_queue (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE UNIQUE INDEX idx_unique_current_jd 
ON job_description_documents (position_standard_id) WHERE is_current = 1;
CREATE TABLE hra_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_secretary_id TEXT,
    council_id INTEGER NOT NULL,
    department TEXT DEFAULT 'HRA',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE legal_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_secretary_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'LEG',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE health_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_secretary_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'HLT',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
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
CREATE TABLE community_sections (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE community_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_type_id INTEGER,
    head_position_id TEXT, is_special_unit BOOLEAN DEFAULT 0, specific_council_id INTEGER,
    FOREIGN KEY (section_id) REFERENCES community_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE community_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE VIEW vw_city_community_standard AS
SELECT 
    p.title,
    p.salary_scale,
    p.establishment,
    u.unit_name,
    s.section_name,
    p.standard_id
FROM community_positions p
JOIN community_units u ON p.unit_id = u.unit_id
JOIN community_sections s ON p.section_id = s.section_id
WHERE p.council_type_id = 3
    AND (p.is_special_unit = 0 OR p.is_special_unit IS NULL)
/* vw_city_community_standard(title,salary_scale,establishment,unit_name,section_name,standard_id) */;
CREATE VIEW vw_kitwe_community_complete AS
SELECT 
    p.title,
    p.salary_scale,
    p.establishment,
    u.unit_name,
    s.section_name,
    p.standard_id,
    CASE WHEN p.is_special_unit = 1 THEN p.special_unit_name ELSE NULL END AS special_unit
FROM community_positions p
JOIN community_units u ON p.unit_id = u.unit_id
JOIN community_sections s ON p.section_id = s.section_id
WHERE p.council_type_id = 3
/* vw_kitwe_community_complete(title,salary_scale,establishment,unit_name,section_name,standard_id,special_unit) */;
CREATE VIEW vw_council_community_services AS
SELECT 
    c.council_name,
    p.title,
    p.salary_scale,
    p.establishment,
    u.unit_name,
    s.section_name,
    CASE 
        WHEN p.is_special_unit = 1 AND p.specific_council_id = c.council_id THEN 'Special Unit'
        ELSE 'Standard'
    END AS unit_type
FROM councils c
CROSS JOIN community_positions p
JOIN community_units u ON p.unit_id = u.unit_id
JOIN community_sections s ON p.section_id = s.section_id
WHERE p.council_type_id = 3
    AND (p.is_special_unit = 0 OR (p.is_special_unit = 1 AND p.specific_council_id = c.council_id))
ORDER BY c.council_name, s.section_name, u.unit_name, p.title
/* vw_council_community_services(council_name,title,salary_scale,establishment,unit_name,section_name,unit_type) */;
CREATE TABLE procurement_sections (
    section_id INTEGER PRIMARY KEY AUTOINCREMENT,
    section_name TEXT NOT NULL,
    section_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT,
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE procurement_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    section_id INTEGER,
    council_type_id INTEGER,
    head_position_id TEXT,
    FOREIGN KEY (section_id) REFERENCES procurement_sections(section_id),
    FOREIGN KEY (council_type_id) REFERENCES council_types(council_type_id)
);
CREATE TABLE procurement_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE procurement_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE audit_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE audit_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
CREATE TABLE audit_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'AUD',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE cos_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
CREATE TABLE cos_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE cos_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'COS',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE toc_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
CREATE TABLE toc_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE toc_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'TOC',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE toc_city_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER,
    head_position_id TEXT
);
CREATE TABLE toc_city_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE TABLE toc_city_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'TOC',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE ict_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 2,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
CREATE TABLE ict_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
CREATE TABLE ict_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'ICT',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE ict_city_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 3,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
CREATE TABLE ict_city_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
CREATE TABLE ict_city_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'ICT',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE commercial_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 2,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
CREATE TABLE commercial_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
CREATE TABLE commercial_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE commercial_city_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    unit_id INTEGER,
    council_type_id INTEGER DEFAULT 3,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
CREATE TABLE commercial_city_units (
    unit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    unit_name TEXT NOT NULL,
    unit_code TEXT UNIQUE,
    council_type_id INTEGER
);
CREATE TABLE commercial_city_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'COM',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE valuation_city_positions (
    position_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    salary_scale TEXT,
    establishment INTEGER DEFAULT 1,
    reports_to TEXT,
    stream TEXT,
    council_type_id INTEGER DEFAULT 3,
    is_head_of_unit BOOLEAN DEFAULT 0,
    standard_id TEXT UNIQUE
);
CREATE TABLE valuation_city_supervision (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_standard_id TEXT NOT NULL UNIQUE,
    immediate_supervisor_id TEXT,
    hod_id TEXT,
    head_of_institution_id TEXT,
    council_type_id INTEGER NOT NULL,
    department TEXT DEFAULT 'VAL',
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE immutable_audit_log (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
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
CREATE INDEX idx_audit_council_period ON immutable_audit_log(council_id, period_date);
CREATE INDEX idx_audit_council_event ON immutable_audit_log(council_id, event_type);
CREATE INDEX idx_audit_council_approver ON immutable_audit_log(council_id, approved_by);
CREATE INDEX idx_audit_period ON immutable_audit_log(period_date);
