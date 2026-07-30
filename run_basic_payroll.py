import sqlite3
from datetime import date, timedelta
from pathlib import Path

from generate_standard_payslip import emit_files

DB_PATH = Path('/Users/Work/Desktop/ERP/hr_platform.db')
PAYSLIP_EXPORT_ROOT = Path('/Users/Work/Desktop/ERP/generated_standard_payslips')

ALLOWANCE_POLICY_2026 = [
    ('HOU', 'Housing Allowance', 'PERCENT_BASIC', 0.20, 0, 0, 1, 'Collective Agreement 2026'),
    ('EDU', 'Education Allowance', 'PERCENT_BASIC', 0.20, 1, 0, 1, 'Collective Agreement 2026'),
    ('TRN', 'Transport Allowance', 'PERCENT_BASIC', 0.20, 1, 0, 1, 'Collective Agreement 2026'),
    ('FUL', 'Fuel Allowance', 'PERCENT_BASIC', 0.30, 1, 0, 1, 'Management Circular 2025 Sec 2.1(ii)'),
    ('RISK', 'Risk Allowance', 'PERCENT_BASIC', 0.05, 1, 0, 1, 'Collective Agreement 2026'),
    ('STANDBY', 'Standby Allowance', 'PERCENT_BASIC', 0.06, 1, 0, 1, 'FIRESUZ Agreement 2024 Sec 2.2(iii)'),
    ('ACTING', 'Acting Allowance', 'VARIABLE', 0.00, 1, 0, 1, 'Collective Agreement 2025 Acting post clause'),
    ('RURAL', 'Rural Hardship Allowance', 'PERCENT_BASIC', 0.20, 1, 0, 1, 'Collective Agreement 2025 Sec 4.2(i)'),
    ('REMOTE', 'Remote Hardship Allowance', 'PERCENT_BASIC', 0.25, 1, 0, 1, 'Collective Agreement 2025 Sec 4.2(ii)'),
    ('RATION', 'Ration Allowance', 'PERCENT_BASIC_TIERED', 0.00, 1, 0, 1, 'FIRESUZ Agreement 2024 Sec 2.2(v)'),
    ('UPKEEP', 'Uniform Upkeep Allowance', 'FIXED_AMOUNT', 240.00, 0, 0, 1, 'Collective Agreement 2026'),
]

RATION_TIERS_2026 = [
    ('LGSS08-LGSS10', 0.125, '["FIRESUZ"]', '2025-01-01'),
    ('LGSS11-LGSS12', 0.150, '["FIRESUZ"]', '2025-01-01'),
    ('LGSS13-LGSS14', 0.200, '["FIRESUZ"]', '2025-01-01'),
]

DEDUCTION_TYPES_2026 = [
    ('PAYE', 'Pay As You Earn', 'STATUTORY', 'FORMULA', 'TAXABLE_PAY', 0.00, 0.00, 'Income Tax Act (Bands effective 2026)', 1, 1),
    ('NAPSA', 'National Pension Scheme', 'STATUTORY', 'PERCENTAGE', 'BASIC_SALARY', 5.00, 5.00, 'NAPSA Act No.40/1996', 2, 1),
    ('NHIS', 'National Health Insurance', 'STATUTORY', 'PERCENTAGE', 'BASIC_SALARY', 1.00, 1.00, 'Health Insurance Act No.2/2018', 3, 1),
    ('NULGAW', 'NULGAW Union Dues', 'VOLUNTARY', 'PERCENTAGE', 'BASIC_SALARY', 2.00, 0.00, 'Union Constitution - NULGAW', 4, 0),
    ('FIRESUZ', 'FIRESUZ Union Dues', 'VOLUNTARY', 'PERCENTAGE', 'BASIC_SALARY', 2.00, 0.00, 'Union Constitution - FIRESUZ', 4, 0),
    ('ZULAWU', 'ZULAWU Union Dues', 'VOLUNTARY', 'PERCENTAGE', 'BASIC_SALARY', 2.00, 0.00, 'Union Constitution', 4, 0),
    ('MADISON_0.4', 'Madison Funeral Policy (Base)', 'INSURANCE', 'PERCENTAGE', 'BASIC_SALARY', 0.40, 0.00, 'Madison Insurance', 5, 1),
]

MADISON_PARENT_COVERAGE_2026 = [
    (1, 5000.0, 10000.0, 0.175, 0.350, 0.575, 0.750, '2025-01-01'),
    (2, 5000.0, 10000.0, 0.350, 0.701, 0.750, 1.101, '2025-01-01'),
]


def ensure_payroll_obligation_schema(cur):
    cur.executescript(
        """
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

        CREATE TABLE IF NOT EXISTS ration_allowance_tiers (
            tier_id TEXT PRIMARY KEY,
            salary_scale_range TEXT NOT NULL,
            percentage REAL NOT NULL,
            applicable_to TEXT,
            effective_from TEXT NOT NULL,
            effective_to TEXT,
            is_active INTEGER NOT NULL DEFAULT 1
        );

        CREATE TABLE IF NOT EXISTS deduction_types (
            deduction_code TEXT PRIMARY KEY,
            deduction_name TEXT NOT NULL,
            deduction_category TEXT NOT NULL,
            calculation_method TEXT NOT NULL,
            calculation_basis TEXT NOT NULL,
            employee_percentage REAL NOT NULL DEFAULT 0,
            employer_percentage REAL NOT NULL DEFAULT 0,
            legal_authority TEXT,
            priority INTEGER NOT NULL DEFAULT 99,
            is_mandatory INTEGER NOT NULL DEFAULT 0,
            active INTEGER NOT NULL DEFAULT 1
        );

        CREATE TABLE IF NOT EXISTS employee_deductions (
            employee_id TEXT NOT NULL,
            deduction_code TEXT NOT NULL,
            calc_method TEXT NOT NULL,
            value REAL NOT NULL,
            effective_from TEXT NOT NULL,
            effective_to TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            PRIMARY KEY (employee_id, deduction_code, effective_from),
            FOREIGN KEY (deduction_code) REFERENCES deduction_types(deduction_code)
        );

        CREATE TABLE IF NOT EXISTS payroll_run_item_deductions (
            item_deduction_id INTEGER PRIMARY KEY AUTOINCREMENT,
            run_item_id INTEGER NOT NULL,
            deduction_code TEXT NOT NULL,
            deduction_name TEXT NOT NULL,
            deduction_category TEXT NOT NULL,
            authority_ref TEXT,
            calc_method TEXT NOT NULL,
            calc_value REAL,
            amount REAL NOT NULL,
            FOREIGN KEY (run_item_id) REFERENCES payroll_run_items(run_item_id)
        );

        CREATE TABLE IF NOT EXISTS madison_parent_coverage_tiers (
            tier_id TEXT PRIMARY KEY,
            parent_count INTEGER NOT NULL,
            cover_min REAL NOT NULL,
            cover_max REAL NOT NULL,
            additional_rate_min REAL NOT NULL,
            additional_rate_max REAL NOT NULL,
            total_rate_min REAL NOT NULL,
            total_rate_max REAL NOT NULL,
            effective_from TEXT NOT NULL,
            effective_to TEXT,
            is_active INTEGER NOT NULL DEFAULT 1
        );
        """
    )

    cur.execute("PRAGMA table_info(employees)")
    employee_cols = {r[1] for r in cur.fetchall()}
    if 'union_code' not in employee_cols:
        cur.execute("ALTER TABLE employees ADD COLUMN union_code TEXT")

    cur.execute(
        """
        INSERT INTO payroll_statutory_rates (rate_code, rate_name, rate_value, cap_amount, effective_from, active)
        VALUES ('NAPSA_EMPLOYER', 'NAPSA employer contribution rate', 0.05, NULL, '2025-01-01', 1)
        ON CONFLICT(rate_code) DO NOTHING
        """
    )

    cur.execute(
        """
        INSERT INTO payroll_statutory_rates (rate_code, rate_name, rate_value, cap_amount, effective_from, active)
        VALUES ('NHIMA_EMPLOYER', 'NHIMA employer contribution rate on gross salary', 0.01, NULL, '2025-01-01', 1)
        ON CONFLICT(rate_code) DO NOTHING
        """
    )

    cur.execute("PRAGMA table_info(allowance_types)")
    allowance_cols = {r[1] for r in cur.fetchall()}
    if 'show_on_payslip' not in allowance_cols:
        cur.execute("ALTER TABLE allowance_types ADD COLUMN show_on_payslip INTEGER NOT NULL DEFAULT 1")

    for code, name, method, value, taxable, pensionable, show_on_payslip, source_doc in ALLOWANCE_POLICY_2026:
        cur.execute(
            """
            INSERT INTO allowance_types (allowance_code, allowance_name, calc_method, default_value, taxable, pensionable, active, source_doc, show_on_payslip)
            VALUES (?, ?, ?, ?, ?, ?, 1, ?, ?)
            ON CONFLICT(allowance_code) DO UPDATE SET
                allowance_name = excluded.allowance_name,
                calc_method = excluded.calc_method,
                default_value = excluded.default_value,
                taxable = excluded.taxable,
                pensionable = excluded.pensionable,
                source_doc = excluded.source_doc,
                show_on_payslip = excluded.show_on_payslip,
                active = 1
            """,
            (code, name, method, value, taxable, pensionable, source_doc, show_on_payslip),
        )

    for scale_range, percentage, applicable_to, effective_from in RATION_TIERS_2026:
        tier_id = f"RATION-{scale_range}"
        cur.execute(
            """
            INSERT INTO ration_allowance_tiers (tier_id, salary_scale_range, percentage, applicable_to, effective_from, effective_to, is_active)
            VALUES (?, ?, ?, ?, ?, NULL, 1)
            ON CONFLICT(tier_id) DO UPDATE SET
                salary_scale_range = excluded.salary_scale_range,
                percentage = excluded.percentage,
                applicable_to = excluded.applicable_to,
                effective_from = excluded.effective_from,
                effective_to = NULL,
                is_active = 1
            """,
            (tier_id, scale_range, percentage, applicable_to, effective_from),
        )

    for row in DEDUCTION_TYPES_2026:
        cur.execute(
            """
            INSERT INTO deduction_types (
                deduction_code, deduction_name, deduction_category,
                calculation_method, calculation_basis,
                employee_percentage, employer_percentage,
                legal_authority, priority, is_mandatory, active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            ON CONFLICT(deduction_code) DO UPDATE SET
                deduction_name = excluded.deduction_name,
                deduction_category = excluded.deduction_category,
                calculation_method = excluded.calculation_method,
                calculation_basis = excluded.calculation_basis,
                employee_percentage = excluded.employee_percentage,
                employer_percentage = excluded.employer_percentage,
                legal_authority = excluded.legal_authority,
                priority = excluded.priority,
                is_mandatory = excluded.is_mandatory,
                active = 1
            """,
            row,
        )

    for parent_count, cover_min, cover_max, additional_rate_min, additional_rate_max, total_rate_min, total_rate_max, effective_from in MADISON_PARENT_COVERAGE_2026:
        tier_id = f"MADISON-PARENT-{parent_count}-{int(cover_min)}-{int(cover_max)}"
        cur.execute(
            """
            INSERT INTO madison_parent_coverage_tiers (
                tier_id, parent_count, cover_min, cover_max,
                additional_rate_min, additional_rate_max,
                total_rate_min, total_rate_max,
                effective_from, effective_to, is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, 1)
            ON CONFLICT(tier_id) DO UPDATE SET
                parent_count = excluded.parent_count,
                cover_min = excluded.cover_min,
                cover_max = excluded.cover_max,
                additional_rate_min = excluded.additional_rate_min,
                additional_rate_max = excluded.additional_rate_max,
                total_rate_min = excluded.total_rate_min,
                total_rate_max = excluded.total_rate_max,
                effective_from = excluded.effective_from,
                effective_to = NULL,
                is_active = 1
            """,
            (tier_id, parent_count, cover_min, cover_max, additional_rate_min, additional_rate_max, total_rate_min, total_rate_max, effective_from),
        )

    cur.execute("PRAGMA table_info(payroll_run_item_allowances)")
    run_allow_cols = {r[1] for r in cur.fetchall()}
    if 'visible_on_payslip' not in run_allow_cols:
        cur.execute("ALTER TABLE payroll_run_item_allowances ADD COLUMN visible_on_payslip INTEGER NOT NULL DEFAULT 1")

    cur.execute("PRAGMA table_info(payroll_run_items)")
    run_item_cols = {r[1] for r in cur.fetchall()}
    if 'taxable_pay' not in run_item_cols:
        cur.execute("ALTER TABLE payroll_run_items ADD COLUMN taxable_pay REAL")
    if 'paye_amount' not in run_item_cols:
        cur.execute("ALTER TABLE payroll_run_items ADD COLUMN paye_amount REAL")
    if 'napsa_amount' not in run_item_cols:
        cur.execute("ALTER TABLE payroll_run_items ADD COLUMN napsa_amount REAL")
    if 'nhis_amount' not in run_item_cols:
        cur.execute("ALTER TABLE payroll_run_items ADD COLUMN nhis_amount REAL")

def get_allowance_meta(cur, code: str):
    cur.execute(
        """
        SELECT allowance_name, COALESCE(taxable,1), COALESCE(show_on_payslip,1)
        FROM allowance_types
        WHERE allowance_code = ?
        """,
        (code,),
    )
    row = cur.fetchone()
    if row:
        return row[0], int(row[1]), int(row[2])
    return code, 1, 1


def get_basic_salary(cur, grade: str, notch: int) -> float:
    """Queries 2026 specific scales first, then falls back to historical notch values."""
    # 1. Try 2026 management table
    cur.execute(
        "SELECT revised_monthly_k FROM salary_scales_2026 WHERE grade = ? AND notch = ?",
        (grade, notch)
    )
    row = cur.fetchone()
    if row:
        return float(row[0])
    
    # 2. Fallback to salary_notch_values (which includes 2026 unionized scales)
    cur.execute(
        """
        SELECT monthly_basic
        FROM salary_notch_values
        WHERE scale_code = ? AND notch_no = ?
        ORDER BY effective_from DESC
        LIMIT 1
        """,
        (grade, notch),
    )
    sal = cur.fetchone()
    if sal:
        return float(sal[0])
    
    return 0.0


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


def month_bounds(year: int, month: int):
    start = date(year, month, 1)
    if month == 12:
        next_month = date(year + 1, 1, 1)
    else:
        next_month = date(year, month + 1, 1)
    end = next_month - timedelta(days=1)
    return start, end


def get_rate(cur, code: str) -> float:
    cur.execute(
        """
        SELECT rate_value FROM payroll_statutory_rates
        WHERE rate_code = ? AND active = 1
        ORDER BY effective_from DESC LIMIT 1
        """,
        (code,),
    )
    row = cur.fetchone()
    return float(row[0]) if row else 0.0


def calculate_paye_2026(taxable_pay: float) -> float:
    taxable_pay = max(float(taxable_pay or 0.0), 0.0)
    band2 = max(0.0, min(taxable_pay, 7100.0) - 5100.0) * 0.20
    band3 = max(0.0, min(taxable_pay, 9200.0) - 7100.0) * 0.30
    band4 = max(0.0, taxable_pay - 9200.0) * 0.37
    return round(band2 + band3 + band4, 2)


def union_for_employee(cur, employee_id: str, is_fire_officer: bool) -> str:
    cur.execute(
        """
        SELECT upper(trim(COALESCE(union_code, '')))
        FROM employees
        WHERE employee_id = ?
        LIMIT 1
        """,
        (employee_id,),
    )
    row = cur.fetchone()
    if row and row[0]:
        return row[0]
    return 'FIRESUZ' if is_fire_officer else 'ZULAWAU'


def ration_percentage_for_scale(cur, scale_code: str) -> float:
    if not scale_code.startswith('LGSS'):
        return 0.0
    try:
        scale_num = int(scale_code.replace('LGSS', ''))
    except ValueError:
        return 0.0

    cur.execute(
        """
        SELECT salary_scale_range, percentage
        FROM ration_allowance_tiers
        WHERE is_active = 1
          AND (effective_to IS NULL OR effective_to >= date('now'))
        ORDER BY effective_from DESC
        """
    )
    for scale_range, pct in cur.fetchall():
        if not scale_range or '-' not in scale_range:
            continue
        start, end = scale_range.split('-', 1)
        try:
            start_num = int(start.replace('LGSS', ''))
            end_num = int(end.replace('LGSS', ''))
        except ValueError:
            continue
        if start_num <= scale_num <= end_num:
            return float(pct or 0.0)
    return 0.0


def additional_employee_deductions(cur, employee_id: str, basic_salary: float):
    cur.execute(
        """
        SELECT
            ed.deduction_code,
            dt.deduction_name,
            dt.deduction_category,
            dt.legal_authority,
            ed.calc_method,
            ed.value
        FROM employee_deductions ed
        JOIN deduction_types dt ON dt.deduction_code = ed.deduction_code
        WHERE ed.employee_id = ?
          AND ed.is_active = 1
          AND dt.active = 1
          AND (ed.effective_to IS NULL OR ed.effective_to >= date('now'))
        ORDER BY dt.priority, dt.deduction_code
        """,
        (employee_id,),
    )
    rows = []
    for code, name, category, legal_authority, method, value in cur.fetchall():
        method_norm = (method or '').upper()
        rate = float(value or 0.0)
        if method_norm == 'PERCENTAGE':
            amount = round(basic_salary * (rate / 100.0), 2)
        else:
            amount = round(rate, 2)
        if amount <= 0:
            continue
        rows.append((code, name, category, legal_authority, method_norm, rate, amount))
    return rows


def sanitize_fragment(value: str) -> str:
    out = ''.join(ch.lower() if ch.isalnum() else '_' for ch in value)
    while '__' in out:
        out = out.replace('__', '_')
    return out.strip('_') or 'value'


def resolve_authority(cur, employee_id: str):
    cur.execute(
        """
        SELECT district, local_authority_service_number
        FROM employees
        WHERE employee_id = ?
        LIMIT 1
        """,
        (employee_id,),
    )
    row = cur.fetchone()
    district = (row[0] or '').strip() if row else ''
    lasn = (row[1] or '').strip() if row else ''

    code = ''
    if employee_id and '-' in employee_id:
        candidate = employee_id.split('-', 1)[0].strip().upper()
        if 2 <= len(candidate) <= 5 and candidate.isalnum():
            code = candidate
    if not code and lasn:
        cleaned = ''.join(ch for ch in lasn.upper() if ch.isalnum())
        code = cleaned[:3] if cleaned else ''
    if not code:
        code = 'GEN'

    cur.execute(
        """
        SELECT authority_name
        FROM authority_codes
        WHERE UPPER(authority_code) = ?
        LIMIT 1
        """,
        (code,),
    )
    code_row = cur.fetchone()

    authority_name = None
    authority_type = None

    if code_row:
        short_name = code_row[0]
        cur.execute(
            """
            SELECT authority_name, authority_type
            FROM authorities
            WHERE authority_prefix LIKE ?
            LIMIT 1
            """,
            (f'%-{code}',),
        )
        auth_row = cur.fetchone()
        if auth_row:
            authority_name, authority_type = auth_row
        else:
            authority_name = f"{short_name} Local Authority"

    if not authority_name:
        if district:
            authority_name = f"{district.title()} Local Authority"
        else:
            authority_name = 'Local Authority'
    if not authority_type:
        authority_type = 'Local Authority'

    email_domain = code.lower() if code != 'GEN' else 'localauthority'
    contact_email = f'payroll@{email_domain}.gov.zm'
    verify_base_url = f'https://verify.{email_domain}.gov.zm/payslip'

    return {
        'code': code,
        'name': authority_name.upper(),
        'type': authority_type,
        'contact_email': contact_email,
        'verify_base_url': verify_base_url,
    }


def build_payload_from_run_item(cur, run_item, period_code: str, period_start: str, period_end: str, pay_date: str):
    run_item_id = run_item['run_item_id']
    employee_id = run_item['employee_id']
    employee_name = run_item['employee_name']
    authority = resolve_authority(cur, employee_id)

    cur.execute(
        """
        SELECT department, position
        FROM employees
        WHERE employee_id = ?
        LIMIT 1
        """,
        (employee_id,),
    )
    employee_row = cur.fetchone()
    department = (employee_row[0] or 'UNASSIGNED').upper() if employee_row else 'UNASSIGNED'
    position = (employee_row[1] or 'UNSPECIFIED POSITION') if employee_row else 'UNSPECIFIED POSITION'

    cur.execute(
        """
        SELECT allowance_code, allowance_name, amount
        FROM payroll_run_item_allowances
        WHERE run_item_id = ? AND COALESCE(visible_on_payslip,1) = 1
        ORDER BY item_allowance_id
        """,
        (run_item_id,),
    )
    allowances_rows = cur.fetchall()

    earnings_items = [
        {
            'code': 'BAS',
            'description': 'Basic Salary',
            'units': '1 month',
            'rate': None,
            'amount': float(run_item['basic_salary']),
            'taxable': True,
            'visibleOnPayslip': True,
        }
    ]

    for allowance_code, allowance_name, amount in allowances_rows:
        code = (allowance_code or 'ALW')[:4].upper()
        description = allowance_name or allowance_code or 'Allowance'
        taxable = 0 if (allowance_code or '').upper() in {'HOUSING', 'HOU'} else 1
        earnings_items.append(
            {
                'code': code,
                'description': description,
                'units': '1 month',
                'rate': None,
                'amount': float(amount or 0.0),
                'taxable': bool(taxable),
                'visibleOnPayslip': True,
            }
        )

    gross = float(run_item['gross_pay'] or 0.0)
    taxable_pay = float(run_item['taxable_pay'] or 0.0)
    non_taxable_pay = round(gross - taxable_pay, 2)
    napsa = float(run_item['napsa_amount'] or 0.0)
    nhima = float(run_item['nhis_amount'] or 0.0)
    paye = float(run_item['paye_amount'] or 0.0)
    total_deductions = float(run_item['deductions_total'] or 0.0)
    net = float(run_item['net_pay'] or 0.0)

    cur.execute(
        """
        SELECT deduction_code, deduction_name, deduction_category, authority_ref, amount
        FROM payroll_run_item_deductions
        WHERE run_item_id = ?
        ORDER BY item_deduction_id
        """,
        (run_item_id,),
    )
    deduction_items = [
        {
            'code': (code or '')[:10],
            'description': name or code or 'Deduction',
            'authorityRef': authority_ref or '',
            'amount': float(amount or 0.0),
            'category': category or 'OTHER',
        }
        for code, name, category, authority_ref, amount in cur.fetchall()
    ]
    statutory_total = round(sum(item['amount'] for item in deduction_items if (item['category'] or '').upper() == 'STATUTORY'), 2)
    other_total = round(sum(item['amount'] for item in deduction_items if (item['category'] or '').upper() != 'STATUTORY'), 2)

    period_norm = period_code.replace('-', '')
    serial = f"{run_item_id:05d}"
    payslip_no = f"PS-{authority['code']}-{period_norm}-{serial}"
    verify_code = payslip_no
    verify_url = f"{authority['verify_base_url']}?code={verify_code}"

    return {
        'header': {
            'authorityName': authority['name'],
            'authorityCode': authority['code'],
            'organizationType': authority['type'],
            'payrollBrand': 'LOCAL AUTHORITY PAYROLL',
            'logoUrl': '',
            'payslipNo': payslip_no,
            'verificationCode': verify_code,
            'payrollMonthLabel': period_code,
            'payPeriodStart': period_start,
            'payPeriodEnd': period_end,
            'issueDate': date.today().isoformat(),
            'currency': 'ZMW',
            'generatedAt': date.today().isoformat(),
            'printLabel': 'EMPLOYEE PAYSLIP',
        },
        'employee': {
            'employeeId': employee_id,
            'employeeNo': employee_id,
            'fullName': (employee_name or '').upper(),
            'department': department,
            'grade': run_item['salary_scale'] or 'N/A',
            'division': 'N/A',
            'notch': run_item['notch_no'] or 1,
            'employmentType': 'PERMANENT',
            'nrcMasked': '******/**/***',
            'tpinMasked': '***********',
            'napsaMasked': '*********',
            'nhimaMasked': '***********',
            'position': position,
        },
        'employer': {
            'authorityName': authority['name'],
            'authorityCode': authority['code'],
            'tpinMasked': '***********',
            'napsaMasked': '*********',
            'nhimaMasked': '***********',
            'address': '',
            'contactEmail': authority['contact_email'],
            'verificationBaseUrl': authority['verify_base_url'],
        },
        'earnings': {
            'items': earnings_items,
            'totalEarnings': gross,
            'taxableAllowances': round(max(taxable_pay - float(run_item['basic_salary'] or 0.0), 0.0), 2),
            'nonTaxableAllowances': round(max(non_taxable_pay, 0.0), 2),
        },
        'deductions': {
            'items': deduction_items,
            'totalStatutory': statutory_total,
            'totalOther': other_total,
            'totalDeductions': total_deductions,
        },
        'employerContributions': {
            'items': [],
            'totalEmployerContributions': 0.0,
        },
        'summary': {
            'basicSalary': float(run_item['basic_salary'] or 0.0),
            'grossSalary': gross,
            'taxablePay': taxable_pay,
            'nonTaxablePay': non_taxable_pay,
            'totalDeductions': total_deductions,
            'netPay': net,
        },
        'payment': {
            'method': 'EFT',
            'bankName': 'N/A',
            'accountMasked': '************',
            'reference': f'EFT-{period_norm}-{serial}',
            'valueDate': pay_date,
        },
        'leave': {
            'items': [{'leaveType': 'Annual Leave', 'balance': 0, 'unit': 'days', 'policyMax': 230}],
        },
        'verification': {
            'verificationCode': verify_code,
            'verifyUrl': verify_url,
            'qrPayload': verify_url,
            'signedAt': date.today().isoformat(),
            'signatureStatus': 'SIGNED',
        },
        'complianceNotes': [
            'Amounts are shown in gross, deductions and net format for transparency.',
            'Mandatory statutory deductions are itemized with legal authority references.',
            'Employee identifiers are masked for data privacy and confidentiality.',
            'Generated automatically after payroll run completion.',
        ],
    }


import json

def export_run_payslips(con, run_id: int, period_code: str, period_start: str, period_end: str, pay_date: str):
    con.row_factory = sqlite3.Row
    cur = con.cursor()
    cur.execute(
        """
        SELECT run_item_id, run_id, employee_id, employee_name, salary_scale, notch_no,
               basic_salary, allowances_total, gross_pay, taxable_pay, deductions_total, net_pay,
               paye_amount, napsa_amount, nhis_amount
        FROM payroll_run_items
        WHERE run_id = ?
        ORDER BY employee_name
        """,
        (run_id,),
    )
    run_items = cur.fetchall()

    year = int(period_code.split('-')[0])
    month = int(period_code.split('-')[1])

    exported = 0
    for run_item in run_items:
        payload = build_payload_from_run_item(cur, run_item, period_code, period_start, period_end, pay_date)
        authority_code = payload['header']['authorityCode']
        employee_id = run_item['employee_id'] or f"emp_{run_item['run_item_id']}"
        
        # 1. Export files
        stem = f"payslip_{sanitize_fragment(period_code)}_{sanitize_fragment(employee_id)}"
        out_dir = PAYSLIP_EXPORT_ROOT / sanitize_fragment(period_code) / sanitize_fragment(authority_code)
        emit_files(payload, out_dir, stem)
        
        # 2. Archive to database
        cur.execute(
            """
            INSERT INTO central_payslip_archive (
                employee_number, employee_name, period_year, period_month,
                basic_salary, total_allowances, total_deductions, net_pay,
                paye_amount, napsa_amount, nhis_amount,
                payment_date, payslip_generated_date, payslip_data
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                employee_id,
                run_item['employee_name'],
                year,
                month,
                run_item['basic_salary'],
                run_item['allowances_total'],
                run_item['deductions_total'],
                run_item['net_pay'],
                run_item['paye_amount'],
                run_item['napsa_amount'],
                run_item['nhis_amount'],
                pay_date,
                date.today().isoformat(),
                json.dumps(payload)
            )
        )
        
        exported += 1

    con.commit()
    return exported


def default_allowances_for_scale(scale_code: str):
    rules = [
        ('HOUSING', 'PERCENT_BASIC', 0.20),
        ('EDUCATION', 'PERCENT_BASIC', 0.20),
    ]
    if scale_code.startswith('LGSS'):
        num = int(scale_code.replace('LGSS', ''))
        if 1 <= num <= 3:
            rules.append(('FUEL', 'PERCENT_BASIC', 0.32))
        elif 4 <= num <= 18:
            rules.append(('TRANSPORT', 'PERCENT_BASIC', 0.17))
    elif scale_code in {'G1', 'G2', 'G3'}:
        rules.append(('TRANSPORT', 'PERCENT_BASIC', 0.17))
    return rules


def division_for_scale(scale_code: str) -> str:
    if scale_code.startswith('LGSS'):
        num = int(scale_code.replace('LGSS', ''))
        if 1 <= num <= 5:
            return 'DIVISION_I'
        if 6 <= num <= 8:
            return 'DIVISION_II'
        if 9 <= num <= 12:
            return 'DIVISION_III'
        return 'DIVISION_IV'
    if scale_code in {'G1', 'G2', 'G3'}:
        return 'DIVISION_I'
    return 'DIVISION_II'


def comprehensive_allowances_for_employee(cur, employee_id: str, scale_code: str, division: str, is_fire_officer: bool, month: int):
    union_code = union_for_employee(cur, employee_id, is_fire_officer)

    cur.execute("SELECT is_zapd_registered, handles_solid_waste, is_council_police FROM employees WHERE employee_id = ?", (employee_id,))
    meta = cur.fetchone()
    is_zapd = meta[0] if meta else 0
    is_solid_waste = meta[1] if meta else 0
    is_police = meta[2] if meta else 0

    rules = [
        ('HOU', 'PERCENT_BASIC', 0.20),
        ('EDU', 'PERCENT_BASIC', 0.20),
    ]

    # Special Allowance (ZAPD) replaces/supplements FUL/TRN
    if is_zapd:
        rules.append(('SPA', 'PERCENT_BASIC', 0.30))
    else:
        # Management Fuel/Transport (LGSS01-07)
        if scale_code.startswith('LGSS'):
            num = int(scale_code.replace('LGSS', ''))
            if 1 <= num <= 3:
                rules.append(('FUL', 'PERCENT_BASIC', 0.32))
            elif 4 <= num <= 7:
                rules.append(('TRN', 'PERCENT_BASIC', 0.20))
            # Standard unionized Transport (Div II-IV)
            elif division in {'DIVISION_II', 'DIVISION_III', 'DIVISION_IV'} and union_code in {'ZULAWAU', 'ZULAWU', 'FIRESUZ'}:
                rules.append(('TRN', 'PERCENT_BASIC', 0.20))

    # General Risk Allowance (Eligible employees get 5%)
    if is_solid_waste:
        rules.append(('RISK', 'PERCENT_BASIC', 0.05))
    elif division in {'DIVISION_II', 'DIVISION_III', 'DIVISION_IV'} and union_code in {'FIRESUZ', 'ZULAWAU', 'ZULAWU'}:
        rules.append(('RISK', 'PERCENT_BASIC', 0.05))

    if is_police and month == 1:
        rules.append(('UPKEEP', 'FIXED_AMOUNT', 240.00))

    if is_fire_officer and division in {'DIVISION_II', 'DIVISION_III'} and union_code == 'FIRESUZ':
        rules.append(('STANDBY', 'PERCENT_BASIC', 0.06))
        ration_pct = ration_percentage_for_scale(cur, scale_code)
        if ration_pct > 0:
            rules.append(('RATION', 'PERCENT_BASIC', ration_pct))

    return rules


def main(year: int, month: int):
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    ensure_payroll_obligation_schema(cur)

    period_start, period_end = month_bounds(year, month)
    period_code = f"{year}-{month:02d}"
    pay_date = period_end

    cur.execute(
        """
        INSERT INTO payroll_periods (period_code, start_date, end_date, pay_date, status)
        VALUES (?, ?, ?, ?, 'OPEN')
        ON CONFLICT(period_code) DO NOTHING
        """,
        (period_code, period_start.isoformat(), period_end.isoformat(), pay_date.isoformat()),
    )

    cur.execute("SELECT period_id FROM payroll_periods WHERE period_code = ?", (period_code,))
    period_id = cur.fetchone()[0]

    run_code = f"RUN-{period_code}"
    cur.execute(
        """
        INSERT INTO payroll_runs (period_id, run_code, run_status, notes)
        VALUES (?, ?, 'DRAFT', 'Basic payroll calculation run')
        """,
        (period_id, run_code),
    )
    run_id = cur.lastrowid

    napsa_rate = get_rate(cur, 'NAPSA')
    napsa_employer_rate = get_rate(cur, 'NAPSA_EMPLOYER')
    nhima_rate = get_rate(cur, 'NHIMA')
    nhima_employer_rate = get_rate(cur, 'NHIMA_EMPLOYER')

    cur.execute(
        """
        SELECT employee_id, name, salary_scale, COALESCE(position,'')
        FROM employees
        WHERE COALESCE(is_active,1) = 1 AND employee_id IS NOT NULL
        ORDER BY name
        """
    )
    employees = cur.fetchall()

    totals = {
        'employees': 0,
        'basic': 0.0,
        'allowances': 0.0,
        'gross': 0.0,
        'deductions': 0.0,
        'net': 0.0,
        'employer_obligations': 0.0,
    }

    for employee_id, name, raw_scale, position in employees:
        scale_code = normalize_scale(raw_scale)
        if not scale_code:
            continue
        division = division_for_scale(scale_code)
        is_fire_officer = 'fire' in (position or '').lower()

        cur.execute(
            """
            SELECT esn.notch_no
            FROM employee_salary_notch esn
            WHERE esn.employee_id = ? AND esn.is_active = 1
            ORDER BY esn.effective_from DESC LIMIT 1
            """,
            (employee_id,),
        )
        row = cur.fetchone()
        notch_no = int(row[0]) if row else 1

        basic_salary = get_basic_salary(cur, scale_code, notch_no)
        if basic_salary <= 0:
            continue

        allowance_lines = []
        for code, method, value in comprehensive_allowances_for_employee(cur, employee_id, scale_code, division, is_fire_officer, month):
            if method == 'PERCENT_BASIC':
                amount = round(basic_salary * float(value), 2)
            else:
                amount = float(value)
            allowance_name, taxable, show_on_payslip = get_allowance_meta(cur, code)
            allowance_lines.append((code, allowance_name, method, float(value), amount, taxable, show_on_payslip))

        cur.execute(
            """
            SELECT ea.allowance_code, ea.calc_method, ea.value
            FROM employee_allowances ea
            WHERE ea.employee_id = ? AND ea.is_active = 1
              AND (ea.effective_to IS NULL OR ea.effective_to >= ?)
            """,
            (employee_id, period_start.isoformat()),
        )
        for code, method, value in cur.fetchall():
            method_norm = (method or '').upper()
            if method_norm == 'PERCENT_BASIC':
                amount = round(basic_salary * float(value), 2)
            elif method_norm in {'FIXED_AMOUNT', 'VARIABLE'}:
                amount = float(value)
            else:
                continue
            allowance_name, taxable, show_on_payslip = get_allowance_meta(cur, code)
            allowance_lines.append((code, allowance_name, method, float(value), amount, taxable, show_on_payslip))

        allowances_total = round(sum(line[4] for line in allowance_lines), 2)
        taxable_allowances_total = round(sum(line[4] for line in allowance_lines if line[5] == 1), 2)
        gross_pay = round(basic_salary + allowances_total, 2)
        taxable_pay = round(basic_salary + taxable_allowances_total, 2)

        napsa = round(basic_salary * napsa_rate, 2)
        napsa_employer = round(basic_salary * napsa_employer_rate, 2)
        nhima = round(basic_salary * nhima_rate, 2)
        nhima_employer = round(basic_salary * nhima_employer_rate, 2)
        madison = round(basic_salary * 0.004, 2)
        paye = calculate_paye_2026(taxable_pay)
        extra_deductions = additional_employee_deductions(cur, employee_id, basic_salary)
        other_deductions_total = round(sum(row[6] for row in extra_deductions), 2)
        deductions_total = round(napsa + nhima + madison + paye + other_deductions_total, 2)
        net_pay = round(gross_pay - deductions_total, 2)

        cur.execute(
            """
            INSERT INTO payroll_run_items (
                run_id, employee_id, employee_name, salary_scale, notch_no,
                basic_salary, allowances_total, gross_pay, deductions_total, net_pay,
                taxable_pay, paye_amount, napsa_amount, nhis_amount
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                run_id,
                employee_id,
                name,
                scale_code,
                notch_no,
                basic_salary,
                allowances_total,
                gross_pay,
                deductions_total,
                net_pay,
                taxable_pay,
                paye,
                napsa,
                nhima,
            ),
        )
        run_item_id = cur.lastrowid

        for code, allowance_name, method, val, amount, _taxable, show_on_payslip in allowance_lines:
            cur.execute(
                """
                INSERT INTO payroll_run_item_allowances (
                    run_item_id, allowance_code, allowance_name, calc_method, calc_value, amount, visible_on_payslip
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                (run_item_id, code, allowance_name, method, val, amount, show_on_payslip),
            )

        cur.execute(
            """
            INSERT INTO payroll_run_item_deductions (
                run_item_id, deduction_code, deduction_name, deduction_category,
                authority_ref, calc_method, calc_value, amount
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (run_item_id, 'NAPSA', 'National Pension Scheme', 'STATUTORY', 'NAPSA Act No.40/1996', 'PERCENTAGE', 5.00, napsa),
        )
        cur.execute(
            """
            INSERT INTO payroll_run_item_deductions (
                run_item_id, deduction_code, deduction_name, deduction_category,
                authority_ref, calc_method, calc_value, amount
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (run_item_id, 'NHIS', 'National Health Insurance', 'STATUTORY', 'Health Insurance Act No.2/2018', 'PERCENTAGE', 1.00, nhima),
        )
        cur.execute(
            """
            INSERT INTO payroll_run_item_deductions (
                run_item_id, deduction_code, deduction_name, deduction_category,
                authority_ref, calc_method, calc_value, amount
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (run_item_id, 'PAYE', 'Pay As You Earn', 'STATUTORY', 'Income Tax Act (2026 bands)', 'FORMULA', None, paye),
        )
        cur.execute(
            """
            INSERT INTO payroll_run_item_deductions (
                run_item_id, deduction_code, deduction_name, deduction_category,
                authority_ref, calc_method, calc_value, amount
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (run_item_id, 'MADISON_0.4', 'Madison Funeral Policy (Base)', 'INSURANCE', 'Madison Insurance', 'PERCENTAGE', 0.40, madison),
        )

        for code, deduction_name, deduction_category, authority_ref, method, rate, amount in extra_deductions:
            cur.execute(
                """
                INSERT INTO payroll_run_item_deductions (
                    run_item_id, deduction_code, deduction_name, deduction_category,
                    authority_ref, calc_method, calc_value, amount
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (run_item_id, code, deduction_name, deduction_category, authority_ref, method, rate, amount),
            )

        if napsa_employer > 0 or napsa > 0:
            cur.execute(
                """
                INSERT INTO payroll_run_item_obligations (
                    run_item_id, employee_id, scheme_code, obligation_type,
                    employee_amount, employer_amount, total_amount, due_date, payment_status
                ) VALUES (?, ?, 'NAPSA', 'PENSION_CONTRIBUTION', ?, ?, ?, ?, 'PENDING')
                """,
                (
                    run_item_id,
                    employee_id,
                    napsa,
                    napsa_employer,
                    round(napsa + napsa_employer, 2),
                    pay_date.isoformat(),
                ),
            )

        if nhima_employer > 0 or nhima > 0:
            cur.execute(
                """
                INSERT INTO payroll_run_item_obligations (
                    run_item_id, employee_id, scheme_code, obligation_type,
                    employee_amount, employer_amount, total_amount, due_date, payment_status
                ) VALUES (?, ?, 'NHIMA', 'HEALTH_INSURANCE_CONTRIBUTION', ?, ?, ?, ?, 'PENDING')
                """,
                (
                    run_item_id,
                    employee_id,
                    nhima,
                    nhima_employer,
                    round(nhima + nhima_employer, 2),
                    pay_date.isoformat(),
                ),
            )

        totals['employees'] += 1
        totals['basic'] += basic_salary
        totals['allowances'] += allowances_total
        totals['gross'] += gross_pay
        totals['deductions'] += deductions_total
        totals['net'] += net_pay
        totals['employer_obligations'] += napsa_employer
        totals['employer_obligations'] += nhima_employer

    cur.execute(
        """
        UPDATE payroll_runs
        SET run_status = 'COMPLETED',
            processed_at = CURRENT_TIMESTAMP,
            total_employees = ?,
            total_basic = ?,
            total_allowances = ?,
            total_gross = ?,
            total_deductions = ?,
            total_net = ?
        WHERE run_id = ?
        """,
        (
            totals['employees'],
            round(totals['basic'], 2),
            round(totals['allowances'], 2),
            round(totals['gross'], 2),
            round(totals['deductions'], 2),
            round(totals['net'], 2),
            run_id,
        ),
    )

    con.commit()

    exported_payslips = export_run_payslips(
        con,
        run_id,
        period_code,
        period_start.isoformat(),
        period_end.isoformat(),
        pay_date.isoformat(),
    )

    print('Payroll run completed')
    print('run_id:', run_id, 'run_code:', run_code)
    print('employees:', totals['employees'])
    print('total_basic:', round(totals['basic'], 2))
    print('total_allowances:', round(totals['allowances'], 2))
    print('total_gross:', round(totals['gross'], 2))
    print('total_deductions:', round(totals['deductions'], 2))
    print('total_net:', round(totals['net'], 2))
    print('total_employer_obligations:', round(totals['employer_obligations'], 2))
    print('payslips_exported:', exported_payslips)
    print('payslip_output_root:', PAYSLIP_EXPORT_ROOT)

    con.close()


if __name__ == '__main__':
    today = date.today()
    main(today.year, today.month)
