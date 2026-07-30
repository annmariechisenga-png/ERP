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
INSERT INTO employees VALUES('Lusaka','Chilanga','Francis Ndola','331541/61/1','M','18.01.1980','Council Secretary','LGSS/03','31707','08.04.2010','02.07.2020','02.07.2020','27.03.2025','G12 Certificate, BSc. Accountancy, MBA','','Office of the Council Secretary','','98','7',20,45,'',40,'02/02/2026',NULL,'CHL-2010-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Luyando Christopher Sikazwa','270856/71/1','M','21.03.1996','Public Relaltions Officer','LGSS/08','31708','27.03.2024','11.03.2025','27.03.2024','06.05.2024','G12 Certificate, BA Education','','Public Relations','','60','6',5,'','',6,'02/02/2026',NULL,'CHL-2024-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Thelma Veronica Chembe','914569/11/1','F','07.04.1987','Assistant Public Relations Officer','LGSS/10','31709','18.07.2017','15.08.2017','15.08.2017','24.03.2025','G12 Certificate, Diploma in Journalism ','','Public Relations','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2017-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Twambo Mobela','203892/77/1','F','23.09.1995','Personal Secretary','LGSS/10','31710','10.09.2018','24.06.2020','01.11.2024','03.12.2024','G12 Certificate, Advanced Certificate in Secretarial and Office Management','','Office of the Council Secretary','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2018-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Muzala C. Kapihya','708796/11/1','F','06.10.1978','Systems Analyst','LGSS/08','31712','03.02.2025','On Probation','03.02.2025','03.02.2025','G12 Certificate, Diploma in Computing & IT, BSc E- Business Computing, MSc Databases and Web-Based Systems, Level 3 Certificate','','Office of the Council Secretary','','IT','6','','','',6,'02/02/2026',NULL,'CHL-2025-000001',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Nomsa Simoonga','152137/78/1','F','16.11.1994','Programmer ','LGSS/10','21054','04.05.2024','','04.05.2024','14.11.2025','G12 Certificate, Diploma in computer studies  ','','Office of the Council Secretary','','IT','6','','','',6,'02/02/2026',NULL,'CHL-2024-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Annette Mubanga Chilando','934714/11/1','F','19.08.1985','Director Human Resource & Administration','LGSS/05','31713','10.02.2010','Not yet Confirmed','22.12.2022','03.01.2023','G12 Certificate, Diploma -Human Resource Management, BA. Human Resource Management','','HRA','','Human Resources','7','','','',7,'02/02/2026',NULL,'CHL-2010-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chisenga Chisenga','804918/11/1','M','16.04.1981','Chief Human Resource Officer','LGSS/05','31831','06.08.2008','01.03.2009','01.09.2018','12.11.2025','G12 Certificate, BA Development Studies with Public Administration, MSc. Strategic Management. MZIHRM','','HRA','260955522188','','7','','','',7,'02/02/2026',NULL,'CHL-2008-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mujinga Mbumba','326816/10/1','F','20.03.1996','Senior Human Resource Officer','LGSS/07','','05.01.2023','20.03.2023','01.11.2024','19.12.2024','G12 Certificate, Diploma in Business Management, BBA','','HRA','','Human Resources','7','','','',7,'02/02/2026',NULL,'CHL-2023-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chimuka Mizinga','721207/11/1','F','26.08.1981','Human Resource Officer','LGSS/08','31717','27.08.2001','27.08.2002','25.09.2023','20.01.2020','G12 Certificate, Diploma in Journlism and Public Relations, BA Public Administration  ','','HRA','','Human Resources','6','','','',6,'02/02/2026',NULL,'CHL-2001-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mbita Kasitu','131629/10/1','F','23.04.1989','Human Resource Officer','LGSS/08','31718','17.03.2025','On Probation','18.12.2024','17.03.2025','G12 Certificate, Diploma in Information Systems and Programming, BBA','','HRA','','Human Resources','6','','','',6,'02/02/2026',NULL,'CHL-2025-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Rachael Choongo','240862/71/1','F','01.07.1985','Chief Administrative and Committee Officer','LGSS/06','80287','05.10.2017','27.03.2019','23.08.2023','06.11.2025','G12 Certificate, BA International Relations','','HRA','','Administration','7','','','',7,'02/02/2026',NULL,'CHL-2017-000002',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Oreen Hara','358869/67/1','F','17.01.1979','Administrative Officer','LGSS/10','31720','21.09.2009','08.08.2015','17.05.2017','08.09.2015','G12 Certificate, Certificate in Leading Fire Fighter Course, Certificate in Fire Prevention, Certificate in Basic Fire, Diploma in Business Administration,  BBA, MBA - Project Management','','HRA','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2009-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Bupe Mulobe','323395/10/1','F','18.09.1993','Administrative Officer','LGSS/10','31638','14.07.2019','','#VALUE!','06.11.2025','G12 Certificate, Diploma in Public Administration','','HRA','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2019-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Fiance Chope','267778/68/1','F','15.04.1986','Stenographer','LGSS/12','31721','27.11.2013','08.01.2015','10.01.2020','28.08.2024','G12 Certificate, Advance Certificate in Secretarial and Office Management,Certificate in Secretarial and Office Management','','HRA','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2013-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mireille Kwizera','448417/16/1','F','05.05.1997','Stenographer','LGSS/12','31722','03.03.2020','16.11.2020','03.03.2020','22.11.2024','G12 Certificate, Certificate of Competence in Monitoring Evaluation, project and planning management, community development,   Advanced Certificate in Secretarial and office management, Diploma in Secretarial and Office Management, BA Public Administration ','','HRA','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2020-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Misozi Longwe','261194/73/1','F','24.12.1988','Typist','LGSS/14','31723','30.09.2011','06.10.2011','08.01.2015','24.03.2025','G12 Certificate, Certificate in Secretarial and Office management, Diploma in Law','','HRA','','Administration','5','','','',5,'02/02/2026',NULL,'CHL-2011-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mercy Bwalya','327728/73/1','F','23.07.1993','Typist','LGSS/14','81215','26.06.2017','27.12.2017','26.06.2017','11.11.2025','G12 Certificate, Certificate in Secretarial &Office Management, Diploma in Public Admin','','HRA','','Administration','5','','','',5,'02/02/2026',NULL,'CHL-2017-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Jane Banda','171855/10/1','F','29.09.1989','Committee Clerk','LGSS/10','31724','05.10.2017','23.06.2018','05.10.2017','24.06.2021','G12 Certificate, Diploma in Public Administration','','HRA','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2017-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mathews Chanda','202609/44/1','M','26.07.1984','Assistant Committee Clerk','LGSS/12','31725','07.12.2018','19.11.2019','10.05.2021','02.01.2019','G12 Certificate, Certificate in prosecutions,  Diploma in Public Administration','','HRA','','','6','','','',6,'02/02/2026',NULL,'CHL-2018-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Lutunti Mwanamwalye','188439/10/1','F','18.07.1992','Assistant Committee Clerk','LGSS/12','31726','10.06.2021','','10.06.2021','','G12 Certificate, Certifcate in Basic Computing, M&E, Project Planning & Management, Business & marketing, BA Adult Education and Extension Studies','','HRA','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2021-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Everret Kapya','174632/35/1','F','03.01.1991','Registry Supervisor','LGSS/14','31727','16.12.2013','11.12.2015','31.05.2021','09.06.2021','Diploma in Local GovernmentAdministration, Certificate of Attendance in Registry Management and Grade 12 Certificate','','HRA','','Administration','5','','','',5,'02/02/2026',NULL,'CHL-2013-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Ufrix Katongo','177808/12/1','M','25.10.1974','Registry Clerk','LGSS/17','31728','01.04.1999','23.09.1999','16.09.2020','10.06.2021','Certificate of attendance in Records Management and Grade 12 Certificate','','HRA','','','5','','','',5,'02/02/2026',NULL,'CHL-1999-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Dina Phiri','206957/75/1','F','26.09.1978','Clerical Officer','LGSS/18','31730','15.08.2018','09.03.2023','15.08.2018','12.02.2020','Certificate in Secretarial and Office Management, Certificate in Information Technology and Computer Applications, Certificate in Psycosocial Counselling and Grade 12 Certificate','','HRA','','Administration','5','','','',5,'02/02/2026',NULL,'CHL-2018-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Joyce Chansa','580045/11/1','F','25.03.1972','Clerical Officer','LGSS/18','31731','03.05.1993','08.07.1998','29.01.2020','13.01.2020','Dipolma in Rural and Urban Management and G12 Certificate','','HRA','','Administration','5','','','',5,'02/02/2026',NULL,'CHL-1993-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Annie Bwalya','641670/11/1','F','10.04.1974','Town Sergent','LGSS/12','31733','24.12.1996','06.01.1997','12.08.2018','07.07.2023','G12 certificate, Certificate in Basic Security ','','HRA','','Security','6','','','',6,'02/02/2026',NULL,'CHL-1996-000001',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Ericko Simposya','214178/47/1','M','14.07.1979','Inspector','LGSS/14','31734','06.12.2018','18.09.2012','06.12.2018','10.05.2021','GCE, Certificate in Basic Security','','HRA','','','5','','','',5,'02/02/2026',NULL,'CHL-2018-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Frazer Nalumpa','541289/11/1','M','25.09.1970','Sub- Inspector','LGSS/16','31735','31.03.2000','21.05.2001','13.08.2012','05.02.2018','GCE, Certificate in Basic Security ','','HRA','','','5','','','',5,'02/02/2026',NULL,'CHL-2000-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Moses Izukanji Phiri','637023/52/1','M','24.11.1994','Sub- Inspector','LGSS/16','31736','17.05.2017','10.01.2018','13.10.2020','02.11.2020','G12 Certificate, Certificate in forensic and criminal investigation phychology ','','HRA','','','5','','','',5,'02/02/2026',NULL,'CHL-2017-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Eunice Mapala','209300/17/1','M','27.11.1979','Director Finance','LGSS/05','31737','01.11.1995','02.10.1996','01.11.1995','19.10.2023','G12 Certificate, Diploma - Accounting & Finance in Business Management, Diploma in purchasing & Resourcing Management & Supply, BA Accounting, BBA ','','Finance','','','7','','','',7,'02/02/2026',NULL,'CHL-1995-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','James Gondwe','723631/11/1','M','24.10.1979','Accountant','LGSS/08','31739','01.06.2000','13.12.2000','20.05.2019','10.06.2019','G12 Certificate, Zica Technician, Diploma in Accountacy, BA Accountancy','','Finance','','','6','','','',6,'02/02/2026',NULL,'CHL-2000-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chileshe Kapambwe','154555/10/1','F','07.12.1990','Assistant Accountant','LGSS/10','31740','30.05.2013','15.10.2018','30.05.2024','04.12.2024','G12 certificate, Diploma in Accounting Technichain, BA Business Administration and Enterprenuership','','Finance','','Finance','6','','','',6,'02/02/2026',NULL,'CHL-2013-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Saviour Kaluba Kangwa','320938/67/1','M','29.12.1973','Assistant Accountant','LGSS/10','31741','02.01.1998','24.03.2000','02.10.2015','16.09.2019','G12 Certificate, Certificate in Operating System Software, Certificate in Accounts and Business Studies, ZICA Technician, Diploma in Accountancy, BA Business Accounting ','Chief Accountant (LGSS/06)10.11.2025','Finance','','','6','','','',6,'02/02/2026',NULL,'CHL-1998-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mirriam Chola','171438/18/1','F','07.09.1992','Assistant Commercial Manager','LGSS/07','70336','07.07.2017','11.12.2017','#VALUE!','18.11.2025','G12 Certificate, BA Banking and Finance, MBA ','Assistant commercial Manager LGSS/07 18.11.2025','Finance','','General','7','','','',7,'02/02/2026',NULL,'CHL-2017-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Christine Mulenga','187828/10/1','F','29.12.1991','Cashier','LGSS/13','31742','24.07.2017','11.12.2017','13.12.2018','06.12.2024','G12 Certificate, CA Application Advanced Diploma in Accountancy, BA Banking and Finance','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2017-000007',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Alice Katwamba','139804/36/1','F','24.12.1993','Accountancy Assistant','LGSS/13','31743','07.01.2020','06.08.2020','07.01.2020','22.01.2020','G12 certificate, ZICA Technician ','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2020-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Afaida Mwanza','201247/71/1','F','15.11.1981','Accountancy Assistant','LGSS/13','31744','11.02.2020','06.08.2020','11.02.2020','25.02.2020','G12 certifcate, CCA Certified Accounting Technician','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2020-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Fuli Caroline Mapulanga','258613/68/1','F','05.11.1983','Stores Officer','LGSS/08','31745','18.12.2024','On Probation','18.12.2024','19.03.2025','G12 Certificate, CIPS Level 6 Proffessional Diploma in Procurment and Supply','','Finance','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2024-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Michelo Guolyn Malambo','272011/43/1','F','31.03.1987','Assistant Stores Officer','LGSS/17','31746','20.12.2018','02.01.2020','27.01.2024','09.05.2022','G12 Certificate, Certificate in Purchasing & Supply, BA Development Studies','','Finance','','Administration','5','','','',5,'02/02/2026',NULL,'CHL-2018-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Angela Muleya','296788/73/1','F','15.11.1989','Assistant Stores Officer','LGSS/10','31747','18.12.2024','On Probation','18.12.2024','24.03.2025','G12 certificate, ZIPS Certificate in Procurment committee papers and mintues writing, Diploma in purchasing and supply','','Finance','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2024-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Gladys Mulowa','542738/52/1','F','15/12/1986','Revenue Collector','LGSS/18','31748','04.09.2015','17.05.2017','04.09.2015','01.04.2023','G12 Certificate','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2015-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mirriam Mulenga','159851/18/1','F','03.11.1988','Revenue Collector','LGSS/18','31749','22.10.2018','19.12.2019','22.10.2018','06.02.2020','G12 Certificate','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2018-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Simon Ngulube','747043/11/1','M','02.20.1981','Revenue Collector','LGSS/18','31750','29.09.2017','27.10.2018','29.09.2017','19.09.2017','G12 Certificate','','Finance','','','5','','','',5,'02/02/2026',NULL,'CHL-2017-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Trevor Kabale','216302/71/1','M','10.11.1981','Revenue Collector','LGSS/18','31751','25.01.2007','19.11.2019','25.01.2007','18.06.2019','G12 Certificate, Certificate in Computer Applications','','Finance','','','5','','','',5,'02/02/2026',NULL,'CHL-2007-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Anastasia Nkolongo','570535/10/1','F','01.04.1999','Revenue Collector','LGSS/18','31752','09.10.2020','25.08.2021','09.10.2020','03.12.2020','G12 Certificate','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2020-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Precious Mulambo','603262/10/1','F','27.09.2001','Revenue Collector','LGSS/18','31753','04.01.2021','07.10.2022','#VALUE!','07.07.2023','G12 Certificate','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2021-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Patrick Phiri','698990/52/1','M','15.12.2000','Revenue Collector','LGSS/18','31754','22.07.2021','09.03.2023','22.07.2021','22.08.2021','G12 Certificate','','Finance','','','5','','','',5,'02/02/2026',NULL,'CHL-2021-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Millimo Mweemba','540317/10/1','F','18.05.1995','Revenue Collector','LGSS/18','31755','05.05.2023','05.05.2023','27.09.2023','19.05.2023','Trade Test Certificate Level 1,Grade 12 Certificate','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2023-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Ruth Twaambo Kwapu','578358/10/1','F','21.05.2001','Revenue Collector','LGSS/18','31756','15.05.2023','27.09.2023','15.05.2300','15.05.2023','G12 Certificate','','Finance','','Finance','5','','','',5,'02/02/2026',NULL,'CHL-2023-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chilufya Shanda Mukuka','167196/10/1','M','05.12.1993','Director of Engineering','LGSS/05','31757','02.05.2017','11.12.2017','01.11.2024','25.11.2024','G12 Certificate, BSc Civil Engineering','','Engineering','','Engineering','7','','','',7,'02/02/2026',NULL,'CHL-2017-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chalwe Luswili','355723/10/1','F','28.07.1996','Civil Engineer','LGSS/07','31759','27.03.2024','11.03.2025','27.03.2024','','G12 Certificate, BSc Civil & Environmental Engineering ','','Engineering','','Engineering','7','','','',7,'02/02/2026',NULL,'CHL-2024-000005',NULL,1,NULL,NULL,NULL,'ENG-ASSTDIR-001','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Gerald Chilufya','264183/63/1','M','07.07.1997','Assistant Civil Engineer','LGSS/10','31760','07.04.2021','19.03.2023','07.04.2021','14.06.2021','G12 Certificate, Diploma in Civil Engineering','','Engineering','','','6','','','',6,'02/02/2026',NULL,'CHL-2021-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Karen Mpundu','550156/10/1','F','22.06.1998','Assistant Civil Engineer','LGSS/10','31761','27.03.2024','17.04.2025','27.03.2024','02.05.2024','G12 Certificate, BSc Civil Engineering ','','Engineering','','Engineering','6','','','',6,'02/02/2026',NULL,'CHL-2024-000006',NULL,1,NULL,NULL,NULL,'CHL-2024-000005','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mathews Nyirenda','317092/51/1','M','31.07.1980','Roller Compactor Operator','LGSS/14','31762','06.12.2024','31.03.2025','06.12.2024','06.12.2024','G12 Certificate, Certificate in Motor Grader Operator, Certificate in Project Planning and Management, Certificate in Motor Vehicle Systems, Driving Lincese Class C ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2024-000007',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Alex Zulu','577017/52/1','M','16.08.1992','Grader Operator','LGSS/14','31763','31.05.2024','17.01.2024','31.05.2024','29.07.2024','G12 Certificate, Certificate in Roads Coustruction and Roads Maintence Supervision, Certificate of Compente in Grader, Certificate in Basic Mechnics ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2024-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Joseph Tembo','306096/53/1','M','12.12.1982','Grader Operator','LGSS/14','31764','31.05.2024','17.01.2025','31.05.2024','31.07.2024','G12 Certificate, Certificate of Competence in Grader Operations, Certificate of Competence in Excavator Operations, International Certificate in Logistics and Transport, Certificate in information Technology and Certificate in attendance in Fire Marshall','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2024-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Billiot Hambizi','207883/76/1','M','15.08.1978','Quantity Surveyor','LGSS/07','31765','27.03.2024','18.04.2025','27.03.2024','18.04.2024','G12 Certificate, BSc Building Science','','Engineering','','','7','','','',7,'02/02/2026',NULL,'CHL-2024-000010',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Precious Shimulopwe','439014/53/1','M','04.04.1985','Water and Sanitation Engineer','LGSS/07','31766','15.01.2020','06.08.2020','15.01.2020','30.01.2020','G12 Certificate, Diploma in Water Engineering ','','Engineering','','','7','','','',7,'02/02/2026',NULL,'CHL-2020-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Lomthuzi Khosa Thandile','365010/65/1','F','17.10.1994','Architect','LGSS/07','31767','04.02.2025','On Probation','04.02.2025','04.02.2025','G12 Certificate, BSc Architecture ','','Engineering','','Engineering','7','','','',7,'02/02/2026',NULL,'CHL-2025-000003',NULL,1,NULL,NULL,NULL,'ENG-ASSTDIR-001','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mubiana Minyoi','103220/78/1','M','17.05.1982','Draughtsman','LGSS/15','31768','17.05.2008','31.03.2010','17.05.2008','03.09.2024','G12 Certificate, Diploma in Building Science ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2008-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Franchesca Mumbi','408722/10/1','F','23.06.1997','Electrical Engineer','LGSS/07','31769','06.02.2025','On Probation','06.02.2025','06.02.2025','G12 Certificate, BSc Electrical Engineering, MSc Electrical Engineering ','','Engineering','','Engineering','7','','','',7,'02/02/2026',NULL,'CHL-2025-000004',NULL,1,NULL,NULL,NULL,'ENG-ASSTDIR-001','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Leon Mainga Kufekisa','286578/71/1','M','29.03.2000','Assistant Electrical Engineer','LGSS/10','31770','06.02.2025','On Probation','06.02.2025','06.02.2025','G12 Certificate, Diploma in Electrical Engineering ','','Engineering','','','6','','','',6,'02/02/2026',NULL,'CHL-2025-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Max Mulilo','121386/11/1','M','27.10.1989','Mechanic','LGSS/14','31771','08.07.2019','08.01.2020','08.07.2019','31.07.2019','G12 Certificate, Craft Certificate in Automotive Mechanics ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2019-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Charles Sichamba','154541/10/1','M','18.02.1990','Electrician','LGSS/14','31773','06.12.2018','18.11.2019','06.12.2018','06.12.2018','G12 Certificate, Craft Certificate in Electrical Engineering  ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2018-000007',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Branco Chiyoma','125553/78/1','M','19.08.1986','Foreman','LGSS/14','','19.09.2017','5.112017','19.09.2017','02.02.2022','G12 Certificate, B.Tech Road Constraction & Maintenance Management','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2017-000010',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Patson Kunda','197120/10/1','M','11.05.1989','Engineering Assistant','LGSS/14','','08.01.2020','06.08.2020','08.01.2020','20.01.2020','G12 Certificate, Certificate in Building Work Supervision ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2020-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Paul Musole','177931/72/1','M','02.12.1987','Engineering Assistant','LGSS/14','','06.12.2018','','25.09.2300','06.10.2023','G12 Certificate, Trade Test Certificate Level 1, Trade certificate Level 1  Certificate in Management of Civil Engineering Conctruction Processes ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2018-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Kelvin Bupe','175767/18/1','M','15.05.1991','Assistant Foreman','LGSS/17','31774','06.12.2018','25.08.2021','06.12.2018','29.10.2020','G12 Certificate, Certificate Electrical Domestic Power ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2018-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Rodgers Muliokela','209983/83/1','M','23.03.1977','Divisional Fire Officer','LGSS/08','31775','12.04.2000','01.10.2002','06.01.2020','13.01.2020','G12 Certificate, Certificates in Basic Firemanship, Leading Fire Fighting, Fire Services and Traffic Accident, Station Officer, Fire Service and Fire Prevention, Fire Investiagtion, Hazardous Materials Course ','','Engineering','','','6','','','',6,'02/02/2026',NULL,'CHL-2000-000003',NULL,1,NULL,NULL,NULL,'ENG-ASSTDIR-001','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Lawrence Chishimba','289737/16/1','M','29.04.1983','Station Officer','LGSS/11','31776','27.09.2013','05.11.2014','26.06.2024','22.06.2017','Certififcate in Problem Solving and Decision making,Certificate in Fire Prevention Course,Sub- Officer Certificate, Certificate in Leading Fire Fighter Course, Certificate in Fire Prevention Course, Certificate in Basic Fire Fighters and Grade 12 Certificate','','Engineering','','','6','','','',6,'02/02/2026',NULL,'CHL-2013-000004',NULL,1,NULL,NULL,NULL,'CHL-2000-000003','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Shadreck Chulu','120732/57/1','M','07.02.1992','Sub-Officer','LGSS/12','31777','27.08.2013','15.10.2015','15.12.2020','25.02.2019','G12 Certificate, Diploma in Environmenatal Healthy and Safety Management ,Certififcates in Monitoring and Evaluation Fundamentals, Fire Prevention Course Certificate in CPR and First Aid, Sub-Officer, Leading Fire Fighter Course, Basic Fire Course, Advanced Certififcate in Occupational Health and Safety ','','Engineering','','','6','','','',6,'02/02/2026',NULL,'CHL-2013-000005',NULL,1,NULL,NULL,NULL,'CHL-2013-000004','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chola Musonda','135721/35/1','M','24.10.1977','Sub-Officer','LGSS/12','31778','29.10.2013','29.10.2013','14.02.2020','29.09.2022','G12 Certificate, Certificates in Defensive Driving Course, Communication Skills, Sub-Officer, Leading Fire Fighter, Fire Prevention, Fire Investigation, Basic Fire Fighters Course ','','Engineering','','','6','','','',6,'02/02/2026',NULL,'CHL-2013-000006',NULL,1,NULL,NULL,NULL,'CHL-2013-000004','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Derrick Chila','194937/44/1','M','05.11.1977','Leading Firefighter','LGSS/13','31779','27.09.2013','07.05.2015','15.12.2020','14.07.2017','G12 Certificate, Certifcates in Fire Prevention Course, Leading Fire Fighting, Basic Fire Fighters ','','Engineering','','Engineering','5','','','',5,'02/02/2026',NULL,'CHL-2013-000007',NULL,1,NULL,NULL,NULL,'CHL-2013-000005','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Dominic Kamanga','237439/32/1','M','25.02.1981','Leading Firefighter','LGSS/13','31780','30.05.2013','09.01.2015','19.05.2020','27.07.2020','G12 Certificate, Certificates in Station Officer, Leading Fire Fighter, Basic Fire Fighters ','','Engineering','','Engineering','5','','','',5,'02/02/2026',NULL,'CHL-2013-000008',NULL,1,NULL,NULL,NULL,'CHL-2013-000006','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Nsofwa Kalonde','118301/91/1','F','16.12.1987','Firefighter','LGSS/14','31781','10.01.2018','31.07.2019','#VALUE!','07.12.2018','G12 Certificate, Certificate in Leading Fire Fighter Course,Certificate in enterprenuership Skills ','','Engineering','','Engineering','5','','','',5,'02/02/2026',NULL,'CHL-2018-000010',NULL,1,NULL,NULL,NULL,'CHL-2013-000007','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Daina Mwilu','769164/11/1','F','03.06.1981','Firefighter','LGSS/14','31782','15.09.2020','19.07.2021','15.09.2020','27.06.2023','G12 Certificate, Certificate in Basic Fire Fighter Course','','Engineering','','Engineering','5','','','',5,'02/02/2026',NULL,'CHL-2020-000007',NULL,1,NULL,NULL,NULL,'CHL-2013-000008','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Soft Zimba','669599/11/1','M','03.01.1977','Firefighter','LGSS/14','31783','02.05.2017','02.09.2019','02.05.2017','05.06.2017','G12 Certificate, Certificate in fire service Course,Fire Prevention Course. Fighting Certificate, Certificate in Prevention Course, Certificate in Basic fire Fighting','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2017-000011',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chester Muchindu','118470/10/1','M','10.06.1987','Firefighter','LGSS/14','31784','07.12.2018','02.09.2019','07.12.2018','07.12.2018','G12 Certificate, Certificate in Fire Service Course, Certificate in Basic Fire Fighter Course ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2018-000011',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Peter Kasapato','215942/18/1','M','02.02.1997','Firefighter','LGSS/14','31785','04.01.2021','25.08.2021','04.01.2021','02.02.2021','G12 Certificate, Certificate in Basic Fire Fighting Course','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2021-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Gift Chipunga','238187/15/1','M','01.08.1991','Firefighter','LGSS/14','31786','05.09.2017','20.09.2018','05.09.2017','12.04.2021','G12 Certificate, Certificate in Basic Fire Fighter Course, Basic Marine and Rescue Course, Certififcate in Leading Fire Fighter Course ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2017-000012',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Kelly Kasonde','478762/67/1','M','06.06.1992','Firefighter','LGSS/14','31787','19.07.2021','09.03.2023','19.07.2021','04.08.2021','G12 Certificate, Certificate in Fire Service Course, Basic Fire Fighter Course ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2021-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Oliver Chuumba','157986/10/1','M','28.03.1989','Firefighter','LGSS/14','31788','25.07.2024','17.01.2025','25.07.2024','04.09.2024','G12 Certificate, Certificate in Fire fighters Recruit Course ','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2024-000011',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Humphrey Sinkala','102967/95/1','M','25.09.1983','Firefighter Driver','LGSS/14','','16.05.2019','20.01.2020','03.10.2025','06.11.2025','Certificate in leading Fire Fighter Course,','','Engineering','','','5','','','',5,'02/02/2026',NULL,'CHL-2019-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Namukolo Mulele','215038/65/1','F','05.12.1986','Director Planning','LGSS/05','235','31.10.2013','22.06.2015','02.05.2017','','G12 Certificate, BSc. Urban and Regional Planning, MSc. Urban Management and Development','','Planning','','Planning','7','','','',7,'02/02/2026',NULL,'CHL-2013-000009',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Yvette Chella','447527/67/1','F','31.07.1991','Assistant Land Surveyor','LGSS/10','80149','16.02.2018','11.12.2018','01.11.2024','01.11.2024','','Land Surveyor. 01.11.2024','Planning','','Planning','6','','','',6,'02/02/2026',NULL,'CHL-2018-000012',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Ronah Muponda','177560/10/1','F','06.08.1991','Social Economic Planner','LGSS/07','31792','02.05.2017','04.07.2018','02.05.2017','23.05.2017','G12 Certificate, BA with Development Studies, MA Development Studies  ','','Planning','','Planning','7','','','',7,'02/02/2026',NULL,'CHL-2017-000013',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Makumba Mwanza','416828/61/1','F','22.01.1991','Town Planner','LGSS/07','31793','02.05.2017','12.06.2018','02.05.2017','27.09.2022','G12 Certificate, BA Science in Urban and Regional Planning ','','Planning','','Planning','7','','','',7,'02/02/2026',NULL,'CHL-2017-000014',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Margaret Mando Mwewa','183586/65/1','F','13.08.1981','Assistant Town Planner','LGSS/10','31794','31.10.2013','08.07.2014','31.08.2016','17.09.2019','G12 Certificate, Certificate in Computer Information System, Diploma in Rural and Ubran Management, BA Development Studies','','Planning','','Planning','6','','','',6,'02/02/2026',NULL,'CHL-2013-000010',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Jenard Sakala','447474/67/1','M','05.02.1993','Assistant Town Planner','LGSS/10','20754','05.10.2017','23.06.2018','05.10.2017','25.11.2024','G12 Certificate, Diploma in Urban and Regional Planning ','','Planning','','','6','','','',6,'02/02/2026',NULL,'CHL-2017-000015',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','David Chibungo','275145/67/1','M','21.08.1966','Chief Building Inspector','LGSS/06','31797','01.10.1994','11.07.1995','20.07.2002','02.05.2023','G12 Certificate, Advanced Certificate in Fabrication Technician ','','Planning','','','7','','','',7,'02/02/2026',NULL,'CHL-1994-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Tamara Namonje','538813/52/1','F','15.07.1988','Building Inspector','LGSS/07','31798','24.07.2017','05.11.2018','24.07.2017','09.08.2017','G12 Certificate, Certificate in Intellectual Property, Certificate in Diplomatic Practise Protocal and Public Relations, MSc. Construction Management, ','','Planning','','Planning','7','','','',7,'02/02/2026',NULL,'CHL-2017-000016',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Anold Chilufya','239136/31/1','M','21.05.1985','Assistant Building Inspector','LGSS/10','31799','07.04.2021','09.03.2023','07.04.2021','13.05.2021','G12 Certificate, Technical Teachers Diploma, Diploma in Construction ','','Planning','','','6','','','',6,'02/02/2026',NULL,'CHL-2021-000007',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Lulu Mwansa','300153/10/1','F','28.03.1994','Valuation Officer','LGSS/07','31801','04.01.2021','29.06.2022','09.03.2023','10.05.2023','G12 Certificate, BSc Real Estates  ','','Planning','','Administration','7','','','',7,'02/02/2026',NULL,'CHL-2021-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Memory Muselekwa','412250/61/1','F','26.09.1991','Data Entry Clerk','LGSS/13','31802','03.06.2021','20.05.2021','20.05.2021','03.06.2021','Grade 12 Certificate, Foundation Diploma in the Management of Information Systems, BA Development Studies','','Planning','','Planning','5','','','',5,'02/02/2026',NULL,'CHL-2021-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mulawo Nkomesha','119206/86/1','M','01.06.1989','Senior Health Inspection Officer','LGSS/07','31803','17.10.2013','02.09.2015','17.10.2013','23.01.2023','G12 Certificate, Diploma Environmental Health Sciences, BSc Environmental Health  ','Assistant Director-Public Health. 13.02.2025','Health Services','','','7','','','',7,'02/02/2026',NULL,'CHL-2013-000011',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Adora Misozi Mbozi','979238/11/1','F','11.09.1986','District HIV/AIDS Coordination Advisor','LGSS/07','31804','14.06.2018','25.07.2018','27.04.2022','10.05.2022','G12 Certificate, Certificate in Pyschosocial Counselling, Certificate in HIV/AIDS, BA Social Work in Community Development','','Health Services','','Health','7','','','',7,'02/02/2026',NULL,'CHL-2018-000013',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Micheal Manza Nzovu','263091/15/1','M','27.07.1996','Health Inspector','LGSS/08','31605','15.10.2020','20.07.2021','15.10.2020','02.12.2024','G12 Certificate, BSc Environmental Health ','','Health Services','','','6','','','',6,'02/02/2026',NULL,'CHL-2020-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Edith Tumba Noah','325383/88/1','F','04.12.1997','Health Education Officer','LGSS/08','31806','27.03.2024','06.08.2024','27.03.2024','22.11.2024','G12 Certificate, Diploma in Public Heaith Nursing, BSc (Public Health Nursing)','','Health Services','','Administration','6','','','',6,'02/02/2026',NULL,'CHL-2024-000012',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Milambo Munsanje','367004/73/1','M','24.02.1998','Assistant Cleaning Superintendent','LGSS/09','31807','27.03.2024','28.02.2025','27.03.2024','24.04.2024','G12 Certificate, Diploma in Environmental Health Technologist ','','Health Services','','','6','','','',6,'02/02/2026',NULL,'CHL-2024-000013',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Able Matanda','187872/91/1','M','18.06.1995','Environmental Health Technologist','LGSS/09','31808','07.04.2021','09.03.2023','07.04.2021','10.06.2021','G12 Certificate, Diploma in Environmental Health','','Health Services','','','6','','','',6,'02/02/2026',NULL,'CHL-2021-000010',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Belinda Pellser','330470/82/1','F','12.03.1993','Community Development Officer','LGSS/07','31809','07.04.2021','25.09.2023','25.09.2023','06.06.2022','G12 Certificate, BA Adult Education, MA Communication & Development,  ','','Community Service','','Administration','7','','','',7,'02/02/2026',NULL,'CHL-2021-000011',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','David Kasonde','439430/61/1','M','31.07.1993','Community Development Officer','LGSS/07','31810','15.01.2020','06.08.2020','15.01.2020','28.02.2020','G12 Certificate, BA Economics (Honors) ','','Community Service','','','7','','','',7,'02/02/2026',NULL,'CHL-2020-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Joe Sabi','222549/46/1','M','06.08.1992','Council Advocate','LGSS/05','40460','16.01.2014','','#VALUE!','01.12.2025','G12 Certificate, Certificate, Diploma and LLB, Advocate of the High Court and Supreme Court and Commissioner of Oaths','','Legal Services','','','7','','','',7,'02/02/2026',NULL,'CHL-2014-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Martha Kabukute','148387/10/1','F','20.01.1989','Senior Legal Assistant','LGSS/07','31811','19.05.2008','','17.07.2017','17.10.2022','G12 Certificate, LLB ','','Legal Services','','Legal','7','','','',7,'02/02/2026',NULL,'CHL-2008-000003',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Musa Litia','237714/71/1','M','27.08.1987','Legal Assistant','LGSS/10','31812','09.11.2022','29.09.2023','25.09.2023','06.08.2024','G12 Certificate, Diploma in Human Resources, LLB','Senior Legal Assistant (LGSS/07). 26.06.2024','Legal Services','','','6','','','',6,'02/02/2026',NULL,'CHL-2022-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Erica Chenga','413002/61/1','F','15.10.1990','Senior Procurement and Supplies Officer','LGSS/07','81179','20.09.2018','16.06.2020','20.09.2018','12.11.2025','G12 Certificate,  Executive Diploma in Procurement and Contract Management, BA. Procurement, Logistics and Supply Chain Management,','','Procurement and Supplies','','Administration','7','','','',7,'02/02/2026',NULL,'CHL-2018-000014',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Namukoko Bwalya','258871/63/1','F','09.09.1993','Clerical Officer','LGSS/18','983','15.10.2017','26.05.2018','15.10.2017','24.11.2025','G12 Certificate, Certificate in Leadership and Organisation, Diploma in Purchase Procurement Management','Assistant Procurement and Supplies Officer (LGSS/10)  12.11.2025','Procurement and Supplies','','Administration','5','','','',5,'02/02/2026',NULL,'CHL-2017-000017',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Choolwe Sichibwa','107175/10/1','M','15.03.1988','Assistant Procurement and Supplies Officer','LGSS/10','31816','01.09.2014','06.07.2018','26.04.2023','27.05.2024','G12 Certificate, Craft Certificate in Electrical Engineering, Advanced Certificate in International Procurement and Supply, CIPS Level 4 Diploma in Procurment and Supply','','Procurement and Supplies','','','6','','','',6,'02/02/2026',NULL,'CHL-2014-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Judith Besa','156864/65/1','F','02.11.1971','Internal Auditor','LGSS/07','31817','11.04.1994','16.07.2007','01.11.2024','21/11/2024','G12 Certificate, Accounting Technician, CABS, BA Accounting and Finance, ','','Internal Audit','','Finance','7','','','',7,'02/02/2026',NULL,'CHL-1994-000002',NULL,1,NULL,NULL,NULL,'CHL-2010-000002','Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','WillIe Kabamba','292955/66/1','M','28.05.1991','Internal Auditor','LGSS/08','31818','26.06.2018','28.02.2019','26.06.2018','26.05.2020','G12 Certificate, Advanced Diploma in Accounting and Business ','','Internal Audit','','','6','','','',6,'02/02/2026',NULL,'CHL-2018-000015',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Higgins Siagwinta','266468/71/1','M','05.03.1993','Assistant Internal Auditor','LGSS/10','31819','11.12.2018','02.09.2019','11.12.2018','21.01.2019','G12 Certificate, Introductory Certificate in Financial, ACCA Diploma in Accounting and Business, ','','Internal Audit','','','6','','','',6,'02/02/2026',NULL,'CHL-2018-000016',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Stella Mwansa','718759/11/1','F','19.05.1986','Office Orderly','G3','','13.06.2013','','#VALUE!','','G9 Certificate, Trade Test Certificate Level  1 Electrical ','','','','Administration','','','','','','',NULL,'CHL-2013-000012',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Sharon Chiyala','210518/18/1','F','31.01.1995','Office Assistant','G3','','01.04.2016','','#VALUE!','','G9 Certificate','','','','Administration','','','','','','',NULL,'CHL-2016-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Stanely Siyowi','237500/74/1','M','12.10.1962','Office Orderly','G3','','21.07.1987','','#VALUE!','','Nil','','','','','','','','','','',NULL,'CHL-1987-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Philda Mainza Milandu ','290364/73/1','F','29.08.1989','Office Orderly','G3','','01.04.2016','','#VALUE!','','G9 Certificate','','','','Administration','','','','','','',NULL,'CHL-2016-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Stanford Cheelo Mweetwa','346282/74/1','M','03.09.1981','Office Orderly','G3','','03.04.2025','','#VALUE!','','G12 Certificate, Certicate of Accounting Technician  ','','','','','','','','','','',NULL,'CHL-2025-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Chipo Muleya Maambo','347861/74/1','F','28.03.1984','Office Orderly','G1','','01.04.2025','','#VALUE!','','G12 Certificate, Certificate in Computer Skills','','','','Administration','','','','','','',NULL,'CHL-2025-000007',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Charles Mudenda','919479/11/1','M','15.02.1983','Driver','G1','','02.05.2013','','#VALUE!','','G12 Certificate, Driving License Class C','','','','','','','','','','',NULL,'CHL-2013-000013',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Joseph Zulu','234174/64/1','M','06.05.1976','Driver','G1','','10.06.2013','','#VALUE!','','G9 Certificate ,Certificate in Front and End Loader and Roller Compactor and  a Drivers Licence C1E','','','','','','','','','','',NULL,'CHL-2013-000014',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Charles Mubita','852332/11/1','M','08.10.1984','Driver','G1','','06.12.2023','','#VALUE!','','G9 Certificate, Certificate in Auto Mechanics, Driving License Class C1E ','','','','','','','','','','',NULL,'CHL-2023-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Ben Mwanza','111939/91/1','M','06.04.1984','Driver','G1','','07.05.2015','','#VALUE!','','G12 Certificate, Driving License Class CE  ','','','','','','','','','','',NULL,'CHL-2015-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Victor Phiri','272019/53/1','M','08.01.1973','Driver','G1','','02.05.2013','','#VALUE!','','Driving License Class C','','','','','','','','','','',NULL,'CHL-2013-000015',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Ilunga Hossana Bwalya','354635/67/1','M','31.01.1976','Driver','G1','','01.10.2016','','#VALUE!','','G9 Certificate, Driving license','','','','','','','','','','',NULL,'CHL-2016-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Zili Ngulube','327630/10/1','M','23.04.1992','Driver','G1','','04.09.2023','','#VALUE!','','G12 Certificate, Certificate in Auto Electrical, Driving License Class C','','','','','','','','','','',NULL,'CHL-2023-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Simbeye Mutale','919675/11/1','M','06.06.1985','Driver','G1','','04.09.2023','','#VALUE!','','G12 Certificate and Driving License Class BCE','','','','','','','','','','',NULL,'CHL-2023-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mizinga Bright','172081/77/1','M','31.10.1989','Driver','G1','','19.05.2025','','#VALUE!','','G12 Certificate, Driver Licence B CE ','','','','','','','','','','',NULL,'CHL-2025-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Victor Nkosi','175633/18/1','M','09.10.1992','Driver','G1','','14.05.2025','','#VALUE!','','G12 Certificate, Driving license, Certificate Level 1  in Automotive Mechanics ','','','','','','','','','','',NULL,'CHL-2025-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Stephen Mukalula','817112/11/1','M','05.04.1984','Driver','G1','','14.05.2025','','#VALUE!','','G12  Certificate , Driving License','','','','','','','','','','',NULL,'CHL-2025-000010',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Dominic Mupila','107999/18/1','M','21.11.1975','Police Sergeant','G3','','17.08.2012','','#VALUE!','','Nil','','','','','','','','','','',NULL,'CHL-2012-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Robert Shachele','428963/11/1','M','15.03.1969','Police Constable','G3','','02.05.2013','','#VALUE!','','G12 Certificate, Private Security Guards Certificate, Diploma in community Based work with children and youths ','','','','','','','','','','',NULL,'CHL-2013-000016',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Remmy Mulemwa Njunga','271214/82/1','M','09.07.1976','Police Constable','G3','','02.05.2013','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2013-000017',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Peggy Nancy Nakawala','731668/11/1','F','14.09.1980','police Constable','G3','','17.06.2013','','#VALUE!','','G12 Certificate','','','','Security','','','','','','',NULL,'CHL-2013-000018',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Peggy Phiri','105980/57/1','F','17.06.1980','Police Constable','G3','','02.05.2013','','#VALUE!','','G12 Certificate','','','','Security','','','','','','',NULL,'CHL-2013-000019',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Julius Daka','316361/10/1','M','15.06.1992',' Police Constable','G3','','01.09.2016','','#VALUE!','','G12 Certificate, Practical Advanced Prosecutors'' Course Certificate in computer studies ','','','','','','','','','','',NULL,'CHL-2016-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Steven Simbeye','199705/18/1','M','08.06.1993','Police Constable','G3','','04.04.2016','','#VALUE!','','G12 Certificate, Dip. Public Administration, BA Public Administration  ','','','','','','','','','','',NULL,'CHL-2016-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mayena Ikuma','991071/11/1','M','30.12.1987','Police Constable','G3','','02.04.2025','','#VALUE!','','G12 Certificate, Certificate in Basic Security, Diploma in Hospitality Managaement, BA Hospitality Management   ','','','','','','','','','','',NULL,'CHL-2025-000011',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Christopher Hansakali','376616/74/1','M','14.05.1983','Police Constable','G3','','02.04.2025','','#VALUE!','','G12  Certificate ','','','','','','','','','','',NULL,'CHL-2025-000012',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Davision Phiri','126420/14/1','M','16.12.1993','Police Constable','G3','','08.12.2025','','#VALUE!','','G12  Certificate ','','','','','','','','','','',NULL,'CHL-2025-000013',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Abel Keya Limama','386254/74/1','M','31.05.1987','Police Constable','G3','','08.12.2025','','#VALUE!','','G12  Certificate ','','','','','','','','','','',NULL,'CHL-2025-000014',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Elalio Kawanga','135950/18/1','M','19.05.1982','Watchman','G3','','01.04.2016','','#VALUE!','','Cerificate in Psychosocial Counselling and G9 Certificate','','','','','','','','','','',NULL,'CHL-2016-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Tukamulozya Sinkamba','191837/10/1','M','11.07.1992','Watchman','G3','','02.10.2017','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2017-000018',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Modern Masemu','204936/75/1','M','10.04.1974','Watchman','G3','','09.10.2017','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2017-000019',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Orlando Sialubala','224388/76/1','M','14.09.1981','Watchman','G3','','01.04.2016','','#VALUE!','','G12 Certificate, Certificate  in Security Management ','','','','','','','','','','',NULL,'CHL-2016-000007',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mathews Silungwe','586591/11/1','M','04.07.1974','Watchman','G3','','04.04.2016','','#VALUE!','','','','','','','','','','','','',NULL,'CHL-2016-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Francis Chanda','106835/10/1','M','28.10.1985','Mechanical Handyman','G1','','07.04.2025','','#VALUE!','','Craft Certificate in Agricultural Mechanics and G12  Certificate ','','','','','','','','','','',NULL,'CHL-2025-000015',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Sangulukani Mbewe','562273/52/1','M','27.07.1988','Mechanical Handyman','G1','','02.04.2025','','#VALUE!','','G12 certificate, Certificate of Competence in Computer Studies ,Trade Test Certificate Level 1 Electrical Advanced Certificate in Project Management','','','','','','','','','','',NULL,'CHL-2025-000016',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Morgan Mphamba','276667/10/1','M','09.09.1993','General Worker','G3','','01.04.2016','','#VALUE!','','G12 Certificate, Trade Test Bricklaying & Plastering  ','','','','','','','','','','',NULL,'CHL-2016-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Sameta Kalupeteka','304637/62/1','M','06.10.1995','General Worker','G3','','01.04.2016','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2016-000010',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Terence Sinkamba','706746/11/1','M','05.03.1978','General Worker','G3','','01.04.2016','','#VALUE!','','Certificate in Mechanical and G12 Certificate ','','','','','','','','','','',NULL,'CHL-2016-000011',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Teddy Munda','717033/11/1','M','01.01.1980','General Worker','G3','','03.04.2016','','#VALUE!','','Nil','','','','','','','','','','',NULL,'CHL-2016-000012',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Samson Wipo Phiri','295272/10/1','M','17.04.1990','General Worker','G3','','01.06.2017','','#VALUE!','','G12 Certificate, Certificate of Competence in Motor Grader Operator','','','','','','','','','','',NULL,'CHL-2017-000020',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mpundu Lloyd','298864/32/1','M','15.08.1992','General Worker','G3','','09.10.2017','','#VALUE!','','    ','','','','','','','','','','',NULL,'CHL-2017-000021',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Misheck Shonga','171585/18/1','M','frazer','General Worker','G3','','01.04.2016','','#VALUE!','','G12 Certificate, Certitificate in sastainable building work supervision, Craft Certificate in Plumbing and Pipe Fitting, Certificate in Pycho-social Counselling, Emergency Aid Certificate ','','','','','','','','','','',NULL,'CHL-2016-000013',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Prince Kapanda Tembo ','431709/53/1','M','20.09.1996','General Worker','G3','','20.05.2019','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2019-000004',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Dailess Lungu','249130/18/1','F','25.12.1998','Chainman','G1','','07.04.25','','#VALUE!','','G12  Certificate           ','','','','General','','','','','','',NULL,'CHL-25-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Aaron Mambwe','341731/64/1','M','04.11.1997','Chainman','G1','','01.04.25','','#VALUE!','','G12 certificate, BSc in Urban and Regional Planning','','','','','','','','','','',NULL,'CHL-25-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Lackwell Muwandia','191992/47/1','M','29.02.1973','Public Worker ','G3','','21.06.2015','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2015-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Julius Zulu','104999/18/1','M','17.02.1974','General Worker ','G3','','17.08.2012','','#VALUE!','','Nil','','','','','','','','','','',NULL,'CHL-2012-000002',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Florence Makombe','102701/18/1','F','05.07.1977','General Worker ','G3','','01.04.2016','','#VALUE!','','Certificate in HSSE, Mechanizing and Customer Service and Cashier and G12 Certificate','','','','Administration','','','','','','',NULL,'CHL-2016-000014',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Rhoda Namutende','386407/67/1','F','03.11.1982','Street Cleaner','G3','','09.10.2017','','#VALUE!','','G9 Certificate','','','','Administration','','','','','','',NULL,'CHL-2017-000022',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Francis Bwalya ','251877/45/1','M','23.01.1992','General Worker ','G3','','09.10.2017','','#VALUE!','','G12 Certificate, Craft Certificate in Automotive Mechanics','','','','','','','','','','',NULL,'CHL-2017-000023',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Robert Chanda','256037/10/1','M','28.10.1993','General Worker ','G3','','09.10.2017','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2017-000024',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Stephen Tembo','113266/57/1','M','06.06.1988','Street Cleaner ','G3','','01.04.2016','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2016-000015',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mwendela Mwendela','167440/81/1','M','20.10.1977','Grave Digger','G3','','17.06.2013','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2013-000020',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Ackim Mbewe','585804/11/1','M','13.07.1973','Grave Digger','G3','','11.06.2013','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2013-000021',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Howard Ilukenaa','238155/83/1','M','26.05.1986','Grave Digger','G3','','07.04.2025','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2025-000017',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Lucas Zulu','176800/57/1','M',' 12.12.2003','Grave Digger','G3','','07.04.2025','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2025-000018',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Paul Musanshiko','200373/18/1','M','26.05.1991','Grave Digger','G3','','19.04.2025','','#VALUE!','','G12 Certificate','','','','','','','','','','',NULL,'CHL-2025-000019',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Kebby Papalu','109175/18/1','M','19.12.1975','General Worker ','G3','','01.09.2012','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2012-000003',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Jairos Njovu','180312/18/1','M','12.11.1986','General Worker ','G3','','17.08.2013','','#VALUE!','','Nil','','','','','','','','','','',NULL,'CHL-2013-000022',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Gift Siyowi','170685/18/1','M','14.01.1991','Refuse Collector','G3','','03.04.2016','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2016-000016',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Frank Mulenga','168112/63/1','M','16.01.1981','Refuse Collector','G3','','01.04.2016','','#VALUE!','','G9 Certificate and Driving License Class C','','','','','','','','','','',NULL,'CHL-2016-000017',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Isaiah Sichamba','207307/10/1','M','24.08.1993','Refuse Collector','G3','','01.04.2016','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2016-000018',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Owen Chiboola','898697/11/1','M','27.07.1982','Refuse Collector','G3','','01.04.2016','','#VALUE!','','G9 Certificate','','','','','','','','','','',NULL,'CHL-2016-000019',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Phylis Miti','319319/61/1','F','06.01.1978','Street Cleaner','G3','','01.04.2016','','#VALUE!','','G9 Certificate','','','','Administration','','','','','','',NULL,'CHL-2016-000020',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Misozi Zulu','188413/18/1','F','25.07.1990','Street Cleaner','G3','','01.04.2016','','#VALUE!','','G9 Certificate','','','','Administration','','','','','','',NULL,'CHL-2016-000021',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Samuel Banda','979925/11/1','M','19.10.1986','General Worker ','G3','','22.05.2019','','#VALUE!','','G12 Certificate ','','','','','','','','','','',NULL,'CHL-2019-000005',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Gift Lungu','432162/10/1','M','10.10.1999','General Worker ','G3','','22.05.2019','','#VALUE!','','Nil','','','','','','','','','','',NULL,'CHL-2019-000006',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Caroline Maambo','150461/19/1','F','03.06.1992','General Worker ','G3','','22.05.2019','','#VALUE!','','G12 Certificate ','','','','Administration','','','','','','',NULL,'CHL-2019-000007',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Kezia Sanana','292823/10/1','F','25.05.1993','General Worker ','G3','','22.05.2019','','#VALUE!','','Nil','','','','Administration','','','','','','',NULL,'CHL-2019-000008',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Priscilla Chongo Lupiya','557789/67/1','F','23.06.1995','General Worker ','G3','','20.05.2019','','#VALUE!','','G12 Certificate ','','','','Administration','','','','','',NULL,NULL,'CHL-2019-000009',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Mackenzie Phiri','580045/11/1A',NULL,NULL,'Town Sergeant',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES('Lusaka','Chilanga','Jane Mwila','123456/78/9','F','1990-05-12','Accounts Officer','C3','LA123','2026-03-01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Administration','0978123456',NULL,NULL,NULL,NULL,NULL,NULL,'ITT-2026-000001',NULL,1,NULL,NULL,NULL,NULL,'Both');
INSERT INTO employees VALUES(NULL,NULL,'Assistant Director Engineering',NULL,'M',NULL,'Assistant Director - Engineering',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Engineering',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ENG-ASSTDIR-001',NULL,1,NULL,NULL,NULL,'CHL-2017-000009','Both');
INSERT INTO employees VALUES(NULL,NULL,'VACANT - Assistant Director Engineering',NULL,NULL,NULL,'Assistant Director - Engineering',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Engineering',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ENG-ASSTDIR-VACANT',NULL,1,NULL,NULL,NULL,'CHL-2017-000009','Both');
INSERT INTO employees VALUES(NULL,NULL,'VACANT - Sub-Officer',NULL,NULL,NULL,'Sub-Officer',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Engineering',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'ENG-SUB-OFF-VACANT',NULL,1,NULL,NULL,NULL,NULL,'Both');
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
INSERT INTO holidays VALUES('2026-12-29','Christian Nation Declaration Day');
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
INSERT INTO calendar VALUES('2026-01-18',0);
INSERT INTO calendar VALUES('2026-01-19',1);
INSERT INTO calendar VALUES('2026-01-20',1);
INSERT INTO calendar VALUES('2026-01-21',1);
INSERT INTO calendar VALUES('2026-01-22',1);
INSERT INTO calendar VALUES('2026-01-23',1);
INSERT INTO calendar VALUES('2026-01-24',0);
INSERT INTO calendar VALUES('2026-01-25',0);
INSERT INTO calendar VALUES('2026-01-26',1);
INSERT INTO calendar VALUES('2026-01-27',1);
INSERT INTO calendar VALUES('2026-01-28',1);
INSERT INTO calendar VALUES('2026-01-29',1);
INSERT INTO calendar VALUES('2026-01-30',1);
INSERT INTO calendar VALUES('2026-01-31',0);
INSERT INTO calendar VALUES('2026-02-01',0);
INSERT INTO calendar VALUES('2026-02-02',1);
INSERT INTO calendar VALUES('2026-02-03',1);
INSERT INTO calendar VALUES('2026-02-04',1);
INSERT INTO calendar VALUES('2026-02-05',1);
INSERT INTO calendar VALUES('2026-02-06',1);
INSERT INTO calendar VALUES('2026-02-07',0);
INSERT INTO calendar VALUES('2026-02-08',0);
INSERT INTO calendar VALUES('2026-02-09',1);
INSERT INTO calendar VALUES('2026-02-10',1);
INSERT INTO calendar VALUES('2026-02-11',1);
INSERT INTO calendar VALUES('2026-02-12',1);
INSERT INTO calendar VALUES('2026-02-13',1);
INSERT INTO calendar VALUES('2026-02-14',0);
INSERT INTO calendar VALUES('2026-02-15',0);
INSERT INTO calendar VALUES('2026-02-16',1);
INSERT INTO calendar VALUES('2026-02-17',1);
INSERT INTO calendar VALUES('2026-02-18',1);
INSERT INTO calendar VALUES('2026-02-19',1);
INSERT INTO calendar VALUES('2026-02-20',1);
INSERT INTO calendar VALUES('2026-02-21',0);
INSERT INTO calendar VALUES('2026-02-22',0);
INSERT INTO calendar VALUES('2026-02-23',1);
INSERT INTO calendar VALUES('2026-02-24',1);
INSERT INTO calendar VALUES('2026-02-25',1);
INSERT INTO calendar VALUES('2026-02-26',1);
INSERT INTO calendar VALUES('2026-02-27',1);
INSERT INTO calendar VALUES('2026-02-28',0);
INSERT INTO calendar VALUES('2026-03-01',0);
INSERT INTO calendar VALUES('2026-03-02',1);
INSERT INTO calendar VALUES('2026-03-03',1);
INSERT INTO calendar VALUES('2026-03-04',1);
INSERT INTO calendar VALUES('2026-03-05',1);
INSERT INTO calendar VALUES('2026-03-06',1);
INSERT INTO calendar VALUES('2026-03-07',0);
INSERT INTO calendar VALUES('2026-03-08',0);
INSERT INTO calendar VALUES('2026-03-09',0);
INSERT INTO calendar VALUES('2026-03-10',1);
INSERT INTO calendar VALUES('2026-03-11',1);
INSERT INTO calendar VALUES('2026-03-12',0);
INSERT INTO calendar VALUES('2026-03-13',1);
INSERT INTO calendar VALUES('2026-03-14',0);
INSERT INTO calendar VALUES('2026-03-15',0);
INSERT INTO calendar VALUES('2026-03-16',1);
INSERT INTO calendar VALUES('2026-03-17',1);
INSERT INTO calendar VALUES('2026-03-18',1);
INSERT INTO calendar VALUES('2026-03-19',1);
INSERT INTO calendar VALUES('2026-03-20',1);
INSERT INTO calendar VALUES('2026-03-21',0);
INSERT INTO calendar VALUES('2026-03-22',0);
INSERT INTO calendar VALUES('2026-03-23',1);
INSERT INTO calendar VALUES('2026-03-24',1);
INSERT INTO calendar VALUES('2026-03-25',1);
INSERT INTO calendar VALUES('2026-03-26',1);
INSERT INTO calendar VALUES('2026-03-27',1);
INSERT INTO calendar VALUES('2026-03-28',0);
INSERT INTO calendar VALUES('2026-03-29',0);
INSERT INTO calendar VALUES('2026-03-30',1);
INSERT INTO calendar VALUES('2026-03-31',1);
INSERT INTO calendar VALUES('2026-04-01',1);
INSERT INTO calendar VALUES('2026-04-02',1);
INSERT INTO calendar VALUES('2026-04-03',0);
INSERT INTO calendar VALUES('2026-04-04',0);
INSERT INTO calendar VALUES('2026-04-05',0);
INSERT INTO calendar VALUES('2026-04-06',0);
INSERT INTO calendar VALUES('2026-04-07',1);
INSERT INTO calendar VALUES('2026-04-08',1);
INSERT INTO calendar VALUES('2026-04-09',1);
INSERT INTO calendar VALUES('2026-04-10',1);
INSERT INTO calendar VALUES('2026-04-11',0);
INSERT INTO calendar VALUES('2026-04-12',0);
INSERT INTO calendar VALUES('2026-04-13',1);
INSERT INTO calendar VALUES('2026-04-14',1);
INSERT INTO calendar VALUES('2026-04-15',1);
INSERT INTO calendar VALUES('2026-04-16',1);
INSERT INTO calendar VALUES('2026-04-17',1);
INSERT INTO calendar VALUES('2026-04-18',0);
INSERT INTO calendar VALUES('2026-04-19',0);
INSERT INTO calendar VALUES('2026-04-20',1);
INSERT INTO calendar VALUES('2026-04-21',1);
INSERT INTO calendar VALUES('2026-04-22',1);
INSERT INTO calendar VALUES('2026-04-23',1);
INSERT INTO calendar VALUES('2026-04-24',1);
INSERT INTO calendar VALUES('2026-04-25',0);
INSERT INTO calendar VALUES('2026-04-26',0);
INSERT INTO calendar VALUES('2026-04-27',1);
INSERT INTO calendar VALUES('2026-04-28',0);
INSERT INTO calendar VALUES('2026-04-29',1);
INSERT INTO calendar VALUES('2026-04-30',1);
INSERT INTO calendar VALUES('2026-05-01',0);
INSERT INTO calendar VALUES('2026-05-02',0);
INSERT INTO calendar VALUES('2026-05-03',0);
INSERT INTO calendar VALUES('2026-05-04',1);
INSERT INTO calendar VALUES('2026-05-05',1);
INSERT INTO calendar VALUES('2026-05-06',1);
INSERT INTO calendar VALUES('2026-05-07',1);
INSERT INTO calendar VALUES('2026-05-08',1);
INSERT INTO calendar VALUES('2026-05-09',0);
INSERT INTO calendar VALUES('2026-05-10',0);
INSERT INTO calendar VALUES('2026-05-11',1);
INSERT INTO calendar VALUES('2026-05-12',1);
INSERT INTO calendar VALUES('2026-05-13',1);
INSERT INTO calendar VALUES('2026-05-14',1);
INSERT INTO calendar VALUES('2026-05-15',1);
INSERT INTO calendar VALUES('2026-05-16',0);
INSERT INTO calendar VALUES('2026-05-17',0);
INSERT INTO calendar VALUES('2026-05-18',1);
INSERT INTO calendar VALUES('2026-05-19',1);
INSERT INTO calendar VALUES('2026-05-20',1);
INSERT INTO calendar VALUES('2026-05-21',1);
INSERT INTO calendar VALUES('2026-05-22',1);
INSERT INTO calendar VALUES('2026-05-23',0);
INSERT INTO calendar VALUES('2026-05-24',0);
INSERT INTO calendar VALUES('2026-05-25',0);
INSERT INTO calendar VALUES('2026-05-26',1);
INSERT INTO calendar VALUES('2026-05-27',1);
INSERT INTO calendar VALUES('2026-05-28',1);
INSERT INTO calendar VALUES('2026-05-29',1);
INSERT INTO calendar VALUES('2026-05-30',0);
INSERT INTO calendar VALUES('2026-05-31',0);
INSERT INTO calendar VALUES('2026-06-01',1);
INSERT INTO calendar VALUES('2026-06-02',1);
INSERT INTO calendar VALUES('2026-06-03',1);
INSERT INTO calendar VALUES('2026-06-04',1);
INSERT INTO calendar VALUES('2026-06-05',1);
INSERT INTO calendar VALUES('2026-06-06',0);
INSERT INTO calendar VALUES('2026-06-07',0);
INSERT INTO calendar VALUES('2026-06-08',1);
INSERT INTO calendar VALUES('2026-06-09',1);
INSERT INTO calendar VALUES('2026-06-10',1);
INSERT INTO calendar VALUES('2026-06-11',1);
INSERT INTO calendar VALUES('2026-06-12',1);
INSERT INTO calendar VALUES('2026-06-13',0);
INSERT INTO calendar VALUES('2026-06-14',0);
INSERT INTO calendar VALUES('2026-06-15',1);
INSERT INTO calendar VALUES('2026-06-16',1);
INSERT INTO calendar VALUES('2026-06-17',1);
INSERT INTO calendar VALUES('2026-06-18',1);
INSERT INTO calendar VALUES('2026-06-19',1);
INSERT INTO calendar VALUES('2026-06-20',0);
INSERT INTO calendar VALUES('2026-06-21',0);
INSERT INTO calendar VALUES('2026-06-22',1);
INSERT INTO calendar VALUES('2026-06-23',1);
INSERT INTO calendar VALUES('2026-06-24',1);
INSERT INTO calendar VALUES('2026-06-25',1);
INSERT INTO calendar VALUES('2026-06-26',1);
INSERT INTO calendar VALUES('2026-06-27',0);
INSERT INTO calendar VALUES('2026-06-28',0);
INSERT INTO calendar VALUES('2026-06-29',1);
INSERT INTO calendar VALUES('2026-06-30',1);
INSERT INTO calendar VALUES('2026-07-01',1);
INSERT INTO calendar VALUES('2026-07-02',1);
INSERT INTO calendar VALUES('2026-07-03',1);
INSERT INTO calendar VALUES('2026-07-04',0);
INSERT INTO calendar VALUES('2026-07-05',0);
INSERT INTO calendar VALUES('2026-07-06',0);
INSERT INTO calendar VALUES('2026-07-07',0);
INSERT INTO calendar VALUES('2026-07-08',1);
INSERT INTO calendar VALUES('2026-07-09',1);
INSERT INTO calendar VALUES('2026-07-10',1);
INSERT INTO calendar VALUES('2026-07-11',0);
INSERT INTO calendar VALUES('2026-07-12',0);
INSERT INTO calendar VALUES('2026-07-13',1);
INSERT INTO calendar VALUES('2026-07-14',1);
INSERT INTO calendar VALUES('2026-07-15',1);
INSERT INTO calendar VALUES('2026-07-16',1);
INSERT INTO calendar VALUES('2026-07-17',1);
INSERT INTO calendar VALUES('2026-07-18',0);
INSERT INTO calendar VALUES('2026-07-19',0);
INSERT INTO calendar VALUES('2026-07-20',1);
INSERT INTO calendar VALUES('2026-07-21',1);
INSERT INTO calendar VALUES('2026-07-22',1);
INSERT INTO calendar VALUES('2026-07-23',1);
INSERT INTO calendar VALUES('2026-07-24',1);
INSERT INTO calendar VALUES('2026-07-25',0);
INSERT INTO calendar VALUES('2026-07-26',0);
INSERT INTO calendar VALUES('2026-07-27',1);
INSERT INTO calendar VALUES('2026-07-28',1);
INSERT INTO calendar VALUES('2026-07-29',1);
INSERT INTO calendar VALUES('2026-07-30',1);
INSERT INTO calendar VALUES('2026-07-31',1);
INSERT INTO calendar VALUES('2026-08-01',0);
INSERT INTO calendar VALUES('2026-08-02',0);
INSERT INTO calendar VALUES('2026-08-03',0);
INSERT INTO calendar VALUES('2026-08-04',1);
INSERT INTO calendar VALUES('2026-08-05',1);
INSERT INTO calendar VALUES('2026-08-06',1);
INSERT INTO calendar VALUES('2026-08-07',1);
INSERT INTO calendar VALUES('2026-08-08',0);
INSERT INTO calendar VALUES('2026-08-09',0);
INSERT INTO calendar VALUES('2026-08-10',1);
INSERT INTO calendar VALUES('2026-08-11',1);
INSERT INTO calendar VALUES('2026-08-12',1);
INSERT INTO calendar VALUES('2026-08-13',0);
INSERT INTO calendar VALUES('2026-08-14',1);
INSERT INTO calendar VALUES('2026-08-15',0);
INSERT INTO calendar VALUES('2026-08-16',0);
INSERT INTO calendar VALUES('2026-08-17',1);
INSERT INTO calendar VALUES('2026-08-18',1);
INSERT INTO calendar VALUES('2026-08-19',1);
INSERT INTO calendar VALUES('2026-08-20',1);
INSERT INTO calendar VALUES('2026-08-21',1);
INSERT INTO calendar VALUES('2026-08-22',0);
INSERT INTO calendar VALUES('2026-08-23',0);
INSERT INTO calendar VALUES('2026-08-24',1);
INSERT INTO calendar VALUES('2026-08-25',1);
INSERT INTO calendar VALUES('2026-08-26',1);
INSERT INTO calendar VALUES('2026-08-27',1);
INSERT INTO calendar VALUES('2026-08-28',1);
INSERT INTO calendar VALUES('2026-08-29',0);
INSERT INTO calendar VALUES('2026-08-30',0);
INSERT INTO calendar VALUES('2026-08-31',1);
INSERT INTO calendar VALUES('2026-09-01',1);
INSERT INTO calendar VALUES('2026-09-02',1);
INSERT INTO calendar VALUES('2026-09-03',1);
INSERT INTO calendar VALUES('2026-09-04',1);
INSERT INTO calendar VALUES('2026-09-05',0);
INSERT INTO calendar VALUES('2026-09-06',0);
INSERT INTO calendar VALUES('2026-09-07',1);
INSERT INTO calendar VALUES('2026-09-08',1);
INSERT INTO calendar VALUES('2026-09-09',1);
INSERT INTO calendar VALUES('2026-09-10',1);
INSERT INTO calendar VALUES('2026-09-11',1);
INSERT INTO calendar VALUES('2026-09-12',0);
INSERT INTO calendar VALUES('2026-09-13',0);
INSERT INTO calendar VALUES('2026-09-14',1);
INSERT INTO calendar VALUES('2026-09-15',1);
INSERT INTO calendar VALUES('2026-09-16',1);
INSERT INTO calendar VALUES('2026-09-17',1);
INSERT INTO calendar VALUES('2026-09-18',1);
INSERT INTO calendar VALUES('2026-09-19',0);
INSERT INTO calendar VALUES('2026-09-20',0);
INSERT INTO calendar VALUES('2026-09-21',1);
INSERT INTO calendar VALUES('2026-09-22',1);
INSERT INTO calendar VALUES('2026-09-23',1);
INSERT INTO calendar VALUES('2026-09-24',1);
INSERT INTO calendar VALUES('2026-09-25',1);
INSERT INTO calendar VALUES('2026-09-26',0);
INSERT INTO calendar VALUES('2026-09-27',0);
INSERT INTO calendar VALUES('2026-09-28',1);
INSERT INTO calendar VALUES('2026-09-29',1);
INSERT INTO calendar VALUES('2026-09-30',1);
INSERT INTO calendar VALUES('2026-10-01',1);
INSERT INTO calendar VALUES('2026-10-02',1);
INSERT INTO calendar VALUES('2026-10-03',0);
INSERT INTO calendar VALUES('2026-10-04',0);
INSERT INTO calendar VALUES('2026-10-05',1);
INSERT INTO calendar VALUES('2026-10-06',1);
INSERT INTO calendar VALUES('2026-10-07',1);
INSERT INTO calendar VALUES('2026-10-08',1);
INSERT INTO calendar VALUES('2026-10-09',1);
INSERT INTO calendar VALUES('2026-10-10',0);
INSERT INTO calendar VALUES('2026-10-11',0);
INSERT INTO calendar VALUES('2026-10-12',1);
INSERT INTO calendar VALUES('2026-10-13',1);
INSERT INTO calendar VALUES('2026-10-14',1);
INSERT INTO calendar VALUES('2026-10-15',1);
INSERT INTO calendar VALUES('2026-10-16',1);
INSERT INTO calendar VALUES('2026-10-17',0);
INSERT INTO calendar VALUES('2026-10-18',0);
INSERT INTO calendar VALUES('2026-10-19',0);
INSERT INTO calendar VALUES('2026-10-20',1);
INSERT INTO calendar VALUES('2026-10-21',1);
INSERT INTO calendar VALUES('2026-10-22',1);
INSERT INTO calendar VALUES('2026-10-23',1);
INSERT INTO calendar VALUES('2026-10-24',0);
INSERT INTO calendar VALUES('2026-10-25',0);
INSERT INTO calendar VALUES('2026-10-26',1);
INSERT INTO calendar VALUES('2026-10-27',1);
INSERT INTO calendar VALUES('2026-10-28',1);
INSERT INTO calendar VALUES('2026-10-29',1);
INSERT INTO calendar VALUES('2026-10-30',1);
INSERT INTO calendar VALUES('2026-10-31',0);
INSERT INTO calendar VALUES('2026-11-01',0);
INSERT INTO calendar VALUES('2026-11-02',1);
INSERT INTO calendar VALUES('2026-11-03',1);
INSERT INTO calendar VALUES('2026-11-04',1);
INSERT INTO calendar VALUES('2026-11-05',1);
INSERT INTO calendar VALUES('2026-11-06',1);
INSERT INTO calendar VALUES('2026-11-07',0);
INSERT INTO calendar VALUES('2026-11-08',0);
INSERT INTO calendar VALUES('2026-11-09',1);
INSERT INTO calendar VALUES('2026-11-10',1);
INSERT INTO calendar VALUES('2026-11-11',1);
INSERT INTO calendar VALUES('2026-11-12',1);
INSERT INTO calendar VALUES('2026-11-13',1);
INSERT INTO calendar VALUES('2026-11-14',0);
INSERT INTO calendar VALUES('2026-11-15',0);
INSERT INTO calendar VALUES('2026-11-16',1);
INSERT INTO calendar VALUES('2026-11-17',1);
INSERT INTO calendar VALUES('2026-11-18',1);
INSERT INTO calendar VALUES('2026-11-19',1);
INSERT INTO calendar VALUES('2026-11-20',1);
INSERT INTO calendar VALUES('2026-11-21',0);
INSERT INTO calendar VALUES('2026-11-22',0);
INSERT INTO calendar VALUES('2026-11-23',1);
INSERT INTO calendar VALUES('2026-11-24',1);
INSERT INTO calendar VALUES('2026-11-25',1);
INSERT INTO calendar VALUES('2026-11-26',1);
INSERT INTO calendar VALUES('2026-11-27',1);
INSERT INTO calendar VALUES('2026-11-28',0);
INSERT INTO calendar VALUES('2026-11-29',0);
INSERT INTO calendar VALUES('2026-11-30',1);
INSERT INTO calendar VALUES('2026-12-01',1);
INSERT INTO calendar VALUES('2026-12-02',1);
INSERT INTO calendar VALUES('2026-12-03',1);
INSERT INTO calendar VALUES('2026-12-04',1);
INSERT INTO calendar VALUES('2026-12-05',0);
INSERT INTO calendar VALUES('2026-12-06',0);
INSERT INTO calendar VALUES('2026-12-07',1);
INSERT INTO calendar VALUES('2026-12-08',1);
INSERT INTO calendar VALUES('2026-12-09',1);
INSERT INTO calendar VALUES('2026-12-10',1);
INSERT INTO calendar VALUES('2026-12-11',1);
INSERT INTO calendar VALUES('2026-12-12',0);
INSERT INTO calendar VALUES('2026-12-13',0);
INSERT INTO calendar VALUES('2026-12-14',1);
INSERT INTO calendar VALUES('2026-12-15',1);
INSERT INTO calendar VALUES('2026-12-16',1);
INSERT INTO calendar VALUES('2026-12-17',1);
INSERT INTO calendar VALUES('2026-12-18',1);
INSERT INTO calendar VALUES('2026-12-19',0);
INSERT INTO calendar VALUES('2026-12-20',0);
INSERT INTO calendar VALUES('2026-12-21',1);
INSERT INTO calendar VALUES('2026-12-22',1);
INSERT INTO calendar VALUES('2026-12-23',1);
INSERT INTO calendar VALUES('2026-12-24',1);
INSERT INTO calendar VALUES('2026-12-25',0);
INSERT INTO calendar VALUES('2026-12-26',0);
INSERT INTO calendar VALUES('2026-12-27',0);
INSERT INTO calendar VALUES('2026-12-28',1);
INSERT INTO calendar VALUES('2026-12-29',0);
INSERT INTO calendar VALUES('2026-12-30',1);
INSERT INTO calendar VALUES('2026-12-31',1);
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
INSERT INTO authority_codes VALUES('Masaiti','MST');
INSERT INTO authority_codes VALUES('Mpongwe','MPG');
INSERT INTO authority_codes VALUES('Mufulira','MUF');
INSERT INTO authority_codes VALUES('Ndola','NDL');
INSERT INTO authority_codes VALUES('Chadiza','CDZ');
INSERT INTO authority_codes VALUES('Chama','CMA');
INSERT INTO authority_codes VALUES('Chasefu','CSF');
INSERT INTO authority_codes VALUES('Chipangali','CPG');
INSERT INTO authority_codes VALUES('Chipata','CPT');
INSERT INTO authority_codes VALUES('Kasenengwa','KSN');
INSERT INTO authority_codes VALUES('Katete','KTT');
INSERT INTO authority_codes VALUES('Lumezi','LMZ');
INSERT INTO authority_codes VALUES('Lundazi','LND');
INSERT INTO authority_codes VALUES('Lusangazi','LSG');
INSERT INTO authority_codes VALUES('Nyimba','NYM');
INSERT INTO authority_codes VALUES('Petauke','PTK');
INSERT INTO authority_codes VALUES('Sinda','SND');
INSERT INTO authority_codes VALUES('Vubwi','VBW');
INSERT INTO authority_codes VALUES('Chembe','CHB');
INSERT INTO authority_codes VALUES('Chiengi','CHG');
INSERT INTO authority_codes VALUES('Chifunabuli','CFB');
INSERT INTO authority_codes VALUES('Chipili','CPL');
INSERT INTO authority_codes VALUES('Kawambwa','KWB');
INSERT INTO authority_codes VALUES('Lunga','LNG');
INSERT INTO authority_codes VALUES('Mansa','MNS');
INSERT INTO authority_codes VALUES('Milenge','MLG');
INSERT INTO authority_codes VALUES('Mwansabombwe','MSB');
INSERT INTO authority_codes VALUES('Mwense','MWE');
INSERT INTO authority_codes VALUES('Nchelenge','NCL');
INSERT INTO authority_codes VALUES('Samfya','SMF');
INSERT INTO authority_codes VALUES('Kafue','KAF');
INSERT INTO authority_codes VALUES('Luangwa','LWG');
INSERT INTO authority_codes VALUES('Lusaka','LSK');
INSERT INTO authority_codes VALUES('Rufunsa','RFN');
INSERT INTO authority_codes VALUES('Chinsali','CNS');
INSERT INTO authority_codes VALUES('Isoka','ISK');
INSERT INTO authority_codes VALUES('Mafinga','MFG');
INSERT INTO authority_codes VALUES('Mpika','MPK');
INSERT INTO authority_codes VALUES('Nakonde','NKD');
INSERT INTO authority_codes VALUES('Kanchibiya','KCB');
INSERT INTO authority_codes VALUES('Lavushimanda','LVM');
INSERT INTO authority_codes VALUES('Shiwang''andu','SWA');
INSERT INTO authority_codes VALUES('Kasama','KSM');
INSERT INTO authority_codes VALUES('Chilubi','CLB');
INSERT INTO authority_codes VALUES('Kaputa','KPT');
INSERT INTO authority_codes VALUES('Mbala','MBL');
INSERT INTO authority_codes VALUES('Mporokoso','MPR');
INSERT INTO authority_codes VALUES('Mpulungu','MPL');
INSERT INTO authority_codes VALUES('Mungwi','MNG');
INSERT INTO authority_codes VALUES('Nsama','NSM');
INSERT INTO authority_codes VALUES('Lupososhi','LPS');
INSERT INTO authority_codes VALUES('Lunte','LNT');
INSERT INTO authority_codes VALUES('Senga Hill','SGH');
INSERT INTO authority_codes VALUES('Chavuma','CVM');
INSERT INTO authority_codes VALUES('Ikelenge','IKG');
INSERT INTO authority_codes VALUES('Kabompo','KBP');
INSERT INTO authority_codes VALUES('Kalumbila','KLB');
INSERT INTO authority_codes VALUES('Kasempa','KSP');
INSERT INTO authority_codes VALUES('Manyinga','MYG');
INSERT INTO authority_codes VALUES('Mufumbwe','MFB');
INSERT INTO authority_codes VALUES('Mushindamo','MSD');
INSERT INTO authority_codes VALUES('Mwinilunga','MWN');
INSERT INTO authority_codes VALUES('Solwezi','SLW');
INSERT INTO authority_codes VALUES('Zambezi','ZMB');
INSERT INTO authority_codes VALUES('Chikankata','CKT');
INSERT INTO authority_codes VALUES('Chirundu','CRD');
INSERT INTO authority_codes VALUES('Choma','CHM');
INSERT INTO authority_codes VALUES('Gwembe','GWB');
INSERT INTO authority_codes VALUES('Itezhi Tezhi','ITT');
INSERT INTO authority_codes VALUES('Kalomo','KLM');
INSERT INTO authority_codes VALUES('Kazungula','KZG');
INSERT INTO authority_codes VALUES('Livingstone','LIV');
INSERT INTO authority_codes VALUES('Mazabuka','MZB');
INSERT INTO authority_codes VALUES('Monze','MNZ');
INSERT INTO authority_codes VALUES('Namwala','NMW');
INSERT INTO authority_codes VALUES('Pemba','PMB');
INSERT INTO authority_codes VALUES('Siavonga','SVG');
INSERT INTO authority_codes VALUES('Sinazongwe','SNZ');
INSERT INTO authority_codes VALUES('Kaoma','KOM');
INSERT INTO authority_codes VALUES('Limulunga','LML');
INSERT INTO authority_codes VALUES('Luampa','LPM');
INSERT INTO authority_codes VALUES('Lukulu','LKL');
INSERT INTO authority_codes VALUES('Mitete','MTT');
INSERT INTO authority_codes VALUES('Mulobezi','MLB');
INSERT INTO authority_codes VALUES('Mwandi','MWD');
INSERT INTO authority_codes VALUES('Nalolo','NLL');
INSERT INTO authority_codes VALUES('Nkeyema','NKY');
INSERT INTO authority_codes VALUES('Senanga','SNG');
INSERT INTO authority_codes VALUES('Sesheke','SSH');
INSERT INTO authority_codes VALUES('Shangombo','SGM');
INSERT INTO authority_codes VALUES('Sikongo','SKG');
INSERT INTO authority_codes VALUES('Sioma','SOM');
INSERT INTO authority_codes VALUES('Chililabombwe','CLC');
INSERT INTO authority_codes VALUES('Chongwe','CHW');
INSERT INTO authority_codes VALUES('Kalabo','KLO');
INSERT INTO authority_codes VALUES('Luwingu','LWI');
INSERT INTO authority_codes VALUES('Mambwe','MMB');
INSERT INTO authority_codes VALUES('Mongu','MGU');
INSERT INTO authority_codes VALUES('Zimba','ZIM');
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
INSERT INTO position_attributes VALUES('ENG-FIRE-HEAD','Municipal','Chief Fire Officer','LGSS/06',1,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-HEAD','City','Chief Fire Officer','LGSS/06',1,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-FF','Town','Firefighter','LGSS/14',4,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-FF','Municipal','Firefighter','LGSS/14',6,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-FF','City','Firefighter','LGSS/14',8,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-DRV','Town','Firefighter Driver','LGSS/14',2,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-DRV','Municipal','Firefighter Driver','LGSS/14',2,NULL);
INSERT INTO position_attributes VALUES('ENG-FIRE-DRV','City','Firefighter Driver','LGSS/14',2,NULL);
INSERT INTO position_attributes VALUES('ENG-MECHNIC','Town','Mechanic','LGSS/14',2,NULL);
INSERT INTO position_attributes VALUES('ENG-MECHNIC','Municipal','Mechanic','LGSS/14',3,NULL);
INSERT INTO position_attributes VALUES('ENG-MECHNIC','City','Mechanic','LGSS/14',3,NULL);
INSERT INTO position_attributes VALUES('ENG-OPER','Town','Operator (Excavator, Roller, Grader, TLB)','LGSS/14',8,NULL);
INSERT INTO position_attributes VALUES('ENG-OPER','Municipal','Ferry/Pontoon Operator','LGSS/14',4,NULL);
INSERT INTO position_attributes VALUES('ENG-OPER','City','Ferry Operator','LGSS/14',4,NULL);
INSERT INTO position_attributes VALUES('ENG-WATSAN-HEAD','Town','Water & Sanitation Engineer','LGSS/07',1,NULL);
INSERT INTO position_attributes VALUES('ENG-WATSAN-HEAD','Municipal','Rural Water & Sanitation Coordinator','LGSS/06',1,NULL);
INSERT INTO position_attributes VALUES('ENG-WATSAN-HEAD','City','Rural Water & Sanitation Coordinator','LGSS/07',1,NULL);
INSERT INTO position_attributes VALUES('HR-DIR-TOWN','Town','Director of Human Resource & Administration','LGSS/05',1,NULL);
INSERT INTO position_attributes VALUES('HR-CHRO-TOWN','Town','Chief Human Resources Officer','LGSS/06',1,NULL);
INSERT INTO position_attributes VALUES('HR-SNR-HRO-TOWN','Town','Senior Human Resource Officer','LGSS/07',1,NULL);
INSERT INTO position_attributes VALUES('HR-HRO-TOWN','Town','Human Resources Officer','LGSS/08',3,NULL);
INSERT INTO position_attributes VALUES('HR-HRM-HEALTH-TOWN','Town','Human Resource Management Officer','LGSS/08',1,NULL);
INSERT INTO position_attributes VALUES('HR-HRM-FISH-TOWN','Town','Human Resource Management Officer','LGSS/08',1,NULL);
INSERT INTO position_attributes VALUES('HR-CH-ADMIN-TOWN','Town','Chief Administrative & Committee Officer','LGSS/06',1,NULL);
INSERT INTO position_attributes VALUES('HR-ADMIN-TOWN','Town','Administrative Officer','LGSS/10',1,NULL);
INSERT INTO position_attributes VALUES('HR-SEC-TOWN','Town','Personal Secretary','LGSS/10',1,NULL);
INSERT INTO position_attributes VALUES('HR-STENO-TOWN','Town','Stenographer','LGSS/12',1,NULL);
INSERT INTO position_attributes VALUES('HR-TYPIST-TOWN','Town','Typist','LGSS/14',2,NULL);
INSERT INTO position_attributes VALUES('HR-ORDERLY-TOWN','Town','Office Orderly','G3',6,NULL);
INSERT INTO position_attributes VALUES('HR-DRIVER-TOWN','Town','Driver','G1',4,NULL);
INSERT INTO position_attributes VALUES('HR-COMM-CLERK-TOWN','Town','Committee Clerk','LGSS/10',1,NULL);
INSERT INTO position_attributes VALUES('HR-ASST-COMM-TOWN','Town','Assistant Committee Clerk','LGSS/12',2,NULL);
INSERT INTO position_attributes VALUES('HR-REG-SUP-TOWN','Town','Registry Supervisor','LGSS/14',1,NULL);
INSERT INTO position_attributes VALUES('HR-REG-CLERK-TOWN','Town','Registry Clerk','LGSS/17',5,NULL);
INSERT INTO position_attributes VALUES('HR-SNR-SEC-TOWN','Town','Senior Security Officer','LGSS/08',1,NULL);
INSERT INTO position_attributes VALUES('HR-SEC-OFFICER-TOWN','Town','Security Officer','LGSS/10',1,NULL);
INSERT INTO position_attributes VALUES('HR-SERGEANT-TOWN','Town','Town Sergeant','LGSS/12',1,NULL);
INSERT INTO position_attributes VALUES('HR-SUB-INSPECTOR-TOWN','Town','Sub-Inspector','LGSS/16',4,NULL);
INSERT INTO position_attributes VALUES('HR-POLICE-TOWN','Town','Police Constable','G3',10,NULL);
CREATE TABLE authorities (
    authority_prefix TEXT PRIMARY KEY,
    authority_name TEXT NOT NULL,
    authority_type TEXT NOT NULL   -- Town, Municipal, City
);
INSERT INTO authorities VALUES('ZM-01-KLO','Kalabo Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-KOM','Kaoma Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-LML','Limulunga Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-LPM','Luampa Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-LKL','Lukulu Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-MTT','Mitete Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-MGU','Mongu Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-01-MLB','Mulobezi Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-MWD','Mwandi Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-NLL','Nalolo Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-NKY','Nkeyema Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-SNG','Senanga Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-SSH','Sesheke Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-SGM','Shangombo Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-SKG','Sikongo Town Council','Town');
INSERT INTO authorities VALUES('ZM-01-SOM','Sioma Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-CBB','Chibombo Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-CSM','Chisamba Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-CTM','Chitambo Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-KBW','Kabwe Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-02-KPM','Kapiri Mposhi Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-LNO','Luano Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-MKU','Mkushi Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-MBW','Mumbwa Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-NGB','Ngabwe Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-SRJ','Serenje Town Council','Town');
INSERT INTO authorities VALUES('ZM-02-SBY','Shibuyunji Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-CDZ','Chadiza Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-CMA','Chama Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-CSF','Chasefu Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-CPG','Chipangali Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-CPT','Chipata City Council','City');
INSERT INTO authorities VALUES('ZM-03-KSN','Kasenengwa Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-KTT','Katete Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-LMZ','Lumezi Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-LND','Lundazi Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-LSG','Lusangazi Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-MMB','Mambwe Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-NYM','Nyimba Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-PTK','Petauke Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-SND','Sinda Town Council','Town');
INSERT INTO authorities VALUES('ZM-03-VBW','Vubwi Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-CHB','Chembe Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-CHG','Chiengi Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-CFB','Chifunabuli Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-CPL','Chipili Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-KWB','Kawambwa Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-LNG','Lunga Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-MNS','Mansa Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-04-MLG','Milenge Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-MSB','Mwansabombwe Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-MWE','Mwense Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-NCL','Nchelenge Town Council','Town');
INSERT INTO authorities VALUES('ZM-04-SMF','Samfya Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-CLB','Chilubi Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-KPT','Kaputa Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-KSM','Kasama Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-05-LNT','Lunte Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-LPS','Lupososhi Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-LWI','Luwingu Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-MBL','Mbala Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-05-MPR','Mporokoso Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-MPL','Mpulungu Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-MNG','Mungwi Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-NSM','Nsama Town Council','Town');
INSERT INTO authorities VALUES('ZM-05-SGH','Senga Hill Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-CVM','Chavuma Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-IKG','Ikelenge Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-KBP','Kabompo Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-KLB','Kalumbila Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-KSP','Kasempa Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-MYG','Manyinga Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-MFB','Mufumbwe Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-MSD','Mushindamo Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-MWN','Mwinilunga Town Council','Town');
INSERT INTO authorities VALUES('ZM-06-SLW','Solwezi Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-06-ZMB','Zambezi Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-CKT','Chikankata Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-CRD','Chirundu Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-CHM','Choma Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-07-GWB','Gwembe Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-ITT','Itezhi Tezhi Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-KLM','Kalomo Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-KZG','Kazungula Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-LCC','Livingstone City Council','City');
INSERT INTO authorities VALUES('ZM-07-MZB','Mazabuka Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-07-MNZ','Monze Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-NMW','Namwala Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-PMB','Pemba Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-SVG','Siavonga Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-SNZ','Sinazongwe Town Council','Town');
INSERT INTO authorities VALUES('ZM-07-ZIM','Zimba Town Council','Town');
INSERT INTO authorities VALUES('ZM-08-CLC','Chililabombwe Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-08-CHN','Chingola Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-08-KLS','Kalulushi Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-08-KCC','Kitwe City Council','City');
INSERT INTO authorities VALUES('ZM-08-LUN','Luanshya Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-08-LFW','Lufwanyama Town Council','Town');
INSERT INTO authorities VALUES('ZM-08-MST','Masaiti Town Council','Town');
INSERT INTO authorities VALUES('ZM-08-MPG','Mpongwe Town Council','Town');
INSERT INTO authorities VALUES('ZM-08-MUF','Mufulira Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-08-NDL','Ndola City Council','City');
INSERT INTO authorities VALUES('ZM-09-CHL','Chilanga Town Council','Town');
INSERT INTO authorities VALUES('ZM-09-CHW','Chongwe Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-09-KAF','Kafue Town Council','Town');
INSERT INTO authorities VALUES('ZM-09-LWG','Luangwa Town Council','Town');
INSERT INTO authorities VALUES('ZM-09-LCC','Lusaka City Council','City');
INSERT INTO authorities VALUES('ZM-09-RFN','Rufunsa Town Council','Town');
INSERT INTO authorities VALUES('ZM-10-CNS','Chinsali Municipal Council','Municipal');
INSERT INTO authorities VALUES('ZM-10-ISK','Isoka Town Council','Town');
INSERT INTO authorities VALUES('ZM-10-KCB','Kanchibiya Town Council','Town');
INSERT INTO authorities VALUES('ZM-10-LVM','Lavushimanda Town Council','Town');
INSERT INTO authorities VALUES('ZM-10-MFG','Mafinga Town Council','Town');
INSERT INTO authorities VALUES('ZM-10-MPK','Mpika Town Council','Town');
INSERT INTO authorities VALUES('ZM-10-NKD','Nakonde Town Council','Town');
INSERT INTO authorities VALUES('ZM-10-SWA','Shiwang''andu Town Council','Town');
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
INSERT INTO position_supervisors VALUES('ENG-MECHNIC','ENG-MECH-HEAD','City',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-DIR-TOWN','COUNC-SEC','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-CHRO-TOWN','HR-DIR-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-SNR-HRO-TOWN','HR-CHRO-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-HRO-TOWN','HR-SNR-HRO-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-HRM-HEALTH-TOWN','HR-DIR-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-HRM-FISH-TOWN','HR-DIR-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-CH-ADMIN-TOWN','HR-DIR-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-ADMIN-TOWN','HR-CH-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-SEC-TOWN','HR-CH-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-STENO-TOWN','HR-CH-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-TYPIST-TOWN','HR-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-ORDERLY-TOWN','HR-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-DRIVER-TOWN','HR-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-COMM-CLERK-TOWN','HR-CH-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-ASST-COMM-TOWN','HR-COMM-CLERK-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-REG-SUP-TOWN','HR-ADMIN-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-REG-CLERK-TOWN','HR-REG-SUP-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-SNR-SEC-TOWN','HR-DIR-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-SEC-OFFICER-TOWN','HR-SNR-SEC-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-SERGEANT-TOWN','HR-SNR-SEC-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-SUB-INSPECTOR-TOWN','HR-SNR-SEC-TOWN','Town',NULL,NULL);
INSERT INTO position_supervisors VALUES('HR-POLICE-TOWN','HR-SNR-SEC-TOWN','Town',NULL,NULL);
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
INSERT INTO HRA_Positions VALUES('HR-DRIVER-HEALTH-TOWN','Driver','G3',3,1,'HRA-SUP-DRV3-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-GW-HEALTH-TOWN','General Worker','G3',3,1,'HRA-SUP-GEN-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-COMM-CLERK-TOWN','Committee Clerk','LGSS/10',1,1,'HRA-ADM-CLK-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-ASST-COMM-TOWN','Assistant Committee Clerk','LGSS/12',2,1,'HRA-ADM-AST-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-REG-SUP-TOWN','Registry Supervisor','LGSS/14',1,1,'HRA-ADM-SUP-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-REG-CLERK-TOWN','Registry Clerk','LGSS/17',5,1,'HRA-ADM-REG-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-SNR-SEC-TOWN','Senior Security Officer','LGSS/08',1,1,'HRA-SEC-SNR-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-SEC-OFFICER-TOWN','Security Officer','LGSS/10',1,1,'HRA-SEC-OFF-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-SERGEANT-TOWN','Town Sergeant','LGSS/12',1,1,'HRA-SEC-SGT-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-SUB-INSPECTOR-TOWN','Sub-Inspector','LGSS/16',4,1,'HRA-SEC-INSP-TOW-01');
INSERT INTO HRA_Positions VALUES('HR-POLICE-TOWN','Police Constable','G3',10,1,'HRA-SEC-PC-TOW-01');
INSERT INTO HRA_Positions VALUES('HRA-DIR-MUN','Director of Human Resource & Administration','LGSS/04',1,2,'HRA-LEAD-DIR-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-CHRO-MUN','Chief Human Resources Officer','LGSS/06',1,2,'HRA-HRM-CHIEF-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-HRO-MUN','Senior Human Resource Officer','LGSS/07',2,2,'HRA-HRM-SNR-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-HRO-MUN','Human Resources Officer','LGSS/08',8,2,'HRA-HRM-OFF-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-CH-ADMIN-MUN','Chief Administrative Officer','LGSS/06',1,2,'HRA-ADM-CHIEF-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-ADMIN-MUN','Senior Administrative Officer','LGSS/07',2,2,'HRA-ADM-SNR-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-ADMIN-MUN','Administrative Officer','LGSS/08',6,2,'HRA-ADM-OFF-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SEC-MUN','Personal Secretary','LGSS/10',1,2,'HRA-ADM-SEC-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-STENO-MUN','Stenographer','LGSS/12',2,2,'HRA-COM-STEN-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-TYPIST-MUN','Typist','LGSS/14',9,2,'HRA-COM-TYP-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-HEAD-DRIVER-MUN','Head Driver','G1',1,2,'HRA-ADM-HDDRV-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-DRIVER-MUN','Driver','G1',24,2,'HRA-ADM-DRV-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-ORDERLY-MUN','Office Orderly','G3',20,2,'HRA-ADM-ORD-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-WATCHMAN-MUN','Watchman','G3',15,2,'HRA-SEC-WATCH-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-REG-SUP-MUN','Registry Supervisor','LGSS/14',2,2,'HRA-ADM-SUP-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-REG-CLERK-MUN','Registry Clerk','LGSS/17',15,2,'HRA-ADM-REG-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-CH-COMM-MUN','Chief Committee Clerk','LGSS/06',1,2,'HRA-COM-CHIEF-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-COMM-MUN','Senior Committee Clerk','LGSS/08',1,2,'HRA-COM-SNR-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-COMM-CLERK-MUN','Committee Clerk','LGSS/10',3,2,'HRA-COM-CLK-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-ASST-COMM-MUN','Assistant Committee Clerk','LGSS/12',2,2,'HRA-COM-AST-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-CH-SEC-MUN','Chief Security Officer','LGSS/06',1,2,'HRA-SEC-CHIEF-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-SEC-MUN','Senior Security Officer','LGSS/08',1,2,'HRA-SEC-SNR-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SEC-OFFICER-MUN','Security Officer','LGSS/08',1,2,'HRA-SEC-OFF-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SERGEANT-MUN','Town Sergeant','LGSS/10',2,2,'HRA-SEC-SGT-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-INSPECTOR-MUN','Inspector','LGSS/12',2,2,'HRA-SEC-INSP-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-SUB-INSPECTOR-MUN','Sub Inspector','LGSS/14',4,2,'HRA-SEC-SUB-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-POLICE-MUN','Police Constable','G1',65,2,'HRA-SEC-PC-MUN-01');
INSERT INTO HRA_Positions VALUES('HRA-DIR-CITY','Director of Human Resource & Administration','LGSS/03',1,3,'HRA-LEAD-DIR-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-ADIR-HRMDEV-CITY','Assistant Director – HR Management & Development','LGSS/05',1,3,'HRA-LEAD-ADIR-HRM-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-CHRO-CITY','Chief Human Resource Officer','LGSS/06',1,3,'HRA-HRM-CHIEF-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-HRO-CITY','Senior Human Resource Officer','LGSS/07',3,3,'HRA-HRM-SNR-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-HRO-CITY','Human Resource Officer','LGSS/08',10,3,'HRA-HRM-OFF-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-ADIR-ADMIN-CITY','Assistant Director – Administration','LGSS/05',1,3,'HRA-LEAD-ADIR-ADM-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-CH-ADMIN-CITY','Chief Administrative Officer','LGSS/06',1,3,'HRA-ADM-CHIEF-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-ADMIN-CITY','Senior Administrative Officer','LGSS/07',8,3,'HRA-ADM-SNR-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-ADMIN-CITY','Administrative Officer','LGSS/08',8,3,'HRA-ADM-OFF-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-PRINT-CITY','Senior Printing Officer','LGSS/08',1,3,'HRA-ADM-SNRPRINT-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-PRINT-CITY','Printing Officer','LGSS/10',1,3,'HRA-ADM-PRINT-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SEC-CITY','Personal Secretary','LGSS/11',1,3,'HRA-ADM-SEC-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-STENO-CITY','Stenographer','LGSS/12',7,3,'HRA-ADM-STEN-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-TYPIST-CITY','Typist','LGSS/14',7,3,'HRA-ADM-TYP-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-HEAD-DRIVER-CITY','Head Driver','G1',1,3,'HRA-ADM-HDDRV-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-DRIVER-CITY','Driver','G1',24,3,'HRA-ADM-DRV-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-ORDERLY-CITY','Office Orderly','G3',20,3,'HRA-ADM-ORD-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-WATCHMAN-CITY','Watchman','G3',15,3,'HRA-SEC-WATCH-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-GW-CITY','General Worker','G3',95,3,'HRA-ADM-GEN-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-REG-SUP-CITY','Registry Supervisor','LGSS/14',3,3,'HRA-ADM-SUP-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-REG-CLERK-CITY','Registry Clerk','LGSS/17',16,3,'HRA-ADM-REG-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-CH-COMM-CITY','Chief Committee Clerk','LGSS/06',1,3,'HRA-COM-CHIEF-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-COMM-CITY','Senior Committee Clerk','LGSS/08',2,3,'HRA-COM-SNR-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-COMM-CLERK-CITY','Committee Clerk','LGSS/10',7,3,'HRA-COM-CLK-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-ASST-COMM-CITY','Assistant Committee Clerk','LGSS/12',5,3,'HRA-COM-AST-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-CH-SEC-CITY','Chief Security Officer','LGSS/06',1,3,'HRA-SEC-CHIEF-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SNR-SEC-CITY','Senior Security Officer','LGSS/08',1,3,'HRA-SEC-SNR-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SEC-OFFICER-CITY','Security Officer','LGSS/10',2,3,'HRA-SEC-OFF-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SERGEANT-CITY','Town Sergeant','LGSS/12',2,3,'HRA-SEC-SGT-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-INSPECTOR-CITY','Inspector','LGSS/14',4,3,'HRA-SEC-INSP-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-SUB-INSPECTOR-CITY','Sub Inspector','LGSS/14',15,3,'HRA-SEC-SUB-CIT-01');
INSERT INTO HRA_Positions VALUES('HRA-POLICE-CITY','Police Constable','G1',65,3,'HRA-SEC-PC-CIT-01');
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
INSERT INTO hra_position_supervisors VALUES('HR-CHRO-TOWN','HR-DIR-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SNR-HRO-TOWN','HR-CHRO-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-HRO-TOWN','HR-SNR-HRO-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-HRM-HEALTH-TOWN','HR-DIR-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-HRM-FISH-TOWN','HR-DIR-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-CH-ADMIN-TOWN','HR-DIR-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-ADMIN-TOWN','HR-CH-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SEC-TOWN','HR-CH-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-STENO-TOWN','HR-CH-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-TYPIST-TOWN','HR-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-ORDERLY-TOWN','HR-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-DRIVER-TOWN','HR-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-COMM-CLERK-TOWN','HR-CH-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-ASST-COMM-TOWN','HR-COMM-CLERK-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-REG-SUP-TOWN','HR-ADMIN-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-REG-CLERK-TOWN','HR-REG-SUP-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SNR-SEC-TOWN','HR-DIR-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SEC-OFFICER-TOWN','HR-SNR-SEC-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SERGEANT-TOWN','HR-SNR-SEC-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-SUB-INSPECTOR-TOWN','HR-SNR-SEC-TOWN','Town');
INSERT INTO hra_position_supervisors VALUES('HR-POLICE-TOWN','HR-SNR-SEC-TOWN','Town');
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
INSERT INTO hra_leave_approval_chain VALUES('HR-SNR-HRO-TOWN','Officer → Supervisor (HR-CHRO-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-HRO-TOWN','Officer → Supervisor (HR-SNR-HRO-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-HRM-HEALTH-TOWN','Officer → Supervisor (HR-DIR-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-HRM-FISH-TOWN','Officer → Supervisor (HR-DIR-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-CH-ADMIN-TOWN','Officer → Supervisor (HR-DIR-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-ADMIN-TOWN','Officer → Supervisor (HR-CH-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SEC-TOWN','Officer → Supervisor (HR-CH-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-STENO-TOWN','Officer → Supervisor (HR-CH-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-TYPIST-TOWN','Officer → Supervisor (HR-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-ORDERLY-TOWN','Officer → Supervisor (HR-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-DRIVER-TOWN','Officer → Supervisor (HR-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-COMM-CLERK-TOWN','Officer → Supervisor (HR-CH-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-ASST-COMM-TOWN','Officer → Supervisor (HR-COMM-CLERK-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-REG-SUP-TOWN','Officer → Supervisor (HR-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-REG-CLERK-TOWN','Officer → Supervisor (HR-ADMIN-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SNR-SEC-TOWN','Officer → Supervisor (HR-DIR-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SEC-OFFICER-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SERGEANT-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-SUB-INSPECTOR-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
INSERT INTO hra_leave_approval_chain VALUES('HR-POLICE-TOWN','Officer → Supervisor (HR-SNR-SEC-TOWN) → HoD (HR-DIR-TOWN) → Council Secretary','Town');
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
INSERT INTO positions VALUES('HRA-SEC-MUN','Personal Secretary',3,'LGSS/10',1,'HRA-ADMIN-MUN',5,0,2);
INSERT INTO positions VALUES('HRA-STENO-MUN','Stenographer',3,'LGSS/12',2,'HRA-ADMIN-MUN',5,0,2);
INSERT INTO positions VALUES('HRA-TYPIST-MUN','Typist',3,'LGSS/14',9,'HRA-ADMIN-MUN',5,0,2);
INSERT INTO positions VALUES('HRA-HEAD-DRIVER-MUN','Head Driver',3,'G1',1,'HRA-ADMIN-MUN',5,0,2);
INSERT INTO positions VALUES('HRA-DRIVER-MUN','Driver',3,'G1',24,'HRA-ADMIN-MUN',6,0,2);
INSERT INTO positions VALUES('HRA-ORDERLY-MUN','Office Orderly',3,'G3',20,'HRA-ADMIN-MUN',6,0,2);
INSERT INTO positions VALUES('HRA-WATCHMAN-MUN','Watchman',3,'G3',15,'HRA-ADMIN-MUN',6,0,2);
INSERT INTO positions VALUES('HRA-REG-SUP-MUN','Registry Supervisor',4,'LGSS/14',2,'HRA-ADMIN-MUN',5,1,2);
INSERT INTO positions VALUES('HRA-REG-CLERK-MUN','Registry Clerk',4,'LGSS/17',15,'HRA-REG-SUP-MUN',6,0,2);
INSERT INTO positions VALUES('HRA-CH-COMM-MUN','Chief Committee Clerk',5,'LGSS/06',1,'HRA-DIR-MUN',2,1,2);
INSERT INTO positions VALUES('HRA-SNR-COMM-MUN','Senior Committee Clerk',5,'LGSS/08',1,'HRA-CH-COMM-MUN',3,0,2);
INSERT INTO positions VALUES('HRA-COMM-CLERK-MUN','Committee Clerk',5,'LGSS/10',3,'HRA-SNR-COMM-MUN',4,0,2);
INSERT INTO positions VALUES('HRA-ASST-COMM-MUN','Assistant Committee Clerk',5,'LGSS/12',2,'HRA-COMM-CLERK-MUN',5,0,2);
INSERT INTO positions VALUES('HRA-CH-SEC-MUN','Chief Security Officer',6,'LGSS/06',1,'HRA-DIR-MUN',2,1,2);
INSERT INTO positions VALUES('HRA-SNR-SEC-MUN','Senior Security Officer',6,'LGSS/07',1,'HRA-CH-SEC-MUN',3,0,2);
INSERT INTO positions VALUES('HRA-SEC-OFFICER-MUN','Security Officer',6,'LGSS/08',1,'HRA-SNR-SEC-MUN',4,0,2);
INSERT INTO positions VALUES('HRA-SERGEANT-MUN','Town Sergeant',6,'LGSS/10',2,'HRA-SNR-SEC-MUN',4,0,2);
INSERT INTO positions VALUES('HRA-INSPECTOR-MUN','Inspector',6,'LGSS/12',2,'HRA-SNR-SEC-MUN',4,0,2);
INSERT INTO positions VALUES('HRA-SUB-INSPECTOR-MUN','Sub Inspector',6,'LGSS/14',4,'HRA-SNR-SEC-MUN',4,0,2);
INSERT INTO positions VALUES('HRA-POLICE-MUN','Police Constable',6,'G1',65,'HRA-SNR-SEC-MUN',5,0,2);
INSERT INTO positions VALUES('HRA-DIR-CITY','Director of Human Resource & Administration',7,'LGSS/03',1,NULL,1,1,3);
INSERT INTO positions VALUES('HRA-ADIR-HRMDEV-CITY','Assistant Director – HR Management & Development',8,'LGSS/05',1,'HRA-DIR-CITY',2,1,3);
INSERT INTO positions VALUES('HRA-CHRO-CITY','Chief Human Resource Officer',8,'LGSS/06',1,'HRA-ADIR-HRMDEV-CITY',3,0,3);
INSERT INTO positions VALUES('HRA-SNR-HRO-CITY','Senior Human Resource Officer',8,'LGSS/07',3,'HRA-CHRO-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-HRO-CITY','Human Resource Officer',8,'LGSS/08',10,'HRA-SNR-HRO-CITY',5,0,3);
INSERT INTO positions VALUES('HRA-ADIR-ADMIN-CITY','Assistant Director – Administration',9,'LGSS/05',1,'HRA-DIR-CITY',2,1,3);
INSERT INTO positions VALUES('HRA-CH-ADMIN-CITY','Chief Administrative Officer',10,'LGSS/06',1,'HRA-ADIR-ADMIN-CITY',3,1,3);
INSERT INTO positions VALUES('HRA-SNR-ADMIN-CITY','Senior Administrative Officer',10,'LGSS/07',8,'HRA-CH-ADMIN-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-ADMIN-CITY','Administrative Officer',10,'LGSS/08',8,'HRA-SNR-ADMIN-CITY',5,0,3);
INSERT INTO positions VALUES('HRA-SNR-PRINT-CITY','Senior Printing Officer',10,'LGSS/08',1,'HRA-CH-ADMIN-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-PRINT-CITY','Printing Officer',10,'LGSS/10',1,'HRA-SNR-PRINT-CITY',5,0,3);
INSERT INTO positions VALUES('HRA-SEC-CITY','Personal Secretary',10,'LGSS/11',1,'HRA-ADMIN-CITY',6,0,3);
INSERT INTO positions VALUES('HRA-STENO-CITY','Stenographer',10,'LGSS/12',7,'HRA-ADMIN-CITY',6,0,3);
INSERT INTO positions VALUES('HRA-TYPIST-CITY','Typist',10,'LGSS/14',7,'HRA-ADMIN-CITY',6,0,3);
INSERT INTO positions VALUES('HRA-HEAD-DRIVER-CITY','Head Driver',10,'G1',1,'HRA-ADMIN-CITY',6,0,3);
INSERT INTO positions VALUES('HRA-DRIVER-CITY','Driver',10,'G1',24,'HRA-ADMIN-CITY',7,0,3);
INSERT INTO positions VALUES('HRA-ORDERLY-CITY','Office Orderly',10,'G3',20,'HRA-ADMIN-CITY',7,0,3);
INSERT INTO positions VALUES('HRA-WATCHMAN-CITY','Watchman',10,'G3',15,'HRA-ADMIN-CITY',7,0,3);
INSERT INTO positions VALUES('HRA-GW-CITY','General Worker',10,'G3',95,'HRA-ADMIN-CITY',7,0,3);
INSERT INTO positions VALUES('HRA-REG-SUP-CITY','Registry Supervisor',11,'LGSS/14',3,'HRA-ADMIN-CITY',6,1,3);
INSERT INTO positions VALUES('HRA-REG-CLERK-CITY','Registry Clerk',11,'LGSS/17',16,'HRA-REG-SUP-CITY',7,0,3);
INSERT INTO positions VALUES('HRA-CH-COMM-CITY','Chief Committee Clerk',12,'LGSS/06',1,'HRA-DIR-CITY',2,1,3);
INSERT INTO positions VALUES('HRA-SNR-COMM-CITY','Senior Committee Clerk',12,'LGSS/08',2,'HRA-CH-COMM-CITY',3,0,3);
INSERT INTO positions VALUES('HRA-COMM-CLERK-CITY','Committee Clerk',12,'LGSS/10',7,'HRA-SNR-COMM-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-ASST-COMM-CITY','Assistant Committee Clerk',12,'LGSS/12',5,'HRA-COMM-CLERK-CITY',5,0,3);
INSERT INTO positions VALUES('HRA-CH-SEC-CITY','Chief Security Officer',13,'LGSS/06',1,'HRA-DIR-CITY',2,1,3);
INSERT INTO positions VALUES('HRA-SNR-SEC-CITY','Senior Security Officer',13,'LGSS/08',1,'HRA-CH-SEC-CITY',3,0,3);
INSERT INTO positions VALUES('HRA-SEC-OFFICER-CITY','Security Officer',13,'LGSS/10',2,'HRA-SNR-SEC-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-SERGEANT-CITY','Town Sergeant',13,'LGSS/12',2,'HRA-SNR-SEC-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-INSPECTOR-CITY','Inspector',13,'LGSS/14',4,'HRA-SNR-SEC-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-SUB-INSPECTOR-CITY','Sub Inspector',13,'LGSS/14',15,'HRA-SNR-SEC-CITY',4,0,3);
INSERT INTO positions VALUES('HRA-POLICE-CITY','Police Constable',13,'G1',65,'HRA-SNR-SEC-CITY',5,0,3);
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
INSERT INTO leave_approval_chain VALUES(13,'HRA-HRO-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(14,'HRA-CH-ADMIN-MUN',1,'Supervisor','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(15,'HRA-CH-ADMIN-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(16,'HRA-CH-ADMIN-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(17,'HRA-SNR-ADMIN-MUN',1,'Supervisor','HRA-CH-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(18,'HRA-SNR-ADMIN-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(19,'HRA-SNR-ADMIN-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(20,'HRA-ADMIN-MUN',1,'Supervisor','HRA-SNR-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(21,'HRA-ADMIN-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(22,'HRA-ADMIN-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(23,'HRA-DRIVER-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(24,'HRA-HEAD-DRIVER-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(25,'HRA-ORDERLY-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(26,'HRA-REG-SUP-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(27,'HRA-SEC-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(28,'HRA-STENO-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(29,'HRA-TYPIST-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(30,'HRA-WATCHMAN-MUN',1,'Supervisor','HRA-ADMIN-MUN');
INSERT INTO leave_approval_chain VALUES(31,'HRA-DRIVER-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(32,'HRA-HEAD-DRIVER-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(33,'HRA-ORDERLY-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(34,'HRA-REG-SUP-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(35,'HRA-SEC-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(36,'HRA-STENO-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(37,'HRA-TYPIST-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(38,'HRA-WATCHMAN-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(39,'HRA-DRIVER-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(40,'HRA-HEAD-DRIVER-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(41,'HRA-ORDERLY-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(42,'HRA-REG-SUP-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(43,'HRA-SEC-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(44,'HRA-STENO-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(45,'HRA-TYPIST-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(46,'HRA-WATCHMAN-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(47,'HRA-REG-CLERK-MUN',1,'Supervisor','HRA-REG-SUP-MUN');
INSERT INTO leave_approval_chain VALUES(48,'HRA-REG-CLERK-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(49,'HRA-REG-CLERK-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(50,'HRA-CH-COMM-MUN',1,'Supervisor','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(51,'HRA-CH-COMM-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(52,'HRA-CH-COMM-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(53,'HRA-SNR-COMM-MUN',1,'Supervisor','HRA-CH-COMM-MUN');
INSERT INTO leave_approval_chain VALUES(54,'HRA-SNR-COMM-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(55,'HRA-SNR-COMM-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(56,'HRA-COMM-CLERK-MUN',1,'Supervisor','HRA-SNR-COMM-MUN');
INSERT INTO leave_approval_chain VALUES(57,'HRA-COMM-CLERK-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(58,'HRA-COMM-CLERK-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(59,'HRA-ASST-COMM-MUN',1,'Supervisor','HRA-COMM-CLERK-MUN');
INSERT INTO leave_approval_chain VALUES(60,'HRA-ASST-COMM-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(61,'HRA-ASST-COMM-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(62,'HRA-CH-SEC-MUN',1,'Supervisor','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(63,'HRA-CH-SEC-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(64,'HRA-CH-SEC-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(65,'HRA-SNR-SEC-MUN',1,'Supervisor','HRA-CH-SEC-MUN');
INSERT INTO leave_approval_chain VALUES(66,'HRA-SNR-SEC-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(67,'HRA-SNR-SEC-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(68,'HRA-INSPECTOR-MUN',1,'Supervisor','HRA-SNR-SEC-MUN');
INSERT INTO leave_approval_chain VALUES(69,'HRA-POLICE-MUN',1,'Supervisor','HRA-SNR-SEC-MUN');
INSERT INTO leave_approval_chain VALUES(70,'HRA-SEC-OFFICER-MUN',1,'Supervisor','HRA-SNR-SEC-MUN');
INSERT INTO leave_approval_chain VALUES(71,'HRA-SERGEANT-MUN',1,'Supervisor','HRA-SNR-SEC-MUN');
INSERT INTO leave_approval_chain VALUES(72,'HRA-SUB-INSPECTOR-MUN',1,'Supervisor','HRA-SNR-SEC-MUN');
INSERT INTO leave_approval_chain VALUES(73,'HRA-INSPECTOR-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(74,'HRA-POLICE-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(75,'HRA-SEC-OFFICER-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(76,'HRA-SERGEANT-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(77,'HRA-SUB-INSPECTOR-MUN',2,'HoD','HRA-DIR-MUN');
INSERT INTO leave_approval_chain VALUES(78,'HRA-INSPECTOR-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(79,'HRA-POLICE-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(80,'HRA-SEC-OFFICER-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(81,'HRA-SERGEANT-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(82,'HRA-SUB-INSPECTOR-MUN',3,'Municipal Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(83,'HRA-DIR-CITY',1,'Supervisor',NULL);
INSERT INTO leave_approval_chain VALUES(84,'HRA-DIR-CITY',2,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(85,'HRA-DIR-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(86,'HRA-DIR-CITY',4,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(87,'HRA-ADIR-HRMDEV-CITY',1,'Supervisor','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(88,'HRA-ADIR-HRMDEV-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(89,'HRA-ADIR-HRMDEV-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(90,'HRA-ADIR-ADMIN-CITY',1,'Supervisor','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(91,'HRA-ADIR-ADMIN-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(92,'HRA-ADIR-ADMIN-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(93,'HRA-CHRO-CITY',1,'Supervisor','HRA-ADIR-HRMDEV-CITY');
INSERT INTO leave_approval_chain VALUES(94,'HRA-CHRO-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(95,'HRA-CHRO-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(96,'HRA-SNR-HRO-CITY',1,'Supervisor','HRA-CHRO-CITY');
INSERT INTO leave_approval_chain VALUES(97,'HRA-SNR-HRO-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(98,'HRA-SNR-HRO-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(99,'HRA-HRO-CITY',1,'Supervisor','HRA-SNR-HRO-CITY');
INSERT INTO leave_approval_chain VALUES(100,'HRA-HRO-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(101,'HRA-HRO-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(102,'HRA-CH-ADMIN-CITY',1,'Supervisor','HRA-ADIR-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(103,'HRA-CH-ADMIN-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(104,'HRA-CH-ADMIN-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(105,'HRA-SNR-ADMIN-CITY',1,'Supervisor','HRA-CH-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(106,'HRA-SNR-ADMIN-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(107,'HRA-SNR-ADMIN-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(108,'HRA-ADMIN-CITY',1,'Supervisor','HRA-SNR-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(109,'HRA-ADMIN-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(110,'HRA-ADMIN-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(111,'HRA-SNR-PRINT-CITY',1,'Supervisor','HRA-CH-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(112,'HRA-SNR-PRINT-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(113,'HRA-SNR-PRINT-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(114,'HRA-PRINT-CITY',1,'Supervisor','HRA-SNR-PRINT-CITY');
INSERT INTO leave_approval_chain VALUES(115,'HRA-PRINT-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(116,'HRA-PRINT-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(117,'HRA-DRIVER-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(118,'HRA-GW-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(119,'HRA-HEAD-DRIVER-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(120,'HRA-ORDERLY-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(121,'HRA-REG-SUP-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(122,'HRA-SEC-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(123,'HRA-STENO-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(124,'HRA-TYPIST-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(125,'HRA-WATCHMAN-CITY',1,'Supervisor','HRA-ADMIN-CITY');
INSERT INTO leave_approval_chain VALUES(126,'HRA-DRIVER-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(127,'HRA-GW-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(128,'HRA-HEAD-DRIVER-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(129,'HRA-ORDERLY-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(130,'HRA-REG-SUP-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(131,'HRA-SEC-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(132,'HRA-STENO-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(133,'HRA-TYPIST-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(134,'HRA-WATCHMAN-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(135,'HRA-DRIVER-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(136,'HRA-GW-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(137,'HRA-HEAD-DRIVER-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(138,'HRA-ORDERLY-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(139,'HRA-REG-SUP-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(140,'HRA-SEC-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(141,'HRA-STENO-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(142,'HRA-TYPIST-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(143,'HRA-WATCHMAN-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(144,'HRA-REG-CLERK-CITY',1,'Supervisor','HRA-REG-SUP-CITY');
INSERT INTO leave_approval_chain VALUES(145,'HRA-REG-CLERK-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(146,'HRA-REG-CLERK-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(147,'HRA-CH-COMM-CITY',1,'Supervisor','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(148,'HRA-CH-COMM-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(149,'HRA-CH-COMM-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(150,'HRA-SNR-COMM-CITY',1,'Supervisor','HRA-CH-COMM-CITY');
INSERT INTO leave_approval_chain VALUES(151,'HRA-SNR-COMM-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(152,'HRA-SNR-COMM-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(153,'HRA-COMM-CLERK-CITY',1,'Supervisor','HRA-SNR-COMM-CITY');
INSERT INTO leave_approval_chain VALUES(154,'HRA-COMM-CLERK-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(155,'HRA-COMM-CLERK-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(156,'HRA-ASST-COMM-CITY',1,'Supervisor','HRA-COMM-CLERK-CITY');
INSERT INTO leave_approval_chain VALUES(157,'HRA-ASST-COMM-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(158,'HRA-ASST-COMM-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(159,'HRA-CH-SEC-CITY',1,'Supervisor','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(160,'HRA-CH-SEC-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(161,'HRA-CH-SEC-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(162,'HRA-SNR-SEC-CITY',1,'Supervisor','HRA-CH-SEC-CITY');
INSERT INTO leave_approval_chain VALUES(163,'HRA-SNR-SEC-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(164,'HRA-SNR-SEC-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(165,'HRA-INSPECTOR-CITY',1,'Supervisor','HRA-SNR-SEC-CITY');
INSERT INTO leave_approval_chain VALUES(166,'HRA-POLICE-CITY',1,'Supervisor','HRA-SNR-SEC-CITY');
INSERT INTO leave_approval_chain VALUES(167,'HRA-SEC-OFFICER-CITY',1,'Supervisor','HRA-SNR-SEC-CITY');
INSERT INTO leave_approval_chain VALUES(168,'HRA-SERGEANT-CITY',1,'Supervisor','HRA-SNR-SEC-CITY');
INSERT INTO leave_approval_chain VALUES(169,'HRA-SUB-INSPECTOR-CITY',1,'Supervisor','HRA-SNR-SEC-CITY');
INSERT INTO leave_approval_chain VALUES(170,'HRA-INSPECTOR-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(171,'HRA-POLICE-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(172,'HRA-SEC-OFFICER-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(173,'HRA-SERGEANT-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(174,'HRA-SUB-INSPECTOR-CITY',2,'HoD','HRA-DIR-CITY');
INSERT INTO leave_approval_chain VALUES(175,'HRA-INSPECTOR-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(176,'HRA-POLICE-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(177,'HRA-SEC-OFFICER-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(178,'HRA-SERGEANT-CITY',3,'Town Clerk',NULL);
INSERT INTO leave_approval_chain VALUES(179,'HRA-SUB-INSPECTOR-CITY',3,'Town Clerk',NULL);
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
INSERT INTO eng_units VALUES(13,'Council Administration','MC-ADMIN',NULL,2);
INSERT INTO eng_units VALUES(14,'Engineering Department','MC-ENG-DEPT',NULL,2);
INSERT INTO eng_units VALUES(15,'Construction & Maintenance Section','MC-CONSTR',NULL,2);
INSERT INTO eng_units VALUES(16,'Electrical Engineering Unit','MC-ELEC',NULL,2);
INSERT INTO eng_units VALUES(17,'Quantity Surveying Unit','MC-QS',NULL,2);
INSERT INTO eng_units VALUES(18,'Architecture Unit','MC-ARCH',NULL,2);
INSERT INTO eng_units VALUES(19,'Maintenance Unit','MC-MAINT',NULL,2);
INSERT INTO eng_units VALUES(20,'Parks & Gardens Unit','MC-PARK',NULL,2);
INSERT INTO eng_units VALUES(21,'Mechanical Services Unit','MC-MECH',NULL,2);
INSERT INTO eng_units VALUES(22,'Roads & Drainages Section','MC-ROADS',NULL,2);
INSERT INTO eng_units VALUES(23,'Fire & Rescue Services Unit','MC-FIRE',NULL,2);
INSERT INTO eng_units VALUES(24,'Rural Water & Sanitation Unit','MC-WATSAN',NULL,2);
INSERT INTO eng_units VALUES(25,'Council Administration','CC-ADMIN',NULL,3);
INSERT INTO eng_units VALUES(26,'Engineering Department','CC-ENG-DEPT',NULL,3);
INSERT INTO eng_units VALUES(27,'Construction & Maintenance Section','CC-CONSTR',NULL,3);
INSERT INTO eng_units VALUES(28,'Electrical Engineering Unit','CC-ELEC',NULL,3);
INSERT INTO eng_units VALUES(29,'Quantity Surveying Unit','CC-QS',NULL,3);
INSERT INTO eng_units VALUES(30,'Architecture Unit','CC-ARCH',NULL,3);
INSERT INTO eng_units VALUES(31,'Maintenance Unit','CC-MAINT',NULL,3);
INSERT INTO eng_units VALUES(32,'Parks & Gardens Unit','CC-PARK',NULL,3);
INSERT INTO eng_units VALUES(33,'Mechanical Services Unit','CC-MECH',NULL,3);
INSERT INTO eng_units VALUES(34,'Roads & Drainages Section','CC-ROADS',NULL,3);
INSERT INTO eng_units VALUES(35,'Fire & Rescue Services Unit','CC-FIRE',NULL,3);
INSERT INTO eng_units VALUES(36,'Rural Water & Sanitation Unit','CC-WATSAN',NULL,3);
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
INSERT INTO eng_positions VALUES('ENG-ELEC-TECH-TC','Electrician','LGSS14',2,'ENG-ELEC-HEAD-TC',3,1,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-SUP-TC','Maintenance Superintendent','LGSS10',1,'ENG-ASST-DIR-TC',4,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-PLUM-TC','Plumber','LGSS15',2,'ENG-MAINT-SUP-TC',4,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-BRICK-TC','Bricklayer','LGSS15',2,'ENG-MAINT-SUP-TC',4,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CARP-TC','Carpenter','LGSS15',2,'ENG-MAINT-SUP-TC',4,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PAINT-TC','Painter','LGSS15',1,'ENG-MAINT-SUP-TC',4,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-GENWORK-TC','General Worker','G3',3,'ENG-MAINT-SUP-TC',4,1,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-TC','Quantity Surveyor','LGSS07',1,'ENG-ASST-DIR-TC',5,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-ASST-TC','Assistant Quantity Surveyor','LGSS10',2,'ENG-QSURV-TC',5,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-TC','Architect','LGSS07',1,'ENG-ASST-DIR-TC',6,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-ASST-TC','Assistant Architect','LGSS10',2,'ENG-ARCH-TC',6,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CLERK-TC','Senior Clerk of Works','LGSS10',1,'ENG-ARCH-TC',6,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-DRAFT-TC','Draughtsman','LGSS15',1,'ENG-ARCH-TC',6,1,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-MGR-TC','Parks Manager','LGSS07',1,'ENG-ASST-DIR-TC',7,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-SUP-TC','Parks Supervisor','LGSS15',1,'ENG-PARK-MGR-TC',7,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-WORK-TC','General Worker','G1',4,'ENG-PARK-SUP-TC',7,1,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-TC','Civil Engineer','LGSS07',1,'ENG-ASST-DIR-TC',8,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASST-TC','Assistant Civil Engineer','LGSS10',2,'ENG-CIVIL-TC',8,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-TECH-TC','Engineering Assistant','LGSS14',2,'ENG-CIVIL-TC',8,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-TC','Mechanical Engineer','LGSS07',1,'ENG-ASST-DIR-TC',9,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASST-TC','Assistant Mechanical Engineer','LGSS10',1,'ENG-MECH-TC',10,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MOTOR-TC','Motor Vehicle Examiner','LGSS11',1,'ENG-MECH-TC',10,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-AUTO-TC','Auto Electrician','LGSS14',1,'ENG-MECH-TC',10,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-TECH-TC','Mechanic','LGSS14',2,'ENG-MECH-TC',10,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-EXCAV-TC','Excavator Operator','LGSS14',1,'ENG-MECH-TC',10,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-SCALER-TC','Scaler Operator','LGSS14',1,'ENG-MECH-TC',10,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-HANDY-TC','Mechanical Handyman','G1',2,'ENG-MECH-TC',10,1,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-WELDER-TC','Welder','LGSS15',1,'ENG-MECH-TC',10,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DIV-TC','Divisional Fire Officer','LGSS08',1,'ENG-ASST-DIR-TC',11,1,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-STN-TC','Station Officer','LGSS11',1,'ENG-FIRE-DIV-TC',11,1,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-SUB-TC','Sub-Officer','LGSS12',1,'ENG-FIRE-STN-TC',11,1,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-LEAD-TC','Leading Firefighter','LGSS13',2,'ENG-FIRE-STN-TC',11,1,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-TC','Firefighter','LGSS14',4,'ENG-FIRE-LEAD-TC',11,1,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DRV-TC','Fire Fighter Driver','LGSS14',2,'ENG-FIRE-LEAD-TC',11,1,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-WATSAN-TC','Water and Sanitation Engineer','LGSS07',1,'ENG-ASST-DIR-TC',12,1,4,1,NULL);
INSERT INTO eng_positions VALUES('TOWN-CLERK-MC','Town Clerk','LGSS02',1,NULL,13,2,1,1,NULL);
INSERT INTO eng_positions VALUES('ENG-DIR-MC','Director - Engineering','LGSS04',1,'TOWN-CLERK-MC',14,2,2,1,NULL);
INSERT INTO eng_positions VALUES('ENG-CONSTR-ASSTDIR-MC','Assistant Director - Construction & Maintenance','LGSS05',1,'ENG-DIR-MC',15,2,3,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ROADS-ASSTDIR-MC','Assistant Director - Roads & Drainages','LGSS05',1,'ENG-DIR-MC',22,2,3,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-CHIEF-MC','Chief Electrical Engineer','LGSS06',1,'ENG-CONSTR-ASSTDIR-MC',16,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ENG07-MC','Electrical Engineer','LGSS07',1,'ENG-ELEC-CHIEF-MC',16,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ASST-MC','Assistant Electrical Engineer','LGSS10',1,'ENG-ELEC-CHIEF-MC',16,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-SUPT-MC','Superintendent','LGSS12',1,'ENG-ELEC-CHIEF-MC',16,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ASSTSUPT-MC','Assistant Superintendent','LGSS13',1,'ENG-ELEC-SUPT-MC',16,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-SENASSIST-MC','Senior Engineering Assistant','LGSS13',1,'ENG-ELEC-SUPT-MC',16,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-WORKSUP-MC','Works Supervisor','LGSS14',1,'ENG-ELEC-SUPT-MC',16,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-TECH-MC','Electrician','LGSS14',5,'ENG-ELEC-WORKSUP-MC',16,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-FOREMAN-MC','Foreman','LGSS14',1,'ENG-ELEC-WORKSUP-MC',16,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ASSTFORE-MC','Assistant Foreman','LGSS17',1,'ENG-ELEC-FOREMAN-MC',16,2,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-CHIEF-MC','Chief Quantity Surveyor','LGSS06',1,'ENG-CONSTR-ASSTDIR-MC',17,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV07-MC','Quantity Surveyor','LGSS07',3,'ENG-QSURV-CHIEF-MC',17,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-ASST-MC','Assistant Quantity Surveyor','LGSS10',3,'ENG-QSURV07-MC',17,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-SENASSIST-MC','Senior Quantity Surveying Assistant','LGSS13',1,'ENG-QSURV-ASST-MC',17,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-ASSIST-MC','Quantity Surveying Assistant','LGSS14',1,'ENG-QSURV-ASST-MC',17,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-CHIEF-MC','Chief Architect','LGSS06',1,'ENG-CONSTR-ASSTDIR-MC',18,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH07-MC','Architect','LGSS07',3,'ENG-ARCH-CHIEF-MC',18,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-ASST-MC','Assistant Architect','LGSS10',2,'ENG-ARCH07-MC',18,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-ASSIST-MC','Architectural Assistant','LGSS14',1,'ENG-ARCH-ASST-MC',18,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-FOREMAN-MC','Foreman','LGSS14',2,'ENG-ARCH-ASST-MC',18,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-ASSTFORE-MC','Assistant Foreman','LGSS17',2,'ENG-ARCH-FOREMAN-MC',18,2,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-SENCLERK-MC','Senior Clerk of Works','LGSS10',2,'ENG-ARCH07-MC',18,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-CLERK-MC','Clerk of Works','LGSS12',2,'ENG-ARCH-SENCLERK-MC',18,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-DRAFT-MC','Draughtsman','LGSS15',1,'ENG-ARCH07-MC',18,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-SUPT-MC','Maintenance Superintendent','LGSS10',1,'ENG-CONSTR-ASSTDIR-MC',19,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-ASSTSUPT-MC','Assistant Superintendent','LGSS12',1,'ENG-MAINT-SUPT-MC',19,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-FOREMAN-MC','Foreman','LGSS14',2,'ENG-MAINT-SUPT-MC',19,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-PLUM-MC','Plumber','LGSS15',2,'ENG-MAINT-FOREMAN-MC',19,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-BRICK-MC','Bricklayer','LGSS15',2,'ENG-MAINT-FOREMAN-MC',19,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-CARP-MC','Carpenter','LGSS15',2,'ENG-MAINT-FOREMAN-MC',19,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-PAINT-MC','Painter','LGSS15',1,'ENG-MAINT-FOREMAN-MC',19,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-GENWORK-MC','General Worker','G3',4,'ENG-MAINT-FOREMAN-MC',19,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-MGR-MC','Parks Manager','LGSS07',1,'ENG-CONSTR-ASSTDIR-MC',20,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-SUPT-MC','Superintendent','LGSS12',1,'ENG-PARK-MGR-MC',20,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-ASSTSUPT-MC','Assistant Superintendent','LGSS13',1,'ENG-PARK-SUPT-MC',20,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-FOREMAN-MC','Parks Foreman','LGSS14',1,'ENG-PARK-SUPT-MC',20,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-SUP-MC','Parks Supervisor','LGSS15',1,'ENG-PARK-FOREMAN-MC',20,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-ASSTFORE-MC','Assistant Parks Foreman','LGSS17',1,'ENG-PARK-FOREMAN-MC',20,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-WORK-MC','General Worker','G1',7,'ENG-PARK-SUP-MC',20,2,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-CHIEF-MC','Chief Mechanical Engineer','LGSS06',1,'ENG-CONSTR-ASSTDIR-MC',21,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH07-MC','Mechanical Engineer','LGSS07',1,'ENG-MECH-CHIEF-MC',21,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASST-MC','Assistant Mechanical Engineer','LGSS10',1,'ENG-MECH07-MC',21,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-SUPT-MC','Superintendent','LGSS12',1,'ENG-MECH07-MC',21,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASSTSUPT-MC','Assistant Superintendent','LGSS13',1,'ENG-MECH-SUPT-MC',21,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASSIST-MC','Engineering Assistant','LGSS14',3,'ENG-MECH-SUPT-MC',21,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-AUTO-MC','Auto Electrician','LGSS14',1,'ENG-MECH-SUPT-MC',21,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-TECH-MC','Mechanic','LGSS14',4,'ENG-MECH-SUPT-MC',21,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-FOREMAN-MC','Foreman','LGSS14',1,'ENG-MECH-SUPT-MC',21,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASSTFORE-MC','Assistant Foreman','LGSS17',1,'ENG-MECH-FOREMAN-MC',21,2,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-PLANT-MC','Plant Operator','LGSS14',16,'ENG-MECH-SUPT-MC',21,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-HANDY-MC','Mechanical Handyman','LGSS18',3,'ENG-MECH-SUPT-MC',21,2,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-WELDER-MC','Welder','LGSS14',1,'ENG-MECH-SUPT-MC',21,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-CHIEF-MC','Chief Civil Engineer','LGSS06',1,'ENG-ROADS-ASSTDIR-MC',22,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL07-MC','Civil Engineer','LGSS07',4,'ENG-CIVIL-CHIEF-MC',22,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASST-MC','Assistant Civil Engineer','LGSS10',1,'ENG-CIVIL07-MC',22,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-HIGHWAY-MC','Superintendent – Highway','LGSS12',1,'ENG-CIVIL07-MC',22,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-SENASSIST-MC','Senior Engineering Assistant','LGSS13',1,'ENG-CIVIL07-MC',22,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASSIST-MC','Engineering Assistant','LGSS14',2,'ENG-CIVIL07-MC',22,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-FOREMAN-MC','Foreman','LGSS14',1,'ENG-CIVIL07-MC',22,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-DRAFT-MC','Draughtsman','LGSS15',1,'ENG-CIVIL07-MC',22,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASSTFORE-MC','Assistant Foreman','LGSS17',3,'ENG-CIVIL-FOREMAN-MC',22,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-CHIEF-MC','Chief Fire Officer','LGSS06',1,'ENG-DIR-MC',23,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DEPUTY-MC','Deputy Chief Fire Officer','LGSS07',2,'ENG-FIRE-CHIEF-MC',23,2,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DIV-MC','Divisional Fire Officer','LGSS09',2,'ENG-FIRE-DEPUTY-MC',23,2,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-ASSTDIV-MC','Assistant Divisional Fire Officer','LGSS10',2,'ENG-FIRE-DIV-MC',23,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-STN-MC','Station Fire Officer','LGSS11',4,'ENG-FIRE-DIV-MC',23,2,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-SUB-MC','Sub-Officer','LGSS12',6,'ENG-FIRE-STN-MC',23,2,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-LEAD-MC','Leading Firefighter','LGSS13',4,'ENG-FIRE-SUB-MC',23,2,9,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-MC','Firefighter','LGSS14',40,'ENG-FIRE-LEAD-MC',23,2,10,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DRV-MC','Fire Fighter Driver','LGSS14',7,'ENG-FIRE-LEAD-MC',23,2,10,0,NULL);
INSERT INTO eng_positions VALUES('ENG-WATSAN-COORD-MC','Rural Water and Sanitation Coordinator','LGSS06',1,'ENG-DIR-MC',24,2,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-WATSAN-ASST-MC','Assistant Water and Sanitation Engineer','LGSS07',1,'ENG-WATSAN-COORD-MC',24,2,5,0,NULL);
INSERT INTO eng_positions VALUES('CITY-CLERK-CC','Town Clerk','LGSS01',1,NULL,25,3,1,1,NULL);
INSERT INTO eng_positions VALUES('ENG-DIR-CC','Director - Engineering','LGSS03',1,'CITY-CLERK-CC',26,3,2,1,NULL);
INSERT INTO eng_positions VALUES('ENG-CONSTR-ASSTDIR-CC','Assistant Director - Construction & Maintenance','LGSS05',1,'ENG-DIR-CC',27,3,3,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ROADS-ASSTDIR-CC','Assistant Director - Roads & Drainages','LGSS05',1,'ENG-DIR-CC',34,3,3,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-CHIEF-CC','Chief Electrical Engineer','LGSS06',1,'ENG-CONSTR-ASSTDIR-CC',28,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ENG07-CC','Electrical Engineer','LGSS07',1,'ENG-ELEC-CHIEF-CC',28,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ASST-CC','Assistant Electrical Engineer','LGSS10',1,'ENG-ELEC-CHIEF-CC',28,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-SEN-SUPT-CC','Senior Electrical Superintendent','LGSS10',1,'ENG-ELEC-CHIEF-CC',28,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-SUPT-CC','Superintendent','LGSS12',1,'ENG-ELEC-CHIEF-CC',28,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ASSTSUPT-CC','Assistant Superintendent','LGSS13',2,'ENG-ELEC-SUPT-CC',28,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-SENASSIST-CC','Senior Engineering Assistant','LGSS13',1,'ENG-ELEC-SUPT-CC',28,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-WORKSUP-CC','Works Supervisor','LGSS14',2,'ENG-ELEC-SUPT-CC',28,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-TECH-CC','Electrician','LGSS14',5,'ENG-ELEC-WORKSUP-CC',28,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-FOREMAN-CC','Foreman','LGSS15',1,'ENG-ELEC-WORKSUP-CC',28,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ELEC-ASSTFORE-CC','Assistant Foreman','LGSS17',2,'ENG-ELEC-FOREMAN-CC',28,3,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-CHIEF-CC','Chief Quantity Surveyor','LGSS06',1,'ENG-CONSTR-ASSTDIR-CC',29,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV07-CC','Quantity Surveyor','LGSS07',2,'ENG-QSURV-CHIEF-CC',29,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-QSURV-ASST-CC','Assistant Quantity Surveyor','LGSS10',4,'ENG-QSURV07-CC',29,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-CHIEF-CC','Chief Architect','LGSS06',1,'ENG-CONSTR-ASSTDIR-CC',30,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH07-CC','Architect','LGSS07',5,'ENG-ARCH-CHIEF-CC',30,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-ASST-CC','Assistant Architect','LGSS10',5,'ENG-ARCH07-CC',30,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-ARCH-DRAFT-CC','Draughtsman','LGSS15',2,'ENG-ARCH07-CC',30,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-SUPT-CC','Maintenance Superintendent','LGSS10',1,'ENG-CONSTR-ASSTDIR-CC',31,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-ASSTSUPT-CC','Assistant Superintendent','LGSS13',1,'ENG-MAINT-SUPT-CC',31,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-ASSTSUPT2-CC','Assistant Superintendent','LGSS12',1,'ENG-MAINT-SUPT-CC',31,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-FOREMAN-CC','Foreman','LGSS14',2,'ENG-MAINT-SUPT-CC',31,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-PLUM-CC','Plumber','LGSS15',3,'ENG-MAINT-FOREMAN-CC',31,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-BRICK-CC','Bricklayer','LGSS15',3,'ENG-MAINT-FOREMAN-CC',31,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-CARP-CC','Carpenter','LGSS15',2,'ENG-MAINT-FOREMAN-CC',31,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-PAINT-CC','Painter','LGSS15',2,'ENG-MAINT-FOREMAN-CC',31,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MAINT-GENWORK-CC','General Worker','G3',6,'ENG-MAINT-FOREMAN-CC',31,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-MGR-CC','Parks & Gardens Manager','LGSS07',1,'ENG-DIR-CC',32,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-SUPT-CC','Superintendent','LGSS12',1,'ENG-PARK-MGR-CC',32,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-ASSTSUPT-CC','Assistant Superintendent','LGSS13',2,'ENG-PARK-SUPT-CC',32,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-FOREMAN-CC','Parks Foreman','LGSS14',4,'ENG-PARK-SUPT-CC',32,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-SUP-CC','Parks Supervisor','LGSS15',4,'ENG-PARK-FOREMAN-CC',32,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-ASSTFORE-CC','Assistant Parks Foreman','LGSS17',4,'ENG-PARK-FOREMAN-CC',32,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-PARK-WORK-CC','General Worker','G1',7,'ENG-PARK-SUP-CC',32,3,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-CHIEF-CC','Chief Mechanical Engineer','LGSS06',1,'ENG-DIR-CC',33,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH07-CC','Mechanical Engineer','LGSS07',1,'ENG-MECH-CHIEF-CC',33,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASST-CC','Assistant Mechanical Engineer','LGSS10',2,'ENG-MECH07-CC',33,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-SUPT-CC','Superintendent','LGSS12',1,'ENG-MECH07-CC',33,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASSTSUPT-CC','Assistant Superintendent','LGSS13',2,'ENG-MECH-SUPT-CC',33,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASSIST-CC','Engineering Assistant','LGSS14',1,'ENG-MECH-SUPT-CC',33,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-AUTO-CC','Auto Electrician','LGSS14',1,'ENG-MECH-SUPT-CC',33,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-TECH-CC','Mechanic','LGSS14',14,'ENG-MECH-SUPT-CC',33,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-FOREMAN-CC','Foreman','LGSS14',1,'ENG-MECH-SUPT-CC',33,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-ASSTFORE-CC','Assistant Foreman','LGSS17',1,'ENG-MECH-FOREMAN-CC',33,3,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-PLANT-CC','Plant Operator','LGSS14',6,'ENG-MECH-SUPT-CC',33,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-HANDY-CC','Mechanical Handyman','LGSS18',3,'ENG-MECH-SUPT-CC',33,3,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-MECH-WELDER-CC','Welder','LGSS14',3,'ENG-MECH-SUPT-CC',33,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-CHIEF-CC','Chief Civil Engineer','LGSS06',1,'ENG-ROADS-ASSTDIR-CC',34,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL06-CC','Civil Engineer','LGSS06',4,'ENG-CIVIL-CHIEF-CC',34,3,4,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL07-CC','Civil Engineer','LGSS07',6,'ENG-CIVIL-CHIEF-CC',34,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASST-CC','Assistant Civil Engineer','LGSS10',10,'ENG-CIVIL06-CC',34,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-HIGHWAY-CC','Superintendent – Highway','LGSS12',1,'ENG-CIVIL06-CC',34,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-SENASSIST-CC','Senior Engineering Assistant','LGSS13',2,'ENG-CIVIL06-CC',34,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASSTSUPT-CC','Assistant Superintendent - Highway','LGSS13',2,'ENG-CIVIL-HIGHWAY-CC',34,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASSIST-CC','Engineering Assistant - Roads','LGSS14',1,'ENG-CIVIL06-CC',34,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-FOREMAN-CC','Foreman','LGSS14',3,'ENG-CIVIL06-CC',34,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-CIVIL-ASSTFORE-CC','Assistant Foreman','LGSS17',4,'ENG-CIVIL-FOREMAN-CC',34,3,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-CHIEF-CC','Chief Fire Officer','LGSS06',1,'ENG-DIR-CC',35,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DEPUTY-CC','Deputy Chief Fire Officer','LGSS07',2,'ENG-FIRE-CHIEF-CC',35,3,5,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DIV-CC','Divisional Fire Officer','LGSS09',2,'ENG-FIRE-DEPUTY-CC',35,3,6,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-ASSTDIV-CC','Assistant Divisional Fire Officer','LGSS10',2,'ENG-FIRE-DIV-CC',35,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-STN-CC','Station Fire Officer','LGSS11',4,'ENG-FIRE-DIV-CC',35,3,7,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-SUB-CC','Sub-Officer','LGSS12',6,'ENG-FIRE-STN-CC',35,3,8,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-LEAD-CC','Leading Firefighter','LGSS13',4,'ENG-FIRE-SUB-CC',35,3,9,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-CC','Firefighter','LGSS14',52,'ENG-FIRE-LEAD-CC',35,3,10,0,NULL);
INSERT INTO eng_positions VALUES('ENG-FIRE-DRV-CC','Fire Fighter Driver','LGSS14',6,'ENG-FIRE-LEAD-CC',35,3,10,0,NULL);
INSERT INTO eng_positions VALUES('ENG-WATSAN-COORD-CC','Rural Water and Sanitation Coordinator','LGSS06',1,'ENG-DIR-CC',36,3,4,1,NULL);
INSERT INTO eng_positions VALUES('ENG-WATSAN-ENG-CC','Rural Water and Sanitation Engineer','LGSS07',2,'ENG-WATSAN-COORD-CC',36,3,5,0,NULL);
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
INSERT INTO eng_leave_approval_chain VALUES(13,'ENG-ELEC-HEAD-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(14,'ENG-ELEC-HEAD-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(15,'ENG-ELEC-HEAD-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(16,'ENG-ELEC-ASST-TC',1,'Supervisor','ENG-ELEC-HEAD-TC');
INSERT INTO eng_leave_approval_chain VALUES(17,'ENG-ELEC-ASST-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(18,'ENG-ELEC-ASST-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(19,'ENG-ELEC-TECH-TC',1,'Supervisor','ENG-ELEC-HEAD-TC');
INSERT INTO eng_leave_approval_chain VALUES(20,'ENG-ELEC-TECH-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(21,'ENG-ELEC-TECH-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(22,'ENG-MAINT-SUP-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(23,'ENG-MAINT-SUP-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(24,'ENG-MAINT-SUP-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(25,'ENG-PLUM-TC',1,'Supervisor','ENG-MAINT-SUP-TC');
INSERT INTO eng_leave_approval_chain VALUES(26,'ENG-PLUM-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(27,'ENG-PLUM-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(28,'ENG-BRICK-TC',1,'Supervisor','ENG-MAINT-SUP-TC');
INSERT INTO eng_leave_approval_chain VALUES(29,'ENG-BRICK-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(30,'ENG-BRICK-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(31,'ENG-CARP-TC',1,'Supervisor','ENG-MAINT-SUP-TC');
INSERT INTO eng_leave_approval_chain VALUES(32,'ENG-CARP-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(33,'ENG-CARP-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(34,'ENG-PAINT-TC',1,'Supervisor','ENG-MAINT-SUP-TC');
INSERT INTO eng_leave_approval_chain VALUES(35,'ENG-PAINT-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(36,'ENG-PAINT-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(37,'ENG-GENWORK-TC',1,'Supervisor','ENG-MAINT-SUP-TC');
INSERT INTO eng_leave_approval_chain VALUES(38,'ENG-GENWORK-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(39,'ENG-GENWORK-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(40,'ENG-QSURV-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(41,'ENG-QSURV-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(42,'ENG-QSURV-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(43,'ENG-QSURV-ASST-TC',1,'Supervisor','ENG-QSURV-TC');
INSERT INTO eng_leave_approval_chain VALUES(44,'ENG-QSURV-ASST-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(45,'ENG-QSURV-ASST-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(46,'ENG-ARCH-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(47,'ENG-ARCH-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(48,'ENG-ARCH-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(49,'ENG-ARCH-ASST-TC',1,'Supervisor','ENG-ARCH-TC');
INSERT INTO eng_leave_approval_chain VALUES(50,'ENG-ARCH-ASST-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(51,'ENG-ARCH-ASST-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(52,'ENG-CLERK-TC',1,'Supervisor','ENG-ARCH-TC');
INSERT INTO eng_leave_approval_chain VALUES(53,'ENG-CLERK-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(54,'ENG-CLERK-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(55,'ENG-DRAFT-TC',1,'Supervisor','ENG-ARCH-TC');
INSERT INTO eng_leave_approval_chain VALUES(56,'ENG-DRAFT-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(57,'ENG-DRAFT-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(58,'ENG-PARK-MGR-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(59,'ENG-PARK-MGR-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(60,'ENG-PARK-MGR-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(61,'ENG-PARK-SUP-TC',1,'Supervisor','ENG-PARK-MGR-TC');
INSERT INTO eng_leave_approval_chain VALUES(62,'ENG-PARK-SUP-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(63,'ENG-PARK-SUP-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(64,'ENG-PARK-WORK-TC',1,'Supervisor','ENG-PARK-SUP-TC');
INSERT INTO eng_leave_approval_chain VALUES(65,'ENG-PARK-WORK-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(66,'ENG-PARK-WORK-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(67,'ENG-CIVIL-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(68,'ENG-CIVIL-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(69,'ENG-CIVIL-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(70,'ENG-CIVIL-ASST-TC',1,'Supervisor','ENG-CIVIL-TC');
INSERT INTO eng_leave_approval_chain VALUES(71,'ENG-CIVIL-ASST-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(72,'ENG-CIVIL-ASST-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(73,'ENG-CIVIL-TECH-TC',1,'Supervisor','ENG-CIVIL-TC');
INSERT INTO eng_leave_approval_chain VALUES(74,'ENG-CIVIL-TECH-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(75,'ENG-CIVIL-TECH-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(76,'ENG-MECH-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(77,'ENG-MECH-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(78,'ENG-MECH-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(79,'ENG-MECH-ASST-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(80,'ENG-MECH-ASST-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(81,'ENG-MECH-ASST-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(82,'ENG-MOTOR-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(83,'ENG-MOTOR-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(84,'ENG-MOTOR-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(85,'ENG-AUTO-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(86,'ENG-AUTO-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(87,'ENG-AUTO-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(88,'ENG-MECH-TECH-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(89,'ENG-MECH-TECH-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(90,'ENG-MECH-TECH-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(91,'ENG-EXCAV-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(92,'ENG-EXCAV-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(93,'ENG-EXCAV-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(94,'ENG-SCALER-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(95,'ENG-SCALER-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(96,'ENG-SCALER-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(97,'ENG-HANDY-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(98,'ENG-HANDY-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(99,'ENG-HANDY-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(100,'ENG-WELDER-TC',1,'Supervisor','ENG-MECH-TC');
INSERT INTO eng_leave_approval_chain VALUES(101,'ENG-WELDER-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(102,'ENG-WELDER-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(103,'ENG-FIRE-DIV-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(104,'ENG-FIRE-DIV-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(105,'ENG-FIRE-DIV-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(106,'ENG-FIRE-STN-TC',1,'Supervisor','ENG-FIRE-DIV-TC');
INSERT INTO eng_leave_approval_chain VALUES(107,'ENG-FIRE-STN-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(108,'ENG-FIRE-STN-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(109,'ENG-FIRE-SUB-TC',1,'Supervisor','ENG-FIRE-STN-TC');
INSERT INTO eng_leave_approval_chain VALUES(110,'ENG-FIRE-SUB-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(111,'ENG-FIRE-SUB-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(112,'ENG-FIRE-LEAD-TC',1,'Supervisor','ENG-FIRE-STN-TC');
INSERT INTO eng_leave_approval_chain VALUES(113,'ENG-FIRE-LEAD-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(114,'ENG-FIRE-LEAD-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(115,'ENG-FIRE-TC',1,'Supervisor','ENG-FIRE-LEAD-TC');
INSERT INTO eng_leave_approval_chain VALUES(116,'ENG-FIRE-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(117,'ENG-FIRE-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(118,'ENG-FIRE-DRV-TC',1,'Supervisor','ENG-FIRE-LEAD-TC');
INSERT INTO eng_leave_approval_chain VALUES(119,'ENG-FIRE-DRV-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(120,'ENG-FIRE-DRV-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(121,'ENG-WATSAN-TC',1,'Supervisor','ENG-ASST-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(122,'ENG-WATSAN-TC',2,'Head of Department','ENG-DIR-TC');
INSERT INTO eng_leave_approval_chain VALUES(123,'ENG-WATSAN-TC',3,'Head of Council','COUNCIL-SEC');
INSERT INTO eng_leave_approval_chain VALUES(124,'TOWN-CLERK-MC',1,'Supervisor',NULL);
INSERT INTO eng_leave_approval_chain VALUES(125,'TOWN-CLERK-MC',2,'Head of Council',NULL);
INSERT INTO eng_leave_approval_chain VALUES(126,'TOWN-CLERK-MC',3,'Head of Council',NULL);
INSERT INTO eng_leave_approval_chain VALUES(127,'ENG-DIR-MC',1,'Supervisor','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(128,'ENG-DIR-MC',2,'Head of Department','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(129,'ENG-DIR-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(130,'ENG-CONSTR-ASSTDIR-MC',1,'Supervisor','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(131,'ENG-CONSTR-ASSTDIR-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(132,'ENG-CONSTR-ASSTDIR-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(133,'ENG-ROADS-ASSTDIR-MC',1,'Supervisor','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(134,'ENG-ROADS-ASSTDIR-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(135,'ENG-ROADS-ASSTDIR-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(136,'ENG-ELEC-CHIEF-MC',1,'Supervisor','ENG-CONSTR-ASSTDIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(137,'ENG-ELEC-CHIEF-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(138,'ENG-ELEC-CHIEF-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(139,'ENG-ELEC-ENG07-MC',1,'Supervisor','ENG-ELEC-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(140,'ENG-ELEC-ENG07-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(141,'ENG-ELEC-ENG07-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(142,'ENG-ELEC-ASST-MC',1,'Supervisor','ENG-ELEC-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(143,'ENG-ELEC-ASST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(144,'ENG-ELEC-ASST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(145,'ENG-ELEC-SUPT-MC',1,'Supervisor','ENG-ELEC-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(146,'ENG-ELEC-SUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(147,'ENG-ELEC-SUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(148,'ENG-ELEC-ASSTSUPT-MC',1,'Supervisor','ENG-ELEC-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(149,'ENG-ELEC-ASSTSUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(150,'ENG-ELEC-ASSTSUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(151,'ENG-ELEC-SENASSIST-MC',1,'Supervisor','ENG-ELEC-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(152,'ENG-ELEC-SENASSIST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(153,'ENG-ELEC-SENASSIST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(154,'ENG-ELEC-WORKSUP-MC',1,'Supervisor','ENG-ELEC-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(155,'ENG-ELEC-WORKSUP-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(156,'ENG-ELEC-WORKSUP-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(157,'ENG-ELEC-TECH-MC',1,'Supervisor','ENG-ELEC-WORKSUP-MC');
INSERT INTO eng_leave_approval_chain VALUES(158,'ENG-ELEC-TECH-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(159,'ENG-ELEC-TECH-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(160,'ENG-ELEC-FOREMAN-MC',1,'Supervisor','ENG-ELEC-WORKSUP-MC');
INSERT INTO eng_leave_approval_chain VALUES(161,'ENG-ELEC-FOREMAN-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(162,'ENG-ELEC-FOREMAN-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(163,'ENG-ELEC-ASSTFORE-MC',1,'Supervisor','ENG-ELEC-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(164,'ENG-ELEC-ASSTFORE-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(165,'ENG-ELEC-ASSTFORE-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(166,'ENG-QSURV-CHIEF-MC',1,'Supervisor','ENG-CONSTR-ASSTDIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(167,'ENG-QSURV-CHIEF-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(168,'ENG-QSURV-CHIEF-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(169,'ENG-QSURV07-MC',1,'Supervisor','ENG-QSURV-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(170,'ENG-QSURV07-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(171,'ENG-QSURV07-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(172,'ENG-QSURV-ASST-MC',1,'Supervisor','ENG-QSURV07-MC');
INSERT INTO eng_leave_approval_chain VALUES(173,'ENG-QSURV-ASST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(174,'ENG-QSURV-ASST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(175,'ENG-QSURV-SENASSIST-MC',1,'Supervisor','ENG-QSURV-ASST-MC');
INSERT INTO eng_leave_approval_chain VALUES(176,'ENG-QSURV-SENASSIST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(177,'ENG-QSURV-SENASSIST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(178,'ENG-QSURV-ASSIST-MC',1,'Supervisor','ENG-QSURV-ASST-MC');
INSERT INTO eng_leave_approval_chain VALUES(179,'ENG-QSURV-ASSIST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(180,'ENG-QSURV-ASSIST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(181,'ENG-ARCH-CHIEF-MC',1,'Supervisor','ENG-CONSTR-ASSTDIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(182,'ENG-ARCH-CHIEF-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(183,'ENG-ARCH-CHIEF-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(184,'ENG-ARCH07-MC',1,'Supervisor','ENG-ARCH-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(185,'ENG-ARCH07-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(186,'ENG-ARCH07-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(187,'ENG-ARCH-ASST-MC',1,'Supervisor','ENG-ARCH07-MC');
INSERT INTO eng_leave_approval_chain VALUES(188,'ENG-ARCH-ASST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(189,'ENG-ARCH-ASST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(190,'ENG-ARCH-ASSIST-MC',1,'Supervisor','ENG-ARCH-ASST-MC');
INSERT INTO eng_leave_approval_chain VALUES(191,'ENG-ARCH-ASSIST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(192,'ENG-ARCH-ASSIST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(193,'ENG-ARCH-FOREMAN-MC',1,'Supervisor','ENG-ARCH-ASST-MC');
INSERT INTO eng_leave_approval_chain VALUES(194,'ENG-ARCH-FOREMAN-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(195,'ENG-ARCH-FOREMAN-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(196,'ENG-ARCH-ASSTFORE-MC',1,'Supervisor','ENG-ARCH-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(197,'ENG-ARCH-ASSTFORE-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(198,'ENG-ARCH-ASSTFORE-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(199,'ENG-ARCH-SENCLERK-MC',1,'Supervisor','ENG-ARCH07-MC');
INSERT INTO eng_leave_approval_chain VALUES(200,'ENG-ARCH-SENCLERK-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(201,'ENG-ARCH-SENCLERK-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(202,'ENG-ARCH-CLERK-MC',1,'Supervisor','ENG-ARCH-SENCLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(203,'ENG-ARCH-CLERK-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(204,'ENG-ARCH-CLERK-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(205,'ENG-ARCH-DRAFT-MC',1,'Supervisor','ENG-ARCH07-MC');
INSERT INTO eng_leave_approval_chain VALUES(206,'ENG-ARCH-DRAFT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(207,'ENG-ARCH-DRAFT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(208,'ENG-MAINT-SUPT-MC',1,'Supervisor','ENG-CONSTR-ASSTDIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(209,'ENG-MAINT-SUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(210,'ENG-MAINT-SUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(211,'ENG-MAINT-ASSTSUPT-MC',1,'Supervisor','ENG-MAINT-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(212,'ENG-MAINT-ASSTSUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(213,'ENG-MAINT-ASSTSUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(214,'ENG-MAINT-FOREMAN-MC',1,'Supervisor','ENG-MAINT-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(215,'ENG-MAINT-FOREMAN-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(216,'ENG-MAINT-FOREMAN-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(217,'ENG-MAINT-PLUM-MC',1,'Supervisor','ENG-MAINT-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(218,'ENG-MAINT-PLUM-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(219,'ENG-MAINT-PLUM-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(220,'ENG-MAINT-BRICK-MC',1,'Supervisor','ENG-MAINT-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(221,'ENG-MAINT-BRICK-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(222,'ENG-MAINT-BRICK-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(223,'ENG-MAINT-CARP-MC',1,'Supervisor','ENG-MAINT-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(224,'ENG-MAINT-CARP-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(225,'ENG-MAINT-CARP-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(226,'ENG-MAINT-PAINT-MC',1,'Supervisor','ENG-MAINT-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(227,'ENG-MAINT-PAINT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(228,'ENG-MAINT-PAINT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(229,'ENG-MAINT-GENWORK-MC',1,'Supervisor','ENG-MAINT-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(230,'ENG-MAINT-GENWORK-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(231,'ENG-MAINT-GENWORK-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(232,'ENG-PARK-MGR-MC',1,'Supervisor','ENG-CONSTR-ASSTDIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(233,'ENG-PARK-MGR-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(234,'ENG-PARK-MGR-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(235,'ENG-PARK-SUPT-MC',1,'Supervisor','ENG-PARK-MGR-MC');
INSERT INTO eng_leave_approval_chain VALUES(236,'ENG-PARK-SUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(237,'ENG-PARK-SUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(238,'ENG-PARK-ASSTSUPT-MC',1,'Supervisor','ENG-PARK-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(239,'ENG-PARK-ASSTSUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(240,'ENG-PARK-ASSTSUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(241,'ENG-PARK-FOREMAN-MC',1,'Supervisor','ENG-PARK-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(242,'ENG-PARK-FOREMAN-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(243,'ENG-PARK-FOREMAN-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(244,'ENG-PARK-SUP-MC',1,'Supervisor','ENG-PARK-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(245,'ENG-PARK-SUP-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(246,'ENG-PARK-SUP-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(247,'ENG-PARK-ASSTFORE-MC',1,'Supervisor','ENG-PARK-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(248,'ENG-PARK-ASSTFORE-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(249,'ENG-PARK-ASSTFORE-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(250,'ENG-PARK-WORK-MC',1,'Supervisor','ENG-PARK-SUP-MC');
INSERT INTO eng_leave_approval_chain VALUES(251,'ENG-PARK-WORK-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(252,'ENG-PARK-WORK-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(253,'ENG-MECH-CHIEF-MC',1,'Supervisor','ENG-CONSTR-ASSTDIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(254,'ENG-MECH-CHIEF-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(255,'ENG-MECH-CHIEF-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(256,'ENG-MECH07-MC',1,'Supervisor','ENG-MECH-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(257,'ENG-MECH07-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(258,'ENG-MECH07-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(259,'ENG-MECH-ASST-MC',1,'Supervisor','ENG-MECH07-MC');
INSERT INTO eng_leave_approval_chain VALUES(260,'ENG-MECH-ASST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(261,'ENG-MECH-ASST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(262,'ENG-MECH-SUPT-MC',1,'Supervisor','ENG-MECH07-MC');
INSERT INTO eng_leave_approval_chain VALUES(263,'ENG-MECH-SUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(264,'ENG-MECH-SUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(265,'ENG-MECH-ASSTSUPT-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(266,'ENG-MECH-ASSTSUPT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(267,'ENG-MECH-ASSTSUPT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(268,'ENG-MECH-ASSIST-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(269,'ENG-MECH-ASSIST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(270,'ENG-MECH-ASSIST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(271,'ENG-MECH-AUTO-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(272,'ENG-MECH-AUTO-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(273,'ENG-MECH-AUTO-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(274,'ENG-MECH-TECH-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(275,'ENG-MECH-TECH-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(276,'ENG-MECH-TECH-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(277,'ENG-MECH-FOREMAN-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(278,'ENG-MECH-FOREMAN-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(279,'ENG-MECH-FOREMAN-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(280,'ENG-MECH-ASSTFORE-MC',1,'Supervisor','ENG-MECH-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(281,'ENG-MECH-ASSTFORE-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(282,'ENG-MECH-ASSTFORE-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(283,'ENG-MECH-PLANT-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(284,'ENG-MECH-PLANT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(285,'ENG-MECH-PLANT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(286,'ENG-MECH-HANDY-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(287,'ENG-MECH-HANDY-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(288,'ENG-MECH-HANDY-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(289,'ENG-MECH-WELDER-MC',1,'Supervisor','ENG-MECH-SUPT-MC');
INSERT INTO eng_leave_approval_chain VALUES(290,'ENG-MECH-WELDER-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(291,'ENG-MECH-WELDER-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(292,'ENG-CIVIL-CHIEF-MC',1,'Supervisor','ENG-ROADS-ASSTDIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(293,'ENG-CIVIL-CHIEF-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(294,'ENG-CIVIL-CHIEF-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(295,'ENG-CIVIL07-MC',1,'Supervisor','ENG-CIVIL-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(296,'ENG-CIVIL07-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(297,'ENG-CIVIL07-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(298,'ENG-CIVIL-ASST-MC',1,'Supervisor','ENG-CIVIL07-MC');
INSERT INTO eng_leave_approval_chain VALUES(299,'ENG-CIVIL-ASST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(300,'ENG-CIVIL-ASST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(301,'ENG-CIVIL-HIGHWAY-MC',1,'Supervisor','ENG-CIVIL07-MC');
INSERT INTO eng_leave_approval_chain VALUES(302,'ENG-CIVIL-HIGHWAY-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(303,'ENG-CIVIL-HIGHWAY-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(304,'ENG-CIVIL-SENASSIST-MC',1,'Supervisor','ENG-CIVIL07-MC');
INSERT INTO eng_leave_approval_chain VALUES(305,'ENG-CIVIL-SENASSIST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(306,'ENG-CIVIL-SENASSIST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(307,'ENG-CIVIL-ASSIST-MC',1,'Supervisor','ENG-CIVIL07-MC');
INSERT INTO eng_leave_approval_chain VALUES(308,'ENG-CIVIL-ASSIST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(309,'ENG-CIVIL-ASSIST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(310,'ENG-CIVIL-FOREMAN-MC',1,'Supervisor','ENG-CIVIL07-MC');
INSERT INTO eng_leave_approval_chain VALUES(311,'ENG-CIVIL-FOREMAN-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(312,'ENG-CIVIL-FOREMAN-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(313,'ENG-CIVIL-DRAFT-MC',1,'Supervisor','ENG-CIVIL07-MC');
INSERT INTO eng_leave_approval_chain VALUES(314,'ENG-CIVIL-DRAFT-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(315,'ENG-CIVIL-DRAFT-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(316,'ENG-CIVIL-ASSTFORE-MC',1,'Supervisor','ENG-CIVIL-FOREMAN-MC');
INSERT INTO eng_leave_approval_chain VALUES(317,'ENG-CIVIL-ASSTFORE-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(318,'ENG-CIVIL-ASSTFORE-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(319,'ENG-FIRE-CHIEF-MC',1,'Supervisor','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(320,'ENG-FIRE-CHIEF-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(321,'ENG-FIRE-CHIEF-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(322,'ENG-FIRE-DEPUTY-MC',1,'Supervisor','ENG-FIRE-CHIEF-MC');
INSERT INTO eng_leave_approval_chain VALUES(323,'ENG-FIRE-DEPUTY-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(324,'ENG-FIRE-DEPUTY-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(325,'ENG-FIRE-DIV-MC',1,'Supervisor','ENG-FIRE-DEPUTY-MC');
INSERT INTO eng_leave_approval_chain VALUES(326,'ENG-FIRE-DIV-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(327,'ENG-FIRE-DIV-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(328,'ENG-FIRE-ASSTDIV-MC',1,'Supervisor','ENG-FIRE-DIV-MC');
INSERT INTO eng_leave_approval_chain VALUES(329,'ENG-FIRE-ASSTDIV-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(330,'ENG-FIRE-ASSTDIV-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(331,'ENG-FIRE-STN-MC',1,'Supervisor','ENG-FIRE-DIV-MC');
INSERT INTO eng_leave_approval_chain VALUES(332,'ENG-FIRE-STN-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(333,'ENG-FIRE-STN-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(334,'ENG-FIRE-SUB-MC',1,'Supervisor','ENG-FIRE-STN-MC');
INSERT INTO eng_leave_approval_chain VALUES(335,'ENG-FIRE-SUB-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(336,'ENG-FIRE-SUB-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(337,'ENG-FIRE-LEAD-MC',1,'Supervisor','ENG-FIRE-SUB-MC');
INSERT INTO eng_leave_approval_chain VALUES(338,'ENG-FIRE-LEAD-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(339,'ENG-FIRE-LEAD-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(340,'ENG-FIRE-MC',1,'Supervisor','ENG-FIRE-LEAD-MC');
INSERT INTO eng_leave_approval_chain VALUES(341,'ENG-FIRE-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(342,'ENG-FIRE-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(343,'ENG-FIRE-DRV-MC',1,'Supervisor','ENG-FIRE-LEAD-MC');
INSERT INTO eng_leave_approval_chain VALUES(344,'ENG-FIRE-DRV-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(345,'ENG-FIRE-DRV-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(346,'ENG-WATSAN-COORD-MC',1,'Supervisor','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(347,'ENG-WATSAN-COORD-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(348,'ENG-WATSAN-COORD-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(349,'ENG-WATSAN-ASST-MC',1,'Supervisor','ENG-WATSAN-COORD-MC');
INSERT INTO eng_leave_approval_chain VALUES(350,'ENG-WATSAN-ASST-MC',2,'Head of Department','ENG-DIR-MC');
INSERT INTO eng_leave_approval_chain VALUES(351,'ENG-WATSAN-ASST-MC',3,'Head of Council','TOWN-CLERK-MC');
INSERT INTO eng_leave_approval_chain VALUES(352,'CITY-CLERK-CC',1,'Supervisor',NULL);
INSERT INTO eng_leave_approval_chain VALUES(353,'CITY-CLERK-CC',2,'Head of Council',NULL);
INSERT INTO eng_leave_approval_chain VALUES(354,'CITY-CLERK-CC',3,'Head of Council',NULL);
INSERT INTO eng_leave_approval_chain VALUES(355,'ENG-DIR-CC',1,'Supervisor','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(356,'ENG-DIR-CC',2,'Head of Department','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(357,'ENG-DIR-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(358,'ENG-CONSTR-ASSTDIR-CC',1,'Supervisor','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(359,'ENG-CONSTR-ASSTDIR-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(360,'ENG-CONSTR-ASSTDIR-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(361,'ENG-ROADS-ASSTDIR-CC',1,'Supervisor','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(362,'ENG-ROADS-ASSTDIR-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(363,'ENG-ROADS-ASSTDIR-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(364,'ENG-ELEC-CHIEF-CC',1,'Supervisor','ENG-CONSTR-ASSTDIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(365,'ENG-ELEC-CHIEF-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(366,'ENG-ELEC-CHIEF-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(367,'ENG-ELEC-ENG07-CC',1,'Supervisor','ENG-ELEC-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(368,'ENG-ELEC-ENG07-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(369,'ENG-ELEC-ENG07-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(370,'ENG-ELEC-ASST-CC',1,'Supervisor','ENG-ELEC-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(371,'ENG-ELEC-ASST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(372,'ENG-ELEC-ASST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(373,'ENG-ELEC-SEN-SUPT-CC',1,'Supervisor','ENG-ELEC-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(374,'ENG-ELEC-SEN-SUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(375,'ENG-ELEC-SEN-SUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(376,'ENG-ELEC-SUPT-CC',1,'Supervisor','ENG-ELEC-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(377,'ENG-ELEC-SUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(378,'ENG-ELEC-SUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(379,'ENG-ELEC-ASSTSUPT-CC',1,'Supervisor','ENG-ELEC-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(380,'ENG-ELEC-ASSTSUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(381,'ENG-ELEC-ASSTSUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(382,'ENG-ELEC-SENASSIST-CC',1,'Supervisor','ENG-ELEC-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(383,'ENG-ELEC-SENASSIST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(384,'ENG-ELEC-SENASSIST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(385,'ENG-ELEC-WORKSUP-CC',1,'Supervisor','ENG-ELEC-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(386,'ENG-ELEC-WORKSUP-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(387,'ENG-ELEC-WORKSUP-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(388,'ENG-ELEC-TECH-CC',1,'Supervisor','ENG-ELEC-WORKSUP-CC');
INSERT INTO eng_leave_approval_chain VALUES(389,'ENG-ELEC-TECH-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(390,'ENG-ELEC-TECH-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(391,'ENG-ELEC-FOREMAN-CC',1,'Supervisor','ENG-ELEC-WORKSUP-CC');
INSERT INTO eng_leave_approval_chain VALUES(392,'ENG-ELEC-FOREMAN-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(393,'ENG-ELEC-FOREMAN-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(394,'ENG-ELEC-ASSTFORE-CC',1,'Supervisor','ENG-ELEC-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(395,'ENG-ELEC-ASSTFORE-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(396,'ENG-ELEC-ASSTFORE-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(397,'ENG-QSURV-CHIEF-CC',1,'Supervisor','ENG-CONSTR-ASSTDIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(398,'ENG-QSURV-CHIEF-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(399,'ENG-QSURV-CHIEF-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(400,'ENG-QSURV07-CC',1,'Supervisor','ENG-QSURV-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(401,'ENG-QSURV07-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(402,'ENG-QSURV07-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(403,'ENG-QSURV-ASST-CC',1,'Supervisor','ENG-QSURV07-CC');
INSERT INTO eng_leave_approval_chain VALUES(404,'ENG-QSURV-ASST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(405,'ENG-QSURV-ASST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(406,'ENG-ARCH-CHIEF-CC',1,'Supervisor','ENG-CONSTR-ASSTDIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(407,'ENG-ARCH-CHIEF-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(408,'ENG-ARCH-CHIEF-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(409,'ENG-ARCH07-CC',1,'Supervisor','ENG-ARCH-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(410,'ENG-ARCH07-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(411,'ENG-ARCH07-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(412,'ENG-ARCH-ASST-CC',1,'Supervisor','ENG-ARCH07-CC');
INSERT INTO eng_leave_approval_chain VALUES(413,'ENG-ARCH-ASST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(414,'ENG-ARCH-ASST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(415,'ENG-ARCH-DRAFT-CC',1,'Supervisor','ENG-ARCH07-CC');
INSERT INTO eng_leave_approval_chain VALUES(416,'ENG-ARCH-DRAFT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(417,'ENG-ARCH-DRAFT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(418,'ENG-MAINT-SUPT-CC',1,'Supervisor','ENG-CONSTR-ASSTDIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(419,'ENG-MAINT-SUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(420,'ENG-MAINT-SUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(421,'ENG-MAINT-ASSTSUPT-CC',1,'Supervisor','ENG-MAINT-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(422,'ENG-MAINT-ASSTSUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(423,'ENG-MAINT-ASSTSUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(424,'ENG-MAINT-ASSTSUPT2-CC',1,'Supervisor','ENG-MAINT-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(425,'ENG-MAINT-ASSTSUPT2-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(426,'ENG-MAINT-ASSTSUPT2-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(427,'ENG-MAINT-FOREMAN-CC',1,'Supervisor','ENG-MAINT-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(428,'ENG-MAINT-FOREMAN-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(429,'ENG-MAINT-FOREMAN-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(430,'ENG-MAINT-PLUM-CC',1,'Supervisor','ENG-MAINT-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(431,'ENG-MAINT-PLUM-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(432,'ENG-MAINT-PLUM-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(433,'ENG-MAINT-BRICK-CC',1,'Supervisor','ENG-MAINT-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(434,'ENG-MAINT-BRICK-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(435,'ENG-MAINT-BRICK-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(436,'ENG-MAINT-CARP-CC',1,'Supervisor','ENG-MAINT-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(437,'ENG-MAINT-CARP-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(438,'ENG-MAINT-CARP-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(439,'ENG-MAINT-PAINT-CC',1,'Supervisor','ENG-MAINT-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(440,'ENG-MAINT-PAINT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(441,'ENG-MAINT-PAINT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(442,'ENG-MAINT-GENWORK-CC',1,'Supervisor','ENG-MAINT-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(443,'ENG-MAINT-GENWORK-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(444,'ENG-MAINT-GENWORK-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(445,'ENG-PARK-MGR-CC',1,'Supervisor','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(446,'ENG-PARK-MGR-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(447,'ENG-PARK-MGR-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(448,'ENG-PARK-SUPT-CC',1,'Supervisor','ENG-PARK-MGR-CC');
INSERT INTO eng_leave_approval_chain VALUES(449,'ENG-PARK-SUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(450,'ENG-PARK-SUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(451,'ENG-PARK-ASSTSUPT-CC',1,'Supervisor','ENG-PARK-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(452,'ENG-PARK-ASSTSUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(453,'ENG-PARK-ASSTSUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(454,'ENG-PARK-FOREMAN-CC',1,'Supervisor','ENG-PARK-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(455,'ENG-PARK-FOREMAN-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(456,'ENG-PARK-FOREMAN-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(457,'ENG-PARK-SUP-CC',1,'Supervisor','ENG-PARK-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(458,'ENG-PARK-SUP-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(459,'ENG-PARK-SUP-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(460,'ENG-PARK-ASSTFORE-CC',1,'Supervisor','ENG-PARK-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(461,'ENG-PARK-ASSTFORE-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(462,'ENG-PARK-ASSTFORE-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(463,'ENG-PARK-WORK-CC',1,'Supervisor','ENG-PARK-SUP-CC');
INSERT INTO eng_leave_approval_chain VALUES(464,'ENG-PARK-WORK-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(465,'ENG-PARK-WORK-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(466,'ENG-MECH-CHIEF-CC',1,'Supervisor','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(467,'ENG-MECH-CHIEF-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(468,'ENG-MECH-CHIEF-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(469,'ENG-MECH07-CC',1,'Supervisor','ENG-MECH-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(470,'ENG-MECH07-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(471,'ENG-MECH07-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(472,'ENG-MECH-ASST-CC',1,'Supervisor','ENG-MECH07-CC');
INSERT INTO eng_leave_approval_chain VALUES(473,'ENG-MECH-ASST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(474,'ENG-MECH-ASST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(475,'ENG-MECH-SUPT-CC',1,'Supervisor','ENG-MECH07-CC');
INSERT INTO eng_leave_approval_chain VALUES(476,'ENG-MECH-SUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(477,'ENG-MECH-SUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(478,'ENG-MECH-ASSTSUPT-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(479,'ENG-MECH-ASSTSUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(480,'ENG-MECH-ASSTSUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(481,'ENG-MECH-ASSIST-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(482,'ENG-MECH-ASSIST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(483,'ENG-MECH-ASSIST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(484,'ENG-MECH-AUTO-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(485,'ENG-MECH-AUTO-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(486,'ENG-MECH-AUTO-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(487,'ENG-MECH-TECH-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(488,'ENG-MECH-TECH-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(489,'ENG-MECH-TECH-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(490,'ENG-MECH-FOREMAN-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(491,'ENG-MECH-FOREMAN-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(492,'ENG-MECH-FOREMAN-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(493,'ENG-MECH-ASSTFORE-CC',1,'Supervisor','ENG-MECH-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(494,'ENG-MECH-ASSTFORE-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(495,'ENG-MECH-ASSTFORE-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(496,'ENG-MECH-PLANT-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(497,'ENG-MECH-PLANT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(498,'ENG-MECH-PLANT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(499,'ENG-MECH-HANDY-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(500,'ENG-MECH-HANDY-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(501,'ENG-MECH-HANDY-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(502,'ENG-MECH-WELDER-CC',1,'Supervisor','ENG-MECH-SUPT-CC');
INSERT INTO eng_leave_approval_chain VALUES(503,'ENG-MECH-WELDER-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(504,'ENG-MECH-WELDER-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(505,'ENG-CIVIL-CHIEF-CC',1,'Supervisor','ENG-ROADS-ASSTDIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(506,'ENG-CIVIL-CHIEF-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(507,'ENG-CIVIL-CHIEF-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(508,'ENG-CIVIL06-CC',1,'Supervisor','ENG-CIVIL-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(509,'ENG-CIVIL06-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(510,'ENG-CIVIL06-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(511,'ENG-CIVIL07-CC',1,'Supervisor','ENG-CIVIL-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(512,'ENG-CIVIL07-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(513,'ENG-CIVIL07-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(514,'ENG-CIVIL-ASST-CC',1,'Supervisor','ENG-CIVIL06-CC');
INSERT INTO eng_leave_approval_chain VALUES(515,'ENG-CIVIL-ASST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(516,'ENG-CIVIL-ASST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(517,'ENG-CIVIL-HIGHWAY-CC',1,'Supervisor','ENG-CIVIL06-CC');
INSERT INTO eng_leave_approval_chain VALUES(518,'ENG-CIVIL-HIGHWAY-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(519,'ENG-CIVIL-HIGHWAY-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(520,'ENG-CIVIL-SENASSIST-CC',1,'Supervisor','ENG-CIVIL06-CC');
INSERT INTO eng_leave_approval_chain VALUES(521,'ENG-CIVIL-SENASSIST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(522,'ENG-CIVIL-SENASSIST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(523,'ENG-CIVIL-ASSTSUPT-CC',1,'Supervisor','ENG-CIVIL-HIGHWAY-CC');
INSERT INTO eng_leave_approval_chain VALUES(524,'ENG-CIVIL-ASSTSUPT-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(525,'ENG-CIVIL-ASSTSUPT-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(526,'ENG-CIVIL-ASSIST-CC',1,'Supervisor','ENG-CIVIL06-CC');
INSERT INTO eng_leave_approval_chain VALUES(527,'ENG-CIVIL-ASSIST-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(528,'ENG-CIVIL-ASSIST-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(529,'ENG-CIVIL-FOREMAN-CC',1,'Supervisor','ENG-CIVIL06-CC');
INSERT INTO eng_leave_approval_chain VALUES(530,'ENG-CIVIL-FOREMAN-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(531,'ENG-CIVIL-FOREMAN-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(532,'ENG-CIVIL-ASSTFORE-CC',1,'Supervisor','ENG-CIVIL-FOREMAN-CC');
INSERT INTO eng_leave_approval_chain VALUES(533,'ENG-CIVIL-ASSTFORE-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(534,'ENG-CIVIL-ASSTFORE-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(535,'ENG-FIRE-CHIEF-CC',1,'Supervisor','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(536,'ENG-FIRE-CHIEF-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(537,'ENG-FIRE-CHIEF-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(538,'ENG-FIRE-DEPUTY-CC',1,'Supervisor','ENG-FIRE-CHIEF-CC');
INSERT INTO eng_leave_approval_chain VALUES(539,'ENG-FIRE-DEPUTY-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(540,'ENG-FIRE-DEPUTY-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(541,'ENG-FIRE-DIV-CC',1,'Supervisor','ENG-FIRE-DEPUTY-CC');
INSERT INTO eng_leave_approval_chain VALUES(542,'ENG-FIRE-DIV-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(543,'ENG-FIRE-DIV-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(544,'ENG-FIRE-ASSTDIV-CC',1,'Supervisor','ENG-FIRE-DIV-CC');
INSERT INTO eng_leave_approval_chain VALUES(545,'ENG-FIRE-ASSTDIV-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(546,'ENG-FIRE-ASSTDIV-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(547,'ENG-FIRE-STN-CC',1,'Supervisor','ENG-FIRE-DIV-CC');
INSERT INTO eng_leave_approval_chain VALUES(548,'ENG-FIRE-STN-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(549,'ENG-FIRE-STN-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(550,'ENG-FIRE-SUB-CC',1,'Supervisor','ENG-FIRE-STN-CC');
INSERT INTO eng_leave_approval_chain VALUES(551,'ENG-FIRE-SUB-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(552,'ENG-FIRE-SUB-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(553,'ENG-FIRE-LEAD-CC',1,'Supervisor','ENG-FIRE-SUB-CC');
INSERT INTO eng_leave_approval_chain VALUES(554,'ENG-FIRE-LEAD-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(555,'ENG-FIRE-LEAD-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(556,'ENG-FIRE-CC',1,'Supervisor','ENG-FIRE-LEAD-CC');
INSERT INTO eng_leave_approval_chain VALUES(557,'ENG-FIRE-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(558,'ENG-FIRE-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(559,'ENG-FIRE-DRV-CC',1,'Supervisor','ENG-FIRE-LEAD-CC');
INSERT INTO eng_leave_approval_chain VALUES(560,'ENG-FIRE-DRV-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(561,'ENG-FIRE-DRV-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(562,'ENG-WATSAN-COORD-CC',1,'Supervisor','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(563,'ENG-WATSAN-COORD-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(564,'ENG-WATSAN-COORD-CC',3,'Head of Council','CITY-CLERK-CC');
INSERT INTO eng_leave_approval_chain VALUES(565,'ENG-WATSAN-ENG-CC',1,'Supervisor','ENG-WATSAN-COORD-CC');
INSERT INTO eng_leave_approval_chain VALUES(566,'ENG-WATSAN-ENG-CC',2,'Head of Department','ENG-DIR-CC');
INSERT INTO eng_leave_approval_chain VALUES(567,'ENG-WATSAN-ENG-CC',3,'Head of Council','CITY-CLERK-CC');
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
INSERT INTO planning_sections VALUES(14,'Socio-Economic Planning','CC-SOC',3,NULL);
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
INSERT INTO planning_positions VALUES('PLAN-ASST-TOWN-TOWN','Assistant Town Planner','LGSS/10',2,'PLAN-TOWN-TOWN',1,3,1,5,0,0,'PLN-PHY-ASST-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-BI-TOWN','Building Inspector','LGSS/07',1,'PLAN-CH-PHY-TOWN',2,3,1,4,1,0,'PLN-BLD-INSP-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-BI-TOWN','Assistant Building Inspector','LGSS/10',2,'PLAN-BI-TOWN',2,3,1,5,0,0,'PLN-BLD-ASST-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-LS-TOWN','Land Surveyor','LGSS/07',1,'PLAN-CH-PHY-TOWN',3,3,1,4,1,0,'PLN-SUR-LS-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-LS-TOWN','Assistant Land Surveyor','LGSS/10',1,'PLAN-LS-TOWN',3,3,1,5,0,0,'PLN-SUR-ASST-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-CHAIN-TOWN','Chainman','G1',2,'PLAN-ASST-LS-TOWN',3,3,1,6,0,0,'PLN-SUR-CHAIN-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-VAL-TOWN','Valuation Officer','LGSS/07',1,'PLAN-DIR-TOWN',4,3,1,4,1,0,'PLN-VAL-OFF-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-VAL-MGMT-TOWN','Assistant Valuation Officer – Property Mgmt','LGSS/10',1,'PLAN-VAL-TOWN',4,3,1,5,0,0,'PLN-VAL-ASST-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-VAL-TAX-TOWN','Assistant Valuation Officer – Property Taxation','LGSS/10',1,'PLAN-VAL-TOWN',4,3,1,5,0,0,'PLN-VAL-ASST-TOW-02');
INSERT INTO planning_positions VALUES('PLAN-DATA-TOWN','Data Entry Clerk','LGSS/18',2,'PLAN-ASST-VAL-MGMT-TOWN',4,3,1,6,0,0,'PLN-VAL-DATA-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-CH-SOC-TOWN','Chief Socio-Economic Planner','LGSS/06',1,'PLAN-DIR-TOWN',NULL,4,1,3,1,1,'PLN-SOC-CHIEF-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-SOC-COUNCIL-TOWN','Socio-Economic Planner – Council','LGSS/07',2,'PLAN-CH-SOC-TOWN',NULL,4,1,4,0,0,'PLN-SOC-PLN-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-SOC-HEALTH-TOWN','Socio-Economic Planner – Health','LGSS/07',1,'PLAN-CH-SOC-TOWN',NULL,4,1,4,0,0,'PLN-SOC-HEALTH-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-SOC-FISH-TOWN','Socio-Economic Planner – Fisheries/Livestock/Vet','LGSS/07',1,'PLAN-CH-SOC-TOWN',NULL,4,1,4,0,0,'PLN-SOC-FISH-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-ENV-TOWN','Environmental Planner','LGSS/07',1,'PLAN-DIR-TOWN',NULL,5,1,4,0,0,'PLN-ENV-PLN-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-ME-TOWN','Monitoring & Evaluation Officer','LGSS/07',1,'PLAN-DIR-TOWN',NULL,5,1,4,0,0,'PLN-ME-OFF-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-DIR-MUN','Director of Planning','LGSS/04',1,'TOWN-CLERK-MUN',NULL,7,2,2,0,1,'PLN-LEAD-DIR-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-ADIR-PHY-MUN','Assistant Director – Physical Planning','LGSS/05',1,'PLAN-DIR-MUN',NULL,8,2,3,1,1,'PLN-LEAD-ADIR-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-TOWN-MUN','Senior Town Planner','LGSS/06',1,'PLAN-ADIR-PHY-MUN',5,8,2,4,1,0,'PLN-PHY-SNRTP-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-TOWN-MUN','Town Planner','LGSS/10',4,'PLAN-SNR-TOWN-MUN',5,8,2,5,0,0,'PLN-PHY-TP-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-TOWN-MUN','Assistant Town Planner','LGSS/10',1,'PLAN-TOWN-MUN',5,8,2,6,0,0,'PLN-PHY-ASTP-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-PA-MUN','Senior Planning Assistant','LGSS/12',1,'PLAN-ASST-TOWN-MUN',5,8,2,7,0,0,'PLN-PHY-SNRPA-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-PA-MUN','Planning Assistant','LGSS/14',2,'PLAN-SNR-PA-MUN',5,8,2,8,0,0,'PLN-PHY-PA-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-CH-BI-MUN','Chief Building Inspector','LGSS/06',1,'PLAN-DIR-MUN',6,8,2,4,1,0,'PLN-BLD-CHIEF-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-BI-MUN','Senior Building Inspector','LGSS/08',2,'PLAN-CH-BI-MUN',6,8,2,5,0,0,'PLN-BLD-SNR-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SUPT-BI-MUN','Superintendent','LGSS/10',3,'PLAN-SNR-BI-MUN',6,8,2,6,0,0,'PLN-BLD-SUPT-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-BI-MUN','Building Inspector','LGSS/10',3,'PLAN-SUPT-BI-MUN',6,8,2,7,0,0,'PLN-BLD-INSP-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-LS-MUN','Senior Land Surveyor','LGSS/06',1,'PLAN-DIR-MUN',7,8,2,4,1,0,'PLN-SUR-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-LS-MUN','Land Surveyor','LGSS/07',1,'PLAN-SNR-LS-MUN',7,8,2,5,0,0,'PLN-SUR-LS-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-LS-MUN','Assistant Land Surveyor','LGSS/10',2,'PLAN-LS-MUN',7,8,2,6,0,0,'PLN-SUR-ASTLS-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-CHAIN-MUN','Chainman','G1',2,'PLAN-ASST-LS-MUN',7,8,2,7,0,0,'PLN-SUR-CHAIN-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-CH-VAL-MUN','Chief Valuation Officer','LGSS/05',1,'PLAN-DIR-MUN',NULL,9,2,3,1,1,'PLN-VAL-CHIEF-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-VAL-MUN','Senior Valuation Officer','LGSS/06',1,'PLAN-CH-VAL-MUN',NULL,9,2,4,0,0,'PLN-VAL-SNR-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-VAL-MGMT-MUN','Senior Valuation Officer – Property Mgmt','LGSS/06',1,'PLAN-CH-VAL-MUN',NULL,9,2,4,0,0,'PLN-VAL-SNRMGMT-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-VAL-TAX-MUN','Senior Valuation Officer – Property Taxation','LGSS/06',1,'PLAN-CH-VAL-MUN',NULL,9,2,4,0,0,'PLN-VAL-SNRTAX-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-VAL-TAX-MUN','Valuation Officer – Property Taxation','LGSS/08',1,'PLAN-SNR-VAL-TAX-MUN',NULL,9,2,5,0,0,'PLN-VAL-TAX-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-VAL-MGMT-MUN','Valuation Assistant – Property Mgmt','LGSS/13',1,'PLAN-MGMT-MUN',NULL,9,2,6,0,0,'PLN-VAL-ASTMGMT-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-VAL-TAX-MUN','Valuation Assistant – Property Taxation','LGSS/13',1,'PLAN-VAL-TAX-MUN',NULL,9,2,6,0,0,'PLN-VAL-ASTTAX-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-FIELD-MUN','Field Inspector','LGSS/13',10,'PLAN-CH-VAL-MUN',NULL,9,2,6,0,0,'PLN-VAL-FLD-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-DATA-MUN','Data Entry Clerk','LGSS/13',1,'PLAN-ASST-VAL-MGMT-MUN',NULL,9,2,7,0,0,'PLN-SOC-DATA-TOW-01');
INSERT INTO planning_positions VALUES('PLAN-REV-MUN','Revenue Collector','LGSS/18',6,'PLAN-CH-VAL-MUN',NULL,9,2,7,0,0,'PLN-VAL-REV-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-CH-SOC-MUN','Chief Planner','LGSS/05',1,'PLAN-DIR-MUN',NULL,10,2,3,1,1,'PLN-PHY-CHIEF-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-SOC-MUN','Senior Socio-Economic Planner','LGSS/06',1,'PLAN-CH-SOC-MUN',NULL,10,2,4,0,0,'PLN-SOC-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SOC-MUN','Socio-Economic Planner','LGSS/07',2,'PLAN-SNR-SOC-MUN',NULL,10,2,5,0,0,'PLN-SOC-PLN-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-ENV-MUN','Senior Environmental Planner','LGSS/06',1,'PLAN-CH-SOC-MUN',NULL,10,2,4,0,0,'PLN-ENV-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-ENV-MUN','Environmental Planner','LGSS/07',1,'PLAN-SNR-ENV-MUN',NULL,10,2,5,0,0,'PLN-ENV-PLN-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SOC-HEALTH-MUN','Socio-Economic Planner – Health Services','LGSS/07',1,'PLAN-SNR-SOC-MUN',NULL,10,2,5,0,0,'PLN-SOC-HEALTH-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SOC-FISH-MUN','Socio-Economic Planner – Fisheries/Livestock/Vet','LGSS/07',1,'PLAN-SNR-SOC-MUN',NULL,10,2,5,0,0,'PLN-SOC-FISH-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-ME-MUN','Senior Monitoring & Evaluation Officer','LGSS/06',1,'PLAN-CH-SOC-MUN',NULL,10,2,4,0,0,'PLN-ME-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-ME-MUN','Monitoring & Evaluation Officer','LGSS/07',1,'PLAN-SNR-ME-MUN',NULL,10,2,5,0,0,'PLN-ME-OFF-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-DIR-CITY','Director of Planning','LGSS/03',1,'TOWN-CLERK-CITY',NULL,12,3,2,0,1,'PLN-LEAD-DIR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-ADIR-PHY-CITY','Assistant Director – Physical Planning','LGSS/05',1,'PLAN-DIR-CITY',NULL,13,3,3,1,1,'PLN-PHY-ADIR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-TOWN-CITY','Senior Town Planner','LGSS/06',1,'PLAN-ADIR-PHY-CITY',8,13,3,4,1,0,'PLN-PHY-SNRTP-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-TOWN-CITY','Town Planner','LGSS/10',4,'PLAN-SNR-TOWN-CITY',8,13,3,5,0,0,'PLN-PHY-TP-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-TOWN-CITY','Assistant Town Planner','LGSS/10',2,'PLAN-TOWN-CITY',8,13,3,6,0,0,'PLN-PHY-ASTP-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-CH-BI-CITY','Chief Building Inspector','LGSS/06',1,'PLAN-DIR-CITY',9,13,3,4,1,0,'PLN-BLD-CHIEF-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-BI-CITY','Senior Building Inspector','LGSS/07',5,'PLAN-CH-BI-CITY',9,13,3,5,0,0,'PLN-BLD-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SUPT-BI-CITY','Superintendent','LGSS/10',6,'PLAN-SNR-BI-CITY',9,13,3,6,0,0,'PLN-BLD-SUPT-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-BI-CITY','Building Inspector','LGSS/10',4,'PLAN-SUPT-BI-CITY',9,13,3,7,0,0,'PLN-BLD-INSP-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-LS-CITY','Senior Land Surveyor','LGSS/06',1,'PLAN-DIR-CITY',10,13,3,4,1,0,'PLN-SUR-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-LS-CITY','Land Surveyor','LGSS/07',3,'PLAN-SNR-LS-CITY',10,13,3,5,0,0,'PLN-SUR-LS-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-ASST-LS-CITY','Assistant Land Surveyor','LGSS/10',3,'PLAN-LS-CITY',10,13,3,6,0,0,'PLN-SUR-ASTLS-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-CHAIN-CITY','Chainman','G1',2,'PLAN-ASST-LS-CITY',10,13,3,7,0,0,'PLN-SUR-CHAIN-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-CH-SOC-CITY','Chief Planner','LGSS/05',1,'PLAN-DIR-CITY',NULL,14,3,3,1,1,'PLN-PHY-CHIEF-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-SOC-CITY','Senior Socio-Economic Planner','LGSS/06',1,'PLAN-CH-SOC-CITY',NULL,14,3,4,0,0,'PLN-SOC-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SOC-CITY','Socio-Economic Planner','LGSS/07',4,'PLAN-SNR-SOC-CITY',NULL,14,3,5,0,0,'PLN-SOC-PLN-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-ENV-CITY','Senior Environmental Planner','LGSS/06',1,'PLAN-CH-SOC-CITY',NULL,14,3,4,0,0,'PLN-ENV-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-ENV-CITY','Environmental Planner','LGSS/07',2,'PLAN-SNR-ENV-CITY',NULL,14,3,5,0,0,'PLN-ENV-PLN-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-SNR-ME-CITY','Senior Monitoring & Evaluation Officer','LGSS/06',1,'PLAN-CH-SOC-CITY',NULL,14,3,4,0,0,'PLN-ME-SNR-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-ME-CITY','Monitoring & Evaluation Officer','LGSS/07',2,'PLAN-SNR-ME-CITY',NULL,14,3,5,0,0,'PLN-ME-OFF-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-GENDER-CITY','Gender Officer','LGSS/07',1,'PLAN-CH-SOC-CITY',NULL,14,3,5,0,0,'PLN-GEN-OFF-CIT-01');
INSERT INTO planning_positions VALUES('PLAN-GENDER-MUN','Gender Officer','LGSS/07',1,'PLAN-CH-SOC-MUN',NULL,10,2,5,0,0,'PLN-SOC-GEN-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-DATA-SOC-MUN','Data Entry Clerk','LGSS/13',2,'PLAN-ME-MUN',NULL,10,2,6,0,0,'PLN-SOC-DATA-MUN-01');
INSERT INTO planning_positions VALUES('PLAN-VAL-MGMT-MUN','Valuation Officer - Property Management','LGSS/07',1,'PLAN-CH-VAL-MUN',NULL,9,2,5,0,0,'PLN-VAL-MGMT-MUN-01');
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
INSERT INTO planning_leave_approval_chain VALUES(31,'PLAN-ASST-TOWN-TOWN',1,'Supervisor','PLAN-TOWN-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(32,'PLAN-ASST-TOWN-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(33,'PLAN-ASST-TOWN-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(34,'PLAN-BI-TOWN',1,'Supervisor','PLAN-CH-PHY-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(35,'PLAN-BI-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(36,'PLAN-BI-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(37,'PLAN-ASST-BI-TOWN',1,'Supervisor','PLAN-BI-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(38,'PLAN-ASST-BI-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(39,'PLAN-ASST-BI-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(40,'PLAN-LS-TOWN',1,'Supervisor','PLAN-CH-PHY-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(41,'PLAN-LS-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(42,'PLAN-LS-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(43,'PLAN-ASST-LS-TOWN',1,'Supervisor','PLAN-LS-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(44,'PLAN-ASST-LS-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(45,'PLAN-ASST-LS-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(46,'PLAN-CHAIN-TOWN',1,'Supervisor','PLAN-ASST-LS-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(47,'PLAN-CHAIN-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(48,'PLAN-CHAIN-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(49,'PLAN-VAL-TOWN',1,'Supervisor','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(50,'PLAN-VAL-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(51,'PLAN-VAL-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(52,'PLAN-ASST-VAL-MGMT-TOWN',1,'Supervisor','PLAN-VAL-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(53,'PLAN-ASST-VAL-MGMT-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(54,'PLAN-ASST-VAL-MGMT-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(55,'PLAN-ASST-VAL-TAX-TOWN',1,'Supervisor','PLAN-VAL-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(56,'PLAN-ASST-VAL-TAX-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(57,'PLAN-ASST-VAL-TAX-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(58,'PLAN-DATA-TOWN',1,'Supervisor','PLAN-ASST-VAL-MGMT-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(59,'PLAN-DATA-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(60,'PLAN-DATA-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(61,'PLAN-CH-SOC-TOWN',1,'Supervisor','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(62,'PLAN-CH-SOC-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(63,'PLAN-CH-SOC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(64,'PLAN-SOC-COUNCIL-TOWN',1,'Supervisor','PLAN-CH-SOC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(65,'PLAN-SOC-COUNCIL-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(66,'PLAN-SOC-COUNCIL-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(67,'PLAN-SOC-HEALTH-TOWN',1,'Supervisor','PLAN-CH-SOC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(68,'PLAN-SOC-HEALTH-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(69,'PLAN-SOC-HEALTH-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(70,'PLAN-SOC-FISH-TOWN',1,'Supervisor','PLAN-CH-SOC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(71,'PLAN-SOC-FISH-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(72,'PLAN-SOC-FISH-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(73,'PLAN-HINFO-TOWN',1,'Supervisor','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(74,'PLAN-HINFO-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(75,'PLAN-HINFO-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(76,'PLAN-ENV-TOWN',1,'Supervisor','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(77,'PLAN-ENV-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(78,'PLAN-ENV-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(79,'PLAN-ME-TOWN',1,'Supervisor','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(80,'PLAN-ME-TOWN',2,'Head of Department','PLAN-DIR-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(81,'PLAN-ME-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO planning_leave_approval_chain VALUES(82,'TOWN-CLERK-MUN',1,'Supervisor',NULL);
INSERT INTO planning_leave_approval_chain VALUES(83,'TOWN-CLERK-MUN',2,'Head of Council',NULL);
INSERT INTO planning_leave_approval_chain VALUES(84,'TOWN-CLERK-MUN',3,'Head of Council',NULL);
INSERT INTO planning_leave_approval_chain VALUES(85,'PLAN-DIR-MUN',1,'Supervisor','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(86,'PLAN-DIR-MUN',2,'Head of Department','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(87,'PLAN-DIR-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(88,'PLAN-ADIR-PHY-MUN',1,'Supervisor','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(89,'PLAN-ADIR-PHY-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(90,'PLAN-ADIR-PHY-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(91,'PLAN-SNR-TOWN-MUN',1,'Supervisor','PLAN-ADIR-PHY-MUN');
INSERT INTO planning_leave_approval_chain VALUES(92,'PLAN-SNR-TOWN-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(93,'PLAN-SNR-TOWN-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(94,'PLAN-TOWN-MUN',1,'Supervisor','PLAN-SNR-TOWN-MUN');
INSERT INTO planning_leave_approval_chain VALUES(95,'PLAN-TOWN-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(96,'PLAN-TOWN-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(97,'PLAN-ASST-TOWN-MUN',1,'Supervisor','PLAN-TOWN-MUN');
INSERT INTO planning_leave_approval_chain VALUES(98,'PLAN-ASST-TOWN-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(99,'PLAN-ASST-TOWN-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(100,'PLAN-SNR-PA-MUN',1,'Supervisor','PLAN-ASST-TOWN-MUN');
INSERT INTO planning_leave_approval_chain VALUES(101,'PLAN-SNR-PA-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(102,'PLAN-SNR-PA-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(103,'PLAN-PA-MUN',1,'Supervisor','PLAN-SNR-PA-MUN');
INSERT INTO planning_leave_approval_chain VALUES(104,'PLAN-PA-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(105,'PLAN-PA-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(106,'PLAN-CH-BI-MUN',1,'Supervisor','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(107,'PLAN-CH-BI-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(108,'PLAN-CH-BI-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(109,'PLAN-SNR-BI-MUN',1,'Supervisor','PLAN-CH-BI-MUN');
INSERT INTO planning_leave_approval_chain VALUES(110,'PLAN-SNR-BI-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(111,'PLAN-SNR-BI-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(112,'PLAN-SUPT-BI-MUN',1,'Supervisor','PLAN-SNR-BI-MUN');
INSERT INTO planning_leave_approval_chain VALUES(113,'PLAN-SUPT-BI-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(114,'PLAN-SUPT-BI-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(115,'PLAN-BI-MUN',1,'Supervisor','PLAN-SUPT-BI-MUN');
INSERT INTO planning_leave_approval_chain VALUES(116,'PLAN-BI-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(117,'PLAN-BI-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(118,'PLAN-SNR-LS-MUN',1,'Supervisor','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(119,'PLAN-SNR-LS-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(120,'PLAN-SNR-LS-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(121,'PLAN-LS-MUN',1,'Supervisor','PLAN-SNR-LS-MUN');
INSERT INTO planning_leave_approval_chain VALUES(122,'PLAN-LS-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(123,'PLAN-LS-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(124,'PLAN-ASST-LS-MUN',1,'Supervisor','PLAN-LS-MUN');
INSERT INTO planning_leave_approval_chain VALUES(125,'PLAN-ASST-LS-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(126,'PLAN-ASST-LS-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(127,'PLAN-CHAIN-MUN',1,'Supervisor','PLAN-ASST-LS-MUN');
INSERT INTO planning_leave_approval_chain VALUES(128,'PLAN-CHAIN-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(129,'PLAN-CHAIN-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(130,'PLAN-CH-VAL-MUN',1,'Supervisor','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(131,'PLAN-CH-VAL-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(132,'PLAN-CH-VAL-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(133,'PLAN-SNR-VAL-MUN',1,'Supervisor','PLAN-CH-VAL-MUN');
INSERT INTO planning_leave_approval_chain VALUES(134,'PLAN-SNR-VAL-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(135,'PLAN-SNR-VAL-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(136,'PLAN-SNR-VAL-MGMT-MUN',1,'Supervisor','PLAN-CH-VAL-MUN');
INSERT INTO planning_leave_approval_chain VALUES(137,'PLAN-SNR-VAL-MGMT-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(138,'PLAN-SNR-VAL-MGMT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(139,'PLAN-SNR-VAL-TAX-MUN',1,'Supervisor','PLAN-CH-VAL-MUN');
INSERT INTO planning_leave_approval_chain VALUES(140,'PLAN-SNR-VAL-TAX-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(141,'PLAN-SNR-VAL-TAX-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(142,'PLAN-MGMT-MUN',1,'Supervisor','PLAN-SNR-VAL-MUN');
INSERT INTO planning_leave_approval_chain VALUES(143,'PLAN-MGMT-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(144,'PLAN-MGMT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(145,'PLAN-VAL-TAX-MUN',1,'Supervisor','PLAN-SNR-VAL-TAX-MUN');
INSERT INTO planning_leave_approval_chain VALUES(146,'PLAN-VAL-TAX-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(147,'PLAN-VAL-TAX-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(148,'PLAN-ASST-VAL-MGMT-MUN',1,'Supervisor','PLAN-MGMT-MUN');
INSERT INTO planning_leave_approval_chain VALUES(149,'PLAN-ASST-VAL-MGMT-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(150,'PLAN-ASST-VAL-MGMT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(151,'PLAN-ASST-VAL-TAX-MUN',1,'Supervisor','PLAN-VAL-TAX-MUN');
INSERT INTO planning_leave_approval_chain VALUES(152,'PLAN-ASST-VAL-TAX-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(153,'PLAN-ASST-VAL-TAX-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(154,'PLAN-FIELD-MUN',1,'Supervisor','PLAN-CH-VAL-MUN');
INSERT INTO planning_leave_approval_chain VALUES(155,'PLAN-FIELD-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(156,'PLAN-FIELD-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(157,'PLAN-DATA-MUN',1,'Supervisor','PLAN-ASST-VAL-MGMT-MUN');
INSERT INTO planning_leave_approval_chain VALUES(158,'PLAN-DATA-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(159,'PLAN-DATA-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(160,'PLAN-REV-MUN',1,'Supervisor','PLAN-CH-VAL-MUN');
INSERT INTO planning_leave_approval_chain VALUES(161,'PLAN-REV-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(162,'PLAN-REV-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(163,'PLAN-CH-SOC-MUN',1,'Supervisor','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(164,'PLAN-CH-SOC-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(165,'PLAN-CH-SOC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(166,'PLAN-SNR-SOC-MUN',1,'Supervisor','PLAN-CH-SOC-MUN');
INSERT INTO planning_leave_approval_chain VALUES(167,'PLAN-SNR-SOC-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(168,'PLAN-SNR-SOC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(169,'PLAN-SOC-MUN',1,'Supervisor','PLAN-SNR-SOC-MUN');
INSERT INTO planning_leave_approval_chain VALUES(170,'PLAN-SOC-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(171,'PLAN-SOC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(172,'PLAN-SNR-ENV-MUN',1,'Supervisor','PLAN-CH-SOC-MUN');
INSERT INTO planning_leave_approval_chain VALUES(173,'PLAN-SNR-ENV-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(174,'PLAN-SNR-ENV-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(175,'PLAN-ENV-MUN',1,'Supervisor','PLAN-SNR-ENV-MUN');
INSERT INTO planning_leave_approval_chain VALUES(176,'PLAN-ENV-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(177,'PLAN-ENV-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(178,'PLAN-SOC-HEALTH-MUN',1,'Supervisor','PLAN-SNR-SOC-MUN');
INSERT INTO planning_leave_approval_chain VALUES(179,'PLAN-SOC-HEALTH-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(180,'PLAN-SOC-HEALTH-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(181,'PLAN-SOC-FISH-MUN',1,'Supervisor','PLAN-SNR-SOC-MUN');
INSERT INTO planning_leave_approval_chain VALUES(182,'PLAN-SOC-FISH-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(183,'PLAN-SOC-FISH-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(184,'PLAN-SNR-ME-MUN',1,'Supervisor','PLAN-CH-SOC-MUN');
INSERT INTO planning_leave_approval_chain VALUES(185,'PLAN-SNR-ME-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(186,'PLAN-SNR-ME-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(187,'PLAN-ME-MUN',1,'Supervisor','PLAN-SNR-ME-MUN');
INSERT INTO planning_leave_approval_chain VALUES(188,'PLAN-ME-MUN',2,'Head of Department','PLAN-DIR-MUN');
INSERT INTO planning_leave_approval_chain VALUES(189,'PLAN-ME-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO planning_leave_approval_chain VALUES(190,'TOWN-CLERK-CITY',1,'Supervisor',NULL);
INSERT INTO planning_leave_approval_chain VALUES(191,'TOWN-CLERK-CITY',2,'Head of Council',NULL);
INSERT INTO planning_leave_approval_chain VALUES(192,'TOWN-CLERK-CITY',3,'Head of Council',NULL);
INSERT INTO planning_leave_approval_chain VALUES(193,'PLAN-DIR-CITY',1,'Supervisor','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(194,'PLAN-DIR-CITY',2,'Head of Department','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(195,'PLAN-DIR-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(196,'PLAN-ADIR-PHY-CITY',1,'Supervisor','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(197,'PLAN-ADIR-PHY-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(198,'PLAN-ADIR-PHY-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(199,'PLAN-SNR-TOWN-CITY',1,'Supervisor','PLAN-ADIR-PHY-CITY');
INSERT INTO planning_leave_approval_chain VALUES(200,'PLAN-SNR-TOWN-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(201,'PLAN-SNR-TOWN-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(202,'PLAN-TOWN-CITY',1,'Supervisor','PLAN-SNR-TOWN-CITY');
INSERT INTO planning_leave_approval_chain VALUES(203,'PLAN-TOWN-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(204,'PLAN-TOWN-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(205,'PLAN-ASST-TOWN-CITY',1,'Supervisor','PLAN-TOWN-CITY');
INSERT INTO planning_leave_approval_chain VALUES(206,'PLAN-ASST-TOWN-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(207,'PLAN-ASST-TOWN-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(208,'PLAN-CH-BI-CITY',1,'Supervisor','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(209,'PLAN-CH-BI-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(210,'PLAN-CH-BI-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(211,'PLAN-SNR-BI-CITY',1,'Supervisor','PLAN-CH-BI-CITY');
INSERT INTO planning_leave_approval_chain VALUES(212,'PLAN-SNR-BI-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(213,'PLAN-SNR-BI-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(214,'PLAN-SUPT-BI-CITY',1,'Supervisor','PLAN-SNR-BI-CITY');
INSERT INTO planning_leave_approval_chain VALUES(215,'PLAN-SUPT-BI-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(216,'PLAN-SUPT-BI-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(217,'PLAN-BI-CITY',1,'Supervisor','PLAN-SUPT-BI-CITY');
INSERT INTO planning_leave_approval_chain VALUES(218,'PLAN-BI-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(219,'PLAN-BI-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(220,'PLAN-SNR-LS-CITY',1,'Supervisor','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(221,'PLAN-SNR-LS-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(222,'PLAN-SNR-LS-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(223,'PLAN-LS-CITY',1,'Supervisor','PLAN-SNR-LS-CITY');
INSERT INTO planning_leave_approval_chain VALUES(224,'PLAN-LS-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(225,'PLAN-LS-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(226,'PLAN-ASST-LS-CITY',1,'Supervisor','PLAN-LS-CITY');
INSERT INTO planning_leave_approval_chain VALUES(227,'PLAN-ASST-LS-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(228,'PLAN-ASST-LS-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(229,'PLAN-CHAIN-CITY',1,'Supervisor','PLAN-ASST-LS-CITY');
INSERT INTO planning_leave_approval_chain VALUES(230,'PLAN-CHAIN-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(231,'PLAN-CHAIN-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(232,'PLAN-CH-SOC-CITY',1,'Supervisor','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(233,'PLAN-CH-SOC-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(234,'PLAN-CH-SOC-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(235,'PLAN-SNR-SOC-CITY',1,'Supervisor','PLAN-CH-SOC-CITY');
INSERT INTO planning_leave_approval_chain VALUES(236,'PLAN-SNR-SOC-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(237,'PLAN-SNR-SOC-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(238,'PLAN-SOC-CITY',1,'Supervisor','PLAN-SNR-SOC-CITY');
INSERT INTO planning_leave_approval_chain VALUES(239,'PLAN-SOC-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(240,'PLAN-SOC-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(241,'PLAN-SNR-ENV-CITY',1,'Supervisor','PLAN-CH-SOC-CITY');
INSERT INTO planning_leave_approval_chain VALUES(242,'PLAN-SNR-ENV-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(243,'PLAN-SNR-ENV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(244,'PLAN-ENV-CITY',1,'Supervisor','PLAN-SNR-ENV-CITY');
INSERT INTO planning_leave_approval_chain VALUES(245,'PLAN-ENV-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(246,'PLAN-ENV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(247,'PLAN-SNR-ME-CITY',1,'Supervisor','PLAN-CH-SOC-CITY');
INSERT INTO planning_leave_approval_chain VALUES(248,'PLAN-SNR-ME-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(249,'PLAN-SNR-ME-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(250,'PLAN-ME-CITY',1,'Supervisor','PLAN-SNR-ME-CITY');
INSERT INTO planning_leave_approval_chain VALUES(251,'PLAN-ME-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(252,'PLAN-ME-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(253,'PLAN-DATA-CITY',1,'Supervisor','PLAN-ME-CITY');
INSERT INTO planning_leave_approval_chain VALUES(254,'PLAN-DATA-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(255,'PLAN-DATA-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO planning_leave_approval_chain VALUES(256,'PLAN-GENDER-CITY',1,'Supervisor','PLAN-CH-SOC-CITY');
INSERT INTO planning_leave_approval_chain VALUES(257,'PLAN-GENDER-CITY',2,'Head of Department','PLAN-DIR-CITY');
INSERT INTO planning_leave_approval_chain VALUES(258,'PLAN-GENDER-CITY',3,'Head of Council','TOWN-CLERK-CITY');
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
INSERT INTO finance_positions VALUES('FIN-ASSTACC-TOWN','Assistant Accountant','LGSS/13',2,'FIN-ACC-TOWN',1,2,1,5,0,0,'FIN-ACC-AST-TOW-01');
INSERT INTO finance_positions VALUES('FIN-STORE-TOWN','Stores Officer','LGSS/17',1,'FIN-CHACC-TOWN',1,2,1,4,0,0,'FIN-STO-OFF-TOW-01');
INSERT INTO finance_positions VALUES('FIN-CHLIC-TOWN','Chief Licensing Officer','LGSS/07',1,'FIN-DIR-TOWN',1,2,1,3,0,0,'FIN-COM-CHIEFLIC-TOW-01');
INSERT INTO finance_positions VALUES('FIN-LIC-TOWN','Licensing Officer','LGSS/08',2,'FIN-CHLIC-TOWN',1,2,1,4,0,0,'FIN-COM-LIC-TOW-01');
INSERT INTO finance_positions VALUES('FIN-CASH-TOWN','Cashier','LGSS/13',2,'FIN-LIC-TOWN',1,2,1,5,0,0,'FIN-REV-CASH-TOW-01');
INSERT INTO finance_positions VALUES('FIN-REV-TOWN','Revenue Collector','LGSS/18',3,'FIN-CASH-TOWN',1,2,1,6,0,0,'FIN-REV-COLL-TOW-01');
INSERT INTO finance_positions VALUES('FIN-HLTH-STORE-TOWN','Stores Officer - Health','LGSS/08',1,'FIN-DIR-TOWN',2,3,1,3,0,0,'FIN-STO-OFFHLT-TOW-01');
INSERT INTO finance_positions VALUES('FIN-HLTH-ASSTSTORE-TOWN','Assistant Stores Officer - Health','LGSS/10',1,'FIN-HLTH-STORE-TOWN',2,3,1,4,0,0,'FIN-STO-ASTHLT-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-MGR-TOWN','Commercial Manager','LGSS/06',1,'FIN-DIR-TOWN',3,4,1,3,0,1,'FIN-COM-MGR-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-ASSTMGR-TOWN','Assistant Commercial Manager','LGSS/07',1,'FIN-COMM-MGR-TOWN',3,4,1,4,0,0,'FIN-COM-ASTMGR-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-HOUSE-TOWN','House Keeper','G3',1,'FIN-COMM-ASSTMGR-TOWN',3,4,1,5,0,0,'FIN-SUP-HOUSE-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-RECEPT-TOWN','Receptionist','G1',4,'FIN-COMM-HOUSE-TOWN',3,4,1,6,0,0,'FIN-SUP-REC-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-BARMAN-TOWN','Barman','G2',3,'FIN-COMM-HOUSE-TOWN',3,4,1,6,0,0,'FIN-COM-BAR-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-WAITER-TOWN','Waiter','G2',2,'FIN-COMM-HOUSE-TOWN',3,4,1,6,0,0,'FIN-COM-WAIT-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-COOK-TOWN','Cook','G1',2,'FIN-COMM-HOUSE-TOWN',3,4,1,6,0,0,'FIN-COM-COOK-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-CHEF-TOWN','Chef','G1',2,'FIN-COMM-HOUSE-TOWN',3,4,1,6,0,0,'FIN-COM-CHEF-TOW-01');
INSERT INTO finance_positions VALUES('FIN-COMM-LAUNDRY-TOWN','Laundryman','G3',3,'FIN-COMM-HOUSE-TOWN',3,4,1,6,0,0,'FIN-SUP-LAUN-TOW-01');
INSERT INTO finance_positions VALUES('FIN-STORE-OFF-TOWN','Store Officer','LGSS/08',1,'FIN-DIR-TOWN',4,5,1,3,0,1,'FIN-STO-OFF-TOW-02');
INSERT INTO finance_positions VALUES('FIN-STORE-ASST-TOWN','Assistant Stores Officer','LGSS/10',1,'FIN-STORE-OFF-TOWN',4,5,1,4,0,0,'FIN-STO-AST-TOW-01');
INSERT INTO finance_positions VALUES('FIN-DIR-MUN','Director of Finance','LGSS/04',1,'TOWN-CLERK-MUN',NULL,6,2,2,1,0,'FIN-LEAD-DIR-MUN-01');
INSERT INTO finance_positions VALUES('FIN-CHACC-MUN','Chief Accountant','LGSS/06',1,'FIN-DIR-MUN',5,7,2,3,0,1,'FIN-ACC-CHIEF-MUN-01');
INSERT INTO finance_positions VALUES('FIN-SNRACC-MUN','Senior Accountant','LGSS/07',5,'FIN-CHACC-MUN',5,7,2,4,0,0,'FIN-ACC-SNR-MUN-01');
INSERT INTO finance_positions VALUES('FIN-ACC-MUN','Accountant','LGSS/10',5,'FIN-SNRACC-MUN',5,7,2,5,0,0,'FIN-ACC-OFF-MUN-01');
INSERT INTO finance_positions VALUES('FIN-ASSTACC-MUN','Assistant Accountant','LGSS/11',4,'FIN-ACC-MUN',5,7,2,6,0,0,'FIN-ACC-AST-MUN-01');
INSERT INTO finance_positions VALUES('FIN-ACCS-MUN','Accounts Assistant','LGSS/13',10,'FIN-ASSTACC-MUN',5,7,2,7,0,0,'FIN-ACC-ASTACC-MUN-01');
INSERT INTO finance_positions VALUES('FIN-REV-MUN','Revenue Collector','LGSS/18',35,'FIN-ACCS-MUN',5,7,2,8,0,0,'FIN-REV-COLL-MUN-01');
INSERT INTO finance_positions VALUES('FIN-STORE-CTRL-MUN','Stores Controller','LGSS/07',1,'FIN-DIR-MUN',6,8,2,3,0,1,'FIN-STO-CONTROLLER-MUN-01');
INSERT INTO finance_positions VALUES('FIN-STORE-OFF-MUN','Stores Officer','LGSS/08',2,'FIN-STORE-CTRL-MUN',6,8,2,4,0,0,'FIN-STO-OFF-MUN-01');
INSERT INTO finance_positions VALUES('FIN-STORE-ASST-MUN','Assistant Stores Officer','LGSS/10',2,'FIN-STORE-OFF-MUN',6,8,2,5,0,0,'FIN-STO-AST-MUN-01');
INSERT INTO finance_positions VALUES('FIN-DIR-CITY','Director of Finance','LGSS/03',1,'TOWN-CLERK-CITY',NULL,9,3,2,1,0,'FIN-LEAD-DIR-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ADIR-REV-CITY','Assistant Director - Revenue','LGSS/05',1,'FIN-DIR-CITY',7,10,3,3,1,1,'FIN-LEAD-ADIR-REV-CIT-01');
INSERT INTO finance_positions VALUES('FIN-CHACC-REV-CITY','Chief Accountant - Revenue','LGSS/06',1,'FIN-ADIR-REV-CITY',7,10,3,4,0,0,'FIN-REV-CHIEF-CIT-01');
INSERT INTO finance_positions VALUES('FIN-SNRACC-REV-CITY','Senior Accountant - Revenue','LGSS/07',2,'FIN-CHACC-REV-CITY',7,10,3,5,0,0,'FIN-REV-SNR-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ACC-REV-CITY','Accountant - Revenue','LGSS/10',4,'FIN-SNRACC-REV-CITY',7,10,3,6,0,0,'FIN-REV-ACC-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ASSTACC-REV-CITY','Assistant Accountant - Revenue','LGSS/11',4,'FIN-ACC-REV-CITY',7,10,3,7,0,0,'FIN-REV-ASTACC-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ACCS-REV-CITY','Accounts Assistant - Revenue','LGSS/13',4,'FIN-ASSTACC-REV-CITY',7,10,3,8,0,0,'FIN-ACC-AST-CIT-01');
INSERT INTO finance_positions VALUES('FIN-REV-CITY','Revenue Collector','LGSS/18',100,'FIN-ACCS-REV-CITY',7,10,3,9,0,0,'FIN-REV-COLL-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ADIR-EXP-CITY','Assistant Director - Expenditure','LGSS/05',1,'FIN-DIR-CITY',8,11,3,3,1,1,'FIN-LEAD-ADIR-EXP-CIT-01');
INSERT INTO finance_positions VALUES('FIN-CHACC-EXP-CITY','Chief Accountant - Expenditure','LGSS/06',3,'FIN-ADIR-EXP-CITY',8,11,3,4,0,0,'FIN-EXP-CHIEF-CIT-01');
INSERT INTO finance_positions VALUES('FIN-SNRACC-EXP-CITY','Senior Accountant - Expenditure','LGSS/07',3,'FIN-CHACC-EXP-CITY',8,11,3,5,0,0,'FIN-EXP-SNR-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ACC-EXP-CITY','Accountant - Expenditure','LGSS/10',6,'FIN-SNRACC-EXP-CITY',8,11,3,6,0,0,'FIN-EXP-ACC-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ASSTACC-EXP-CITY','Assistant Accountant - Expenditure','LGSS/11',8,'FIN-ACC-EXP-CITY',8,11,3,7,0,0,'FIN-EXP-ASTACC-CIT-01');
INSERT INTO finance_positions VALUES('FIN-ACCS-EXP-CITY','Accounts Assistant - Expenditure','LGSS/13',12,'FIN-ASSTACC-EXP-CITY',8,11,3,8,0,0,'FIN-EXP-AST-CIT-01');
INSERT INTO finance_positions VALUES('FIN-STORE-CTRL-CITY','Stores Controller','LGSS/07',1,'FIN-DIR-CITY',9,12,3,3,0,1,'FIN-STO-CONTROLLER-CIT-01');
INSERT INTO finance_positions VALUES('FIN-STORE-OFF-CITY','Stores Officer','LGSS/08',5,'FIN-STORE-CTRL-CITY',9,12,3,4,0,0,'FIN-STO-OFF-CIT-01');
INSERT INTO finance_positions VALUES(NULL,'Assistant Accountant - Health',NULL,1,NULL,NULL,NULL,1,NULL,0,0,'FIN-HLT-ASTACC-TOW-01');
INSERT INTO finance_positions VALUES(NULL,'Accounts Assistant - Health',NULL,2,NULL,NULL,NULL,1,NULL,0,0,'FIN-HLT-AST-TOW-01');
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
INSERT INTO finance_leave_approval_chain VALUES(13,'FIN-ASSTACC-TOWN',1,'Supervisor','FIN-ACC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(14,'FIN-ASSTACC-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(15,'FIN-ASSTACC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(16,'FIN-STORE-TOWN',1,'Supervisor','FIN-CHACC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(17,'FIN-STORE-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(18,'FIN-STORE-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(19,'FIN-CHLIC-TOWN',1,'Supervisor','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(20,'FIN-CHLIC-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(21,'FIN-CHLIC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(22,'FIN-LIC-TOWN',1,'Supervisor','FIN-CHLIC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(23,'FIN-LIC-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(24,'FIN-LIC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(25,'FIN-CASH-TOWN',1,'Supervisor','FIN-LIC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(26,'FIN-CASH-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(27,'FIN-CASH-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(28,'FIN-REV-TOWN',1,'Supervisor','FIN-CASH-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(29,'FIN-REV-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(30,'FIN-REV-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(31,'FIN-HLTH-ASSTACC-TOWN',1,'Supervisor','FIN-ACC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(32,'FIN-HLTH-ASSTACC-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(33,'FIN-HLTH-ASSTACC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(34,'FIN-HLTH-ACCS-TOWN',1,'Supervisor','FIN-HLTH-ASSTACC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(35,'FIN-HLTH-ACCS-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(36,'FIN-HLTH-ACCS-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(37,'FIN-HLTH-STORE-TOWN',1,'Supervisor','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(38,'FIN-HLTH-STORE-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(39,'FIN-HLTH-STORE-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(40,'FIN-HLTH-ASSTSTORE-TOWN',1,'Supervisor','FIN-HLTH-STORE-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(41,'FIN-HLTH-ASSTSTORE-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(42,'FIN-HLTH-ASSTSTORE-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(43,'FIN-COMM-MGR-TOWN',1,'Supervisor','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(44,'FIN-COMM-MGR-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(45,'FIN-COMM-MGR-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(46,'FIN-COMM-ASSTMGR-TOWN',1,'Supervisor','FIN-COMM-MGR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(47,'FIN-COMM-ASSTMGR-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(48,'FIN-COMM-ASSTMGR-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(49,'FIN-COMM-HOUSE-TOWN',1,'Supervisor','FIN-COMM-ASSTMGR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(50,'FIN-COMM-HOUSE-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(51,'FIN-COMM-HOUSE-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(52,'FIN-COMM-RECEPT-TOWN',1,'Supervisor','FIN-COMM-HOUSE-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(53,'FIN-COMM-RECEPT-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(54,'FIN-COMM-RECEPT-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(55,'FIN-COMM-BARMAN-TOWN',1,'Supervisor','FIN-COMM-HOUSE-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(56,'FIN-COMM-BARMAN-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(57,'FIN-COMM-BARMAN-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(58,'FIN-COMM-WAITER-TOWN',1,'Supervisor','FIN-COMM-HOUSE-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(59,'FIN-COMM-WAITER-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(60,'FIN-COMM-WAITER-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(61,'FIN-COMM-COOK-TOWN',1,'Supervisor','FIN-COMM-HOUSE-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(62,'FIN-COMM-COOK-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(63,'FIN-COMM-COOK-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(64,'FIN-COMM-CHEF-TOWN',1,'Supervisor','FIN-COMM-HOUSE-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(65,'FIN-COMM-CHEF-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(66,'FIN-COMM-CHEF-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(67,'FIN-COMM-LAUNDRY-TOWN',1,'Supervisor','FIN-COMM-HOUSE-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(68,'FIN-COMM-LAUNDRY-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(69,'FIN-COMM-LAUNDRY-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(70,'FIN-STORE-OFF-TOWN',1,'Supervisor','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(71,'FIN-STORE-OFF-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(72,'FIN-STORE-OFF-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(73,'FIN-STORE-ASST-TOWN',1,'Supervisor','FIN-STORE-OFF-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(74,'FIN-STORE-ASST-TOWN',2,'Head of Department','FIN-DIR-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(75,'FIN-STORE-ASST-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO finance_leave_approval_chain VALUES(76,'TOWN-CLERK-MUN',1,'Supervisor',NULL);
INSERT INTO finance_leave_approval_chain VALUES(77,'TOWN-CLERK-MUN',2,'Head of Council',NULL);
INSERT INTO finance_leave_approval_chain VALUES(78,'TOWN-CLERK-MUN',3,'Head of Council',NULL);
INSERT INTO finance_leave_approval_chain VALUES(79,'FIN-DIR-MUN',1,'Supervisor','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(80,'FIN-DIR-MUN',2,'Head of Department','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(81,'FIN-DIR-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(82,'FIN-CHACC-MUN',1,'Supervisor','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(83,'FIN-CHACC-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(84,'FIN-CHACC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(85,'FIN-SNRACC-MUN',1,'Supervisor','FIN-CHACC-MUN');
INSERT INTO finance_leave_approval_chain VALUES(86,'FIN-SNRACC-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(87,'FIN-SNRACC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(88,'FIN-ACC-MUN',1,'Supervisor','FIN-SNRACC-MUN');
INSERT INTO finance_leave_approval_chain VALUES(89,'FIN-ACC-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(90,'FIN-ACC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(91,'FIN-ASSTACC-MUN',1,'Supervisor','FIN-ACC-MUN');
INSERT INTO finance_leave_approval_chain VALUES(92,'FIN-ASSTACC-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(93,'FIN-ASSTACC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(94,'FIN-ACCS-MUN',1,'Supervisor','FIN-ASSTACC-MUN');
INSERT INTO finance_leave_approval_chain VALUES(95,'FIN-ACCS-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(96,'FIN-ACCS-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(97,'FIN-REV-MUN',1,'Supervisor','FIN-ACCS-MUN');
INSERT INTO finance_leave_approval_chain VALUES(98,'FIN-REV-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(99,'FIN-REV-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(100,'FIN-STORE-CTRL-MUN',1,'Supervisor','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(101,'FIN-STORE-CTRL-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(102,'FIN-STORE-CTRL-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(103,'FIN-STORE-OFF-MUN',1,'Supervisor','FIN-STORE-CTRL-MUN');
INSERT INTO finance_leave_approval_chain VALUES(104,'FIN-STORE-OFF-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(105,'FIN-STORE-OFF-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(106,'FIN-STORE-ASST-MUN',1,'Supervisor','FIN-STORE-OFF-MUN');
INSERT INTO finance_leave_approval_chain VALUES(107,'FIN-STORE-ASST-MUN',2,'Head of Department','FIN-DIR-MUN');
INSERT INTO finance_leave_approval_chain VALUES(108,'FIN-STORE-ASST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO finance_leave_approval_chain VALUES(109,'TOWN-CLERK-CITY',1,'Supervisor',NULL);
INSERT INTO finance_leave_approval_chain VALUES(110,'TOWN-CLERK-CITY',2,'Head of Council',NULL);
INSERT INTO finance_leave_approval_chain VALUES(111,'TOWN-CLERK-CITY',3,'Head of Council',NULL);
INSERT INTO finance_leave_approval_chain VALUES(112,'FIN-DIR-CITY',1,'Supervisor','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(113,'FIN-DIR-CITY',2,'Head of Department','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(114,'FIN-DIR-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(115,'FIN-ADIR-REV-CITY',1,'Supervisor','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(116,'FIN-ADIR-REV-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(117,'FIN-ADIR-REV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(118,'FIN-CHACC-REV-CITY',1,'Supervisor','FIN-ADIR-REV-CITY');
INSERT INTO finance_leave_approval_chain VALUES(119,'FIN-CHACC-REV-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(120,'FIN-CHACC-REV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(121,'FIN-SNRACC-REV-CITY',1,'Supervisor','FIN-CHACC-REV-CITY');
INSERT INTO finance_leave_approval_chain VALUES(122,'FIN-SNRACC-REV-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(123,'FIN-SNRACC-REV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(124,'FIN-ACC-REV-CITY',1,'Supervisor','FIN-SNRACC-REV-CITY');
INSERT INTO finance_leave_approval_chain VALUES(125,'FIN-ACC-REV-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(126,'FIN-ACC-REV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(127,'FIN-ASSTACC-REV-CITY',1,'Supervisor','FIN-ACC-REV-CITY');
INSERT INTO finance_leave_approval_chain VALUES(128,'FIN-ASSTACC-REV-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(129,'FIN-ASSTACC-REV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(130,'FIN-ACCS-REV-CITY',1,'Supervisor','FIN-ASSTACC-REV-CITY');
INSERT INTO finance_leave_approval_chain VALUES(131,'FIN-ACCS-REV-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(132,'FIN-ACCS-REV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(133,'FIN-REV-CITY',1,'Supervisor','FIN-ACCS-REV-CITY');
INSERT INTO finance_leave_approval_chain VALUES(134,'FIN-REV-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(135,'FIN-REV-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(136,'FIN-ADIR-EXP-CITY',1,'Supervisor','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(137,'FIN-ADIR-EXP-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(138,'FIN-ADIR-EXP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(139,'FIN-CHACC-EXP-CITY',1,'Supervisor','FIN-ADIR-EXP-CITY');
INSERT INTO finance_leave_approval_chain VALUES(140,'FIN-CHACC-EXP-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(141,'FIN-CHACC-EXP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(142,'FIN-SNRACC-EXP-CITY',1,'Supervisor','FIN-CHACC-EXP-CITY');
INSERT INTO finance_leave_approval_chain VALUES(143,'FIN-SNRACC-EXP-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(144,'FIN-SNRACC-EXP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(145,'FIN-ACC-EXP-CITY',1,'Supervisor','FIN-SNRACC-EXP-CITY');
INSERT INTO finance_leave_approval_chain VALUES(146,'FIN-ACC-EXP-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(147,'FIN-ACC-EXP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(148,'FIN-ASSTACC-EXP-CITY',1,'Supervisor','FIN-ACC-EXP-CITY');
INSERT INTO finance_leave_approval_chain VALUES(149,'FIN-ASSTACC-EXP-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(150,'FIN-ASSTACC-EXP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(151,'FIN-ACCS-EXP-CITY',1,'Supervisor','FIN-ASSTACC-EXP-CITY');
INSERT INTO finance_leave_approval_chain VALUES(152,'FIN-ACCS-EXP-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(153,'FIN-ACCS-EXP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(154,'FIN-STORE-CTRL-CITY',1,'Supervisor','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(155,'FIN-STORE-CTRL-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(156,'FIN-STORE-CTRL-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO finance_leave_approval_chain VALUES(157,'FIN-STORE-OFF-CITY',1,'Supervisor','FIN-STORE-CTRL-CITY');
INSERT INTO finance_leave_approval_chain VALUES(158,'FIN-STORE-OFF-CITY',2,'Head of Department','FIN-DIR-CITY');
INSERT INTO finance_leave_approval_chain VALUES(159,'FIN-STORE-OFF-CITY',3,'Head of Council','TOWN-CLERK-CITY');
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
INSERT INTO legal_units VALUES(11,'Estates Unit','LEG-EST-UNIT-CC',7,3,NULL);
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
INSERT INTO legal_positions VALUES('LEG-REG-TOWN','Registry Clerk','LGSS/17',1,'LEG-SRASST-TOWN',1,1,1,4,0,0,'LEG-ADM-REG-TOW-01');
INSERT INTO legal_positions VALUES('LEG-DIR-MUN','Director Legal Services','LGSS/04',1,'TOWN-CLERK-MUN',NULL,2,2,2,1,0,'LEG-LEAD-DIR-MUN-01');
INSERT INTO legal_positions VALUES('LEG-ADV-LIT-MUN','Council Advocate - Litigation','LGSS/05',1,'LEG-DIR-MUN',NULL,3,2,3,1,1,'LEG-LEAD-ADV-LIT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-OFF-LIT-MUN','Legal Officer - Litigation','LGSS/06',1,'LEG-ADV-LIT-MUN',2,3,2,4,0,1,'LEG-LIT-OFF-LIT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-LIT-MUN','Senior Legal Assistant - Litigation','LGSS/07',1,'LEG-OFF-LIT-MUN',2,3,2,5,0,0,'LEG-LIT-SRASST-LIT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-REG-LIT-MUN','Registry Clerk - Litigation','LGSS/17',1,'LEG-SRASST-LIT-MUN',2,3,2,6,0,0,'LEG-LIT-REG-LIT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-REG-DEEDS-MUN','Registry Clerk - Deeds','LGSS/17',5,'LEG-ADV-LIT-MUN',3,3,2,4,0,1,'LEG-LIT-REG-DEEDS-MUN-01');
INSERT INTO legal_positions VALUES('LEG-OFF-PROSE-MUN','Legal Officer - Prosecution','LGSS/06',1,'LEG-ADV-LIT-MUN',4,3,2,4,0,1,'LEG-LIT-OFF-PROSE-MUN-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-PROSE-MUN','Senior Legal Assistant - Prosecution','LGSS/07',1,'LEG-OFF-PROSE-MUN',4,3,2,5,0,0,'LEG-LIT-SRASST-PROSE-MUN-01');
INSERT INTO legal_positions VALUES('LEG-ASST-PROSE-MUN','Legal Assistant - Prosecution','LGSS/10',1,'LEG-SRASST-PROSE-MUN',4,3,2,6,0,0,'LEG-LIT-AST-PROSE-MUN-01');
INSERT INTO legal_positions VALUES('LEG-REG-PROSE-MUN','Registry Clerk - Prosecution','LGSS/17',1,'LEG-ASST-PROSE-MUN',4,3,2,7,0,0,'LEG-LIT-REG-PROSE-MUN-01');
INSERT INTO legal_positions VALUES('LEG-ADV-EST-MUN','Council Advocate - Estates & Contracts','LGSS/05',1,'LEG-DIR-MUN',NULL,4,2,3,1,1,'LEG-LEAD-ADV-ESTCON-MUN-01');
INSERT INTO legal_positions VALUES('LEG-OFF-CONT-MUN','Legal Officer - Contracts','LGSS/06',1,'LEG-ADV-EST-MUN',5,4,2,4,0,1,'LEG-ESTCON-OFF-CONT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-CONT-MUN','Senior Legal Assistant - Contracts','LGSS/07',1,'LEG-OFF-CONT-MUN',5,4,2,5,0,0,'LEG-ESTCON-SRASST-CONT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-ASST-CONT-MUN','Legal Assistant - Contracts','LGSS/10',1,'LEG-SRASST-CONT-MUN',5,4,2,6,0,0,'LEG-ESTCON-AST-CONT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-REG-CONT-MUN','Registry Clerk - Contracts','LGSS/17',1,'LEG-ASST-CONT-MUN',5,4,2,7,0,0,'LEG-ESTCON-REG-CONT-MUN-01');
INSERT INTO legal_positions VALUES('LEG-OFF-LIC-MUN','Legal Officer - Licensing','LGSS/06',1,'LEG-ADV-EST-MUN',6,4,2,4,0,1,'LEG-ESTCON-OFF-LIC-MUN-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-LIC-MUN','Senior Legal Assistant - Licensing','LGSS/07',1,'LEG-OFF-LIC-MUN',6,4,2,5,0,0,'LEG-ESTCON-SRASST-LIC-MUN-01');
INSERT INTO legal_positions VALUES('LEG-ASST-LIC-MUN','Legal Assistant - Licensing','LGSS/10',1,'LEG-SRASST-LIC-MUN',6,4,2,6,0,0,'LEG-ESTCON-AST-LIC-MUN-01');
INSERT INTO legal_positions VALUES('LEG-LIC-OFF-MUN','Licensing Officer','LGSS/06',2,'LEG-ADV-EST-MUN',6,4,2,4,0,0,'LEG-ESTCON-LIC-MUN-01');
INSERT INTO legal_positions VALUES('LEG-REG-LIC-MUN','Registry Clerk - Licensing','LGSS/17',1,'LEG-LIC-OFF-MUN',6,4,2,5,0,0,'LEG-ESTCON-REG-LIC-MUN-01');
INSERT INTO legal_positions VALUES('LEG-OFF-EST-MUN','Legal Officer - Estates','LGSS/06',1,'LEG-ADV-EST-MUN',7,4,2,4,0,1,'LEG-ESTCON-OFF-EST-MUN-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-EST-MUN','Senior Legal Assistant - Estates','LGSS/07',1,'LEG-OFF-EST-MUN',7,4,2,5,0,0,'LEG-ESTCON-SRASST-EST-MUN-01');
INSERT INTO legal_positions VALUES('LEG-ASST-EST-MUN','Legal Assistant - Estates','LGSS/10',1,'LEG-SRASST-EST-MUN',7,4,2,6,0,0,'LEG-ESTCON-AST-EST-MUN-01');
INSERT INTO legal_positions VALUES('LEG-REG-EST-MUN','Registry Clerk - Estates','LGSS/17',1,'LEG-ASST-EST-MUN',7,4,2,7,0,0,'LEG-ESTCON-REG-EST-MUN-01');
INSERT INTO legal_positions VALUES('LEG-DIR-CITY','Director Legal Services','LGSS/03',1,'TOWN-CLERK-CITY',NULL,5,3,2,1,0,'LEG-LEAD-DIR-CIT-01');
INSERT INTO legal_positions VALUES('LEG-ADV-LIT-CITY','Council Advocate - Litigation & Deeds','LGSS/05',1,'LEG-DIR-CITY',NULL,6,3,3,1,1,'LEG-LIT-ADV-CIT-01');
INSERT INTO legal_positions VALUES('LEG-OFF-LIT-CITY','Legal Officer - Litigation','LGSS/06',2,'LEG-ADV-LIT-CITY',8,6,3,4,0,1,'LEG-LIT-OFF-LIT-CIT-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-LIT-CITY','Senior Legal Assistant - Litigation','LGSS/07',2,'LEG-OFF-LIT-CITY',8,6,3,5,0,0,'LEG-LIT-SRASST-LIT-CIT-01');
INSERT INTO legal_positions VALUES('LEG-ASST-LIT-CITY','Legal Assistant - Litigation','LGSS/10',4,'LEG-SRASST-LIT-CITY',8,6,3,6,0,0,'LEG-LIT-AST-LIT-CIT-01');
INSERT INTO legal_positions VALUES('LEG-OFF-DEEDS-CITY','Legal Officer - Deeds','LGSS/06',2,'LEG-ADV-LIT-CITY',9,6,3,4,0,1,'LEG-LIT-OFF-DEEDS-CIT-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-DEEDS-CITY','Senior Legal Assistant - Deeds','LGSS/07',2,'LEG-OFF-DEEDS-CITY',9,6,3,5,0,0,'LEG-LIT-SRASST-DEEDS-CIT-01');
INSERT INTO legal_positions VALUES('LEG-ASST-DEEDS-CITY','Legal Assistant - Deeds','LGSS/10',4,'LEG-SRASST-DEEDS-CITY',9,6,3,6,0,0,'LEG-LIT-AST-DEEDS-CIT-01');
INSERT INTO legal_positions VALUES('LEG-ADV-EST-CITY','Council Advocate - Estates & Contracts','LGSS/05',1,'LEG-DIR-CITY',NULL,7,3,3,1,1,'LEG-ESTCON-ADV-CIT-01');
INSERT INTO legal_positions VALUES('LEG-OFF-CONT-CITY','Legal Officer - Contracts & Licensing','LGSS/06',1,'LEG-ADV-EST-CITY',10,7,3,4,0,1,'LEG-ESTCON-OFF-CONT-CIT-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-CONT-CITY','Senior Legal Assistant - Contracts & Licensing','LGSS/07',1,'LEG-OFF-CONT-CITY',10,7,3,5,0,0,'LEG-ESTCON-SRASST-CONT-CIT-01');
INSERT INTO legal_positions VALUES('LEG-ASST-CONT-CITY','Legal Assistant - Contracts & Licensing','LGSS/10',3,'LEG-SRASST-CONT-CITY',10,7,3,6,0,0,'LEG-ESTCON-AST-CONT-CIT-01');
INSERT INTO legal_positions VALUES('LEG-LIC-CITY','Licensing Officer','LGSS/10',2,'LEG-OFF-CONT-CITY',10,7,3,5,0,0,'LEG-ESTCON-LIC-CIT-01');
INSERT INTO legal_positions VALUES('LEG-OFF-EST-CITY','Legal Officer - Estates','LGSS/06',1,'LEG-ADV-EST-CITY',11,7,3,4,0,1,'LEG-ESTCON-OFF-EST-CIT-01');
INSERT INTO legal_positions VALUES('LEG-SRASST-EST-CITY','Senior Legal Assistant - Estates','LGSS/07',1,'LEG-OFF-EST-CITY',11,7,3,5,0,0,'LEG-ESTCON-SRASST-EST-CIT-01');
INSERT INTO legal_positions VALUES('LEG-ASST-EST-CITY','Legal Assistant - Estates','LGSS/10',1,'LEG-SRASST-EST-CITY',11,7,3,6,0,0,'LEG-ESTCON-AST-EST-CIT-01');
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
INSERT INTO legal_leave_approval_chain VALUES(13,'TOWN-CLERK-MUN',1,'Supervisor',NULL);
INSERT INTO legal_leave_approval_chain VALUES(14,'TOWN-CLERK-MUN',2,'Head of Council',NULL);
INSERT INTO legal_leave_approval_chain VALUES(15,'TOWN-CLERK-MUN',3,'Head of Council',NULL);
INSERT INTO legal_leave_approval_chain VALUES(16,'LEG-DIR-MUN',1,'Supervisor','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(17,'LEG-DIR-MUN',2,'Head of Department','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(18,'LEG-DIR-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(19,'LEG-ADV-LIT-MUN',1,'Supervisor','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(20,'LEG-ADV-LIT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(21,'LEG-ADV-LIT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(22,'LEG-ADV-EST-MUN',1,'Supervisor','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(23,'LEG-ADV-EST-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(24,'LEG-ADV-EST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(25,'LEG-OFF-LIT-MUN',1,'Supervisor','LEG-ADV-LIT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(26,'LEG-OFF-LIT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(27,'LEG-OFF-LIT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(28,'LEG-OFF-PROSE-MUN',1,'Supervisor','LEG-ADV-LIT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(29,'LEG-OFF-PROSE-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(30,'LEG-OFF-PROSE-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(31,'LEG-OFF-CONT-MUN',1,'Supervisor','LEG-ADV-EST-MUN');
INSERT INTO legal_leave_approval_chain VALUES(32,'LEG-OFF-CONT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(33,'LEG-OFF-CONT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(34,'LEG-OFF-LIC-MUN',1,'Supervisor','LEG-ADV-EST-MUN');
INSERT INTO legal_leave_approval_chain VALUES(35,'LEG-OFF-LIC-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(36,'LEG-OFF-LIC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(37,'LEG-OFF-EST-MUN',1,'Supervisor','LEG-ADV-EST-MUN');
INSERT INTO legal_leave_approval_chain VALUES(38,'LEG-OFF-EST-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(39,'LEG-OFF-EST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(40,'LEG-LIC-OFF-MUN',1,'Supervisor','LEG-ADV-EST-MUN');
INSERT INTO legal_leave_approval_chain VALUES(41,'LEG-LIC-OFF-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(42,'LEG-LIC-OFF-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(43,'LEG-SRASST-LIT-MUN',1,'Supervisor','LEG-OFF-LIT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(44,'LEG-SRASST-LIT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(45,'LEG-SRASST-LIT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(46,'LEG-SRASST-PROSE-MUN',1,'Supervisor','LEG-OFF-PROSE-MUN');
INSERT INTO legal_leave_approval_chain VALUES(47,'LEG-SRASST-PROSE-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(48,'LEG-SRASST-PROSE-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(49,'LEG-SRASST-CONT-MUN',1,'Supervisor','LEG-OFF-CONT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(50,'LEG-SRASST-CONT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(51,'LEG-SRASST-CONT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(52,'LEG-SRASST-LIC-MUN',1,'Supervisor','LEG-OFF-LIC-MUN');
INSERT INTO legal_leave_approval_chain VALUES(53,'LEG-SRASST-LIC-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(54,'LEG-SRASST-LIC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(55,'LEG-SRASST-EST-MUN',1,'Supervisor','LEG-OFF-EST-MUN');
INSERT INTO legal_leave_approval_chain VALUES(56,'LEG-SRASST-EST-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(57,'LEG-SRASST-EST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(58,'LEG-ASST-PROSE-MUN',1,'Supervisor','LEG-SRASST-PROSE-MUN');
INSERT INTO legal_leave_approval_chain VALUES(59,'LEG-ASST-PROSE-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(60,'LEG-ASST-PROSE-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(61,'LEG-ASST-CONT-MUN',1,'Supervisor','LEG-SRASST-CONT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(62,'LEG-ASST-CONT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(63,'LEG-ASST-CONT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(64,'LEG-ASST-LIC-MUN',1,'Supervisor','LEG-SRASST-LIC-MUN');
INSERT INTO legal_leave_approval_chain VALUES(65,'LEG-ASST-LIC-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(66,'LEG-ASST-LIC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(67,'LEG-ASST-EST-MUN',1,'Supervisor','LEG-SRASST-EST-MUN');
INSERT INTO legal_leave_approval_chain VALUES(68,'LEG-ASST-EST-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(69,'LEG-ASST-EST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(70,'LEG-REG-LIT-MUN',1,'Supervisor','LEG-SRASST-LIT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(71,'LEG-REG-LIT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(72,'LEG-REG-LIT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(73,'LEG-REG-DEEDS-MUN',1,'Supervisor','LEG-ADV-LIT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(74,'LEG-REG-DEEDS-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(75,'LEG-REG-DEEDS-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(76,'LEG-REG-PROSE-MUN',1,'Supervisor','LEG-ASST-PROSE-MUN');
INSERT INTO legal_leave_approval_chain VALUES(77,'LEG-REG-PROSE-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(78,'LEG-REG-PROSE-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(79,'LEG-REG-CONT-MUN',1,'Supervisor','LEG-ASST-CONT-MUN');
INSERT INTO legal_leave_approval_chain VALUES(80,'LEG-REG-CONT-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(81,'LEG-REG-CONT-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(82,'LEG-REG-LIC-MUN',1,'Supervisor','LEG-LIC-OFF-MUN');
INSERT INTO legal_leave_approval_chain VALUES(83,'LEG-REG-LIC-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(84,'LEG-REG-LIC-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(85,'LEG-REG-EST-MUN',1,'Supervisor','LEG-ASST-EST-MUN');
INSERT INTO legal_leave_approval_chain VALUES(86,'LEG-REG-EST-MUN',2,'Head of Department','LEG-DIR-MUN');
INSERT INTO legal_leave_approval_chain VALUES(87,'LEG-REG-EST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO legal_leave_approval_chain VALUES(88,'TOWN-CLERK-CITY',1,'Supervisor',NULL);
INSERT INTO legal_leave_approval_chain VALUES(89,'TOWN-CLERK-CITY',2,'Head of Council',NULL);
INSERT INTO legal_leave_approval_chain VALUES(90,'TOWN-CLERK-CITY',3,'Head of Council',NULL);
INSERT INTO legal_leave_approval_chain VALUES(91,'LEG-DIR-CITY',1,'Supervisor','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(92,'LEG-DIR-CITY',2,'Head of Department','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(93,'LEG-DIR-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(94,'LEG-ADV-LIT-CITY',1,'Supervisor','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(95,'LEG-ADV-LIT-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(96,'LEG-ADV-LIT-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(97,'LEG-ADV-EST-CITY',1,'Supervisor','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(98,'LEG-ADV-EST-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(99,'LEG-ADV-EST-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(100,'LEG-OFF-LIT-CITY',1,'Supervisor','LEG-ADV-LIT-CITY');
INSERT INTO legal_leave_approval_chain VALUES(101,'LEG-OFF-LIT-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(102,'LEG-OFF-LIT-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(103,'LEG-OFF-DEEDS-CITY',1,'Supervisor','LEG-ADV-LIT-CITY');
INSERT INTO legal_leave_approval_chain VALUES(104,'LEG-OFF-DEEDS-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(105,'LEG-OFF-DEEDS-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(106,'LEG-OFF-CONT-CITY',1,'Supervisor','LEG-ADV-EST-CITY');
INSERT INTO legal_leave_approval_chain VALUES(107,'LEG-OFF-CONT-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(108,'LEG-OFF-CONT-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(109,'LEG-OFF-EST-CITY',1,'Supervisor','LEG-ADV-EST-CITY');
INSERT INTO legal_leave_approval_chain VALUES(110,'LEG-OFF-EST-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(111,'LEG-OFF-EST-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(112,'LEG-LIC-CITY',1,'Supervisor','LEG-OFF-CONT-CITY');
INSERT INTO legal_leave_approval_chain VALUES(113,'LEG-LIC-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(114,'LEG-LIC-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(115,'LEG-SRASST-LIT-CITY',1,'Supervisor','LEG-OFF-LIT-CITY');
INSERT INTO legal_leave_approval_chain VALUES(116,'LEG-SRASST-LIT-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(117,'LEG-SRASST-LIT-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(118,'LEG-SRASST-DEEDS-CITY',1,'Supervisor','LEG-OFF-DEEDS-CITY');
INSERT INTO legal_leave_approval_chain VALUES(119,'LEG-SRASST-DEEDS-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(120,'LEG-SRASST-DEEDS-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(121,'LEG-SRASST-CONT-CITY',1,'Supervisor','LEG-OFF-CONT-CITY');
INSERT INTO legal_leave_approval_chain VALUES(122,'LEG-SRASST-CONT-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(123,'LEG-SRASST-CONT-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(124,'LEG-SRASST-EST-CITY',1,'Supervisor','LEG-OFF-EST-CITY');
INSERT INTO legal_leave_approval_chain VALUES(125,'LEG-SRASST-EST-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(126,'LEG-SRASST-EST-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(127,'LEG-ASST-LIT-CITY',1,'Supervisor','LEG-SRASST-LIT-CITY');
INSERT INTO legal_leave_approval_chain VALUES(128,'LEG-ASST-LIT-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(129,'LEG-ASST-LIT-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(130,'LEG-ASST-DEEDS-CITY',1,'Supervisor','LEG-SRASST-DEEDS-CITY');
INSERT INTO legal_leave_approval_chain VALUES(131,'LEG-ASST-DEEDS-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(132,'LEG-ASST-DEEDS-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(133,'LEG-ASST-CONT-CITY',1,'Supervisor','LEG-SRASST-CONT-CITY');
INSERT INTO legal_leave_approval_chain VALUES(134,'LEG-ASST-CONT-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(135,'LEG-ASST-CONT-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO legal_leave_approval_chain VALUES(136,'LEG-ASST-EST-CITY',1,'Supervisor','LEG-SRASST-EST-CITY');
INSERT INTO legal_leave_approval_chain VALUES(137,'LEG-ASST-EST-CITY',2,'Head of Department','LEG-DIR-CITY');
INSERT INTO legal_leave_approval_chain VALUES(138,'LEG-ASST-EST-CITY',3,'Head of Council','TOWN-CLERK-CITY');
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
INSERT INTO health_units VALUES(11,'Public Health Inspectorate Unit','HLTH-HI-CC',3,3,NULL);
INSERT INTO health_units VALUES(12,'Health Promotions Unit','HLTH-HP-CC',3,3,NULL);
INSERT INTO health_units VALUES(13,'Cleansing and Pest Control Unit','HLTH-CLEAN-CC',3,3,NULL);
INSERT INTO health_units VALUES(14,'Funeral and Burial Services Unit','HLTH-FUN-CC',3,3,NULL);
INSERT INTO health_units VALUES(15,'Health Information Systems Unit','HLTH-HIS-CC',3,3,NULL);
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
INSERT INTO health_positions VALUES('HLTH-HI-TOWN','Health Inspector','LGSS/08',2,'HLTH-SNR-HIO-TOWN',2,1,1,4,0,0,'HLT-HIN-INSP-TOW-01');
INSERT INTO health_positions VALUES('HLTH-FUN-SUP-TOWN','Funeral Superintendent','LGSS/08',1,'HLTH-SNR-HIO-TOWN',2,1,1,4,0,0,'HLT-HIN-FUN-TOW-01');
INSERT INTO health_positions VALUES('HLTH-GENWORK-TOWN','General Worker','G1',10,'HLTH-FUN-SUP-TOWN',2,1,1,5,0,0,'HLT-HIN-GEN-TOW-01');
INSERT INTO health_positions VALUES('HLTH-HEALTH-EDU-TOWN','Health Education Officer','LGSS/08',2,'HLTH-SNR-HIO-TOWN',2,1,1,4,0,0,'HLT-HIN-EDU-TOW-01');
INSERT INTO health_positions VALUES('HLTH-CLEAN-SUP-TOWN','Cleansing Superintendent','LGSS/08',1,'HLTH-ADIR-TOWN',3,1,1,3,0,1,'HLT-CLE-SUP-TOW-01');
INSERT INTO health_positions VALUES('HLTH-ASST-CLEAN-TOWN','Assistant Cleansing Superintendent','LGSS/10',2,'HLTH-CLEAN-SUP-TOWN',3,1,1,4,0,0,'HLT-CLE-ASST-TOW-01');
INSERT INTO health_positions VALUES('HLTH-DRIVER-WASTE-TOWN','Driver-Waste Management','G1',3,'HLTH-ASST-CLEAN-TOWN',3,1,1,5,0,0,'HLT-CLE-DRV-TOW-01');
INSERT INTO health_positions VALUES('HLTH-FUN-SUP-SVC-TOWN','Funeral Superintendent','LGSS/08',1,'HLTH-ADIR-TOWN',4,1,1,3,0,1,'HLT-FUN-SUP-TOW-01');
INSERT INTO health_positions VALUES('HLTH-ASST-FUN-TOWN','Assistant Funeral Superintendent','LGSS/09',1,'HLTH-FUN-SUP-SVC-TOWN',4,1,1,4,0,0,'HLT-FUN-ASST-TOW-01');
INSERT INTO health_positions VALUES('HLTH-SANITARY-TOWN','Sanitary Assistant','G3',5,'HLTH-ASST-FUN-TOWN',4,1,1,5,0,0,'HLT-FUN-SAN-TOW-01');
INSERT INTO health_positions VALUES('HLTH-GRAVE-TOWN','Grave Digger','G3',5,'HLTH-ASST-FUN-TOWN',4,1,1,5,0,0,'HLT-FUN-GRAVE-TOW-01');
INSERT INTO health_positions VALUES('HLTH-ADIR-MUN','Assistant Director - Public Health','LGSS/05',1,'TOWN-CLERK-MUN',NULL,2,2,2,1,0,'HLT-LEAD-ADIR-MUN-01');
INSERT INTO health_positions VALUES('HLTH-CHIEF-HIO-MUN','Chief Health Inspection Officer','LGSS/06',1,'HLTH-ADIR-MUN',5,2,2,3,0,1,'HLT-HIN-CHIEF-MUN-01');
INSERT INTO health_positions VALUES('HLTH-SNR-HIO-MUN','Senior Health Inspection Officer','LGSS/07',2,'HLTH-CHIEF-HIO-MUN',5,2,2,4,0,0,'HLT-HIN-SNR-MUN-01');
INSERT INTO health_positions VALUES('HLTH-HI-MUN','Health Inspector','LGSS/08',10,'HLTH-SNR-HIO-MUN',5,2,2,5,0,0,'HLT-HIN-INSP-MUN-01');
INSERT INTO health_positions VALUES('HLTH-FIELD-DRIVER-MUN','Field Driver','G1',1,'HLTH-HI-MUN',5,2,2,6,0,0,'HLT-HIN-DRV-MUN-01');
INSERT INTO health_positions VALUES('HLTH-SNR-HPO-MUN','Senior Health Education Officer','LGSS/07',1,'HLTH-ADIR-MUN',6,2,2,3,0,1,'HLT-HPR-SNR-MUN-01');
INSERT INTO health_positions VALUES('HLTH-HPO-MUN','Health Education Officer','LGSS/08',2,'HLTH-SNR-HPO-MUN',6,2,2,4,0,0,'HLT-HPR-OFF-MUN-01');
INSERT INTO health_positions VALUES('HLTH-ASST-HPO-MUN','Assistant Health Education Officer','LGSS/09',1,'HLTH-HPO-MUN',6,2,2,5,0,0,'HLT-HPR-ASTOFF-MUN-01');
INSERT INTO health_positions VALUES('HLTH-HEALTH-EDU-ASST-MUN','Health Education Assistant','LGSS/10',1,'HLTH-ASST-HPO-MUN',6,2,2,6,0,0,'HLT-HPR-AST-MUN-01');
INSERT INTO health_positions VALUES('HLTH-CLEAN-MGR-MUN','Cleansing Manager','LGSS/07',1,'HLTH-ADIR-MUN',7,2,2,3,0,1,'HLT-CLE-MGR-MUN-01');
INSERT INTO health_positions VALUES('HLTH-CLEAN-SUP-MUN','Cleansing Superintendent','LGSS/08',1,'HLTH-CLEAN-MGR-MUN',7,2,2,4,0,0,'HLT-CLE-SUP-MUN-01');
INSERT INTO health_positions VALUES('HLTH-ASST-CLEAN-MUN','Assistant Cleansing Superintendent','LGSS/09',1,'HLTH-CLEAN-SUP-MUN',7,2,2,5,0,0,'HLT-CLE-ASTSUP-MUN-01');
INSERT INTO health_positions VALUES('HLTH-PEST-SUP-MUN','Pest Control Superintendent','LGSS/08',1,'HLTH-CLEAN-MGR-MUN',7,2,2,4,0,0,'HLT-CLE-PEST-MUN-01');
INSERT INTO health_positions VALUES('HLTH-ASST-PEST-MUN','Assistant Pest Control Superintendent','LGSS/09',1,'HLTH-PEST-SUP-MUN',7,2,2,5,0,0,'HLT-CLE-ASTPEST-MUN-01');
INSERT INTO health_positions VALUES('HLTH-CLEAN-FORE-MUN','Cleansing Foreman','LGSS',1,'HLTH-CLEAN-MGR-MUN',7,2,2,4,0,0,'HLT-CLE-FORE-MUN-01');
INSERT INTO health_positions VALUES('HLTH-WASTE-DRIVER-MUN','Waste Management Driver','LGSS',6,'HLTH-CLEAN-FORE-MUN',7,2,2,5,0,0,'HLT-CLE-DRV-MUN-01');
INSERT INTO health_positions VALUES('HLTH-FUN-SUP-MUN','Funeral Superintendent','LGSS/08',1,'HLTH-ADIR-MUN',8,2,2,3,0,1,'HLT-FUN-SUP-MUN-01');
INSERT INTO health_positions VALUES('HLTH-ASST-FUN-MUN','Assistant Funeral Superintendent','LGSS/09',1,'HLTH-FUN-SUP-MUN',8,2,2,4,0,0,'HLT-FUN-AST-MUN-01');
INSERT INTO health_positions VALUES('HLTH-SANITARY-MUN','Sanitary Assistant','G3',10,'HLTH-ASST-FUN-MUN',8,2,2,5,0,0,'HLT-FUN-SAN-MUN-01');
INSERT INTO health_positions VALUES('HLTH-GRAVE-MUN','Grave Digger','G3',10,'HLTH-ASST-FUN-MUN',8,2,2,5,0,0,'HLT-FUN-GRAVE-MUN-01');
INSERT INTO health_positions VALUES('HLTH-HIS-MUN','Health Information Systems Officer','LGSS/06',1,'HLTH-ADIR-MUN',9,2,2,3,0,1,'HLT-HIS-OFF-MUN-01');
INSERT INTO health_positions VALUES('HLTH-ADIR-CITY','Assistant Director - Public Health','LGSS/05',1,'TOWN-CLERK-CITY',NULL,3,3,2,1,0,'HLT-LEAD-ADIR-CIT-01');
INSERT INTO health_positions VALUES('HLTH-SNR-EHO-CITY','Senior Environmental Health Officer','LGSS/07',1,'HLTH-ADIR-CITY',10,3,3,3,0,1,'HLT-ENV-SNR-CIT-01');
INSERT INTO health_positions VALUES('HLTH-SNR-TECH-CITY','Senior Environmental Health Technologist','LGSS/08',5,'HLTH-SNR-EHO-CITY',10,3,3,4,0,0,'HLT-ENV-SR-TECH-CIT-01');
INSERT INTO health_positions VALUES('HLTH-TECH-CITY','Environmental Health Technologist','LGSS/08',8,'HLTH-SNR-TECH-CITY',10,3,3,5,0,0,'HLT-ENV-TECH-CIT-01');
INSERT INTO health_positions VALUES('HLTH-CHIEF-HIO-CITY','Chief Health Inspection Officer','LGSS/06',1,'HLTH-ADIR-CITY',11,3,3,3,0,1,'HLT-HIN-CHIEF-CIT-01');
INSERT INTO health_positions VALUES('HLTH-SNR-HIO-CITY','Senior Health Inspection Officer','LGSS/07',5,'HLTH-CHIEF-HIO-CITY',11,3,3,4,0,0,'HLT-HIN-SNR-CIT-01');
INSERT INTO health_positions VALUES('HLTH-HI-CITY','Health Inspector','LGSS/08',35,'HLTH-SNR-HIO-CITY',11,3,3,5,0,0,'HLT-HIN-INSP-CIT-01');
INSERT INTO health_positions VALUES('HLTH-FIELD-DRIVER-CITY','Field Driver','G1',1,'HLTH-HI-CITY',11,3,3,6,0,0,'HLT-HIN-DRV-CIT-01');
INSERT INTO health_positions VALUES('HLTH-SNR-HPO-CITY','Senior Health Education Officer','LGSS/07',5,'HLTH-ADIR-CITY',12,3,3,3,0,1,'HLT-HPR-SNR-CIT-01');
INSERT INTO health_positions VALUES('HLTH-HPO-CITY','Health Education Officer','LGSS/08',5,'HLTH-SNR-HPO-CITY',12,3,3,4,0,0,'HLT-HPR-OFF-CIT-01');
INSERT INTO health_positions VALUES('HLTH-HEALTH-EDU-ASST-CITY','Health Education Assistant','LGSS/10',2,'HLTH-HPO-CITY',12,3,3,5,0,0,'HLT-HPR-AST-CIT-01');
INSERT INTO health_positions VALUES('HLTH-CLEAN-MGR-CITY','Cleansing Manager','LGSS/07',1,'HLTH-ADIR-CITY',13,3,3,3,0,1,'HLT-CLE-MGR-CIT-01');
INSERT INTO health_positions VALUES('HLTH-CLEAN-SUP-CITY','Cleansing Superintendent','LGSS/08',1,'HLTH-CLEAN-MGR-CITY',13,3,3,4,0,0,'HLT-CLE-SUP-CIT-01');
INSERT INTO health_positions VALUES('HLTH-ASST-CLEAN-CITY','Assistant Cleansing Superintendent','LGSS/09',1,'HLTH-CLEAN-SUP-CITY',13,3,3,5,0,0,'HLT-CLE-ASTSUP-CIT-01');
INSERT INTO health_positions VALUES('HLTH-PEST-SUP-CITY','Pest Control Superintendent','LGSS/08',1,'HLTH-CLEAN-MGR-CITY',13,3,3,4,0,0,'HLT-CLE-PEST-CIT-01');
INSERT INTO health_positions VALUES('HLTH-ASST-PEST-CITY','Assistant Pest Control Superintendent','LGSS/09',1,'HLTH-PEST-SUP-CITY',13,3,3,5,0,0,'HLT-CLE-ASTPEST-CIT-01');
INSERT INTO health_positions VALUES('HLTH-WASTE-DRIVER-CITY','Waste Management Driver','G1',1,'HLTH-CLEAN-SUP-CITY',13,3,3,5,0,0,'HLT-CLE-DRV-CIT-01');
INSERT INTO health_positions VALUES('HLTH-FUN-SUP-CITY','Funeral Superintendent','LGSS/08',2,'HLTH-ADIR-CITY',14,3,3,3,0,1,'HLT-FUN-SUP-CIT-01');
INSERT INTO health_positions VALUES('HLTH-SANITARY-CITY','Sanitary Assistant','G3',10,'HLTH-FUN-SUP-CITY',14,3,3,4,0,0,'HLT-FUN-SAN-CIT-01');
INSERT INTO health_positions VALUES('HLTH-GRAVE-CITY','Grave Digger','G3',10,'HLTH-FUN-SUP-CITY',14,3,3,4,0,0,'HLT-FUN-GRAVE-CIT-01');
INSERT INTO health_positions VALUES('HLTH-HIS-CITY','Health Information Officer','LGSS/06',1,'HLTH-ADIR-CITY',15,3,3,3,0,1,'HLT-HIS-OFF-CIT-01');
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
INSERT INTO health_leave_approval_chain VALUES(13,'HLTH-HI-TOWN',1,'Supervisor','HLTH-SNR-HIO-TOWN');
INSERT INTO health_leave_approval_chain VALUES(14,'HLTH-HI-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(15,'HLTH-HI-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(16,'HLTH-FUN-SUP-TOWN',1,'Supervisor','HLTH-SNR-HIO-TOWN');
INSERT INTO health_leave_approval_chain VALUES(17,'HLTH-FUN-SUP-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(18,'HLTH-FUN-SUP-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(19,'HLTH-GENWORK-TOWN',1,'Supervisor','HLTH-FUN-SUP-TOWN');
INSERT INTO health_leave_approval_chain VALUES(20,'HLTH-GENWORK-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(21,'HLTH-GENWORK-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(22,'HLTH-HEALTH-EDU-TOWN',1,'Supervisor','HLTH-SNR-HIO-TOWN');
INSERT INTO health_leave_approval_chain VALUES(23,'HLTH-HEALTH-EDU-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(24,'HLTH-HEALTH-EDU-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(25,'HLTH-CLEAN-SUP-TOWN',1,'Supervisor','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(26,'HLTH-CLEAN-SUP-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(27,'HLTH-CLEAN-SUP-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(28,'HLTH-ASST-CLEAN-TOWN',1,'Supervisor','HLTH-CLEAN-SUP-TOWN');
INSERT INTO health_leave_approval_chain VALUES(29,'HLTH-ASST-CLEAN-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(30,'HLTH-ASST-CLEAN-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(31,'HLTH-DRIVER-WASTE-TOWN',1,'Supervisor','HLTH-ASST-CLEAN-TOWN');
INSERT INTO health_leave_approval_chain VALUES(32,'HLTH-DRIVER-WASTE-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(33,'HLTH-DRIVER-WASTE-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(34,'HLTH-FUN-SUP-SVC-TOWN',1,'Supervisor','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(35,'HLTH-FUN-SUP-SVC-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(36,'HLTH-FUN-SUP-SVC-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(37,'HLTH-ASST-FUN-TOWN',1,'Supervisor','HLTH-FUN-SUP-SVC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(38,'HLTH-ASST-FUN-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(39,'HLTH-ASST-FUN-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(40,'HLTH-SANITARY-TOWN',1,'Supervisor','HLTH-ASST-FUN-TOWN');
INSERT INTO health_leave_approval_chain VALUES(41,'HLTH-SANITARY-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(42,'HLTH-SANITARY-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(43,'HLTH-GRAVE-TOWN',1,'Supervisor','HLTH-ASST-FUN-TOWN');
INSERT INTO health_leave_approval_chain VALUES(44,'HLTH-GRAVE-TOWN',2,'Head of Department','HLTH-ADIR-TOWN');
INSERT INTO health_leave_approval_chain VALUES(45,'HLTH-GRAVE-TOWN',3,'Head of Council','COUNCIL-SEC-TOWN');
INSERT INTO health_leave_approval_chain VALUES(46,'TOWN-CLERK-MUN',1,'Supervisor',NULL);
INSERT INTO health_leave_approval_chain VALUES(47,'TOWN-CLERK-MUN',2,'Head of Council',NULL);
INSERT INTO health_leave_approval_chain VALUES(48,'TOWN-CLERK-MUN',3,'Head of Council',NULL);
INSERT INTO health_leave_approval_chain VALUES(49,'HLTH-ADIR-MUN',1,'Supervisor','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(50,'HLTH-ADIR-MUN',2,'Head of Department','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(51,'HLTH-ADIR-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(52,'HLTH-CHIEF-HIO-MUN',1,'Supervisor','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(53,'HLTH-CHIEF-HIO-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(54,'HLTH-CHIEF-HIO-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(55,'HLTH-SNR-HIO-MUN',1,'Supervisor','HLTH-CHIEF-HIO-MUN');
INSERT INTO health_leave_approval_chain VALUES(56,'HLTH-SNR-HIO-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(57,'HLTH-SNR-HIO-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(58,'HLTH-HI-MUN',1,'Supervisor','HLTH-SNR-HIO-MUN');
INSERT INTO health_leave_approval_chain VALUES(59,'HLTH-HI-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(60,'HLTH-HI-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(61,'HLTH-FIELD-DRIVER-MUN',1,'Supervisor','HLTH-HI-MUN');
INSERT INTO health_leave_approval_chain VALUES(62,'HLTH-FIELD-DRIVER-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(63,'HLTH-FIELD-DRIVER-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(64,'HLTH-SNR-HPO-MUN',1,'Supervisor','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(65,'HLTH-SNR-HPO-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(66,'HLTH-SNR-HPO-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(67,'HLTH-HPO-MUN',1,'Supervisor','HLTH-SNR-HPO-MUN');
INSERT INTO health_leave_approval_chain VALUES(68,'HLTH-HPO-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(69,'HLTH-HPO-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(70,'HLTH-ASST-HPO-MUN',1,'Supervisor','HLTH-HPO-MUN');
INSERT INTO health_leave_approval_chain VALUES(71,'HLTH-ASST-HPO-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(72,'HLTH-ASST-HPO-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(73,'HLTH-HEALTH-EDU-ASST-MUN',1,'Supervisor','HLTH-ASST-HPO-MUN');
INSERT INTO health_leave_approval_chain VALUES(74,'HLTH-HEALTH-EDU-ASST-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(75,'HLTH-HEALTH-EDU-ASST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(76,'HLTH-CLEAN-MGR-MUN',1,'Supervisor','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(77,'HLTH-CLEAN-MGR-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(78,'HLTH-CLEAN-MGR-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(79,'HLTH-CLEAN-SUP-MUN',1,'Supervisor','HLTH-CLEAN-MGR-MUN');
INSERT INTO health_leave_approval_chain VALUES(80,'HLTH-CLEAN-SUP-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(81,'HLTH-CLEAN-SUP-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(82,'HLTH-ASST-CLEAN-MUN',1,'Supervisor','HLTH-CLEAN-SUP-MUN');
INSERT INTO health_leave_approval_chain VALUES(83,'HLTH-ASST-CLEAN-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(84,'HLTH-ASST-CLEAN-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(85,'HLTH-PEST-SUP-MUN',1,'Supervisor','HLTH-CLEAN-MGR-MUN');
INSERT INTO health_leave_approval_chain VALUES(86,'HLTH-PEST-SUP-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(87,'HLTH-PEST-SUP-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(88,'HLTH-ASST-PEST-MUN',1,'Supervisor','HLTH-PEST-SUP-MUN');
INSERT INTO health_leave_approval_chain VALUES(89,'HLTH-ASST-PEST-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(90,'HLTH-ASST-PEST-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(91,'HLTH-CLEAN-FORE-MUN',1,'Supervisor','HLTH-CLEAN-MGR-MUN');
INSERT INTO health_leave_approval_chain VALUES(92,'HLTH-CLEAN-FORE-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(93,'HLTH-CLEAN-FORE-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(94,'HLTH-WASTE-DRIVER-MUN',1,'Supervisor','HLTH-CLEAN-FORE-MUN');
INSERT INTO health_leave_approval_chain VALUES(95,'HLTH-WASTE-DRIVER-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(96,'HLTH-WASTE-DRIVER-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(97,'HLTH-FUN-SUP-MUN',1,'Supervisor','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(98,'HLTH-FUN-SUP-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(99,'HLTH-FUN-SUP-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(100,'HLTH-ASST-FUN-MUN',1,'Supervisor','HLTH-FUN-SUP-MUN');
INSERT INTO health_leave_approval_chain VALUES(101,'HLTH-ASST-FUN-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(102,'HLTH-ASST-FUN-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(103,'HLTH-SANITARY-MUN',1,'Supervisor','HLTH-ASST-FUN-MUN');
INSERT INTO health_leave_approval_chain VALUES(104,'HLTH-SANITARY-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(105,'HLTH-SANITARY-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(106,'HLTH-GRAVE-MUN',1,'Supervisor','HLTH-ASST-FUN-MUN');
INSERT INTO health_leave_approval_chain VALUES(107,'HLTH-GRAVE-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(108,'HLTH-GRAVE-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(109,'HLTH-HIS-MUN',1,'Supervisor','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(110,'HLTH-HIS-MUN',2,'Head of Department','HLTH-ADIR-MUN');
INSERT INTO health_leave_approval_chain VALUES(111,'HLTH-HIS-MUN',3,'Head of Council','TOWN-CLERK-MUN');
INSERT INTO health_leave_approval_chain VALUES(112,'TOWN-CLERK-CITY',1,'Supervisor',NULL);
INSERT INTO health_leave_approval_chain VALUES(113,'TOWN-CLERK-CITY',2,'Head of Council',NULL);
INSERT INTO health_leave_approval_chain VALUES(114,'TOWN-CLERK-CITY',3,'Head of Council',NULL);
INSERT INTO health_leave_approval_chain VALUES(115,'HLTH-ADIR-CITY',1,'Supervisor','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(116,'HLTH-ADIR-CITY',2,'Head of Department','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(117,'HLTH-ADIR-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(118,'HLTH-SNR-EHO-CITY',1,'Supervisor','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(119,'HLTH-SNR-EHO-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(120,'HLTH-SNR-EHO-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(121,'HLTH-SNR-TECH-CITY',1,'Supervisor','HLTH-SNR-EHO-CITY');
INSERT INTO health_leave_approval_chain VALUES(122,'HLTH-SNR-TECH-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(123,'HLTH-SNR-TECH-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(124,'HLTH-TECH-CITY',1,'Supervisor','HLTH-SNR-TECH-CITY');
INSERT INTO health_leave_approval_chain VALUES(125,'HLTH-TECH-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(126,'HLTH-TECH-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(127,'HLTH-CHIEF-HIO-CITY',1,'Supervisor','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(128,'HLTH-CHIEF-HIO-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(129,'HLTH-CHIEF-HIO-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(130,'HLTH-SNR-HIO-CITY',1,'Supervisor','HLTH-CHIEF-HIO-CITY');
INSERT INTO health_leave_approval_chain VALUES(131,'HLTH-SNR-HIO-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(132,'HLTH-SNR-HIO-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(133,'HLTH-HI-CITY',1,'Supervisor','HLTH-SNR-HIO-CITY');
INSERT INTO health_leave_approval_chain VALUES(134,'HLTH-HI-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(135,'HLTH-HI-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(136,'HLTH-FIELD-DRIVER-CITY',1,'Supervisor','HLTH-HI-CITY');
INSERT INTO health_leave_approval_chain VALUES(137,'HLTH-FIELD-DRIVER-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(138,'HLTH-FIELD-DRIVER-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(139,'HLTH-SNR-HPO-CITY',1,'Supervisor','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(140,'HLTH-SNR-HPO-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(141,'HLTH-SNR-HPO-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(142,'HLTH-HPO-CITY',1,'Supervisor','HLTH-SNR-HPO-CITY');
INSERT INTO health_leave_approval_chain VALUES(143,'HLTH-HPO-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(144,'HLTH-HPO-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(145,'HLTH-HEALTH-EDU-ASST-CITY',1,'Supervisor','HLTH-HPO-CITY');
INSERT INTO health_leave_approval_chain VALUES(146,'HLTH-HEALTH-EDU-ASST-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(147,'HLTH-HEALTH-EDU-ASST-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(148,'HLTH-CLEAN-MGR-CITY',1,'Supervisor','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(149,'HLTH-CLEAN-MGR-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(150,'HLTH-CLEAN-MGR-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(151,'HLTH-CLEAN-SUP-CITY',1,'Supervisor','HLTH-CLEAN-MGR-CITY');
INSERT INTO health_leave_approval_chain VALUES(152,'HLTH-CLEAN-SUP-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(153,'HLTH-CLEAN-SUP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(154,'HLTH-ASST-CLEAN-CITY',1,'Supervisor','HLTH-CLEAN-SUP-CITY');
INSERT INTO health_leave_approval_chain VALUES(155,'HLTH-ASST-CLEAN-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(156,'HLTH-ASST-CLEAN-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(157,'HLTH-PEST-SUP-CITY',1,'Supervisor','HLTH-CLEAN-MGR-CITY');
INSERT INTO health_leave_approval_chain VALUES(158,'HLTH-PEST-SUP-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(159,'HLTH-PEST-SUP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(160,'HLTH-ASST-PEST-CITY',1,'Supervisor','HLTH-PEST-SUP-CITY');
INSERT INTO health_leave_approval_chain VALUES(161,'HLTH-ASST-PEST-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(162,'HLTH-ASST-PEST-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(163,'HLTH-WASTE-DRIVER-CITY',1,'Supervisor','HLTH-CLEAN-SUP-CITY');
INSERT INTO health_leave_approval_chain VALUES(164,'HLTH-WASTE-DRIVER-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(165,'HLTH-WASTE-DRIVER-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(166,'HLTH-FUN-SUP-CITY',1,'Supervisor','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(167,'HLTH-FUN-SUP-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(168,'HLTH-FUN-SUP-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(169,'HLTH-SANITARY-CITY',1,'Supervisor','HLTH-FUN-SUP-CITY');
INSERT INTO health_leave_approval_chain VALUES(170,'HLTH-SANITARY-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(171,'HLTH-SANITARY-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(172,'HLTH-GRAVE-CITY',1,'Supervisor','HLTH-FUN-SUP-CITY');
INSERT INTO health_leave_approval_chain VALUES(173,'HLTH-GRAVE-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(174,'HLTH-GRAVE-CITY',3,'Head of Council','TOWN-CLERK-CITY');
INSERT INTO health_leave_approval_chain VALUES(175,'HLTH-HIS-CITY',1,'Supervisor','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(176,'HLTH-HIS-CITY',2,'Head of Department','HLTH-ADIR-CITY');
INSERT INTO health_leave_approval_chain VALUES(177,'HLTH-HIS-CITY',3,'Head of Council','TOWN-CLERK-CITY');
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
    FOREIGN KEY (supervisor_id) REFERENCES employees(employee_id)
);
INSERT INTO mothers_day_leave_tracking VALUES(1,'ITT-2026-000001','2024-03-15','2024-03',NULL,0,NULL,1,'2026-02-24 20:57:50',0,NULL,1,'2026-02-24 20:57:52','Approved','Both',NULL,'2026-02-24 20:57:50');
INSERT INTO mothers_day_leave_tracking VALUES(2,'CHL-2020-000007','2026-02-26','2026-02','CHL-2013-000008',1,NULL,1,'2026-02-26 09:00:22',0,NULL,0,NULL,'Approved','Both',NULL,'2026-02-26 09:00:22');
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
INSERT INTO eng_position_hierarchy VALUES(6,'ENG-ELEC-ASST','Assistant Electrical Engineer','Electrical Unit','LGSS10',1,'ENG-ELEC-HEAD','Town',1,5,0,'2026-02-25 13:37:54','ENG-ELE-ASSTELEC-TOW-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(7,'ENG-ELEC-TECH','Electrician','Electrical Unit','LGSS14',2,'ENG-ELEC-HEAD','Town',1,5,0,'2026-02-25 13:37:54','ENG-ELE-ELEC-TOW-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(8,'ENG-MAINT-SUP','Maintenance Superintendent','Maintenance Unit','LGSS10',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-MTN-MAINTSUPT-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(9,'ENG-PLUM','Plumber','Maintenance Unit','LGSS15',2,'ENG-MAINT-SUP','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-PLUMB-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(10,'ENG-BRICK','Bricklayer','Maintenance Unit','LGSS15',2,'ENG-MAINT-SUP','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-BRICK-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(11,'ENG-CARP','Carpenter','Maintenance Unit','LGSS15',2,'ENG-MAINT-SUP','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-CARP-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(12,'ENG-PAINT','Painter','Maintenance Unit','LGSS15',1,'ENG-MAINT-SUP','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-PAINT-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(13,'ENG-GENWORK','General Worker','Maintenance Unit','G3',3,'ENG-MAINT-SUP','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-GENWK-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(14,'ENG-QSURV','Quantity Surveyor','Quantity Surveying Unit','LGSS07',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-SUR-QS-TOW-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(15,'ENG-QSURV-ASST','Assistant Quantity Surveyor','Quantity Surveying Unit','LGSS10',2,'ENG-QSURV','Town',1,5,0,'2026-02-25 13:37:54','ENG-SUR-ASSTQS-TOW-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(16,'ENG-ARCH','Architect','Architecture Unit','LGSS07',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-ARC-ARCH-TOW-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(17,'ENG-ARCH-ASST','Assistant Architect','Architecture Unit','LGSS10',2,'ENG-ARCH','Town',1,5,0,'2026-02-25 13:37:54','ENG-ARC-ASSTARCH-TOW-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(18,'ENG-CLERK','Senior Clerk of Works','Architecture Unit','LGSS10',1,'ENG-ARCH','Town',1,5,0,'2026-02-25 13:37:54','ENG-ARC-SNRCLRKWRK-TOW-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(19,'ENG-DRAFT','Draughtsman','Architecture Unit','LGSS15',1,'ENG-ARCH','Town',1,5,0,'2026-02-25 13:37:54','ENG-ARC-DRAFT-TOW-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(20,'ENG-PARK-MGR','Parks Manager','Parks and Gardens Unit','LGSS07',1,'ENG-ASST-DIR','Town',1,3,1,'2026-02-25 13:37:54','ENG-PRK-PARKMGR-TOW-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(21,'ENG-PARK-SUP','Parks Supervisor','Parks and Gardens Unit','LGSS15',1,'ENG-PARK-MGR','Town',1,4,0,'2026-02-25 13:37:54','ENG-PRK-PARKSUP-TOW-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(22,'ENG-PARK-WORK','General Worker','Parks and Gardens Unit','G1',4,'ENG-PARK-SUP','Town',1,5,0,'2026-02-25 13:37:54','ENG-PRK-GENWK-TOW-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(23,'ENG-CIVIL','Civil Engineer','Roads and Drainages Unit','LGSS07',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-RDS-CIVENG-TOW-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(24,'ENG-CIVIL-ASST','Assistant Civil Engineer','Roads and Drainages Unit','LGSS10',2,'ENG-CIVIL','Town',1,5,0,'2026-02-25 13:37:54','ENG-RDS-ASSTCIV-TOW-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(25,'ENG-CIVIL-TECH','Engineering Assistant','Roads and Drainages Unit','LGSS14',2,'ENG-CIVIL','Town',1,5,0,'2026-02-25 13:37:54','ENG-RDS-ENGASST-TOW-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(26,'ENG-MECH','Mechanical Engineer','Mechanical Services Unit','LGSS07',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-MEC-MECHENG-TOW-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(27,'ENG-MECH-ASST','Assistant Mechanical Engineer','Vehicle Maintenance Services Sub-Unit','LGSS10',1,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-ASSTMECH-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(28,'ENG-MOTOR','Motor Vehicle Examiner','Vehicle Maintenance Services Sub-Unit','LGSS11',1,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-MVE-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(29,'ENG-AUTO','Auto Electrician','Vehicle Maintenance Services Sub-Unit','LGSS14',1,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-AUTOELEC-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(30,'ENG-MECH-TECH','Mechanic','Vehicle Maintenance Services Sub-Unit','LGSS14',2,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-MECH-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(31,'ENG-EXCAV','Excavator Operator','Vehicle Maintenance Services Sub-Unit','LGSS14',1,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-EXCAV-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(32,'ENG-SCALER','Scaler Operator','Vehicle Maintenance Services Sub-Unit','LGSS14',1,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-SCALER-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(33,'ENG-HANDY','Mechanical Handyman','Vehicle Maintenance Services Sub-Unit','G1',2,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-MECHHAND-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(34,'ENG-WELDER','Welder','Vehicle Maintenance Services Sub-Unit','LGSS15',1,'ENG-MECH','Town',1,5,0,'2026-02-25 13:37:54','ENG-MTN-WELD-TOW-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(35,'ENG-FIRE-DIV','Divisional Fire Officer','Fire and Rescue Services Unit','LGSS08',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-FRS-DIVFIRE-TOW-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(36,'ENG-FIRE-STN','Station Officer','Fire and Rescue Services Unit','LGSS11',1,'ENG-FIRE-DIV','Town',1,5,0,'2026-02-25 13:37:54','ENG-FRS-STNOFF-TOW-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(37,'ENG-FIRE-SUB','Sub-Officer','Fire and Rescue Services Unit','LGSS12',1,'ENG-FIRE-STN','Town',1,6,0,'2026-02-25 13:37:54','ENG-FRS-SUBOFF-TOW-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(38,'ENG-FIRE-LEAD','Leading Firefighter','Fire and Rescue Services Unit','LGSS13',2,'ENG-FIRE-STN','Town',1,6,0,'2026-02-25 13:37:54','ENG-FRS-LDFF-TOW-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(39,'ENG-FIRE','Firefighter','Fire and Rescue Services Unit','LGSS14',4,'ENG-FIRE-LEAD','Town',1,7,0,'2026-02-25 13:37:54','ENG-FRS-FF-TOW-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(40,'ENG-FIRE-DRV','Firefighter Driver','Fire and Rescue Services Unit','LGSS14',2,'ENG-FIRE-LEAD','Town',1,7,0,'2026-02-25 13:37:54','ENG-FRS-FFDRV-TOW-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(41,'ENG-WATSAN','Water and Sanitation Engineer','Rural Water and Sanitation Unit','LGSS07',1,'ENG-ASST-DIR','Town',1,4,1,'2026-02-25 13:37:54','ENG-WAT-WATSANENG-TOW-WATSAN-01');
INSERT INTO eng_position_hierarchy VALUES(42,'TOWN-CLERK','Town Clerk','Council Administration','LGSS02',1,NULL,'Municipal',2,1,1,'2026-02-25 13:37:55','ENG-ADM-TOWNCLRK-MUN-ADMIN-01');
INSERT INTO eng_position_hierarchy VALUES(43,'ENG-DIR','Director - Engineering','Engineering Department','LGSS04',1,'TOWN-CLERK','Municipal',2,2,1,'2026-02-25 13:37:55','ENG-GEN-DIRENG-MUN-GEN-01');
INSERT INTO eng_position_hierarchy VALUES(44,'ENG-CONSTR-ASSTDIR','Assistant Director - Construction & Maintenance','Construction & Maintenance Section','LGSS05',1,'ENG-DIR','Municipal',2,3,1,'2026-02-25 13:37:55','ENG-MTN-ADIRCONST-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(45,'ENG-ELEC-CHIEF','Chief Electrical Engineer','Electrical Engineering Unit','LGSS06',1,'ENG-CONSTR-ASSTDIR','Municipal',2,4,1,'2026-02-25 13:37:55','ENG-ELE-CHIEFELEC-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(46,'ENG-ELEC-ENG07','Electrical Engineer','Electrical Engineering Unit','LGSS07',1,'ENG-ELEC-CHIEF','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-ELE-ELECENG-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(47,'ENG-ELEC-ASST','Assistant Electrical Engineer','Electrical Engineering Unit','LGSS10',1,'ENG-ELEC-CHIEF','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-ELE-ASSTELEC-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(48,'ENG-ELEC-SUPT','Superintendent','Electrical Engineering Unit','LGSS12',1,'ENG-ELEC-CHIEF','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-ELE-SUPT-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(49,'ENG-ELEC-ASSTSUPT','Assistant Superintendent','Electrical Engineering Unit','LGSS13',1,'ENG-ELEC-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-ELE-ASSTSUPT-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(50,'ENG-ELEC-SENASSIST','Senior Engineering Assistant','Electrical Engineering Unit','LGSS13',1,'ENG-ELEC-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-ELE-SNRENGASST-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(51,'ENG-ELEC-WORKSUP','Works Supervisor','Electrical Engineering Unit','LGSS14',1,'ENG-ELEC-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-ELE-WRKSUP-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(52,'ENG-ELEC-TECH','Electrician','Electrical Engineering Unit','LGSS14',5,'ENG-ELEC-WORKSUP','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-ELE-ELEC-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(53,'ENG-ELEC-FOREMAN','Foreman','Electrical Engineering Unit','LGSS14',1,'ENG-ELEC-WORKSUP','Municipal',2,7,0,'2026-02-25 13:37:55','ENG-ELE-FORE-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(54,'ENG-ELEC-ASSTFORE','Assistant Foreman','Electrical Engineering Unit','LGSS17',1,'ENG-ELEC-FOREMAN','Municipal',2,8,0,'2026-02-25 13:37:55','ENG-ELE-ASSTFORE-MUN-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(55,'ENG-QSURV-CHIEF','Chief Quantity Surveyor','Quantity Surveying Unit','LGSS06',1,'ENG-CONSTR-ASSTDIR','Municipal',2,4,1,'2026-02-25 13:37:55','ENG-SUR-CHIEFQS-MUN-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(56,'ENG-QSURV07','Quantity Surveyor','Quantity Surveying Unit','LGSS07',3,'ENG-QSURV-CHIEF','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-SUR-QS-MUN-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(57,'ENG-QSURV-ASST','Assistant Quantity Surveyor','Quantity Surveying Unit','LGSS10',3,'ENG-QSURV07','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-SUR-ASSTQS-MUN-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(58,'ENG-QSURV-SENASSIST','Senior Quantity Surveying Assistant','Quantity Surveying Unit','LGSS13',1,'ENG-QSURV-ASST','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-SUR-SNRQSASST-MUN-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(59,'ENG-QSURV-ASSIST','Quantity Surveying Assistant','Quantity Surveying Unit','LGSS14',1,'ENG-QSURV-ASST','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-SUR-QSASST-MUN-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(60,'ENG-ARCH-CHIEF','Chief Architect','Architecture Unit','LGSS06',1,'ENG-CONSTR-ASSTDIR','Municipal',2,4,1,'2026-02-25 13:37:55','ENG-ARC-CHIEFARCH-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(61,'ENG-ARCH07','Architect','Architecture Unit','LGSS07',3,'ENG-ARCH-CHIEF','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-ARC-ARCH-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(62,'ENG-ARCH-ASST','Assistant Architect','Architecture Unit','LGSS10',2,'ENG-ARCH07','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-ARC-ASSTARCH-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(63,'ENG-ARCH-ASSIST','Architectural Assistant','Architecture Unit','LGSS14',1,'ENG-ARCH-ASST','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-ARC-ARCHASST-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(64,'ENG-ARCH-FOREMAN','Foreman','Architecture Unit','LGSS14',2,'ENG-ARCH-ASST','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-ARC-FORE-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(65,'ENG-ARCH-ASSTFORE','Assistant Foreman','Architecture Unit','LGSS17',2,'ENG-ARCH-FOREMAN','Municipal',2,7,0,'2026-02-25 13:37:55','ENG-ARC-ASSTFORE-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(66,'ENG-ARCH-SENCLERK','Senior Clerk of Works','Architecture Unit','LGSS10',2,'ENG-ARCH07','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-ARC-SNRCLRKWRK-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(67,'ENG-ARCH-CLERK','Clerk of Works','Architecture Unit','LGSS12',2,'ENG-ARCH-SENCLERK','Municipal',2,7,0,'2026-02-25 13:37:55','ENG-ARC-CLRKWRK-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(68,'ENG-ARCH-DRAFT','Draughtsman','Architecture Unit','LGSS15',1,'ENG-ARCH07','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-ARC-DRAFT-MUN-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(69,'ENG-MAINT-SUPT','Maintenance Superintendent','Maintenance Unit','LGSS10',1,'ENG-CONSTR-ASSTDIR','Municipal',2,4,1,'2026-02-25 13:37:55','ENG-MTN-MAINTSUPT-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(70,'ENG-MAINT-ASSTSUPT','Assistant Superintendent','Maintenance Unit','LGSS12',1,'ENG-MAINT-SUPT','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-MTN-ASSTSUPT-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(71,'ENG-MAINT-FOREMAN','Foreman','Maintenance Unit','LGSS14',2,'ENG-MAINT-SUPT','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-MTN-FORE-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(72,'ENG-MAINT-PLUM','Plumber','Maintenance Unit','LGSS15',2,'ENG-MAINT-FOREMAN','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MTN-PLUMB-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(73,'ENG-MAINT-BRICK','Bricklayer','Maintenance Unit','LGSS15',2,'ENG-MAINT-FOREMAN','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MTN-BRICK-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(74,'ENG-MAINT-CARP','Carpenter','Maintenance Unit','LGSS15',2,'ENG-MAINT-FOREMAN','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MTN-CARP-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(75,'ENG-MAINT-PAINT','Painter','Maintenance Unit','LGSS15',1,'ENG-MAINT-FOREMAN','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MTN-PAINT-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(76,'ENG-MAINT-GENWORK','General Worker','Maintenance Unit','G3',4,'ENG-MAINT-FOREMAN','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MTN-GENWK-MUN-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(77,'ENG-PARK-MGR','Parks Manager','Parks & Gardens Unit','LGSS07',1,'ENG-CONSTR-ASSTDIR','Municipal',2,3,1,'2026-02-25 13:37:55','ENG-PRK-PARKMGR-MUN-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(78,'ENG-PARK-SUPT','Superintendent','Parks & Gardens Unit','LGSS12',1,'ENG-PARK-MGR','Municipal',2,4,0,'2026-02-25 13:37:55','ENG-PRK-SUPT-MUN-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(79,'ENG-PARK-ASSTSUPT','Assistant Superintendent','Parks & Gardens Unit','LGSS13',1,'ENG-PARK-SUPT','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-PRK-ASSTSUPT-MUN-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(80,'ENG-PARK-FOREMAN','Parks Foreman','Parks & Gardens Unit','LGSS14',1,'ENG-PARK-SUPT','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-PRK-PARKFORE-MUN-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(81,'ENG-PARK-SUP','Parks Supervisor','Parks & Gardens Unit','LGSS15',1,'ENG-PARK-FOREMAN','Municipal',2,4,0,'2026-02-25 13:37:55','ENG-PRK-PARKSUP-MUN-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(82,'ENG-PARK-ASSTFORE','Assistant Parks Foreman','Parks & Gardens Unit','LGSS17',1,'ENG-PARK-FOREMAN','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-PRK-ASSTPARKFORE-MUN-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(83,'ENG-PARK-WORK','General Worker','Parks & Gardens Unit','G1',7,'ENG-PARK-SUP','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-PRK-GENWK-MUN-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(84,'ENG-ROADS-ASSTDIR','Assistant Director - Roads & Drainages','Roads & Drainages Section','LGSS05',1,'ENG-DIR','Municipal',2,3,1,'2026-02-25 13:37:55','ENG-RDS-ADIRROADS-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(85,'ENG-CIVIL-CHIEF','Chief Civil Engineer','Roads & Drainages Section','LGSS06',1,'ENG-ROADS-ASSTDIR','Municipal',2,4,1,'2026-02-25 13:37:55','ENG-RDS-CHIEFCIV-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(86,'ENG-CIVIL07','Civil Engineer','Roads & Drainages Section','LGSS07',4,'ENG-CIVIL-CHIEF','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-RDS-CIVENG-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(87,'ENG-CIVIL-ASST','Assistant Civil Engineer','Roads & Drainages Section','LGSS10',1,'ENG-CIVIL07','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-RDS-ASSTCIV-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(88,'ENG-CIVIL-HIGHWAY','Superintendent – Highway','Roads & Drainages Section','LGSS12',1,'ENG-CIVIL07','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-RDS-SUPTHWY-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(89,'ENG-CIVIL-SENASSIST','Senior Engineering Assistant','Roads & Drainages Section','LGSS13',1,'ENG-CIVIL07','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-RDS-SNRENGASST-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(90,'ENG-CIVIL-ASSIST','Engineering Assistant','Roads & Drainages Section','LGSS14',2,'ENG-CIVIL07','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-RDS-ENGASST-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(91,'ENG-CIVIL-FOREMAN','Foreman','Roads & Drainages Section','LGSS14',1,'ENG-CIVIL07','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-RDS-FORE-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(92,'ENG-CIVIL-DRAFT','Draughtsman','Roads & Drainages Section','LGSS15',1,'ENG-CIVIL07','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-RDS-DRAFT-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(93,'ENG-CIVIL-ASSTFORE','Assistant Foreman','Roads & Drainages Section','LGSS17',3,'ENG-CIVIL-FOREMAN','Municipal',2,7,0,'2026-02-25 13:37:55','ENG-RDS-ASSTFORE-MUN-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(94,'ENG-MECH-CHIEF','Chief Mechanical Engineer - Buildings Construction & Maintenance','Mechanical Services Unit','LGSS06',1,'ENG-CONSTR-ASSTDIR','Municipal',2,3,1,'2026-02-25 13:37:55','ENG-MEC-CHIEFMECHBLD-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(95,'ENG-MECH07','Mechanical Engineer - Buildings Construction & Maintenance','Mechanical Services Unit','LGSS07',1,'ENG-MECH-CHIEF','Municipal',2,4,0,'2026-02-25 13:37:55','ENG-MEC-MECHENGBLD-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(96,'ENG-MECH-ASST','Assistant Mechanical Engineer','Mechanical Services Unit','LGSS10',1,'ENG-MECH07','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-MEC-ASSTMECH-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(97,'ENG-MECH-SUPT','Superintendent','Mechanical Services Unit','LGSS12',1,'ENG-MECH07','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-MEC-SUPT-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(98,'ENG-MECH-ASSTSUPT','Assistant Superintendent','Mechanical Services Unit','LGSS13',1,'ENG-MECH-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MEC-ASSTSUPT-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(99,'ENG-MECH-ASSIST','Engineering Assistant','Mechanical Services Unit','LGSS14',3,'ENG-MECH-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MEC-ENGASST-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(100,'ENG-MECH-AUTO','Auto Electrician','Mechanical Services Unit','LGSS14',1,'ENG-MECH-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MEC-AUTOELEC-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(101,'ENG-MECH-TECH','Mechanic','Mechanical Services Unit','LGSS14',4,'ENG-MECH-SUPT','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-MEC-MECH-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(102,'ENG-MECH-FOREMAN','Foreman','Mechanical Services Unit','LGSS14',1,'ENG-MECH-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MEC-FORE-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(103,'ENG-MECH-ASSTFORE','Assistant Foreman','Mechanical Services Unit','LGSS17',1,'ENG-MECH-FOREMAN','Municipal',2,7,0,'2026-02-25 13:37:55','ENG-MEC-ASSTFORE-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(104,'ENG-MECH-PLANT','Plant Operator','Mechanical Services Unit','LGSS14',16,'ENG-MECH-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MEC-PLANTOP-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(105,'ENG-MECH-HANDY','Mechanical Handyman','Mechanical Services Unit','LGSS18',3,'ENG-MECH-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MEC-MECHHAND-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(106,'ENG-MECH-WELDER','Welder','Mechanical Services Unit','LGSS14',1,'ENG-MECH-SUPT','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-MEC-WELD-MUN-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(107,'ENG-FIRE-CHIEF','Chief Fire Officer','Fire & Rescue Services Unit','LGSS06',1,'ENG-DIR','Municipal',2,3,1,'2026-02-25 13:37:55','ENG-FRS-CHIEFFIRE-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(108,'ENG-FIRE-DEPUTY','Deputy Chief Fire Officer','Fire & Rescue Services Unit','LGSS07',2,'ENG-FIRE-CHIEF','Municipal',2,4,0,'2026-02-25 13:37:55','ENG-FRS-DEPCHIEFFIRE-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(109,'ENG-FIRE-DIV','Divisional Fire Officer','Fire & Rescue Services Unit','LGSS09',2,'ENG-FIRE-DEPUTY','Municipal',2,4,0,'2026-02-25 13:37:55','ENG-FRS-DIVFIRE-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(110,'ENG-FIRE-ASSTDIV','Assistant Divisional Fire Officer','Fire & Rescue Services Unit','LGSS10',2,'ENG-FIRE-DIV','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-FRS-ASSTDIVFIRE-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(111,'ENG-FIRE-STN','Station Fire Officer','Fire & Rescue Services Unit','LGSS11',4,'ENG-FIRE-DIV','Municipal',2,5,0,'2026-02-25 13:37:55','ENG-FRS-STNFIRE-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(112,'ENG-FIRE-SUB','Sub-Officer','Fire & Rescue Services Unit','LGSS12',6,'ENG-FIRE-STN','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-FRS-SUBOFF-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(113,'ENG-FIRE-LEAD','Leading Firefighter','Fire & Rescue Services Unit','LGSS13',4,'ENG-FIRE-SUB','Municipal',2,6,0,'2026-02-25 13:37:55','ENG-FRS-LDFF-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(114,'ENG-FIRE','Firefighter','Fire & Rescue Services Unit','LGSS14',40,'ENG-FIRE-LEAD','Municipal',2,7,0,'2026-02-25 13:37:55','ENG-FRS-FF-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(115,'ENG-FIRE-DRV','Firefighter Driver','Fire & Rescue Services Unit','LGSS14',7,'ENG-FIRE-LEAD','Municipal',2,7,0,'2026-02-25 13:37:55','ENG-FRS-FFDRV-MUN-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(116,'ENG-WATSAN-COORD','Rural Water and Sanitation Coordinator','Rural Water & Sanitation Unit','LGSS06',1,'ENG-DIR','Municipal',2,3,1,'2026-02-25 13:37:55','ENG-WAT-RURALWATCOORD-MUN-WATSAN-01');
INSERT INTO eng_position_hierarchy VALUES(117,'ENG-WATSAN-ASST','Assistant Water and Sanitation Engineer','Rural Water & Sanitation Unit','LGSS07',1,'ENG-WATSAN-COORD','Municipal',2,4,0,'2026-02-25 13:37:55','ENG-WAT-ASSTWATENG-MUN-WATSAN-01');
INSERT INTO eng_position_hierarchy VALUES(118,'CITY-CLERK','Town Clerk','Council Administration','LGSS01',1,NULL,'City',3,1,1,'2026-02-25 13:37:57','ENG-ADM-TOWNCLRK-CIT-ADMIN-01');
INSERT INTO eng_position_hierarchy VALUES(119,'ENG-DIR','Director - Engineering','Engineering Department','LGSS03',1,'CITY-CLERK','City',3,2,1,'2026-02-25 13:37:57','ENG-GEN-DIRENG-CIT-GEN-01');
INSERT INTO eng_position_hierarchy VALUES(120,'ENG-CONSTR-ASSTDIR','Assistant Director - Construction & Maintenance','Construction & Maintenance Section','LGSS05',1,'ENG-DIR','City',3,3,1,'2026-02-25 13:37:57','ENG-MTN-ADIRCONST-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(121,'ENG-ELEC-CHIEF','Chief Electrical Engineer','Electrical Engineering Unit','LGSS06',1,'ENG-CONSTR-ASSTDIR','City',3,4,1,'2026-02-25 13:37:57','ENG-ELE-CHIEFELEC-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(122,'ENG-ELEC-ENG07','Electrical Engineer','Electrical Engineering Unit','LGSS07',1,'ENG-ELEC-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-ELE-ELECENG-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(123,'ENG-ELEC-ASST','Assistant Electrical Engineer','Electrical Engineering Unit','LGSS10',1,'ENG-ELEC-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-ELE-ASSTELEC-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(124,'ENG-ELEC-SEN-SUPT','Senior Electrical Superintendent','Electrical Engineering Unit','LGSS10',1,'ENG-ELEC-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-ELE-SNRELECSUPT-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(125,'ENG-ELEC-SUPT','Superintendent','Electrical Engineering Unit','LGSS12',1,'ENG-ELEC-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-ELE-SUPT-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(126,'ENG-ELEC-ASSTSUPT','Assistant Superintendent','Electrical Engineering Unit','LGSS13',2,'ENG-ELEC-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-ELE-ASSTSUPT-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(127,'ENG-ELEC-SENASSIST','Senior Engineering Assistant','Electrical Engineering Unit','LGSS13',1,'ENG-ELEC-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-ELE-SNRENGASST-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(128,'ENG-ELEC-WORKSUP','Works Supervisor','Electrical Engineering Unit','LGSS14',2,'ENG-ELEC-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-ELE-WRKSUP-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(129,'ENG-ELEC-TECH','Electrician','Electrical Engineering Unit','LGSS14',5,'ENG-ELEC-WORKSUP','City',3,5,0,'2026-02-25 13:37:57','ENG-ELE-ELEC-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(130,'ENG-ELEC-FOREMAN','Foreman','Electrical Engineering Unit','LGSS15',1,'ENG-ELEC-WORKSUP','City',3,7,0,'2026-02-25 13:37:57','ENG-ELE-FORE-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(131,'ENG-ELEC-ASSTFORE','Assistant Foreman','Electrical Engineering Unit','LGSS17',2,'ENG-ELEC-FOREMAN','City',3,8,0,'2026-02-25 13:37:57','ENG-ELE-ASSTFORE-CIT-ELEC-01');
INSERT INTO eng_position_hierarchy VALUES(132,'ENG-QSURV-CHIEF','Chief Quantity Surveyor','Quantity Surveying Unit','LGSS06',1,'ENG-CONSTR-ASSTDIR','City',3,4,1,'2026-02-25 13:37:57','ENG-SUR-CHIEFQS-CIT-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(133,'ENG-QSURV07','Quantity Surveyor','Quantity Surveying Unit','LGSS07',2,'ENG-QSURV-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-SUR-QS-CIT-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(134,'ENG-QSURV-ASST','Assistant Quantity Surveyor','Quantity Surveying Unit','LGSS10',4,'ENG-QSURV07','City',3,5,0,'2026-02-25 13:37:57','ENG-SUR-ASSTQS-CIT-SURV-01');
INSERT INTO eng_position_hierarchy VALUES(135,'ENG-ARCH-CHIEF','Chief Architect','Architecture Unit','LGSS06',1,'ENG-CONSTR-ASSTDIR','City',3,4,1,'2026-02-25 13:37:57','ENG-ARC-CHIEFARCH-CIT-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(136,'ENG-ARCH07','Architect','Architecture Unit','LGSS07',5,'ENG-ARCH-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-ARC-ARCH-CIT-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(137,'ENG-ARCH-ASST','Assistant Architect','Architecture Unit','LGSS10',5,'ENG-ARCH07','City',3,5,0,'2026-02-25 13:37:57','ENG-ARC-ASSTARCH-CIT-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(138,'ENG-ARCH-DRAFT','Draughtsman','Architecture Unit','LGSS15',2,'ENG-ARCH07','City',3,6,0,'2026-02-25 13:37:57','ENG-ARC-DRAFT-CIT-ARCH-01');
INSERT INTO eng_position_hierarchy VALUES(139,'ENG-MAINT-SUPT','Maintenance Superintendent','Maintenance Unit','LGSS10',1,'ENG-CONSTR-ASSTDIR','City',3,4,1,'2026-02-25 13:37:57','ENG-MTN-MAINTSUPT-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(140,'ENG-MAINT-ASSTSUPT','Assistant Superintendent','Maintenance Unit','LGSS13',1,'ENG-MAINT-SUPT','City',3,5,0,'2026-02-25 13:37:57','ENG-MTN-ASSTSUPT-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(141,'ENG-MAINT-ASSTSUPT2','Assistant Superintendent','Maintenance Unit','LGSS12',1,'ENG-MAINT-SUPT','City',3,5,0,'2026-02-25 13:37:57','ENG-MTN-ASSTSUPT-CIT-MAINT-02');
INSERT INTO eng_position_hierarchy VALUES(142,'ENG-MAINT-FOREMAN','Foreman','Maintenance Unit','LGSS14',2,'ENG-MAINT-SUPT','City',3,5,0,'2026-02-25 13:37:57','ENG-MTN-FORE-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(143,'ENG-MAINT-PLUM','Plumber','Maintenance Unit','LGSS15',3,'ENG-MAINT-FOREMAN','City',3,6,0,'2026-02-25 13:37:57','ENG-MTN-PLUMB-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(144,'ENG-MAINT-BRICK','Bricklayer','Maintenance Unit','LGSS15',3,'ENG-MAINT-FOREMAN','City',3,6,0,'2026-02-25 13:37:57','ENG-MTN-BRICK-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(145,'ENG-MAINT-CARP','Carpenter','Maintenance Unit','LGSS15',2,'ENG-MAINT-FOREMAN','City',3,6,0,'2026-02-25 13:37:57','ENG-MTN-CARP-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(146,'ENG-MAINT-PAINT','Painter','Maintenance Unit','LGSS15',2,'ENG-MAINT-FOREMAN','City',3,6,0,'2026-02-25 13:37:57','ENG-MTN-PAINT-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(147,'ENG-MAINT-GENWORK','General Worker','Maintenance Unit','G3',6,'ENG-MAINT-FOREMAN','City',3,6,0,'2026-02-25 13:37:57','ENG-MTN-GENWK-CIT-MAINT-01');
INSERT INTO eng_position_hierarchy VALUES(148,'ENG-PARK-MGR','Parks & Gardens Manager','Parks & Gardens Unit','LGSS07',1,'ENG-DIR','City',3,3,1,'2026-02-25 13:37:57','ENG-PRK-PARKGMGR-CIT-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(149,'ENG-PARK-SUPT','Superintendent','Parks & Gardens Unit','LGSS12',1,'ENG-PARK-MGR','City',3,4,0,'2026-02-25 13:37:57','ENG-PRK-SUPT-CIT-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(150,'ENG-PARK-ASSTSUPT','Assistant Superintendent','Parks & Gardens Unit','LGSS13',2,'ENG-PARK-SUPT','City',3,5,0,'2026-02-25 13:37:57','ENG-PRK-ASSTSUPT-CIT-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(151,'ENG-PARK-FOREMAN','Parks Foreman','Parks & Gardens Unit','LGSS14',4,'ENG-PARK-SUPT','City',3,5,0,'2026-02-25 13:37:57','ENG-PRK-PARKFORE-CIT-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(152,'ENG-PARK-SUP','Parks Supervisor','Parks & Gardens Unit','LGSS15',4,'ENG-PARK-FOREMAN','City',3,4,0,'2026-02-25 13:37:57','ENG-PRK-PARKSUP-CIT-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(153,'ENG-PARK-ASSTFORE','Assistant Parks Foreman','Parks & Gardens Unit','LGSS17',4,'ENG-PARK-FOREMAN','City',3,6,0,'2026-02-25 13:37:57','ENG-PRK-ASSTPARKFORE-CIT-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(154,'ENG-PARK-WORK','General Worker','Parks & Gardens Unit','G1',7,'ENG-PARK-SUP','City',3,5,0,'2026-02-25 13:37:57','ENG-PRK-GENWK-CIT-PARK-01');
INSERT INTO eng_position_hierarchy VALUES(155,'ENG-ROADS-ASSTDIR','Assistant Director - Roads & Drainages','Roads & Drainages Section','LGSS05',1,'ENG-DIR','City',3,3,1,'2026-02-25 13:37:57','ENG-RDS-ADIRROADS-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(156,'ENG-CIVIL-CHIEF','Chief Civil Engineer','Roads & Drainages Section','LGSS06',1,'ENG-ROADS-ASSTDIR','City',3,4,1,'2026-02-25 13:37:57','ENG-RDS-CHIEFCIV-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(157,'ENG-CIVIL06','Civil Engineer','Roads & Drainages Section','LGSS06',4,'ENG-CIVIL-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-RDS-CIVENG-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(158,'ENG-CIVIL07','Civil Engineer','Roads & Drainages Section','LGSS07',6,'ENG-CIVIL-CHIEF','City',3,5,0,'2026-02-25 13:37:57','ENG-RDS-CIVENG-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(159,'ENG-CIVIL-ASST','Assistant Civil Engineer','Roads & Drainages Section','LGSS10',10,'ENG-CIVIL06','City',3,5,0,'2026-02-25 13:37:57','ENG-RDS-ASSTCIV-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(160,'ENG-CIVIL-HIGHWAY','Superintendent – Highway','Roads & Drainages Section','LGSS12',1,'ENG-CIVIL06','City',3,6,0,'2026-02-25 13:37:57','ENG-RDS-SUPTHWY-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(161,'ENG-CIVIL-SENASSIST','Senior Engineering Assistant','Roads & Drainages Section','LGSS13',2,'ENG-CIVIL06','City',3,6,0,'2026-02-25 13:37:57','ENG-RDS-SNRENGASST-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(162,'ENG-CIVIL-ASSTSUPT','Assistant Superintendent - Highway','Roads & Drainages Section','LGSS13',2,'ENG-CIVIL-HIGHWAY','City',3,7,0,'2026-02-25 13:37:57','ENG-RDS-ASSTSUPTHWY-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(163,'ENG-CIVIL-ASSIST','Engineering Assistant - Roads','Roads & Drainages Section','LGSS14',1,'ENG-CIVIL06','City',3,6,0,'2026-02-25 13:37:57','ENG-RDS-ENGASSTRD-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(164,'ENG-CIVIL-FOREMAN','Foreman','Roads & Drainages Section','LGSS14',3,'ENG-CIVIL06','City',3,6,0,'2026-02-25 13:37:57','ENG-RDS-FORE-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(165,'ENG-CIVIL-ASSTFORE','Assistant Foreman','Roads & Drainages Section','LGSS17',4,'ENG-CIVIL-FOREMAN','City',3,7,0,'2026-02-25 13:37:57','ENG-RDS-ASSTFORE-CIT-ROAD-01');
INSERT INTO eng_position_hierarchy VALUES(166,'ENG-MECH-CHIEF','Chief Mechanical Engineer','Mechanical Services Unit','LGSS06',1,'ENG-DIR','City',3,3,1,'2026-02-25 13:37:57','ENG-MEC-CHIEFMECH-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(167,'ENG-MECH07','Mechanical Engineer','Mechanical Services Unit','LGSS07',1,'ENG-MECH-CHIEF','City',3,4,0,'2026-02-25 13:37:57','ENG-MEC-MECHENG-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(168,'ENG-MECH-ASST','Assistant Mechanical Engineer','Mechanical Services Unit','LGSS10',2,'ENG-MECH07','City',3,5,0,'2026-02-25 13:37:57','ENG-MEC-ASSTMECH-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(169,'ENG-MECH-SUPT','Superintendent','Mechanical Services Unit','LGSS12',1,'ENG-MECH07','City',3,5,0,'2026-02-25 13:37:57','ENG-MEC-SUPT-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(170,'ENG-MECH-ASSTSUPT','Assistant Superintendent','Mechanical Services Unit','LGSS13',2,'ENG-MECH-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-MEC-ASSTSUPT-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(171,'ENG-MECH-ASSIST','Engineering Assistant','Mechanical Services Unit','LGSS14',1,'ENG-MECH-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-MEC-ENGASST-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(172,'ENG-MECH-AUTO','Auto Electrician','Mechanical Services Unit','LGSS14',1,'ENG-MECH-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-MEC-AUTOELEC-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(173,'ENG-MECH-TECH','Mechanic','Mechanical Services Unit','LGSS14',14,'ENG-MECH-SUPT','City',3,5,0,'2026-02-25 13:37:57','ENG-MEC-MECH-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(174,'ENG-MECH-FOREMAN','Foreman','Mechanical Services Unit','LGSS14',1,'ENG-MECH-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-MEC-FORE-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(175,'ENG-MECH-ASSTFORE','Assistant Foreman','Mechanical Services Unit','LGSS17',1,'ENG-MECH-FOREMAN','City',3,7,0,'2026-02-25 13:37:57','ENG-MEC-ASSTFORE-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(176,'ENG-MECH-PLANT','Plant Operator','Mechanical Services Unit','LGSS14',6,'ENG-MECH-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-MEC-PLANTOP-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(177,'ENG-MECH-HANDY','Mechanical Handyman','Mechanical Services Unit','LGSS18',3,'ENG-MECH-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-MEC-MECHHAND-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(178,'ENG-MECH-WELDER','Welder','Mechanical Services Unit','LGSS14',3,'ENG-MECH-SUPT','City',3,6,0,'2026-02-25 13:37:57','ENG-MEC-WELD-CIT-MECH-01');
INSERT INTO eng_position_hierarchy VALUES(179,'ENG-FIRE-CHIEF','Chief Fire Officer','Fire & Rescue Services Unit','LGSS06',1,'ENG-DIR','City',3,3,1,'2026-02-25 13:37:57','ENG-FRS-CHIEFFIRE-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(180,'ENG-FIRE-DEPUTY','Deputy Chief Fire Officer','Fire & Rescue Services Unit','LGSS07',2,'ENG-FIRE-CHIEF','City',3,4,0,'2026-02-25 13:37:57','ENG-FRS-DEPCHIEFFIRE-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(181,'ENG-FIRE-DIV','Divisional Fire Officer','Fire & Rescue Services Unit','LGSS09',2,'ENG-FIRE-DEPUTY','City',3,4,0,'2026-02-25 13:37:57','ENG-FRS-DIVFIRE-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(182,'ENG-FIRE-ASSTDIV','Assistant Divisional Fire Officer','Fire & Rescue Services Unit','LGSS10',2,'ENG-FIRE-DIV','City',3,5,0,'2026-02-25 13:37:57','ENG-FRS-ASSTDIVFIRE-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(183,'ENG-FIRE-STN','Station Fire Officer','Fire & Rescue Services Unit','LGSS11',4,'ENG-FIRE-DIV','City',3,5,0,'2026-02-25 13:37:57','ENG-FRS-STNFIRE-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(184,'ENG-FIRE-SUB','Sub-Officer','Fire & Rescue Services Unit','LGSS12',6,'ENG-FIRE-STN','City',3,6,0,'2026-02-25 13:37:57','ENG-FRS-SUBOFF-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(185,'ENG-FIRE-LEAD','Leading Firefighter','Fire & Rescue Services Unit','LGSS13',4,'ENG-FIRE-SUB','City',3,6,0,'2026-02-25 13:37:57','ENG-FRS-LDFF-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(186,'ENG-FIRE','Firefighter','Fire & Rescue Services Unit','LGSS14',52,'ENG-FIRE-LEAD','City',3,7,0,'2026-02-25 13:37:57','ENG-FRS-FF-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(187,'ENG-FIRE-DRV','Firefighter Driver','Fire & Rescue Services Unit','LGSS14',6,'ENG-FIRE-LEAD','City',3,7,0,'2026-02-25 13:37:57','ENG-FRS-FFDRV-CIT-FIRE-01');
INSERT INTO eng_position_hierarchy VALUES(188,'ENG-WATSAN-COORD','Rural Water and Sanitation Coordinator','Rural Water & Sanitation Unit','LGSS06',1,'ENG-DIR','City',3,3,1,'2026-02-25 13:37:57','ENG-WAT-RURALWATCOORD-CIT-WATSAN-01');
INSERT INTO eng_position_hierarchy VALUES(189,'ENG-WATSAN-ENG','Rural Water and Sanitation Engineer','Rural Water & Sanitation Unit','LGSS07',2,'ENG-WATSAN-COORD','City',3,4,0,'2026-02-25 13:37:57','ENG-WAT-RURALWATENG-CIT-WATSAN-01');
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
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CONSTR-ASSTDIR','Assistant Director - Construction & Maintenance','Municipal','MTN','ADIR','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ASST-DIR','Assistant Director - Engineering','Town','GEN','ADIR','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ROADS-ASSTDIR','Assistant Director - Roads & Drainages','City','GEN','ADIR','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ROADS-ASSTDIR','Assistant Director - Roads & Drainages','Municipal','GEN','ADIR','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-ASSTDIV','Assistant Divisional Fire Officer','City','FRS','ASST','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-ASSTDIV','Assistant Divisional Fire Officer','Municipal','FRS','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ASST','Assistant Electrical Engineer','City','ELE','ASSTENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ASST','Assistant Electrical Engineer','Municipal','ELE','ASSTENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ASST','Assistant Electrical Engineer','Town','ELE','ASSTENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASSTFORE','Assistant Foreman','City','GEN','ASST','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ASSTFORE','Assistant Foreman','City','ELE','ASST','CIT',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASSTFORE','Assistant Foreman','City','MEC','ASST','CIT',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-ASSTFORE','Assistant Foreman','Municipal','ARC','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASSTFORE','Assistant Foreman','Municipal','GEN','ASST','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ASSTFORE','Assistant Foreman','Municipal','ELE','ASST','MUN',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASSTFORE','Assistant Foreman','Municipal','MEC','ASST','MUN',4);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASST','Assistant Mechanical Engineer','City','MEC','ASSTENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASST','Assistant Mechanical Engineer','Municipal','MEC','ASSTENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASST','Assistant Mechanical Engineer','Town','MTN','ASSTENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-ASSTFORE','Assistant Parks Foreman','City','GEN','ASST','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-ASSTFORE','Assistant Parks Foreman','Municipal','GEN','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV-ASST','Assistant Quantity Surveyor','City','SUR','ASST','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV-ASST','Assistant Quantity Surveyor','Municipal','SUR','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV-ASST','Assistant Quantity Surveyor','Town','SUR','ASST','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ASSTSUPT','Assistant Superintendent','City','ELE','ASST','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-ASSTSUPT','Assistant Superintendent','City','MTN','ASST','CIT',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-ASSTSUPT2','Assistant Superintendent','City','MTN','ASST','CIT',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASSTSUPT','Assistant Superintendent','City','MEC','ASST','CIT',4);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-ASSTSUPT','Assistant Superintendent','City','GEN','ASST','CIT',5);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ASSTSUPT','Assistant Superintendent','Municipal','ELE','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-ASSTSUPT','Assistant Superintendent','Municipal','MTN','ASST','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASSTSUPT','Assistant Superintendent','Municipal','MEC','ASST','MUN',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-ASSTSUPT','Assistant Superintendent','Municipal','GEN','ASST','MUN',4);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASSTSUPT','Assistant Superintendent - Highway','City','GEN','ASST','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-WATSAN-ASST','Assistant Water and Sanitation Engineer','Municipal','GEN','ASSTENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-AUTO','Auto Electrician','City','MEC','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-AUTO','Auto Electrician','Municipal','MEC','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-AUTO','Auto Electrician','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-BRICK','Bricklayer','City','MTN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-BRICK','Bricklayer','Municipal','MTN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-BRICK','Bricklayer','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-CARP','Carpenter','City','MTN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-CARP','Carpenter','Municipal','MTN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CARP','Carpenter','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-CHIEF','Chief Architect','City','ARC','CHIEF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-CHIEF','Chief Architect','Municipal','ARC','CHIEF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-CHIEF','Chief Civil Engineer','City','GEN','CHIEF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-CHIEF','Chief Civil Engineer','Municipal','GEN','CHIEF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-CHIEF','Chief Electrical Engineer','City','ELE','CHIEF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-CHIEF','Chief Electrical Engineer','Municipal','ELE','CHIEF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-CHIEF','Chief Electrical Engineer','Town','ELE','CHIEF','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-CHIEF','Chief Fire Officer','City','FRS','CHIEF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-CHIEF','Chief Fire Officer','Municipal','FRS','CHIEF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-CHIEF','Chief Mechanical Engineer','City','MEC','CHIEF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-CHIEF','Chief Mechanical Engineer - Buildings Construction & Maintenance','Municipal','MEC','CHIEF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV-CHIEF','Chief Quantity Surveyor','City','SUR','CHIEF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV-CHIEF','Chief Quantity Surveyor','Municipal','SUR','CHIEF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL06','Civil Engineer','City','GEN','ENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL07','Civil Engineer','City','GEN','ENG','CIT',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL07','Civil Engineer','Municipal','GEN','ENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL','Civil Engineer','Town','GEN','ENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-CLERK','Clerk of Works','Municipal','ARC','CLK','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','COUNCIL-SEC','Council Secretary','Town','ADM','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DEPUTY','Deputy Chief Fire Officer','City','FRS','CHIEF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DEPUTY','Deputy Chief Fire Officer','Municipal','FRS','CHIEF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-DIR','Director - Engineering','City','GEN','DIR','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-DIR','Director - Engineering','Municipal','GEN','DIR','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-DIR','Director - Engineering','Town','GEN','DIR','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DIV','Divisional Fire Officer','City','FRS','OFF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DIV','Divisional Fire Officer','Municipal','FRS','OFF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DIV','Divisional Fire Officer','Town','FRS','OFF','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-DRAFT','Draughtsman','City','ARC','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-DRAFT','Draughtsman','Municipal','ARC','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-DRAFT','Draughtsman','Municipal','GEN','GEN','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-DRAFT','Draughtsman','Town','ARC','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ENG07','Electrical Engineer','City','ELE','ENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-ENG07','Electrical Engineer','Municipal','ELE','ENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-HEAD','Electrical Engineer','Town','ELE','ENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-TECH','Electrician','City','ELE','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-TECH','Electrician','Municipal','ELE','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-TECH','Electrician','Town','ELE','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASSIST','Engineering Assistant','City','MEC','ASSTENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASSIST','Engineering Assistant','Municipal','GEN','ASSTENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-ASSIST','Engineering Assistant','Municipal','MEC','ASSTENG','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-TECH','Engineering Assistant','Town','GEN','ASSTENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-ASSIST','Engineering Assistant - Roads','City','GEN','ASSTENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-EXCAV','Excavator Operator','Town','MTN','OP','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE','Firefighter','City','FRS','FF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE','Firefighter','Municipal','FRS','FF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE','Firefighter','Town','FRS','FF','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DRV','Firefighter Driver','City','FRS','FFDRV','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DRV','Firefighter Driver','Municipal','FRS','FFDRV','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-DRV','Firefighter Driver','Town','FRS','FFDRV','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-FOREMAN','Foreman','City','GEN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-FOREMAN','Foreman','City','ELE','GEN','CIT',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-FOREMAN','Foreman','City','MTN','GEN','CIT',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-FOREMAN','Foreman','City','MEC','GEN','CIT',4);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-FOREMAN','Foreman','Municipal','ARC','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-FOREMAN','Foreman','Municipal','GEN','GEN','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-FOREMAN','Foreman','Municipal','ELE','GEN','MUN',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-FOREMAN','Foreman','Municipal','MTN','GEN','MUN',4);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-FOREMAN','Foreman','Municipal','MEC','GEN','MUN',5);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-GENWORK','General Worker','City','MTN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-WORK','General Worker','City','GEN','GEN','CIT',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-GENWORK','General Worker','Municipal','MTN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-WORK','General Worker','Municipal','GEN','GEN','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-GENWORK','General Worker','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-WORK','General Worker','Town','GEN','GEN','TOW',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-LEAD','Leading Firefighter','City','FRS','FF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-LEAD','Leading Firefighter','Municipal','FRS','FF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-LEAD','Leading Firefighter','Town','FRS','FF','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-SUPT','Maintenance Superintendent','City','MTN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-SUPT','Maintenance Superintendent','Municipal','MTN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-SUP','Maintenance Superintendent','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-TECH','Mechanic','City','MEC','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-TECH','Mechanic','Municipal','MEC','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-TECH','Mechanic','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH07','Mechanical Engineer','City','MEC','ENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH','Mechanical Engineer','Town','MEC','ENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH07','Mechanical Engineer - Buildings Construction & Maintenance','Municipal','MEC','ENG','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-HANDY','Mechanical Handyman','City','MEC','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-HANDY','Mechanical Handyman','Municipal','MEC','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-HANDY','Mechanical Handyman','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MOTOR','Motor Vehicle Examiner','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-PAINT','Painter','City','MTN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-PAINT','Painter','Municipal','MTN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PAINT','Painter','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-MGR','Parks & Gardens Manager','City','GEN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-FOREMAN','Parks Foreman','City','GEN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-FOREMAN','Parks Foreman','Municipal','GEN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-MGR','Parks Manager','Municipal','GEN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-MGR','Parks Manager','Town','GEN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-SUP','Parks Supervisor','City','GEN','SUP','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-SUP','Parks Supervisor','Municipal','GEN','SUP','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-SUP','Parks Supervisor','Town','GEN','SUP','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-PLANT','Plant Operator','City','MEC','OP','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-PLANT','Plant Operator','Municipal','MEC','OP','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-PLUM','Plumber','City','MTN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MAINT-PLUM','Plumber','Municipal','MTN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PLUM','Plumber','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV-ASSIST','Quantity Surveying Assistant','Municipal','SUR','ASST','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV07','Quantity Surveyor','City','SUR','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV07','Quantity Surveyor','Municipal','SUR','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV','Quantity Surveyor','Town','SUR','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-WATSAN-COORD','Rural Water and Sanitation Coordinator','City','GEN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-WATSAN-COORD','Rural Water and Sanitation Coordinator','Municipal','GEN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-WATSAN-ENG','Rural Water and Sanitation Engineer','City','GEN','ENG','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-SCALER','Scaler Operator','Town','MTN','OP','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ARCH-SENCLERK','Senior Clerk of Works','Municipal','ARC','SNR','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CLERK','Senior Clerk of Works','Town','ARC','SNR','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-SEN-SUPT','Senior Electrical Superintendent','City','ELE','SNR','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-SENASSIST','Senior Engineering Assistant','City','GEN','SNR','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-SENASSIST','Senior Engineering Assistant','City','ELE','SNR','CIT',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-SENASSIST','Senior Engineering Assistant','Municipal','GEN','SNR','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-SENASSIST','Senior Engineering Assistant','Municipal','ELE','SNR','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-QSURV-SENASSIST','Senior Quantity Surveying Assistant','Municipal','SUR','SNR','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-STN','Station Fire Officer','City','FRS','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-STN','Station Fire Officer','Municipal','FRS','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-STN','Station Officer','Town','FRS','STNOFF','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-SUB','Sub-Officer','City','FRS','OFF','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-SUB','Sub-Officer','Municipal','FRS','OFF','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-FIRE-SUB','Sub-Officer','Town','FRS','OFF','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-SUPT','Superintendent','City','ELE','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-SUPT','Superintendent','City','MEC','GEN','CIT',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-SUPT','Superintendent','City','GEN','GEN','CIT',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-SUPT','Superintendent','Municipal','ELE','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-SUPT','Superintendent','Municipal','MEC','GEN','MUN',2);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-PARK-SUPT','Superintendent','Municipal','GEN','GEN','MUN',3);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-HIGHWAY','Superintendent – Highway','City','GEN','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-CIVIL-HIGHWAY','Superintendent – Highway','Municipal','GEN','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','CITY-CLERK','Town Clerk','City','ADM','CLK','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','TOWN-CLERK','Town Clerk','Municipal','ADM','CLK','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-WATSAN','Water and Sanitation Engineer','Town','GEN','ENG','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-WELDER','Welder','City','MEC','GEN','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-MECH-WELDER','Welder','Municipal','MEC','GEN','MUN',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-WELDER','Welder','Town','MTN','GEN','TOW',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-WORKSUP','Works Supervisor','City','ELE','SUP','CIT',1);
INSERT INTO position_standard_id_map VALUES('ENG','ENG-ELEC-WORKSUP','Works Supervisor','Municipal','ELE','SUP','MUN',1);
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
INSERT INTO position_role_codes VALUES('Engineering Assistant','ENGASST','Civil');
INSERT INTO position_role_codes VALUES('Engineering Assistant - Roads','ENGASSTRD','Civil');
INSERT INTO position_role_codes VALUES('Senior Engineering Assistant','SNRENGASST','Civil');
INSERT INTO position_role_codes VALUES('Superintendent – Highway','SUPTHWY','Civil');
INSERT INTO position_role_codes VALUES('Assistant Superintendent - Highway','ASSTSUPTHWY','Civil');
INSERT INTO position_role_codes VALUES('Electrical Engineer','ELECENG','Electrical');
INSERT INTO position_role_codes VALUES('Chief Electrical Engineer','CHIEFELEC','Electrical');
INSERT INTO position_role_codes VALUES('Assistant Electrical Engineer','ASSTELEC','Electrical');
INSERT INTO position_role_codes VALUES('Electrician','ELEC','Electrical');
INSERT INTO position_role_codes VALUES('Senior Electrical Superintendent','SNRELECSUPT','Electrical');
INSERT INTO position_role_codes VALUES('Works Supervisor','WRKSUP','Electrical');
INSERT INTO position_role_codes VALUES('Mechanical Engineer','MECHENG','Mechanical');
INSERT INTO position_role_codes VALUES('Mechanical Engineer - Buildings Construction & Maintenance','MECHENGBLD','Mechanical');
INSERT INTO position_role_codes VALUES('Chief Mechanical Engineer','CHIEFMECH','Mechanical');
INSERT INTO position_role_codes VALUES('Chief Mechanical Engineer - Buildings Construction & Maintenance','CHIEFMECHBLD','Mechanical');
INSERT INTO position_role_codes VALUES('Assistant Mechanical Engineer','ASSTMECH','Mechanical');
INSERT INTO position_role_codes VALUES('Mechanic','MECH','Mechanical');
INSERT INTO position_role_codes VALUES('Mechanical Handyman','MECHHAND','Mechanical');
INSERT INTO position_role_codes VALUES('Auto Electrician','AUTOELEC','Mechanical');
INSERT INTO position_role_codes VALUES('Motor Vehicle Examiner','MVE','Mechanical');
INSERT INTO position_role_codes VALUES('Plant Operator','PLANTOP','Mechanical');
INSERT INTO position_role_codes VALUES('Welder','WELD','Mechanical');
INSERT INTO position_role_codes VALUES('Excavator Operator','EXCAV','Mechanical');
INSERT INTO position_role_codes VALUES('Scaler Operator','SCALER','Mechanical');
INSERT INTO position_role_codes VALUES('Chief Fire Officer','CHIEFFIRE','Fire');
INSERT INTO position_role_codes VALUES('Deputy Chief Fire Officer','DEPCHIEFFIRE','Fire');
INSERT INTO position_role_codes VALUES('Divisional Fire Officer','DIVFIRE','Fire');
INSERT INTO position_role_codes VALUES('Assistant Divisional Fire Officer','ASSTDIVFIRE','Fire');
INSERT INTO position_role_codes VALUES('Station Officer','STNOFF','Fire');
INSERT INTO position_role_codes VALUES('Station Fire Officer','STNFIRE','Fire');
INSERT INTO position_role_codes VALUES('Sub-Officer','SUBOFF','Fire');
INSERT INTO position_role_codes VALUES('Leading Firefighter','LDFF','Fire');
INSERT INTO position_role_codes VALUES('Firefighter','FF','Fire');
INSERT INTO position_role_codes VALUES('Firefighter Driver','FFDRV','Fire');
INSERT INTO position_role_codes VALUES('Quantity Surveyor','QS','Quantity Surveying');
INSERT INTO position_role_codes VALUES('Chief Quantity Surveyor','CHIEFQS','Quantity Surveying');
INSERT INTO position_role_codes VALUES('Assistant Quantity Surveyor','ASSTQS','Quantity Surveying');
INSERT INTO position_role_codes VALUES('Quantity Surveying Assistant','QSASST','Quantity Surveying');
INSERT INTO position_role_codes VALUES('Senior Quantity Surveying Assistant','SNRQSASST','Quantity Surveying');
INSERT INTO position_role_codes VALUES('Maintenance Superintendent','MAINTSUPT','Maintenance');
INSERT INTO position_role_codes VALUES('Plumber','PLUMB','Maintenance');
INSERT INTO position_role_codes VALUES('Bricklayer','BRICK','Maintenance');
INSERT INTO position_role_codes VALUES('Carpenter','CARP','Maintenance');
INSERT INTO position_role_codes VALUES('Painter','PAINT','Maintenance');
INSERT INTO position_role_codes VALUES('General Worker','GENWK','Maintenance');
INSERT INTO position_role_codes VALUES('Parks Manager','PARKMGR','Parks');
INSERT INTO position_role_codes VALUES('Parks & Gardens Manager','PARKGMGR','Parks');
INSERT INTO position_role_codes VALUES('Parks Foreman','PARKFORE','Parks');
INSERT INTO position_role_codes VALUES('Assistant Parks Foreman','ASSTPARKFORE','Parks');
INSERT INTO position_role_codes VALUES('Parks Supervisor','PARKSUP','Parks');
INSERT INTO position_role_codes VALUES('Water and Sanitation Engineer','WATSANENG','Water');
INSERT INTO position_role_codes VALUES('Rural Water and Sanitation Coordinator','RURALWATCOORD','Water');
INSERT INTO position_role_codes VALUES('Rural Water and Sanitation Engineer','RURALWATENG','Water');
INSERT INTO position_role_codes VALUES('Assistant Water and Sanitation Engineer','ASSTWATENG','Water');
INSERT INTO position_role_codes VALUES('Foreman','FORE','General');
INSERT INTO position_role_codes VALUES('Assistant Foreman','ASSTFORE','General');
INSERT INTO position_role_codes VALUES('Superintendent','SUPT','General');
INSERT INTO position_role_codes VALUES('Assistant Superintendent','ASSTSUPT','General');
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
INSERT INTO position_supervision VALUES(10,'FIN-COM-LIC-TOW-01','FIN-COM-CHIEFLIC-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(11,'FIN-REV-COLL-TOW-01','FIN-ACC-CHIEF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:40:59');
INSERT INTO position_supervision VALUES(12,'FIN-REV-CASH-TOW-01','FIN-ACC-CHIEF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(13,'FIN-STO-OFF-TOW-01','FIN-ACC-CHIEF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(14,'FIN-STO-OFF-TOW-02','FIN-ACC-CHIEF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(15,'FIN-STO-AST-TOW-01','FIN-STO-OFF-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(16,'FIN-STO-ASTHLT-TOW-01','FIN-HLT-ASTACC-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(17,'FIN-STO-OFFHLT-TOW-01','FIN-HLT-ASTACC-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(18,'FIN-SUP-HOUSE-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(19,'FIN-SUP-LAUN-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(20,'FIN-SUP-REC-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(21,'FIN-COM-BAR-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(22,'FIN-COM-CHEF-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(23,'FIN-COM-COOK-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:00');
INSERT INTO position_supervision VALUES(24,'FIN-COM-WAIT-TOW-01','FIN-COM-MGR-TOW-01','FIN-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'FIN',1,'2026-02-27 21:41:01');
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
INSERT INTO hra_supervision VALUES(11,'HRA-HRM-SNR-TOW-01','HRA-HRM-CHIEF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(12,'HRA-HRM-OFF-TOW-01','HRA-HRM-SNR-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(13,'HRA-HRM-OFF-TOW-02','HRA-HRM-SNR-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(14,'HRA-HRM-OFF-TOW-03','HRA-HRM-SNR-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(15,'HRA-SEC-SNR-TOW-01','HRA-ADM-CHIEF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(16,'HRA-SEC-OFF-TOW-01','HRA-SEC-SNR-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(17,'HRA-SEC-INSP-TOW-01','HRA-SEC-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(18,'HRA-SEC-INSP-TOW-02','HRA-SEC-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(19,'HRA-SEC-INSP-TOW-03','HRA-SEC-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(20,'HRA-SEC-INSP-TOW-04','HRA-SEC-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(21,'HRA-SEC-PC-TOW-01','HRA-SEC-INSP-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(22,'HRA-SEC-SGT-TOW-01','HRA-SEC-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(23,'HRA-SUP-DRV1-TOW-01','HRA-ADM-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(24,'HRA-SUP-DRV3-TOW-01','HRA-ADM-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(25,'HRA-SUP-GEN-TOW-01','HRA-ADM-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:00');
INSERT INTO hra_supervision VALUES(26,'HRA-SUP-ORD-TOW-01','HRA-ADM-OFF-TOW-01','HRA-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'HRA',1,'2026-02-28 21:48:02');
INSERT INTO hra_supervision VALUES(27,'HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(28,'HRA-ADM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(29,'HRA-ADM-SEC-MUN-01','HRA-ADM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(30,'HRA-ADM-SNR-MUN-01','HRA-ADM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(31,'HRA-ADM-SNR-MUN-02','HRA-ADM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(32,'HRA-ADM-OFF-MUN-01','HRA-ADM-SNR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(33,'HRA-ADM-OFF-MUN-02','HRA-ADM-SNR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(34,'HRA-ADM-OFF-MUN-03','HRA-ADM-SNR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(35,'HRA-ADM-OFF-MUN-04','HRA-ADM-SNR-MUN-02','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(36,'HRA-ADM-OFF-MUN-05','HRA-ADM-SNR-MUN-02','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(37,'HRA-ADM-OFF-MUN-06','HRA-ADM-SNR-MUN-02','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(38,'HRA-RGS-SUP-MUN-01','HRA-ADM-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(39,'HRA-RGS-CLK-MUN-01','HRA-RGS-SUP-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(40,'HRA-ADM-HDDRV-MUN-01','HRA-ADM-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(41,'HRA-ADM-DRV-MUN-01','HRA-ADM-HDDRV-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(42,'HRA-ADM-ORD-MUN-01','HRA-ADM-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(43,'HRA-COM-STEN-MUN-01','HRA-ADM-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(44,'HRA-COM-TYP-MUN-01','HRA-ADM-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(45,'HRA-COM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(46,'HRA-COM-SNR-MUN-01','HRA-COM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(47,'HRA-COM-CLK-MUN-01','HRA-COM-SNR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(48,'HRA-COM-AST-MUN-01','HRA-COM-CLK-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(49,'HRA-HRM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(50,'HRA-HRM-SNR-MUN-01','HRA-HRM-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(51,'HRA-HRM-OFF-MUN-01','HRA-HRM-SNR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:03');
INSERT INTO hra_supervision VALUES(52,'HRA-SEC-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(53,'HRA-SEC-SNR-MUN-01','HRA-SEC-CHIEF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(54,'HRA-SEC-OFF-MUN-01','HRA-SEC-SNR-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(55,'HRA-SEC-INSP-MUN-01','HRA-SEC-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(56,'HRA-SEC-SUB-MUN-01','HRA-SEC-INSP-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(57,'HRA-SEC-SGT-MUN-01','HRA-SEC-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(58,'HRA-SEC-PC-MUN-01','HRA-SEC-SUB-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(59,'HRA-SEC-WATCH-MUN-01','HRA-SEC-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:47:05');
INSERT INTO hra_supervision VALUES(60,'HRA-ADM-SUP-MUN-01','HRA-ADM-OFF-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:49:01');
INSERT INTO hra_supervision VALUES(61,'HRA-ADM-REG-MUN-01','HRA-ADM-SUP-MUN-01','HRA-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'HRA',1,'2026-03-01 20:49:08');
INSERT INTO hra_supervision VALUES(62,'HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(63,'HRA-LEAD-ADIR-ADM-CIT-01','HRA-LEAD-DIR-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(64,'HRA-LEAD-ADIR-HRM-CIT-01','HRA-LEAD-DIR-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(65,'HRA-ADM-CHIEF-CIT-01','HRA-LEAD-ADIR-ADM-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(66,'HRA-COM-CHIEF-CIT-01','HRA-LEAD-ADIR-ADM-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(67,'HRA-SEC-CHIEF-CIT-01','HRA-LEAD-ADIR-ADM-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(68,'HRA-HRM-CHIEF-CIT-01','HRA-LEAD-ADIR-HRM-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(69,'HRA-ADM-SNR-CIT-01','HRA-ADM-CHIEF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(70,'HRA-COM-SNR-CIT-01','HRA-COM-CHIEF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(71,'HRA-SEC-SNR-CIT-01','HRA-SEC-CHIEF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:57');
INSERT INTO hra_supervision VALUES(72,'HRA-HRM-SNR-CIT-01','HRA-HRM-CHIEF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(73,'HRA-ADM-SNRPRINT-CIT-01','HRA-ADM-CHIEF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(74,'HRA-ADM-OFF-CIT-01','HRA-ADM-SNR-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(75,'HRA-COM-CLK-CIT-01','HRA-COM-SNR-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(76,'HRA-SEC-OFF-CIT-01','HRA-SEC-SNR-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(77,'HRA-HRM-OFF-CIT-01','HRA-HRM-SNR-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(78,'HRA-ADM-PRINT-CIT-01','HRA-ADM-SNRPRINT-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(79,'HRA-ADM-SEC-CIT-01','HRA-ADM-CHIEF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(80,'HRA-ADM-SUP-CIT-01','HRA-ADM-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(81,'HRA-ADM-REG-CIT-01','HRA-ADM-SUP-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(82,'HRA-ADM-STEN-CIT-01','HRA-ADM-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(83,'HRA-ADM-TYP-CIT-01','HRA-ADM-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(84,'HRA-COM-AST-CIT-01','HRA-COM-CLK-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(85,'HRA-ADM-HDDRV-CIT-01','HRA-ADM-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(86,'HRA-ADM-DRV-CIT-01','HRA-ADM-HDDRV-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(87,'HRA-ADM-ORD-CIT-01','HRA-ADM-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(88,'HRA-ADM-GEN-CIT-01','HRA-ADM-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(89,'HRA-SEC-INSP-CIT-01','HRA-SEC-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(90,'HRA-SEC-SUB-CIT-01','HRA-SEC-INSP-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(91,'HRA-SEC-SGT-CIT-01','HRA-SEC-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(92,'HRA-SEC-PC-CIT-01','HRA-SEC-SUB-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:58');
INSERT INTO hra_supervision VALUES(93,'HRA-SEC-WATCH-CIT-01','HRA-SEC-OFF-CIT-01','HRA-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'HRA',1,'2026-03-01 21:24:59');
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
INSERT INTO legal_supervision VALUES(11,'LEG-LIT-OFF-PROSE-MUN-01','LEG-LEAD-ADV-LIT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(12,'LEG-ESTCON-LIC-MUN-01','LEG-LEAD-ADV-ESTCON-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(13,'LEG-ESTCON-SRASST-CONT-MUN-01','LEG-ESTCON-OFF-CONT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(14,'LEG-ESTCON-SRASST-EST-MUN-01','LEG-ESTCON-OFF-EST-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(15,'LEG-ESTCON-SRASST-LIC-MUN-01','LEG-ESTCON-OFF-LIC-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(16,'LEG-LIT-SRASST-LIT-MUN-01','LEG-LIT-OFF-LIT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(17,'LEG-LIT-SRASST-PROSE-MUN-01','LEG-LIT-OFF-PROSE-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(18,'LEG-ESTCON-AST-CONT-MUN-01','LEG-ESTCON-SRASST-CONT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(19,'LEG-ESTCON-AST-EST-MUN-01','LEG-ESTCON-SRASST-EST-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(20,'LEG-ESTCON-AST-LIC-MUN-01','LEG-ESTCON-SRASST-LIC-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(21,'LEG-LIT-AST-PROSE-MUN-01','LEG-LIT-SRASST-PROSE-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:54');
INSERT INTO legal_supervision VALUES(22,'LEG-ESTCON-REG-CONT-MUN-01','LEG-ESTCON-SRASST-CONT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:55');
INSERT INTO legal_supervision VALUES(23,'LEG-ESTCON-REG-EST-MUN-01','LEG-ESTCON-SRASST-EST-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:55');
INSERT INTO legal_supervision VALUES(24,'LEG-ESTCON-REG-LIC-MUN-01','LEG-ESTCON-SRASST-LIC-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:55');
INSERT INTO legal_supervision VALUES(25,'LEG-LIT-REG-DEEDS-MUN-01','LEG-LIT-SRASST-LIT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:55');
INSERT INTO legal_supervision VALUES(26,'LEG-LIT-REG-LIT-MUN-01','LEG-LIT-SRASST-LIT-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:55');
INSERT INTO legal_supervision VALUES(27,'LEG-LIT-REG-PROSE-MUN-01','LEG-LIT-SRASST-PROSE-MUN-01','LEG-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'LEG',1,'2026-03-01 22:08:55');
INSERT INTO legal_supervision VALUES(28,'LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:03');
INSERT INTO legal_supervision VALUES(29,'LEG-LIT-ADV-CIT-01','LEG-LEAD-DIR-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:03');
INSERT INTO legal_supervision VALUES(30,'LEG-ESTCON-ADV-CIT-01','LEG-LEAD-DIR-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:03');
INSERT INTO legal_supervision VALUES(31,'LEG-LIT-OFF-LIT-CIT-01','LEG-LIT-ADV-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:03');
INSERT INTO legal_supervision VALUES(32,'LEG-LIT-OFF-DEEDS-CIT-01','LEG-LIT-ADV-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:03');
INSERT INTO legal_supervision VALUES(33,'LEG-ESTCON-OFF-EST-CIT-01','LEG-ESTCON-ADV-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:03');
INSERT INTO legal_supervision VALUES(34,'LEG-ESTCON-OFF-CONT-CIT-01','LEG-ESTCON-ADV-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:03');
INSERT INTO legal_supervision VALUES(35,'LEG-LIT-SRASST-LIT-CIT-01','LEG-LIT-OFF-LIT-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:04');
INSERT INTO legal_supervision VALUES(36,'LEG-LIT-SRASST-DEEDS-CIT-01','LEG-LIT-OFF-DEEDS-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:04');
INSERT INTO legal_supervision VALUES(37,'LEG-ESTCON-SRASST-EST-CIT-01','LEG-ESTCON-OFF-EST-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:04');
INSERT INTO legal_supervision VALUES(38,'LEG-ESTCON-SRASST-CONT-CIT-01','LEG-ESTCON-OFF-CONT-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:04');
INSERT INTO legal_supervision VALUES(39,'LEG-ESTCON-LIC-CIT-01','LEG-ESTCON-OFF-CONT-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:04');
INSERT INTO legal_supervision VALUES(40,'LEG-LIT-AST-LIT-CIT-01','LEG-LIT-SRASST-LIT-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:04');
INSERT INTO legal_supervision VALUES(41,'LEG-LIT-AST-DEEDS-CIT-01','LEG-LIT-SRASST-DEEDS-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:04');
INSERT INTO legal_supervision VALUES(42,'LEG-ESTCON-AST-EST-CIT-01','LEG-ESTCON-SRASST-EST-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:05');
INSERT INTO legal_supervision VALUES(43,'LEG-ESTCON-AST-CONT-CIT-01','LEG-ESTCON-SRASST-CONT-CIT-01','LEG-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'LEG',1,'2026-03-01 22:35:05');
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
INSERT INTO health_supervision VALUES(11,'HLT-FUN-SUP-TOW-01','HLT-LEAD-ADIR-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:47');
INSERT INTO health_supervision VALUES(12,'HLT-FUN-ASST-TOW-01','HLT-FUN-SUP-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:47');
INSERT INTO health_supervision VALUES(13,'HLT-FUN-SAN-TOW-01','HLT-FUN-SUP-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:47');
INSERT INTO health_supervision VALUES(14,'HLT-FUN-GRAVE-TOW-01','HLT-FUN-SUP-TOW-01','HLT-LEAD-ADIR-TOW-01','EXEC-SEC-TOW-01',1,'HLT',1,'2026-03-01 23:01:48');
INSERT INTO health_supervision VALUES(15,'HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:57');
INSERT INTO health_supervision VALUES(16,'HLT-HIN-CHIEF-MUN-01','HLT-LEAD-ADIR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:57');
INSERT INTO health_supervision VALUES(17,'HLT-HPR-SNR-MUN-01','HLT-LEAD-ADIR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:57');
INSERT INTO health_supervision VALUES(18,'HLT-CLE-MGR-MUN-01','HLT-LEAD-ADIR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:57');
INSERT INTO health_supervision VALUES(19,'HLT-FUN-SUP-MUN-01','HLT-LEAD-ADIR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:57');
INSERT INTO health_supervision VALUES(20,'HLT-HIS-OFF-MUN-01','HLT-LEAD-ADIR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:57');
INSERT INTO health_supervision VALUES(21,'HLT-HIN-SNR-MUN-01','HLT-HIN-CHIEF-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(22,'HLT-HIN-INSP-MUN-01','HLT-HIN-CHIEF-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(23,'HLT-HIN-DRV-MUN-01','HLT-HIN-CHIEF-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(24,'HLT-HPR-OFF-MUN-01','HLT-HPR-SNR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(25,'HLT-HPR-ASTOFF-MUN-01','HLT-HPR-SNR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(26,'HLT-HPR-AST-MUN-01','HLT-HPR-SNR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(27,'HLT-CLE-SUP-MUN-01','HLT-CLE-MGR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(28,'HLT-CLE-PEST-MUN-01','HLT-CLE-MGR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(29,'HLT-CLE-ASTSUP-MUN-01','HLT-CLE-MGR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(30,'HLT-CLE-ASTPEST-MUN-01','HLT-CLE-MGR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(31,'HLT-CLE-FORE-MUN-01','HLT-CLE-MGR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(32,'HLT-CLE-DRV-MUN-01','HLT-CLE-MGR-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(33,'HLT-FUN-AST-MUN-01','HLT-FUN-SUP-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(34,'HLT-FUN-SAN-MUN-01','HLT-FUN-SUP-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(35,'HLT-FUN-GRAVE-MUN-01','HLT-FUN-SUP-MUN-01','HLT-LEAD-ADIR-MUN-01','EXEC-CLK-MUN-01',2,'HLT',1,'2026-03-01 23:40:58');
INSERT INTO health_supervision VALUES(36,'HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(37,'HLT-ENV-SNR-CIT-01','HLT-LEAD-ADIR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(38,'HLT-HIN-CHIEF-CIT-01','HLT-LEAD-ADIR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(39,'HLT-HPR-SNR-CIT-01','HLT-LEAD-ADIR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(40,'HLT-CLE-MGR-CIT-01','HLT-LEAD-ADIR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(41,'HLT-FUN-SUP-CIT-01','HLT-LEAD-ADIR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(42,'HLT-HIS-OFF-CIT-01','HLT-LEAD-ADIR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(43,'HLT-ENV-SR-TECH-CIT-01','HLT-ENV-SNR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(44,'HLT-ENV-TECH-CIT-01','HLT-ENV-SNR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(45,'HLT-HIN-SNR-CIT-01','HLT-HIN-CHIEF-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(46,'HLT-HIN-INSP-CIT-01','HLT-HIN-CHIEF-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(47,'HLT-HIN-DRV-CIT-01','HLT-HIN-CHIEF-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(48,'HLT-HPR-OFF-CIT-01','HLT-HPR-SNR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(49,'HLT-HPR-AST-CIT-01','HLT-HPR-SNR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(50,'HLT-CLE-SUP-CIT-01','HLT-CLE-MGR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(51,'HLT-CLE-PEST-CIT-01','HLT-CLE-MGR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(52,'HLT-CLE-ASTSUP-CIT-01','HLT-CLE-MGR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(53,'HLT-CLE-ASTPEST-CIT-01','HLT-CLE-MGR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(54,'HLT-CLE-DRV-CIT-01','HLT-CLE-MGR-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:06');
INSERT INTO health_supervision VALUES(55,'HLT-FUN-SAN-CIT-01','HLT-FUN-SUP-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:07');
INSERT INTO health_supervision VALUES(56,'HLT-FUN-GRAVE-CIT-01','HLT-FUN-SUP-CIT-01','HLT-LEAD-ADIR-CIT-01','EXEC-CLK-CIT-01',3,'HLT',1,'2026-03-01 23:51:07');
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
INSERT INTO community_positions VALUES(NULL,'Conservator','LGSS/10',1,'COM-LIB-OFF-TOW-01',2,1,1,NULL,0,0,'COM-LIB-CON-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Library Officer','LGSS/10',1,'COM-LIB-OFF-TOW-01',2,1,1,NULL,0,0,'COM-LIB-AST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Housing Officer','LGSS/08',1,'COM-BSM-ADIR-TOW-01',3,2,1,NULL,0,1,'COM-HOUS-OFF-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Housing Officer','LGSS/14',2,'COM-HOUS-OFF-TOW-01',3,2,1,NULL,0,0,'COM-HOUS-AST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Bus Stations Manager','LGSS/07',1,'COM-BSM-ADIR-TOW-01',4,2,1,NULL,0,1,'COM-BUS-MGR-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Bus Stations Manager','LGSS/08',1,'COM-BUS-MGR-TOW-01',4,2,1,NULL,0,0,'COM-BUS-AST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Bus Station Master','LGSS/16',2,'COM-BUS-MGR-TOW-01',4,2,1,NULL,0,0,'COM-BUS-MST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Markets Manager','LGSS/07',1,'COM-BSM-ADIR-TOW-01',5,2,1,NULL,0,1,'COM-MKT-MGR-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Markets Manager','LGSS/08',1,'COM-MKT-MGR-TOW-01',5,2,1,NULL,0,0,'COM-MKT-AST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Markets Master','LGSS/16',2,'COM-MKT-MGR-TOW-01',5,2,1,NULL,0,0,'COM-MKT-MST-TOW-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Director - Community Services','LGSS/04',1,NULL,NULL,NULL,2,NULL,1,0,'COM-LEAD-DIR-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Director - Social Services','LGSS/05',1,NULL,NULL,3,2,NULL,1,0,'COM-SOC-ADIR-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Director - Bus Stations, Markets & Housing','LGSS/05',1,NULL,NULL,4,2,NULL,1,0,'COM-BSM-ADIR-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Chief Community Development Officer','LGSS/06',1,NULL,6,3,2,NULL,0,1,'COM-DEV-CHIEF-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Community Development Officer','LGSS/07',2,NULL,6,3,2,NULL,0,0,'COM-DEV-SNR-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Community Development Officer','LGSS/08',6,NULL,6,3,2,NULL,0,0,'COM-DEV-OFF-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Assistant Development Officer','LGSS/11',4,NULL,6,3,2,NULL,0,0,'COM-DEV-SRASST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Community Development Officer','LGSS/14',4,NULL,6,3,2,NULL,0,0,'COM-DEV-AST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Community Development Assistant','LGSS/17',10,NULL,6,3,2,NULL,0,0,'COM-DEV-ASST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Librarian','LGSS/07',1,NULL,7,3,2,NULL,0,1,'COM-LIB-LIB-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Assistant Librarian','LGSS/10',2,NULL,7,3,2,NULL,0,0,'COM-LIB-SRASST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Librarian','LGSS/12',8,NULL,7,3,2,NULL,0,0,'COM-LIB-AST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Library Assistant','LGSS/14',1,NULL,7,3,2,NULL,0,0,'COM-LIB-SRASST2-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Library Assistant','LGSS/17',2,NULL,7,3,2,NULL,0,0,'COM-LIB-ASST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Chief Housing Officer','LGSS/06',1,NULL,8,4,2,NULL,0,1,'COM-HOUS-CHIEF-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Chief Settlements Officer','LGSS/07',1,NULL,8,4,2,NULL,0,0,'COM-HOUS-SETTLE-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Settlements Officer','LGSS/08',3,NULL,8,4,2,NULL,0,0,'COM-HOUS-SNR-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Housing Officer','LGSS/10',5,NULL,8,4,2,NULL,0,0,'COM-HOUS-OFF-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Housing Officer','LGSS/14',3,NULL,8,4,2,NULL,0,0,'COM-HOUS-AST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Bus Stations Manager','LGSS/06',1,NULL,9,4,2,NULL,0,1,'COM-BUS-MGR-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Bus Stations Manager','LGSS/08',1,NULL,9,4,2,NULL,0,0,'COM-BUS-AST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Station Master','LGSS/16',2,NULL,9,4,2,NULL,0,0,'COM-BUS-MST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Markets Manager','LGSS/06',1,NULL,10,4,2,NULL,0,1,'COM-MKT-MGR-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Markets Manager','LGSS/08',1,NULL,10,4,2,NULL,0,0,'COM-MKT-AST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Markets Master','LGSS/16',11,NULL,10,4,2,NULL,0,0,'COM-MKT-MST-MUN-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Director - Community Services','LGSS/03',1,NULL,NULL,NULL,3,NULL,1,0,'COM-LEAD-DIR-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Director - Social Services','LGSS/05',1,NULL,NULL,5,3,NULL,1,0,'COM-SOC-ADIR-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Director - Bus Stations, Markets & Housing','LGSS/05',1,NULL,NULL,6,3,NULL,1,0,'COM-BSM-ADIR-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Chief Officer - Community Development','LGSS/06',1,NULL,11,5,3,NULL,0,1,'COM-DEV-CHIEF-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Community Development Officer','LGSS/07',5,NULL,11,5,3,NULL,0,0,'COM-DEV-SNR-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Community Development Officer','LGSS/08',14,NULL,11,5,3,NULL,0,0,'COM-DEV-OFF-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Assistant Development Officer','LGSS/11',8,NULL,11,5,3,NULL,0,0,'COM-DEV-SRASST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Community Development Officer','LGSS/14',25,NULL,11,5,3,NULL,0,0,'COM-DEV-AST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Community Development Assistant','LGSS/17',10,NULL,11,5,3,NULL,0,0,'COM-DEV-ASST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Chief Library and Archives Officer','LGSS/06',1,NULL,12,5,3,NULL,0,1,'COM-LIB-CHIEF-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Librarian','LGSS/07',4,NULL,12,5,3,NULL,0,0,'COM-LIB-LIB-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Assistant Librarian','LGSS/10',4,NULL,12,5,3,NULL,0,0,'COM-LIB-SRASST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Librarian','LGSS/12',4,NULL,12,5,3,NULL,0,0,'COM-LIB-AST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Library Assistant','LGSS/14',8,NULL,12,5,3,NULL,0,0,'COM-LIB-SRASST2-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Library Assistant','LGSS/17',7,NULL,12,5,3,NULL,0,0,'COM-LIB-ASST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Chief Housing Officer','LGSS/06',1,NULL,13,6,3,NULL,0,1,'COM-HOUS-CHIEF-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Chief Settlements Officer','LGSS/07',1,NULL,13,6,3,NULL,0,0,'COM-HOUS-SETTLE-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Settlements Officer','LGSS/08',3,NULL,13,6,3,NULL,0,0,'COM-HOUS-SNR-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Settlement Officer','LGSS/10',7,NULL,13,6,3,NULL,0,0,'COM-HOUS-SETTLEOFF-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Housing Officer','LGSS/08',5,NULL,13,6,3,NULL,0,0,'COM-HOUS-SNRHO-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Housing Officer','LGSS/10',8,NULL,13,6,3,NULL,0,0,'COM-HOUS-OFF-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Bus Station Manager','LGSS/06',1,NULL,14,6,3,NULL,0,1,'COM-BUS-MGR-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Bus Station Manager','LGSS/08',1,NULL,14,6,3,NULL,0,0,'COM-BUS-AST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Bus Station Master','LGSS/16',5,NULL,14,6,3,NULL,0,0,'COM-BUS-MST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Markets Manager','LGSS/06',1,NULL,15,6,3,NULL,0,1,'COM-MKT-MGR-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Assistant Markets Manager','LGSS/08',4,NULL,15,6,3,NULL,0,0,'COM-MKT-AST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Market Master','LGSS/16',25,NULL,15,6,3,NULL,0,0,'COM-MKT-MST-CIT-01',0,NULL,NULL);
INSERT INTO community_positions VALUES(NULL,'Senior Skills Training Officer','LGSS/07',1,NULL,16,7,3,NULL,0,1,'COM-VOC-SNR-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'Skills Training Officer','LGSS/08',1,NULL,16,7,3,NULL,0,0,'COM-VOC-OFF-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'Automotive Engineering Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-AUTO-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'Carpentry & Joinery Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-CARP-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'Fashion Design & Textile Technology Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-FASH-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'General Agriculture Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-AGRI-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'Electrical Technology Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-ELEC-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'General Hospitality Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-HOSP-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'Auto body repair, panel beating & spray painting Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-AUTOBDY-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
INSERT INTO community_positions VALUES(NULL,'Metal Fabrication & Welding Instructor','LGSS/14',2,NULL,16,7,3,NULL,0,0,'COM-VOC-METAL-CIT-01',1,5,'Buchi Youth Vocational Training Centre');
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
INSERT INTO community_units VALUES(12,'Library and Archiving Services Unit','LIB-ARC-CIT',5,3,NULL,0,NULL);
INSERT INTO community_units VALUES(13,'Housing Unit','HOUS-CIT',6,3,NULL,0,NULL);
INSERT INTO community_units VALUES(14,'Bus Stations Unit','BUS-CIT',6,3,NULL,0,NULL);
INSERT INTO community_units VALUES(15,'Markets Unit','MKT-CIT',6,3,NULL,0,NULL);
INSERT INTO community_units VALUES(16,'Vocational Training Unit','VOC-CIT',7,3,NULL,1,5);
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
INSERT INTO community_supervision VALUES(10,'COM-DEV-ASST-TOW-01','COM-DEV-OFF-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(11,'COM-LIB-CON-TOW-01','COM-LIB-OFF-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(12,'COM-LIB-AST-TOW-01','COM-LIB-OFF-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(13,'COM-HOUS-AST-TOW-01','COM-HOUS-OFF-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(14,'COM-BUS-AST-TOW-01','COM-BUS-MGR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(15,'COM-BUS-MST-TOW-01','COM-BUS-MGR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(16,'COM-MKT-AST-TOW-01','COM-MKT-MGR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(17,'COM-MKT-MST-TOW-01','COM-MKT-MGR-TOW-01','COM-LEAD-DIR-TOW-01','EXEC-SEC-TOW-01',1,'COM',1,'2026-03-02 20:36:52');
INSERT INTO community_supervision VALUES(18,'COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(19,'COM-SOC-ADIR-MUN-01','COM-LEAD-DIR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(20,'COM-BSM-ADIR-MUN-01','COM-LEAD-DIR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(21,'COM-DEV-CHIEF-MUN-01','COM-SOC-ADIR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(22,'COM-LIB-LIB-MUN-01','COM-SOC-ADIR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(23,'COM-HOUS-CHIEF-MUN-01','COM-BSM-ADIR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(24,'COM-BUS-MGR-MUN-01','COM-BSM-ADIR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(25,'COM-MKT-MGR-MUN-01','COM-BSM-ADIR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:50');
INSERT INTO community_supervision VALUES(26,'COM-DEV-SNR-MUN-01','COM-DEV-CHIEF-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(27,'COM-DEV-OFF-MUN-01','COM-DEV-SNR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(28,'COM-LIB-SRASST-MUN-01','COM-LIB-LIB-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(29,'COM-LIB-AST-MUN-01','COM-LIB-SRASST-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(30,'COM-HOUS-SETTLE-MUN-01','COM-HOUS-CHIEF-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(31,'COM-HOUS-SNR-MUN-01','COM-HOUS-CHIEF-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(32,'COM-BUS-AST-MUN-01','COM-BUS-MGR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(33,'COM-MKT-AST-MUN-01','COM-MKT-MGR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:51');
INSERT INTO community_supervision VALUES(34,'COM-DEV-SRASST-MUN-01','COM-DEV-OFF-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(35,'COM-DEV-AST-MUN-01','COM-DEV-SRASST-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(36,'COM-DEV-ASST-MUN-01','COM-DEV-AST-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(37,'COM-LIB-SRASST2-MUN-01','COM-LIB-AST-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(38,'COM-LIB-ASST-MUN-01','COM-LIB-SRASST2-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(39,'COM-HOUS-OFF-MUN-01','COM-HOUS-SNR-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(40,'COM-HOUS-AST-MUN-01','COM-HOUS-OFF-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(41,'COM-BUS-MST-MUN-01','COM-BUS-AST-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(42,'COM-MKT-MST-MUN-01','COM-MKT-AST-MUN-01','COM-LEAD-DIR-MUN-01','EXEC-CLK-MUN-01',2,'COM',1,'2026-03-02 20:43:52');
INSERT INTO community_supervision VALUES(43,'COM-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01','COM-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 20:48:35');
INSERT INTO community_supervision VALUES(44,'COM-SOC-ADIR-CIT-01','COM-LEAD-DIR-CIT-01','COM-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 20:48:36');
INSERT INTO community_supervision VALUES(45,'COM-BSM-ADIR-CIT-01','COM-LEAD-DIR-CIT-01','COM-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 20:48:36');
INSERT INTO community_supervision VALUES(46,'COM-MKT-AST-CIT-01','COM-MKT-MGR-CIT-01','COM-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 21:14:37');
INSERT INTO community_supervision VALUES(47,'COM-MKT-MST-CIT-01','COM-MKT-AST-CIT-01','COM-LEAD-DIR-CIT-01','EXEC-CLK-CIT-01',3,'COM',1,'2026-03-02 21:14:38');
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
INSERT INTO procurement_positions VALUES(5,'Procurement & Supplies Officer - Health Services','LGSS/08',1,'PRO-CHIEF-TOW-01',1,NULL,1,0,0,1,'PRO-HLTH-TOW-01');
INSERT INTO procurement_positions VALUES(6,'Head - Procurement','LGSS/06',1,'EXEC-CLK-MUN-01',NULL,NULL,2,1,0,0,'PRO-HEAD-MUN-01');
INSERT INTO procurement_positions VALUES(7,'Senior Procurement Officer','LGSS/07',2,'PRO-HEAD-MUN-01',NULL,NULL,2,0,0,0,'PRO-SNR-MUN-01');
INSERT INTO procurement_positions VALUES(8,'Procurement Officer','LGSS/08',2,'PRO-SNR-MUN-01',NULL,NULL,2,0,0,0,'PRO-OFF-MUN-01');
INSERT INTO procurement_positions VALUES(9,'Procurement Assistant','LGSS/10',4,'PRO-OFF-MUN-01',NULL,NULL,2,0,0,0,'PRO-AST-MUN-01');
INSERT INTO procurement_positions VALUES(10,'Procurement Officer - Health Services','LGSS/08',1,'PRO-HEAD-MUN-01',NULL,NULL,2,0,0,1,'PRO-HLTH-MUN-01');
INSERT INTO procurement_positions VALUES(11,'Head - Procurement','LGSS/05',1,'EXEC-CLK-CIT-01',3,NULL,3,1,0,0,'PRO-HEAD-CIT-01');
INSERT INTO procurement_positions VALUES(12,'Chief Procurement Officer','LGSS/06',1,'PRO-HEAD-CIT-01',3,NULL,3,0,0,0,'PRO-CHIEF-CIT-01');
INSERT INTO procurement_positions VALUES(13,'Senior Procurement Officer','LGSS/07',3,'PRO-CHIEF-CIT-01',3,NULL,3,0,0,0,'PRO-SNR-CIT-01');
INSERT INTO procurement_positions VALUES(14,'Procurement Assistant','LGSS/10',6,'PRO-SNR-CIT-01',3,NULL,3,0,0,0,'PRO-AST-CIT-01');
INSERT INTO procurement_positions VALUES(15,'Procurement Officer - Health Services','LGSS/08',1,'PRO-HEAD-CIT-01',3,NULL,3,0,0,1,'PRO-HLTH-CIT-01');
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
INSERT INTO procurement_supervision VALUES(10,'PRO-HLTH-CIT-01','PRO-HEAD-CIT-01','PRO-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'PRO',1,'2026-03-02 22:10:13');
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
INSERT INTO audit_positions VALUES(10,'Head - Internal Audit','LGSS/05',1,'EXEC-CLK-CIT-01',3,3,1,0,'AUD-HEAD-CIT-01');
INSERT INTO audit_positions VALUES(11,'Principal Internal Auditor','LGSS/06',1,'AUD-HEAD-CIT-01',3,3,0,0,'AUD-PRIN-CIT-01');
INSERT INTO audit_positions VALUES(12,'Senior Internal Auditor','LGSS/07',2,'AUD-PRIN-CIT-01',3,3,0,0,'AUD-SNR-CIT-01');
INSERT INTO audit_positions VALUES(13,'Internal Auditor','LGSS/08',4,'AUD-SNR-CIT-01',3,3,0,0,'AUD-OFF-CIT-01');
INSERT INTO audit_positions VALUES(14,'Assistant Internal Auditor','LGSS/10',8,'AUD-OFF-CIT-01',3,3,0,0,'AUD-AST-CIT-01');
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
INSERT INTO audit_supervision VALUES(11,'AUD-PRIN-CIT-01','AUD-HEAD-CIT-01','AUD-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'AUD',1,'2026-03-02 22:32:11');
INSERT INTO audit_supervision VALUES(12,'AUD-SNR-CIT-01','AUD-PRIN-CIT-01','AUD-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'AUD',1,'2026-03-02 22:32:11');
INSERT INTO audit_supervision VALUES(13,'AUD-OFF-CIT-01','AUD-SNR-CIT-01','AUD-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'AUD',1,'2026-03-02 22:32:11');
INSERT INTO audit_supervision VALUES(14,'AUD-AST-CIT-01','AUD-OFF-CIT-01','AUD-HEAD-CIT-01','EXEC-CLK-CIT-01',3,'AUD',1,'2026-03-02 22:32:11');
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
INSERT INTO valuation_city_positions VALUES(11,'Data Entry Clerk','LGSS/13',2,'VAL-VOTR-CIT-01','Taxation & Rating',3,0,'VAL-DEC-CIT-01');
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
INSERT INTO valuation_city_supervision VALUES(11,'VAL-DEC-CIT-01','VAL-VOTR-CIT-01','VAL-DIR-CIT-01','EXEC-CLK-CIT-01',3,'VAL',1,'2026-03-02 23:39:33');
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
;
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
END
;
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
END
;
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
END
;
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
SELECT * FROM org_tree ORDER BY level, title;
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
ORDER BY s.section_name, p.level;
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
ORDER BY p.title, lac.step_number;
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
SELECT * FROM org_tree ORDER BY level, title;
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
ORDER BY s.section_name, p.level;
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
ORDER BY p.title, lac.step_number;
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
ORDER BY ct.council_type_name, ot.level, ot.title;
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
ORDER BY ct.council_type_name, eu.unit_name, ss.level;
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
ORDER BY ct.council_type_name, total_staff DESC;
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
ORDER BY ct.council_type_name, ss.level;
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
GROUP BY ct.council_type_name;
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
ORDER BY ct.council_type_name, ot.level, ot.title;
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
ORDER BY ct.council_type_name, ps.section_name, pu.unit_name, ss.level;
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
ORDER BY ct.council_type_name, total_staff DESC;
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
ORDER BY ct.council_type_name, ss.level;
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
ORDER BY ct.council_type_name, pp.level;
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
ORDER BY ct.council_type_name, p.title, lac.step_number;
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
ORDER BY ct.council_type_name, p.title, lac.step_number;
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
GROUP BY ct.council_type_name;
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
ORDER BY ct.council_type_name, ot.level, ot.title;
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
ORDER BY ct.council_type_name, fs.section_name, fu.unit_name, ss.level;
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
ORDER BY ct.council_type_name, total_staff DESC;
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
ORDER BY ct.council_type_name, p.title, lac.step_number;
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
ORDER BY ct.council_type_name, ss.level;
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
GROUP BY ct.council_type_name;
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
ORDER BY ct.council_type_name, ot.level, ot.title;
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
ORDER BY ct.council_type_name, ls.section_name, lu.unit_name, ss.level;
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
ORDER BY ct.council_type_name, total_staff DESC;
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
ORDER BY ct.council_type_name, p.title, lac.step_number;
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
ORDER BY ct.council_type_name, ss.level;
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
GROUP BY ct.council_type_name;
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
ORDER BY ct.council_type_name, ot.level, ot.title;
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
ORDER BY ct.council_type_name, hu.unit_name, ss.level;
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
ORDER BY ct.council_type_name, total_staff DESC;
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
ORDER BY ct.council_type_name, p.title, lac.step_number;
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
ORDER BY ct.council_type_name, ss.level;
CREATE INDEX idx_notification_tracking ON mothers_day_notification_log(tracking_id);
CREATE INDEX idx_notification_recipient ON mothers_day_notification_log(recipient_id);
CREATE INDEX idx_notification_status ON mothers_day_notification_log(status);
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
ORDER BY month DESC;
CREATE INDEX idx_notification_history_tracking ON notification_history(tracking_id);
CREATE INDEX idx_notification_history_recipient ON notification_history(recipient_id);
CREATE INDEX idx_sms_delivery_status ON sms_delivery_log(status);
CREATE INDEX idx_sms_delivery_phone ON sms_delivery_log(phone_number);
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
AND scg.is_active = 1
;
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
;
CREATE VIEW vw_monthly_leave_taken AS
SELECT 
    employee_id,
    month_year,
    COUNT(*) AS days_taken
FROM mothers_day_leave_tracking
GROUP BY employee_id, month_year;
CREATE VIEW vw_eligibility_with_status AS
SELECT 
    e.*,
    COALESCE(mlt.days_taken, 0) AS days_taken_this_month,
    CASE 
        WHEN e.is_eligible = 1 AND COALESCE(mlt.days_taken, 0) = 0 THEN 1
        ELSE 0
    END AS can_take_leave
FROM vw_employee_eligibility e
LEFT JOIN vw_monthly_leave_taken mlt ON e.employee_id = mlt.employee_id AND mlt.month_year = e.current_month;
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
ORDER BY total_days_taken DESC;
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
CREATE INDEX idx_mothers_day_employee ON mothers_day_leave_tracking(employee_id);
CREATE INDEX idx_mothers_day_month ON mothers_day_leave_tracking(month_year);
CREATE INDEX idx_mothers_day_status ON mothers_day_leave_tracking(status);
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
ORDER BY mdt.created_at;
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
;
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
GROUP BY e.employee_id;
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
WHERE sex = 'F' AND is_active = 1;
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
ORDER BY e.department, e.name;
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
WHERE hr.is_active = 1;
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
ORDER BY direct_reports DESC;
CREATE VIEW vw_notification_preferences AS
SELECT 
    notification_preference,
    COUNT(*) as employee_count,
    GROUP_CONCAT(name) as employees
FROM employees
WHERE sex = 'F' AND is_active = 1
GROUP BY notification_preference;
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
ORDER BY ph.council_type, ph.level, ph.unit;
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
ORDER BY council_type, level, position_title;
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
ORDER BY ph.council_type, ph.unit, ph.level;
CREATE VIEW vw_eng_summary_by_council AS
SELECT 
    council_type,
    COUNT(*) as total_positions,
    COUNT(DISTINCT unit) as total_units,
    MAX(level) as max_depth,
    SUM(establishment_count) as total_establishment
FROM eng_position_hierarchy
GROUP BY council_type
ORDER BY council_type;
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
ORDER BY vs.council_type, vs.unit, vs.employee_title
;
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
;
CREATE VIEW vw_mothers_day_hr_summary AS
SELECT 
    council_type,
    immediate_supervisor,
    supervisor_unit,
    COUNT(*) as staff_count,
    GROUP_CONCAT(employee_title, ', ') as staff_list
FROM vw_mothers_day_engineering
GROUP BY council_type, immediate_supervisor
ORDER BY council_type, staff_count DESC;
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
    END;
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
  AND e.is_active = 1;
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
ORDER BY ph.council_type, ph.level, ph.position_title;
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
ORDER BY ph.council_type, ph.position_title;
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
FROM planning_positions;
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
ORDER BY council_type;
CREATE VIEW vw_establishment_by_council AS
SELECT 
    council_type,
    COUNT(DISTINCT position_title) as unique_positions,
    SUM(establishment_count) as total_staff,
    AVG(establishment_count) as avg_per_position
FROM eng_position_hierarchy
GROUP BY council_type
ORDER BY council_type;
CREATE VIEW vw_staff_by_level AS
SELECT 
    council_type,
    level,
    COUNT(DISTINCT position_title) as positions,
    SUM(establishment_count) as staff_count,
    ROUND(SUM(establishment_count) * 100.0 / SUM(SUM(establishment_count)) OVER (PARTITION BY council_type), 1) as percentage
FROM eng_position_hierarchy
GROUP BY council_type, level
ORDER BY council_type, level;
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
FROM vw_staff_by_level;
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
ORDER BY council_type, level;
CREATE VIEW vw_org_dna AS
SELECT 
    council_type,
    ROUND(100.0 * SUM(CASE WHEN level <= 3 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_management,
    ROUND(100.0 * SUM(CASE WHEN level = 4 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_supervisory,
    ROUND(100.0 * SUM(CASE WHEN level = 5 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_technical,
    ROUND(100.0 * SUM(CASE WHEN level = 6 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_skilled,
    ROUND(100.0 * SUM(CASE WHEN level >= 7 THEN staff_count ELSE 0 END) / SUM(staff_count), 1) as pct_entry
FROM vw_org_chart_data
GROUP BY council_type;
CREATE INDEX idx_supervision_position ON position_supervision(position_standard_id);
CREATE INDEX idx_supervision_supervisor ON position_supervision(immediate_supervisor_id);
CREATE INDEX idx_supervision_hod ON position_supervision(hod_id);
CREATE INDEX idx_supervision_council ON position_supervision(council_type_id);
CREATE UNIQUE INDEX idx_unique_current_jd 
ON job_description_documents (position_standard_id) WHERE is_current = 1;
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
    AND (p.is_special_unit = 0 OR p.is_special_unit IS NULL);
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
WHERE p.council_type_id = 3;
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
ORDER BY c.council_name, s.section_name, u.unit_name, p.title;
CREATE INDEX idx_audit_council_period ON immutable_audit_log(council_id, period_date);
CREATE INDEX idx_audit_council_event ON immutable_audit_log(council_id, event_type);
CREATE INDEX idx_audit_council_approver ON immutable_audit_log(council_id, approved_by);
CREATE INDEX idx_audit_period ON immutable_audit_log(period_date);
