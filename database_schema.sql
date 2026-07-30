--
-- PostgreSQL database dump
--

\restrict s0J9LFmC6gWYCJ9HHrPQqUqTxChDehAY1XKag6afFba6PResuh6LZNQDmItUu9c

-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: allowance_types; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.allowance_types (
    allowance_code text NOT NULL,
    allowance_name text,
    calc_method text,
    default_value real,
    taxable bigint DEFAULT '1'::bigint,
    pensionable bigint DEFAULT '0'::bigint,
    active bigint DEFAULT '1'::bigint,
    source_doc text,
    show_on_payslip bigint DEFAULT '1'::bigint
);


ALTER TABLE public.allowance_types OWNER TO chisenga;

--
-- Name: approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.approval_chain (
    employee_id bigint NOT NULL,
    supervisor_id bigint,
    hod_id bigint,
    council_secretary_id bigint
);


ALTER TABLE public.approval_chain OWNER TO chisenga;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.audit_log (
    log_id bigint NOT NULL,
    action text,
    table_name text,
    record_name text,
    record_nrc text,
    reason text,
    performed_by text,
    performed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    local_authority text
);


ALTER TABLE public.audit_log OWNER TO chisenga;

--
-- Name: audit_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.audit_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '1'::bigint,
    is_head_of_unit boolean DEFAULT false,
    is_vacant boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.audit_positions OWNER TO chisenga;

--
-- Name: audit_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.audit_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_positions_position_id_seq OWNER TO chisenga;

--
-- Name: audit_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.audit_positions_position_id_seq OWNED BY public.audit_positions.position_id;


--
-- Name: audit_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.audit_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    head_of_institution_id text,
    council_type_id bigint,
    department text DEFAULT 'AUD'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_supervision OWNER TO chisenga;

--
-- Name: audit_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.audit_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_supervision_id_seq OWNER TO chisenga;

--
-- Name: audit_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.audit_supervision_id_seq OWNED BY public.audit_supervision.id;


--
-- Name: audit_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.audit_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint,
    head_position_id text
);


ALTER TABLE public.audit_units OWNER TO chisenga;

--
-- Name: audit_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.audit_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_units_unit_id_seq OWNER TO chisenga;

--
-- Name: audit_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.audit_units_unit_id_seq OWNED BY public.audit_units.unit_id;


--
-- Name: authorities; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.authorities (
    authority_prefix text NOT NULL,
    authority_name text,
    authority_type text
);


ALTER TABLE public.authorities OWNER TO chisenga;

--
-- Name: authority_codes; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.authority_codes (
    authority_name text NOT NULL,
    authority_code text
);


ALTER TABLE public.authority_codes OWNER TO chisenga;

--
-- Name: authority_master; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.authority_master (
    authority_id text NOT NULL,
    country_code text,
    province_code text,
    legacy_authority_code text,
    display_code text,
    authority_ref text,
    authority_name text,
    official_name text,
    authority_type text,
    status text DEFAULT 'active'::text,
    valid_from date,
    valid_to date
);


ALTER TABLE public.authority_master OWNER TO chisenga;

--
-- Name: calendar; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.calendar (
    day date NOT NULL,
    is_working_day bigint
);


ALTER TABLE public.calendar OWNER TO chisenga;

--
-- Name: central_payslip_archive; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.central_payslip_archive (
    archive_id text DEFAULT 'lower(hex(randomblob(16)))'::text NOT NULL,
    authority_id text,
    submission_id text,
    officer_id text,
    employee_number text,
    employee_name text,
    period_year bigint,
    period_month bigint,
    basic_salary real,
    housing_allowance real,
    total_allowances real,
    total_deductions real,
    net_pay real,
    paye_amount real,
    napsa_amount real,
    nhis_amount real,
    leave_earned real,
    leave_taken real,
    leave_balance real,
    payment_date text,
    payslip_generated_date text,
    payslip_data text,
    archived_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.central_payslip_archive OWNER TO chisenga;

--
-- Name: commercial_city_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.commercial_city_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '3'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.commercial_city_positions OWNER TO chisenga;

--
-- Name: commercial_city_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.commercial_city_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commercial_city_positions_position_id_seq OWNER TO chisenga;

--
-- Name: commercial_city_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.commercial_city_positions_position_id_seq OWNED BY public.commercial_city_positions.position_id;


--
-- Name: commercial_city_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.commercial_city_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    head_of_institution_id text,
    council_type_id bigint,
    department text DEFAULT 'COM'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.commercial_city_supervision OWNER TO chisenga;

--
-- Name: commercial_city_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.commercial_city_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commercial_city_supervision_id_seq OWNER TO chisenga;

--
-- Name: commercial_city_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.commercial_city_supervision_id_seq OWNED BY public.commercial_city_supervision.id;


--
-- Name: commercial_city_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.commercial_city_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint
);


ALTER TABLE public.commercial_city_units OWNER TO chisenga;

--
-- Name: commercial_city_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.commercial_city_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commercial_city_units_unit_id_seq OWNER TO chisenga;

--
-- Name: commercial_city_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.commercial_city_units_unit_id_seq OWNED BY public.commercial_city_units.unit_id;


--
-- Name: commercial_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.commercial_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '2'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.commercial_positions OWNER TO chisenga;

--
-- Name: commercial_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.commercial_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commercial_positions_position_id_seq OWNER TO chisenga;

--
-- Name: commercial_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.commercial_positions_position_id_seq OWNED BY public.commercial_positions.position_id;


--
-- Name: commercial_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.commercial_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    head_of_institution_id text,
    council_type_id bigint,
    department text DEFAULT 'COM'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.commercial_supervision OWNER TO chisenga;

--
-- Name: commercial_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.commercial_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commercial_supervision_id_seq OWNER TO chisenga;

--
-- Name: commercial_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.commercial_supervision_id_seq OWNED BY public.commercial_supervision.id;


--
-- Name: commercial_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.commercial_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint
);


ALTER TABLE public.commercial_units OWNER TO chisenga;

--
-- Name: commercial_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.commercial_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commercial_units_unit_id_seq OWNER TO chisenga;

--
-- Name: commercial_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.commercial_units_unit_id_seq OWNED BY public.commercial_units.unit_id;


--
-- Name: community_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.community_positions (
    position_id text,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    section_id bigint,
    council_type_id bigint,
    level bigint,
    is_head_of_section boolean DEFAULT false,
    is_head_of_unit boolean DEFAULT false,
    standard_id text,
    is_special_unit boolean DEFAULT false,
    specific_council_id bigint,
    special_unit_name text
);


ALTER TABLE public.community_positions OWNER TO chisenga;

--
-- Name: community_sections; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.community_sections (
    section_id bigint NOT NULL,
    section_name text,
    section_code text,
    council_type_id bigint,
    head_position_id text
);


ALTER TABLE public.community_sections OWNER TO chisenga;

--
-- Name: community_sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.community_sections_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.community_sections_section_id_seq OWNER TO chisenga;

--
-- Name: community_sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.community_sections_section_id_seq OWNED BY public.community_sections.section_id;


--
-- Name: community_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.community_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_secretary_id text,
    council_type_id bigint,
    department text DEFAULT 'COM'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.community_supervision OWNER TO chisenga;

--
-- Name: community_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.community_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.community_supervision_id_seq OWNER TO chisenga;

--
-- Name: community_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.community_supervision_id_seq OWNED BY public.community_supervision.id;


--
-- Name: community_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.community_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    section_id bigint,
    council_type_id bigint,
    head_position_id text,
    is_special_unit boolean DEFAULT false,
    specific_council_id bigint
);


ALTER TABLE public.community_units OWNER TO chisenga;

--
-- Name: community_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.community_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.community_units_unit_id_seq OWNER TO chisenga;

--
-- Name: community_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.community_units_unit_id_seq OWNED BY public.community_units.unit_id;


--
-- Name: compliance_issues; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.compliance_issues (
    issue_id text DEFAULT 'lower(hex(randomblob(16)))'::text NOT NULL,
    authority_id text,
    submission_id text,
    issue_type text,
    issue_severity text,
    issue_description text,
    days_late bigint,
    deadline_date text,
    submission_date text,
    affected_employees bigint,
    total_discrepancy real,
    resolution_status text DEFAULT 'OPEN'::text,
    resolution_notes text,
    resolved_by text,
    resolved_date text,
    created_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.compliance_issues OWNER TO chisenga;

--
-- Name: cos_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.cos_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '1'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.cos_positions OWNER TO chisenga;

--
-- Name: cos_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.cos_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cos_positions_position_id_seq OWNER TO chisenga;

--
-- Name: cos_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.cos_positions_position_id_seq OWNED BY public.cos_positions.position_id;


--
-- Name: cos_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.cos_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_type_id bigint,
    department text DEFAULT 'COS'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.cos_supervision OWNER TO chisenga;

--
-- Name: cos_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.cos_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cos_supervision_id_seq OWNER TO chisenga;

--
-- Name: cos_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.cos_supervision_id_seq OWNED BY public.cos_supervision.id;


--
-- Name: cos_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.cos_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint,
    head_position_id text
);


ALTER TABLE public.cos_units OWNER TO chisenga;

--
-- Name: cos_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.cos_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cos_units_unit_id_seq OWNER TO chisenga;

--
-- Name: cos_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.cos_units_unit_id_seq OWNED BY public.cos_units.unit_id;


--
-- Name: council_types; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.council_types (
    council_type_id bigint NOT NULL,
    council_type_code text,
    council_type_name text,
    head_of_council_title text,
    head_of_council_scale text
);


ALTER TABLE public.council_types OWNER TO chisenga;

--
-- Name: council_types_council_type_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.council_types_council_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.council_types_council_type_id_seq OWNER TO chisenga;

--
-- Name: council_types_council_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.council_types_council_type_id_seq OWNED BY public.council_types.council_type_id;


--
-- Name: councils; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.councils (
    council_id bigint NOT NULL,
    council_name text,
    top_authority text
);


ALTER TABLE public.councils OWNER TO chisenga;

--
-- Name: councils_council_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.councils_council_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.councils_council_id_seq OWNER TO chisenga;

--
-- Name: councils_council_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.councils_council_id_seq OWNED BY public.councils.council_id;


--
-- Name: deduction_types; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.deduction_types (
    deduction_code text NOT NULL,
    deduction_name text,
    deduction_category text,
    calculation_method text,
    calculation_basis text,
    employee_percentage real DEFAULT '0'::real,
    employer_percentage real DEFAULT '0'::real,
    legal_authority text,
    priority bigint DEFAULT '99'::bigint,
    is_mandatory bigint DEFAULT '0'::bigint,
    active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.deduction_types OWNER TO chisenga;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.departments (
    dept_code text NOT NULL,
    dept_name text
);


ALTER TABLE public.departments OWNER TO chisenga;

--
-- Name: duplicates_archive; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.duplicates_archive (
    province text,
    district text,
    name text,
    nrc_number text,
    sex text,
    date_of_birth text,
    "position" text,
    salary_scale text,
    local_authority_service_number text,
    date_of_first_appointment text,
    date_confirmed text,
    date_substantive_appointment text,
    date_reported text,
    academic_qualifications text,
    professional_qualifications text,
    acting_position text,
    acting_date text,
    department text,
    phone_number text,
    carried_forward_leave integer,
    days_availed integer,
    leave_taken integer,
    leave_commuted integer,
    leave_transferred_out integer,
    leave_balance integer,
    reason text
);


ALTER TABLE public.duplicates_archive OWNER TO chisenga;

--
-- Name: employee_allowances; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.employee_allowances (
    employee_id text NOT NULL,
    allowance_code text NOT NULL,
    calc_method text,
    value real,
    effective_from date NOT NULL,
    effective_to date,
    is_active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.employee_allowances OWNER TO chisenga;

--
-- Name: employee_deductions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.employee_deductions (
    employee_id text NOT NULL,
    deduction_code text NOT NULL,
    calc_method text,
    value real,
    effective_from text NOT NULL,
    effective_to text,
    is_active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.employee_deductions OWNER TO chisenga;

--
-- Name: employee_salary_notch; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.employee_salary_notch (
    employee_id text NOT NULL,
    scale_code text,
    notch_no bigint,
    effective_from date NOT NULL,
    effective_to date,
    is_active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.employee_salary_notch OWNER TO chisenga;

--
-- Name: employee_sequence; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.employee_sequence (
    authority_code text NOT NULL,
    year bigint NOT NULL,
    next_number bigint
);


ALTER TABLE public.employee_sequence OWNER TO chisenga;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.employees (
    province text,
    district text,
    name text,
    nrc_number text,
    sex text,
    date_of_birth text,
    "position" text,
    salary_scale text,
    local_authority_service_number text,
    date_of_first_appointment text,
    date_confirmed text,
    date_substantive_appointment text,
    date_reported text,
    academic_qualifications text,
    professional_qualifications text,
    acting_position text,
    acting_date text,
    department text,
    phone_number text,
    carried_forward_leave bigint,
    days_availed bigint,
    leave_taken bigint,
    leave_commuted bigint,
    leave_transferred_out bigint,
    leave_balance bigint,
    employee_id text NOT NULL,
    gender text,
    is_active boolean DEFAULT true,
    hire_date date,
    email text,
    phone text,
    supervisor_id bigint,
    notification_preference text DEFAULT 'Both'::text,
    salary_scale_code text,
    establishment_position_code text,
    authorized_establishment bigint,
    establishment_department text,
    council_type_id bigint,
    establishment_match_method text,
    union_code text,
    is_zapd_registered bigint DEFAULT '0'::bigint,
    handles_solid_waste bigint DEFAULT '0'::bigint,
    is_council_police bigint DEFAULT '0'::bigint,
    authority_code text,
    CONSTRAINT chk_vacant_ids CHECK ((((employee_id ~~ '%-VACANT'::text) AND (is_active = false)) OR (employee_id !~~ '%-VACANT'::text)))
);


ALTER TABLE public.employees OWNER TO chisenga;

--
-- Name: employment_history; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.employment_history (
    employment_id text DEFAULT 'lower(hex(randomblob(16)))'::text NOT NULL,
    employee_id text,
    authority_id text,
    salary_scale text,
    notch_number bigint,
    monthly_salary real,
    division text,
    approved_by text,
    approval_date text,
    approval_reference text,
    appointment_letter_url text,
    effective_date text,
    end_date text,
    is_current bigint DEFAULT '1'::bigint,
    created_at text DEFAULT CURRENT_TIMESTAMP,
    created_by text
);


ALTER TABLE public.employment_history OWNER TO chisenga;

--
-- Name: eng_leave_approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.eng_leave_approval_chain (
    chain_id bigint NOT NULL,
    position_id text,
    step_number bigint,
    approver_role text,
    approver_position_id text
);


ALTER TABLE public.eng_leave_approval_chain OWNER TO chisenga;

--
-- Name: eng_leave_approval_chain_chain_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.eng_leave_approval_chain_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eng_leave_approval_chain_chain_id_seq OWNER TO chisenga;

--
-- Name: eng_leave_approval_chain_chain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.eng_leave_approval_chain_chain_id_seq OWNED BY public.eng_leave_approval_chain.chain_id;


--
-- Name: eng_position_hierarchy; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.eng_position_hierarchy (
    hierarchy_id bigint NOT NULL,
    position_id text,
    position_title text,
    unit text,
    salary_scale text,
    establishment_count bigint,
    reports_to_position_id text,
    council_type text,
    council_type_id bigint,
    level bigint,
    is_head_of_unit boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    standard_id text
);


ALTER TABLE public.eng_position_hierarchy OWNER TO chisenga;

--
-- Name: eng_position_hierarchy_hierarchy_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.eng_position_hierarchy_hierarchy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eng_position_hierarchy_hierarchy_id_seq OWNER TO chisenga;

--
-- Name: eng_position_hierarchy_hierarchy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.eng_position_hierarchy_hierarchy_id_seq OWNED BY public.eng_position_hierarchy.hierarchy_id;


--
-- Name: eng_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.eng_positions (
    position_id text NOT NULL,
    title text,
    salary_scale text,
    establishment_count bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint,
    level bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.eng_positions OWNER TO chisenga;

--
-- Name: eng_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.eng_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    parent_unit_id bigint,
    council_type_id bigint
);


ALTER TABLE public.eng_units OWNER TO chisenga;

--
-- Name: eng_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.eng_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.eng_units_unit_id_seq OWNER TO chisenga;

--
-- Name: eng_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.eng_units_unit_id_seq OWNED BY public.eng_units.unit_id;


--
-- Name: executive_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.executive_positions (
    id bigint NOT NULL,
    title text,
    standard_id text,
    council_type_id bigint,
    is_council_secretary boolean DEFAULT false,
    is_head_of_department boolean DEFAULT false,
    establishment bigint DEFAULT '1'::bigint
);


ALTER TABLE public.executive_positions OWNER TO chisenga;

--
-- Name: executive_positions_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.executive_positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.executive_positions_id_seq OWNER TO chisenga;

--
-- Name: executive_positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.executive_positions_id_seq OWNED BY public.executive_positions.id;


--
-- Name: finance_leave_approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.finance_leave_approval_chain (
    chain_id bigint NOT NULL,
    position_id text,
    step_number bigint,
    approver_role text,
    approver_position_id text
);


ALTER TABLE public.finance_leave_approval_chain OWNER TO chisenga;

--
-- Name: finance_leave_approval_chain_chain_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.finance_leave_approval_chain_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finance_leave_approval_chain_chain_id_seq OWNER TO chisenga;

--
-- Name: finance_leave_approval_chain_chain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.finance_leave_approval_chain_chain_id_seq OWNED BY public.finance_leave_approval_chain.chain_id;


--
-- Name: finance_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.finance_positions (
    position_id text,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    section_id bigint,
    council_type_id bigint,
    level bigint,
    is_head_of_section boolean DEFAULT false,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.finance_positions OWNER TO chisenga;

--
-- Name: finance_sections; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.finance_sections (
    section_id bigint NOT NULL,
    section_name text,
    section_code text,
    council_type_id bigint,
    description text
);


ALTER TABLE public.finance_sections OWNER TO chisenga;

--
-- Name: finance_sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.finance_sections_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finance_sections_section_id_seq OWNER TO chisenga;

--
-- Name: finance_sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.finance_sections_section_id_seq OWNED BY public.finance_sections.section_id;


--
-- Name: finance_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.finance_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    section_id bigint,
    council_type_id bigint,
    parent_unit_id bigint
);


ALTER TABLE public.finance_units OWNER TO chisenga;

--
-- Name: finance_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.finance_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.finance_units_unit_id_seq OWNER TO chisenga;

--
-- Name: finance_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.finance_units_unit_id_seq OWNED BY public.finance_units.unit_id;


--
-- Name: health_leave_approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.health_leave_approval_chain (
    chain_id bigint NOT NULL,
    position_id text,
    step_number bigint,
    approver_role text,
    approver_position_id text
);


ALTER TABLE public.health_leave_approval_chain OWNER TO chisenga;

--
-- Name: health_leave_approval_chain_chain_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.health_leave_approval_chain_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_leave_approval_chain_chain_id_seq OWNER TO chisenga;

--
-- Name: health_leave_approval_chain_chain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.health_leave_approval_chain_chain_id_seq OWNED BY public.health_leave_approval_chain.chain_id;


--
-- Name: health_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.health_positions (
    position_id text NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    section_id bigint,
    council_type_id bigint,
    level bigint,
    is_head_of_section boolean DEFAULT false,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.health_positions OWNER TO chisenga;

--
-- Name: health_sections; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.health_sections (
    section_id bigint NOT NULL,
    section_name text,
    section_code text,
    council_type_id bigint,
    description text
);


ALTER TABLE public.health_sections OWNER TO chisenga;

--
-- Name: health_sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.health_sections_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_sections_section_id_seq OWNER TO chisenga;

--
-- Name: health_sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.health_sections_section_id_seq OWNED BY public.health_sections.section_id;


--
-- Name: health_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.health_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_secretary_id text,
    council_type_id bigint,
    department text DEFAULT 'HLT'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.health_supervision OWNER TO chisenga;

--
-- Name: health_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.health_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_supervision_id_seq OWNER TO chisenga;

--
-- Name: health_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.health_supervision_id_seq OWNED BY public.health_supervision.id;


--
-- Name: health_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.health_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    section_id bigint,
    council_type_id bigint,
    parent_unit_id bigint
);


ALTER TABLE public.health_units OWNER TO chisenga;

--
-- Name: health_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.health_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_units_unit_id_seq OWNER TO chisenga;

--
-- Name: health_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.health_units_unit_id_seq OWNED BY public.health_units.unit_id;


--
-- Name: holidays; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.holidays (
    holiday_date date NOT NULL,
    description text
);


ALTER TABLE public.holidays OWNER TO chisenga;

--
-- Name: hr_recipients; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hr_recipients (
    recipient_id bigint NOT NULL,
    employee_id bigint,
    email text,
    is_primary boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hr_recipients OWNER TO chisenga;

--
-- Name: hra_leave_approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hra_leave_approval_chain (
    position_id text,
    approval_chain text,
    authority_type text
);


ALTER TABLE public.hra_leave_approval_chain OWNER TO chisenga;

--
-- Name: hra_leaveapprovalchains; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hra_leaveapprovalchains (
    id bigint NOT NULL,
    position_id text,
    supervisor text,
    hod text,
    top_authority text
);


ALTER TABLE public.hra_leaveapprovalchains OWNER TO chisenga;

--
-- Name: hra_position_attributes; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hra_position_attributes (
    position_id text NOT NULL,
    authority_type text,
    title text,
    salary_scale text,
    establishment_count bigint
);


ALTER TABLE public.hra_position_attributes OWNER TO chisenga;

--
-- Name: hra_position_supervisors; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hra_position_supervisors (
    position_id text,
    supervisor_id text,
    authority_type text
);


ALTER TABLE public.hra_position_supervisors OWNER TO chisenga;

--
-- Name: hra_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hra_positions (
    position_id text NOT NULL,
    title text,
    salary_scale text,
    establishment bigint,
    council_id bigint,
    standard_id text
);


ALTER TABLE public.hra_positions OWNER TO chisenga;

--
-- Name: hra_reportinglines; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hra_reportinglines (
    id bigint NOT NULL,
    position_id text,
    reports_to text
);


ALTER TABLE public.hra_reportinglines OWNER TO chisenga;

--
-- Name: hra_reportinglines_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.hra_reportinglines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hra_reportinglines_id_seq OWNER TO chisenga;

--
-- Name: hra_reportinglines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.hra_reportinglines_id_seq OWNED BY public.hra_reportinglines.id;


--
-- Name: hra_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.hra_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_secretary_id text,
    council_id bigint,
    department text DEFAULT 'HRA'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.hra_supervision OWNER TO chisenga;

--
-- Name: hra_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.hra_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hra_supervision_id_seq OWNER TO chisenga;

--
-- Name: hra_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.hra_supervision_id_seq OWNED BY public.hra_supervision.id;


--
-- Name: ict_city_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.ict_city_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '3'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.ict_city_positions OWNER TO chisenga;

--
-- Name: ict_city_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.ict_city_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ict_city_positions_position_id_seq OWNER TO chisenga;

--
-- Name: ict_city_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.ict_city_positions_position_id_seq OWNED BY public.ict_city_positions.position_id;


--
-- Name: ict_city_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.ict_city_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    head_of_institution_id text,
    council_type_id bigint,
    department text DEFAULT 'ICT'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ict_city_supervision OWNER TO chisenga;

--
-- Name: ict_city_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.ict_city_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ict_city_supervision_id_seq OWNER TO chisenga;

--
-- Name: ict_city_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.ict_city_supervision_id_seq OWNED BY public.ict_city_supervision.id;


--
-- Name: ict_city_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.ict_city_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint
);


ALTER TABLE public.ict_city_units OWNER TO chisenga;

--
-- Name: ict_city_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.ict_city_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ict_city_units_unit_id_seq OWNER TO chisenga;

--
-- Name: ict_city_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.ict_city_units_unit_id_seq OWNED BY public.ict_city_units.unit_id;


--
-- Name: ict_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.ict_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '2'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.ict_positions OWNER TO chisenga;

--
-- Name: ict_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.ict_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ict_positions_position_id_seq OWNER TO chisenga;

--
-- Name: ict_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.ict_positions_position_id_seq OWNED BY public.ict_positions.position_id;


--
-- Name: ict_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.ict_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    head_of_institution_id text,
    council_type_id bigint,
    department text DEFAULT 'ICT'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ict_supervision OWNER TO chisenga;

--
-- Name: ict_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.ict_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ict_supervision_id_seq OWNER TO chisenga;

--
-- Name: ict_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.ict_supervision_id_seq OWNED BY public.ict_supervision.id;


--
-- Name: ict_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.ict_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint
);


ALTER TABLE public.ict_units OWNER TO chisenga;

--
-- Name: ict_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.ict_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ict_units_unit_id_seq OWNER TO chisenga;

--
-- Name: ict_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.ict_units_unit_id_seq OWNED BY public.ict_units.unit_id;


--
-- Name: immutable_audit_log; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.immutable_audit_log (
    log_id bigint NOT NULL,
    event_type text,
    council_id bigint,
    period_date text,
    approved_by text,
    approved_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    data_hash text,
    payload text,
    previous_hash text,
    signature text
);


ALTER TABLE public.immutable_audit_log OWNER TO chisenga;

--
-- Name: jd_review_queue; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.jd_review_queue (
    id bigint NOT NULL,
    jd_id bigint,
    suggested_standard_id text,
    confidence_score bigint,
    needs_review boolean DEFAULT true,
    reviewed_by text,
    review_date timestamp with time zone,
    approved boolean,
    notes text
);


ALTER TABLE public.jd_review_queue OWNER TO chisenga;

--
-- Name: jd_upload_queue; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.jd_upload_queue (
    id bigint NOT NULL,
    filename text,
    file_path text,
    upload_status text DEFAULT 'pending'::text,
    extracted_title text,
    suggested_standard_id text,
    confidence_score bigint,
    needs_review boolean DEFAULT true,
    uploaded_by text,
    upload_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.jd_upload_queue OWNER TO chisenga;

--
-- Name: jd_upload_queue_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.jd_upload_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jd_upload_queue_id_seq OWNER TO chisenga;

--
-- Name: jd_upload_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.jd_upload_queue_id_seq OWNED BY public.jd_upload_queue.id;


--
-- Name: job_description_documents; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.job_description_documents (
    id bigint NOT NULL,
    position_standard_id text,
    original_filename text,
    file_path text,
    file_type text,
    upload_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    position_title text,
    grade text,
    department text,
    council_type_id bigint,
    reports_to_standard_id text,
    is_current_version boolean DEFAULT true,
    version bigint DEFAULT '1'::bigint,
    is_current boolean DEFAULT true
);


ALTER TABLE public.job_description_documents OWNER TO chisenga;

--
-- Name: job_description_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.job_description_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_description_documents_id_seq OWNER TO chisenga;

--
-- Name: job_description_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.job_description_documents_id_seq OWNED BY public.job_description_documents.id;


--
-- Name: la_payroll_config; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.la_payroll_config (
    config_id text DEFAULT 'lower(hex(randomblob(16)))'::text NOT NULL,
    authority_id text,
    payslip_submission_deadline bigint DEFAULT '5'::bigint,
    payroll_data_deadline bigint DEFAULT '7'::bigint,
    compliance_officer_name text,
    compliance_officer_email text,
    compliance_officer_phone text,
    created_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.la_payroll_config OWNER TO chisenga;

--
-- Name: la_payroll_submissions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.la_payroll_submissions (
    submission_id text DEFAULT 'lower(hex(randomblob(16)))'::text NOT NULL,
    authority_id text,
    period_year bigint,
    period_month bigint,
    la_payroll_date text,
    submission_date text DEFAULT CURRENT_TIMESTAMP,
    submission_status text DEFAULT 'PENDING'::text,
    payroll_data text,
    compliance_check_passed bigint,
    compliance_check_notes text,
    compliance_officer_id text,
    compliance_check_date text
);


ALTER TABLE public.la_payroll_submissions OWNER TO chisenga;

--
-- Name: la_session_context; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.la_session_context (
    context_id bigint NOT NULL,
    authority_id text,
    set_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.la_session_context OWNER TO chisenga;

--
-- Name: leave_approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.leave_approval_chain (
    chain_id bigint NOT NULL,
    position_id text,
    step_number bigint,
    approver_role text,
    approver_position_id text
);


ALTER TABLE public.leave_approval_chain OWNER TO chisenga;

--
-- Name: leave_approval_chain_chain_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.leave_approval_chain_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.leave_approval_chain_chain_id_seq OWNER TO chisenga;

--
-- Name: leave_approval_chain_chain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.leave_approval_chain_chain_id_seq OWNED BY public.leave_approval_chain.chain_id;


--
-- Name: leave_balances; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.leave_balances (
    employee_id bigint NOT NULL,
    local_leave_balance bigint,
    vacation_leave_balance bigint
);


ALTER TABLE public.leave_balances OWNER TO chisenga;

--
-- Name: leave_policy; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.leave_policy (
    leave_type text,
    division text,
    accrual_rate real,
    max_days bigint,
    carry_forward bigint,
    eligibility text,
    fixed_days bigint,
    max_accumulation bigint,
    max_duration bigint,
    advance_notice bigint
);


ALTER TABLE public.leave_policy OWNER TO chisenga;

--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.leave_requests (
    request_id bigint NOT NULL,
    employee_id bigint,
    leave_type text,
    requested_days bigint,
    start_date date,
    end_date date,
    status text DEFAULT 'Pending'::text,
    current_approver_id bigint,
    approved_by_supervisor bigint,
    approved_by_hod bigint,
    approved_by_secretary bigint,
    hr_processed bigint DEFAULT '0'::bigint,
    resumption_date date,
    remaining_balance bigint,
    certificate_path text,
    certificate_received bigint DEFAULT '0'::bigint,
    allowance_granted bigint DEFAULT '0'::bigint,
    last_allowance_date date
);


ALTER TABLE public.leave_requests OWNER TO chisenga;

--
-- Name: leave_types; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.leave_types (
    leave_type_id bigint NOT NULL,
    leave_type_code text,
    leave_type_name text,
    description text,
    requires_approval boolean DEFAULT true,
    is_paid boolean DEFAULT true,
    is_cumulative boolean DEFAULT false,
    max_days_per_month bigint,
    max_days_per_year bigint,
    applicable_to text,
    requires_supervisor_notification boolean DEFAULT true,
    requires_hr_notification boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.leave_types OWNER TO chisenga;

--
-- Name: leave_types_leave_type_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.leave_types_leave_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.leave_types_leave_type_id_seq OWNER TO chisenga;

--
-- Name: leave_types_leave_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.leave_types_leave_type_id_seq OWNED BY public.leave_types.leave_type_id;


--
-- Name: leaveapprovalchains; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.leaveapprovalchains (
    id bigint NOT NULL,
    position_id text,
    supervisor text,
    hod text,
    top_authority text,
    position_standard_id text,
    approver_standard_id text
);


ALTER TABLE public.leaveapprovalchains OWNER TO chisenga;

--
-- Name: legal_leave_approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.legal_leave_approval_chain (
    chain_id bigint NOT NULL,
    position_id text,
    step_number bigint,
    approver_role text,
    approver_position_id text
);


ALTER TABLE public.legal_leave_approval_chain OWNER TO chisenga;

--
-- Name: legal_leave_approval_chain_chain_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.legal_leave_approval_chain_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legal_leave_approval_chain_chain_id_seq OWNER TO chisenga;

--
-- Name: legal_leave_approval_chain_chain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.legal_leave_approval_chain_chain_id_seq OWNED BY public.legal_leave_approval_chain.chain_id;


--
-- Name: legal_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.legal_positions (
    position_id text NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    section_id bigint,
    council_type_id bigint,
    level bigint,
    is_head_of_section boolean DEFAULT false,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.legal_positions OWNER TO chisenga;

--
-- Name: legal_sections; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.legal_sections (
    section_id bigint NOT NULL,
    section_name text,
    section_code text,
    council_type_id bigint,
    description text
);


ALTER TABLE public.legal_sections OWNER TO chisenga;

--
-- Name: legal_sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.legal_sections_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legal_sections_section_id_seq OWNER TO chisenga;

--
-- Name: legal_sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.legal_sections_section_id_seq OWNED BY public.legal_sections.section_id;


--
-- Name: legal_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.legal_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_secretary_id text,
    council_type_id bigint,
    department text DEFAULT 'LEG'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.legal_supervision OWNER TO chisenga;

--
-- Name: legal_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.legal_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legal_supervision_id_seq OWNER TO chisenga;

--
-- Name: legal_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.legal_supervision_id_seq OWNED BY public.legal_supervision.id;


--
-- Name: legal_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.legal_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    section_id bigint,
    council_type_id bigint,
    parent_unit_id bigint
);


ALTER TABLE public.legal_units OWNER TO chisenga;

--
-- Name: legal_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.legal_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legal_units_unit_id_seq OWNER TO chisenga;

--
-- Name: legal_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.legal_units_unit_id_seq OWNED BY public.legal_units.unit_id;


--
-- Name: length_of_stay; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.length_of_stay (
    employee_id text NOT NULL,
    date_reported text,
    years_stayed bigint,
    months_stayed bigint,
    last_updated text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.length_of_stay OWNER TO chisenga;

--
-- Name: local_authorities; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.local_authorities (
    authority_id text NOT NULL,
    authority_code text,
    authority_name text,
    payroll_cycle text DEFAULT 'MONTHLY'::text,
    standard_pay_day bigint,
    pay_day_frequency text,
    allows_split_payment bigint DEFAULT '0'::bigint,
    grace_period_days bigint DEFAULT '0'::bigint,
    max_pay_delay_days bigint DEFAULT '5'::bigint,
    annual_payroll_budget real,
    current_cash_position real,
    last_payroll_date text,
    next_payroll_date text,
    payroll_bank_account text,
    payroll_bank_branch text,
    payroll_contact_name text,
    payroll_contact_email text,
    payroll_contact_phone text,
    created_at text DEFAULT CURRENT_TIMESTAMP,
    is_active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.local_authorities OWNER TO chisenga;

--
-- Name: madison_parent_coverage_tiers; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.madison_parent_coverage_tiers (
    tier_id text NOT NULL,
    parent_count bigint,
    cover_min real,
    cover_max real,
    additional_rate_min real,
    additional_rate_max real,
    total_rate_min real,
    total_rate_max real,
    effective_from text,
    effective_to text,
    is_active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.madison_parent_coverage_tiers OWNER TO chisenga;

--
-- Name: mothers_day_acknowledgments; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.mothers_day_acknowledgments (
    acknowledgment_id bigint NOT NULL,
    tracking_id bigint,
    recipient_type text,
    recipient_id bigint,
    acknowledged_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    acknowledgment_method text DEFAULT 'System'::text,
    ip_address text,
    notes text
);


ALTER TABLE public.mothers_day_acknowledgments OWNER TO chisenga;

--
-- Name: mothers_day_leave_tracking; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.mothers_day_leave_tracking (
    tracking_id bigint NOT NULL,
    employee_id bigint,
    leave_date date,
    month_year text,
    supervisor_id bigint,
    supervisor_notified bigint DEFAULT '0'::bigint,
    supervisor_notification_date timestamp without time zone,
    supervisor_approved bigint DEFAULT '0'::bigint,
    supervisor_approval_date timestamp without time zone,
    hr_notified bigint DEFAULT '0'::bigint,
    hr_notification_date timestamp without time zone,
    hr_viewed bigint DEFAULT '0'::bigint,
    hr_viewed_date timestamp without time zone,
    status text DEFAULT 'Pending'::text,
    notification_method text DEFAULT 'Both'::text,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mothers_day_leave_tracking OWNER TO chisenga;

--
-- Name: mothers_day_leave_tracking_tracking_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.mothers_day_leave_tracking_tracking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mothers_day_leave_tracking_tracking_id_seq OWNER TO chisenga;

--
-- Name: mothers_day_leave_tracking_tracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.mothers_day_leave_tracking_tracking_id_seq OWNED BY public.mothers_day_leave_tracking.tracking_id;


--
-- Name: mothers_day_notification_log; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.mothers_day_notification_log (
    notification_id bigint NOT NULL,
    tracking_id bigint,
    recipient_type text,
    recipient_id bigint,
    recipient_name text,
    recipient_email text,
    notification_type text DEFAULT 'Email'::text,
    notification_subject text,
    notification_body text,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sent_by bigint,
    status text DEFAULT 'Sent'::text,
    error_message text,
    read_at timestamp without time zone
);


ALTER TABLE public.mothers_day_notification_log OWNER TO chisenga;

--
-- Name: notification_history; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.notification_history (
    history_id bigint NOT NULL,
    queue_id bigint,
    tracking_id bigint,
    recipient_type text,
    recipient_id bigint,
    recipient_name text,
    recipient_email text,
    recipient_phone text,
    notification_method text,
    subject text,
    message text,
    sms_message text,
    status text,
    sent_at timestamp without time zone,
    delivered_at timestamp without time zone,
    read_at timestamp without time zone,
    error_message text,
    created_at timestamp without time zone
);


ALTER TABLE public.notification_history OWNER TO chisenga;

--
-- Name: notification_queue; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.notification_queue (
    queue_id bigint NOT NULL,
    tracking_id bigint,
    recipient_type text,
    recipient_id bigint,
    recipient_name text,
    recipient_email text,
    recipient_phone text,
    notification_type text,
    subject text,
    message text,
    sms_message text,
    status text DEFAULT 'Pending'::text,
    sent_at timestamp without time zone,
    viewed_at timestamp without time zone,
    action_taken_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.notification_queue OWNER TO chisenga;

--
-- Name: overtime_requests; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.overtime_requests (
    overtime_id bigint NOT NULL,
    employee_id text,
    employee_name text,
    salary_scale text,
    division text,
    overtime_date text,
    start_time text,
    end_time text,
    hours_worked real,
    overtime_type text DEFAULT 'normal'::text,
    hourly_rate real,
    rate_multiplier real,
    amount_earned real,
    reason text,
    requested_by_employee_id text,
    requested_by_name text,
    requested_by_role text,
    is_self_request bigint DEFAULT '1'::bigint,
    requested_on_behalf_of_note text,
    request_initiated_at text DEFAULT CURRENT_TIMESTAMP,
    supervisor_approved text DEFAULT 'pending'::text,
    supervisor_approved_by text,
    supervisor_approved_by_name text,
    supervisor_approved_at text,
    supervisor_notes text,
    hod_approved text DEFAULT 'pending'::text,
    hod_approved_by text,
    hod_approved_by_name text,
    hod_approved_at text,
    hod_notes text,
    principal_officer_approved text DEFAULT 'pending'::text,
    principal_officer_approved_by text,
    principal_officer_approved_by_name text,
    principal_officer_approved_at text,
    principal_officer_notes text,
    audit_authorized text DEFAULT 'pending'::text,
    audit_authorized_by text,
    audit_authorized_by_name text,
    audit_authorized_at text,
    audit_notes text,
    audit_reference_number text,
    audit_query_response text,
    payroll_integrated bigint DEFAULT '0'::bigint,
    payroll_run_id bigint,
    payroll_month text,
    payroll_processed_at text,
    payment_status text DEFAULT 'pending'::text,
    payment_reference text,
    rejection_stage text,
    rejection_reason text,
    rejected_by text,
    rejected_at text,
    cancelled bigint DEFAULT '0'::bigint,
    cancelled_by text,
    cancelled_at text,
    cancellation_reason text,
    status text DEFAULT 'draft'::text,
    created_at text DEFAULT CURRENT_TIMESTAMP,
    updated_at text DEFAULT CURRENT_TIMESTAMP,
    notch_no bigint,
    monthly_salary real
);


ALTER TABLE public.overtime_requests OWNER TO chisenga;

--
-- Name: overtime_requests_overtime_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.overtime_requests_overtime_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.overtime_requests_overtime_id_seq OWNER TO chisenga;

--
-- Name: overtime_requests_overtime_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.overtime_requests_overtime_id_seq OWNED BY public.overtime_requests.overtime_id;


--
-- Name: payment_batches; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payment_batches (
    batch_id text NOT NULL,
    authority_id text,
    schedule_id text,
    batch_reference text,
    batch_date text,
    total_amount real,
    employee_count bigint,
    bank_file_generated_at text,
    bank_file_sent_at text,
    bank_confirmation_received bigint DEFAULT '0'::bigint,
    bank_confirmation_date text,
    bank_rejection_reason text,
    status text DEFAULT 'CREATED'::text
);


ALTER TABLE public.payment_batches OWNER TO chisenga;

--
-- Name: payment_delay_approvals; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payment_delay_approvals (
    delay_id text NOT NULL,
    authority_id text,
    schedule_id text,
    delay_days bigint,
    reason text,
    approved_by text,
    approval_date text,
    payslips_issued_on_time bigint DEFAULT '0'::bigint,
    notification_sent_to_employees bigint DEFAULT '0'::bigint,
    notification_date text
);


ALTER TABLE public.payment_delay_approvals OWNER TO chisenga;

--
-- Name: payroll_assignment_exception; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_assignment_exception (
    id bigint NOT NULL,
    employee_id text,
    exception_type text,
    effective_position_title text,
    effective_department_name text,
    effective_salary_scale_code text,
    official_position_code text,
    official_position_title text,
    official_salary_scale_code text,
    structural_status text DEFAULT 'ON_STRUCTURE'::text,
    notes text,
    approval_reference text,
    effective_from text,
    effective_to text,
    is_active bigint DEFAULT '1'::bigint,
    created_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payroll_assignment_exception OWNER TO chisenga;

--
-- Name: payroll_assignment_exception_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_assignment_exception_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_assignment_exception_id_seq OWNER TO chisenga;

--
-- Name: payroll_assignment_exception_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_assignment_exception_id_seq OWNED BY public.payroll_assignment_exception.id;


--
-- Name: payroll_establishment_position; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_establishment_position (
    id bigint NOT NULL,
    source_table text,
    department_code text,
    department_name text,
    position_code text,
    position_title text,
    normalized_title text,
    salary_scale_raw text,
    salary_scale_code text,
    authorized_establishment bigint DEFAULT '0'::bigint,
    reports_to_position_code text,
    unit_ref text,
    section_ref text,
    stream_ref text,
    council_type_id bigint,
    level_no bigint,
    is_head_of_unit bigint DEFAULT '0'::bigint,
    is_head_of_section bigint DEFAULT '0'::bigint,
    standard_id text,
    created_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payroll_establishment_position OWNER TO chisenga;

--
-- Name: payroll_establishment_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_establishment_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_establishment_position_id_seq OWNER TO chisenga;

--
-- Name: payroll_establishment_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_establishment_position_id_seq OWNED BY public.payroll_establishment_position.id;


--
-- Name: payroll_integrity_log; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_integrity_log (
    log_id text NOT NULL,
    payroll_id text,
    event_type text,
    message text,
    created_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payroll_integrity_log OWNER TO chisenga;

--
-- Name: payroll_periods; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_periods (
    period_id bigint NOT NULL,
    period_code text,
    start_date date,
    end_date date,
    pay_date date,
    status text DEFAULT 'OPEN'::text
);


ALTER TABLE public.payroll_periods OWNER TO chisenga;

--
-- Name: payroll_periods_period_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_periods_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_periods_period_id_seq OWNER TO chisenga;

--
-- Name: payroll_periods_period_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_periods_period_id_seq OWNED BY public.payroll_periods.period_id;


--
-- Name: payroll_run; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_run (
    payroll_id text NOT NULL,
    schedule_id text,
    authority_id text,
    employee_id text,
    payslip_number text,
    document_verification_code text,
    payslip_available_date text,
    payslip_viewed_date text,
    payslip_delivery_method text,
    payment_due_date text,
    payment_actual_date text,
    payment_status text DEFAULT 'PENDING'::text,
    payment_reference text,
    basic_salary real,
    total_allowances real,
    total_deductions real,
    net_pay real,
    created_at text DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payroll_run OWNER TO chisenga;

--
-- Name: payroll_run_item_allowances; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_run_item_allowances (
    item_allowance_id bigint NOT NULL,
    run_item_id bigint,
    allowance_code text,
    allowance_name text,
    calc_method text,
    calc_value real,
    amount real,
    visible_on_payslip bigint DEFAULT '1'::bigint
);


ALTER TABLE public.payroll_run_item_allowances OWNER TO chisenga;

--
-- Name: payroll_run_item_allowances_item_allowance_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_run_item_allowances_item_allowance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_run_item_allowances_item_allowance_id_seq OWNER TO chisenga;

--
-- Name: payroll_run_item_allowances_item_allowance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_run_item_allowances_item_allowance_id_seq OWNED BY public.payroll_run_item_allowances.item_allowance_id;


--
-- Name: payroll_run_item_deductions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_run_item_deductions (
    item_deduction_id bigint NOT NULL,
    run_item_id bigint,
    deduction_code text,
    deduction_name text,
    deduction_category text,
    authority_ref text,
    calc_method text,
    calc_value real,
    amount real
);


ALTER TABLE public.payroll_run_item_deductions OWNER TO chisenga;

--
-- Name: payroll_run_item_deductions_item_deduction_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_run_item_deductions_item_deduction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_run_item_deductions_item_deduction_id_seq OWNER TO chisenga;

--
-- Name: payroll_run_item_deductions_item_deduction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_run_item_deductions_item_deduction_id_seq OWNED BY public.payroll_run_item_deductions.item_deduction_id;


--
-- Name: payroll_run_item_obligations; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_run_item_obligations (
    item_obligation_id bigint NOT NULL,
    run_item_id bigint,
    employee_id text,
    scheme_code text,
    obligation_type text,
    employee_amount real DEFAULT '0'::real,
    employer_amount real DEFAULT '0'::real,
    total_amount real DEFAULT '0'::real,
    due_date date,
    payment_status text DEFAULT 'PENDING'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.payroll_run_item_obligations OWNER TO chisenga;

--
-- Name: payroll_run_item_obligations_item_obligation_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_run_item_obligations_item_obligation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_run_item_obligations_item_obligation_id_seq OWNER TO chisenga;

--
-- Name: payroll_run_item_obligations_item_obligation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_run_item_obligations_item_obligation_id_seq OWNED BY public.payroll_run_item_obligations.item_obligation_id;


--
-- Name: payroll_run_items; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_run_items (
    run_item_id bigint NOT NULL,
    run_id bigint,
    employee_id text,
    employee_name text,
    salary_scale text,
    notch_no bigint,
    basic_salary real,
    allowances_total real,
    gross_pay real,
    deductions_total real,
    net_pay real,
    taxable_pay real,
    paye_amount real,
    napsa_amount real,
    nhima_amount real,
    position_title text,
    position_department text,
    salary_scale_code text,
    establishment_position_code text,
    authorized_establishment bigint,
    establishment_department text,
    council_type_id bigint,
    establishment_match_method text,
    nhis_amount real
);


ALTER TABLE public.payroll_run_items OWNER TO chisenga;

--
-- Name: payroll_run_items_run_item_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_run_items_run_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_run_items_run_item_id_seq OWNER TO chisenga;

--
-- Name: payroll_run_items_run_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_run_items_run_item_id_seq OWNED BY public.payroll_run_items.run_item_id;


--
-- Name: payroll_runs; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_runs (
    run_id bigint NOT NULL,
    period_id bigint,
    run_code text,
    run_status text DEFAULT 'DRAFT'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    processed_at timestamp without time zone,
    total_employees bigint DEFAULT '0'::bigint,
    total_basic real DEFAULT '0'::real,
    total_allowances real DEFAULT '0'::real,
    total_gross real DEFAULT '0'::real,
    total_deductions real DEFAULT '0'::real,
    total_net real DEFAULT '0'::real,
    notes text
);


ALTER TABLE public.payroll_runs OWNER TO chisenga;

--
-- Name: payroll_runs_run_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.payroll_runs_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payroll_runs_run_id_seq OWNER TO chisenga;

--
-- Name: payroll_runs_run_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.payroll_runs_run_id_seq OWNED BY public.payroll_runs.run_id;


--
-- Name: payroll_schedules; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_schedules (
    schedule_id text NOT NULL,
    authority_id text,
    period_year bigint,
    period_month bigint,
    payroll_cutoff_date text,
    processing_start_date text,
    processing_end_date text,
    payslip_generation_date text,
    scheduled_payment_date text,
    actual_payslip_date text,
    actual_payment_date text,
    status text DEFAULT 'SCHEDULED'::text,
    delay_reason text
);


ALTER TABLE public.payroll_schedules OWNER TO chisenga;

--
-- Name: payroll_statutory_rates; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payroll_statutory_rates (
    rate_code text NOT NULL,
    rate_name text,
    rate_value real,
    cap_amount real,
    effective_from date,
    active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.payroll_statutory_rates OWNER TO chisenga;

--
-- Name: payslip_access_log; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.payslip_access_log (
    access_id text NOT NULL,
    payroll_id text,
    employee_id text,
    access_type text,
    access_timestamp text DEFAULT CURRENT_TIMESTAMP,
    access_ip text,
    access_device text,
    delivery_confirmation bigint DEFAULT '0'::bigint,
    delivery_confirmation_time text
);


ALTER TABLE public.payslip_access_log OWNER TO chisenga;

--
-- Name: planning_leave_approval_chain; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.planning_leave_approval_chain (
    chain_id bigint NOT NULL,
    position_id text,
    step_number bigint,
    approver_role text,
    approver_position_id text
);


ALTER TABLE public.planning_leave_approval_chain OWNER TO chisenga;

--
-- Name: planning_leave_approval_chain_chain_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.planning_leave_approval_chain_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.planning_leave_approval_chain_chain_id_seq OWNER TO chisenga;

--
-- Name: planning_leave_approval_chain_chain_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.planning_leave_approval_chain_chain_id_seq OWNED BY public.planning_leave_approval_chain.chain_id;


--
-- Name: planning_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.planning_positions (
    position_id text NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    section_id bigint,
    council_type_id bigint,
    level bigint,
    is_head_of_unit boolean DEFAULT false,
    is_head_of_section boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.planning_positions OWNER TO chisenga;

--
-- Name: planning_sections; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.planning_sections (
    section_id bigint NOT NULL,
    section_name text,
    section_code text,
    council_type_id bigint,
    description text
);


ALTER TABLE public.planning_sections OWNER TO chisenga;

--
-- Name: planning_sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.planning_sections_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.planning_sections_section_id_seq OWNER TO chisenga;

--
-- Name: planning_sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.planning_sections_section_id_seq OWNED BY public.planning_sections.section_id;


--
-- Name: planning_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.planning_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    section_id bigint,
    council_type_id bigint,
    parent_unit_id bigint
);


ALTER TABLE public.planning_units OWNER TO chisenga;

--
-- Name: planning_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.planning_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.planning_units_unit_id_seq OWNER TO chisenga;

--
-- Name: planning_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.planning_units_unit_id_seq OWNED BY public.planning_units.unit_id;


--
-- Name: position_attributes; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.position_attributes (
    position_id text,
    authority_type text,
    title text,
    salary_scale text,
    establishment_count bigint,
    position_standard_id text
);


ALTER TABLE public.position_attributes OWNER TO chisenga;

--
-- Name: position_role_codes; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.position_role_codes (
    position_title text NOT NULL,
    role_code text,
    category text
);


ALTER TABLE public.position_role_codes OWNER TO chisenga;

--
-- Name: position_standard_id_map; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.position_standard_id_map (
    dept_code text,
    old_id text,
    position_title text,
    council_type text,
    unit_code text,
    role_code text,
    council_code text,
    seq text
);


ALTER TABLE public.position_standard_id_map OWNER TO chisenga;

--
-- Name: position_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.position_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_secretary_id text,
    council_type_id bigint,
    department text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.position_supervision OWNER TO chisenga;

--
-- Name: position_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.position_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.position_supervision_id_seq OWNER TO chisenga;

--
-- Name: position_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.position_supervision_id_seq OWNED BY public.position_supervision.id;


--
-- Name: position_supervisors; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.position_supervisors (
    position_id text,
    supervisor_id text,
    authority_type text,
    position_standard_id text,
    supervisor_standard_id text
);


ALTER TABLE public.position_supervisors OWNER TO chisenga;

--
-- Name: positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.positions (
    position_id text NOT NULL,
    title text,
    section_id bigint,
    salary_scale text,
    proposed_establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    level bigint,
    is_head_of_section boolean DEFAULT false,
    council_type_id bigint DEFAULT '2'::bigint
);


ALTER TABLE public.positions OWNER TO chisenga;

--
-- Name: procurement_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.procurement_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    section_id bigint,
    council_type_id bigint DEFAULT '1'::bigint,
    is_head_of_unit boolean DEFAULT false,
    is_head_of_section boolean DEFAULT false,
    is_specialist boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.procurement_positions OWNER TO chisenga;

--
-- Name: procurement_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.procurement_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.procurement_positions_position_id_seq OWNER TO chisenga;

--
-- Name: procurement_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.procurement_positions_position_id_seq OWNED BY public.procurement_positions.position_id;


--
-- Name: procurement_sections; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.procurement_sections (
    section_id bigint NOT NULL,
    section_name text,
    section_code text,
    council_type_id bigint,
    head_position_id text
);


ALTER TABLE public.procurement_sections OWNER TO chisenga;

--
-- Name: procurement_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.procurement_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    head_of_institution_id text,
    council_type_id bigint,
    department text DEFAULT 'PRO'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.procurement_supervision OWNER TO chisenga;

--
-- Name: procurement_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.procurement_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.procurement_supervision_id_seq OWNER TO chisenga;

--
-- Name: procurement_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.procurement_supervision_id_seq OWNED BY public.procurement_supervision.id;


--
-- Name: procurement_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.procurement_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    section_id bigint,
    council_type_id bigint,
    head_position_id text
);


ALTER TABLE public.procurement_units OWNER TO chisenga;

--
-- Name: procurement_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.procurement_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.procurement_units_unit_id_seq OWNER TO chisenga;

--
-- Name: procurement_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.procurement_units_unit_id_seq OWNED BY public.procurement_units.unit_id;


--
-- Name: province_codes; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.province_codes (
    province_name text NOT NULL,
    province_code text
);


ALTER TABLE public.province_codes OWNER TO chisenga;

--
-- Name: provinces; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.provinces (
    province_code text NOT NULL,
    country_code text DEFAULT 'ZM'::text,
    province_name text
);


ALTER TABLE public.provinces OWNER TO chisenga;

--
-- Name: ration_allowance_tiers; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.ration_allowance_tiers (
    tier_id text NOT NULL,
    salary_scale_range text,
    percentage real,
    applicable_to text,
    effective_from text,
    effective_to text,
    is_active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.ration_allowance_tiers OWNER TO chisenga;

--
-- Name: reportinglines; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.reportinglines (
    id bigint NOT NULL,
    position_id text,
    reports_to text,
    position_standard_id text,
    reports_to_standard_id text
);


ALTER TABLE public.reportinglines OWNER TO chisenga;

--
-- Name: salary_notch_values; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.salary_notch_values (
    scale_code text NOT NULL,
    notch_no bigint NOT NULL,
    annual_basic real,
    monthly_basic real,
    effective_from date NOT NULL,
    source_doc text
);


ALTER TABLE public.salary_notch_values OWNER TO chisenga;

--
-- Name: salary_notch_values_official; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.salary_notch_values_official (
    notch_value_id text DEFAULT 'lower(hex(randomblob(16)))'::text NOT NULL,
    salary_scale text,
    notch_number bigint,
    annual_amount real,
    monthly_amount real,
    notch_increment real,
    effective_from text,
    effective_to text,
    is_active bigint DEFAULT '1'::bigint
);


ALTER TABLE public.salary_notch_values_official OWNER TO chisenga;

--
-- Name: salary_scales; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.salary_scales (
    scale_id bigint NOT NULL,
    scale_code text,
    scale_name text,
    level bigint,
    applicable_to text
);


ALTER TABLE public.salary_scales OWNER TO chisenga;

--
-- Name: salary_scales_2026; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.salary_scales_2026 (
    grade text NOT NULL,
    notch bigint NOT NULL,
    existing_annual_k real,
    existing_monthly_k real,
    revised_annual_k real,
    revised_monthly_k real,
    increment_k real
);


ALTER TABLE public.salary_scales_2026 OWNER TO chisenga;

--
-- Name: salary_scales_official; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.salary_scales_official (
    scale_id text DEFAULT 'lower(hex(randomblob(16)))'::text NOT NULL,
    salary_scale text,
    division text,
    min_notch bigint,
    max_notch bigint,
    effective_from text,
    effective_to text,
    is_active bigint DEFAULT '1'::bigint,
    authority_document text,
    page_reference text
);


ALTER TABLE public.salary_scales_official OWNER TO chisenga;

--
-- Name: salary_scales_scale_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.salary_scales_scale_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.salary_scales_scale_id_seq OWNER TO chisenga;

--
-- Name: salary_scales_scale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.salary_scales_scale_id_seq OWNED BY public.salary_scales.scale_id;


--
-- Name: sections; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.sections (
    section_id bigint NOT NULL,
    section_name text,
    section_code text,
    description text
);


ALTER TABLE public.sections OWNER TO chisenga;

--
-- Name: sections_section_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.sections_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sections_section_id_seq OWNER TO chisenga;

--
-- Name: sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.sections_section_id_seq OWNED BY public.sections.section_id;


--
-- Name: sms_delivery_log; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.sms_delivery_log (
    sms_id bigint NOT NULL,
    notification_queue_id bigint,
    phone_number text,
    message text,
    status text DEFAULT 'Pending'::text,
    provider_message_id text,
    sent_at timestamp without time zone,
    delivered_at timestamp without time zone,
    error_code text,
    error_message text,
    retry_count bigint DEFAULT '0'::bigint,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sms_delivery_log OWNER TO chisenga;

--
-- Name: sms_gateway_config; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.sms_gateway_config (
    config_id bigint NOT NULL,
    gateway_name text,
    gateway_url text,
    api_key text,
    sender_id text DEFAULT 'COUNCIL'::text,
    is_active bigint DEFAULT '1'::bigint,
    max_sms_length bigint DEFAULT '160'::bigint,
    supports_unicode bigint DEFAULT '0'::bigint,
    cost_per_sms numeric(10,2),
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sms_gateway_config OWNER TO chisenga;

--
-- Name: sms_gateway_config_config_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.sms_gateway_config_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sms_gateway_config_config_id_seq OWNER TO chisenga;

--
-- Name: sms_gateway_config_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.sms_gateway_config_config_id_seq OWNED BY public.sms_gateway_config.config_id;


--
-- Name: sms_message_parts; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.sms_message_parts (
    part_id bigint NOT NULL,
    notification_queue_id bigint,
    part_number bigint,
    total_parts bigint,
    message_text text,
    character_count bigint,
    status text DEFAULT 'Pending'::text,
    sent_at timestamp without time zone
);


ALTER TABLE public.sms_message_parts OWNER TO chisenga;

--
-- Name: station_hardship_classification; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.station_hardship_classification (
    classification_id text NOT NULL,
    authority_id text,
    is_remote_hardship bigint DEFAULT '0'::bigint,
    is_rural_hardship bigint DEFAULT '0'::bigint,
    designated_from text,
    designated_to text,
    is_current bigint DEFAULT '1'::bigint,
    circular_reference text,
    circular_date text,
    circular_document_url text,
    criteria_met text,
    approved_by text,
    approval_date text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text
);


ALTER TABLE public.station_hardship_classification OWNER TO chisenga;

--
-- Name: station_hardship_history; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.station_hardship_history (
    history_id text NOT NULL,
    authority_id text,
    previous_designation text,
    new_designation text,
    change_reason text,
    circular_reference text,
    effective_date text,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    changed_by text
);


ALTER TABLE public.station_hardship_history OWNER TO chisenga;

--
-- Name: toc_city_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.toc_city_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '3'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.toc_city_positions OWNER TO chisenga;

--
-- Name: toc_city_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.toc_city_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.toc_city_positions_position_id_seq OWNER TO chisenga;

--
-- Name: toc_city_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.toc_city_positions_position_id_seq OWNED BY public.toc_city_positions.position_id;


--
-- Name: toc_city_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.toc_city_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_type_id bigint,
    department text DEFAULT 'TOC'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.toc_city_supervision OWNER TO chisenga;

--
-- Name: toc_city_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.toc_city_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.toc_city_supervision_id_seq OWNER TO chisenga;

--
-- Name: toc_city_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.toc_city_supervision_id_seq OWNED BY public.toc_city_supervision.id;


--
-- Name: toc_city_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.toc_city_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint,
    head_position_id text
);


ALTER TABLE public.toc_city_units OWNER TO chisenga;

--
-- Name: toc_city_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.toc_city_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.toc_city_units_unit_id_seq OWNER TO chisenga;

--
-- Name: toc_city_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.toc_city_units_unit_id_seq OWNED BY public.toc_city_units.unit_id;


--
-- Name: toc_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.toc_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    unit_id bigint,
    council_type_id bigint DEFAULT '2'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.toc_positions OWNER TO chisenga;

--
-- Name: toc_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.toc_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.toc_positions_position_id_seq OWNER TO chisenga;

--
-- Name: toc_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.toc_positions_position_id_seq OWNED BY public.toc_positions.position_id;


--
-- Name: toc_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.toc_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    council_type_id bigint,
    department text DEFAULT 'TOC'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.toc_supervision OWNER TO chisenga;

--
-- Name: toc_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.toc_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.toc_supervision_id_seq OWNER TO chisenga;

--
-- Name: toc_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.toc_supervision_id_seq OWNED BY public.toc_supervision.id;


--
-- Name: toc_units; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.toc_units (
    unit_id bigint NOT NULL,
    unit_name text,
    unit_code text,
    council_type_id bigint,
    head_position_id text
);


ALTER TABLE public.toc_units OWNER TO chisenga;

--
-- Name: toc_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.toc_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.toc_units_unit_id_seq OWNER TO chisenga;

--
-- Name: toc_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.toc_units_unit_id_seq OWNED BY public.toc_units.unit_id;


--
-- Name: vacancy_status; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.vacancy_status (
    position_code text NOT NULL,
    department_name text,
    status text,
    filled_on text,
    vacant_and_funded_since text,
    employee_id text
);


ALTER TABLE public.vacancy_status OWNER TO chisenga;

--
-- Name: vacation_allowances; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.vacation_allowances (
    allowance_id bigint NOT NULL,
    employee_id bigint,
    amount bigint,
    granted_date date,
    processed bigint DEFAULT '0'::bigint
);


ALTER TABLE public.vacation_allowances OWNER TO chisenga;

--
-- Name: valuation_city_positions; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.valuation_city_positions (
    position_id bigint NOT NULL,
    title text,
    salary_scale text,
    establishment bigint DEFAULT '1'::bigint,
    reports_to text,
    stream text,
    council_type_id bigint DEFAULT '3'::bigint,
    is_head_of_unit boolean DEFAULT false,
    standard_id text
);


ALTER TABLE public.valuation_city_positions OWNER TO chisenga;

--
-- Name: valuation_city_positions_position_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.valuation_city_positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.valuation_city_positions_position_id_seq OWNER TO chisenga;

--
-- Name: valuation_city_positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.valuation_city_positions_position_id_seq OWNED BY public.valuation_city_positions.position_id;


--
-- Name: valuation_city_supervision; Type: TABLE; Schema: public; Owner: chisenga
--

CREATE TABLE public.valuation_city_supervision (
    id bigint NOT NULL,
    position_standard_id text,
    immediate_supervisor_id text,
    hod_id text,
    head_of_institution_id text,
    council_type_id bigint,
    department text DEFAULT 'VAL'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.valuation_city_supervision OWNER TO chisenga;

--
-- Name: valuation_city_supervision_id_seq; Type: SEQUENCE; Schema: public; Owner: chisenga
--

CREATE SEQUENCE public.valuation_city_supervision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.valuation_city_supervision_id_seq OWNER TO chisenga;

--
-- Name: valuation_city_supervision_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chisenga
--

ALTER SEQUENCE public.valuation_city_supervision_id_seq OWNED BY public.valuation_city_supervision.id;


--
-- Name: audit_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.audit_positions ALTER COLUMN position_id SET DEFAULT nextval('public.audit_positions_position_id_seq'::regclass);


--
-- Name: audit_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.audit_supervision ALTER COLUMN id SET DEFAULT nextval('public.audit_supervision_id_seq'::regclass);


--
-- Name: audit_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.audit_units ALTER COLUMN unit_id SET DEFAULT nextval('public.audit_units_unit_id_seq'::regclass);


--
-- Name: commercial_city_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_city_positions ALTER COLUMN position_id SET DEFAULT nextval('public.commercial_city_positions_position_id_seq'::regclass);


--
-- Name: commercial_city_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_city_supervision ALTER COLUMN id SET DEFAULT nextval('public.commercial_city_supervision_id_seq'::regclass);


--
-- Name: commercial_city_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_city_units ALTER COLUMN unit_id SET DEFAULT nextval('public.commercial_city_units_unit_id_seq'::regclass);


--
-- Name: commercial_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_positions ALTER COLUMN position_id SET DEFAULT nextval('public.commercial_positions_position_id_seq'::regclass);


--
-- Name: commercial_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_supervision ALTER COLUMN id SET DEFAULT nextval('public.commercial_supervision_id_seq'::regclass);


--
-- Name: commercial_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_units ALTER COLUMN unit_id SET DEFAULT nextval('public.commercial_units_unit_id_seq'::regclass);


--
-- Name: community_sections section_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_sections ALTER COLUMN section_id SET DEFAULT nextval('public.community_sections_section_id_seq'::regclass);


--
-- Name: community_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_supervision ALTER COLUMN id SET DEFAULT nextval('public.community_supervision_id_seq'::regclass);


--
-- Name: community_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_units ALTER COLUMN unit_id SET DEFAULT nextval('public.community_units_unit_id_seq'::regclass);


--
-- Name: cos_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.cos_positions ALTER COLUMN position_id SET DEFAULT nextval('public.cos_positions_position_id_seq'::regclass);


--
-- Name: cos_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.cos_supervision ALTER COLUMN id SET DEFAULT nextval('public.cos_supervision_id_seq'::regclass);


--
-- Name: cos_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.cos_units ALTER COLUMN unit_id SET DEFAULT nextval('public.cos_units_unit_id_seq'::regclass);


--
-- Name: council_types council_type_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.council_types ALTER COLUMN council_type_id SET DEFAULT nextval('public.council_types_council_type_id_seq'::regclass);


--
-- Name: councils council_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.councils ALTER COLUMN council_id SET DEFAULT nextval('public.councils_council_id_seq'::regclass);


--
-- Name: eng_leave_approval_chain chain_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_leave_approval_chain ALTER COLUMN chain_id SET DEFAULT nextval('public.eng_leave_approval_chain_chain_id_seq'::regclass);


--
-- Name: eng_position_hierarchy hierarchy_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_position_hierarchy ALTER COLUMN hierarchy_id SET DEFAULT nextval('public.eng_position_hierarchy_hierarchy_id_seq'::regclass);


--
-- Name: eng_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_units ALTER COLUMN unit_id SET DEFAULT nextval('public.eng_units_unit_id_seq'::regclass);


--
-- Name: executive_positions id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.executive_positions ALTER COLUMN id SET DEFAULT nextval('public.executive_positions_id_seq'::regclass);


--
-- Name: finance_leave_approval_chain chain_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_leave_approval_chain ALTER COLUMN chain_id SET DEFAULT nextval('public.finance_leave_approval_chain_chain_id_seq'::regclass);


--
-- Name: finance_sections section_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_sections ALTER COLUMN section_id SET DEFAULT nextval('public.finance_sections_section_id_seq'::regclass);


--
-- Name: finance_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_units ALTER COLUMN unit_id SET DEFAULT nextval('public.finance_units_unit_id_seq'::regclass);


--
-- Name: health_leave_approval_chain chain_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_leave_approval_chain ALTER COLUMN chain_id SET DEFAULT nextval('public.health_leave_approval_chain_chain_id_seq'::regclass);


--
-- Name: health_sections section_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_sections ALTER COLUMN section_id SET DEFAULT nextval('public.health_sections_section_id_seq'::regclass);


--
-- Name: health_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_supervision ALTER COLUMN id SET DEFAULT nextval('public.health_supervision_id_seq'::regclass);


--
-- Name: health_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_units ALTER COLUMN unit_id SET DEFAULT nextval('public.health_units_unit_id_seq'::regclass);


--
-- Name: hra_reportinglines id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_reportinglines ALTER COLUMN id SET DEFAULT nextval('public.hra_reportinglines_id_seq'::regclass);


--
-- Name: hra_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_supervision ALTER COLUMN id SET DEFAULT nextval('public.hra_supervision_id_seq'::regclass);


--
-- Name: ict_city_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_city_positions ALTER COLUMN position_id SET DEFAULT nextval('public.ict_city_positions_position_id_seq'::regclass);


--
-- Name: ict_city_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_city_supervision ALTER COLUMN id SET DEFAULT nextval('public.ict_city_supervision_id_seq'::regclass);


--
-- Name: ict_city_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_city_units ALTER COLUMN unit_id SET DEFAULT nextval('public.ict_city_units_unit_id_seq'::regclass);


--
-- Name: ict_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_positions ALTER COLUMN position_id SET DEFAULT nextval('public.ict_positions_position_id_seq'::regclass);


--
-- Name: ict_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_supervision ALTER COLUMN id SET DEFAULT nextval('public.ict_supervision_id_seq'::regclass);


--
-- Name: ict_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_units ALTER COLUMN unit_id SET DEFAULT nextval('public.ict_units_unit_id_seq'::regclass);


--
-- Name: jd_upload_queue id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.jd_upload_queue ALTER COLUMN id SET DEFAULT nextval('public.jd_upload_queue_id_seq'::regclass);


--
-- Name: job_description_documents id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.job_description_documents ALTER COLUMN id SET DEFAULT nextval('public.job_description_documents_id_seq'::regclass);


--
-- Name: leave_approval_chain chain_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_approval_chain ALTER COLUMN chain_id SET DEFAULT nextval('public.leave_approval_chain_chain_id_seq'::regclass);


--
-- Name: leave_types leave_type_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_types ALTER COLUMN leave_type_id SET DEFAULT nextval('public.leave_types_leave_type_id_seq'::regclass);


--
-- Name: legal_leave_approval_chain chain_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_leave_approval_chain ALTER COLUMN chain_id SET DEFAULT nextval('public.legal_leave_approval_chain_chain_id_seq'::regclass);


--
-- Name: legal_sections section_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_sections ALTER COLUMN section_id SET DEFAULT nextval('public.legal_sections_section_id_seq'::regclass);


--
-- Name: legal_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_supervision ALTER COLUMN id SET DEFAULT nextval('public.legal_supervision_id_seq'::regclass);


--
-- Name: legal_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_units ALTER COLUMN unit_id SET DEFAULT nextval('public.legal_units_unit_id_seq'::regclass);


--
-- Name: mothers_day_leave_tracking tracking_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.mothers_day_leave_tracking ALTER COLUMN tracking_id SET DEFAULT nextval('public.mothers_day_leave_tracking_tracking_id_seq'::regclass);


--
-- Name: overtime_requests overtime_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.overtime_requests ALTER COLUMN overtime_id SET DEFAULT nextval('public.overtime_requests_overtime_id_seq'::regclass);


--
-- Name: payroll_assignment_exception id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_assignment_exception ALTER COLUMN id SET DEFAULT nextval('public.payroll_assignment_exception_id_seq'::regclass);


--
-- Name: payroll_establishment_position id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_establishment_position ALTER COLUMN id SET DEFAULT nextval('public.payroll_establishment_position_id_seq'::regclass);


--
-- Name: payroll_periods period_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_periods ALTER COLUMN period_id SET DEFAULT nextval('public.payroll_periods_period_id_seq'::regclass);


--
-- Name: payroll_run_item_allowances item_allowance_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_allowances ALTER COLUMN item_allowance_id SET DEFAULT nextval('public.payroll_run_item_allowances_item_allowance_id_seq'::regclass);


--
-- Name: payroll_run_item_deductions item_deduction_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_deductions ALTER COLUMN item_deduction_id SET DEFAULT nextval('public.payroll_run_item_deductions_item_deduction_id_seq'::regclass);


--
-- Name: payroll_run_item_obligations item_obligation_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_obligations ALTER COLUMN item_obligation_id SET DEFAULT nextval('public.payroll_run_item_obligations_item_obligation_id_seq'::regclass);


--
-- Name: payroll_run_items run_item_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_items ALTER COLUMN run_item_id SET DEFAULT nextval('public.payroll_run_items_run_item_id_seq'::regclass);


--
-- Name: payroll_runs run_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_runs ALTER COLUMN run_id SET DEFAULT nextval('public.payroll_runs_run_id_seq'::regclass);


--
-- Name: planning_leave_approval_chain chain_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_leave_approval_chain ALTER COLUMN chain_id SET DEFAULT nextval('public.planning_leave_approval_chain_chain_id_seq'::regclass);


--
-- Name: planning_sections section_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_sections ALTER COLUMN section_id SET DEFAULT nextval('public.planning_sections_section_id_seq'::regclass);


--
-- Name: planning_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_units ALTER COLUMN unit_id SET DEFAULT nextval('public.planning_units_unit_id_seq'::regclass);


--
-- Name: position_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.position_supervision ALTER COLUMN id SET DEFAULT nextval('public.position_supervision_id_seq'::regclass);


--
-- Name: procurement_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_positions ALTER COLUMN position_id SET DEFAULT nextval('public.procurement_positions_position_id_seq'::regclass);


--
-- Name: procurement_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_supervision ALTER COLUMN id SET DEFAULT nextval('public.procurement_supervision_id_seq'::regclass);


--
-- Name: procurement_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_units ALTER COLUMN unit_id SET DEFAULT nextval('public.procurement_units_unit_id_seq'::regclass);


--
-- Name: salary_scales scale_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.salary_scales ALTER COLUMN scale_id SET DEFAULT nextval('public.salary_scales_scale_id_seq'::regclass);


--
-- Name: sections section_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sections ALTER COLUMN section_id SET DEFAULT nextval('public.sections_section_id_seq'::regclass);


--
-- Name: sms_gateway_config config_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sms_gateway_config ALTER COLUMN config_id SET DEFAULT nextval('public.sms_gateway_config_config_id_seq'::regclass);


--
-- Name: toc_city_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_city_positions ALTER COLUMN position_id SET DEFAULT nextval('public.toc_city_positions_position_id_seq'::regclass);


--
-- Name: toc_city_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_city_supervision ALTER COLUMN id SET DEFAULT nextval('public.toc_city_supervision_id_seq'::regclass);


--
-- Name: toc_city_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_city_units ALTER COLUMN unit_id SET DEFAULT nextval('public.toc_city_units_unit_id_seq'::regclass);


--
-- Name: toc_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_positions ALTER COLUMN position_id SET DEFAULT nextval('public.toc_positions_position_id_seq'::regclass);


--
-- Name: toc_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_supervision ALTER COLUMN id SET DEFAULT nextval('public.toc_supervision_id_seq'::regclass);


--
-- Name: toc_units unit_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_units ALTER COLUMN unit_id SET DEFAULT nextval('public.toc_units_unit_id_seq'::regclass);


--
-- Name: valuation_city_positions position_id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.valuation_city_positions ALTER COLUMN position_id SET DEFAULT nextval('public.valuation_city_positions_position_id_seq'::regclass);


--
-- Name: valuation_city_supervision id; Type: DEFAULT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.valuation_city_supervision ALTER COLUMN id SET DEFAULT nextval('public.valuation_city_supervision_id_seq'::regclass);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: audit_log idx_32783_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT idx_32783_audit_log_pkey PRIMARY KEY (log_id);


--
-- Name: leave_requests idx_32794_leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT idx_32794_leave_requests_pkey PRIMARY KEY (request_id);


--
-- Name: holidays idx_32803_sqlite_autoindex_holidays_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.holidays
    ADD CONSTRAINT idx_32803_sqlite_autoindex_holidays_1 PRIMARY KEY (holiday_date);


--
-- Name: calendar idx_32808_sqlite_autoindex_calendar_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.calendar
    ADD CONSTRAINT idx_32808_sqlite_autoindex_calendar_1 PRIMARY KEY (day);


--
-- Name: leave_balances idx_32811_leave_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_balances
    ADD CONSTRAINT idx_32811_leave_balances_pkey PRIMARY KEY (employee_id);


--
-- Name: authority_codes idx_32814_sqlite_autoindex_authority_codes_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.authority_codes
    ADD CONSTRAINT idx_32814_sqlite_autoindex_authority_codes_1 PRIMARY KEY (authority_name);


--
-- Name: employee_sequence idx_32819_sqlite_autoindex_employee_sequence_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employee_sequence
    ADD CONSTRAINT idx_32819_sqlite_autoindex_employee_sequence_1 PRIMARY KEY (authority_code, year);


--
-- Name: vacation_allowances idx_32824_vacation_allowances_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.vacation_allowances
    ADD CONSTRAINT idx_32824_vacation_allowances_pkey PRIMARY KEY (allowance_id);


--
-- Name: approval_chain idx_32828_approval_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.approval_chain
    ADD CONSTRAINT idx_32828_approval_chain_pkey PRIMARY KEY (employee_id);


--
-- Name: departments idx_32831_sqlite_autoindex_departments_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT idx_32831_sqlite_autoindex_departments_1 PRIMARY KEY (dept_code);


--
-- Name: authorities idx_32841_sqlite_autoindex_authorities_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.authorities
    ADD CONSTRAINT idx_32841_sqlite_autoindex_authorities_1 PRIMARY KEY (authority_prefix);


--
-- Name: reportinglines idx_32851_reportinglines_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.reportinglines
    ADD CONSTRAINT idx_32851_reportinglines_pkey PRIMARY KEY (id);


--
-- Name: leaveapprovalchains idx_32856_leaveapprovalchains_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leaveapprovalchains
    ADD CONSTRAINT idx_32856_leaveapprovalchains_pkey PRIMARY KEY (id);


--
-- Name: councils idx_32862_councils_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.councils
    ADD CONSTRAINT idx_32862_councils_pkey PRIMARY KEY (council_id);


--
-- Name: hra_positions idx_32868_sqlite_autoindex_hra_positions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_positions
    ADD CONSTRAINT idx_32868_sqlite_autoindex_hra_positions_1 PRIMARY KEY (position_id);


--
-- Name: hra_reportinglines idx_32874_hra_reportinglines_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_reportinglines
    ADD CONSTRAINT idx_32874_hra_reportinglines_pkey PRIMARY KEY (id);


--
-- Name: hra_leaveapprovalchains idx_32880_hra_leaveapprovalchains_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_leaveapprovalchains
    ADD CONSTRAINT idx_32880_hra_leaveapprovalchains_pkey PRIMARY KEY (id);


--
-- Name: hra_position_attributes idx_32885_sqlite_autoindex_hra_position_attributes_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_position_attributes
    ADD CONSTRAINT idx_32885_sqlite_autoindex_hra_position_attributes_1 PRIMARY KEY (position_id);


--
-- Name: sections idx_32901_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT idx_32901_sections_pkey PRIMARY KEY (section_id);


--
-- Name: positions idx_32907_sqlite_autoindex_positions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT idx_32907_sqlite_autoindex_positions_1 PRIMARY KEY (position_id);


--
-- Name: leave_approval_chain idx_32916_leave_approval_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_approval_chain
    ADD CONSTRAINT idx_32916_leave_approval_chain_pkey PRIMARY KEY (chain_id);


--
-- Name: eng_units idx_32923_eng_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_units
    ADD CONSTRAINT idx_32923_eng_units_pkey PRIMARY KEY (unit_id);


--
-- Name: eng_positions idx_32929_sqlite_autoindex_eng_positions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_positions
    ADD CONSTRAINT idx_32929_sqlite_autoindex_eng_positions_1 PRIMARY KEY (position_id);


--
-- Name: eng_leave_approval_chain idx_32937_eng_leave_approval_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_leave_approval_chain
    ADD CONSTRAINT idx_32937_eng_leave_approval_chain_pkey PRIMARY KEY (chain_id);


--
-- Name: planning_sections idx_32944_planning_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_sections
    ADD CONSTRAINT idx_32944_planning_sections_pkey PRIMARY KEY (section_id);


--
-- Name: planning_units idx_32951_planning_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_units
    ADD CONSTRAINT idx_32951_planning_units_pkey PRIMARY KEY (unit_id);


--
-- Name: planning_positions idx_32957_sqlite_autoindex_planning_positions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_positions
    ADD CONSTRAINT idx_32957_sqlite_autoindex_planning_positions_1 PRIMARY KEY (position_id);


--
-- Name: planning_leave_approval_chain idx_32966_planning_leave_approval_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_leave_approval_chain
    ADD CONSTRAINT idx_32966_planning_leave_approval_chain_pkey PRIMARY KEY (chain_id);


--
-- Name: finance_sections idx_32973_finance_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_sections
    ADD CONSTRAINT idx_32973_finance_sections_pkey PRIMARY KEY (section_id);


--
-- Name: finance_units idx_32980_finance_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_units
    ADD CONSTRAINT idx_32980_finance_units_pkey PRIMARY KEY (unit_id);


--
-- Name: finance_leave_approval_chain idx_32995_finance_leave_approval_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_leave_approval_chain
    ADD CONSTRAINT idx_32995_finance_leave_approval_chain_pkey PRIMARY KEY (chain_id);


--
-- Name: legal_sections idx_33002_legal_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_sections
    ADD CONSTRAINT idx_33002_legal_sections_pkey PRIMARY KEY (section_id);


--
-- Name: legal_units idx_33009_legal_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_units
    ADD CONSTRAINT idx_33009_legal_units_pkey PRIMARY KEY (unit_id);


--
-- Name: legal_positions idx_33015_sqlite_autoindex_legal_positions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_positions
    ADD CONSTRAINT idx_33015_sqlite_autoindex_legal_positions_1 PRIMARY KEY (position_id);


--
-- Name: legal_leave_approval_chain idx_33024_legal_leave_approval_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_leave_approval_chain
    ADD CONSTRAINT idx_33024_legal_leave_approval_chain_pkey PRIMARY KEY (chain_id);


--
-- Name: council_types idx_33031_council_types_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.council_types
    ADD CONSTRAINT idx_33031_council_types_pkey PRIMARY KEY (council_type_id);


--
-- Name: salary_scales idx_33038_salary_scales_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.salary_scales
    ADD CONSTRAINT idx_33038_salary_scales_pkey PRIMARY KEY (scale_id);


--
-- Name: health_sections idx_33045_health_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_sections
    ADD CONSTRAINT idx_33045_health_sections_pkey PRIMARY KEY (section_id);


--
-- Name: health_units idx_33052_health_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_units
    ADD CONSTRAINT idx_33052_health_units_pkey PRIMARY KEY (unit_id);


--
-- Name: health_positions idx_33058_sqlite_autoindex_health_positions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_positions
    ADD CONSTRAINT idx_33058_sqlite_autoindex_health_positions_1 PRIMARY KEY (position_id);


--
-- Name: health_leave_approval_chain idx_33067_health_leave_approval_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_leave_approval_chain
    ADD CONSTRAINT idx_33067_health_leave_approval_chain_pkey PRIMARY KEY (chain_id);


--
-- Name: leave_types idx_33074_leave_types_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_types
    ADD CONSTRAINT idx_33074_leave_types_pkey PRIMARY KEY (leave_type_id);


--
-- Name: hr_recipients idx_33086_hr_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hr_recipients
    ADD CONSTRAINT idx_33086_hr_recipients_pkey PRIMARY KEY (recipient_id);


--
-- Name: mothers_day_notification_log idx_33094_mothers_day_notification_log_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.mothers_day_notification_log
    ADD CONSTRAINT idx_33094_mothers_day_notification_log_pkey PRIMARY KEY (notification_id);


--
-- Name: mothers_day_acknowledgments idx_33102_mothers_day_acknowledgments_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.mothers_day_acknowledgments
    ADD CONSTRAINT idx_33102_mothers_day_acknowledgments_pkey PRIMARY KEY (acknowledgment_id);


--
-- Name: notification_history idx_33109_notification_history_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.notification_history
    ADD CONSTRAINT idx_33109_notification_history_pkey PRIMARY KEY (history_id);


--
-- Name: sms_gateway_config idx_33115_sms_gateway_config_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sms_gateway_config
    ADD CONSTRAINT idx_33115_sms_gateway_config_pkey PRIMARY KEY (config_id);


--
-- Name: sms_delivery_log idx_33127_sms_delivery_log_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sms_delivery_log
    ADD CONSTRAINT idx_33127_sms_delivery_log_pkey PRIMARY KEY (sms_id);


--
-- Name: sms_message_parts idx_33135_sms_message_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sms_message_parts
    ADD CONSTRAINT idx_33135_sms_message_parts_pkey PRIMARY KEY (part_id);


--
-- Name: mothers_day_leave_tracking idx_33142_mothers_day_leave_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.mothers_day_leave_tracking
    ADD CONSTRAINT idx_33142_mothers_day_leave_tracking_pkey PRIMARY KEY (tracking_id);


--
-- Name: notification_queue idx_33155_notification_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.notification_queue
    ADD CONSTRAINT idx_33155_notification_queue_pkey PRIMARY KEY (queue_id);


--
-- Name: eng_position_hierarchy idx_33163_eng_position_hierarchy_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_position_hierarchy
    ADD CONSTRAINT idx_33163_eng_position_hierarchy_pkey PRIMARY KEY (hierarchy_id);


--
-- Name: position_role_codes idx_33176_sqlite_autoindex_position_role_codes_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.position_role_codes
    ADD CONSTRAINT idx_33176_sqlite_autoindex_position_role_codes_1 PRIMARY KEY (position_title);


--
-- Name: position_supervision idx_33182_position_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.position_supervision
    ADD CONSTRAINT idx_33182_position_supervision_pkey PRIMARY KEY (id);


--
-- Name: executive_positions idx_33191_executive_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.executive_positions
    ADD CONSTRAINT idx_33191_executive_positions_pkey PRIMARY KEY (id);


--
-- Name: jd_upload_queue idx_33201_jd_upload_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.jd_upload_queue
    ADD CONSTRAINT idx_33201_jd_upload_queue_pkey PRIMARY KEY (id);


--
-- Name: job_description_documents idx_33211_job_description_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.job_description_documents
    ADD CONSTRAINT idx_33211_job_description_documents_pkey PRIMARY KEY (id);


--
-- Name: jd_review_queue idx_33221_jd_review_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.jd_review_queue
    ADD CONSTRAINT idx_33221_jd_review_queue_pkey PRIMARY KEY (id);


--
-- Name: hra_supervision idx_33228_hra_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_supervision
    ADD CONSTRAINT idx_33228_hra_supervision_pkey PRIMARY KEY (id);


--
-- Name: legal_supervision idx_33238_legal_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_supervision
    ADD CONSTRAINT idx_33238_legal_supervision_pkey PRIMARY KEY (id);


--
-- Name: health_supervision idx_33248_health_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_supervision
    ADD CONSTRAINT idx_33248_health_supervision_pkey PRIMARY KEY (id);


--
-- Name: community_sections idx_33267_community_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_sections
    ADD CONSTRAINT idx_33267_community_sections_pkey PRIMARY KEY (section_id);


--
-- Name: community_units idx_33274_community_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_units
    ADD CONSTRAINT idx_33274_community_units_pkey PRIMARY KEY (unit_id);


--
-- Name: community_supervision idx_33282_community_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_supervision
    ADD CONSTRAINT idx_33282_community_supervision_pkey PRIMARY KEY (id);


--
-- Name: procurement_sections idx_33291_procurement_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_sections
    ADD CONSTRAINT idx_33291_procurement_sections_pkey PRIMARY KEY (section_id);


--
-- Name: procurement_units idx_33297_procurement_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_units
    ADD CONSTRAINT idx_33297_procurement_units_pkey PRIMARY KEY (unit_id);


--
-- Name: procurement_positions idx_33304_procurement_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_positions
    ADD CONSTRAINT idx_33304_procurement_positions_pkey PRIMARY KEY (position_id);


--
-- Name: procurement_supervision idx_33316_procurement_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_supervision
    ADD CONSTRAINT idx_33316_procurement_supervision_pkey PRIMARY KEY (id);


--
-- Name: audit_positions idx_33326_audit_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.audit_positions
    ADD CONSTRAINT idx_33326_audit_positions_pkey PRIMARY KEY (position_id);


--
-- Name: audit_units idx_33337_audit_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.audit_units
    ADD CONSTRAINT idx_33337_audit_units_pkey PRIMARY KEY (unit_id);


--
-- Name: audit_supervision idx_33344_audit_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.audit_supervision
    ADD CONSTRAINT idx_33344_audit_supervision_pkey PRIMARY KEY (id);


--
-- Name: cos_units idx_33354_cos_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.cos_units
    ADD CONSTRAINT idx_33354_cos_units_pkey PRIMARY KEY (unit_id);


--
-- Name: cos_positions idx_33361_cos_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.cos_positions
    ADD CONSTRAINT idx_33361_cos_positions_pkey PRIMARY KEY (position_id);


--
-- Name: cos_supervision idx_33371_cos_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.cos_supervision
    ADD CONSTRAINT idx_33371_cos_supervision_pkey PRIMARY KEY (id);


--
-- Name: toc_units idx_33381_toc_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_units
    ADD CONSTRAINT idx_33381_toc_units_pkey PRIMARY KEY (unit_id);


--
-- Name: toc_positions idx_33388_toc_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_positions
    ADD CONSTRAINT idx_33388_toc_positions_pkey PRIMARY KEY (position_id);


--
-- Name: toc_supervision idx_33398_toc_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_supervision
    ADD CONSTRAINT idx_33398_toc_supervision_pkey PRIMARY KEY (id);


--
-- Name: toc_city_units idx_33408_toc_city_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_city_units
    ADD CONSTRAINT idx_33408_toc_city_units_pkey PRIMARY KEY (unit_id);


--
-- Name: toc_city_positions idx_33415_toc_city_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_city_positions
    ADD CONSTRAINT idx_33415_toc_city_positions_pkey PRIMARY KEY (position_id);


--
-- Name: toc_city_supervision idx_33425_toc_city_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_city_supervision
    ADD CONSTRAINT idx_33425_toc_city_supervision_pkey PRIMARY KEY (id);


--
-- Name: ict_positions idx_33435_ict_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_positions
    ADD CONSTRAINT idx_33435_ict_positions_pkey PRIMARY KEY (position_id);


--
-- Name: ict_units idx_33445_ict_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_units
    ADD CONSTRAINT idx_33445_ict_units_pkey PRIMARY KEY (unit_id);


--
-- Name: ict_supervision idx_33452_ict_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_supervision
    ADD CONSTRAINT idx_33452_ict_supervision_pkey PRIMARY KEY (id);


--
-- Name: ict_city_positions idx_33462_ict_city_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_city_positions
    ADD CONSTRAINT idx_33462_ict_city_positions_pkey PRIMARY KEY (position_id);


--
-- Name: ict_city_units idx_33472_ict_city_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_city_units
    ADD CONSTRAINT idx_33472_ict_city_units_pkey PRIMARY KEY (unit_id);


--
-- Name: ict_city_supervision idx_33479_ict_city_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ict_city_supervision
    ADD CONSTRAINT idx_33479_ict_city_supervision_pkey PRIMARY KEY (id);


--
-- Name: commercial_positions idx_33489_commercial_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_positions
    ADD CONSTRAINT idx_33489_commercial_positions_pkey PRIMARY KEY (position_id);


--
-- Name: commercial_units idx_33499_commercial_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_units
    ADD CONSTRAINT idx_33499_commercial_units_pkey PRIMARY KEY (unit_id);


--
-- Name: commercial_supervision idx_33506_commercial_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_supervision
    ADD CONSTRAINT idx_33506_commercial_supervision_pkey PRIMARY KEY (id);


--
-- Name: commercial_city_positions idx_33516_commercial_city_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_city_positions
    ADD CONSTRAINT idx_33516_commercial_city_positions_pkey PRIMARY KEY (position_id);


--
-- Name: commercial_city_units idx_33526_commercial_city_units_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_city_units
    ADD CONSTRAINT idx_33526_commercial_city_units_pkey PRIMARY KEY (unit_id);


--
-- Name: commercial_city_supervision idx_33533_commercial_city_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.commercial_city_supervision
    ADD CONSTRAINT idx_33533_commercial_city_supervision_pkey PRIMARY KEY (id);


--
-- Name: valuation_city_positions idx_33543_valuation_city_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.valuation_city_positions
    ADD CONSTRAINT idx_33543_valuation_city_positions_pkey PRIMARY KEY (position_id);


--
-- Name: valuation_city_supervision idx_33553_valuation_city_supervision_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.valuation_city_supervision
    ADD CONSTRAINT idx_33553_valuation_city_supervision_pkey PRIMARY KEY (id);


--
-- Name: immutable_audit_log idx_33562_immutable_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.immutable_audit_log
    ADD CONSTRAINT idx_33562_immutable_audit_log_pkey PRIMARY KEY (log_id);


--
-- Name: provinces idx_33568_sqlite_autoindex_provinces_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT idx_33568_sqlite_autoindex_provinces_1 PRIMARY KEY (province_code);


--
-- Name: authority_master idx_33574_sqlite_autoindex_authority_master_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.authority_master
    ADD CONSTRAINT idx_33574_sqlite_autoindex_authority_master_1 PRIMARY KEY (authority_id);


--
-- Name: salary_notch_values idx_33580_sqlite_autoindex_salary_notch_values_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.salary_notch_values
    ADD CONSTRAINT idx_33580_sqlite_autoindex_salary_notch_values_1 PRIMARY KEY (scale_code, notch_no, effective_from);


--
-- Name: employee_salary_notch idx_33585_sqlite_autoindex_employee_salary_notch_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employee_salary_notch
    ADD CONSTRAINT idx_33585_sqlite_autoindex_employee_salary_notch_1 PRIMARY KEY (employee_id, effective_from);


--
-- Name: allowance_types idx_33591_sqlite_autoindex_allowance_types_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.allowance_types
    ADD CONSTRAINT idx_33591_sqlite_autoindex_allowance_types_1 PRIMARY KEY (allowance_code);


--
-- Name: employee_allowances idx_33600_sqlite_autoindex_employee_allowances_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employee_allowances
    ADD CONSTRAINT idx_33600_sqlite_autoindex_employee_allowances_1 PRIMARY KEY (employee_id, allowance_code, effective_from);


--
-- Name: payroll_periods idx_33607_payroll_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_periods
    ADD CONSTRAINT idx_33607_payroll_periods_pkey PRIMARY KEY (period_id);


--
-- Name: payroll_runs idx_33615_payroll_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_runs
    ADD CONSTRAINT idx_33615_payroll_runs_pkey PRIMARY KEY (run_id);


--
-- Name: payroll_run_items idx_33630_payroll_run_items_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_items
    ADD CONSTRAINT idx_33630_payroll_run_items_pkey PRIMARY KEY (run_item_id);


--
-- Name: payroll_run_item_allowances idx_33637_payroll_run_item_allowances_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_allowances
    ADD CONSTRAINT idx_33637_payroll_run_item_allowances_pkey PRIMARY KEY (item_allowance_id);


--
-- Name: payroll_statutory_rates idx_33644_sqlite_autoindex_payroll_statutory_rates_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_statutory_rates
    ADD CONSTRAINT idx_33644_sqlite_autoindex_payroll_statutory_rates_1 PRIMARY KEY (rate_code);


--
-- Name: payroll_run_item_obligations idx_33651_payroll_run_item_obligations_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_obligations
    ADD CONSTRAINT idx_33651_payroll_run_item_obligations_pkey PRIMARY KEY (item_obligation_id);


--
-- Name: local_authorities idx_33662_sqlite_autoindex_local_authorities_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.local_authorities
    ADD CONSTRAINT idx_33662_sqlite_autoindex_local_authorities_1 PRIMARY KEY (authority_id);


--
-- Name: payroll_schedules idx_33673_sqlite_autoindex_payroll_schedules_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_schedules
    ADD CONSTRAINT idx_33673_sqlite_autoindex_payroll_schedules_1 PRIMARY KEY (schedule_id);


--
-- Name: payment_batches idx_33679_sqlite_autoindex_payment_batches_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payment_batches
    ADD CONSTRAINT idx_33679_sqlite_autoindex_payment_batches_1 PRIMARY KEY (batch_id);


--
-- Name: payroll_integrity_log idx_33686_sqlite_autoindex_payroll_integrity_log_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_integrity_log
    ADD CONSTRAINT idx_33686_sqlite_autoindex_payroll_integrity_log_1 PRIMARY KEY (log_id);


--
-- Name: payroll_run idx_33692_sqlite_autoindex_payroll_run_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run
    ADD CONSTRAINT idx_33692_sqlite_autoindex_payroll_run_1 PRIMARY KEY (payroll_id);


--
-- Name: payslip_access_log idx_33699_sqlite_autoindex_payslip_access_log_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payslip_access_log
    ADD CONSTRAINT idx_33699_sqlite_autoindex_payslip_access_log_1 PRIMARY KEY (access_id);


--
-- Name: payment_delay_approvals idx_33706_sqlite_autoindex_payment_delay_approvals_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payment_delay_approvals
    ADD CONSTRAINT idx_33706_sqlite_autoindex_payment_delay_approvals_1 PRIMARY KEY (delay_id);


--
-- Name: la_payroll_config idx_33713_sqlite_autoindex_la_payroll_config_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.la_payroll_config
    ADD CONSTRAINT idx_33713_sqlite_autoindex_la_payroll_config_1 PRIMARY KEY (config_id);


--
-- Name: la_payroll_submissions idx_33722_sqlite_autoindex_la_payroll_submissions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.la_payroll_submissions
    ADD CONSTRAINT idx_33722_sqlite_autoindex_la_payroll_submissions_1 PRIMARY KEY (submission_id);


--
-- Name: compliance_issues idx_33730_sqlite_autoindex_compliance_issues_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.compliance_issues
    ADD CONSTRAINT idx_33730_sqlite_autoindex_compliance_issues_1 PRIMARY KEY (issue_id);


--
-- Name: central_payslip_archive idx_33738_sqlite_autoindex_central_payslip_archive_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.central_payslip_archive
    ADD CONSTRAINT idx_33738_sqlite_autoindex_central_payslip_archive_1 PRIMARY KEY (archive_id);


--
-- Name: station_hardship_classification idx_33745_sqlite_autoindex_station_hardship_classification_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.station_hardship_classification
    ADD CONSTRAINT idx_33745_sqlite_autoindex_station_hardship_classification_1 PRIMARY KEY (classification_id);


--
-- Name: station_hardship_history idx_33755_sqlite_autoindex_station_hardship_history_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.station_hardship_history
    ADD CONSTRAINT idx_33755_sqlite_autoindex_station_hardship_history_1 PRIMARY KEY (history_id);


--
-- Name: la_session_context idx_33761_la_session_context_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.la_session_context
    ADD CONSTRAINT idx_33761_la_session_context_pkey PRIMARY KEY (context_id);


--
-- Name: salary_scales_official idx_33767_sqlite_autoindex_salary_scales_official_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.salary_scales_official
    ADD CONSTRAINT idx_33767_sqlite_autoindex_salary_scales_official_1 PRIMARY KEY (scale_id);


--
-- Name: salary_notch_values_official idx_33774_sqlite_autoindex_salary_notch_values_official_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.salary_notch_values_official
    ADD CONSTRAINT idx_33774_sqlite_autoindex_salary_notch_values_official_1 PRIMARY KEY (notch_value_id);


--
-- Name: employment_history idx_33781_sqlite_autoindex_employment_history_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employment_history
    ADD CONSTRAINT idx_33781_sqlite_autoindex_employment_history_1 PRIMARY KEY (employment_id);


--
-- Name: payroll_assignment_exception idx_33790_payroll_assignment_exception_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_assignment_exception
    ADD CONSTRAINT idx_33790_payroll_assignment_exception_pkey PRIMARY KEY (id);


--
-- Name: payroll_establishment_position idx_33800_payroll_establishment_position_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_establishment_position
    ADD CONSTRAINT idx_33800_payroll_establishment_position_pkey PRIMARY KEY (id);


--
-- Name: ration_allowance_tiers idx_33810_sqlite_autoindex_ration_allowance_tiers_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.ration_allowance_tiers
    ADD CONSTRAINT idx_33810_sqlite_autoindex_ration_allowance_tiers_1 PRIMARY KEY (tier_id);


--
-- Name: deduction_types idx_33816_sqlite_autoindex_deduction_types_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.deduction_types
    ADD CONSTRAINT idx_33816_sqlite_autoindex_deduction_types_1 PRIMARY KEY (deduction_code);


--
-- Name: employee_deductions idx_33826_sqlite_autoindex_employee_deductions_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employee_deductions
    ADD CONSTRAINT idx_33826_sqlite_autoindex_employee_deductions_1 PRIMARY KEY (employee_id, deduction_code, effective_from);


--
-- Name: payroll_run_item_deductions idx_33833_payroll_run_item_deductions_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_deductions
    ADD CONSTRAINT idx_33833_payroll_run_item_deductions_pkey PRIMARY KEY (item_deduction_id);


--
-- Name: madison_parent_coverage_tiers idx_33839_sqlite_autoindex_madison_parent_coverage_tiers_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.madison_parent_coverage_tiers
    ADD CONSTRAINT idx_33839_sqlite_autoindex_madison_parent_coverage_tiers_1 PRIMARY KEY (tier_id);


--
-- Name: overtime_requests idx_33846_overtime_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.overtime_requests
    ADD CONSTRAINT idx_33846_overtime_requests_pkey PRIMARY KEY (overtime_id);


--
-- Name: salary_scales_2026 idx_33865_sqlite_autoindex_salary_scales_2026_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.salary_scales_2026
    ADD CONSTRAINT idx_33865_sqlite_autoindex_salary_scales_2026_1 PRIMARY KEY (grade, notch);


--
-- Name: province_codes idx_33870_sqlite_autoindex_province_codes_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.province_codes
    ADD CONSTRAINT idx_33870_sqlite_autoindex_province_codes_1 PRIMARY KEY (province_name);


--
-- Name: length_of_stay idx_33875_sqlite_autoindex_length_of_stay_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.length_of_stay
    ADD CONSTRAINT idx_33875_sqlite_autoindex_length_of_stay_1 PRIMARY KEY (employee_id);


--
-- Name: vacancy_status idx_33881_sqlite_autoindex_vacancy_status_1; Type: CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.vacancy_status
    ADD CONSTRAINT idx_33881_sqlite_autoindex_vacancy_status_1 PRIMARY KEY (position_code);


--
-- Name: idx_32814_sqlite_autoindex_authority_codes_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_32814_sqlite_autoindex_authority_codes_2 ON public.authority_codes USING btree (authority_code);


--
-- Name: idx_32901_sqlite_autoindex_sections_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_32901_sqlite_autoindex_sections_1 ON public.sections USING btree (section_code);


--
-- Name: idx_32986_sqlite_autoindex_finance_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_32986_sqlite_autoindex_finance_positions_1 ON public.finance_positions USING btree (position_id);


--
-- Name: idx_33031_sqlite_autoindex_council_types_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33031_sqlite_autoindex_council_types_1 ON public.council_types USING btree (council_type_code);


--
-- Name: idx_33038_sqlite_autoindex_salary_scales_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33038_sqlite_autoindex_salary_scales_1 ON public.salary_scales USING btree (scale_code);


--
-- Name: idx_33074_sqlite_autoindex_leave_types_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33074_sqlite_autoindex_leave_types_1 ON public.leave_types USING btree (leave_type_code);


--
-- Name: idx_33086_sqlite_autoindex_hr_recipients_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33086_sqlite_autoindex_hr_recipients_1 ON public.hr_recipients USING btree (employee_id);


--
-- Name: idx_33094_idx_notification_recipient; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33094_idx_notification_recipient ON public.mothers_day_notification_log USING btree (recipient_id);


--
-- Name: idx_33094_idx_notification_status; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33094_idx_notification_status ON public.mothers_day_notification_log USING btree (status);


--
-- Name: idx_33094_idx_notification_tracking; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33094_idx_notification_tracking ON public.mothers_day_notification_log USING btree (tracking_id);


--
-- Name: idx_33102_idx_acknowledgments_tracking; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33102_idx_acknowledgments_tracking ON public.mothers_day_acknowledgments USING btree (tracking_id);


--
-- Name: idx_33109_idx_notification_history_recipient; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33109_idx_notification_history_recipient ON public.notification_history USING btree (recipient_id);


--
-- Name: idx_33109_idx_notification_history_tracking; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33109_idx_notification_history_tracking ON public.notification_history USING btree (tracking_id);


--
-- Name: idx_33127_idx_sms_delivery_phone; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33127_idx_sms_delivery_phone ON public.sms_delivery_log USING btree (phone_number);


--
-- Name: idx_33127_idx_sms_delivery_status; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33127_idx_sms_delivery_status ON public.sms_delivery_log USING btree (status);


--
-- Name: idx_33142_idx_mothers_day_employee; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33142_idx_mothers_day_employee ON public.mothers_day_leave_tracking USING btree (employee_id);


--
-- Name: idx_33142_idx_mothers_day_month; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33142_idx_mothers_day_month ON public.mothers_day_leave_tracking USING btree (month_year);


--
-- Name: idx_33142_idx_mothers_day_status; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33142_idx_mothers_day_status ON public.mothers_day_leave_tracking USING btree (status);


--
-- Name: idx_33142_idx_mothers_day_supervisor; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33142_idx_mothers_day_supervisor ON public.mothers_day_leave_tracking USING btree (supervisor_id);


--
-- Name: idx_33155_idx_notification_queue_status; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33155_idx_notification_queue_status ON public.notification_queue USING btree (status);


--
-- Name: idx_33155_idx_notification_queue_tracking; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33155_idx_notification_queue_tracking ON public.notification_queue USING btree (tracking_id);


--
-- Name: idx_33163_idx_eng_council; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33163_idx_eng_council ON public.eng_position_hierarchy USING btree (council_type);


--
-- Name: idx_33163_idx_eng_position_id; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33163_idx_eng_position_id ON public.eng_position_hierarchy USING btree (position_id);


--
-- Name: idx_33163_idx_eng_reports_to; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33163_idx_eng_reports_to ON public.eng_position_hierarchy USING btree (reports_to_position_id);


--
-- Name: idx_33176_sqlite_autoindex_position_role_codes_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33176_sqlite_autoindex_position_role_codes_2 ON public.position_role_codes USING btree (role_code);


--
-- Name: idx_33182_idx_supervision_council; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33182_idx_supervision_council ON public.position_supervision USING btree (council_type_id);


--
-- Name: idx_33182_idx_supervision_hod; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33182_idx_supervision_hod ON public.position_supervision USING btree (hod_id);


--
-- Name: idx_33182_idx_supervision_position; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33182_idx_supervision_position ON public.position_supervision USING btree (position_standard_id);


--
-- Name: idx_33182_idx_supervision_supervisor; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33182_idx_supervision_supervisor ON public.position_supervision USING btree (immediate_supervisor_id);


--
-- Name: idx_33182_sqlite_autoindex_position_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33182_sqlite_autoindex_position_supervision_1 ON public.position_supervision USING btree (position_standard_id);


--
-- Name: idx_33191_sqlite_autoindex_executive_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33191_sqlite_autoindex_executive_positions_1 ON public.executive_positions USING btree (standard_id);


--
-- Name: idx_33211_idx_unique_current_jd; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33211_idx_unique_current_jd ON public.job_description_documents USING btree (position_standard_id);


--
-- Name: idx_33228_sqlite_autoindex_hra_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33228_sqlite_autoindex_hra_supervision_1 ON public.hra_supervision USING btree (position_standard_id);


--
-- Name: idx_33238_sqlite_autoindex_legal_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33238_sqlite_autoindex_legal_supervision_1 ON public.legal_supervision USING btree (position_standard_id);


--
-- Name: idx_33248_sqlite_autoindex_health_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33248_sqlite_autoindex_health_supervision_1 ON public.health_supervision USING btree (position_standard_id);


--
-- Name: idx_33257_sqlite_autoindex_community_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33257_sqlite_autoindex_community_positions_1 ON public.community_positions USING btree (position_id);


--
-- Name: idx_33257_sqlite_autoindex_community_positions_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33257_sqlite_autoindex_community_positions_2 ON public.community_positions USING btree (standard_id);


--
-- Name: idx_33267_sqlite_autoindex_community_sections_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33267_sqlite_autoindex_community_sections_1 ON public.community_sections USING btree (section_code);


--
-- Name: idx_33274_sqlite_autoindex_community_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33274_sqlite_autoindex_community_units_1 ON public.community_units USING btree (unit_code);


--
-- Name: idx_33282_sqlite_autoindex_community_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33282_sqlite_autoindex_community_supervision_1 ON public.community_supervision USING btree (position_standard_id);


--
-- Name: idx_33291_sqlite_autoindex_procurement_sections_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33291_sqlite_autoindex_procurement_sections_1 ON public.procurement_sections USING btree (section_code);


--
-- Name: idx_33297_sqlite_autoindex_procurement_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33297_sqlite_autoindex_procurement_units_1 ON public.procurement_units USING btree (unit_code);


--
-- Name: idx_33304_sqlite_autoindex_procurement_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33304_sqlite_autoindex_procurement_positions_1 ON public.procurement_positions USING btree (standard_id);


--
-- Name: idx_33316_sqlite_autoindex_procurement_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33316_sqlite_autoindex_procurement_supervision_1 ON public.procurement_supervision USING btree (position_standard_id);


--
-- Name: idx_33326_sqlite_autoindex_audit_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33326_sqlite_autoindex_audit_positions_1 ON public.audit_positions USING btree (standard_id);


--
-- Name: idx_33337_sqlite_autoindex_audit_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33337_sqlite_autoindex_audit_units_1 ON public.audit_units USING btree (unit_code);


--
-- Name: idx_33344_sqlite_autoindex_audit_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33344_sqlite_autoindex_audit_supervision_1 ON public.audit_supervision USING btree (position_standard_id);


--
-- Name: idx_33354_sqlite_autoindex_cos_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33354_sqlite_autoindex_cos_units_1 ON public.cos_units USING btree (unit_code);


--
-- Name: idx_33361_sqlite_autoindex_cos_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33361_sqlite_autoindex_cos_positions_1 ON public.cos_positions USING btree (standard_id);


--
-- Name: idx_33371_sqlite_autoindex_cos_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33371_sqlite_autoindex_cos_supervision_1 ON public.cos_supervision USING btree (position_standard_id);


--
-- Name: idx_33381_sqlite_autoindex_toc_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33381_sqlite_autoindex_toc_units_1 ON public.toc_units USING btree (unit_code);


--
-- Name: idx_33388_sqlite_autoindex_toc_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33388_sqlite_autoindex_toc_positions_1 ON public.toc_positions USING btree (standard_id);


--
-- Name: idx_33398_sqlite_autoindex_toc_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33398_sqlite_autoindex_toc_supervision_1 ON public.toc_supervision USING btree (position_standard_id);


--
-- Name: idx_33408_sqlite_autoindex_toc_city_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33408_sqlite_autoindex_toc_city_units_1 ON public.toc_city_units USING btree (unit_code);


--
-- Name: idx_33415_sqlite_autoindex_toc_city_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33415_sqlite_autoindex_toc_city_positions_1 ON public.toc_city_positions USING btree (standard_id);


--
-- Name: idx_33425_sqlite_autoindex_toc_city_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33425_sqlite_autoindex_toc_city_supervision_1 ON public.toc_city_supervision USING btree (position_standard_id);


--
-- Name: idx_33435_sqlite_autoindex_ict_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33435_sqlite_autoindex_ict_positions_1 ON public.ict_positions USING btree (standard_id);


--
-- Name: idx_33445_sqlite_autoindex_ict_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33445_sqlite_autoindex_ict_units_1 ON public.ict_units USING btree (unit_code);


--
-- Name: idx_33452_sqlite_autoindex_ict_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33452_sqlite_autoindex_ict_supervision_1 ON public.ict_supervision USING btree (position_standard_id);


--
-- Name: idx_33462_sqlite_autoindex_ict_city_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33462_sqlite_autoindex_ict_city_positions_1 ON public.ict_city_positions USING btree (standard_id);


--
-- Name: idx_33472_sqlite_autoindex_ict_city_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33472_sqlite_autoindex_ict_city_units_1 ON public.ict_city_units USING btree (unit_code);


--
-- Name: idx_33479_sqlite_autoindex_ict_city_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33479_sqlite_autoindex_ict_city_supervision_1 ON public.ict_city_supervision USING btree (position_standard_id);


--
-- Name: idx_33489_sqlite_autoindex_commercial_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33489_sqlite_autoindex_commercial_positions_1 ON public.commercial_positions USING btree (standard_id);


--
-- Name: idx_33499_sqlite_autoindex_commercial_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33499_sqlite_autoindex_commercial_units_1 ON public.commercial_units USING btree (unit_code);


--
-- Name: idx_33506_sqlite_autoindex_commercial_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33506_sqlite_autoindex_commercial_supervision_1 ON public.commercial_supervision USING btree (position_standard_id);


--
-- Name: idx_33516_sqlite_autoindex_commercial_city_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33516_sqlite_autoindex_commercial_city_positions_1 ON public.commercial_city_positions USING btree (standard_id);


--
-- Name: idx_33526_sqlite_autoindex_commercial_city_units_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33526_sqlite_autoindex_commercial_city_units_1 ON public.commercial_city_units USING btree (unit_code);


--
-- Name: idx_33533_sqlite_autoindex_commercial_city_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33533_sqlite_autoindex_commercial_city_supervision_1 ON public.commercial_city_supervision USING btree (position_standard_id);


--
-- Name: idx_33543_sqlite_autoindex_valuation_city_positions_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33543_sqlite_autoindex_valuation_city_positions_1 ON public.valuation_city_positions USING btree (standard_id);


--
-- Name: idx_33553_sqlite_autoindex_valuation_city_supervision_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33553_sqlite_autoindex_valuation_city_supervision_1 ON public.valuation_city_supervision USING btree (position_standard_id);


--
-- Name: idx_33562_idx_audit_council_approver; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33562_idx_audit_council_approver ON public.immutable_audit_log USING btree (council_id, approved_by);


--
-- Name: idx_33562_idx_audit_council_event; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33562_idx_audit_council_event ON public.immutable_audit_log USING btree (council_id, event_type);


--
-- Name: idx_33562_idx_audit_council_period; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33562_idx_audit_council_period ON public.immutable_audit_log USING btree (council_id, period_date);


--
-- Name: idx_33562_idx_audit_period; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33562_idx_audit_period ON public.immutable_audit_log USING btree (period_date);


--
-- Name: idx_33568_sqlite_autoindex_provinces_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33568_sqlite_autoindex_provinces_2 ON public.provinces USING btree (province_name);


--
-- Name: idx_33574_sqlite_autoindex_authority_master_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33574_sqlite_autoindex_authority_master_2 ON public.authority_master USING btree (legacy_authority_code);


--
-- Name: idx_33574_sqlite_autoindex_authority_master_3; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33574_sqlite_autoindex_authority_master_3 ON public.authority_master USING btree (authority_ref);


--
-- Name: idx_33574_sqlite_autoindex_authority_master_4; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33574_sqlite_autoindex_authority_master_4 ON public.authority_master USING btree (authority_name);


--
-- Name: idx_33574_sqlite_autoindex_authority_master_5; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33574_sqlite_autoindex_authority_master_5 ON public.authority_master USING btree (official_name);


--
-- Name: idx_33607_sqlite_autoindex_payroll_periods_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33607_sqlite_autoindex_payroll_periods_1 ON public.payroll_periods USING btree (period_code);


--
-- Name: idx_33615_sqlite_autoindex_payroll_runs_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33615_sqlite_autoindex_payroll_runs_1 ON public.payroll_runs USING btree (run_code);


--
-- Name: idx_33662_sqlite_autoindex_local_authorities_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33662_sqlite_autoindex_local_authorities_2 ON public.local_authorities USING btree (authority_code);


--
-- Name: idx_33673_sqlite_autoindex_payroll_schedules_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33673_sqlite_autoindex_payroll_schedules_2 ON public.payroll_schedules USING btree (authority_id, period_year, period_month);


--
-- Name: idx_33679_sqlite_autoindex_payment_batches_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33679_sqlite_autoindex_payment_batches_2 ON public.payment_batches USING btree (batch_reference);


--
-- Name: idx_33692_sqlite_autoindex_payroll_run_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33692_sqlite_autoindex_payroll_run_2 ON public.payroll_run USING btree (payslip_number);


--
-- Name: idx_33692_sqlite_autoindex_payroll_run_3; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33692_sqlite_autoindex_payroll_run_3 ON public.payroll_run USING btree (document_verification_code);


--
-- Name: idx_33692_sqlite_autoindex_payroll_run_4; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33692_sqlite_autoindex_payroll_run_4 ON public.payroll_run USING btree (schedule_id, employee_id);


--
-- Name: idx_33713_sqlite_autoindex_la_payroll_config_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33713_sqlite_autoindex_la_payroll_config_2 ON public.la_payroll_config USING btree (authority_id);


--
-- Name: idx_33722_sqlite_autoindex_la_payroll_submissions_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33722_sqlite_autoindex_la_payroll_submissions_2 ON public.la_payroll_submissions USING btree (authority_id, period_year, period_month);


--
-- Name: idx_33730_idx_ci_authority; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33730_idx_ci_authority ON public.compliance_issues USING btree (authority_id);


--
-- Name: idx_33730_idx_ci_late_submission_dedup; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33730_idx_ci_late_submission_dedup ON public.compliance_issues USING btree (submission_id, issue_type);


--
-- Name: idx_33730_idx_ci_status; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33730_idx_ci_status ON public.compliance_issues USING btree (resolution_status);


--
-- Name: idx_33730_idx_ci_submission; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33730_idx_ci_submission ON public.compliance_issues USING btree (submission_id);


--
-- Name: idx_33730_idx_ci_unauth_remote_dedup; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33730_idx_ci_unauth_remote_dedup ON public.compliance_issues USING btree (submission_id, issue_type);


--
-- Name: idx_33730_idx_ci_unauth_rural_dedup; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33730_idx_ci_unauth_rural_dedup ON public.compliance_issues USING btree (submission_id, issue_type);


--
-- Name: idx_33738_idx_cpa_authority_period; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33738_idx_cpa_authority_period ON public.central_payslip_archive USING btree (authority_id, period_year, period_month);


--
-- Name: idx_33738_idx_cpa_employee; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33738_idx_cpa_employee ON public.central_payslip_archive USING btree (employee_number);


--
-- Name: idx_33745_idx_shc_authority; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33745_idx_shc_authority ON public.station_hardship_classification USING btree (authority_id);


--
-- Name: idx_33745_idx_shc_current; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33745_idx_shc_current ON public.station_hardship_classification USING btree (is_current);


--
-- Name: idx_33745_sqlite_autoindex_station_hardship_classification_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33745_sqlite_autoindex_station_hardship_classification_2 ON public.station_hardship_classification USING btree (authority_id, is_current);


--
-- Name: idx_33755_idx_shh_authority; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33755_idx_shh_authority ON public.station_hardship_history USING btree (authority_id);


--
-- Name: idx_33767_sqlite_autoindex_salary_scales_official_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33767_sqlite_autoindex_salary_scales_official_2 ON public.salary_scales_official USING btree (salary_scale, effective_from);


--
-- Name: idx_33774_idx_snvo_scale_date; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33774_idx_snvo_scale_date ON public.salary_notch_values_official USING btree (salary_scale, notch_number, effective_from);


--
-- Name: idx_33774_sqlite_autoindex_salary_notch_values_official_2; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33774_sqlite_autoindex_salary_notch_values_official_2 ON public.salary_notch_values_official USING btree (salary_scale, notch_number, effective_from);


--
-- Name: idx_33781_idx_eh_authority; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33781_idx_eh_authority ON public.employment_history USING btree (authority_id);


--
-- Name: idx_33781_idx_eh_employee; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33781_idx_eh_employee ON public.employment_history USING btree (employee_id);


--
-- Name: idx_33781_idx_eh_scale_notch; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33781_idx_eh_scale_notch ON public.employment_history USING btree (salary_scale, notch_number);


--
-- Name: idx_33790_idx_payroll_assignment_exception_active; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33790_idx_payroll_assignment_exception_active ON public.payroll_assignment_exception USING btree (employee_id, is_active, effective_from);


--
-- Name: idx_33790_sqlite_autoindex_payroll_assignment_exception_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33790_sqlite_autoindex_payroll_assignment_exception_1 ON public.payroll_assignment_exception USING btree (employee_id, exception_type, effective_from);


--
-- Name: idx_33800_idx_payroll_establishment_position_dept; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33800_idx_payroll_establishment_position_dept ON public.payroll_establishment_position USING btree (department_code, position_title);


--
-- Name: idx_33800_idx_payroll_establishment_position_match; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33800_idx_payroll_establishment_position_match ON public.payroll_establishment_position USING btree (normalized_title, salary_scale_code, department_code);


--
-- Name: idx_33800_sqlite_autoindex_payroll_establishment_position_1; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE UNIQUE INDEX idx_33800_sqlite_autoindex_payroll_establishment_position_1 ON public.payroll_establishment_position USING btree (source_table, position_code);


--
-- Name: idx_33846_idx_overtime_audit; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33846_idx_overtime_audit ON public.overtime_requests USING btree (audit_authorized, audit_authorized_at);


--
-- Name: idx_33846_idx_overtime_date; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33846_idx_overtime_date ON public.overtime_requests USING btree (overtime_date);


--
-- Name: idx_33846_idx_overtime_employee; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33846_idx_overtime_employee ON public.overtime_requests USING btree (employee_id);


--
-- Name: idx_33846_idx_overtime_payroll; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33846_idx_overtime_payroll ON public.overtime_requests USING btree (payroll_integrated, payroll_month);


--
-- Name: idx_33846_idx_overtime_principal_approval; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33846_idx_overtime_principal_approval ON public.overtime_requests USING btree (principal_officer_approved, principal_officer_approved_at);


--
-- Name: idx_33846_idx_overtime_requested_by; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33846_idx_overtime_requested_by ON public.overtime_requests USING btree (requested_by_employee_id);


--
-- Name: idx_33846_idx_overtime_status; Type: INDEX; Schema: public; Owner: chisenga
--

CREATE INDEX idx_33846_idx_overtime_status ON public.overtime_requests USING btree (status);


--
-- Name: authority_master authority_master_province_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.authority_master
    ADD CONSTRAINT authority_master_province_code_fkey FOREIGN KEY (province_code) REFERENCES public.provinces(province_code);


--
-- Name: central_payslip_archive central_payslip_archive_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.central_payslip_archive
    ADD CONSTRAINT central_payslip_archive_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: central_payslip_archive central_payslip_archive_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.central_payslip_archive
    ADD CONSTRAINT central_payslip_archive_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.la_payroll_submissions(submission_id);


--
-- Name: community_sections community_sections_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_sections
    ADD CONSTRAINT community_sections_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: community_supervision community_supervision_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_supervision
    ADD CONSTRAINT community_supervision_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: community_units community_units_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_units
    ADD CONSTRAINT community_units_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: community_units community_units_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.community_units
    ADD CONSTRAINT community_units_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.community_sections(section_id);


--
-- Name: compliance_issues compliance_issues_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.compliance_issues
    ADD CONSTRAINT compliance_issues_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: compliance_issues compliance_issues_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.compliance_issues
    ADD CONSTRAINT compliance_issues_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.la_payroll_submissions(submission_id);


--
-- Name: cos_positions cos_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.cos_positions
    ADD CONSTRAINT cos_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.cos_units(unit_id);


--
-- Name: employee_allowances employee_allowances_allowance_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employee_allowances
    ADD CONSTRAINT employee_allowances_allowance_code_fkey FOREIGN KEY (allowance_code) REFERENCES public.allowance_types(allowance_code);


--
-- Name: employee_deductions employee_deductions_deduction_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employee_deductions
    ADD CONSTRAINT employee_deductions_deduction_code_fkey FOREIGN KEY (deduction_code) REFERENCES public.deduction_types(deduction_code);


--
-- Name: employment_history employment_history_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.employment_history
    ADD CONSTRAINT employment_history_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: eng_position_hierarchy eng_position_hierarchy_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_position_hierarchy
    ADD CONSTRAINT eng_position_hierarchy_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: eng_positions eng_positions_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_positions
    ADD CONSTRAINT eng_positions_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: eng_positions eng_positions_reports_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_positions
    ADD CONSTRAINT eng_positions_reports_to_fkey FOREIGN KEY (reports_to) REFERENCES public.eng_positions(position_id);


--
-- Name: eng_positions eng_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_positions
    ADD CONSTRAINT eng_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.eng_units(unit_id);


--
-- Name: eng_units eng_units_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_units
    ADD CONSTRAINT eng_units_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: eng_units eng_units_parent_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.eng_units
    ADD CONSTRAINT eng_units_parent_unit_id_fkey FOREIGN KEY (parent_unit_id) REFERENCES public.eng_units(unit_id);


--
-- Name: finance_positions finance_positions_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_positions
    ADD CONSTRAINT finance_positions_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: finance_positions finance_positions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_positions
    ADD CONSTRAINT finance_positions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.finance_sections(section_id);


--
-- Name: finance_positions finance_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_positions
    ADD CONSTRAINT finance_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.finance_units(unit_id);


--
-- Name: finance_sections finance_sections_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_sections
    ADD CONSTRAINT finance_sections_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: finance_units finance_units_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_units
    ADD CONSTRAINT finance_units_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: finance_units finance_units_parent_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_units
    ADD CONSTRAINT finance_units_parent_unit_id_fkey FOREIGN KEY (parent_unit_id) REFERENCES public.finance_units(unit_id);


--
-- Name: finance_units finance_units_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.finance_units
    ADD CONSTRAINT finance_units_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.finance_sections(section_id);


--
-- Name: health_positions health_positions_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_positions
    ADD CONSTRAINT health_positions_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: health_positions health_positions_salary_scale_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_positions
    ADD CONSTRAINT health_positions_salary_scale_fkey FOREIGN KEY (salary_scale) REFERENCES public.salary_scales(scale_code);


--
-- Name: health_positions health_positions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_positions
    ADD CONSTRAINT health_positions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.health_sections(section_id);


--
-- Name: health_positions health_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_positions
    ADD CONSTRAINT health_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.health_units(unit_id);


--
-- Name: health_sections health_sections_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_sections
    ADD CONSTRAINT health_sections_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: health_units health_units_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_units
    ADD CONSTRAINT health_units_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: health_units health_units_parent_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_units
    ADD CONSTRAINT health_units_parent_unit_id_fkey FOREIGN KEY (parent_unit_id) REFERENCES public.health_units(unit_id);


--
-- Name: health_units health_units_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.health_units
    ADD CONSTRAINT health_units_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.health_sections(section_id);


--
-- Name: hra_leaveapprovalchains hra_leaveapprovalchains_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_leaveapprovalchains
    ADD CONSTRAINT hra_leaveapprovalchains_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.hra_positions(position_id);


--
-- Name: hra_positions hra_positions_council_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_positions
    ADD CONSTRAINT hra_positions_council_id_fkey FOREIGN KEY (council_id) REFERENCES public.councils(council_id);


--
-- Name: hra_reportinglines hra_reportinglines_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_reportinglines
    ADD CONSTRAINT hra_reportinglines_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.hra_positions(position_id);


--
-- Name: hra_reportinglines hra_reportinglines_reports_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.hra_reportinglines
    ADD CONSTRAINT hra_reportinglines_reports_to_fkey FOREIGN KEY (reports_to) REFERENCES public.hra_positions(position_id);


--
-- Name: jd_review_queue jd_review_queue_jd_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.jd_review_queue
    ADD CONSTRAINT jd_review_queue_jd_id_fkey FOREIGN KEY (jd_id) REFERENCES public.job_description_documents(id);


--
-- Name: la_payroll_config la_payroll_config_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.la_payroll_config
    ADD CONSTRAINT la_payroll_config_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: la_payroll_submissions la_payroll_submissions_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.la_payroll_submissions
    ADD CONSTRAINT la_payroll_submissions_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: la_session_context la_session_context_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.la_session_context
    ADD CONSTRAINT la_session_context_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: leave_approval_chain leave_approval_chain_approver_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_approval_chain
    ADD CONSTRAINT leave_approval_chain_approver_position_id_fkey FOREIGN KEY (approver_position_id) REFERENCES public.positions(position_id);


--
-- Name: leave_approval_chain leave_approval_chain_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.leave_approval_chain
    ADD CONSTRAINT leave_approval_chain_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.positions(position_id);


--
-- Name: legal_positions legal_positions_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_positions
    ADD CONSTRAINT legal_positions_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: legal_positions legal_positions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_positions
    ADD CONSTRAINT legal_positions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.legal_sections(section_id);


--
-- Name: legal_positions legal_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_positions
    ADD CONSTRAINT legal_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.legal_units(unit_id);


--
-- Name: legal_sections legal_sections_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_sections
    ADD CONSTRAINT legal_sections_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: legal_units legal_units_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_units
    ADD CONSTRAINT legal_units_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: legal_units legal_units_parent_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_units
    ADD CONSTRAINT legal_units_parent_unit_id_fkey FOREIGN KEY (parent_unit_id) REFERENCES public.legal_units(unit_id);


--
-- Name: legal_units legal_units_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.legal_units
    ADD CONSTRAINT legal_units_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.legal_sections(section_id);


--
-- Name: length_of_stay length_of_stay_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.length_of_stay
    ADD CONSTRAINT length_of_stay_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- Name: mothers_day_acknowledgments mothers_day_acknowledgments_tracking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.mothers_day_acknowledgments
    ADD CONSTRAINT mothers_day_acknowledgments_tracking_id_fkey FOREIGN KEY (tracking_id) REFERENCES public.mothers_day_leave_tracking(tracking_id);


--
-- Name: mothers_day_notification_log mothers_day_notification_log_tracking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.mothers_day_notification_log
    ADD CONSTRAINT mothers_day_notification_log_tracking_id_fkey FOREIGN KEY (tracking_id) REFERENCES public.mothers_day_leave_tracking(tracking_id);


--
-- Name: notification_history notification_history_tracking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.notification_history
    ADD CONSTRAINT notification_history_tracking_id_fkey FOREIGN KEY (tracking_id) REFERENCES public.mothers_day_leave_tracking(tracking_id);


--
-- Name: notification_queue notification_queue_tracking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.notification_queue
    ADD CONSTRAINT notification_queue_tracking_id_fkey FOREIGN KEY (tracking_id) REFERENCES public.mothers_day_leave_tracking(tracking_id);


--
-- Name: payment_batches payment_batches_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payment_batches
    ADD CONSTRAINT payment_batches_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: payment_batches payment_batches_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payment_batches
    ADD CONSTRAINT payment_batches_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.payroll_schedules(schedule_id);


--
-- Name: payment_delay_approvals payment_delay_approvals_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payment_delay_approvals
    ADD CONSTRAINT payment_delay_approvals_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: payment_delay_approvals payment_delay_approvals_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payment_delay_approvals
    ADD CONSTRAINT payment_delay_approvals_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.payroll_schedules(schedule_id);


--
-- Name: payroll_run payroll_run_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run
    ADD CONSTRAINT payroll_run_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: payroll_run_item_allowances payroll_run_item_allowances_run_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_allowances
    ADD CONSTRAINT payroll_run_item_allowances_run_item_id_fkey FOREIGN KEY (run_item_id) REFERENCES public.payroll_run_items(run_item_id);


--
-- Name: payroll_run_item_deductions payroll_run_item_deductions_run_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_deductions
    ADD CONSTRAINT payroll_run_item_deductions_run_item_id_fkey FOREIGN KEY (run_item_id) REFERENCES public.payroll_run_items(run_item_id);


--
-- Name: payroll_run_item_obligations payroll_run_item_obligations_run_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_item_obligations
    ADD CONSTRAINT payroll_run_item_obligations_run_item_id_fkey FOREIGN KEY (run_item_id) REFERENCES public.payroll_run_items(run_item_id);


--
-- Name: payroll_run_items payroll_run_items_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run_items
    ADD CONSTRAINT payroll_run_items_run_id_fkey FOREIGN KEY (run_id) REFERENCES public.payroll_runs(run_id);


--
-- Name: payroll_run payroll_run_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_run
    ADD CONSTRAINT payroll_run_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.payroll_schedules(schedule_id);


--
-- Name: payroll_runs payroll_runs_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_runs
    ADD CONSTRAINT payroll_runs_period_id_fkey FOREIGN KEY (period_id) REFERENCES public.payroll_periods(period_id);


--
-- Name: payroll_schedules payroll_schedules_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payroll_schedules
    ADD CONSTRAINT payroll_schedules_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: payslip_access_log payslip_access_log_payroll_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.payslip_access_log
    ADD CONSTRAINT payslip_access_log_payroll_id_fkey FOREIGN KEY (payroll_id) REFERENCES public.payroll_run(payroll_id);


--
-- Name: planning_positions planning_positions_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_positions
    ADD CONSTRAINT planning_positions_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: planning_positions planning_positions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_positions
    ADD CONSTRAINT planning_positions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.planning_sections(section_id);


--
-- Name: planning_positions planning_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_positions
    ADD CONSTRAINT planning_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.planning_units(unit_id);


--
-- Name: planning_sections planning_sections_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_sections
    ADD CONSTRAINT planning_sections_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: planning_units planning_units_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_units
    ADD CONSTRAINT planning_units_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: planning_units planning_units_parent_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_units
    ADD CONSTRAINT planning_units_parent_unit_id_fkey FOREIGN KEY (parent_unit_id) REFERENCES public.planning_units(unit_id);


--
-- Name: planning_units planning_units_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.planning_units
    ADD CONSTRAINT planning_units_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.planning_sections(section_id);


--
-- Name: positions positions_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: positions positions_reports_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_reports_to_fkey FOREIGN KEY (reports_to) REFERENCES public.positions(position_id);


--
-- Name: positions positions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.sections(section_id);


--
-- Name: procurement_positions procurement_positions_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_positions
    ADD CONSTRAINT procurement_positions_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: procurement_positions procurement_positions_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_positions
    ADD CONSTRAINT procurement_positions_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.procurement_sections(section_id);


--
-- Name: procurement_positions procurement_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_positions
    ADD CONSTRAINT procurement_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.procurement_units(unit_id);


--
-- Name: procurement_sections procurement_sections_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_sections
    ADD CONSTRAINT procurement_sections_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: procurement_supervision procurement_supervision_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_supervision
    ADD CONSTRAINT procurement_supervision_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: procurement_units procurement_units_council_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_units
    ADD CONSTRAINT procurement_units_council_type_id_fkey FOREIGN KEY (council_type_id) REFERENCES public.council_types(council_type_id);


--
-- Name: procurement_units procurement_units_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.procurement_units
    ADD CONSTRAINT procurement_units_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.procurement_sections(section_id);


--
-- Name: salary_notch_values_official salary_notch_values_official_salary_scale_effective_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.salary_notch_values_official
    ADD CONSTRAINT salary_notch_values_official_salary_scale_effective_from_fkey FOREIGN KEY (salary_scale, effective_from) REFERENCES public.salary_scales_official(salary_scale, effective_from);


--
-- Name: sms_delivery_log sms_delivery_log_notification_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sms_delivery_log
    ADD CONSTRAINT sms_delivery_log_notification_queue_id_fkey FOREIGN KEY (notification_queue_id) REFERENCES public.notification_queue(queue_id);


--
-- Name: sms_message_parts sms_message_parts_notification_queue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.sms_message_parts
    ADD CONSTRAINT sms_message_parts_notification_queue_id_fkey FOREIGN KEY (notification_queue_id) REFERENCES public.notification_queue(queue_id);


--
-- Name: station_hardship_classification station_hardship_classification_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.station_hardship_classification
    ADD CONSTRAINT station_hardship_classification_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: station_hardship_history station_hardship_history_authority_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.station_hardship_history
    ADD CONSTRAINT station_hardship_history_authority_id_fkey FOREIGN KEY (authority_id) REFERENCES public.local_authorities(authority_id);


--
-- Name: toc_city_positions toc_city_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_city_positions
    ADD CONSTRAINT toc_city_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.toc_city_units(unit_id);


--
-- Name: toc_positions toc_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.toc_positions
    ADD CONSTRAINT toc_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.toc_units(unit_id);


--
-- Name: vacancy_status vacancy_status_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chisenga
--

ALTER TABLE ONLY public.vacancy_status
    ADD CONSTRAINT vacancy_status_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(employee_id);


--
-- PostgreSQL database dump complete
--

\unrestrict s0J9LFmC6gWYCJ9HHrPQqUqTxChDehAY1XKag6afFba6PResuh6LZNQDmItUu9c

