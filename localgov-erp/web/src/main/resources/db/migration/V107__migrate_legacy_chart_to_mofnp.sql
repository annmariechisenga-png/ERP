-- ============================================================================
-- V107: Migrate legacy chart_of_accounts to MoFNP
-- ----------------------------------------------------------------------------
-- This migration:
--   1. Adds MoFNP mapping columns to chart_of_accounts
--   2. Maps 133 legacy accounts to MoFNP targets (MAPPED)
--   3. Flags 8 legacy accounts as council-specific (KEPT)
--   4. Repoints FKs on transaction tables to mofnp_chart_of_accounts
--   5. Migrates existing transaction rows to MoFNP account IDs
--   6. Creates the audit view for old-to-new crosswalk
--
-- Idempotent: safe to run on a fresh DB, a partially-migrated DB, or a
-- fully-migrated DB. Uses IF NOT EXISTS / DO blocks throughout.
--
-- Depends on: V105 (mofnp_chart_of_accounts table), V106 (MoFNP seed data)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- PART 1: Add MoFNP mapping columns to chart_of_accounts
-- ---------------------------------------------------------------------------
ALTER TABLE chart_of_accounts
    ADD COLUMN IF NOT EXISTS mofnp_account_id UUID,
    ADD COLUMN IF NOT EXISTS mofnp_mapping_status VARCHAR(20),
    ADD COLUMN IF NOT EXISTS mofnp_mapping_notes TEXT;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chart_of_accounts_mofnp_mapping_status_check') THEN
        ALTER TABLE chart_of_accounts
            ADD CONSTRAINT chart_of_accounts_mofnp_mapping_status_check
            CHECK (mofnp_mapping_status IN ('MAPPED','KEPT','MERGED','UNMAPPED'));
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chart_of_accounts_mofnp_account_id_fkey') THEN
        ALTER TABLE chart_of_accounts
            ADD CONSTRAINT chart_of_accounts_mofnp_account_id_fkey
            FOREIGN KEY (mofnp_account_id)
            REFERENCES mofnp_chart_of_accounts(account_id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_chart_of_accounts_mofnp
    ON chart_of_accounts(mofnp_account_id)
    WHERE mofnp_account_id IS NOT NULL;

-- ---------------------------------------------------------------------------
-- PART 2: Reset mapping state (idempotent starting point)
-- ---------------------------------------------------------------------------
UPDATE chart_of_accounts
SET mofnp_account_id = NULL,
    mofnp_mapping_status = NULL,
    mofnp_mapping_notes = NULL
WHERE mofnp_mapping_status IS NOT NULL;

-- ---------------------------------------------------------------------------
-- PART 3: Populate MAPPED accounts (133)
-- ---------------------------------------------------------------------------

-- ASSETS
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='326060'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Cash-in-hand per MoFNP p.71' WHERE account_code='10100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='322010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Standing Imprest per MoFNP p.71' WHERE account_code='10110';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='326040'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Commercial Account Balances per MoFNP p.71' WHERE account_code IN ('10200','10210','10220','10230','10240','10250','10290');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='323099'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other prepayments per MoFNP p.71' WHERE account_code='12000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='322070'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Staff Advances per MoFNP p.71' WHERE account_code='12100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='322099'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other loans per MoFNP p.71' WHERE account_code IN ('12200','12300');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='312201'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Material and supplies per MoFNP p.70' WHERE account_code IN ('13000','13100','13200','13300');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='312299'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other inventory per MoFNP p.70' WHERE account_code='13900';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='314003'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Land per MoFNP p.71' WHERE account_code='15000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='311101'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Residential Buildings per MoFNP p.67' WHERE account_code='15100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='311201'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Earth Moving Machinery per MoFNP p.67' WHERE account_code='15200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='311704'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Motor Vehicles per MoFNP p.69' WHERE account_code='15300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='311501'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Office Furniture per MoFNP p.69' WHERE account_code='15400';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='311301'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Computers, Peripherals, Equipment per MoFNP p.68' WHERE account_code='15500';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='311401'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Dams per MoFNP p.69' WHERE account_code='15600';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='311950'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Computer software per MoFNP p.70' WHERE account_code='15700';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='312202'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Work-in-progress per MoFNP p.70' WHERE account_code='15800';

-- LIABILITIES
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411110'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Suppliers of goods and services per MoFNP p.71' WHERE account_code='20100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411399'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other Creditors per MoFNP p.71' WHERE account_code='20200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411140'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='ZRA per MoFNP p.71' WHERE account_code IN ('21000','22300','22400');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411150'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='NAPSA per MoFNP p.71' WHERE account_code IN ('21100','21200');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411190'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Health Insurance per MoFNP p.71' WHERE account_code IN ('21300','21400');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411170'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='LASF per MoFNP p.71' WHERE account_code='21500';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411200'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Funeral Scheme per MoFNP p.71' WHERE account_code IN ('21600','21700');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411210'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Union per MoFNP p.71' WHERE account_code='21800';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411299'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other accrued expenses per MoFNP p.71' WHERE account_code IN ('21900','22000');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411450'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Third Party deposits per MoFNP p.72' WHERE account_code IN ('22100','22200');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411410'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Short term loans per MoFNP p.72' WHERE account_code='25000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='421399'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other creditors per MoFNP p.72' WHERE account_code IN ('25100','25200');

-- EQUITY
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='510010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Accumulated fund per MoFNP p.72' WHERE account_code IN ('30100','30500');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='530010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Asset Replacement Reserve per MoFNP p.73' WHERE account_code='30200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='530020'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Revaluation Reserve per MoFNP p.73' WHERE account_code='30300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='530030'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='General Reserves per MoFNP p.73' WHERE account_code='30400';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='520000'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Excess/(Deficit) per MoFNP p.72' WHERE account_code='39900';

-- REVENUE
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='151101'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Residential Rates per MoFNP p.49' WHERE account_code='40100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='151201'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Personal levy per MoFNP p.49' WHERE account_code='40200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='152013'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Market Fees per MoFNP p.49' WHERE account_code IN ('40300','40400');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='152199'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other fees and charges per MoFNP p.52' WHERE account_code='40500';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='153099'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other Licences per MoFNP p.52' WHERE account_code='40600';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='155001'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Health permits per MoFNP p.53' WHERE account_code='40700';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='156001'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Service Charges Residential plots per MoFNP p.53' WHERE account_code IN ('40800','41100');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='157002'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Surplus/Deficit Commercial Ventures per MoFNP p.54' WHERE account_code='40900';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='157014'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Proceeds from sale of publications per MoFNP p.54' WHERE account_code='41000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='157099'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other Income per MoFNP p.54' WHERE account_code IN ('41200','41400');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='157001'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Interest on investments per MoFNP p.54' WHERE account_code='41300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='158004'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='LGEF per MoFNP p.54' WHERE account_code='45000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='158001'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='CDF per MoFNP p.54' WHERE account_code='45100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='159001'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Devolution Capital Grant per MoFNP p.54' WHERE account_code='45200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='158099'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other Grants per MoFNP p.54' WHERE account_code IN ('45300','45400');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='611010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Gains (Loss) on sale of assets per MoFNP p.73' WHERE account_code='49000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='530020'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Revaluation Reserve per MoFNP p.73' WHERE account_code='49100';

-- EXPENSES: Personal Emoluments
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='211310'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Salaries Div. I per MoFNP p.55' WHERE account_code='50100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213220'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Housing Allowance per MoFNP p.56' WHERE account_code='50200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213218'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Transport allowance per MoFNP p.56' WHERE account_code='50300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213299'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Other Allowances per MoFNP p.56' WHERE account_code IN ('50400','50910');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213223'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Education Allowance per MoFNP p.56' WHERE account_code='50500';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213219'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Risk allowance per MoFNP p.56' WHERE account_code='50600';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213206'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Overtime Div. I per MoFNP p.56' WHERE account_code='50700';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213110'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Rural Hardship per MoFNP p.55' WHERE account_code='50800';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213130'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Remote Allowance per MoFNP p.56' WHERE account_code='50900';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213224'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Acting Allowance per MoFNP p.56' WHERE account_code='50920';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='213201'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Cash in Lieu of Leave per MoFNP p.56' WHERE account_code='50930';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='411520'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Terminal Benefits per MoFNP p.72' WHERE account_code='50940';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='214210'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='NAPSA per MoFNP p.56' WHERE account_code='51000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='214250'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='NHIMA per MoFNP p.57' WHERE account_code='51100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='214230'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='LASF per MoFNP p.56' WHERE account_code='51200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='214260'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Funeral Insurance per MoFNP p.57' WHERE account_code='51300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='214240'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Workman Compensation per MoFNP p.57' WHERE account_code='51400';

-- EXPENSES: Goods and Services
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='221010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Office Material per MoFNP p.57' WHERE account_code='52000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='225023'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Cleaning Materials per MoFNP p.58' WHERE account_code='52100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='225011'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Road Maintenance Materials per MoFNP p.58' WHERE account_code IN ('52200','55200');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='225003'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='PPE and Uniforms per MoFNP p.58' WHERE account_code='52300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='225005'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Drugs, Vaccines per MoFNP p.58' WHERE account_code='52400';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='222030'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Electricity Charges per MoFNP p.57' WHERE account_code='53000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='222020'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Water and Sanitation Charges per MoFNP p.57' WHERE account_code='53100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='221020'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Telephone, Fax, Telex, Radio per MoFNP p.57' WHERE account_code='53200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='221040'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Postal Charges per MoFNP p.57' WHERE account_code='53300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='223010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Fuel Oil and Lubricants per MoFNP p.57' WHERE account_code='54000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='223050'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Repairs per MoFNP p.58' WHERE account_code IN ('54100','55100');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='223060'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Insurance per MoFNP p.58' WHERE account_code='54200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='222040'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Building Maintenance per MoFNP p.57' WHERE account_code='55000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='226043'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Parks and Gardens per MoFNP p.60' WHERE account_code='55300';

-- EXPENSES: Services
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='227110'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Road, Rail and Air Fares per MoFNP p.60' WHERE account_code='56000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='227130'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Allowances per MoFNP p.60' WHERE account_code='56100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='228110'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Training Allowances per MoFNP p.60' WHERE account_code='56200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='228310'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Training Allowances per MoFNP p.61' WHERE account_code='56300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='229060'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Legal fees per MoFNP p.61' WHERE account_code='57000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='226003'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Audit fees per MoFNP p.59' WHERE account_code='57100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='226001'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Consultancy per MoFNP p.59' WHERE account_code IN ('57200','57300');
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='222060'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Insurance for Buildings per MoFNP p.57' WHERE account_code='58000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='226007'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Bank Charges per MoFNP p.59' WHERE account_code='58100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='221090'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Subscription per MoFNP p.57' WHERE account_code='58200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='226008'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Advertisement per MoFNP p.59' WHERE account_code='58300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='226009'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Public Functions per MoFNP p.59' WHERE account_code='58400';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='262010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Grants to NGOs per MoFNP p.63' WHERE account_code='58500';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='224007'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Loss of Public Money/Stores per MoFNP p.58' WHERE account_code='58600';

-- EXPENSES: Depreciation
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='231010'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Depreciation Freehold per MoFNP p.62' WHERE account_code='59000';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='231025'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Depreciation Plant per MoFNP p.62' WHERE account_code='59100';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='231015'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Depreciation Vehicles per MoFNP p.62' WHERE account_code='59200';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='231035'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Depreciation Furniture per MoFNP p.62' WHERE account_code='59300';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='231030'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Depreciation Computers per MoFNP p.62' WHERE account_code IN ('59400','59500');

-- EXPENSES: Capital Works
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='229102'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='AUC Office Buildings per MoFNP p.61' WHERE account_code='59600';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='229403'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='Road Regravelling per MoFNP p.62' WHERE account_code='59700';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='229108'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='AUC Boreholes per MoFNP p.61' WHERE account_code='59800';
UPDATE chart_of_accounts SET mofnp_account_id=(SELECT account_id FROM mofnp_chart_of_accounts WHERE account_code='229199'), mofnp_mapping_status='MAPPED', mofnp_mapping_notes='AUC Other per MoFNP p.61' WHERE account_code='59900';

-- ---------------------------------------------------------------------------
-- PART 4: Mark KEPT accounts
-- ---------------------------------------------------------------------------
UPDATE chart_of_accounts
SET mofnp_account_id = NULL,
    mofnp_mapping_status = 'KEPT',
    mofnp_mapping_notes = 'Council-specific AR sub-ledger; no direct MoFNP equivalent'
WHERE account_code IN ('11000','11100','11200','11300','11400','11500','11900');

UPDATE chart_of_accounts
SET mofnp_account_id = NULL,
    mofnp_mapping_status = 'KEPT',
    mofnp_mapping_notes = 'Legacy consolidated accumulated depreciation. MoFNP requires split by asset class: 311305, 311411, 311505, 311603, 311707, 311804. Split scheduled for V110.'
WHERE account_code = '15900';

-- ---------------------------------------------------------------------------
-- PART 5: Repoint FKs on transaction tables
-- ---------------------------------------------------------------------------
DO $$
DECLARE fk_target TEXT;
BEGIN
    SELECT ccu.table_name INTO fk_target
    FROM information_schema.table_constraints tc
    JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND tc.table_name = 'journal_line'
      AND tc.constraint_name = 'journal_line_account_id_fkey';
    IF fk_target = 'chart_of_accounts' THEN
        ALTER TABLE journal_line DROP CONSTRAINT journal_line_account_id_fkey;
        ALTER TABLE journal_line ADD CONSTRAINT journal_line_account_id_fkey
            FOREIGN KEY (account_id) REFERENCES mofnp_chart_of_accounts(account_id);
    END IF;
END $$;

DO $$
DECLARE fk_target TEXT;
BEGIN
    SELECT ccu.table_name INTO fk_target
    FROM information_schema.table_constraints tc
    JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND tc.table_name = 'ap_invoice_line'
      AND tc.constraint_name = 'ap_invoice_line_account_id_fkey';
    IF fk_target = 'chart_of_accounts' THEN
        ALTER TABLE ap_invoice_line DROP CONSTRAINT ap_invoice_line_account_id_fkey;
        ALTER TABLE ap_invoice_line ADD CONSTRAINT ap_invoice_line_account_id_fkey
            FOREIGN KEY (account_id) REFERENCES mofnp_chart_of_accounts(account_id);
    END IF;
END $$;

DO $$
DECLARE fk_target TEXT;
BEGIN
    SELECT ccu.table_name INTO fk_target
    FROM information_schema.table_constraints tc
    JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
    WHERE tc.constraint_type = 'FOREIGN KEY'
      AND tc.table_name = 'ar_invoice_line'
      AND tc.constraint_name = 'ar_invoice_line_account_id_fkey';
    IF fk_target = 'chart_of_accounts' THEN
        ALTER TABLE ar_invoice_line DROP CONSTRAINT ar_invoice_line_account_id_fkey;
        ALTER TABLE ar_invoice_line ADD CONSTRAINT ar_invoice_line_account_id_fkey
            FOREIGN KEY (account_id) REFERENCES mofnp_chart_of_accounts(account_id);
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- PART 6: Migrate transaction rows
-- ---------------------------------------------------------------------------
ALTER TABLE journal_line DISABLE TRIGGER trg_prevent_journal_line_change;

UPDATE journal_line jl
SET account_id = coa.mofnp_account_id
FROM chart_of_accounts coa
WHERE jl.account_id = coa.account_id
  AND coa.mofnp_mapping_status = 'MAPPED'
  AND coa.mofnp_account_id IS NOT NULL;

ALTER TABLE journal_line ENABLE TRIGGER trg_prevent_journal_line_change;

UPDATE ap_invoice_line ail
SET account_id = coa.mofnp_account_id
FROM chart_of_accounts coa
WHERE ail.account_id = coa.account_id
  AND coa.mofnp_mapping_status = 'MAPPED'
  AND coa.mofnp_account_id IS NOT NULL;

UPDATE ar_invoice_line aril
SET account_id = coa.mofnp_account_id
FROM chart_of_accounts coa
WHERE aril.account_id = coa.account_id
  AND coa.mofnp_mapping_status = 'MAPPED'
  AND coa.mofnp_account_id IS NOT NULL;

-- ---------------------------------------------------------------------------
-- PART 7: Audit view
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_mofnp_migration_audit AS
SELECT coa.account_code AS old_code,
       coa.account_name AS old_name,
       coa.account_type AS old_type,
       mca.account_code AS new_code,
       mca.account_name AS new_name,
       coa.mofnp_mapping_status,
       coa.mofnp_mapping_notes
FROM chart_of_accounts coa
LEFT JOIN mofnp_chart_of_accounts mca ON coa.mofnp_account_id = mca.account_id
ORDER BY coa.account_code;

-- ---------------------------------------------------------------------------
-- PART 8: Verification
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    unmapped_count INTEGER;
    mapped_count INTEGER;
    kept_count INTEGER;
    null_target_mapped INTEGER;
BEGIN
    SELECT COUNT(*) INTO unmapped_count FROM chart_of_accounts WHERE mofnp_mapping_status IS NULL;
    SELECT COUNT(*) INTO mapped_count FROM chart_of_accounts WHERE mofnp_mapping_status = 'MAPPED';
    SELECT COUNT(*) INTO kept_count FROM chart_of_accounts WHERE mofnp_mapping_status = 'KEPT';
    SELECT COUNT(*) INTO null_target_mapped FROM chart_of_accounts WHERE mofnp_mapping_status = 'MAPPED' AND mofnp_account_id IS NULL;

    IF unmapped_count > 0 THEN
        RAISE EXCEPTION 'V107 FAILED: % accounts have no mapping status', unmapped_count;
    END IF;
    IF null_target_mapped > 0 THEN
        RAISE EXCEPTION 'V107 FAILED: % MAPPED accounts have NULL target', null_target_mapped;
    END IF;

    RAISE NOTICE 'V107 PASSED: % MAPPED, % KEPT', mapped_count, kept_count;
END $$;
