"""
Regenerate payslip specimen for Mbala Municipal Council - Director (HR & Administration).
Layout follows a reusable international-standard local authority payslip format.
"""
import json
import sqlite3
from pathlib import Path
from datetime import datetime

# ── layout constants ─────────────────────────────────────────────
W = 67          # total inner width (between outer │ chars)
EMP_COL = 39    # employee info left column width
ER_COL  = 25    # employer info right column width (EMP_COL + 1(┼) + ER_COL + 2 outer = 67)
# earnings / deductions table columns (inner content widths, excl leading space)
C_CODE  = 12    # code column content
C_DESC  = 17    # description column content
C_UNITS = 11    # units/authority column content
C_AMT   = 18    # amount column content (right-aligned)
# payment | leave split
PAY_COL  = 37
LEAV_COL = 27

H = '─'
V = '│'
TL='┌'; TR='┐'; BL='└'; BR='┘'
LT='├'; RT='┤'; TT='┬'; BT='┴'; XX='┼'


def box_top():      return TL + H*W + TR
def box_bot():      return BL + H*W + BR
def box_div():      return LT + H*W + RT
def box_line(s):
    inner = s[:W].ljust(W)
    return V + inner + V
def box_center(s):
    inner = s[:W].center(W)
    return V + inner + V
def two_col_div():
    return LT + H*EMP_COL + XX + H*ER_COL + RT
def two_col_end():
    return LT + H*EMP_COL + BT + H*ER_COL + RT
def two_col_row(left, right):
    l = (' ' + left)[:EMP_COL].ljust(EMP_COL)
    r = (' ' + right)[:ER_COL].ljust(ER_COL)
    return V + l + V + r + V
def table_top():
    return LT + H*(C_CODE+1) + TT + H*(C_DESC+1) + TT + H*(C_UNITS+1) + TT + H*(C_AMT+1) + RT
def table_head_row(c1, c2, c3, c4):
    return (V + (' '+c1).ljust(C_CODE+1) + V +
                (' '+c2).ljust(C_DESC+1) + V +
                (' '+c3).ljust(C_UNITS+1) + V +
                (' '+c4).ljust(C_AMT+1) + V)
def table_div():
    return LT + H*(C_CODE+1) + XX + H*(C_DESC+1) + XX + H*(C_UNITS+1) + XX + H*(C_AMT+1) + RT
def table_data_row(code, desc, units, amt_str):
    return (V + (' '+code[:C_CODE]).ljust(C_CODE+1) + V +
                (' '+desc[:C_DESC]).ljust(C_DESC+1) + V +
                (' '+units[:C_UNITS]).ljust(C_UNITS+1) + V +
                (' '+amt_str[:C_AMT]).rjust(C_AMT+1) + V)
def table_total_div():
    # merges first 3 cols, leaves amount col separate
    merged = C_CODE + 1 + C_DESC + 1 + C_UNITS + 1 + 1   # +1 for leading space in cells
    return LT + H*merged + XX + H*(C_AMT+1) + RT
def table_total_row(label, amt_str):
    merged = C_CODE + 1 + C_DESC + 1 + C_UNITS + 1 + 1
    inner_label = (' ' + label).ljust(merged)
    return V + inner_label + V + (' '+amt_str).rjust(C_AMT+1) + V
def table_bot_merged():
    merged = C_CODE + 1 + C_DESC + 1 + C_UNITS + 1 + 1
    return LT + H*merged + BT + H*(C_AMT+1) + RT
def pay_leave_div():
    return LT + H*PAY_COL + XX + H*LEAV_COL + RT
def pay_leave_end():
    return LT + H*PAY_COL + BT + H*LEAV_COL + RT
def pay_leave_row(left, right):
    l = (' ' + left)[:PAY_COL].ljust(PAY_COL)
    r = (' ' + right)[:LEAV_COL].ljust(LEAV_COL)
    return V + l + V + r + V

def fmt(v):
    return f"{v:,.2f}"

root = Path('/Users/Work/Desktop/ERP')
db = root / 'hr_platform.db'
out_json = root / 'generated_payslip_mbala_director_hr_admin_2026-06.json'
out_txt = root / 'generated_payslip_mbala_director_hr_admin_2026-06.txt'
out_pdf = root / 'generated_payslip_mbala_director_hr_admin_2026-06.pdf'

conn = sqlite3.connect(str(db))
cur = conn.cursor()


def get_rate(code):
    row = cur.execute(
        """
        SELECT rate_value FROM payroll_statutory_rates
        WHERE rate_code=? AND active=1
        ORDER BY effective_from DESC
        LIMIT 1
        """,
        (code,),
    ).fetchone()
    return float(row[0]) if row else 0.0


rates = {
    'NAPSA_EMP': get_rate('NAPSA'),
    'NHIMA_EMP': get_rate('NHIMA'),
    'PAYE': get_rate('PAYE'),
    'NAPSA_ER': get_rate('NAPSA_EMPLOYER'),
    'NHIMA_ER': get_rate('NHIMA_EMPLOYER'),
}

bench = cur.execute(
    """
    SELECT basic_salary
    FROM payroll_run_items
    WHERE lower(employee_name)='annette mubanga chilando'
    ORDER BY run_id DESC
    LIMIT 1
    """
).fetchone()

conn.close()

basic = float(bench[0]) if bench else 16572.00
housing = round(basic * 0.25, 2)
transport = round(basic * 0.10, 2)
responsibility = round(basic * 0.15, 2)

earnings_items = [
    {'code': 'BAS', 'description': 'Basic Salary', 'units': '1 month', 'rate': None, 'amount': round(basic, 2), 'taxable': True, 'visibleOnPayslip': True},
    {'code': 'HOU', 'description': 'Housing Allowance', 'units': '1 month', 'rate': 0.25, 'amount': housing, 'taxable': False, 'visibleOnPayslip': True},
    {'code': 'TRN', 'description': 'Transport Allow', 'units': '1 month', 'rate': 0.10, 'amount': transport, 'taxable': True, 'visibleOnPayslip': True},
    {'code': 'RSP', 'description': 'Resp Allowance', 'units': '1 month', 'rate': 0.15, 'amount': responsibility, 'taxable': True, 'visibleOnPayslip': True},
]

gross = round(sum(item['amount'] for item in earnings_items), 2)
taxable_pay = round(sum(item['amount'] for item in earnings_items if item['taxable']), 2)
non_taxable_pay = round(gross - taxable_pay, 2)

napsa_emp = round(gross * rates['NAPSA_EMP'], 2)
nhima_emp = round(gross * rates['NHIMA_EMP'], 2)
paye = 0.0 if rates['PAYE'] == 0 else round(gross * rates['PAYE'], 2)

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
verify_code = 'MBL-PS-2026-06-0001'
verify_url = f'https://verify.mbala.gov.zm/payslip?code={verify_code}'
issue_date = datetime.now().date().isoformat()

payload = {
    'header': {
        'authorityName': 'MBALA MUNICIPAL COUNCIL',
        'authorityCode': 'MBL',
        'organizationType': 'Local Authority',
        'payrollBrand': 'LOCAL AUTHORITY PAYROLL',
        'logoUrl': '',
        'payslipNo': 'PS-MBL-2026-06-0001',
        'verificationCode': verify_code,
        'payrollMonthLabel': 'JUNE 2026',
        'payPeriodStart': '2026-06-01',
        'payPeriodEnd': '2026-06-30',
        'issueDate': issue_date,
        'currency': 'ZMW',
        'generatedAt': now_iso,
        'printLabel': 'EMPLOYEE PAYSLIP'
    },
    'employee': {
        'employeeId': 'MBL-DIR-HRA-0001',
        'employeeNo': 'MBL***001',
        'fullName': 'SPECIMEN DIRECTOR HR & ADMINISTRATION',
        'department': 'HUMAN RESOURCE AND ADMINISTRATION',
        'grade': 'LGSS/04',
        'division': 'Div I',
        'notch': 1,
        'employmentType': 'PERMANENT',
        'nrcMasked': '******/**/***',
        'tpinMasked': '***********',
        'napsaMasked': '*********',
        'nhimaMasked': '***********'
    },
    'employer': {
        'authorityName': 'MBALA MUNICIPAL COUNCIL',
        'authorityCode': 'MBL',
        'tpinMasked': '***********',
        'napsaMasked': '*********',
        'nhimaMasked': '***********',
        'address': 'Mbala Civic Centre, Mbala, Zambia',
        'contactEmail': 'payroll@mbala.gov.zm',
        'verificationBaseUrl': 'https://verify.mbala.gov.zm/payslip'
    },
    'earnings': {
        'items': earnings_items,
        'totalEarnings': gross,
        'taxableAllowances': round(transport + responsibility, 2),
        'nonTaxableAllowances': housing
    },
    'deductions': {
        'items': deduction_items,
        'totalStatutory': total_statutory,
        'totalOther': total_other,
        'totalDeductions': total_deductions
    },
    'employerContributions': {
        'items': employer_contrib_items,
        'totalEmployerContributions': round(sum(i['amount'] for i in employer_contrib_items), 2)
    },
    'summary': {
        'basicSalary': round(basic, 2),
        'grossSalary': gross,
        'taxablePay': taxable_pay,
        'nonTaxablePay': non_taxable_pay,
        'totalDeductions': total_deductions,
        'netPay': net
    },
    'payment': {
        'method': 'EFT',
        'bankName': 'ZANACO',
        'accountMasked': '************',
        'reference': 'EFT-20260630-MBL-0001',
        'valueDate': '2026-06-30'
    },
    'leave': {
        'items': [
            {'leaveType': 'Annual Leave', 'balance': 0, 'unit': 'days', 'policyMax': 230}
        ]
    },
    'ytd': {
        'gross': gross,
        'taxablePay': taxable_pay,
        'paye': paye,
        'napsaEmployee': napsa_emp,
        'nhimaEmployee': nhima_emp,
        'netPay': net
    },
    'verification': {
        'verificationCode': verify_code,
        'verifyUrl': verify_url,
        'qrPayload': verify_url,
        'signedAt': now_iso,
        'signatureStatus': 'SIGNED'
    },
    'complianceNotes': [
        'Amounts are shown in gross, deductions and net format for transparency.',
        'Mandatory statutory deductions are itemized with legal authority references.',
        'Employee identifiers are masked for data privacy and confidentiality.',
        'Generated as specimen due to missing live Mbala Director HR/Admin payroll row in database snapshot.'
    ]
}

out_json.write_text(json.dumps(payload, indent=2), encoding='utf-8')

# ── build payslip in box-drawing format ─────────────────────────
lines = []

# Header block
lines.append(box_top())
h = payload['header']
lines.append(box_center(h['authorityName']))
lines.append(box_center(h['payrollBrand']))
lines.append(box_center(h['printLabel']))
lines.append(box_center(f"PAY PERIOD: {h['payPeriodStart']} TO {h['payPeriodEnd']}"))
lines.append(box_div())

ps   = h['payslipNo']
vc   = h['verificationCode']
hdr2 = f"PAYSLIP NO: {ps}  ISSUE DATE: {h['issueDate']}"
hdr3 = f"CURRENCY: {h['currency']}  VERIFICATION CODE: {vc}"
lines.append(box_line(hdr2))
lines.append(box_line(hdr3))
lines.append(box_div())

# Employee | Employer two-column header
e  = payload['employee']
er = payload['employer']
emp_rows = [
    f"Name: {e['fullName']}",
    f"Emp No: {e['employeeNo']}",
    f"NRC: {e['nrcMasked']}",
    f"NHIMA: {e['nhimaMasked']}",
    f"TPIN: {e['tpinMasked']}",
    f"NAPSA: {e['napsaMasked']}",
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
    ''
]
lines.append(V + ' EMPLOYEE INFORMATION'.ljust(EMP_COL) + V + ' EMPLOYER INFORMATION'.ljust(ER_COL) + V)
lines.append(two_col_div())
for i in range(max(len(emp_rows), len(er_rows))):
    lines.append(two_col_row(emp_rows[i] if i < len(emp_rows) else '', er_rows[i] if i < len(er_rows) else ''))
lines.append(two_col_end())

# EARNINGS table
lines.append(box_line(' EARNINGS'))
lines.append(table_top())
lines.append(table_head_row('Code', 'Description', 'Units', 'Amount (ZMW)'))
lines.append(table_div())
for item in payload['earnings']['items']:
    lines.append(table_data_row(item['code'], item['description'], item['units'], fmt(item['amount'])))
lines.append(table_total_div())
lines.append(table_total_row('TOTAL EARNINGS', fmt(payload['earnings']['totalEarnings'])))
lines.append(table_bot_merged())

# DEDUCTIONS table
lines.append(box_line(' DEDUCTIONS'))
lines.append(table_top())
lines.append(table_head_row('Code', 'Description', 'Authority', 'Amount (ZMW)'))
lines.append(table_div())
for item in payload['deductions']['items']:
    lines.append(table_data_row(item['code'], item['description'], item.get('authorityRef', ''), fmt(item['amount'])))
lines.append(table_total_div())
lines.append(table_total_row('TOTAL DEDUCTIONS', fmt(payload['deductions']['totalDeductions'])))
lines.append(table_bot_merged())

# NET PAY
lines.append(box_line(f" NET PAY: {h['currency']} {fmt(payload['summary']['netPay'])}"))
lines.append(box_div())

# PAY SUMMARY (best-practice quick view)
lines.append(box_line(' PAY SUMMARY'))
lines.append(box_div())
lines.append(box_line(f" Gross Pay: {h['currency']} {fmt(payload['summary']['grossSalary'])}"))
lines.append(box_line(f" Taxable Pay: {h['currency']} {fmt(payload['summary']['taxablePay'])}"))
lines.append(box_line(f" Non-Taxable Pay: {h['currency']} {fmt(payload['summary']['nonTaxablePay'])}"))
lines.append(box_line(f" Total Deductions: {h['currency']} {fmt(payload['summary']['totalDeductions'])}"))
lines.append(box_line(f" Net Pay: {h['currency']} {fmt(payload['summary']['netPay'])}"))
lines.append(box_div())

# PAYMENT | LEAVE two-column
pay  = payload['payment']
lvs  = payload['leave']['items']
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

# VERIFICATION
lines.append(box_line(' VERIFICATION & AUTHENTICITY'))
lines.append(box_div())
lines.append(box_line(' This payslip is system-generated and valid without wet signature.'))
lines.append(box_line(f" Digital issue timestamp: {payload['verification']['signedAt']}"))
lines.append(box_line(f" Verify portal: {er['verificationBaseUrl']}"))
lines.append(box_line(f" Verification code: {payload['verification']['verificationCode']}"))
lines.append(box_line(''))
lines.append(box_line(f" Payroll helpdesk: {er['contactEmail']}"))
lines.append(box_bot())
out_txt.write_text('\n'.join(lines) + '\n', encoding='utf-8')

# PDF (Courier for monospace box-drawing alignment)
text_lines = out_txt.read_text(encoding='utf-8').splitlines()
page_w, page_h = 595.28, 841.89
margin_left = 22
margin_top  = 55
font_size   = 8
leading     = 11
bottom_margin = 40
max_lines = int((page_h - margin_top - bottom_margin) // leading)
pages = [text_lines[i:i + max_lines] for i in range(0, len(text_lines), max_lines)] or [[]]


def esc(s):
    return s.replace('\\', r'\\').replace('(', r'\(').replace(')', r'\)')


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
            cmds.append(f'({esc(line)}) Tj')
            first = False
        else:
            cmds.extend(['T*', f'({esc(line)}) Tj'])
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

print('JSON:', out_json)
print('TXT :', out_txt)
print('PDF :', out_pdf)
print('Grade: LGSS/04')
print('Net pay:', net)
