CREATE TABLE IF NOT EXISTS salary_advance_request (
    id BIGSERIAL PRIMARY KEY,
    request_number VARCHAR(40) NOT NULL UNIQUE,
    employee_id BIGINT NOT NULL,
    requested_amount NUMERIC(18,2) NOT NULL,
    reason VARCHAR(500) NOT NULL,
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    eligibility_checked BOOLEAN NOT NULL DEFAULT FALSE,
    eligibility_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    eligibility_checked_at TIMESTAMP,
    eligibility_checked_by VARCHAR(120),
    has_running_advance_at_check BOOLEAN,
    eligibility_notes VARCHAR(500),

    head_approver_title VARCHAR(30),
    head_approver_name VARCHAR(120),
    head_decision VARCHAR(20),
    head_decision_at TIMESTAMP,
    head_decision_notes VARCHAR(500),

    finance_officer_name VARCHAR(120),
    finance_decision VARCHAR(20),
    finance_decision_at TIMESTAMP,
    finance_decision_notes VARCHAR(500),

    disbursement_reference VARCHAR(80),
    disbursed_at TIMESTAMP,
    disbursed_by VARCHAR(120),
    disbursed_amount NUMERIC(18,2),

    status VARCHAR(40) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,

    CONSTRAINT fk_salary_advance_employee
        FOREIGN KEY (employee_id)
        REFERENCES erp_employee(id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_salary_advance_requested_amount
        CHECK (requested_amount > 0),

    CONSTRAINT chk_salary_advance_eligibility_status
        CHECK (eligibility_status IN ('PENDING', 'ELIGIBLE', 'INELIGIBLE')),

    CONSTRAINT chk_salary_advance_head_title
        CHECK (head_approver_title IS NULL OR head_approver_title IN ('COUNCIL_SECRETARY', 'TOWN_CLERK')),

    CONSTRAINT chk_salary_advance_head_decision
        CHECK (head_decision IS NULL OR head_decision IN ('APPROVED', 'REJECTED')),

    CONSTRAINT chk_salary_advance_finance_decision
        CHECK (finance_decision IS NULL OR finance_decision IN ('APPROVED', 'REJECTED')),

    CONSTRAINT chk_salary_advance_status
        CHECK (status IN (
            'SUBMITTED',
            'ELIGIBILITY_FAILED',
            'PENDING_HEAD_APPROVAL',
            'REJECTED_BY_HEAD',
            'PENDING_FINANCE_APPROVAL',
            'REJECTED_BY_FINANCE',
            'APPROVED_FOR_DISBURSEMENT',
            'DISBURSED',
            'CANCELLED'
        )),

    CONSTRAINT chk_salary_advance_head_after_eligibility
        CHECK (
            head_decision IS NULL
            OR eligibility_status = 'ELIGIBLE'
        ),

    CONSTRAINT chk_salary_advance_finance_after_head
        CHECK (
            finance_decision IS NULL
            OR head_decision = 'APPROVED'
        ),

    CONSTRAINT chk_salary_advance_disbursement_after_finance
        CHECK (
            disbursed_at IS NULL
            OR finance_decision = 'APPROVED'
        ),

    CONSTRAINT chk_salary_advance_disbursed_amount
        CHECK (
            disbursed_amount IS NULL
            OR disbursed_amount > 0
        )
);

CREATE INDEX IF NOT EXISTS idx_salary_advance_request_employee_created
    ON salary_advance_request(employee_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_salary_advance_request_status_created
    ON salary_advance_request(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_salary_advance_request_eligibility
    ON salary_advance_request(eligibility_status, requested_at DESC);

CREATE TABLE IF NOT EXISTS salary_advance_workflow_event (
    id BIGSERIAL PRIMARY KEY,
    salary_advance_request_id BIGINT NOT NULL,
    event_stage VARCHAR(40) NOT NULL,
    event_action VARCHAR(40) NOT NULL,
    actor_role VARCHAR(40) NOT NULL,
    actor_name VARCHAR(120),
    event_notes VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_salary_advance_workflow_request
        FOREIGN KEY (salary_advance_request_id)
        REFERENCES salary_advance_request(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_salary_advance_event_stage
        CHECK (event_stage IN (
            'APPLICATION',
            'ELIGIBILITY_CHECK',
            'HEAD_APPROVAL',
            'FINANCE_APPROVAL',
            'DISBURSEMENT'
        ))
);

CREATE INDEX IF NOT EXISTS idx_salary_advance_workflow_request_created
    ON salary_advance_workflow_event(salary_advance_request_id, created_at ASC);