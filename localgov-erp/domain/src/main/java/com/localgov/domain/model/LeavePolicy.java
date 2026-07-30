package com.localgov.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

/**
 * Maps to the {@code leave_policy} PostgreSQL table.
 * Single source of truth for all leave policy definitions.
 */
@Entity
@Table(name = "leave_policy")
public class LeavePolicy {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "leave_type")
    private String leaveType;

    @Column(name = "division")
    private String division;

    @Column(name = "accrual_rate")
    private Double accrualRate;

    @Column(name = "max_days")
    private Integer maxDays;

    @Column(name = "carry_forward")
    private Integer carryForward;

    @Column(name = "eligibility")
    private String eligibility;

    /** For fixed-duration types (Maternity=98, Paternity=10).
     *  For Compassionate: CHILD/PARENT max days.
     *  For Mother's Day: 1 (days per month). */
    @Column(name = "fixed_days")
    private Integer fixedDays;

    @Column(name = "max_accumulation")
    private Integer maxAccumulation;

    @Column(name = "continuous_leave_limit")
    private Integer continuousLeaveLimit;

    /** Max duration per request.
     *  For Compassionate: SPOUSE max days.
     *  For Family Care / Mother's Day: days per request. */
    @Column(name = "max_duration")
    private Integer maxDuration;

    @Column(name = "advance_notice")
    private Integer advanceNotice;

    /** "ALL", "FEMALE", or "MALE" */
    @Column(name = "gender_restriction")
    private String genderRestriction;

    /** "WORKING" (excludes Sat/Sun/holidays) or "CALENDAR" (inclusive). */
    @Column(name = "day_calculation_mode")
    private String dayCalculationMode;

    /** Max days takeable per calendar month (Mother's Day = 1). */
    @Column(name = "monthly_limit")
    private Integer monthlyLimit;

    /** Max days takeable per calendar year (Family Care = 3). */
    @Column(name = "annual_limit")
    private Integer annualLimit;

    /** Sick leave: full-pay months for established employees (3). */
    @Column(name = "sick_full_pay_months")
    private Integer sickFullPayMonths;

    /** Sick leave: half-pay months for established employees (3). */
    @Column(name = "sick_half_pay_months")
    private Integer sickHalfPayMonths;

    /** Sick leave: full-pay working days for short-term contract (26). */
    @Column(name = "sick_full_pay_days_contract")
    private Integer sickFullPayDaysContract;

    /** Sick leave: half-pay working days for short-term contract (26). */
    @Column(name = "sick_half_pay_days_contract")
    private Integer sickHalfPayDaysContract;

    @Column(name = "requires_birth_proof")
    private Boolean requiresBirthProof;

    @Column(name = "requires_medical_cert")
    private Boolean requiresMedicalCert;

    @Column(name = "advance_notice_days")
    private Integer advanceNoticeDays;

    /** Minimum chargeable working days required for a Vacation Leave allowance. */
    @Column(name = "vacation_allowance_min_days")
    private Integer vacationAllowanceMinDays;

    /** Number of months that must pass before another Vacation Leave allowance can be paid. */
    @Column(name = "vacation_allowance_frequency_months")
    private Integer vacationAllowanceFrequencyMonths;

    // ── accessors ──────────────────────────────────────────────────────────
    public Long getId()                         { return id; }
    public String getLeaveType()                { return leaveType; }
    public String getDivision()                 { return division; }
    public Double getAccrualRate()              { return accrualRate; }
    public Integer getMaxDays()                 { return maxDays; }
    public Integer getCarryForward()            { return carryForward; }
    public String getEligibility()              { return eligibility; }
    public Integer getFixedDays()               { return fixedDays; }
    public Integer getMaxAccumulation()         { return maxAccumulation; }
    public Integer getContinuousLeaveLimit()   { return continuousLeaveLimit; }
    public Integer getMaxDuration()             { return maxDuration; }
    public Integer getAdvanceNotice()           { return advanceNotice; }
    public String getGenderRestriction()        { return genderRestriction; }
    public String getDayCalculationMode()       { return dayCalculationMode; }
    public Integer getMonthlyLimit()            { return monthlyLimit; }
    public Integer getAnnualLimit()             { return annualLimit; }
    public Integer getSickFullPayMonths()       { return sickFullPayMonths; }
    public Integer getSickHalfPayMonths()       { return sickHalfPayMonths; }
    public Integer getSickFullPayDaysContract() { return sickFullPayDaysContract; }
    public Integer getSickHalfPayDaysContract() { return sickHalfPayDaysContract; }
    public Boolean getRequiresBirthProof()      { return requiresBirthProof; }
    public Boolean getRequiresMedicalCert()     { return requiresMedicalCert; }
    public Integer getAdvanceNoticeDays()       { return advanceNoticeDays; }
    public Integer getVacationAllowanceMinDays() { return vacationAllowanceMinDays; }
    public Integer getVacationAllowanceFrequencyMonths() { return vacationAllowanceFrequencyMonths; }

    public boolean isCalendarDays() {
        return "CALENDAR".equalsIgnoreCase(dayCalculationMode);
    }
    public boolean isFemaleOnly() {
        return "FEMALE".equalsIgnoreCase(genderRestriction);
    }
    public boolean isMaleOnly() {
        return "MALE".equalsIgnoreCase(genderRestriction);
    }
}
