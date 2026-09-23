import sqlite3
from pathlib import Path

DB_PATH = Path('/Users/Work/Desktop/ERP/hr_platform.db')

NOTCHS_2025 = {
    'LGSS01': [198927, 194825, 190724, 186623, 182522, 178420, 174319],
    'LGSS02': [187297, 183305, 179313, 175321, 171329, 167336, 163344],
    'LGSS03': [175998, 172114, 168230, 164346, 160462, 156578, 152694],
    'LGSS04': [158865, 155270, 151675, 148080, 144485, 140890, 137295],
    'LGSS05': [147629, 144135, 140641, 137147, 133653, 130159, 126665],
    'LGSS06': [137783, 134394, 131005, 127616, 124227, 120838, 117449],
    'LGSS07': [128270, 124982, 121694, 118406, 115118, 111830, 108542],
    'LGSS08': [123277, 120410, 117543, 114676, 111809, 108942, 106075],
    'LGSS09': [114869, 112091, 109313, 106535, 103757, 100979, 98201],
    'LGSS10': [106668, 103982, 101296, 98610, 95924, 93238, 90552],
    'LGSS11': [98718, 96123, 93528, 90933, 88338, 85743, 83148],
    'LGSS12': [91539, 89023, 86507, 83991, 81475, 78959, 76443],
    'LGSS13': [84354, 81921, 79488, 77055, 74622, 72189, 69756],
    'LGSS14': [77050, 74711, 72372, 70033, 67694, 65355, 63016],
    'LGSS15': [70258, 68005, 65752, 63499, 61266, 58993, 56740],
    'LGSS16': [63648, 61484, 59320, 57156, 54992, 52828, 50664],
    'LGSS17': [57247, 55172, 53097, 51022, 48947, 46872, 44797],
    'LGSS18': [54998, 52987, 50976, 48965, 46954, 44943, 42932],
    'G1': [50680, 49184, 47688, 46192, 44696],
    'G2': [46389, 44994, 43599, 42204, 40809],
    'G3': [45324, 44030, 42736, 41442, 40148],
}

ALLOWANCE_TYPES = [
    ('HOUSING', 'Housing Allowance', 'PERCENT_BASIC', 0.20, 0, 0, 1, '2025 Management / 2025 Collective Agreement Unionized'),
    ('TRANSPORT', 'Transport Allowance', 'PERCENT_BASIC', 0.17, 1, 0, 1, '2025 Management / 2025 Collective Agreement Unionized'),
    ('FUEL', 'Fuel Allowance', 'PERCENT_BASIC', 0.32, 1, 0, 1, '2025 Management'),
    ('EDUCATION', 'Education Allowance', 'PERCENT_BASIC', 0.20, 1, 0, 1, '2025 Management / 2025 Collective Agreement Unionized'),
    ('RISK', 'Risk Allowance', 'PERCENT_BASIC', 0.02, 1, 0, 1, '2025 Collective Agreement Unionized / FireSUZ 2024'),
    ('RURAL_HARDSHIP', 'Rural Hardship Allowance', 'PERCENT_BASIC', 0.20, 1, 0, 1, '2025 Management / 2025 Collective Agreement Unionized'),
    ('REMOTE_HARDSHIP', 'Remote Hardship Allowance', 'PERCENT_BASIC', 0.25, 1, 0, 1, '2025 Management / 2025 Collective Agreement Unionized'),
    ('STANDBY', 'Standby Allowance', 'PERCENT_BASIC', 0.06, 1, 0, 1, 'FireSUZ 2024'),
    ('EXCESS_HOURS', 'Allowance in Lieu of Excess Hours', 'FIXED_AMOUNT', 400.0, 1, 0, 1, 'FireSUZ 2024'),
    ('MEAL', 'Meal Allowance', 'FIXED_AMOUNT', 150.0, 0, 0, 1, '2025 Management'),
    ('SETTLING_IN', 'Settling-in Allowance', 'PERCENT_ANNUAL_BASIC', 0.25, 0, 0, 1, '2025 Management / 2025 Collective Agreement Unionized'),
    ('SUBSISTENCE', 'Subsistence Allowance', 'FIXED_AMOUNT', 0.0, 0, 0, 1, 'Policy dependent by location'),
    ('OUT_OF_POCKET', 'Out-of-Pocket Allowance', 'FIXED_AMOUNT', 0.0, 0, 0, 1, 'Policy dependent by location'),
    ('REPATRIATION', 'Repatriation Allowance', 'FIXED_AMOUNT', 0.0, 0, 0, 1, 'Policy dependent by division'),
]

DDL = """
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS salary_notch_values (
    scale_code TEXT NOT NULL,
    notch_no INTEGER NOT NULL,
    annual_basic REAL NOT NULL,
    monthly_basic REAL NOT NULL,
    effective_from DATE NOT NULL,
    source_doc TEXT,
    PRIMARY KEY (scale_code, notch_no, effective_from)
);

CREATE TABLE IF NOT EXISTS employee_salary_notch (
    employee_id TEXT NOT NULL,
    scale_code TEXT NOT NULL,
    notch_no INTEGER NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (employee_id, effective_from)
);

CREATE TABLE IF NOT EXISTS allowance_types (
    allowance_code TEXT PRIMARY KEY,
    allowance_name TEXT NOT NULL,
    calc_method TEXT NOT NULL,
    default_value REAL NOT NULL,
    taxable INTEGER NOT NULL DEFAULT 1,
    pensionable INTEGER NOT NULL DEFAULT 0,
    show_on_payslip INTEGER NOT NULL DEFAULT 1,
    active INTEGER NOT NULL DEFAULT 1,
    source_doc TEXT
);

CREATE TABLE IF NOT EXISTS employee_allowances (
    employee_id TEXT NOT NULL,
    allowance_code TEXT NOT NULL,
    calc_method TEXT NOT NULL,
    value REAL NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (employee_id, allowance_code, effective_from),
    FOREIGN KEY (allowance_code) REFERENCES allowance_types(allowance_code)
);

CREATE TABLE IF NOT EXISTS payroll_periods (
    period_id INTEGER PRIMARY KEY AUTOINCREMENT,
    period_code TEXT NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pay_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'OPEN'
);

CREATE TABLE IF NOT EXISTS payroll_runs (
    run_id INTEGER PRIMARY KEY AUTOINCREMENT,
    period_id INTEGER NOT NULL,
    run_code TEXT NOT NULL UNIQUE,
    run_status TEXT NOT NULL DEFAULT 'DRAFT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    total_employees INTEGER DEFAULT 0,
    total_basic REAL DEFAULT 0,
    total_allowances REAL DEFAULT 0,
    total_gross REAL DEFAULT 0,
    total_deductions REAL DEFAULT 0,
    total_net REAL DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (period_id) REFERENCES payroll_periods(period_id)
);

CREATE TABLE IF NOT EXISTS payroll_run_items (
    run_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_id INTEGER NOT NULL,
    employee_id TEXT NOT NULL,
    employee_name TEXT,
    salary_scale TEXT,
    notch_no INTEGER,
    basic_salary REAL NOT NULL,
    allowances_total REAL NOT NULL,
    gross_pay REAL NOT NULL,
    deductions_total REAL NOT NULL,
    net_pay REAL NOT NULL,
    FOREIGN KEY (run_id) REFERENCES payroll_runs(run_id)
);

CREATE TABLE IF NOT EXISTS payroll_run_item_allowances (
    item_allowance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_item_id INTEGER NOT NULL,
    allowance_code TEXT NOT NULL,
    allowance_name TEXT NOT NULL,
    calc_method TEXT NOT NULL,
    calc_value REAL NOT NULL,
    amount REAL NOT NULL,
    visible_on_payslip INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (run_item_id) REFERENCES payroll_run_items(run_item_id)
);

CREATE TABLE IF NOT EXISTS payroll_run_item_obligations (
    item_obligation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    run_item_id INTEGER NOT NULL,
    employee_id TEXT NOT NULL,
    scheme_code TEXT NOT NULL,
    obligation_type TEXT NOT NULL,
    employee_amount REAL NOT NULL DEFAULT 0,
    employer_amount REAL NOT NULL DEFAULT 0,
    total_amount REAL NOT NULL DEFAULT 0,
    due_date DATE,
    payment_status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (run_item_id) REFERENCES payroll_run_items(run_item_id)
);

CREATE TABLE IF NOT EXISTS payroll_statutory_rates (
    rate_code TEXT PRIMARY KEY,
    rate_name TEXT NOT NULL,
    rate_value REAL NOT NULL,
    cap_amount REAL,
    effective_from DATE NOT NULL,
    active INTEGER NOT NULL DEFAULT 1
);
"""


def normalize_scale(raw: str | None) -> str | None:
    if not raw:
        return None
    s = raw.upper().replace(' ', '').replace('/', '')
    if s.startswith('LGSS'):
        num = ''.join(ch for ch in s[4:] if ch.isdigit())
        if num:
            return f'LGSS{int(num):02d}'
    if s in {'G1', 'G2', 'G3'}:
        return s
    if s.startswith('GRADE'):
        n = ''.join(ch for ch in s if ch.isdigit())
        if n in {'1', '2', '3'}:
            return f'G{n}'
    return s


con = sqlite3.connect(DB_PATH)
cur = con.cursor()
cur.executescript(DDL)

# Seed notch values (2025 effective)
cur.execute("DELETE FROM salary_notch_values WHERE effective_from = '2025-01-01'")
for scale, annual_desc in NOTCHS_2025.items():
    annual_asc = sorted(annual_desc)
    for idx, annual in enumerate(annual_asc, start=1):
        monthly = round(annual / 12.0, 2)
        cur.execute(
            """
            INSERT INTO salary_notch_values (scale_code, notch_no, annual_basic, monthly_basic, effective_from, source_doc)
            VALUES (?, ?, ?, ?, '2025-01-01', 'FireSUZ 2024 + 2025 Management + 2025 Collective Agreement Unionized')
            """,
            (scale, idx, float(annual), monthly),
        )

# Seed allowance types
for row in ALLOWANCE_TYPES:
    cur.execute(
        """
        INSERT INTO allowance_types (allowance_code, allowance_name, calc_method, default_value, taxable, pensionable, show_on_payslip, active, source_doc)
        VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)
        ON CONFLICT(allowance_code) DO UPDATE SET
            allowance_name=excluded.allowance_name,
            calc_method=excluded.calc_method,
            default_value=excluded.default_value,
            taxable=excluded.taxable,
            pensionable=excluded.pensionable,
            show_on_payslip=excluded.show_on_payslip,
            source_doc=excluded.source_doc,
            active=1
        """,
        row,
    )

# Seed statutory rates (basic placeholders; can be adjusted by finance)
rates = [
    ('PAYE', 'PAYE rate (basic placeholder)', 0.00, None, '2025-01-01'),
    ('NHIMA', 'NHIMA employee contribution rate on gross salary', 0.01, None, '2025-01-01'),
    ('NHIMA_EMPLOYER', 'NHIMA employer contribution rate on gross salary', 0.01, None, '2025-01-01'),
    ('NAPSA', 'NAPSA employee contribution rate (basic placeholder)', 0.05, None, '2025-01-01'),
    ('NAPSA_EMPLOYER', 'NAPSA employer contribution rate', 0.05, None, '2025-01-01'),
]
for rate in rates:
    cur.execute(
        """
        INSERT INTO payroll_statutory_rates (rate_code, rate_name, rate_value, cap_amount, effective_from, active)
        VALUES (?, ?, ?, ?, ?, 1)
        ON CONFLICT(rate_code) DO UPDATE SET
            rate_name=excluded.rate_name,
            rate_value=excluded.rate_value,
            cap_amount=excluded.cap_amount,
            effective_from=excluded.effective_from,
            active=1
        """,
        rate,
    )

# Seed employee notch assignment (entry notch = 1 by default)
cur.execute("SELECT employee_id, salary_scale FROM employees WHERE COALESCE(is_active,1)=1 AND employee_id IS NOT NULL")
for employee_id, raw_scale in cur.fetchall():
    scale = normalize_scale(raw_scale)
    if not scale or scale not in NOTCHS_2025:
        continue

    cur.execute(
        """
        SELECT 1 FROM employee_salary_notch
        WHERE employee_id = ? AND is_active = 1
        """,
        (employee_id,),
    )
    if cur.fetchone():
        continue

    cur.execute(
        """
        INSERT INTO employee_salary_notch (employee_id, scale_code, notch_no, effective_from, effective_to, is_active)
        VALUES (?, ?, 1, '2025-01-01', NULL, 1)
        """,
        (employee_id, scale),
    )

con.commit()

# Summary
cur.execute("SELECT COUNT(*) FROM salary_notch_values WHERE effective_from='2025-01-01'")
notch_count = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM allowance_types WHERE active=1")
allow_count = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM employee_salary_notch WHERE is_active=1")
emp_notch_count = cur.fetchone()[0]

print('Database:', DB_PATH)
print('Seeded salary_notch_values:', notch_count)
print('Seeded allowance_types:', allow_count)
print('Active employee notch assignments:', emp_notch_count)

con.close()
