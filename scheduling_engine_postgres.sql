-- ===================================================
-- SCHEDULING ENGINE FOR MULTIPLE PAY DATES (POSTGRES)
-- ===================================================

ALTER TABLE local_authorities
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- 1. FUNCTION TO GENERATE PAYROLL SCHEDULES FOR ALL AUTHORITIES
CREATE OR REPLACE FUNCTION generate_payroll_schedules(
    p_year INTEGER,
    p_month INTEGER
) RETURNS TABLE (
    authority_code VARCHAR,
    scheduled_payment_date DATE,
    payslip_generation_date DATE
) AS $$
DECLARE
    v_authority RECORD;
    v_payment_date DATE;
    v_payslip_date DATE;
    v_last_day INTEGER;
BEGIN
    FOR v_authority IN
        SELECT authority_id, authority_code, standard_pay_day
        FROM local_authorities
        WHERE COALESCE(is_active, TRUE) = TRUE
    LOOP
        v_last_day := EXTRACT(
            DAY FROM (date_trunc('month', make_date(p_year, p_month, 1)) + interval '1 month - 1 day')
        );

        v_payment_date := make_date(
            p_year,
            p_month,
            LEAST(GREATEST(COALESCE(v_authority.standard_pay_day, 25), 1), v_last_day)
        );

        IF EXTRACT(DOW FROM v_payment_date) = 0 THEN
            v_payment_date := (v_payment_date - INTERVAL '2 days')::DATE;
        ELSIF EXTRACT(DOW FROM v_payment_date) = 6 THEN
            v_payment_date := (v_payment_date - INTERVAL '1 day')::DATE;
        END IF;

        v_payslip_date := (v_payment_date - INTERVAL '2 days')::DATE;

        INSERT INTO payroll_schedules (
            authority_id, period_year, period_month,
            scheduled_payment_date, payslip_generation_date,
            status
        ) VALUES (
            v_authority.authority_id, p_year, p_month,
            v_payment_date, v_payslip_date,
            'SCHEDULED'
        )
        ON CONFLICT (authority_id, period_year, period_month)
        DO UPDATE SET
            scheduled_payment_date = EXCLUDED.scheduled_payment_date,
            payslip_generation_date = EXCLUDED.payslip_generation_date,
            status = EXCLUDED.status;

        authority_code := v_authority.authority_code;
        scheduled_payment_date := v_payment_date;
        payslip_generation_date := v_payslip_date;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 2. FUNCTION TO CHECK PAYSLIP AVAILABILITY BEFORE PAYMENT
CREATE OR REPLACE FUNCTION validate_payslip_before_payment(
    p_authority_id UUID,
    p_schedule_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_payslip_count INTEGER;
    v_employee_count INTEGER;
    v_schedule RECORD;
BEGIN
    SELECT * INTO v_schedule
    FROM payroll_schedules
    WHERE schedule_id = p_schedule_id;

    SELECT COUNT(*) INTO v_employee_count
    FROM employment_history eh
    JOIN officers o ON eh.officer_id = o.officer_id
    WHERE eh.authority_id = p_authority_id
      AND eh.is_current = TRUE;

    SELECT COUNT(*) INTO v_payslip_count
    FROM payroll_run
    WHERE schedule_id = p_schedule_id;

    IF v_payslip_count < v_employee_count THEN
        RAISE NOTICE 'Missing payslips for % employees', (v_employee_count - v_payslip_count);
        RETURN FALSE;
    END IF;

    IF CURRENT_DATE > v_schedule.payslip_generation_date THEN
        RAISE NOTICE 'Payslips generated late: % > %', CURRENT_DATE, v_schedule.payslip_generation_date;
    END IF;

    UPDATE payroll_run
    SET payslip_available_date = CURRENT_TIMESTAMP
    WHERE schedule_id = p_schedule_id
      AND payslip_available_date IS NULL;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 3. PAYMENT PROCESSING WITH PAYSLIP VALIDATION
CREATE OR REPLACE FUNCTION process_authority_payment(
    p_authority_id UUID,
    p_schedule_id UUID
) RETURNS JSONB AS $$
DECLARE
    v_valid BOOLEAN;
    v_batch_id UUID;
    v_total_amount DECIMAL;
    v_employee_count INTEGER;
    v_schedule RECORD;
BEGIN
    v_valid := validate_payslip_before_payment(p_authority_id, p_schedule_id);

    IF NOT v_valid THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Cannot process payment: Missing payslips'
        );
    END IF;

    SELECT * INTO v_schedule FROM payroll_schedules WHERE schedule_id = p_schedule_id;

    SELECT SUM(net_pay), COUNT(*)
    INTO v_total_amount, v_employee_count
    FROM payroll_run
    WHERE schedule_id = p_schedule_id;

    INSERT INTO payment_batches (
        authority_id, schedule_id, batch_reference, batch_date,
        total_amount, employee_count, status
    ) VALUES (
        p_authority_id, p_schedule_id,
        'PAY-' || p_authority_id || '-' || to_char(CURRENT_DATE, 'YYYYMMDD'),
        CURRENT_DATE, COALESCE(v_total_amount, 0), COALESCE(v_employee_count, 0),
        'CREATED'
    ) RETURNING batch_id INTO v_batch_id;

    UPDATE payroll_run
    SET payment_status = 'PROCESSED',
        payment_due_date = v_schedule.scheduled_payment_date
    WHERE schedule_id = p_schedule_id;

    RETURN jsonb_build_object(
        'success', TRUE,
        'batch_id', v_batch_id,
        'authority_id', p_authority_id,
        'payment_date', v_schedule.scheduled_payment_date,
        'total_amount', COALESCE(v_total_amount, 0),
        'employee_count', COALESCE(v_employee_count, 0),
        'message', 'Payment batch created. Payslips already available.'
    );
END;
$$ LANGUAGE plpgsql;
