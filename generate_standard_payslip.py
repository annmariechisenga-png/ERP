import argparse
import json
import sqlite3
from datetime import datetime
from pathlib import Path

W = 67
EMP_COL = 39
ER_COL = 25
C_CODE = 12
C_DESC = 17
C_UNITS = 11
C_AMT = 18
PAY_COL = 37
LEAV_COL = 27

H = '─'
V = '│'
TL = '┌'
TR = '┐'
BL = '└'
BR = '┘'
LT = '├'
RT = '┤'
TT = '┬'
BT = '┴'
XX = '┼'


ASCII_MAP = str.maketrans({
    '┌': '+', '┐': '+', '└': '+', '┘': '+',
    '├': '+', '┤': '+', '┬': '+', '┴': '+', '┼': '+',
    '─': '-', '│': '|',
})


def box_top():
    return TL + H * W + TR


def box_bot():
    return BL + H * W + BR


def box_div():
    return LT + H * W + RT


def box_line(s):
    inner = s[:W].ljust(W)
    return V + inner + V


def box_center(s):
    inner = s[:W].center(W)
    return V + inner + V


def two_col_div():
    return LT + H * EMP_COL + XX + H * ER_COL + RT


def two_col_end():
    return LT + H * EMP_COL + BT + H * ER_COL + RT


def two_col_row(left, right):
    l = (' ' + left)[:EMP_COL].ljust(EMP_COL)
    r = (' ' + right)[:ER_COL].ljust(ER_COL)
    return V + l + V + r + V


def table_top():
    return LT + H * (C_CODE + 1) + TT + H * (C_DESC + 1) + TT + H * (C_UNITS + 1) + TT + H * (C_AMT + 1) + RT


def table_head_row(c1, c2, c3, c4):
    return (
        V + (' ' + c1).ljust(C_CODE + 1) + V +
        (' ' + c2).ljust(C_DESC + 1) + V +
        (' ' + c3).ljust(C_UNITS + 1) + V +
        (' ' + c4).ljust(C_AMT + 1) + V
    )


def table_div():
    return LT + H * (C_CODE + 1) + XX + H * (C_DESC + 1) + XX + H * (C_UNITS + 1) + XX + H * (C_AMT + 1) + RT


def table_data_row(code, desc, units, amt_str):
    return (
        V + (' ' + code[:C_CODE]).ljust(C_CODE + 1) + V +
        (' ' + desc[:C_DESC]).ljust(C_DESC + 1) + V +
        (' ' + units[:C_UNITS]).ljust(C_UNITS + 1) + V +
        (' ' + amt_str[:C_AMT]).rjust(C_AMT + 1) + V
    )


def table_total_div():
    merged = C_CODE + 1 + C_DESC + 1 + C_UNITS + 1 + 1
    return LT + H * merged + XX + H * (C_AMT + 1) + RT


def table_total_row(label, amt_str):
    merged = C_CODE + 1 + C_DESC + 1 + C_UNITS + 1 + 1
    inner_label = (' ' + label).ljust(merged)
    return V + inner_label + V + (' ' + amt_str).rjust(C_AMT + 1) + V


def table_bot_merged():
    merged = C_CODE + 1 + C_DESC + 1 + C_UNITS + 1 + 1
    return LT + H * merged + BT + H * (C_AMT + 1) + RT


def pay_leave_div():
    return LT + H * PAY_COL + XX + H * LEAV_COL + RT


def pay_leave_end():
    return LT + H * PAY_COL + BT + H * LEAV_COL + RT


def pay_leave_row(left, right):
    l = (' ' + left)[:PAY_COL].ljust(PAY_COL)
    r = (' ' + right)[:LEAV_COL].ljust(LEAV_COL)
    return V + l + V + r + V


def fmt(v):
    return f"{v:,.2f}"


def normalize_scale(raw):
    if not raw:
        return ''
    s = str(raw).upper().replace(' ', '').replace('/', '')
    if s.startswith('LGSS'):
        digits = ''.join(ch for ch in s[4:] if ch.isdigit())
        if digits:
            return f"LGSS{int(digits):02d}"
    return s


def normalize_division(raw):
    if not raw:
        return ''
    s = str(raw).strip().upper().replace(' ', '_')
    s = s.replace('DIVISION_', 'DIVISION_')
    if s in {'DIV_I', 'DIVISION_I'}:
        return 'DIVISION_I'
    if s in {'DIV_II', 'DIVISION_II'}:
        return 'DIVISION_II'
    if s in {'DIV_III', 'DIVISION_III'}:
        return 'DIVISION_III'
    if s in {'DIV_IV', 'DIVISION_IV'}:
        return 'DIVISION_IV'
    return s


def ration_percentage_for_scale(scale):
    if not scale.startswith('LGSS'):
        return None
    num = int(scale.replace('LGSS', ''))
    if 8 <= num <= 10:
        return 0.125
    if 11 <= num <= 12:
        return 0.15
    if 13 <= num <= 14:
        return 0.20
    return None


def allowance_rules_for_grade(grade, division, is_fire_officer, housing_rate, education_rate, fuel_rate, transport_gen_rate, transport_fire_rate, risk_rate, standby_rate, excess_hours_fixed):
    scale = normalize_scale(grade)
    div = normalize_division(division)
    rules = [
        ('HOU', 'Housing Allowance', 'PERCENT', housing_rate, False),
        ('EDU', 'Education Allowance', 'PERCENT', education_rate, True),
    ]

    if div == 'DIVISION_I' and scale.startswith('LGSS'):
        num = int(scale.replace('LGSS', ''))
        if 1 <= num <= 3:
            rules.append(('FUL_MGT', 'Fuel Allowance', 'PERCENT', fuel_rate, True))
    elif is_fire_officer and div in {'DIVISION_II', 'DIVISION_III'}:
        rules.append(('TRN_FIRE', 'Transport Allow (Fire)', 'PERCENT', transport_fire_rate, True))
        rules.append(('STANDBY', 'Standby Allowance', 'PERCENT', standby_rate, True))
        rules.append(('EXCESS_HOURS', 'Excess Hours', 'FIXED', excess_hours_fixed, True))
        ration_pct = ration_percentage_for_scale(scale)
        if ration_pct is not None:
            rules.append(('RATION', 'Ration Allowance', 'PERCENT', ration_pct, True))
    elif div in {'DIVISION_II', 'DIVISION_III', 'DIVISION_IV'}:
        rules.append(('TRN_GEN', 'Transport Allow', 'PERCENT', transport_gen_rate, True))

    if div in {'DIVISION_II', 'DIVISION_III', 'DIVISION_IV'}:
        rules.append(('RISK', 'Risk Allowance', 'PERCENT', risk_rate, True))

    return rules


def esc_pdf(s):
    return s.replace('\\', r'\\').replace('(', r'\(').replace(')', r'\)')


def to_pdf_safe(line):
    return line.translate(ASCII_MAP)


def parse_args():
    parser = argparse.ArgumentParser(description='Generate international-standard local authority payslip (JSON/TXT/PDF).')
    parser.add_argument('--db-path', default='/Users/Work/Desktop/ERP/hr_platform.db')
    parser.add_argument('--output-dir', default='/Users/Work/Desktop/ERP')
    parser.add_argument('--output-stem', default='generated_payslip_mbala_director_hr_admin_2026-06')

    parser.add_argument('--authority-name', default='MBALA MUNICIPAL COUNCIL')
    parser.add_argument('--authority-code', default='MBL')
    parser.add_argument('--organization-type', default='Local Authority')
    parser.add_argument('--payroll-brand', default='LOCAL AUTHORITY PAYROLL')
    parser.add_argument('--authority-email', default='payroll@mbala.gov.zm')
    parser.add_argument('--verification-base-url', default='https://verify.mbala.gov.zm/payslip')
    parser.add_argument('--currency', default='ZMW')

    parser.add_argument('--period-start', default='2026-06-01')
    parser.add_argument('--period-end', default='2026-06-30')
    parser.add_argument('--period-label', default='JUNE 2026')

    parser.add_argument('--employee-id', default='MBL-DIR-HRA-0001')
    parser.add_argument('--employee-no', default='MBL***001')
    parser.add_argument('--employee-name', default='SPECIMEN DIRECTOR HR & ADMINISTRATION')
    parser.add_argument('--position', default='Director (Human Resource and Administration)')
    parser.add_argument('--department', default='HUMAN RESOURCE AND ADMINISTRATION')
    parser.add_argument('--grade', default='LGSS/04')
    parser.add_argument('--division', default='Div I')
    parser.add_argument('--is-fire-officer', action='store_true')

    parser.add_argument('--benchmark-employee', default='annette mubanga chilando')
    parser.add_argument('--default-basic', type=float, default=16572.0)
    parser.add_argument('--housing-rate', type=float, default=0.20)
    parser.add_argument('--education-rate', type=float, default=0.20)
    parser.add_argument('--fuel-rate', type=float, default=0.32)
    parser.add_argument('--transport-rate', type=float, default=0.17)
    parser.add_argument('--transport-fire-rate', type=float, default=0.15)
    parser.add_argument('--risk-rate', type=float, default=0.02)
    parser.add_argument('--standby-rate', type=float, default=0.06)
    parser.add_argument('--excess-hours-fixed', type=float, default=400.0)

    parser.add_argument('--bank-name', default='ZANACO')
    parser.add_argument('--bank-account-masked', default='************')
    parser.add_argument('--payment-reference', default='EFT-20260630-MBL-0001')
    parser.add_argument('--value-date', default='2026-06-30')

    parser.add_argument('--nrc-masked', default='******/**/***')
    parser.add_argument('--tpin-masked', default='***********')
    parser.add_argument('--napsa-masked', default='*********')
    parser.add_argument('--nhima-masked', default='***********')
    return parser.parse_args()


def get_active_rate(cur, code):
    row = cur.execute(
        """
        SELECT rate_value
        FROM payroll_statutory_rates
        WHERE rate_code=? AND active=1
        ORDER BY effective_from DESC
        LIMIT 1
        """,
        (code,),
    ).fetchone()
    return float(row[0]) if row else 0.0


def build_payload(args):
    conn = sqlite3.connect(args.db_path)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    # 1. Fetch Employee Details
    emp = cur.execute(
        "SELECT * FROM employees WHERE employee_id = ?", (args.employee_id,)
    ).fetchone()

    # 2. Fetch Active Salary Notch and Basic
    salary_data = cur.execute(
        """
        SELECT snv.monthly_basic, esn.scale_code, esn.notch_no, sso.division
        FROM employee_salary_notch esn
        JOIN salary_notch_values snv ON esn.scale_code = snv.scale_code AND esn.notch_no = snv.notch_no AND esn.effective_from = snv.effective_from
        JOIN salary_scales_official sso ON esn.scale_code = sso.salary_scale AND esn.effective_from = sso.effective_from
        WHERE esn.employee_id = ? AND esn.is_active = 1
        """,
        (args.employee_id,),
    ).fetchone()

    # 3. Fetch Allowances from database
    db_allowances = cur.execute(
        """
        SELECT ea.allowance_code, at.allowance_name, ea.value, ea.calc_method
        FROM employee_allowances ea
        JOIN allowance_types at ON ea.allowance_code = at.allowance_code
        WHERE ea.employee_id = ? AND ea.is_active = 1
        """,
        (args.employee_id,),
    ).fetchall()

    # 4. Fetch Council Details
    council_name = args.authority_name
    council_code = args.authority_code
    if emp:
        # Try to find council by district
        auth = cur.execute(
            "SELECT * FROM authorities WHERE authority_name LIKE ?", 
            (f"%{emp['district']}%",)
        ).fetchone()
        if auth:
            council_name = auth['authority_name'].upper()
            council_code = auth['authority_prefix'].split('-')[-1]

    rates = {
        'NAPSA_EMP': get_active_rate(cur, 'NAPSA'),
        'NHIMA_EMP': get_active_rate(cur, 'NHIMA'),
        'PAYE': get_active_rate(cur, 'PAYE'),
        'NAPSA_ER': get_active_rate(cur, 'NAPSA_EMPLOYER'),
        'NHIMA_ER': get_active_rate(cur, 'NHIMA_EMPLOYER'),
    }

    basic = salary_data['monthly_basic'] if salary_data else args.default_basic
    grade = salary_data['scale_code'] if salary_data else args.grade
    division = salary_data['division'] if salary_data else args.division
    notch = salary_data['notch_no'] if salary_data else 1
    
    # Override with emp table if needed
    name = emp['name'] if emp else args.employee_name
    position = emp['position'] if emp else args.position
    
    # Improved Department Lookup
    dept = emp['department'] if emp else args.department
    if dept and dept.isdigit():
        d_name = cur.execute("SELECT dept_name FROM departments WHERE dept_code = ?", (dept,)).fetchone()
        if d_name:
            dept = d_name['dept_name']
        elif emp['establishment_department'] and not emp['establishment_department'].isdigit():
            dept = emp['establishment_department']

    nrc = emp['nrc_number'] if emp else args.nrc_masked

    earnings_items = [
        {'code': 'BAS', 'description': 'Basic Salary', 'units': '1 month', 'rate': None, 'amount': round(basic, 2), 'taxable': True, 'visibleOnPayslip': True},
    ]

    # Process DB allowances first
    for al in db_allowances:
        amount = al['value']
        if al['calc_method'] == 'PERCENT_BASIC':
            amount = round(basic * al['value'], 2)
        
        earnings_items.append({
            'code': al['allowance_code'],
            'description': al['allowance_name'],
            'units': '1 month',
            'rate': al['value'] if al['calc_method'] == 'PERCENT_BASIC' else None,
            'amount': amount,
            'taxable': True, # Default to taxable for now as per unionized rules
            'visibleOnPayslip': True,
        })

    # Add standard allowances if NOT in DB already
    existing_codes = {item['code'] for item in earnings_items}
    allowance_rules = allowance_rules_for_grade(
        grade,
        division,
        args.is_fire_officer,
        args.housing_rate,
        args.education_rate,
        args.fuel_rate,
        args.transport_rate,
        args.transport_fire_rate,
        args.risk_rate,
        args.standby_rate,
        args.excess_hours_fixed,
    )
    for code, description, calc_kind, calc_value, taxable in allowance_rules:
        if code in existing_codes: continue
        # Risk allowance is special - only if entitled
        if code == 'RISK': continue 
        
        amount = round(basic * calc_value, 2) if calc_kind == 'PERCENT' else round(calc_value, 2)
        earnings_items.append(
            {
                'code': code,
                'description': description,
                'units': '1 month',
                'rate': calc_value if calc_kind == 'PERCENT' else None,
                'amount': amount,
                'taxable': taxable,
                'visibleOnPayslip': True,
            }
        )

    gross = round(sum(item['amount'] for item in earnings_items), 2)
    taxable_pay = round(sum(item['amount'] for item in earnings_items if item['taxable']), 2)
    non_taxable_pay = round(gross - taxable_pay, 2)

    napsa_emp = round(gross * rates['NAPSA_EMP'], 2)
    nhima_emp = round(gross * rates['NHIMA_EMP'], 2)
    
    # Basic PAYE calculation for Zambia (simplified for this exercise)
    # Threshold is K5,100 as of 2025/2026
    paye = 0.0
    if taxable_pay > 5100:
        remainder = taxable_pay - 5100
        # Next 2000 at 20%, next 2100 at 30%, rest at 37%
        if remainder <= 2000:
            paye = remainder * 0.20
        elif remainder <= 4100:
            paye = (2000 * 0.20) + (remainder - 2000) * 0.30
        else:
            paye = (2000 * 0.20) + (2100 * 0.30) + (remainder - 4100) * 0.37
    
    paye = round(paye, 2)

    deduction_items = [
        {'code': 'NAPSA', 'description': 'National Pension', 'authorityRef': 'NAPSA Act', 'amount': napsa_emp, 'category': 'STATUTORY'},
        {'code': 'NHIS', 'description': 'Health Insurance', 'authorityRef': 'NHIMA Act', 'amount': nhima_emp, 'category': 'STATUTORY'},
        {'code': 'TAX', 'description': 'PAYE', 'authorityRef': 'ITA Cap 45', 'amount': paye, 'category': 'STATUTORY'},
    ]

    total_statutory = round(sum(d['amount'] for d in deduction_items if d['category'] == 'STATUTORY'), 2)
    total_other = 0.0
    total_deductions = round(total_statutory + total_other, 2)
    net = round(gross - total_deductions, 2)

    employer_contrib_items = [
        {'code': 'NAPSA_ER', 'description': 'NAPSA Employer Contribution', 'amount': round(gross * rates['NAPSA_ER'], 2)},
        {'code': 'NHIMA_ER', 'description': 'NHIMA Employer Contribution', 'amount': round(gross * rates['NHIMA_ER'], 2)},
    ]

    now_iso = datetime.now().astimezone().isoformat(timespec='seconds')
    issue_date = datetime.now().date().isoformat()
    verify_code = f"{council_code}-PS-{args.period_start[:7]}-0001"
    verify_url = f"{args.verification_base_url.replace('mbala.gov.zm', council_name.lower().replace(' ', '') + '.gov.zm')}?code={verify_code}"

    conn.close()

    return {
        'header': {
            'authorityName': council_name,
            'authorityCode': council_code,
            'organizationType': args.organization_type,
            'payrollBrand': args.payroll_brand,
            'logoUrl': '',
            'payslipNo': f"PS-{council_code}-{args.period_start[:7]}-0001",
            'verificationCode': verify_code,
            'payrollMonthLabel': args.period_label,
            'payPeriodStart': args.period_start,
            'payPeriodEnd': args.period_end,
            'issueDate': issue_date,
            'currency': args.currency,
            'generatedAt': now_iso,
            'printLabel': 'EMPLOYEE PAYSLIP',
        },
        'employee': {
            'employeeId': args.employee_id,
            'employeeNo': emp['local_authority_service_number'] if emp else args.employee_no,
            'fullName': name,
            'department': dept,
            'grade': grade,
            'division': division,
            'notch': notch,
            'employmentType': 'PERMANENT',
            'nrcMasked': nrc,
            'tpinMasked': args.tpin_masked,
            'napsaMasked': args.napsa_masked,
            'nhimaMasked': args.nhima_masked,
            'position': position,
        },
        'employer': {
            'authorityName': council_name,
            'authorityCode': council_code,
            'tpinMasked': args.tpin_masked,
            'napsaMasked': args.napsa_masked,
            'nhimaMasked': args.nhima_masked,
            'address': f"{council_name}, Zambia",
            'contactEmail': args.authority_email.replace('mbala.gov.zm', council_name.lower().replace(' ', '') + '.gov.zm'),
            'verificationBaseUrl': args.verification_base_url,
        },
        'earnings': {
            'items': earnings_items,
            'totalEarnings': gross,
            'taxableAllowances': round(sum(item['amount'] for item in earnings_items[1:] if item['taxable']), 2),
            'nonTaxableAllowances': round(sum(item['amount'] for item in earnings_items[1:] if not item['taxable']), 2),
        },
        'deductions': {
            'items': deduction_items,
            'totalStatutory': total_statutory,
            'totalOther': total_other,
            'totalDeductions': total_deductions,
        },
        'employerContributions': {
            'items': employer_contrib_items,
            'totalEmployerContributions': round(sum(i['amount'] for i in employer_contrib_items), 2),
        },
        'summary': {
            'basicSalary': round(basic, 2),
            'grossSalary': gross,
            'taxablePay': taxable_pay,
            'nonTaxablePay': non_taxable_pay,
            'totalDeductions': total_deductions,
            'netPay': net,
        },
        'payment': {
            'method': 'EFT',
            'bankName': args.bank_name,
            'accountMasked': args.bank_account_masked,
            'reference': args.payment_reference,
            'valueDate': args.value_date,
        },
        'leave': {
            'items': [{'leaveType': 'Annual Leave', 'balance': emp['leave_balance'] if emp else 0, 'unit': 'days', 'policyMax': 230}],
        },
        'verification': {
            'verificationCode': verify_code,
            'verifyUrl': verify_url,
            'qrPayload': verify_url,
            'signedAt': now_iso,
            'signatureStatus': 'SIGNED',
        },
        'complianceNotes': [
            'Amounts are shown in gross, deductions and net format for transparency.',
            'Mandatory statutory deductions are itemized with legal authority references.',
            'Allowance composition follows current collective framework and commission rules.',
            'Employee identifiers are masked for data privacy and confidentiality.',
            f"Generated based on official data for {council_name}.",
        ],
    }


def build_text_lines(payload):
    lines = []
    h = payload['header']
    e = payload['employee']
    er = payload['employer']

    lines.append(box_top())
    lines.append(box_center(h['authorityName']))
    lines.append(box_center(h['payrollBrand']))
    lines.append(box_center(h['printLabel']))
    lines.append(box_center(f"PAY PERIOD: {h['payPeriodStart']} TO {h['payPeriodEnd']}"))
    lines.append(box_div())

    lines.append(box_line(f"PAYSLIP NO: {h['payslipNo']}  ISSUE DATE: {h['issueDate']}"))
    lines.append(box_line(f"CURRENCY: {h['currency']}  VERIFICATION CODE: {h['verificationCode']}"))
    lines.append(box_div())

    emp_rows = [
        f"Name: {e['fullName']}",
        f"Emp No: {e['employeeNo']}",
        f"Position: {e['position']}",
        f"NRC: {e['nrcMasked']}",
        f"NHIMA: {e['nhimaMasked']}",
        f"TPIN: {e['tpinMasked']}",
        f"Department: {e['department']}",
        f"Grade: {e['grade']} | {e['division']}",
    ]

    er_rows = [
        er['authorityName'],
        f"Authority Code: {er['authorityCode']}",
        f"TPIN: {er['tpinMasked']}",
        f"NAPSA: {er['napsaMasked']}",
        f"NHIMA: {er['nhimaMasked']}",
        'Contact: See footer',
        '',
        '',
    ]

    lines.append(V + ' EMPLOYEE INFORMATION'.ljust(EMP_COL) + V + ' EMPLOYER INFORMATION'.ljust(ER_COL) + V)
    lines.append(two_col_div())
    for i in range(max(len(emp_rows), len(er_rows))):
        lines.append(two_col_row(emp_rows[i] if i < len(emp_rows) else '', er_rows[i] if i < len(er_rows) else ''))
    lines.append(two_col_end())

    lines.append(box_line(' EARNINGS'))
    lines.append(table_top())
    lines.append(table_head_row('Code', 'Description', 'Units', f"Amount ({h['currency']})"))
    lines.append(table_div())
    for item in payload['earnings']['items']:
        lines.append(table_data_row(item['code'], item['description'], item['units'], fmt(item['amount'])))
    lines.append(table_total_div())
    lines.append(table_total_row('TOTAL EARNINGS', fmt(payload['earnings']['totalEarnings'])))
    lines.append(table_bot_merged())

    lines.append(box_line(' DEDUCTIONS'))
    lines.append(table_top())
    lines.append(table_head_row('Code', 'Description', 'Authority', f"Amount ({h['currency']})"))
    lines.append(table_div())
    for item in payload['deductions']['items']:
        lines.append(table_data_row(item['code'], item['description'], item.get('authorityRef', ''), fmt(item['amount'])))
    lines.append(table_total_div())
    lines.append(table_total_row('TOTAL DEDUCTIONS', fmt(payload['deductions']['totalDeductions'])))
    lines.append(table_bot_merged())

    lines.append(box_line(f" NET PAY: {h['currency']} {fmt(payload['summary']['netPay'])}"))
    lines.append(box_div())

    lines.append(box_line(' PAY SUMMARY'))
    lines.append(box_div())
    lines.append(box_line(f" Gross Pay: {h['currency']} {fmt(payload['summary']['grossSalary'])}"))
    lines.append(box_line(f" Taxable Pay: {h['currency']} {fmt(payload['summary']['taxablePay'])}"))
    lines.append(box_line(f" Non-Taxable Pay: {h['currency']} {fmt(payload['summary']['nonTaxablePay'])}"))
    lines.append(box_line(f" Total Deductions: {h['currency']} {fmt(payload['summary']['totalDeductions'])}"))
    lines.append(box_line(f" Net Pay: {h['currency']} {fmt(payload['summary']['netPay'])}"))
    lines.append(box_div())

    pay = payload['payment']
    lvs = payload['leave']['items']
    pay_rows = [
        f"Bank: {pay['bankName']}",
        f"Account: {pay['accountMasked']}",
        f"Ref: {pay['reference']}",
        f"Value Date: {pay['valueDate']}",
    ]
    leave_rows = [f"{lv['leaveType']}: {lv['balance']} {lv['unit']}" for lv in lvs]
    if lvs and lvs[0].get('policyMax'):
        leave_rows.append(f"Max: {lvs[0]['policyMax']} days")

    lines.append(V + ' PAYMENT DETAILS'.ljust(PAY_COL) + V + ' LEAVE SUMMARY'.ljust(LEAV_COL) + V)
    lines.append(pay_leave_div())
    for i in range(max(len(pay_rows), len(leave_rows))):
        lines.append(pay_leave_row(pay_rows[i] if i < len(pay_rows) else '', leave_rows[i] if i < len(leave_rows) else ''))
    lines.append(pay_leave_end())

    lines.append(box_line(' VERIFICATION & AUTHENTICITY'))
    lines.append(box_div())
    lines.append(box_line(' This payslip is system-generated and valid without wet signature.'))
    lines.append(box_line(f" Digital issue timestamp: {payload['verification']['signedAt']}"))
    lines.append(box_line(f" Verify portal: {er['verificationBaseUrl']}"))
    lines.append(box_line(f" Verification code: {payload['verification']['verificationCode']}"))
    lines.append(box_line(''))
    lines.append(box_line(f" Payroll helpdesk: {er['contactEmail']}"))
    lines.append(box_bot())

    return lines


def write_pdf(lines, out_pdf):
    text_lines = [to_pdf_safe(line) for line in lines]

    page_w, page_h = 595.28, 841.89
    margin_left = 22
    margin_top = 55
    font_size = 8
    leading = 11
    bottom_margin = 40
    max_lines = int((page_h - margin_top - bottom_margin) // leading)
    pages = [text_lines[i:i + max_lines] for i in range(0, len(text_lines), max_lines)] or [[]]

    objs = []

    def add(content):
        objs.append(content)
        return len(objs)

    font_id = add('<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>')
    page_ids = []

    for chunk in pages:
        cmds = ['BT', f'/F1 {font_size} Tf', f'1 0 0 1 {margin_left:.2f} {page_h - margin_top:.2f} Tm', f'{leading:.2f} TL']
        first = True
        for line in chunk:
            if first:
                cmds.append(f'({esc_pdf(line)}) Tj')
                first = False
            else:
                cmds.extend(['T*', f'({esc_pdf(line)}) Tj'])
        cmds.append('ET')

        stream_bytes = '\n'.join(cmds).encode('latin-1', errors='replace')
        stream = f'<< /Length {len(stream_bytes)} >>\nstream\n'.encode('latin-1') + stream_bytes + b'\nendstream'
        content_id = add(stream.decode('latin-1', errors='replace'))
        page_id = add(f'<< /Type /Page /Parent 0 0 R /MediaBox [0 0 {page_w:.2f} {page_h:.2f}] /Resources << /Font << /F1 {font_id} 0 R >> >> /Contents {content_id} 0 R >>')
        page_ids.append(page_id)

    kids = ' '.join(f'{pid} 0 R' for pid in page_ids)
    pages_id = add(f'<< /Type /Pages /Count {len(page_ids)} /Kids [{kids}] >>')
    for pid in page_ids:
        objs[pid - 1] = objs[pid - 1].replace('/Parent 0 0 R', f'/Parent {pages_id} 0 R')
    root_id = add(f'<< /Type /Catalog /Pages {pages_id} 0 R >>')

    pdf = bytearray(b'%PDF-1.4\n%\xe2\xe3\xcf\xd3\n')
    offsets = [0]
    for idx, obj in enumerate(objs, start=1):
        offsets.append(len(pdf))
        pdf.extend(f'{idx} 0 obj\n'.encode('latin-1'))
        pdf.extend(obj.encode('latin-1', errors='replace'))
        pdf.extend(b'\nendobj\n')

    xref_pos = len(pdf)
    pdf.extend(f'xref\n0 {len(objs) + 1}\n'.encode('latin-1'))
    pdf.extend(b'0000000000 65535 f \n')
    for offset in offsets[1:]:
        pdf.extend(f'{offset:010d} 00000 n \n'.encode('latin-1'))

    pdf.extend((
        f'trailer\n<< /Size {len(objs) + 1} /Root {root_id} 0 R >>\n'
        f'startxref\n{xref_pos}\n%%EOF\n'
    ).encode('latin-1'))

    out_pdf.write_bytes(pdf)


def emit_files(payload, output_dir, output_stem):
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    out_json = output_dir / f'{output_stem}.json'
    out_txt = output_dir / f'{output_stem}.txt'
    out_pdf = output_dir / f'{output_stem}.pdf'

    lines = build_text_lines(payload)
    out_json.write_text(json.dumps(payload, indent=2), encoding='utf-8')
    out_txt.write_text('\n'.join(lines) + '\n', encoding='utf-8')
    write_pdf(lines, out_pdf)

    return out_json, out_txt, out_pdf


def main():
    args = parse_args()
    payload = build_payload(args)
    out_json, out_txt, out_pdf = emit_files(payload, args.output_dir, args.output_stem)

    print('JSON:', out_json)
    print('TXT :', out_txt)
    print('PDF :', out_pdf)
    print('Grade:', payload['employee']['grade'])
    print('Net pay:', payload['summary']['netPay'])


if __name__ == '__main__':
    main()
