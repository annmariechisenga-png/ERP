#!/usr/bin/env python3
import argparse
import sqlite3
from datetime import date, timedelta
from pathlib import Path

import run_basic_payroll as rb


def get_period_context(cur: sqlite3.Cursor, period_code: str | None):
    if period_code:
        cur.execute(
            """
            SELECT period_code, start_date, end_date, pay_date
            FROM payroll_periods
            WHERE period_code = ?
            LIMIT 1
            """,
            (period_code.strip(),),
        )
        row = cur.fetchone()
        if row:
            return row[0], row[1], row[2], row[3]
        raise RuntimeError(f"Period code not found in payroll_periods: {period_code}")

    cur.execute(
        """
        SELECT period_code, start_date, end_date, pay_date
        FROM payroll_periods
        ORDER BY period_id DESC
        LIMIT 1
        """
    )
    row = cur.fetchone()
    if row:
        return row[0], row[1], row[2], row[3]

    today = date.today()
    start = today.replace(day=1)
    if today.month == 12:
        next_month = date(today.year + 1, 1, 1)
    else:
        next_month = date(today.year, today.month + 1, 1)
    end = next_month - timedelta(days=1)
    period = f"{today.year}-{today.month:02d}"
    return period, start.isoformat(), end.isoformat(), end.isoformat()


def get_authority(cur: sqlite3.Cursor, authority_code: str):
    code = (authority_code or "").strip().upper()
    cur.execute(
        """
        SELECT display_code, authority_name, authority_type
        FROM authority_master
        WHERE UPPER(display_code) = ?
        LIMIT 1
        """,
        (code,),
    )
    row = cur.fetchone()
    if not row:
        raise RuntimeError(f"Authority code not found: {code}")

    display_code, authority_name, authority_type = row
    cur.execute(
        """
        SELECT council_type_id
        FROM council_types
        WHERE lower(council_type_name) = lower(?)
        LIMIT 1
        """,
        (authority_type,),
    )
    council_type = cur.fetchone()
    if not council_type:
        raise RuntimeError(f"Council type mapping not found for authority type: {authority_type}")

    email_domain = display_code.lower()
    return {
        "code": display_code,
        "name": f"{authority_name} {authority_type}".upper(),
        "type": authority_type,
        "council_type_id": int(council_type[0]),
        "contact_email": f"payroll@{email_domain}.gov.zm",
        "verify_base_url": f"https://verify.{email_domain}.gov.zm/payslip",
    }


def get_position_definition(cur: sqlite3.Cursor, council_type_id: int, position: str):
    exact_query = """
        SELECT position_title, department_name, salary_scale_code, source_table
        FROM payroll_establishment_position
        WHERE council_type_id = ?
          AND lower(trim(position_title)) = lower(trim(?))
        ORDER BY CASE WHEN COALESCE(salary_scale_code, '') = '' THEN 1 ELSE 0 END,
                 CASE WHEN source_table = 'executive_positions' THEN 0 ELSE 1 END,
                 authorized_establishment DESC,
                 source_table,
                 position_title
        LIMIT 1
    """
    cur.execute(exact_query, (council_type_id, position))
    row = cur.fetchone()

    if not row:
        like_query = """
            SELECT position_title, department_name, salary_scale_code, source_table
            FROM payroll_establishment_position
            WHERE council_type_id = ?
              AND lower(position_title) LIKE ?
            ORDER BY CASE WHEN COALESCE(salary_scale_code, '') = '' THEN 1 ELSE 0 END,
                     CASE WHEN source_table = 'executive_positions' THEN 0 ELSE 1 END,
                     authorized_establishment DESC,
                     source_table,
                     position_title
            LIMIT 1
        """
        cur.execute(like_query, (council_type_id, f"%{position.lower()}%"))
        row = cur.fetchone()

    if not row:
        raise RuntimeError(
            f"Position '{position}' not found for council_type_id={council_type_id} in payroll_establishment_position"
        )

    title, department_name, salary_scale_code, source_table = row
    scale_code = rb.normalize_scale(salary_scale_code)
    if not scale_code:
        raise RuntimeError(f"No salary scale configured for position '{title}'")

    return {
        "position_title": title,
        "department_name": department_name or "ADMINISTRATION",
        "salary_scale_code": scale_code,
        "source_table": source_table or "payroll_establishment_position",
    }


def get_active_assignment_exception(cur: sqlite3.Cursor, employee_id: str):
    cur.execute(
        """
        SELECT exception_type,
               effective_position_title,
               effective_department_name,
               effective_salary_scale_code,
               approval_reference,
               notes
        FROM payroll_assignment_exception
        WHERE employee_id = ?
          AND is_active = 1
          AND date(effective_from) <= date('now')
          AND (effective_to IS NULL OR date(effective_to) >= date('now'))
        ORDER BY date(effective_from) DESC, id DESC
        LIMIT 1
        """,
        (employee_id,),
    )
    row = cur.fetchone()
    if not row:
        return None
    return {
        "exception_type": row[0],
        "effective_position_title": row[1],
        "effective_department_name": row[2],
        "effective_salary_scale_code": rb.normalize_scale(row[3]),
        "approval_reference": row[4],
        "notes": row[5],
    }


def position_capacity(cur: sqlite3.Cursor, authority_code: str, council_type_id: int, position_title: str):
    cur.execute(
        """
        SELECT MAX(COALESCE(authorized_establishment, 0))
        FROM payroll_establishment_position
        WHERE council_type_id = ?
          AND lower(trim(position_title)) = lower(trim(?))
        """,
        (council_type_id, position_title),
    )
    auth_row = cur.fetchone()
    authorized = int(auth_row[0] or 0)

    cur.execute(
        """
        SELECT COUNT(*)
        FROM employees
        WHERE substr(upper(employee_id), 1, 3) = ?
          AND lower(trim(COALESCE(position, ''))) = lower(trim(?))
          AND COALESCE(is_active, 1) = 1
        """,
        (authority_code.upper(), position_title),
    )
    incumbents_row = cur.fetchone()
    incumbents = int(incumbents_row[0] or 0)
    return authorized, incumbents


def enforce_capacity_or_exception(
    cur: sqlite3.Cursor,
    authority_code: str,
    council_type_id: int,
    position_title: str,
    employee_id: str,
    active_exception: dict | None,
):
    authorized, incumbents = position_capacity(cur, authority_code, council_type_id, position_title)
    if authorized <= 0:
        if active_exception:
            return
        raise RuntimeError(
            f"No authorized establishment slot found for '{position_title}' under authority {authority_code}. "
            f"Provide an active approved exception in payroll_assignment_exception."
        )

    if incumbents <= authorized:
        return

    if active_exception and (active_exception.get("approval_reference") or "").strip():
        return

    raise RuntimeError(
        f"Incumbents exceed authorized establishment for '{position_title}' under {authority_code} "
        f"({incumbents}>{authorized}) and no active approved exception was found for employee {employee_id}."
    )


def resolve_position_definition(
    cur: sqlite3.Cursor,
    authority: dict,
    position: str,
    employee_id: str,
):
    active_exception = get_active_assignment_exception(cur, employee_id)

    try:
        base_def = get_position_definition(cur, authority["council_type_id"], position)
    except RuntimeError:
        if not active_exception:
            raise
        exc_title = active_exception.get("effective_position_title") or position
        exc_dept = active_exception.get("effective_department_name") or "ADMINISTRATION"
        exc_scale = active_exception.get("effective_salary_scale_code")
        if not exc_scale:
            raise RuntimeError(
                f"Position '{position}' not found in establishment and active exception for {employee_id} has no effective salary scale"
            )
        base_def = {
            "position_title": exc_title,
            "department_name": exc_dept,
            "salary_scale_code": exc_scale,
            "source_table": f"assignment_exception:{active_exception.get('exception_type') or 'UNKNOWN'}",
        }

    if active_exception:
        if active_exception.get("effective_position_title"):
            base_def["position_title"] = active_exception["effective_position_title"]
        if active_exception.get("effective_department_name"):
            base_def["department_name"] = active_exception["effective_department_name"]
        if active_exception.get("effective_salary_scale_code"):
            base_def["salary_scale_code"] = active_exception["effective_salary_scale_code"]
        base_def["source_table"] = f"assignment_exception:{active_exception.get('exception_type') or 'UNKNOWN'}"

    enforce_capacity_or_exception(
        cur,
        authority["code"],
        authority["council_type_id"],
        base_def["position_title"],
        employee_id,
        active_exception,
    )
    return base_def, active_exception


def get_basic_salary(cur: sqlite3.Cursor, scale_code: str, notch_no: int):
    cur.execute(
        """
        SELECT monthly_basic
        FROM salary_notch_values
        WHERE scale_code = ? AND notch_no = ?
        ORDER BY effective_from DESC
        LIMIT 1
        """,
        (scale_code, notch_no),
    )
    row = cur.fetchone()
    if not row:
        raise RuntimeError(f"Salary amount not found for scale={scale_code}, notch={notch_no}")
    return round(float(row[0] or 0.0), 2)


def synthetic_employee_id(authority_code: str):
    return f"{authority_code.upper()}-GEN-000001"


def validate_employee_authority_match(employee_id: str, authority_code: str):
    employee_id = (employee_id or "").strip().upper()
    prefix = employee_id.split("-", 1)[0] if "-" in employee_id else employee_id[:3]
    if prefix != authority_code.upper():
        raise RuntimeError(
            f"Authority code and employee number prefix must match: authority={authority_code.upper()}, employee_id={employee_id}"
        )


def synthetic_division_for_scale(scale_code: str):
    if scale_code in {"G1", "G2", "G3"}:
        return "DIVISION_IV"
    return rb.division_for_scale(scale_code)


def synthetic_union_code(scale_code: str, position_title: str):
    division = synthetic_division_for_scale(scale_code)
    if "fire" in (position_title or "").lower():
        return "FIRESUZ"
    if division in {"DIVISION_II", "DIVISION_III", "DIVISION_IV"}:
        return "ZULAWU"
    if division == "DIVISION_I":
        return "MANAGEMENT"
    return "ZULAWAU"


def risk_allowance_eligible(position_title: str, department_name: str):
    position_norm = (position_title or "").lower()
    department_norm = (department_name or "").lower()
    is_fire_section = "fire" in position_norm or "fire" in department_norm
    is_solid_waste_driver = "driver" in position_norm and "solid waste" in department_norm
    return is_fire_section or is_solid_waste_driver


def fire_section_role(position_title: str, department_name: str):
    position_norm = (position_title or "").lower()
    department_norm = (department_name or "").lower()
    return "fire" in position_norm or "fire" in department_norm


def allowance_rules(cur: sqlite3.Cursor, scale_code: str, position_title: str, department_name: str):
    division = synthetic_division_for_scale(scale_code)
    is_fire_officer = fire_section_role(position_title, department_name)
    union_code = synthetic_union_code(scale_code, position_title)

    rules = [
        ("HOU", "PERCENT_BASIC", 0.20),
        ("EDU", "PERCENT_BASIC", 0.20),
    ]

    if scale_code.startswith("LGSS"):
        num = int(scale_code.replace("LGSS", ""))
        if 1 <= num <= 3:
            rules.append(("FUL", "PERCENT_BASIC", 0.30))
        else:
            rules.append(("TRN", "PERCENT_BASIC", 0.17))
    else:
        rules.append(("TRN", "PERCENT_BASIC", 0.17))

    if division in {"DIVISION_II", "DIVISION_III", "DIVISION_IV"} and risk_allowance_eligible(position_title, department_name):
        rules.append(("RISK", "PERCENT_BASIC", 0.02))

    if is_fire_officer and union_code == "FIRESUZ":
        rules.append(("STANDBY", "PERCENT_BASIC", 0.06))
        rules.append(("EXCESS_HOURS", "FIXED_AMOUNT", 400.0))
        ration_pct = rb.ration_percentage_for_scale(cur, scale_code)
        if ration_pct > 0:
            rules.append(("RATION", "PERCENT_BASIC", ration_pct))

    return rules


def compute_allowances(cur: sqlite3.Cursor, basic_salary: float, scale_code: str, position_title: str, department_name: str):
    allowance_items = []
    total = 0.0
    taxable_total = 0.0
    non_taxable_total = 0.0

    for code, method, value in allowance_rules(cur, scale_code, position_title, department_name):
        if method == "PERCENT_BASIC":
            amount = round(basic_salary * float(value or 0.0), 2)
        elif method == "FIXED_AMOUNT":
            amount = round(float(value or 0.0), 2)
        else:
            continue

        if amount <= 0:
            continue

        allowance_name, taxable, show_on_payslip = rb.get_allowance_meta(cur, code)
        item = {
            "code": (code or "ALW")[:4].upper(),
            "description": allowance_name or code or "Allowance",
            "units": "1 month",
            "rate": None,
            "amount": amount,
            "taxable": bool(taxable),
            "visibleOnPayslip": bool(show_on_payslip),
        }
        allowance_items.append(item)
        total = round(total + amount, 2)
        if taxable:
            taxable_total = round(taxable_total + amount, 2)
        else:
            non_taxable_total = round(non_taxable_total + amount, 2)

    return allowance_items, total, taxable_total, non_taxable_total


def compute_mandatory_deductions(cur: sqlite3.Cursor, basic_salary: float, taxable_pay: float):
    cur.execute(
        """
        SELECT deduction_code, deduction_name, deduction_category, calculation_method,
               calculation_basis, employee_percentage, employer_percentage, legal_authority
        FROM deduction_types
        WHERE active = 1 AND is_mandatory = 1
        ORDER BY priority, deduction_code
        """
    )

    deduction_items = []
    employer_items = []

    for code, name, category, method, basis, employee_pct, employer_pct, authority_ref in cur.fetchall():
        calc_basis = (basis or "BASIC_SALARY").upper()
        employee_rate = float(employee_pct or 0.0)
        employer_rate = float(employer_pct or 0.0)
        method_norm = (method or "").upper()

        if (code or "").upper() == "PAYE":
            employee_amount = rb.calculate_paye_2026(taxable_pay)
        elif method_norm == "PERCENTAGE":
            base_amount = taxable_pay if calc_basis == "TAXABLE_PAY" else basic_salary
            employee_amount = round(base_amount * (employee_rate / 100.0), 2)
        else:
            employee_amount = round(employee_rate, 2)

        if employee_amount > 0:
            deduction_items.append(
                {
                    "code": (code or "")[:10],
                    "description": name or code or "Deduction",
                    "authorityRef": authority_ref or "",
                    "amount": employee_amount,
                    "category": category or "OTHER",
                }
            )

        if employer_rate > 0:
            base_amount = taxable_pay if calc_basis == "TAXABLE_PAY" else basic_salary
            employer_amount = round(base_amount * (employer_rate / 100.0), 2)
            if employer_amount > 0:
                employer_items.append(
                    {
                        "code": (code or "")[:10],
                        "description": f"Employer {name or code}",
                        "amount": employer_amount,
                    }
                )

    total_deductions = round(sum(item["amount"] for item in deduction_items), 2)
    total_statutory = round(sum(item["amount"] for item in deduction_items if (item["category"] or "").upper() == "STATUTORY"), 2)
    total_other = round(sum(item["amount"] for item in deduction_items if (item["category"] or "").upper() != "STATUTORY"), 2)
    total_employer = round(sum(item["amount"] for item in employer_items), 2)
    return deduction_items, employer_items, total_deductions, total_statutory, total_other, total_employer


def compute_union_deduction(cur: sqlite3.Cursor, scale_code: str, position_title: str, basic_salary: float):
    union_code = synthetic_union_code(scale_code, position_title)
    if union_code not in {"FIRESUZ", "ZULAWU", "NULGAW"}:
        return None

    cur.execute(
        """
        SELECT deduction_code, deduction_name, deduction_category, employee_percentage, legal_authority
        FROM deduction_types
        WHERE deduction_code = ? AND active = 1
        LIMIT 1
        """,
        (union_code,),
    )
    row = cur.fetchone()
    if not row:
        return None

    code, name, category, employee_pct, authority_ref = row
    amount = round(basic_salary * (float(employee_pct or 0.0) / 100.0), 2)
    if amount <= 0:
        return None

    return {
        "code": code,
        "description": name or code,
        "authorityRef": authority_ref or "",
        "amount": amount,
        "category": category or "VOLUNTARY",
    }


def build_payload(
    cur: sqlite3.Cursor,
    authority: dict,
    position_def: dict,
    period_code: str,
    period_start: str,
    period_end: str,
    pay_date: str,
    employee_id: str,
    employee_name: str,
    notch_no: int,
    active_exception: dict | None,
):
    position_title = position_def["position_title"]
    scale_code = position_def["salary_scale_code"]
    basic_salary = get_basic_salary(cur, scale_code, notch_no)
    division = synthetic_division_for_scale(scale_code)

    allowance_items, allowances_total, taxable_allowances, non_taxable_allowances = compute_allowances(
        cur, basic_salary, scale_code, position_title, position_def["department_name"]
    )
    gross_pay = round(basic_salary + allowances_total, 2)
    taxable_pay = round(basic_salary + taxable_allowances, 2)
    non_taxable_pay = round(gross_pay - taxable_pay, 2)

    deduction_items, employer_items, total_deductions, total_statutory, total_other, total_employer = compute_mandatory_deductions(
        cur, basic_salary, taxable_pay
    )
    union_deduction = compute_union_deduction(cur, scale_code, position_title, basic_salary)
    if union_deduction:
        deduction_items.append(union_deduction)
        total_deductions = round(total_deductions + union_deduction["amount"], 2)
        if (union_deduction["category"] or "").upper() == "STATUTORY":
            total_statutory = round(total_statutory + union_deduction["amount"], 2)
        else:
            total_other = round(total_other + union_deduction["amount"], 2)
    net_pay = round(gross_pay - total_deductions, 2)

    period_norm = period_code.replace("-", "")
    serial = employee_id.replace("-", "_").upper()
    payslip_no = f"PS-{authority['code']}-{period_norm}-{serial}"
    verify_url = f"{authority['verify_base_url']}?code={payslip_no}"

    earnings_items = [
        {
            "code": "BAS",
            "description": "Basic Salary",
            "units": "1 month",
            "rate": None,
            "amount": basic_salary,
            "taxable": True,
            "visibleOnPayslip": True,
        }
    ] + allowance_items

    payload = {
        "header": {
            "authorityName": authority["name"],
            "authorityCode": authority["code"],
            "organizationType": authority["type"],
            "payrollBrand": "LOCAL AUTHORITY PAYROLL",
            "logoUrl": "",
            "payslipNo": payslip_no,
            "verificationCode": payslip_no,
            "payrollMonthLabel": period_code,
            "payPeriodStart": period_start,
            "payPeriodEnd": period_end,
            "issueDate": date.today().isoformat(),
            "currency": "ZMW",
            "generatedAt": date.today().isoformat(),
            "printLabel": "EMPLOYEE PAYSLIP",
        },
        "employee": {
            "employeeId": employee_id,
            "employeeNo": employee_id,
            "fullName": employee_name.upper(),
            "department": position_def["department_name"].upper(),
            "grade": scale_code,
            "division": division,
            "notch": notch_no,
            "employmentType": "PERMANENT",
            "nrcMasked": "******/**/***",
            "tpinMasked": "***********",
            "napsaMasked": "*********",
            "nhimaMasked": "***********",
            "position": position_title,
        },
        "employer": {
            "authorityName": authority["name"],
            "authorityCode": authority["code"],
            "tpinMasked": "***********",
            "napsaMasked": "*********",
            "nhimaMasked": "***********",
            "address": "",
            "contactEmail": authority["contact_email"],
            "verificationBaseUrl": authority["verify_base_url"],
        },
        "earnings": {
            "items": earnings_items,
            "totalEarnings": gross_pay,
            "taxableAllowances": taxable_allowances,
            "nonTaxableAllowances": non_taxable_allowances,
        },
        "deductions": {
            "items": deduction_items,
            "totalStatutory": total_statutory,
            "totalOther": total_other,
            "totalDeductions": total_deductions,
        },
        "employerContributions": {
            "items": employer_items,
            "totalEmployerContributions": total_employer,
        },
        "summary": {
            "basicSalary": basic_salary,
            "grossSalary": gross_pay,
            "taxablePay": taxable_pay,
            "nonTaxablePay": non_taxable_pay,
            "totalDeductions": total_deductions,
            "netPay": net_pay,
        },
        "payment": {
            "method": "EFT",
            "bankName": "N/A",
            "accountMasked": "************",
            "reference": f"EFT-{period_norm}-{authority['code']}-{serial}",
            "valueDate": pay_date,
        },
        "leave": {
            "items": [{"leaveType": "Annual Leave", "balance": 0, "unit": "days", "policyMax": 230}],
        },
        "verification": {
            "verificationCode": payslip_no,
            "verifyUrl": verify_url,
            "qrPayload": verify_url,
            "signedAt": date.today().isoformat(),
            "signatureStatus": "SIGNED",
        },
        "complianceNotes": [
            "Amounts are shown in gross, deductions and net format for transparency.",
            "Mandatory statutory deductions are itemized with legal authority references.",
            "Employee identifiers are masked for data privacy and confidentiality.",
            "Generated automatically from authority, position and salary master data.",
        ],
    }

    if active_exception:
        payload["complianceNotes"].append(
            f"Assignment exception applied: {active_exception.get('exception_type', 'UNKNOWN')}"
            + (
                f" ({active_exception.get('approval_reference')})"
                if active_exception.get("approval_reference")
                else ""
            )
        )

    return payload


def main():
    parser = argparse.ArgumentParser(description="Generate a generic payslip from authority, position and salary master data")
    parser.add_argument("--authority-code", required=True, help="Authority display code, e.g. KZG, MZB, CHL")
    parser.add_argument("--position", required=True, help="Exact or partial position title, e.g. Council Secretary")
    parser.add_argument("--period-code", default=None, help="Optional period code (YYYY-MM) from payroll_periods")
    parser.add_argument("--notch", type=int, default=1, help="Salary notch to use for the synthetic payslip")
    parser.add_argument("--employee-id", default=None, help="Optional employee number override; prefix must match authority code")
    parser.add_argument("--employee-name", default=None, help="Optional employee name override")
    parser.add_argument("--db", default="hr_platform.db", help="Path to SQLite payroll database")
    parser.add_argument("--output-root", default="generated_standard_payslips", help="Root output folder")
    args = parser.parse_args()

    con = sqlite3.connect(args.db)
    con.row_factory = sqlite3.Row
    cur = con.cursor()

    period_code, period_start, period_end, pay_date = get_period_context(cur, args.period_code)
    authority = get_authority(cur, args.authority_code)
    employee_id = (args.employee_id or synthetic_employee_id(authority["code"])).upper()
    validate_employee_authority_match(employee_id, authority["code"])
    position_def, active_exception = resolve_position_definition(cur, authority, args.position, employee_id)
    employee_name = args.employee_name or f"Generic {position_def['position_title']}"

    payload = build_payload(
        cur,
        authority,
        position_def,
        period_code,
        period_start,
        period_end,
        pay_date,
        employee_id,
        employee_name,
        args.notch,
        active_exception,
    )

    out_dir = Path(args.output_root) / rb.sanitize_fragment(period_code) / authority["code"].lower()
    stem = (
        f"payslip_{rb.sanitize_fragment(period_code)}_{authority['code'].lower()}_"
        f"{rb.sanitize_fragment(position_def['position_title'])}_{rb.sanitize_fragment(employee_id)}"
    )
    rb.emit_files(payload, out_dir, stem)

    print(f"Authority: {authority['name']} ({authority['code']})")
    print(f"Position: {position_def['position_title']}")
    print(f"Scale/Notch: {position_def['salary_scale_code']} / {args.notch}")
    print(f"Employee ID: {employee_id}")
    print(f"Basic Salary: {payload['summary']['basicSalary']:.2f}")
    print(f"Net Pay: {payload['summary']['netPay']:.2f}")
    print(f"Generated: {out_dir / (stem + '.json')}")
    print(f"Generated: {out_dir / (stem + '.txt')}")
    print(f"Generated: {out_dir / (stem + '.pdf')}")


if __name__ == "__main__":
    main()
