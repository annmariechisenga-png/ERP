import re
import sqlite3
from pathlib import Path
from typing import Dict, List, Tuple, Optional

import xlrd

ROOT = Path('/Users/Work/Desktop/ERP')
DB_PATH = ROOT / 'hr_platform.db'
DOWNLOADS = Path.home() / 'Downloads'
FILES = [
    DOWNLOADS / 'Payroll December, 2025 Div I-III.xls',
    DOWNLOADS / 'Payroll December, 2025 Div IV.xls',
]


def norm(text: str) -> str:
    return re.sub(r'[^a-z0-9]+', '_', str(text).strip().lower()).strip('_')


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


def pick_col(headers: List[str], include: List[str], exclude: List[str] = None) -> Optional[int]:
    exclude = exclude or []
    for i, h in enumerate(headers):
        if all(k in h for k in include) and not any(x in h for x in exclude):
            return i
    return None


def find_header_row(sheet) -> Optional[int]:
    for r in range(min(sheet.nrows, 80)):
        vals = [str(sheet.cell_value(r, c)).strip() for c in range(sheet.ncols)]
        nvals = [norm(v) for v in vals if str(v).strip()]
        if not nvals:
            continue
        joined = ' '.join(nvals)
        if ('basic' in joined and 'net' in joined) or ('deduction' in joined and 'gross' in joined):
            if len(nvals) >= 8:
                return r
    return None


def extract_sheet_rows(file_path: Path):
    wb = xlrd.open_workbook(str(file_path))
    rows_out = []
    metadata = []

    for sname in wb.sheet_names():
        sh = wb.sheet_by_name(sname)
        hrow = find_header_row(sh)
        if hrow is None:
            continue

        headers_raw = [str(sh.cell_value(hrow, c)).strip() for c in range(sh.ncols)]
        headers = [norm(h) for h in headers_raw]

        name_col = pick_col(headers, ['name'])
        basic_col = pick_col(headers, ['basic'])
        gross_col = pick_col(headers, ['gross'])
        net_col = pick_col(headers, ['net'])
        deduction_total_col = pick_col(headers, ['deduction'])
        allowance_total_col = pick_col(headers, ['allowance'])
        napsa_col = pick_col(headers, ['napsa'])
        nhima_col = pick_col(headers, ['nhima'])
        paye_col = pick_col(headers, ['paye'])

        metadata.append({
            'file': file_path.name,
            'sheet': sname,
            'header_row': hrow,
            'mapped_columns': {
                'name': name_col,
                'basic': basic_col,
                'gross': gross_col,
                'net': net_col,
                'deduction_total': deduction_total_col,
                'allowance_total': allowance_total_col,
                'napsa': napsa_col,
                'nhima': nhima_col,
                'paye': paye_col,
            },
            'headers': headers_raw,
        })

        for r in range(hrow + 1, sh.nrows):
            values = [sh.cell_value(r, c) for c in range(sh.ncols)]
            if not any(str(v).strip() for v in values):
                continue

            basic = to_float(values[basic_col]) if basic_col is not None else None
            gross = to_float(values[gross_col]) if gross_col is not None else None
            net = to_float(values[net_col]) if net_col is not None else None
            deductions = to_float(values[deduction_total_col]) if deduction_total_col is not None else None
            allowances = to_float(values[allowance_total_col]) if allowance_total_col is not None else None
            napsa = to_float(values[napsa_col]) if napsa_col is not None else None
            nhima = to_float(values[nhima_col]) if nhima_col is not None else None
            paye = to_float(values[paye_col]) if paye_col is not None else None

            employee_name = None
            if name_col is not None:
                employee_name = str(values[name_col]).strip() or None

            numeric_presence = sum(v is not None for v in [basic, gross, net, deductions, allowances])
            if numeric_presence == 0:
                continue
            if basic is not None and basic <= 0:
                continue

            rows_out.append({
                'file': file_path.name,
                'sheet': sname,
                'row': r + 1,
                'employee_name': employee_name,
                'basic': basic,
                'allowances': allowances,
                'gross': gross,
                'deductions': deductions,
                'net': net,
                'napsa': napsa,
                'nhima': nhima,
                'paye': paye,
            })

    return rows_out, metadata


def get_erp_baseline(db_path: Path):
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    rates = {}
    for code, value in cur.execute("SELECT rate_code, rate_value FROM payroll_statutory_rates WHERE active = 1"):
        rates[str(code).upper()] = float(value)

    cur.execute("""
        SELECT
            COUNT(*),
            SUM(basic_salary),
            SUM(allowances_total),
            SUM(gross_pay),
            SUM(deductions_total),
            SUM(net_pay)
        FROM payroll_run_items
    """)
    row = cur.fetchone()
    erp_summary = {
        'employees': row[0] or 0,
        'basic_total': row[1] or 0.0,
        'allowances_total': row[2] or 0.0,
        'gross_total': row[3] or 0.0,
        'deductions_total': row[4] or 0.0,
        'net_total': row[5] or 0.0,
    }

    conn.close()
    return rates, erp_summary


def analyze(rows: List[Dict], rates: Dict[str, float]):
    napsa_rate = rates.get('NAPSA', 0.0)
    nhima_rate = rates.get('NHIMA', 0.0)
    paye_rate = rates.get('PAYE', 0.0)
    total_rate = napsa_rate + nhima_rate + paye_rate

    anomalies = []
    by_file = {}

    for rec in rows:
        f = rec['file']
        by_file.setdefault(f, {
            'count': 0,
            'basic_total': 0.0,
            'allowances_total': 0.0,
            'gross_total': 0.0,
            'deductions_total': 0.0,
            'net_total': 0.0,
            'deduction_rate_samples': [],
            'erp_delta_samples': [],
        })

        st = by_file[f]
        st['count'] += 1
        for key, skey in [('basic', 'basic_total'), ('allowances', 'allowances_total'), ('gross', 'gross_total'), ('deductions', 'deductions_total'), ('net', 'net_total')]:
            if rec[key] is not None:
                st[skey] += rec[key]

        basic = rec['basic']
        allowances = rec['allowances']
        gross = rec['gross']
        deductions = rec['deductions']
        net = rec['net']

        if basic and deductions is not None and basic > 0:
            st['deduction_rate_samples'].append(deductions / basic)
            expected = basic * total_rate
            delta = deductions - expected
            st['erp_delta_samples'].append(delta)
            if abs(delta) > max(1.0, 0.02 * basic):
                anomalies.append((
                    'DEDUCTION_VS_ERP_RATE',
                    rec,
                    f'ded={deductions:.2f}, expected_erp={expected:.2f}, delta={delta:.2f}'
                ))

        if basic is not None and allowances is not None and gross is not None:
            calc = basic + allowances
            diff = gross - calc
            if abs(diff) > 1.0:
                anomalies.append((
                    'GROSS_MISMATCH',
                    rec,
                    f'gross={gross:.2f}, basic+allowances={calc:.2f}, diff={diff:.2f}'
                ))

        if gross is not None and deductions is not None and net is not None:
            calc = gross - deductions
            diff = net - calc
            if abs(diff) > 1.0:
                anomalies.append((
                    'NET_MISMATCH',
                    rec,
                    f'net={net:.2f}, gross-ded={calc:.2f}, diff={diff:.2f}'
                ))

        if basic is not None and rec['napsa'] is not None:
            expected_napsa = basic * napsa_rate
            if abs(rec['napsa'] - expected_napsa) > max(1.0, 0.01 * basic):
                anomalies.append((
                    'NAPSA_MISMATCH',
                    rec,
                    f'napsa={rec["napsa"]:.2f}, expected={expected_napsa:.2f}'
                ))

        if basic is not None and rec['nhima'] is not None:
            expected_nhima = basic * nhima_rate
            if abs(rec['nhima'] - expected_nhima) > max(1.0, 0.01 * basic):
                anomalies.append((
                    'NHIMA_MISMATCH',
                    rec,
                    f'nhima={rec["nhima"]:.2f}, expected={expected_nhima:.2f}'
                ))

    return by_file, anomalies


def main():
    rows = []
    metadata_all = []
    for f in FILES:
        r, md = extract_sheet_rows(f)
        rows.extend(r)
        metadata_all.extend(md)

    rates, erp_summary = get_erp_baseline(DB_PATH)
    by_file, anomalies = analyze(rows, rates)

    out = []
    out.append('PAYROLL ANOMALY CHECK - DECEMBER 2025 (XLS vs ERP BASELINE)')
    out.append('')
    out.append(f'ERP statutory rates: NAPSA={rates.get("NAPSA",0.0):.4f}, NHIMA={rates.get("NHIMA",0.0):.4f}, PAYE={rates.get("PAYE",0.0):.4f}, TOTAL={rates.get("NAPSA",0.0)+rates.get("NHIMA",0.0)+rates.get("PAYE",0.0):.4f}')
    out.append(f'ERP payroll totals (current run items): employees={erp_summary["employees"]}, basic={erp_summary["basic_total"]:.2f}, allowances={erp_summary["allowances_total"]:.2f}, gross={erp_summary["gross_total"]:.2f}, deductions={erp_summary["deductions_total"]:.2f}, net={erp_summary["net_total"]:.2f}')
    out.append('')

    out.append('Detected sheet mappings:')
    for md in metadata_all:
        mapped = ', '.join([f'{k}:{v}' for k, v in md['mapped_columns'].items() if v is not None])
        out.append(f"- {md['file']} | sheet='{md['sheet']}' | header_row={md['header_row']+1} | {mapped}")
    out.append('')

    out.append('File summaries:')
    for f, st in by_file.items():
        avg_rate = (sum(st['deduction_rate_samples']) / len(st['deduction_rate_samples'])) if st['deduction_rate_samples'] else 0.0
        avg_delta = (sum(st['erp_delta_samples']) / len(st['erp_delta_samples'])) if st['erp_delta_samples'] else 0.0
        out.append(
            f"- {f}: rows={st['count']}, basic={st['basic_total']:.2f}, allowances={st['allowances_total']:.2f}, gross={st['gross_total']:.2f}, deductions={st['deductions_total']:.2f}, net={st['net_total']:.2f}, avg_deduction_rate={avg_rate:.4f}, avg_deduction_minus_erp={avg_delta:.2f}"
        )
    out.append('')

    by_type = {}
    for t, rec, msg in anomalies:
        by_type[t] = by_type.get(t, 0) + 1

    out.append('Anomaly counts:')
    if by_type:
        for t, c in sorted(by_type.items()):
            out.append(f'- {t}: {c}')
    else:
        out.append('- None')
    out.append('')

    out.append('Top anomaly samples (max 30):')
    if anomalies:
        for t, rec, msg in anomalies[:30]:
            out.append(f"- {t} | {rec['file']} | sheet={rec['sheet']} | row={rec['row']} | emp={rec['employee_name']} | {msg}")
    else:
        out.append('- None')

    report_path = ROOT / 'payroll_anomaly_report_dec2025.txt'
    report_path.write_text('\n'.join(out), encoding='utf-8')

    csv_lines = ['type,file,sheet,row,employee_name,basic,allowances,gross,deductions,net,napsa,nhima,paye,detail']
    for t, rec, msg in anomalies:
        fields = [
            t,
            rec['file'],
            rec['sheet'],
            str(rec['row']),
            (rec['employee_name'] or '').replace(',', ' '),
            '' if rec['basic'] is None else f"{rec['basic']:.2f}",
            '' if rec['allowances'] is None else f"{rec['allowances']:.2f}",
            '' if rec['gross'] is None else f"{rec['gross']:.2f}",
            '' if rec['deductions'] is None else f"{rec['deductions']:.2f}",
            '' if rec['net'] is None else f"{rec['net']:.2f}",
            '' if rec['napsa'] is None else f"{rec['napsa']:.2f}",
            '' if rec['nhima'] is None else f"{rec['nhima']:.2f}",
            '' if rec['paye'] is None else f"{rec['paye']:.2f}",
            msg.replace(',', ';'),
        ]
        csv_lines.append(','.join(fields))

    csv_path = ROOT / 'payroll_anomalies_dec2025.csv'
    csv_path.write_text('\n'.join(csv_lines), encoding='utf-8')

    print(f'Wrote: {report_path}')
    print(f'Wrote: {csv_path}')
    print(f'Parsed rows: {len(rows)} | anomalies: {len(anomalies)}')


if __name__ == '__main__':
    main()
