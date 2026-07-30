-- Step 1: Add two missing HRA Town positions
INSERT OR IGNORE INTO HRA_Positions (position_id, title, salary_scale, establishment, council_id, standard_id)
VALUES
  ('HR-HRM-HEALTH-TOWN', 'Human Resource Management Officer', 'LGSS/08', 1, 1, 'HRA-HRM-HEALTH-TOW-01'),
  ('HR-HRM-FISH-TOWN',   'Human Resource Management Officer', 'LGSS/08', 1, 1, 'HRA-HRM-FISH-TOW-01');

-- Step 2: Populate HRA_ReportingLines with all Town Council reporting relationships
INSERT OR IGNORE INTO HRA_ReportingLines (position_id, reports_to) VALUES
  ('HR-DIR-TOWN',           NULL),
  ('HR-CHRO-TOWN',          'HR-DIR-TOWN'),
  ('HR-SNR-HRO-TOWN',       'HR-CHRO-TOWN'),
  ('HR-HRO-TOWN',           'HR-SNR-HRO-TOWN'),
  ('HR-HRM-HEALTH-TOWN',    'HR-DIR-TOWN'),
  ('HR-HRM-FISH-TOWN',      'HR-DIR-TOWN'),
  ('HR-CH-ADMIN-TOWN',      'HR-DIR-TOWN'),
  ('HR-ADMIN-TOWN',         'HR-CH-ADMIN-TOWN'),
  ('HR-SEC-TOWN',           'HR-CH-ADMIN-TOWN'),
  ('HR-STENO-TOWN',         'HR-CH-ADMIN-TOWN'),
  ('HR-TYPIST-TOWN',        'HR-ADMIN-TOWN'),
  ('HR-ORDERLY-TOWN',       'HR-ADMIN-TOWN'),
  ('HR-DRIVER-TOWN',        'HR-ADMIN-TOWN'),
  ('HR-ADMIN-HEALTH-TOWN',  'HR-DIR-TOWN'),
  ('HR-STENO-HEALTH-TOWN',  'HR-DIR-TOWN'),
  ('HR-DRIVER-HEALTH-TOWN', 'HR-DIR-TOWN'),
  ('HR-GW-HEALTH-TOWN',     'HR-DIR-TOWN'),
  ('HR-COMM-CLERK-TOWN',    'HR-CH-ADMIN-TOWN'),
  ('HR-ASST-COMM-TOWN',     'HR-COMM-CLERK-TOWN'),
  ('HR-REG-SUP-TOWN',       'HR-ADMIN-TOWN'),
  ('HR-REG-CLERK-TOWN',     'HR-REG-SUP-TOWN'),
  ('HR-SNR-SEC-TOWN',       'HR-DIR-TOWN'),
  ('HR-SEC-OFFICER-TOWN',   'HR-SNR-SEC-TOWN'),
  ('HR-SERGEANT-TOWN',      'HR-SNR-SEC-TOWN'),
  ('HR-SUB-INSPECTOR-TOWN', 'HR-SNR-SEC-TOWN'),
  ('HR-POLICE-TOWN',        'HR-SNR-SEC-TOWN');

SELECT 'HRA_Positions Town count:', COUNT(*) FROM HRA_Positions WHERE council_id = 1;
SELECT 'HRA_ReportingLines count:', COUNT(*) FROM HRA_ReportingLines;
