-- V20: Officer career progression view
--
-- Corrected mappings vs draft:
--   officers.full_name            -> erp_employee.first_name || ' ' || last_name
--   officers.employee_number      -> erp_employee.employee_code
--   local_authorities.authority_name -> erp_authority_master.official_name
--   salary_notch_values table     -> salary_notch_values compatibility view (V18)
--   appointment_date (missing)    -> earliest employment_history.effective_date per officer

CREATE OR REPLACE VIEW v_officer_career_progression AS
SELECT
    e.name                                                     AS full_name,
    e.employee_id                                             AS employee_number,
    am.official_name                                          AS authority_name,
    eh.salary_scale,
    eh.notch_number                                           AS current_notch,
    curr_notch.monthly_amount                                 AS current_salary,

    service_start.service_start_date,

    (CURRENT_DATE - eh.effective_date)                        AS days_at_current_notch,
    GREATEST(0, 365 - (CURRENT_DATE - eh.effective_date))     AS days_to_next_increment,

    next_notch.monthly_amount                                 AS next_notch_salary,
    CASE
        WHEN next_notch.monthly_amount IS NOT NULL
            THEN (next_notch.monthly_amount - eh.monthly_salary)
        ELSE NULL
    END                                                       AS next_increase_amount,

    (eh.notch_number::TEXT || ' of 7')                        AS progression,
    ROUND(((eh.notch_number - 1) * 100.0 / 6), 1)             AS percent_to_max,

    CASE
        WHEN eh.notch_number = 7 THEN 'MAXIMUM_REACHED'
        WHEN (CURRENT_DATE - eh.effective_date) >= 365 THEN 'ELIGIBLE_NOW'
        ELSE 'NOT_YET_ELIGIBLE'
    END                                                       AS increment_eligibility,

    CASE
        WHEN eh.notch_number = 1 THEN 'ENTRY_LEVEL'
        WHEN eh.notch_number <= 3 THEN 'JUNIOR'
        WHEN eh.notch_number <= 5 THEN 'MID-LEVEL'
        WHEN eh.notch_number <= 6 THEN 'SENIOR'
        WHEN eh.notch_number = 7 THEN 'TOP_OF_SCALE'
    END                                                       AS career_stage

FROM employment_history eh
JOIN employees e
  ON eh.employee_id = e.employee_id
LEFT JOIN erp_authority_master am
  ON eh.authority_id::text = am.authority_id::text

-- Current notch salary row as at this employment effective date
LEFT JOIN LATERAL (
    SELECT snv.monthly_amount
      FROM salary_notch_values snv
     WHERE snv.salary_scale = eh.salary_scale
       AND snv.notch_number = eh.notch_number
       AND snv.effective_from <= eh.effective_date
     ORDER BY snv.effective_from DESC
     LIMIT 1
) curr_notch ON TRUE

-- Next notch salary row as at this employment effective date
LEFT JOIN LATERAL (
    SELECT snv2.monthly_amount
      FROM salary_notch_values snv2
     WHERE snv2.salary_scale = eh.salary_scale
       AND snv2.notch_number = eh.notch_number + 1
       AND snv2.effective_from <= eh.effective_date
     ORDER BY snv2.effective_from DESC
     LIMIT 1
) next_notch ON TRUE

-- Entry/service start date per officer
LEFT JOIN LATERAL (
    SELECT MIN(eh2.effective_date) AS service_start_date
      FROM employment_history eh2
     WHERE eh2.employee_id = eh.employee_id
) service_start ON TRUE

WHERE eh.is_current = TRUE;
