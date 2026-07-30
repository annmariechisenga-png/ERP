import sqlite3
import uuid

def apply_2026_agreement():
    db_path = 'hr_platform.db'
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 1. Increment amount
    MONTHLY_INCREMENT = 710.0
    EFFECTIVE_DATE = '2026-01-01'
    SOURCE_DOC = 'Collective Agreement 2026'

    try:
        # Get scales in Divisions II, III, IV
        cursor.execute("""
            SELECT DISTINCT salary_scale, division, min_notch, max_notch
            FROM salary_scales_official
            WHERE division IN ('DIVISION_II', 'DIVISION_III', 'DIVISION_IV')
              AND effective_from = '2025-01-01'
        """)
        scales = cursor.fetchall()

        print(f"Found {len(scales)} scales to update for 2026.")

        for scale_code, division, min_notch, max_notch in scales:
            # Insert into salary_scales_official for 2026
            new_scale_id = uuid.uuid4().hex
            cursor.execute("""
                INSERT OR IGNORE INTO salary_scales_official 
                (scale_id, salary_scale, division, min_notch, max_notch, effective_from, authority_document, is_active)
                VALUES (?, ?, ?, ?, ?, ?, ?, 1)
            """, (new_scale_id, scale_code, division, min_notch, max_notch, EFFECTIVE_DATE, SOURCE_DOC))

            # Get 2025 notch values
            cursor.execute("""
                SELECT notch_no, annual_basic, monthly_basic
                FROM salary_notch_values
                WHERE scale_code = ? AND effective_from = '2025-01-01'
            """, (scale_code,))
            notches = cursor.fetchall()

            for notch_no, annual_2025, monthly_2025 in notches:
                new_monthly = monthly_2025 + MONTHLY_INCREMENT
                new_annual = new_monthly * 12

                # Insert into salary_notch_values
                cursor.execute("""
                    INSERT OR IGNORE INTO salary_notch_values
                    (scale_code, notch_no, annual_basic, monthly_basic, effective_from, source_doc)
                    VALUES (?, ?, ?, ?, ?, ?)
                """, (scale_code, notch_no, new_annual, new_monthly, EFFECTIVE_DATE, SOURCE_DOC))

                # Insert into salary_notch_values_official
                new_notch_val_id = uuid.uuid4().hex
                cursor.execute("""
                    INSERT OR IGNORE INTO salary_notch_values_official
                    (notch_value_id, salary_scale, notch_number, annual_amount, monthly_amount, effective_from, is_active)
                    VALUES (?, ?, ?, ?, ?, ?, 1)
                """, (new_notch_val_id, scale_code, notch_no, new_annual, new_monthly, EFFECTIVE_DATE))

        conn.commit()
        print("2026 Collective Agreement scales applied successfully.")

        # Update USSD server query to use 2026 values
        # Actually, let's keep it as is for now and I'll update it separately
        
    except Exception as e:
        print(f"Error: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    apply_2026_agreement()
