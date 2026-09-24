-- =====================================================================
-- V58__seed_chart_of_accounts.sql
-- Seed the Chart of Accounts for a Zambian Local Authority
-- =====================================================================
-- Populates the chart_of_accounts table with the standard account
-- structure for a Local Authority in Zambia.
--
-- Structure:
--   10000–19999  Assets
--   20000–29999  Liabilities
--   30000–39999  Equity
--   40000–49999  Revenue
--   50000–59999  Expenses
--
-- Total: ~105 accounts
-- =====================================================================

-- =====================================================================
-- ASSETS (10000–19999)
-- =====================================================================

-- ---- Cash and Bank (10100–10999) ----
INSERT INTO chart_of_accounts
    (account_code, account_name, account_type, account_class, normal_balance,
     is_postable, is_control_account, control_account_for, is_bank_account,
     effective_from, description)
VALUES
    ('10100', 'Cash on Hand', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Physical cash held in council cash offices.'),

    ('10110', 'Petty Cash', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Small cash float for minor expenses.'),

    ('10200', 'Bank - Main Account', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, TRUE, '2026-01-01',
     'Primary council bank account.'),

    ('10210', 'Bank - Revenue Collection', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, TRUE, '2026-01-01',
     'Bank account for revenue collections.'),

    ('10220', 'Bank - Payroll Account', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, TRUE, '2026-01-01',
     'Bank account for payroll disbursements.'),

    ('10230', 'Bank - CDF Account', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, TRUE, '2026-01-01',
     'Bank account for Constituency Development Fund.'),

    ('10240', 'Bank - LGEF Account', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, TRUE, '2026-01-01',
     'Bank account for Local Government Equalisation Fund.'),

    ('10250', 'Bank - Donor Account', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, TRUE, '2026-01-01',
     'Bank account for donor-funded projects.'),

    ('10290', 'Bank - Other Accounts', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, TRUE, '2026-01-01',
     'Catch-all for other council bank accounts.'),

-- ---- Receivables (11000–11999) ----
    ('11000', 'Accounts Receivable - Property Rates', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'AR', FALSE, '2026-01-01',
     'Control account for property rate debtors.'),

    ('11100', 'Accounts Receivable - Personal Levy', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'AR', FALSE, '2026-01-01',
     'Control account for personal levy debtors.'),

    ('11200', 'Accounts Receivable - Market Fees', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'AR', FALSE, '2026-01-01',
     'Control account for market fee debtors.'),

    ('11300', 'Accounts Receivable - Bus Station Fees', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'AR', FALSE, '2026-01-01',
     'Control account for bus station fee debtors.'),

    ('11400', 'Accounts Receivable - Rent', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'AR', FALSE, '2026-01-01',
     'Control account for rental debtors.'),

    ('11500', 'Accounts Receivable - Licenses', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'AR', FALSE, '2026-01-01',
     'Control account for license fee debtors.'),

    ('11900', 'Accounts Receivable - Other', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'AR', FALSE, '2026-01-01',
     'Control account for other debtors.'),

-- ---- Prepayments and Advances (12000–12999) ----
    ('12000', 'Prepaid Expenses', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Expenses paid in advance (rent, insurance, subscriptions).'),

    ('12100', 'Salary Advance Receivable', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'PAYROLL', FALSE, '2026-01-01',
     'Control account for salary advances to employees.'),

    ('12200', 'Staff Loans Receivable', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Loans extended to staff.'),

    ('12300', 'Other Advances', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Other advances and prepayments.'),

-- ---- Inventory (13000–13999) ----
    ('13000', 'Inventory - Stores', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'INVENTORY', FALSE, '2026-01-01',
     'Control account for general store inventory.'),

    ('13100', 'Inventory - Fuel and Lubricants', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'INVENTORY', FALSE, '2026-01-01',
     'Control account for fuel and lubricant inventory.'),

    ('13200', 'Inventory - Drugs and Medical Supplies', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'INVENTORY', FALSE, '2026-01-01',
     'Control account for health facility drug inventory.'),

    ('13300', 'Inventory - Construction Materials', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'INVENTORY', FALSE, '2026-01-01',
     'Control account for construction material inventory.'),

    ('13900', 'Inventory - Other', 'ASSET', 'CURRENT_ASSET', 'DEBIT',
     FALSE, TRUE, 'INVENTORY', FALSE, '2026-01-01',
     'Other inventory.'),

-- ---- Non-Current Assets (15000–15999) ----
    ('15000', 'Land', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Council-owned land.'),

    ('15100', 'Buildings', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Council-owned buildings at cost.'),

    ('15200', 'Plant and Equipment', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Plant, machinery, and equipment.'),

    ('15300', 'Motor Vehicles', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Council motor vehicles.'),

    ('15400', 'Furniture and Fittings', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Office furniture and fittings.'),

    ('15500', 'IT Equipment', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Computers, servers, network equipment.'),

    ('15600', 'Infrastructure Assets', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Roads, drainages, street lights (non-depreciable).'),

    ('15700', 'Intangible Assets', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Software licenses, patents, trademarks.'),

    ('15800', 'Work in Progress', 'ASSET', 'NON_CURRENT_ASSET', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Capital work not yet completed.'),

    ('15900', 'Accumulated Depreciation', 'ASSET', 'NON_CURRENT_ASSET', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Cumulative depreciation on fixed assets (contra-asset).');

-- =====================================================================
-- LIABILITIES (20000–29999)
-- =====================================================================

-- ---- Payables (20100–20999) ----
INSERT INTO chart_of_accounts
    (account_code, account_name, account_type, account_class, normal_balance,
     is_postable, is_control_account, control_account_for, is_bank_account,
     effective_from, description)
VALUES
    ('20100', 'Accounts Payable - Vendors', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     FALSE, TRUE, 'AP', FALSE, '2026-01-01',
     'Control account for supplier invoices.'),

    ('20200', 'Accounts Payable - Other', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     FALSE, TRUE, 'AP', FALSE, '2026-01-01',
     'Other payables.'),

-- ---- Employee Statutory Payables (21000–21999) ----
    ('21000', 'PAYE Payable', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'PAYE deducted from employees, payable to ZRA.'),

    ('21100', 'NAPSA Payable - Employee', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employee NAPSA contribution payable.'),

    ('21200', 'NAPSA Payable - Employer', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employer NAPSA contribution payable.'),

    ('21300', 'NHIMA Payable - Employee', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employee NHIMA contribution payable.'),

    ('21400', 'NHIMA Payable - Employer', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employer NHIMA contribution payable.'),

    ('21500', 'LASF Payable', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Local Authorities Superannuation Fund payable.'),

    ('21600', 'Funeral Scheme Payable - Employee', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employee contribution to funeral insurance scheme.'),

    ('21700', 'Funeral Scheme Payable - Employer', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employer contribution to funeral insurance scheme.'),

    ('21800', 'Union Dues Payable', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Union dues deducted from employees, payable to unions.'),

    ('21900', 'Other Payroll Deductions Payable', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Other voluntary deductions payable.'),

-- ---- Other Current Liabilities (22000–22999) ----
    ('22000', 'Accrued Expenses', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Expenses incurred but not yet invoiced.'),

    ('22100', 'Deferred Revenue', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Revenue received in advance of service delivery.'),

    ('22200', 'Customer Deposits', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Deposits held on behalf of third parties.'),

    ('22300', 'Withholding Tax Payable', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Withholding tax collected, payable to ZRA.'),

    ('22400', 'VAT Payable', 'LIABILITY', 'CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'VAT collected, payable to ZRA.'),

-- ---- Non-Current Liabilities (25000–25999) ----
    ('25000', 'Long-Term Loans', 'LIABILITY', 'NON_CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Long-term loans from financial institutions.'),

    ('25100', 'Development Loans', 'LIABILITY', 'NON_CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Development loans for capital projects.'),

    ('25200', 'Government Loans', 'LIABILITY', 'NON_CURRENT_LIABILITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Loans from Central Government.');

-- =====================================================================
-- EQUITY / NET ASSETS (30000–39999)
-- =====================================================================
INSERT INTO chart_of_accounts
    (account_code, account_name, account_type, account_class, normal_balance,
     is_postable, is_control_account, control_account_for, is_bank_account,
     effective_from, description)
VALUES
    ('30100', 'Accumulated Surplus / (Deficit)', 'EQUITY', 'EQUITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Accumulated surplus or deficit from operations.'),

    ('30200', 'Capital Reserve', 'EQUITY', 'EQUITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Reserve for capital projects.'),

    ('30300', 'Revaluation Reserve', 'EQUITY', 'EQUITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Reserve from asset revaluations.'),

    ('30400', 'Statutory Reserve', 'EQUITY', 'EQUITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Reserve established by statute or regulation.'),

    ('30500', 'Opening Balance Equity', 'EQUITY', 'EQUITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Opening balance offset for system setup.'),

    ('39900', 'Inter-Fund Clearing', 'EQUITY', 'EQUITY', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Clearing account for inter-fund transfers.');

-- =====================================================================
-- REVENUE (40000–49999)
-- =====================================================================

-- ---- Operating Revenue (40000–44999) ----
INSERT INTO chart_of_accounts
    (account_code, account_name, account_type, account_class, normal_balance,
     is_postable, is_control_account, control_account_for, is_bank_account,
     effective_from, description)
VALUES
    ('40100', 'Property Rates', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Annual property rate revenue.'),

    ('40200', 'Personal Levy', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Personal levy collected from residents.'),

    ('40300', 'Market Fees', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Fees collected from market stalls and vendors.'),

    ('40400', 'Bus Station Fees', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Fees collected from bus station operations.'),

    ('40500', 'Parking Fees', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Parking fees from council-controlled parking.'),

    ('40600', 'Business Licenses', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Business licenses and permits.'),

    ('40700', 'Building Permits', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Building permit fees.'),

    ('40800', 'Rent Income', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Rent from council-owned properties.'),

    ('40900', 'Commercial Venture Income', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Income from commercial ventures (guest houses, transport, abattoirs).'),

    ('41000', 'Sale of Goods', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Revenue from sale of goods.'),

    ('41100', 'Service Charges', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Charges for services rendered.'),

    ('41200', 'Fines and Penalties', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Court fines and penalties.'),

    ('41300', 'Interest Income', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Interest earned on bank balances.'),

    ('41400', 'Other Operating Income', 'REVENUE', 'OPERATING_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Other operating income.'),

-- ---- Capital Revenue (45000–45999) ----
    ('45000', 'LGEF Grant', 'REVENUE', 'CAPITAL_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Local Government Equalisation Fund grant from Central Government.'),

    ('45100', 'CDF Grant', 'REVENUE', 'CAPITAL_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Constituency Development Fund grant.'),

    ('45200', 'Donor Grants', 'REVENUE', 'CAPITAL_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Grants from donor agencies.'),

    ('45300', 'Government Capital Grants', 'REVENUE', 'CAPITAL_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Capital grants from Central Government.'),

    ('45400', 'Other Capital Grants', 'REVENUE', 'CAPITAL_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Other capital grants.'),

-- ---- Other Revenue (49000–49999) ----
    ('49000', 'Gain on Disposal of Assets', 'REVENUE', 'OTHER_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Gain from disposal of fixed assets.'),

    ('49100', 'Revaluation Surplus', 'REVENUE', 'OTHER_REVENUE', 'CREDIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Surplus from asset revaluations.');

-- =====================================================================
-- EXPENSES (50000–59999)
-- =====================================================================

-- ---- Personnel Emoluments (50000–50999) ----
INSERT INTO chart_of_accounts
    (account_code, account_name, account_type, account_class, normal_balance,
     is_postable, is_control_account, control_account_for, is_bank_account,
     effective_from, description)
VALUES
    ('50100', 'Basic Salaries', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Basic salaries for all council employees.'),

    ('50200', 'Housing Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Housing allowance (20% of basic).'),

    ('50300', 'Transport Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Transport allowance (20% of basic).'),

    ('50400', 'Fuel Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Fuel allowance (32% of basic for LGSS 03+).'),

    ('50500', 'Education Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Education allowance (20% of basic).'),

    ('50600', 'Risk Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Risk allowance (5% of basic).'),

    ('50700', 'Overtime', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Ordinary and commuted overtime payments.'),

    ('50800', 'Rural Hardship Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Rural hardship allowance (20% of basic).'),

    ('50900', 'Remote Hardship Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Remote hardship allowance (25% of basic).'),

    ('50910', 'Disability Special Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Disability special allowance (30% of basic, replaces transport).'),

    ('50920', 'Acting Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Acting allowance for higher posts.'),

    ('50930', 'Leave Commutation', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Payment in lieu of commuted leave.'),

    ('50940', 'Terminal Benefits', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Terminal leave, gratuity, pension contributions on separation.'),

-- ---- Employer Statutory Contributions (51000–51999) ----
    ('51000', 'NAPSA Employer Contribution', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employer NAPSA contribution (5% of gross, capped).'),

    ('51100', 'NHIMA Employer Contribution', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employer NHIMA contribution (1% of gross).'),

    ('51200', 'LASF Employer Contribution', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employer LASF contribution.'),

    ('51300', 'Funeral Scheme Employer Contribution', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Employer funeral insurance contribution (0.6%).'),

    ('51400', 'Workers Compensation Contribution', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Workers Compensation Fund contribution.'),

-- ---- Supplies and Consumables (52000–52999) ----
    ('52000', 'Office Supplies', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Stationery, printer cartridges, office consumables.'),

    ('52100', 'Cleaning Materials', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Cleaning materials and supplies.'),

    ('52200', 'Maintenance Materials', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Materials for repairs and maintenance.'),

    ('52300', 'PPE and Uniforms', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Personal protective equipment and uniforms.'),

    ('52400', 'Drugs and Medical Supplies', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Pharmaceuticals and medical supplies.'),

-- ---- Utilities and Communication (53000–53999) ----
    ('53000', 'Electricity', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Electricity bills for council facilities.'),

    ('53100', 'Water and Sewerage', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Water and sewerage bills.'),

    ('53200', 'Telephone and Internet', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Telephone, internet, and communication services.'),

    ('53300', 'Postage and Courier', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Postage and courier services.'),

-- ---- Fuel and Vehicle Operating Costs (54000–54999) ----
    ('54000', 'Fuel and Lubricants', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Fuel and lubricants for vehicles and equipment.'),

    ('54100', 'Vehicle Repairs and Maintenance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Repairs and maintenance for vehicles.'),

    ('54200', 'Vehicle Insurance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Vehicle insurance premiums.'),

-- ---- Repairs and Maintenance (55000–55999) ----
    ('55000', 'Building Repairs and Maintenance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Repairs and maintenance of council buildings.'),

    ('55100', 'Plant and Equipment Repairs', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Repairs and maintenance of plant and equipment.'),

    ('55200', 'Road and Drainage Maintenance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Routine maintenance of roads and drainages.'),

    ('55300', 'Parks and Gardens Maintenance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Maintenance of parks, gardens, and open spaces.'),

-- ---- Travel and Training (56000–56999) ----
    ('56000', 'Travel and Transport', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Travel and transport costs.'),

    ('56100', 'Subsistence Allowance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Subsistence allowance for travel on duty.'),

    ('56200', 'Training and Development', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Staff training, workshops, and conferences.'),

    ('56300', 'Study Leave Support', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Support for staff on paid study leave.'),

-- ---- Professional Services (57000–57999) ----
    ('57000', 'Professional Fees - Legal', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Legal fees and professional services.'),

    ('57100', 'Professional Fees - Audit', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'External audit fees.'),

    ('57200', 'Professional Fees - Other', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Other professional fees.'),

    ('57300', 'Consultancy Services', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Consultancy services.'),

-- ---- Other Operating Expenses (58000–58999) ----
    ('58000', 'Insurance', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Insurance premiums other than vehicle.'),

    ('58100', 'Bank Charges', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Bank charges and transaction fees.'),

    ('58200', 'Subscriptions', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Subscriptions to professional bodies and publications.'),

    ('58300', 'Publicity and Marketing', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Publicity, marketing, and advertising.'),

    ('58400', 'Council Functions and Events', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Council functions and events.'),

    ('58500', 'Grants and Donations', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Grants and donations to third parties.'),

    ('58600', 'Bad Debts', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Bad debt written off.'),

-- ---- Depreciation and Amortisation (59000–59999) ----
    ('59000', 'Depreciation - Buildings', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Depreciation on buildings.'),

    ('59100', 'Depreciation - Plant and Equipment', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Depreciation on plant and equipment.'),

    ('59200', 'Depreciation - Motor Vehicles', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Depreciation on motor vehicles.'),

    ('59300', 'Depreciation - Furniture and Fittings', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Depreciation on furniture and fittings.'),

    ('59400', 'Depreciation - IT Equipment', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Depreciation on IT equipment.'),

    ('59500', 'Amortisation - Intangible Assets', 'EXPENSE', 'OPERATING_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Amortisation on intangible assets.'),

-- ---- Capital Expenditure (59600–59999) ----
    ('59600', 'Capital Works - Buildings', 'EXPENSE', 'CAPITAL_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Capital expenditure on buildings.'),

    ('59700', 'Capital Works - Roads', 'EXPENSE', 'CAPITAL_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Capital expenditure on roads.'),

    ('59800', 'Capital Works - Water and Sanitation', 'EXPENSE', 'CAPITAL_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Capital expenditure on water and sanitation infrastructure.'),

    ('59900', 'Capital Works - Other', 'EXPENSE', 'CAPITAL_EXPENSE', 'DEBIT',
     TRUE, FALSE, NULL, FALSE, '2026-01-01',
     'Other capital expenditure.');

-- =====================================================================
-- AUDIT LOG — Record COA seeding
-- =====================================================================
INSERT INTO compliance_rule_change_log
    (entity_type, entity_id, change_type, new_value, change_reason, changed_by, record_hash)
SELECT
    'CHART_OF_ACCOUNTS',
    coa.account_id,
    'CREATE',
    jsonb_build_object(
        'account_code', coa.account_code,
        'account_name', coa.account_name,
        'account_type', coa.account_type,
        'account_class', coa.account_class,
        'normal_balance', coa.normal_balance,
        'is_control_account', coa.is_control_account
    ),
    'Initial chart of accounts seed — Zambian Local Authority standard structure',
    '00000000-0000-0000-0000-000000000001'::UUID,
    encode(sha256((coa.account_id::text || coa.account_code || NOW()::text)::bytea), 'hex')
FROM chart_of_accounts coa;
