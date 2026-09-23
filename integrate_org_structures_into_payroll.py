from __future__ import annotations

import re
import sqlite3
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parent
DB_PATH = ROOT / "hr_platform.db"

POSITION_TABLE_QUERY = """
SELECT name
FROM sqlite_master
WHERE type = 'table'
  AND lower(name) LIKE '%positions%'
  AND lower(name) NOT LIKE '%detailed%'
  AND lower(name) NOT LIKE 'vw_%'
ORDER BY name
"""

DEPARTMENT_MAP = {
    "hra_positions": ("HRA", "Human Resources and Administration"),
    "audit_positions": ("AUDIT", "Audit"),
    "commercial_city_positions": ("COMMERCIAL", "Commercial Services"),
    "commercial_positions": ("COMMERCIAL", "Commercial Services"),
    "community_positions": ("COMMUNITY", "Community Development"),
    "cos_positions": ("COS", "Council Secretary"),
    "eng_positions": ("ENG", "Engineering"),
    "executive_positions": ("EXEC", "Executive Management"),
    "finance_positions": ("FIN", "Finance"),
    "health_positions": ("HEALTH", "Health"),
    "ict_city_positions": ("ICT", "Information and Communication Technology"),
    "ict_positions": ("ICT", "Information and Communication Technology"),
    "legal_positions": ("LEGAL", "Legal Services"),
    "planning_positions": ("PLANNING", "Planning"),
    "positions": ("GENERAL", "General Establishment"),
    "procurement_positions": ("PROC", "Procurement"),
    "toc_city_positions": ("EXEC", "Town Clerk"),
    "toc_positions": ("EXEC", "Town Clerk"),
    "valuation_city_positions": ("VALUATION", "Valuation"),
}

AUTHORITY_TYPE_TO_COUNCIL_TYPE_ID = {
    "town": 1,
    "municipal": 2,
    "city": 3,
}


def normalize_scale(value: Any) -> str | None:
    if value is None:
        return None
    text = str(value).strip().upper()
    if not text:
        return None
    text = text.replace(" ", "")
    text = text.replace("/", "")
    text = text.replace("-", "")
    return text


def normalize_text(value: Any) -> str:
    if value is None:
        return ""
    text = str(value).strip().lower()
    text = re.sub(r"[^a-z0-9]+", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def normalize_position_code(value: Any) -> str:
    text = "" if value is None else str(value).strip()
    if not text:
        return text
    return re.sub(r"^HR(?!A)", "HRA", text, flags=re.IGNORECASE)


def coerce_bool(value: Any) -> int:
    if value in (None, "", 0, "0", False):
        return 0
    if value in (True, 1, "1"):
        return 1
    text = str(value).strip().lower()
    return 1 if text in {"true", "t", "yes", "y"} else 0


def coerce_establishment(value: Any) -> int:
    if value is None or value == "":
        return 0
    if isinstance(value, bool):
        return 1 if value else 0
    text = str(value).strip()
    if text.lower() in {"true", "t", "yes", "y"}:
        return 1
    if text.lower() in {"false", "f", "no", "n"}:
        return 0
    try:
        return int(float(text))
    except ValueError:
        return 0


def ensure_column(cur: sqlite3.Cursor, table_name: str, column_name: str, column_type: str) -> None:
    cols = {row[1] for row in cur.execute(f'PRAGMA table_info({table_name})').fetchall()}
    if column_name not in cols:
        cur.execute(f'ALTER TABLE {table_name} ADD COLUMN {column_name} {column_type}')


def department_for_table(table_name: str) -> tuple[str, str]:
    return DEPARTMENT_MAP.get(table_name.lower(), (table_name.upper(), table_name.replace("_", " ").title()))


def executive_department_for_council_type(council_type_id: Any) -> tuple[str, str]:
    try:
        council_id = int(council_type_id) if council_type_id is not None else None
    except (TypeError, ValueError):
        council_id = None

    if council_id == 1:
        return "COS", "Office of the Council Secretary"
    if council_id in {2, 3}:
        return "TOC", "Office of the Town Clerk"
    return "EXEC", "Executive Management"


def create_assignment_exception_support(cur: sqlite3.Cursor) -> None:
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS payroll_assignment_exception (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id TEXT NOT NULL,
            exception_type TEXT NOT NULL,
            effective_position_title TEXT,
            effective_department_name TEXT,
            effective_salary_scale_code TEXT,
            official_position_code TEXT,
            official_position_title TEXT,
            official_salary_scale_code TEXT,
            structural_status TEXT NOT NULL DEFAULT 'ON_STRUCTURE',
            notes TEXT,
            approval_reference TEXT,
            effective_from TEXT NOT NULL,
            effective_to TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            UNIQUE (employee_id, exception_type, effective_from)
        )
        """
    )
    cur.execute(
        "CREATE INDEX IF NOT EXISTS idx_payroll_assignment_exception_active ON payroll_assignment_exception(employee_id, is_active, effective_from DESC)"
    )


def seed_known_assignment_exceptions(cur: sqlite3.Cursor) -> None:
    chisenga = cur.execute(
        """
        SELECT employee_id, establishment_position_code, position, salary_scale_code, establishment_department
        FROM employees
        WHERE lower(name) = 'chisenga chisenga'
        LIMIT 1
        """
    ).fetchone()
    if chisenga:
        employee_id, position_code, position_title, salary_scale_code, department_name = chisenga
        cur.execute(
            """
            INSERT OR IGNORE INTO payroll_assignment_exception (
                employee_id,
                exception_type,
                effective_position_title,
                effective_department_name,
                effective_salary_scale_code,
                official_position_code,
                official_position_title,
                official_salary_scale_code,
                structural_status,
                notes,
                approval_reference,
                effective_from,
                is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            """,
            (
                employee_id,
                'PERSONAL_TO_HOLDER_SCALE',
                position_title,
                department_name or 'Human Resources and Administration',
                'LGSS05',
                position_code,
                position_title,
                salary_scale_code,
                'ON_STRUCTURE',
                'Officer is personal-to-holder: retain Chief Human Resource Officer title but pay on LGSS/05 instead of the structural LGSS/06.',
                'USER-INSTRUCTION-2026-03-16',
                '2026-03-16',
            ),
        )

    david = cur.execute(
        """
        SELECT employee_id, establishment_position_code, position, salary_scale_code
        FROM employees
        WHERE lower(name) = 'david chibungo'
        LIMIT 1
        """
    ).fetchone()
    if david:
        employee_id, position_code, position_title, salary_scale_code = david
        cur.execute(
            """
            INSERT OR IGNORE INTO payroll_assignment_exception (
                employee_id,
                exception_type,
                effective_position_title,
                effective_department_name,
                effective_salary_scale_code,
                official_position_code,
                official_position_title,
                official_salary_scale_code,
                structural_status,
                notes,
                approval_reference,
                effective_from,
                is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            """,
            (
                employee_id,
                'TRANSFERRED_CAPACITY',
                'Chief Building Inspector',
                'Planning',
                normalize_scale(salary_scale_code) or 'LGSS06',
                position_code,
                position_title,
                normalize_scale(salary_scale_code) or 'LGSS06',
                'TRANSFERRED_CAPACITY',
                'Officer transferred to Chilanga in the same capacity although the Town Council establishment does not carry a Chief Building Inspector post.',
                'USER-INSTRUCTION-2026-03-16',
                '2026-03-16',
            ),
        )

    chilanga_watchmen = cur.execute(
        """
        SELECT employee_id, establishment_position_code, position, salary_scale_code, establishment_department
        FROM employees
        WHERE lower(COALESCE(position, '')) = 'watchman'
          AND lower(COALESCE(district, '')) = 'chilanga'
        """
    ).fetchall()
    for watchman in chilanga_watchmen:
        employee_id, position_code, position_title, salary_scale_code, department_name = watchman
        cur.execute(
            """
            INSERT OR IGNORE INTO payroll_assignment_exception (
                employee_id,
                exception_type,
                effective_position_title,
                effective_department_name,
                effective_salary_scale_code,
                official_position_code,
                official_position_title,
                official_salary_scale_code,
                structural_status,
                notes,
                approval_reference,
                effective_from,
                is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            """,
            (
                employee_id,
                'TRANSFERRED_CAPACITY',
                'Watchman',
                department_name or 'Human Resources and Administration',
                normalize_scale(salary_scale_code),
                position_code,
                position_title or 'Watchman',
                normalize_scale(salary_scale_code),
                'TRANSFERRED_CAPACITY',
                'Chilanga Town Council exception: retain Watchman position although the Town Council establishment does not carry a Watchman post.',
                'USER-INSTRUCTION-2026-03-19',
                '2026-03-19',
            ),
        )

    memory = cur.execute(
        """
        SELECT employee_id, salary_scale_code
        FROM employees
        WHERE lower(trim(COALESCE(name, ''))) = 'memory muselekwa'
        LIMIT 1
        """
    ).fetchone()
    if memory:
        employee_id, salary_scale_code = memory
        cur.execute(
            """
            INSERT OR IGNORE INTO payroll_assignment_exception (
                employee_id,
                exception_type,
                effective_position_title,
                effective_department_name,
                effective_salary_scale_code,
                official_position_code,
                official_position_title,
                official_salary_scale_code,
                structural_status,
                notes,
                approval_reference,
                effective_from,
                is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            """,
            (
                employee_id,
                'TRANSFERRED_CAPACITY',
                'Data Entry Clerk',
                'Planning',
                'LGSS13',
                'PLAN-DATA-TOWN',
                'Data Entry Clerk',
                'LGSS18',
                'TRANSFERRED_CAPACITY',
                'Officer transferred from City Council to Chilanga Town Council retaining LGSS/13 salary scale; Town structural post carries LGSS/18.',
                'USER-INSTRUCTION-2026-03-19',
                '2026-03-19',
            ),
        )

    kelvin = cur.execute(
        """
        SELECT employee_id, salary_scale_code
        FROM employees
        WHERE lower(trim(COALESCE(name, ''))) = 'kelvin bupe'
        LIMIT 1
        """
    ).fetchone()
    if kelvin:
        employee_id, salary_scale_code = kelvin
        cur.execute(
            """
            INSERT OR IGNORE INTO payroll_assignment_exception (
                employee_id,
                exception_type,
                effective_position_title,
                effective_department_name,
                effective_salary_scale_code,
                official_position_code,
                official_position_title,
                official_salary_scale_code,
                structural_status,
                notes,
                approval_reference,
                effective_from,
                is_active
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            """,
            (
                employee_id,
                'PERSONAL_TO_HOLDER_SCALE',
                'Assistant Foreman',
                'Engineering',
                salary_scale_code or 'LGSS17',
                'ENG-ARCH-ASSTFORE-MC',
                'Assistant Foreman',
                'LGSS17',
                'PERSONAL_TO_HOLDER_SCALE',
                'Assistant Foreman post does not exist in the Chilanga Town Council establishment; officer was appointed to this post and holds it on a personal-to-holder basis.',
                'USER-INSTRUCTION-2026-03-19',
                '2026-03-19',
            ),
        )


def build_establishment_table(cur: sqlite3.Cursor) -> None:
    cur.execute("DROP TABLE IF EXISTS payroll_establishment_position")
    cur.execute(
        """
        CREATE TABLE payroll_establishment_position (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            source_table TEXT NOT NULL,
            department_code TEXT NOT NULL,
            department_name TEXT NOT NULL,
            position_code TEXT NOT NULL,
            position_title TEXT NOT NULL,
            normalized_title TEXT NOT NULL,
            salary_scale_raw TEXT,
            salary_scale_code TEXT,
            authorized_establishment INTEGER NOT NULL DEFAULT 0,
            reports_to_position_code TEXT,
            unit_ref TEXT,
            section_ref TEXT,
            stream_ref TEXT,
            council_type_id INTEGER,
            level_no INTEGER,
            is_head_of_unit INTEGER NOT NULL DEFAULT 0,
            is_head_of_section INTEGER NOT NULL DEFAULT 0,
            standard_id TEXT,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            UNIQUE (source_table, position_code)
        )
        """
    )

    table_names = [row[0] for row in cur.execute(POSITION_TABLE_QUERY).fetchall()]

    inserted = 0
    for table_name in table_names:
        default_department_code, default_department_name = department_for_table(table_name)
        rows = cur.execute(f'SELECT * FROM "{table_name}"').fetchall()
        for raw_row in rows:
            row = dict(raw_row)
            department_code = default_department_code
            department_name = default_department_name
            source_department_name = row.get("department_name") or row.get("department")
            if source_department_name:
                department_name = str(source_department_name).strip()
            if table_name.lower() in {"executive_positions", "toc_positions", "toc_city_positions"}:
                inferred_council_type_id = row.get("council_type_id")
                if inferred_council_type_id is None and table_name.lower() == "toc_city_positions":
                    inferred_council_type_id = 3
                department_code, department_name = executive_department_for_council_type(inferred_council_type_id)
            raw_pid = row.get("position_id")
            try:
                int(raw_pid)  # numeric position_id — prefer standard_id to avoid cross-table collisions
                position_code = row.get("standard_id") or str(raw_pid)
            except (TypeError, ValueError):
                position_code = raw_pid or row.get("standard_id") or row.get("id")
            position_code = normalize_position_code(position_code)
            position_title = row.get("title") or row.get("position_title") or str(position_code)
            department_name = normalize_department_for_storage(department_name, position_title=position_title)
            if department_name == "Human Resources and Administration":
                department_code = "HRA"
            salary_scale_raw = row.get("salary_scale")
            establishment_value = (
                row.get("establishment_count")
                if "establishment_count" in row
                else row.get("establishment")
                if "establishment" in row
                else row.get("proposed_establishment")
            )
            cur.execute(
                """
                INSERT INTO payroll_establishment_position (
                    source_table,
                    department_code,
                    department_name,
                    position_code,
                    position_title,
                    normalized_title,
                    salary_scale_raw,
                    salary_scale_code,
                    authorized_establishment,
                    reports_to_position_code,
                    unit_ref,
                    section_ref,
                    stream_ref,
                    council_type_id,
                    level_no,
                    is_head_of_unit,
                    is_head_of_section,
                    standard_id
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                (
                    table_name,
                    department_code,
                    department_name,
                    str(position_code),
                    str(position_title),
                    normalize_text(position_title),
                    salary_scale_raw,
                    normalize_scale(salary_scale_raw),
                    coerce_establishment(establishment_value),
                    row.get("reports_to"),
                    row.get("unit_id"),
                    row.get("section_id"),
                    row.get("stream"),
                    row.get("council_type_id") or row.get("council_id"),
                    row.get("level"),
                    coerce_bool(row.get("is_head_of_unit")),
                    coerce_bool(row.get("is_head_of_section")),
                    row.get("standard_id"),
                ),
            )
            inserted += 1

    cur.execute(
        """
        DELETE FROM payroll_establishment_position
        WHERE rowid IN (
            WITH ranked AS (
                SELECT
                    rowid,
                    ROW_NUMBER() OVER (
                        PARTITION BY position_code
                        ORDER BY
                            CASE WHEN source_table = 'positions' THEN 1 ELSE 0 END,
                            CASE WHEN department_name = 'General Establishment' THEN 1 ELSE 0 END,
                            CASE WHEN source_table LIKE 'AUTO_%' THEN 1 ELSE 0 END,
                            authorized_establishment DESC,
                            source_table,
                            department_name
                    ) AS rn
                FROM payroll_establishment_position
            )
            SELECT rowid
            FROM ranked
            WHERE rn > 1
        )
        """
    )
    cur.execute(
        "CREATE INDEX IF NOT EXISTS idx_payroll_establishment_position_match ON payroll_establishment_position(normalized_title, salary_scale_code, department_code)"
    )
    cur.execute(
        "CREATE INDEX IF NOT EXISTS idx_payroll_establishment_position_dept ON payroll_establishment_position(department_code, position_title)"
    )
    # Back-fill reports_to_position_code for HRA_Positions using HRA_ReportingLines
    hra_lines = cur.execute(
        "SELECT position_id, reports_to FROM HRA_ReportingLines"
    ).fetchall()
    for src_id, reports_to_raw in hra_lines:
        normalized_code = normalize_position_code(src_id)
        normalized_reports_to = normalize_position_code(reports_to_raw) if reports_to_raw else None
        cur.execute(
            """
            UPDATE payroll_establishment_position
            SET reports_to_position_code = ?
            WHERE position_code = ?
              AND source_table = 'HRA_Positions'
            """,
            (normalized_reports_to, normalized_code),
        )

    final_count = cur.execute("SELECT COUNT(*) FROM payroll_establishment_position").fetchone()[0]
    print(f"Created payroll_establishment_position with {final_count} rows")


def department_hint(value: Any) -> str:
    text = normalize_text(canonical_department_name(value))
    if not text:
        return ""
    replacements = {
        "human resources": "human resources and administration",
        "human resource": "human resources and administration",
        "administration": "human resources and administration",
        "it": "information and communication technology",
        "ict": "information and communication technology",
        "engineering": "engineering",
        "finance": "finance",
        "planning": "planning",
        "health": "health",
        "legal": "legal services",
        "security": "human resources and administration",
    }
    for key, replacement in replacements.items():
        if key in text:
            return replacement
    return text


def canonical_department_name(
    department_value: Any,
    employee_name: Any = None,
    position_title: Any = None,
) -> str:
    name_text = normalize_text(employee_name)
    if name_text == "francis ndola":
        return "Office of the Council Secretary"
    if name_text == "jane banda":
        return "Human Resources and Administration"

    dept_text = normalize_text(department_value)
    if not dept_text:
        position_text = normalize_text(position_title)
        if "human resource" in position_text:
            return "Human Resources and Administration"
        return ""

    if "administration" in dept_text or "human resource" in dept_text:
        return "Human Resources and Administration"

    return str(department_value).strip()


def normalize_department_for_storage(department_value: Any, position_title: Any = None) -> str:
    normalized = canonical_department_name(department_value, position_title=position_title)
    if normalized:
        return normalized
    if department_value is None:
        return ""
    return str(department_value).strip()


def normalize_authority_type(value: Any) -> str:
    return normalize_text(value)


def load_district_council_map(cur: sqlite3.Cursor) -> dict[str, int]:
    if not cur.execute("SELECT 1 FROM sqlite_master WHERE type='table' AND name='authorities'").fetchone():
        return {}

    rows = cur.execute(
        """
        SELECT lower(trim(authority_name)), lower(trim(authority_type))
        FROM authorities
        WHERE authority_name IS NOT NULL
          AND trim(authority_name) <> ''
          AND authority_type IS NOT NULL
          AND trim(authority_type) <> ''
        """
    ).fetchall()

    mapping: dict[str, set[int]] = {}
    for authority_name, authority_type in rows:
        council_type_id = AUTHORITY_TYPE_TO_COUNCIL_TYPE_ID.get(normalize_authority_type(authority_type))
        if council_type_id is None:
            continue
        for token in normalize_text(authority_name).split(" "):
            if len(token) < 4 or token in {"town", "city", "council", "municipal"}:
                continue
            mapping.setdefault(token, set()).add(council_type_id)

    result: dict[str, int] = {}
    for district, ids in mapping.items():
        if len(ids) == 1:
            result[district] = next(iter(ids))
    return result


def infer_council_type_from_text(value: Any) -> int | None:
    text = normalize_text(value)
    if not text:
        return None
    if "town" in text or " tc " in f" {text} ":
        return 1
    if "municipal" in text or " mun " in f" {text} " or " mc " in f" {text} ":
        return 2
    if "city" in text or " cit " in f" {text} " or " cc " in f" {text} ":
        return 3
    return None


def infer_employee_council_type(
    district: Any,
    service_number: Any,
    position_title: Any,
    district_council_map: dict[str, int],
) -> int | None:
    district_key = normalize_text(district)
    if district_key in district_council_map:
        return district_council_map[district_key]

    from_service = infer_council_type_from_text(service_number)
    if from_service is not None:
        return from_service

    return infer_council_type_from_text(position_title)


def choose_match(
    candidates: list[sqlite3.Row],
    row_department: Any,
    row_position_title: Any = None,
    council_type_hint: int | None = None,
) -> tuple[sqlite3.Row | None, str]:
    if not candidates:
        return None, "unmatched_no_candidate"
    if len(candidates) == 1:
        return candidates[0], "exact_unique"

    position_hint = normalize_text(row_position_title)
    if "council secretary" in position_hint:
        def council_secretary_priority(candidate: sqlite3.Row) -> int:
            source = normalize_text(candidate["source_table"])
            dept_name = normalize_text(candidate["department_name"])
            dept_code = normalize_text(candidate["department_code"])
            if source == "cos positions" or dept_code == "cos" or dept_name == "council secretary":
                return 0
            if source == "executive positions" or dept_name == "executive management":
                return 1
            if source == "legal positions" or dept_name == "legal services":
                return 2
            return 3

        ranked_cs = sorted(
            candidates,
            key=lambda candidate: (
                council_secretary_priority(candidate),
                0 if candidate["authorized_establishment"] > 0 else 1,
                normalize_text(candidate["department_name"]),
                normalize_text(candidate["position_title"]),
                candidate["position_code"],
            ),
        )
        if ranked_cs and council_secretary_priority(ranked_cs[0]) < 3:
            return ranked_cs[0], "council_secretary_preferred"

    if council_type_hint is not None:
        filtered = [candidate for candidate in candidates if candidate["council_type_id"] == council_type_hint]
        if len(filtered) == 1:
            return filtered[0], "council_type_resolved"
        if filtered:
            candidates = filtered

    dept_hint = department_hint(row_department)
    if dept_hint:
        filtered = []
        for candidate in candidates:
            candidate_dept = normalize_text(candidate["department_name"])
            if dept_hint in candidate_dept or candidate_dept in dept_hint:
                filtered.append(candidate)
        if len(filtered) == 1:
            return filtered[0], "department_resolved"
        if filtered:
            candidates = filtered

    unique_codes = {candidate["position_code"] for candidate in candidates}
    if len(unique_codes) == 1:
        return candidates[0], "filtered_unique_position"
    return sorted(
        candidates,
        key=lambda c: (
            0 if c["authorized_establishment"] > 0 else 1,
            normalize_text(c["department_name"]),
            normalize_text(c["position_title"]),
            c["position_code"],
        ),
    )[0], "forced_official_fallback"


def slugify_for_code(value: Any, max_len: int = 18) -> str:
    text = normalize_text(value).replace(" ", "-")
    if not text:
        return "unspecified"
    return text[:max_len]


def create_synthetic_establishment_for_employees(cur: sqlite3.Cursor) -> None:
    rows = cur.execute(
        """
        SELECT
            rowid,
            COALESCE(NULLIF(TRIM(position), ''), 'Unspecified Position') AS position_title,
            COALESCE(NULLIF(TRIM(salary_scale_code), ''), NULLIF(TRIM(REPLACE(REPLACE(UPPER(COALESCE(salary_scale, '')), '/', ''), '-', '')), ''), 'UNSCALED') AS salary_scale_code,
            COALESCE(council_type_id, 0) AS council_type_id,
            COALESCE(NULLIF(TRIM(establishment_department), ''), NULLIF(TRIM(department), ''), 'Unassigned') AS department_name
        FROM employees
        WHERE establishment_position_code IS NULL
        """
    ).fetchall()

    grouped: dict[tuple[str, str, int, str], list[int]] = {}
    for rowid, position_title, salary_scale_code, council_type_id, department_name in rows:
        key = (
            normalize_text(position_title),
            normalize_scale(salary_scale_code) or "UNSCALED",
            int(council_type_id or 0),
            department_name,
        )
        grouped.setdefault(key, []).append(rowid)

    counter = 1
    for (normalized_title, scale_code, council_type_id, department_name), employee_rowids in grouped.items():
        source_table = "AUTO_UNMAPPED_EMPLOYEE"
        position_code = f"AUTO-EMP-{counter:04d}-{slugify_for_code(normalized_title)}"
        position_title = normalized_title.title() if normalized_title else "Unspecified Position"
        authorized = len(employee_rowids)

        cur.execute(
            """
            INSERT OR IGNORE INTO payroll_establishment_position (
                source_table,
                department_code,
                department_name,
                position_code,
                position_title,
                normalized_title,
                salary_scale_raw,
                salary_scale_code,
                authorized_establishment,
                reports_to_position_code,
                unit_ref,
                section_ref,
                stream_ref,
                council_type_id,
                level_no,
                is_head_of_unit,
                is_head_of_section,
                standard_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, NULL, ?, NULL, 0, 0, ?)
            """,
            (
                source_table,
                "AUTO",
                department_name,
                position_code,
                position_title,
                normalized_title,
                scale_code,
                scale_code,
                authorized,
                council_type_id if council_type_id > 0 else None,
                position_code,
            ),
        )

        for rowid in employee_rowids:
            cur.execute(
                """
                UPDATE employees
                SET establishment_position_code=?,
                    authorized_establishment=?,
                    establishment_department=?,
                    council_type_id=COALESCE(council_type_id, ?),
                    establishment_match_method='synthetic_employee_fallback'
                WHERE rowid=?
                """,
                (
                    position_code,
                    authorized,
                    department_name,
                    council_type_id if council_type_id > 0 else None,
                    rowid,
                ),
            )
        counter += 1


def create_synthetic_establishment_for_payroll(cur: sqlite3.Cursor) -> None:
    rows = cur.execute(
        """
        SELECT
            rowid,
            COALESCE(NULLIF(TRIM(position_title), ''), 'Unspecified Position') AS position_title,
            COALESCE(NULLIF(TRIM(salary_scale_code), ''), NULLIF(TRIM(REPLACE(REPLACE(UPPER(COALESCE(salary_scale, '')), '/', ''), '-', '')), ''), 'UNSCALED') AS salary_scale_code,
            COALESCE(council_type_id, 0) AS council_type_id,
            COALESCE(NULLIF(TRIM(establishment_department), ''), NULLIF(TRIM(position_department), ''), 'Unassigned') AS department_name
        FROM payroll_run_items
        WHERE establishment_position_code IS NULL
        """
    ).fetchall()

    grouped: dict[tuple[str, str, int, str], list[int]] = {}
    for rowid, position_title, salary_scale_code, council_type_id, department_name in rows:
        key = (
            normalize_text(position_title),
            normalize_scale(salary_scale_code) or "UNSCALED",
            int(council_type_id or 0),
            department_name,
        )
        grouped.setdefault(key, []).append(rowid)

    counter = 1
    for (normalized_title, scale_code, council_type_id, department_name), run_rowids in grouped.items():
        source_table = "AUTO_UNMAPPED_PAYROLL"
        position_code = f"AUTO-PR-{counter:04d}-{slugify_for_code(normalized_title)}"
        position_title = normalized_title.title() if normalized_title else "Unspecified Position"
        authorized = len(run_rowids)

        cur.execute(
            """
            INSERT OR IGNORE INTO payroll_establishment_position (
                source_table,
                department_code,
                department_name,
                position_code,
                position_title,
                normalized_title,
                salary_scale_raw,
                salary_scale_code,
                authorized_establishment,
                reports_to_position_code,
                unit_ref,
                section_ref,
                stream_ref,
                council_type_id,
                level_no,
                is_head_of_unit,
                is_head_of_section,
                standard_id
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, NULL, NULL, NULL, ?, NULL, 0, 0, ?)
            """,
            (
                source_table,
                "AUTO",
                department_name,
                position_code,
                position_title,
                normalized_title,
                scale_code,
                scale_code,
                authorized,
                council_type_id if council_type_id > 0 else None,
                position_code,
            ),
        )

        for rowid in run_rowids:
            cur.execute(
                """
                UPDATE payroll_run_items
                SET establishment_position_code=?,
                    authorized_establishment=?,
                    establishment_department=?,
                    council_type_id=COALESCE(council_type_id, ?),
                    establishment_match_method='synthetic_payroll_fallback'
                WHERE rowid=?
                """,
                (
                    position_code,
                    authorized,
                    department_name,
                    council_type_id if council_type_id > 0 else None,
                    rowid,
                ),
            )
        counter += 1


def apply_chilanga_driver_override(cur: sqlite3.Cursor) -> None:
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'HRA-DRIVER-TOWN'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return

    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET establishment_position_code=?,
            authorized_establishment=?,
            establishment_department=?,
            council_type_id=COALESCE(?, council_type_id),
            establishment_match_method='chilanga_driver_override'
        WHERE lower(COALESCE(position, '')) = 'driver'
          AND lower(COALESCE(district, '')) = 'chilanga'
        """,
        (
            position_code,
            authorized_establishment,
            department_name,
            council_type_id,
        ),
    )

    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code=?,
            authorized_establishment=?,
            establishment_department=?,
            council_type_id=COALESCE(?, council_type_id),
            establishment_match_method='chilanga_driver_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT)
            FROM employees
            WHERE lower(COALESCE(position, '')) = 'driver'
              AND lower(COALESCE(district, '')) = 'chilanga'
        )
           OR (
                lower(COALESCE(position_title, '')) = 'driver'
            AND lower(COALESCE(employee_name, '')) IN (
                SELECT lower(name)
                FROM employees
                WHERE lower(COALESCE(position, '')) = 'driver'
                  AND lower(COALESCE(district, '')) = 'chilanga'
            )
        )
        """,
        (
            position_code,
            authorized_establishment,
            department_name,
            council_type_id,
        ),
    )


def apply_branco_chiyoma_override(cur: sqlite3.Cursor) -> None:
    """Override Branco Chiyoma's original position title to Engineering Assistant
    under Engineering Department, mapped to ENG-CIVIL-TECH-TC (Town Council)."""
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'ENG-CIVIL-TECH-TC'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return

    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET position                  = 'Engineering Assistant',
            department               = 'Engineering',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(COALESCE(name, '')) = 'branco chiyoma'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )

    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_title           = 'Engineering Assistant',
            position_department      = 'Engineering',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT)
            FROM employees
            WHERE lower(COALESCE(name, '')) = 'branco chiyoma'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_general_worker_engineering_override(cur: sqlite3.Cursor) -> None:
    preferred_codes_by_council = {
        1: ["ENG-GENWORK-TC", "ENG-PARK-WORK-TC"],
        2: ["ENG-MAINT-GENWORK-MC", "ENG-PARK-WORK-MC"],
        3: ["ENG-MAINT-GENWORK-CC", "ENG-PARK-WORK-CC"],
    }

    targets: dict[int, tuple[str, int, str, int | None]] = {}
    for council_type_id, preferred_codes in preferred_codes_by_council.items():
        target = cur.execute(
            f"""
            SELECT position_code, authorized_establishment, department_name, council_type_id
            FROM payroll_establishment_position
            WHERE position_code IN ({','.join('?' for _ in preferred_codes)})
            ORDER BY CASE position_code
                {''.join(f"WHEN '{code}' THEN {idx} " for idx, code in enumerate(preferred_codes))}
                ELSE 999
            END
            LIMIT 1
            """,
            preferred_codes,
        ).fetchone()
        if target:
            targets[council_type_id] = target

    for council_type_id, target in targets.items():
        position_code, authorized_establishment, department_name, target_council_type_id = target

        cur.execute(
            """
            UPDATE employees
            SET department = 'Engineering',
                establishment_position_code = ?,
                authorized_establishment = ?,
                establishment_department = ?,
                council_type_id = COALESCE(council_type_id, ?),
                establishment_match_method = 'general_worker_engineering_override'
            WHERE lower(trim(COALESCE(position, ''))) = 'general worker'
              AND lower(COALESCE(establishment_match_method, '')) = 'forced_official_fallback'
              AND COALESCE(council_type_id, ?) = ?
            """,
            (
                position_code,
                authorized_establishment,
                department_name,
                target_council_type_id,
                council_type_id,
                council_type_id,
            ),
        )

        cur.execute(
            """
            UPDATE payroll_run_items
            SET position_department = 'Engineering',
                establishment_position_code = ?,
                authorized_establishment = ?,
                establishment_department = ?,
                council_type_id = COALESCE(council_type_id, ?),
                establishment_match_method = 'general_worker_engineering_override'
            WHERE lower(trim(COALESCE(position_title, ''))) = 'general worker'
              AND lower(COALESCE(establishment_match_method, '')) = 'forced_official_fallback'
              AND COALESCE(council_type_id, ?) = ?
            """,
            (
                position_code,
                authorized_establishment,
                department_name,
                target_council_type_id,
                council_type_id,
                council_type_id,
            ),
        )


def apply_bupe_mulobe_override(cur: sqlite3.Cursor) -> None:
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'HRA-ADMIN-HEALTH-TOWN'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return

    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET position                  = 'Administrative Officer',
            department               = 'Human Resources and Administration',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(COALESCE(name, '')) = 'bupe mulobe'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )

    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_title           = 'Administrative Officer',
            position_department      = 'Human Resources and Administration',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT)
            FROM employees
            WHERE lower(COALESCE(name, '')) = 'bupe mulobe'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_memory_muselekwa_override(cur: sqlite3.Cursor) -> None:
    """Pin Memory Muselekwa to PLAN-DATA-TOWN (Town Data Entry Clerk) while
    retaining her LGSS/13 transfer scale documented via assignment exception."""
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'PLAN-DATA-TOWN'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(trim(COALESCE(name, ''))) = 'memory muselekwa'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(trim(COALESCE(name, ''))) = 'memory muselekwa'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_stanford_mweetwa_override(cur: sqlite3.Cursor) -> None:
    """Move Stanford Cheelo Mweetwa from COS-ORD-TOW-01 to HRA-ORDERLY-TOWN.
    Stanley Siyowi remains on COS-ORD-TOW-01 unchanged."""
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'HRA-ORDERLY-TOWN'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(trim(COALESCE(name, ''))) = 'stanford cheelo mweetwa'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(trim(COALESCE(name, ''))) = 'stanford cheelo mweetwa'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_oreen_hara_override(cur: sqlite3.Cursor) -> None:
    """Pin Oreen Hara to HRA-ADMIN-HEALTH-TOWN (confirmed placement)."""
    target = cur.execute(
        "SELECT position_code, authorized_establishment, department_name, council_type_id "
        "FROM payroll_establishment_position WHERE position_code = 'HRA-ADMIN-HEALTH-TOWN' LIMIT 1"
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target
    cur.execute(
        """
        UPDATE employees
        SET establishment_position_code = ?, authorized_establishment = ?,
            establishment_department = ?, council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(trim(COALESCE(name, ''))) = 'oreen hara'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code = ?, authorized_establishment = ?,
            establishment_department = ?, council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(trim(COALESCE(name, ''))) = 'oreen hara'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_fiance_chope_override(cur: sqlite3.Cursor) -> None:
    """Pin Fiance Chope to HRA-STENO-HEALTH-TOWN (confirmed placement)."""
    target = cur.execute(
        "SELECT position_code, authorized_establishment, department_name, council_type_id "
        "FROM payroll_establishment_position WHERE position_code = 'HRA-STENO-HEALTH-TOWN' LIMIT 1"
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target
    cur.execute(
        """
        UPDATE employees
        SET establishment_position_code = ?, authorized_establishment = ?,
            establishment_department = ?, council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(trim(COALESCE(name, ''))) = 'fiance chope'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code = ?, authorized_establishment = ?,
            establishment_department = ?, council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(trim(COALESCE(name, ''))) = 'fiance chope'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_stanely_siyowi_override(cur: sqlite3.Cursor) -> None:
    """Pin Stanely Siyowi to COS-ORD-TOW-01 (confirmed placement — maintain as instructed)."""
    target = cur.execute(
        "SELECT position_code, authorized_establishment, department_name, council_type_id "
        "FROM payroll_establishment_position WHERE position_code = 'COS-ORD-TOW-01' LIMIT 1"
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target
    cur.execute(
        """
        UPDATE employees
        SET establishment_position_code = ?, authorized_establishment = ?,
            establishment_department = ?, council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(trim(COALESCE(name, ''))) = 'stanely siyowi'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code = ?, authorized_establishment = ?,
            establishment_department = ?, council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(trim(COALESCE(name, ''))) = 'stanely siyowi'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_ufrix_katongo_override(cur: sqlite3.Cursor) -> None:
    """Pin Ufrix Katongo to HRA-REG-CLERK-TOWN with manual_position_override."""
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'HRA-REG-CLERK-TOWN'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(trim(COALESCE(name, ''))) = 'ufrix katongo'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(trim(COALESCE(name, ''))) = 'ufrix katongo'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_mireille_kwizera_override(cur: sqlite3.Cursor) -> None:
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'HRA-STENO-HEALTH-TOWN'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return

    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET position                  = 'Stenographer',
            department               = 'Human Resources and Administration',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(COALESCE(name, '')) = 'mireille kwizera'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )

    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_title           = 'Stenographer',
            position_department      = 'Human Resources and Administration',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT)
            FROM employees
            WHERE lower(COALESCE(name, '')) = 'mireille kwizera'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_fuli_mapulanga_override(cur: sqlite3.Cursor) -> None:
    """Move Fuli Caroline Mapulanga from FIN-STORE-OFF-CITY to FIN-HLTH-STORE-TOWN."""
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'FIN-HLTH-STORE-TOWN'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET department               = 'Finance',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE lower(COALESCE(name, '')) LIKE '%mapulanga%'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_department      = 'Finance',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(?, council_type_id),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(COALESCE(name, '')) LIKE '%mapulanga%'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def apply_higgins_siagwinta_override(cur: sqlite3.Cursor) -> None:
    """Set Higgins Siagwinta's department to Audit and pin him to the Town
    Council Assistant Internal Auditor post (AUD-AST-TOW-01)."""
    target = cur.execute(
        """
        SELECT position_code, authorized_establishment, department_name, council_type_id
        FROM payroll_establishment_position
        WHERE position_code = 'AUD-AST-TOW-01'
        LIMIT 1
        """
    ).fetchone()
    if not target:
        return
    position_code, authorized_establishment, department_name, council_type_id = target

    cur.execute(
        """
        UPDATE employees
        SET department               = 'Audit',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(council_type_id, ?),
            establishment_match_method = 'manual_position_override'
        WHERE lower(COALESCE(name, '')) LIKE '%siagwinta%'
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_department      = 'Audit',
            establishment_position_code = ?,
            authorized_establishment = ?,
            establishment_department = ?,
            council_type_id          = COALESCE(council_type_id, ?),
            establishment_match_method = 'manual_position_override'
        WHERE CAST(employee_id AS TEXT) IN (
            SELECT CAST(employee_id AS TEXT) FROM employees
            WHERE lower(COALESCE(name, '')) LIKE '%siagwinta%'
        )
        """,
        (position_code, authorized_establishment, department_name, council_type_id),
    )


def enrich_employees_and_payroll(cur: sqlite3.Cursor) -> None:
    district_council_map = load_district_council_map(cur)

    ensure_column(cur, "employees", "salary_scale_code", "TEXT")
    ensure_column(cur, "employees", "establishment_position_code", "TEXT")
    ensure_column(cur, "employees", "authorized_establishment", "INTEGER")
    ensure_column(cur, "employees", "establishment_department", "TEXT")
    ensure_column(cur, "employees", "council_type_id", "INTEGER")
    ensure_column(cur, "employees", "establishment_match_method", "TEXT")

    ensure_column(cur, "payroll_run_items", "position_title", "TEXT")
    ensure_column(cur, "payroll_run_items", "position_department", "TEXT")
    ensure_column(cur, "payroll_run_items", "salary_scale_code", "TEXT")
    ensure_column(cur, "payroll_run_items", "establishment_position_code", "TEXT")
    ensure_column(cur, "payroll_run_items", "authorized_establishment", "INTEGER")
    ensure_column(cur, "payroll_run_items", "establishment_department", "TEXT")
    ensure_column(cur, "payroll_run_items", "council_type_id", "INTEGER")
    ensure_column(cur, "payroll_run_items", "establishment_match_method", "TEXT")

    cur.execute(
        """
        UPDATE employees
        SET department = 'Human Resources and Administration'
        WHERE lower(trim(COALESCE(department, ''))) LIKE '%administration%'
           OR lower(trim(COALESCE(department, ''))) LIKE '%human resource%'
        """
    )
    cur.execute(
        """
        UPDATE employees
        SET department = 'Office of the Council Secretary'
        WHERE lower(trim(COALESCE(name, ''))) = 'francis ndola'
        """
    )
    cur.execute(
        """
        UPDATE employees
        SET department = 'Human Resources and Administration'
        WHERE lower(trim(COALESCE(name, ''))) = 'jane banda'
        """
    )

    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_department = 'Human Resources and Administration'
        WHERE lower(trim(COALESCE(position_department, ''))) LIKE '%administration%'
           OR lower(trim(COALESCE(position_department, ''))) LIKE '%human resource%'
        """
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_department = 'Office of the Council Secretary'
        WHERE lower(trim(COALESCE(employee_name, ''))) = 'francis ndola'
        """
    )
    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_department = 'Human Resources and Administration'
        WHERE lower(trim(COALESCE(employee_name, ''))) = 'jane banda'
        """
    )

    employees = cur.execute(
        "SELECT rowid, employee_id, name, position, salary_scale, department, district, local_authority_service_number FROM employees"
    ).fetchall()
    establishment_rows = cur.execute(
        "SELECT * FROM payroll_establishment_position"
    ).fetchall()

    by_title_scale: dict[tuple[str, str | None], list[sqlite3.Row]] = {}
    by_title_only: dict[str, list[sqlite3.Row]] = {}
    for row in establishment_rows:
        title_key = normalize_text(row["position_title"])
        scale_key = normalize_scale(row["salary_scale_code"])
        by_title_scale.setdefault((title_key, scale_key), []).append(row)
        by_title_only.setdefault(title_key, []).append(row)

    employee_council_by_id: dict[str, int] = {}

    for rowid, employee_id, employee_name, position, salary_scale, department, district, service_number in employees:
        title_key = normalize_text(position)
        scale_key = normalize_scale(salary_scale)
        normalized_department = canonical_department_name(department, employee_name=employee_name, position_title=position)
        council_type_hint = infer_employee_council_type(
            district=district,
            service_number=service_number,
            position_title=position,
            district_council_map=district_council_map,
        )
        if council_type_hint is not None:
            employee_council_by_id[str(employee_id)] = council_type_hint
        if "council secretary" in title_key:
            candidates = by_title_only.get(title_key, [])
        else:
            candidates = by_title_scale.get((title_key, scale_key), [])
            if not candidates:
                candidates = by_title_only.get(title_key, [])
        match, match_method = choose_match(candidates, normalized_department, position, council_type_hint)
        cur.execute(
            "UPDATE employees SET salary_scale_code=?, council_type_id=?, establishment_match_method=NULL WHERE rowid=?",
            (scale_key, council_type_hint, rowid),
        )
        if match is not None:
            cur.execute(
                """
                UPDATE employees
                SET establishment_position_code=?,
                    authorized_establishment=?,
                    establishment_department=?,
                    council_type_id=COALESCE(council_type_id, ?),
                    establishment_match_method=?
                WHERE rowid=?
                """,
                (
                    match["position_code"],
                    match["authorized_establishment"],
                    match["department_name"],
                    match["council_type_id"],
                    match_method,
                    rowid,
                ),
            )

    create_synthetic_establishment_for_employees(cur)

    cur.execute(
        """
        UPDATE payroll_run_items
        SET position_title = (
                SELECT e.position FROM employees e
                WHERE CAST(e.employee_id AS TEXT) = CAST(payroll_run_items.employee_id AS TEXT)
                LIMIT 1
            ),
            position_department = (
                SELECT e.department FROM employees e
                WHERE CAST(e.employee_id AS TEXT) = CAST(payroll_run_items.employee_id AS TEXT)
                LIMIT 1
            ),
            salary_scale_code = REPLACE(REPLACE(UPPER(COALESCE(payroll_run_items.salary_scale, '')), '/', ''), '-', '')
        WHERE position_title IS NULL OR position_department IS NULL OR salary_scale_code IS NULL
        """
    )

    payroll_rows = cur.execute(
        "SELECT rowid, employee_id, employee_name, position_title, salary_scale, salary_scale_code, position_department, council_type_id FROM payroll_run_items"
    ).fetchall()
    for rowid, employee_id, employee_name, position_title, salary_scale, salary_scale_code, position_department, council_type_id in payroll_rows:
        title_key = normalize_text(position_title)
        scale_key = normalize_scale(salary_scale_code or salary_scale)
        normalized_department = canonical_department_name(position_department, employee_name=employee_name, position_title=position_title)
        council_type_hint = council_type_id or employee_council_by_id.get(str(employee_id))
        if "council secretary" in title_key:
            candidates = by_title_only.get(title_key, [])
        else:
            candidates = by_title_scale.get((title_key, scale_key), [])
            if not candidates:
                candidates = by_title_only.get(title_key, [])
        match, match_method = choose_match(candidates, normalized_department, position_title, council_type_hint)
        if match is not None:
            cur.execute(
                """
                UPDATE payroll_run_items
                SET establishment_position_code=?,
                    authorized_establishment=?,
                    establishment_department=?,
                    salary_scale_code=?,
                    council_type_id=COALESCE(council_type_id, ?),
                    establishment_match_method=?
                WHERE rowid=?
                """,
                (
                    match["position_code"],
                    match["authorized_establishment"],
                    match["department_name"],
                    scale_key,
                    match["council_type_id"],
                    match_method,
                    rowid,
                ),
            )

    cur.execute(
        """
        UPDATE payroll_run_items
        SET establishment_position_code = (
                SELECT e.establishment_position_code FROM employees e
                WHERE CAST(e.employee_id AS TEXT) = CAST(payroll_run_items.employee_id AS TEXT)
                LIMIT 1
            ),
            authorized_establishment = (
                SELECT e.authorized_establishment FROM employees e
                WHERE CAST(e.employee_id AS TEXT) = CAST(payroll_run_items.employee_id AS TEXT)
                LIMIT 1
            ),
            establishment_department = (
                SELECT e.establishment_department FROM employees e
                WHERE CAST(e.employee_id AS TEXT) = CAST(payroll_run_items.employee_id AS TEXT)
                LIMIT 1
            ),
            establishment_match_method = COALESCE(
                establishment_match_method,
                (
                    SELECT e.establishment_match_method FROM employees e
                    WHERE CAST(e.employee_id AS TEXT) = CAST(payroll_run_items.employee_id AS TEXT)
                    LIMIT 1
                ),
                'employee_inherited_match'
            ),
            council_type_id = COALESCE(
                council_type_id,
                (
                    SELECT e.council_type_id FROM employees e
                    WHERE CAST(e.employee_id AS TEXT) = CAST(payroll_run_items.employee_id AS TEXT)
                    LIMIT 1
                )
            )
        WHERE establishment_position_code IS NULL
        """
    )

    create_synthetic_establishment_for_payroll(cur)
    apply_chilanga_driver_override(cur)
    apply_branco_chiyoma_override(cur)
    apply_general_worker_engineering_override(cur)
    apply_bupe_mulobe_override(cur)
    apply_mireille_kwizera_override(cur)
    apply_fuli_mapulanga_override(cur)
    apply_higgins_siagwinta_override(cur)
    apply_memory_muselekwa_override(cur)
    apply_stanford_mweetwa_override(cur)
    apply_ufrix_katongo_override(cur)
    apply_oreen_hara_override(cur)
    apply_fiance_chope_override(cur)
    apply_stanely_siyowi_override(cur)


def create_views(cur: sqlite3.Cursor) -> None:
    cur.execute("DROP VIEW IF EXISTS vw_payroll_run_items_enriched")
    cur.execute(
        """
        CREATE VIEW vw_payroll_run_items_enriched AS
        WITH active_exception AS (
            SELECT pa1.*
            FROM payroll_assignment_exception pa1
            WHERE pa1.is_active = 1
              AND NOT EXISTS (
                  SELECT 1
                  FROM payroll_assignment_exception pa2
                  WHERE pa2.employee_id = pa1.employee_id
                    AND pa2.is_active = 1
                    AND pa2.effective_from > pa1.effective_from
              )
        )
        SELECT
            pri.run_item_id,
            pri.run_id,
            pri.employee_id,
            pri.employee_name,
            COALESCE(ae.effective_position_title, pri.position_title, e.position) AS position_title,
            COALESCE(ae.effective_department_name, pri.position_department, e.department, pep.department_name) AS department_name,
            COALESCE(ae.effective_salary_scale_code, pri.salary_scale_code, REPLACE(REPLACE(UPPER(COALESCE(pri.salary_scale, '')), '/', ''), '-', '')) AS salary_scale_code,
            pri.salary_scale AS salary_scale_raw,
            pri.notch_no,
            pri.basic_salary,
            pri.allowances_total,
            pri.gross_pay,
            pri.deductions_total,
            pri.net_pay,
            pri.taxable_pay,
            pri.paye_amount,
            pri.napsa_amount,
            pri.nhima_amount,
            pri.establishment_position_code,
            pri.authorized_establishment,
            pri.establishment_match_method,
            ae.exception_type AS assignment_exception_type,
            ae.structural_status AS assignment_structural_status,
            ae.notes AS assignment_exception_notes,
            pep.source_table AS establishment_source_table,
            pep.department_code AS establishment_department_code,
            pep.department_name AS establishment_department_name,
            pep.council_type_id AS establishment_council_type_id,
            pep.position_title AS establishment_position_title
        FROM payroll_run_items pri
        LEFT JOIN employees e
            ON CAST(e.employee_id AS TEXT) = CAST(pri.employee_id AS TEXT)
        LEFT JOIN active_exception ae
            ON ae.employee_id = CAST(pri.employee_id AS TEXT)
        LEFT JOIN payroll_establishment_position pep
            ON pep.position_code = pri.establishment_position_code
        """
    )

    cur.execute("DROP VIEW IF EXISTS vw_payroll_employee_effective_assignment")
    cur.execute(
        """
        CREATE VIEW vw_payroll_employee_effective_assignment AS
        WITH active_exception AS (
            SELECT pa1.*
            FROM payroll_assignment_exception pa1
            WHERE pa1.is_active = 1
              AND NOT EXISTS (
                  SELECT 1
                  FROM payroll_assignment_exception pa2
                  WHERE pa2.employee_id = pa1.employee_id
                    AND pa2.is_active = 1
                    AND pa2.effective_from > pa1.effective_from
              )
        )
        SELECT
            CAST(e.employee_id AS TEXT) AS employee_id,
            e.name AS employee_name,
            e.position AS recorded_position_title,
            e.department AS recorded_department,
            e.salary_scale_code AS recorded_salary_scale_code,
            e.establishment_position_code,
            e.establishment_match_method,
            pep.position_title AS structural_position_title,
            pep.department_name AS structural_department_name,
            pep.salary_scale_code AS structural_salary_scale_code,
            ae.exception_type,
            ae.structural_status,
            ae.notes AS exception_notes,
            COALESCE(ae.effective_position_title, pep.position_title, e.position) AS effective_position_title,
            COALESCE(ae.effective_department_name, pep.department_name, e.establishment_department, e.department) AS effective_department_name,
            COALESCE(ae.effective_salary_scale_code, pep.salary_scale_code, e.salary_scale_code) AS effective_salary_scale_code,
            COALESCE(ae.approval_reference, e.establishment_match_method) AS handling_reference
        FROM employees e
        LEFT JOIN payroll_establishment_position pep
            ON pep.position_code = e.establishment_position_code
        LEFT JOIN active_exception ae
            ON ae.employee_id = CAST(e.employee_id AS TEXT)
        """
    )

    cur.execute("DROP VIEW IF EXISTS vw_payroll_position_establishment_summary")
    cur.execute(
        """
        CREATE VIEW vw_payroll_position_establishment_summary AS
        WITH employee_fill AS (
            SELECT
                establishment_position_code,
                COUNT(*) AS employee_count
            FROM employees
            WHERE establishment_position_code IS NOT NULL
            GROUP BY establishment_position_code
        ),
        payroll_fill AS (
            SELECT
                establishment_position_code,
                COUNT(*) AS payroll_count
            FROM payroll_run_items
            WHERE establishment_position_code IS NOT NULL
            GROUP BY establishment_position_code
        )
        SELECT
            pep.source_table,
            pep.department_code,
            pep.department_name,
            pep.council_type_id,
            pep.position_code,
            pep.position_title,
            pep.salary_scale_code,
            pep.authorized_establishment,
            COALESCE(ef.employee_count, 0) AS current_employees,
            COALESCE(pf.payroll_count, 0) AS payroll_rows,
            pep.authorized_establishment - COALESCE(ef.employee_count, 0) AS vacancies,
            COALESCE(pf.payroll_count, 0) - pep.authorized_establishment AS payroll_variance,
            CASE
                WHEN COALESCE(ef.employee_count, 0) = 0 THEN 'VACANT'
                WHEN COALESCE(ef.employee_count, 0) < pep.authorized_establishment THEN 'UNDER STAFFED'
                WHEN COALESCE(ef.employee_count, 0) = pep.authorized_establishment THEN 'FULLY STAFFED'
                ELSE 'OVER STAFFED'
            END AS staffing_status
        FROM payroll_establishment_position pep
        LEFT JOIN employee_fill ef
            ON ef.establishment_position_code = pep.position_code
        LEFT JOIN payroll_fill pf
            ON pf.establishment_position_code = pep.position_code
        """
    )

    cur.execute("DROP VIEW IF EXISTS vw_payroll_department_establishment_summary")
    cur.execute(
        """
        CREATE VIEW vw_payroll_department_establishment_summary AS
        SELECT
            department_code,
            department_name,
            COUNT(*) AS establishment_positions,
            SUM(authorized_establishment) AS authorized_establishment,
            SUM(current_employees) AS current_employees,
            SUM(payroll_rows) AS payroll_rows,
            SUM(vacancies) AS vacancies,
            SUM(payroll_variance) AS payroll_variance
        FROM vw_payroll_position_establishment_summary
        GROUP BY department_code, department_name
        ORDER BY department_name
        """
    )

    cur.execute("DROP VIEW IF EXISTS vw_payroll_unmatched_staff")
    cur.execute(
        """
        CREATE VIEW vw_payroll_unmatched_staff AS
        SELECT
            'EMPLOYEE' AS source_type,
            CAST(employee_id AS TEXT) AS source_employee_id,
            name AS employee_name,
            department,
            position AS position_title,
            salary_scale,
            salary_scale_code
        FROM employees
        WHERE establishment_position_code IS NULL
        UNION ALL
        SELECT
            'PAYROLL' AS source_type,
            CAST(employee_id AS TEXT) AS source_employee_id,
            employee_name,
            position_department AS department,
            position_title,
            salary_scale,
            salary_scale_code
        FROM payroll_run_items
        WHERE establishment_position_code IS NULL
        """
    )

    cur.execute("DROP VIEW IF EXISTS vw_payroll_synthetic_establishment_cleanup")
    cur.execute(
        """
        CREATE VIEW vw_payroll_synthetic_establishment_cleanup AS
        WITH employee_rollup AS (
            SELECT
                establishment_position_code,
                GROUP_CONCAT(name, '; ') AS employee_names,
                GROUP_CONCAT(CAST(employee_id AS TEXT), '; ') AS employee_ids,
                COUNT(*) AS employee_count
            FROM employees
            WHERE establishment_position_code IS NOT NULL
            GROUP BY establishment_position_code
        )
        SELECT
            pep.position_code,
            pep.position_title,
            pep.department_name,
            pep.salary_scale_code,
            pep.authorized_establishment,
            pep.council_type_id,
            er.employee_count,
            er.employee_ids,
            er.employee_names,
            CASE
                WHEN pep.department_name IN ('Unassigned', '60', '98') THEN 'Review department classification and create official post'
                ELSE 'Create official org-structure post and replace synthetic mapping'
            END AS recommended_action,
            pep.source_table
        FROM payroll_establishment_position pep
        LEFT JOIN employee_rollup er
            ON er.establishment_position_code = pep.position_code
        WHERE pep.source_table IN ('AUTO_UNMAPPED_EMPLOYEE', 'AUTO_UNMAPPED_PAYROLL')
        ORDER BY pep.department_name, pep.position_title, pep.position_code
        """
    )

    cur.execute("DROP VIEW IF EXISTS vw_payroll_forced_official_matches")
    cur.execute(
        """
        CREATE VIEW vw_payroll_forced_official_matches AS
        WITH active_exception AS (
            SELECT pa1.*
            FROM payroll_assignment_exception pa1
            WHERE pa1.is_active = 1
              AND NOT EXISTS (
                  SELECT 1
                  FROM payroll_assignment_exception pa2
                  WHERE pa2.employee_id = pa1.employee_id
                    AND pa2.is_active = 1
                    AND pa2.effective_from > pa1.effective_from
              )
        )
        SELECT
            'EMPLOYEE' AS record_source,
            CAST(e.employee_id AS TEXT) AS record_id,
            e.name AS employee_name,
            e.position AS original_position_title,
            CASE
                WHEN lower(trim(COALESCE(e.position, ''))) = 'general worker' THEN 'Engineering'
                ELSE e.department
            END AS original_department,
            e.salary_scale_code AS original_salary_scale_code,
            e.establishment_match_method,
            pep.position_code AS matched_position_code,
            pep.position_title AS matched_position_title,
            pep.department_name AS matched_department_name,
            pep.salary_scale_code AS matched_salary_scale_code,
            pep.council_type_id,
            pep.source_table AS matched_source_table
        FROM employees e
        JOIN payroll_establishment_position pep
            ON pep.position_code = e.establishment_position_code
        LEFT JOIN active_exception ae
            ON ae.employee_id = CAST(e.employee_id AS TEXT)
        WHERE e.establishment_match_method = 'forced_official_fallback'
            AND pep.source_table NOT LIKE 'AUTO_%'
            AND ae.employee_id IS NULL
            AND upper(CAST(e.employee_id AS TEXT)) NOT LIKE '%VACANT%'
            AND upper(COALESCE(e.name, '')) NOT LIKE 'VACANT%'

        UNION ALL

        SELECT
            'PAYROLL' AS record_source,
            CAST(pri.run_item_id AS TEXT) AS record_id,
            pri.employee_name,
            pri.position_title AS original_position_title,
            CASE
                WHEN lower(trim(COALESCE(pri.position_title, ''))) = 'general worker' THEN 'Engineering'
                ELSE pri.position_department
            END AS original_department,
            pri.salary_scale_code AS original_salary_scale_code,
            pri.establishment_match_method,
            pep.position_code AS matched_position_code,
            pep.position_title AS matched_position_title,
            pep.department_name AS matched_department_name,
            pep.salary_scale_code AS matched_salary_scale_code,
            pep.council_type_id,
            pep.source_table AS matched_source_table
        FROM payroll_run_items pri
        JOIN payroll_establishment_position pep
            ON pep.position_code = pri.establishment_position_code
        LEFT JOIN active_exception ae
            ON ae.employee_id = CAST(pri.employee_id AS TEXT)
        WHERE pri.establishment_match_method = 'forced_official_fallback'
            AND pep.source_table NOT LIKE 'AUTO_%'
            AND ae.employee_id IS NULL
            AND upper(CAST(pri.employee_id AS TEXT)) NOT LIKE '%VACANT%'
            AND upper(COALESCE(pri.employee_name, '')) NOT LIKE 'VACANT%'
        ORDER BY record_source, employee_name, original_position_title
        """
    )


def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    create_assignment_exception_support(cur)
    build_establishment_table(cur)
    enrich_employees_and_payroll(cur)
    seed_known_assignment_exceptions(cur)
    create_views(cur)

    matched_employees = cur.execute(
        "SELECT COUNT(*) FROM employees WHERE establishment_position_code IS NOT NULL"
    ).fetchone()[0]
    total_employees = cur.execute("SELECT COUNT(*) FROM employees").fetchone()[0]
    matched_payroll = cur.execute(
        "SELECT COUNT(*) FROM payroll_run_items WHERE establishment_position_code IS NOT NULL"
    ).fetchone()[0]
    total_payroll = cur.execute("SELECT COUNT(*) FROM payroll_run_items").fetchone()[0]

    conn.commit()
    conn.close()

    print(f"Employees matched to establishment: {matched_employees}/{total_employees}")
    print(f"Payroll rows matched to establishment: {matched_payroll}/{total_payroll}")
    print(
        "Created views: vw_payroll_run_items_enriched, vw_payroll_position_establishment_summary, "
        "vw_payroll_department_establishment_summary, vw_payroll_unmatched_staff, "
        "vw_payroll_synthetic_establishment_cleanup, vw_payroll_employee_effective_assignment, "
        "vw_payroll_forced_official_matches"
    )


if __name__ == "__main__":
    main()
