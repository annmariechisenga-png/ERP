import re
import sqlite3
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional

import xlrd

ROOT = Path('/Users/Work/Desktop/ERP')
DB_PATH = ROOT / 'hr_platform.db'
DOWNLOADS = Path.home() / 'Downloads'
FILES = [
    DOWNLOADS / 'Payroll December, 2025 Div I-III.xls',
    DOWNLOADS / 'Payroll December, 2025 Div IV.xls',
]


def clean_text(v) -> str:
    return str(v).strip() if v is not None else ''


def to_float(v) -> Optional[float]:
    if v is None:
        return None
    if isinstance(v, (int, float)):
        return float(v)
    s = str(v).strip()
    if not s:
        return None
    s = s.replace(',', '')
    s = s.replace('(', '-').replace(')', '')
    try:
        return float(s)
    except Exception:
        return None


def norm_name(s: str) -> str:
    return re.sub(r'\s+', ' ', s.strip().upper())


def get_erp_baseline(db_path: Path):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    rates = {}
    for code, value in cur.execute("SELECT rate_code, rate_value FROM payroll_statutory_rates WHERE active = 1"):
        rates[code.upper()] = float(value)

    allowance_defaults = {}
    for code, calc_method, default_value in cur.execute(
        "SELECT allowance_code, calc_method, default_value FROM allowance_types WHERE active = 1"
    ):
        allowance_defaults[code.upper()] = {
            'calc_method': calc_method,
            'default_value': float(default_value),
        }

    cur.execute(
        """
        SELECT COUNT(*), SUM(basic_salary), SUM(allowances_total), SUM(gross_pay), SUM(deductions_total), SUM(net_pay)
        FROM payroll_run_items
        """
    )
    c, b, a, g, d, n = cur.fetchone()

    conn.close()
    return rates, allowance_defaults, {
        'employees': c or 0,
        'basic': b or 0.0,
        'allowances': a or 0.0,
        'gross': g or 0.0,
        'deductions': d or 0.0,
        'net': n or 0.0,
    }


def map_earning_to_erp_code(name: str) -> Optional[str]:
    n = name.upper()
    if 'HOUSING' in n:
        return 'HOUSING'
    if 'EDUCATION' in n:
        return 'EDUCATION'
    if 'TRANSPORT' in n:
        return 'TRANSPORT'
    if 'RISK' in n:
        return 'RISK'
    if 'STAND BY' in n or 'STANDBY' in n:
        return 'STANDBY'
    if 'EXCESS HRS' in n or 'EXCESS HOURS' in n:
        return 'EXCESS_HOURS'
    if 'RATION' in n or 'MEAL' in n:
        return 'MEAL'
    return None


def parse_workbook(file_path: Path) -> List[Dict]:
    wb = xlrd.open_workbook(str(file_path))
    sh = wb.sheet_by_index(0)

    rows = []
    r = 3
    while r < sh.nrows:
        emp_no = clean_text(sh.cell_value(r, 0))
        first_name = clean_text(sh.cell_value(r, 1))

        if not emp_no:
            r += 1
            continue

        employee_name_parts = [first_name] if first_name else []
        earnings = defaultdict(float)
        deductions = defaultdict(float)
        basic_pay = None
        gross_total = None
        deduction_total = None
        net_pay = None

        rr = r
        while rr < sh.nrows:
            c0 = clean_text(sh.cell_value(rr, 0))
            c1 = clean_text(sh.cell_value(rr, 1))
            c2 = clean_text(sh.cell_value(rr, 2))
            c6 = clean_text(sh.cell_value(rr, 6))
            c7 = clean_text(sh.cell_value(rr, 7))
            c9 = clean_text(sh.cell_value(rr, 9))
            c11 = to_float(sh.cell_value(rr, 11))

            if rr > r and c0:
                break

            if rr > r and c1 and not c2 and not c7 and not c6 and not c9 and c1.isalpha() is False:
                employee_name_parts.append(c1)

            if rr > r and c1 and not c2 and not c7 and not c6 and not c9 and c1:
                employee_name_parts.append(c1)

            earn_amt = to_float(sh.cell_value(rr, 6))
            if c2 and earn_amt is not None:
                earnings[c2.upper()] += earn_amt
                if c2.upper().startswith('BASIC PAY'):
                    basic_pay = (basic_pay or 0.0) + earn_amt

            ded_amt = to_float(sh.cell_value(rr, 9))
            if c7 and ded_amt is not None:
                deductions[c7.upper()] += ded_amt

            if c11 is not None:
                gross_total = to_float(sh.cell_value(rr, 6))
                deduction_total = to_float(sh.cell_value(rr, 9))
                net_pay = c11
                rr += 1
                break

            rr += 1

        employee_name = norm_name(' '.join([p for p in employee_name_parts if p]))

        if gross_total is not None and deduction_total is not None and net_pay is not None:
            rows.append({
                'file': file_path.name,
                'employee_no': emp_no,
                'employee_name': employee_name,
                'basic_pay': basic_pay or 0.0,
                'gross_total': gross_total,
                'deduction_total': deduction_total,
                'net_pay': net_pay,
                'earnings': dict(earnings),
                'deductions': dict(deductions),
            })

        r = rr if rr > r else r + 1

    return rows


def analyze(rows: List[Dict], rates: Dict[str, float], allowance_defaults: Dict[str, Dict]):
    anomalies = []
    summary_by_file = {}

    total_rate = rates.get('NAPSA', 0.0) + rates.get('NHIMA', 0.0) + rates.get('PAYE', 0.0)

    for rec in rows:
        f = rec['file']
        summary_by_file.setdefault(f, {
            'count': 0,
            'basic': 0.0,
            'gross': 0.0,
            'ded': 0.0,
            'net': 0.0,
            'ded_rate_samples': [],
            'paye_total': 0.0,
            'napsa_total': 0.0,
            'nhima_total': 0.0,
        })
        s = summary_by_file[f]

        s['count'] += 1
        s['basic'] += rec['basic_pay']
        s['gross'] += rec['gross_total'] or 0.0
        s['ded'] += rec['deduction_total'] or 0.0
        s['net'] += rec['net_pay'] or 0.0

        if rec['basic_pay'] > 0:
            s['ded_rate_samples'].append((rec['deduction_total'] or 0.0) / rec['basic_pay'])

        paye = rec['deductions'].get('P.A.Y.E (INCOME TAX)', 0.0)
        napsa = rec['deductions'].get('NAPSA CONTR', 0.0)
        nhima = rec['deductions'].get('NATIONAL HEALTH INSURANCE', 0.0)

        s['paye_total'] += paye
        s['napsa_total'] += napsa
        s['nhima_total'] += nhima

        # Arithmetic consistency
        if abs((rec['gross_total'] - rec['deduction_total']) - rec['net_pay']) > 1.0:
            anomalies.append({
                'type': 'NET_ARITHMETIC_MISMATCH',
                'file': f,
                'employee_no': rec['employee_no'],
                'employee_name': rec['employee_name'],
                'detail': f"gross({rec['gross_total']:.2f}) - ded({rec['deduction_total']:.2f}) != net({rec['net_pay']:.2f})",
            })

        # Statutory mismatch against ERP baseline
        if rec['basic_pay'] > 0:
            expected_stat_total = rec['basic_pay'] * total_rate
            if abs((rec['deduction_total'] or 0.0) - expected_stat_total) > max(1.0, 0.02 * rec['basic_pay']):
                anomalies.append({
                    'type': 'DEDUCTION_TOTAL_VS_ERP_BASELINE',
                    'file': f,
                    'employee_no': rec['employee_no'],
                    'employee_name': rec['employee_name'],
                    'detail': f"ded({rec['deduction_total']:.2f}) vs ERP expected({expected_stat_total:.2f})",
                })

            expected_napsa = rec['basic_pay'] * rates.get('NAPSA', 0.0)
            if napsa and abs(napsa - expected_napsa) > max(1.0, 0.01 * rec['basic_pay']):
                anomalies.append({
                    'type': 'NAPSA_RATE_MISMATCH',
                    'file': f,
                    'employee_no': rec['employee_no'],
                    'employee_name': rec['employee_name'],
                    'detail': f"napsa({napsa:.2f}) vs expected({expected_napsa:.2f})",
                })

            expected_nhima = rec['basic_pay'] * rates.get('NHIMA', 0.0)
            if nhima and abs(nhima - expected_nhima) > max(1.0, 0.01 * rec['basic_pay']):
                anomalies.append({
                    'type': 'NHIMA_RATE_MISMATCH',
                    'file': f,
                    'employee_no': rec['employee_no'],
                    'employee_name': rec['employee_name'],
                    'detail': f"nhima({nhima:.2f}) vs expected({expected_nhima:.2f})",
                })

        # Allowance ratio checks against ERP default percentages
        for earn_name, amount in rec['earnings'].items():
            if earn_name.startswith('BASIC PAY') or amount <= 0 or rec['basic_pay'] <= 0:
                continue
            code = map_earning_to_erp_code(earn_name)
            if not code or code not in allowance_defaults:
                continue
            baseline = allowance_defaults[code]
            if baseline['calc_method'] == 'PERCENT_BASIC':
                actual_ratio = amount / rec['basic_pay']
                expected_ratio = baseline['default_value']
                if abs(actual_ratio - expected_ratio) > 0.015:
                    anomalies.append({
                        'type': 'ALLOWANCE_RATE_MISMATCH',
                        'file': f,
                        'employee_no': rec['employee_no'],
                        'employee_name': rec['employee_name'],
                        'detail': f"{earn_name}: actual_ratio({actual_ratio:.4f}) vs ERP({expected_ratio:.4f})",
                    })
            elif baseline['calc_method'] == 'FIXED_AMOUNT':
                expected_amt = baseline['default_value']
                if abs(amount - expected_amt) > max(1.0, 0.1 * max(expected_amt, 1.0)):
                    anomalies.append({
                        'type': 'ALLOWANCE_FIXED_MISMATCH',
                        'file': f,
                        'employee_no': rec['employee_no'],
                        'employee_name': rec['employee_name'],
                        'detail': f"{earn_name}: amount({amount:.2f}) vs ERP fixed({expected_amt:.2f})",
                    })

        # Detect non-statutory deductions present in payroll files
        for dname, damt in rec['deductions'].items():
            if dname in {'P.A.Y.E (INCOME TAX)', 'NAPSA CONTR', 'NATIONAL HEALTH INSURANCE'}:
                continue
            if damt > 0:
                anomalies.append({
                    'type': 'EXTRA_DEDUCTION_NOT_IN_ERP_STATUTORY',
                    'file': f,
                    'employee_no': rec['employee_no'],
                    'employee_name': rec['employee_name'],
                    'detail': f"{dname}: {damt:.2f}",
                })

    return summary_by_file, anomalies


def write_outputs(rows, summary, anomalies, rates, allowance_defaults, erp_totals):
    report = []
    report.append('DECEMBER 2025 PAYROLL COMPARISON (Downloads XLS vs ERP baseline)')
    report.append('')
    report.append(
        f"ERP statutory rates: NAPSA={rates.get('NAPSA',0):.4f}, NHIMA={rates.get('NHIMA',0):.4f}, PAYE={rates.get('PAYE',0):.4f}"
    )
    report.append(
        f"ERP run totals: employees={erp_totals['employees']}, basic={erp_totals['basic']:.2f}, allowances={erp_totals['allowances']:.2f}, gross={erp_totals['gross']:.2f}, deductions={erp_totals['deductions']:.2f}, net={erp_totals['net']:.2f}"
    )
    report.append('')

    report.append('File summaries:')
    for f, s in summary.items():
        avg_rate = sum(s['ded_rate_samples']) / len(s['ded_rate_samples']) if s['ded_rate_samples'] else 0.0
        report.append(
            f"- {f}: employees={s['count']}, basic={s['basic']:.2f}, gross={s['gross']:.2f}, deductions={s['ded']:.2f}, net={s['net']:.2f}, avg_deduction_rate={avg_rate:.4f}, PAYE_total={s['paye_total']:.2f}, NAPSA_total={s['napsa_total']:.2f}, NHIMA_total={s['nhima_total']:.2f}"
        )
    report.append('')

    report.append('Anomaly counts:')
    counts = defaultdict(int)
    for a in anomalies:
        counts[a['type']] += 1
    for t in sorted(counts):
        report.append(f'- {t}: {counts[t]}')
    if not counts:
        report.append('- None')
    report.append('')

    report.append('Top anomalies (first 80):')
    for a in anomalies[:80]:
        report.append(
            f"- {a['type']} | {a['file']} | {a['employee_no']} | {a['employee_name']} | {a['detail']}"
        )
    if not anomalies:
        report.append('- None')

    report_path = ROOT / 'payroll_dec2025_compare_report.txt'
    report_path.write_text('\n'.join(report), encoding='utf-8')

    csv = ['type,file,employee_no,employee_name,detail']
    for a in anomalies:
        csv.append(
            ','.join([
                a['type'],
                a['file'],
                a['employee_no'],
                a['employee_name'].replace(',', ' '),
                a['detail'].replace(',', ';')
            ])
        )
    csv_path = ROOT / 'payroll_dec2025_anomalies.csv'
    csv_path.write_text('\n'.join(csv), encoding='utf-8')

    parsed_path = ROOT / 'payroll_dec2025_parsed_counts.txt'
    parsed_path.write_text(f'Parsed employees: {len(rows)}\nAnomalies: {len(anomalies)}\n', encoding='utf-8')

    print(f'Wrote: {report_path}')
    print(f'Wrote: {csv_path}')
    print(f'Wrote: {parsed_path}')
    print(f'Parsed employees: {len(rows)} | anomalies: {len(anomalies)}')


def main():
    rates, allowance_defaults, erp_totals = get_erp_baseline(DB_PATH)

    all_rows = []
    for f in FILES:
        rows = parse_workbook(f)
        all_rows.extend(rows)

    summary, anomalies = analyze(all_rows, rates, allowance_defaults)
    write_outputs(all_rows, summary, anomalies, rates, allowance_defaults, erp_totals)


if __name__ == '__main__':
    main()
