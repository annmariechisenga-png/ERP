from __future__ import annotations

import csv
import json
import sqlite3
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DB_PATH = ROOT / "hr_platform.db"
STAMP = date.today().isoformat()
CSV_PATH = ROOT / f"payroll_assignment_exceptions_report_{STAMP}.csv"
JSON_PATH = ROOT / f"payroll_assignment_exceptions_report_{STAMP}.json"
MD_PATH = ROOT / f"payroll_assignment_exceptions_review_{STAMP}.md"

QUERY = """
SELECT
    employee_id,
    employee_name,
    recorded_position_title,
    effective_position_title,
    recorded_salary_scale_code,
    effective_salary_scale_code,
    structural_position_title,
    structural_salary_scale_code,
    recorded_department,
    effective_department_name,
    structural_department_name,
    exception_type,
    structural_status,
    exception_notes,
    handling_reference
FROM vw_payroll_employee_effective_assignment
WHERE exception_type IS NOT NULL
ORDER BY exception_type, employee_name
"""


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    rows = [dict(row) for row in conn.execute(QUERY).fetchall()]
    conn.close()

    fieldnames = list(rows[0].keys()) if rows else [
        "employee_id",
        "employee_name",
        "recorded_position_title",
        "effective_position_title",
        "recorded_salary_scale_code",
        "effective_salary_scale_code",
        "structural_position_title",
        "structural_salary_scale_code",
        "recorded_department",
        "effective_department_name",
        "structural_department_name",
        "exception_type",
        "structural_status",
        "exception_notes",
        "handling_reference",
    ]

    with CSV_PATH.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    with JSON_PATH.open("w", encoding="utf-8") as handle:
        json.dump(rows, handle, indent=2, ensure_ascii=False)

    lines = [
        "# Payroll Assignment Exceptions Review",
        "",
        f"Generated: {STAMP}",
        "",
        f"Total managed exceptions: {len(rows)}",
        "",
    ]

    for index, row in enumerate(rows, start=1):
        lines.extend(
            [
                f"## {index}. {row['employee_name']} ({row['employee_id']})",
                "",
                f"- Exception type: {row['exception_type']}",
                f"- Structural status: {row['structural_status']}",
                f"- Recorded title: {row['recorded_position_title']}",
                f"- Effective title: {row['effective_position_title']}",
                f"- Structural title: {row['structural_position_title']}",
                f"- Recorded scale: {row['recorded_salary_scale_code']}",
                f"- Effective scale: {row['effective_salary_scale_code']}",
                f"- Structural scale: {row['structural_salary_scale_code']}",
                f"- Recorded department: {row['recorded_department']}",
                f"- Effective department: {row['effective_department_name']}",
                f"- Structural department: {row['structural_department_name']}",
                f"- Reference: {row['handling_reference']}",
                f"- Notes: {row['exception_notes']}",
                "",
            ]
        )

    MD_PATH.write_text("\n".join(lines), encoding="utf-8")

    print(f"csv {CSV_PATH}")
    print(f"json {JSON_PATH}")
    print(f"markdown {MD_PATH}")
    print(f"records {len(rows)}")


if __name__ == "__main__":
    main()
