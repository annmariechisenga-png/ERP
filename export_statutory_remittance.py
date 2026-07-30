import argparse
import csv
import sqlite3
from datetime import datetime
from pathlib import Path


def resolve_run(cur, run_code: str | None):
    if run_code:
        cur.execute(
            """
            SELECT run_id, run_code
            FROM payroll_runs
            WHERE run_code = ?
            """,
            (run_code,),
        )
    else:
        cur.execute(
            """
            SELECT run_id, run_code
            FROM payroll_runs
            ORDER BY run_id DESC
            LIMIT 1
            """
        )
    row = cur.fetchone()
    if not row:
        raise RuntimeError('No payroll run found')
    return int(row[0]), str(row[1])


def fetch_obligation_rows(cur, run_id: int):
    cur.execute(
        """
        SELECT
            pri.employee_id,
            COALESCE(pri.employee_name, ''),
            pro.scheme_code,
            ROUND(COALESCE(pro.employee_amount, 0), 2) AS employee_amount,
            ROUND(COALESCE(pro.employer_amount, 0), 2) AS employer_amount,
            ROUND(COALESCE(pro.total_amount, 0), 2) AS total_amount,
            COALESCE(pro.payment_status, 'PENDING') AS payment_status,
            COALESCE(pro.due_date, '') AS due_date
        FROM payroll_run_item_obligations pro
        INNER JOIN payroll_run_items pri ON pri.run_item_id = pro.run_item_id
        WHERE pri.run_id = ?
          AND pro.scheme_code IN ('NAPSA', 'NHIMA')
        ORDER BY pro.scheme_code, pri.employee_id
        """,
        (run_id,),
    )
    return cur.fetchall()


def fetch_paye_rows(cur, run_id: int):
    cur.execute(
        """
        SELECT
            employee_id,
            COALESCE(employee_name, ''),
            'PAYE' AS scheme_code,
            ROUND(COALESCE(paye_amount, 0), 2) AS employee_amount,
            0.00 AS employer_amount,
            ROUND(COALESCE(paye_amount, 0), 2) AS total_amount,
            'PENDING' AS payment_status,
            '' AS due_date
        FROM payroll_run_items
        WHERE run_id = ?
        ORDER BY employee_id
        """,
        (run_id,),
    )
    return cur.fetchall()


def write_detail_csv(path: Path, rows):
    with path.open('w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow([
            'employee_id',
            'employee_name',
            'scheme_code',
            'employee_amount',
            'employer_amount',
            'total_amount',
            'payment_status',
            'due_date',
        ])
        for r in rows:
            writer.writerow(r)


def write_summary_csv(path: Path, rows):
    summary = {}
    for r in rows:
        scheme = r[2]
        employee_amt = float(r[3] or 0)
        employer_amt = float(r[4] or 0)
        total_amt = float(r[5] or 0)
        if scheme not in summary:
            summary[scheme] = {
                'lines': 0,
                'employee_total': 0.0,
                'employer_total': 0.0,
                'total': 0.0,
            }
        summary[scheme]['lines'] += 1
        summary[scheme]['employee_total'] += employee_amt
        summary[scheme]['employer_total'] += employer_amt
        summary[scheme]['total'] += total_amt

    with path.open('w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow([
            'scheme_code',
            'line_count',
            'employee_total',
            'employer_total',
            'remittance_total',
        ])
        for scheme in sorted(summary.keys()):
            s = summary[scheme]
            writer.writerow([
                scheme,
                s['lines'],
                f"{s['employee_total']:.2f}",
                f"{s['employer_total']:.2f}",
                f"{s['total']:.2f}",
            ])


def write_manifest(
    path: Path,
    run_id: int,
    run_code: str,
    detail_path: Path,
    summary_path: Path,
    fixed_detail_path: Path,
    fixed_summary_path: Path,
    latest_detail_path: Path,
    latest_summary_path: Path,
):
    lines = [
        f'run_id={run_id}',
        f'run_code={run_code}',
        f'detail_csv_timestamped={detail_path}',
        f'summary_csv_timestamped={summary_path}',
        f'detail_csv_fixed={fixed_detail_path}',
        f'summary_csv_fixed={fixed_summary_path}',
        f'detail_csv_latest={latest_detail_path}',
        f'summary_csv_latest={latest_summary_path}',
    ]
    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description='Export statutory remittance (NAPSA, NHIMA, PAYE) for a payroll run.')
    parser.add_argument('--db', default='/Users/Work/Desktop/ERP/hr_platform.db', help='Path to ERP SQLite database')
    parser.add_argument('--run-code', default=None, help='Payroll run code (e.g. RUN-2026-06). Defaults to latest run')
    parser.add_argument('--out-dir', default='/Users/Work/Desktop/ERP', help='Output directory for CSV files')
    args = parser.parse_args()

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    con = sqlite3.connect(args.db)
    cur = con.cursor()

    run_id, run_code = resolve_run(cur, args.run_code)
    obligation_rows = fetch_obligation_rows(cur, run_id)
    paye_rows = fetch_paye_rows(cur, run_id)

    all_rows = list(obligation_rows) + list(paye_rows)

    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    detail_path = out_dir / f'statutory_remittance_{run_code}_{ts}.csv'
    summary_path = out_dir / f'statutory_remittance_summary_{run_code}_{ts}.csv'
    fixed_detail_path = out_dir / f'statutory_remittance_{run_code}.csv'
    fixed_summary_path = out_dir / f'statutory_remittance_summary_{run_code}.csv'
    latest_detail_path = out_dir / 'statutory_remittance_latest.csv'
    latest_summary_path = out_dir / 'statutory_remittance_summary_latest.csv'
    manifest_path = out_dir / f'statutory_remittance_manifest_{run_code}.txt'

    write_detail_csv(detail_path, all_rows)
    write_summary_csv(summary_path, all_rows)
    write_detail_csv(fixed_detail_path, all_rows)
    write_summary_csv(fixed_summary_path, all_rows)
    write_detail_csv(latest_detail_path, all_rows)
    write_summary_csv(latest_summary_path, all_rows)
    write_manifest(
        manifest_path,
        run_id,
        run_code,
        detail_path,
        summary_path,
        fixed_detail_path,
        fixed_summary_path,
        latest_detail_path,
        latest_summary_path,
    )

    print(f'run_id={run_id} run_code={run_code}')
    print(f'detail_csv={detail_path}')
    print(f'summary_csv={summary_path}')
    print(f'detail_csv_fixed={fixed_detail_path}')
    print(f'summary_csv_fixed={fixed_summary_path}')
    print(f'detail_csv_latest={latest_detail_path}')
    print(f'summary_csv_latest={latest_summary_path}')
    print(f'manifest={manifest_path}')
    print(f'rows_exported={len(all_rows)}')

    con.close()


if __name__ == '__main__':
    main()
