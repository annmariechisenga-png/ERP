package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonUnwrapped;
import com.localgov.domain.model.LeaveType;

import java.time.LocalDate;

/**
 * Composite leave calculation response.
 * Structured into logical groups for maintainability; serialized flat for
 * backward-compatible API response via {@link JsonUnwrapped}.
 */
public record LeaveCalculationResult(
        @JsonUnwrapped CalculationSummary summary,
        @JsonUnwrapped PolicyEvaluation policyEvaluation,
        @JsonUnwrapped BalanceProjection balanceProjection,
        @JsonUnwrapped AllowanceEvaluation allowanceEvaluation
) {

    /** Factory preserving the original flat constructor signature for internal callers. */
    public LeaveCalculationResult(
            LeaveType leaveType, String policyName, String calculationMode,
            LocalDate startDate, int chargeableDays,
            boolean weekendsExcluded, boolean publicHolidaysExcluded,
            int weekendDaysSkipped, int publicHolidaysSkipped,
            LocalDate leaveEndDate, LocalDate resumeDutiesDate,
            Integer currentLeaveBalance, Integer remainingBalanceAfterApproval,
            boolean deductsFromAccruedBalance, String balanceBucket,
            Integer continuousLeaveLimit, Integer accumulationLimit,
            Integer forfeitedDays, String policyViolationFlag) {
        this(
                new CalculationSummary(leaveType, policyName, calculationMode,
                        startDate, chargeableDays, weekendsExcluded, publicHolidaysExcluded,
                        weekendDaysSkipped, publicHolidaysSkipped,
                        leaveEndDate, resumeDutiesDate),
                new PolicyEvaluation(continuousLeaveLimit, accumulationLimit,
                        forfeitedDays, policyViolationFlag),
                new BalanceProjection(currentLeaveBalance, remainingBalanceAfterApproval,
                        deductsFromAccruedBalance, balanceBucket),
                AllowanceEvaluation.none()
        );
    }

    /** Factory including Vacation Leave allowance evaluation. */
    public LeaveCalculationResult(
            LeaveType leaveType, String policyName, String calculationMode,
            LocalDate startDate, int chargeableDays,
            boolean weekendsExcluded, boolean publicHolidaysExcluded,
            int weekendDaysSkipped, int publicHolidaysSkipped,
            LocalDate leaveEndDate, LocalDate resumeDutiesDate,
            Integer currentLeaveBalance, Integer remainingBalanceAfterApproval,
            boolean deductsFromAccruedBalance, String balanceBucket,
            Integer continuousLeaveLimit, Integer accumulationLimit,
            Integer forfeitedDays, String policyViolationFlag,
            boolean allowanceEligible, String allowanceReason,
            Integer allowanceThresholdDays, Integer allowanceFrequencyMonths) {
        this(
                new CalculationSummary(leaveType, policyName, calculationMode,
                        startDate, chargeableDays, weekendsExcluded, publicHolidaysExcluded,
                        weekendDaysSkipped, publicHolidaysSkipped,
                        leaveEndDate, resumeDutiesDate),
                new PolicyEvaluation(continuousLeaveLimit, accumulationLimit,
                        forfeitedDays, policyViolationFlag),
                new BalanceProjection(currentLeaveBalance, remainingBalanceAfterApproval,
                        deductsFromAccruedBalance, balanceBucket),
                new AllowanceEvaluation(allowanceEligible, allowanceReason,
                        allowanceThresholdDays, allowanceFrequencyMonths)
        );
    }

    // Convenience accessors (backward compat for code that references fields directly)
    public LeaveType leaveType() { return summary.leaveType(); }
    public String policyName() { return summary.policyName(); }
    public String calculationMode() { return summary.calculationMode(); }
    public LocalDate startDate() { return summary.startDate(); }
    public int chargeableDays() { return summary.chargeableDays(); }
    public LocalDate leaveEndDate() { return summary.leaveEndDate(); }
    public LocalDate resumeDutiesDate() { return summary.resumeDutiesDate(); }
    public Integer currentLeaveBalance() { return balanceProjection.currentLeaveBalance(); }
    public Integer remainingBalanceAfterApproval() { return balanceProjection.remainingBalanceAfterApproval(); }
    public Integer forfeitedDays() { return policyEvaluation.forfeitedDays(); }
    public String policyViolationFlag() { return policyEvaluation.policyViolationFlag(); }
    public boolean allowanceEligible() { return allowanceEvaluation.eligible(); }
    public String allowanceReason() { return allowanceEvaluation.reason(); }
    public Integer allowanceThresholdDays() { return allowanceEvaluation.thresholdDays(); }
    public Integer allowanceFrequencyMonths() { return allowanceEvaluation.frequencyMonths(); }

    // ── Sub-records ──────────────────────────────────────────────────

    public record CalculationSummary(
            LeaveType leaveType,
            String policyName,
            String calculationMode,
            LocalDate startDate,
            int chargeableDays,
            boolean weekendsExcluded,
            boolean publicHolidaysExcluded,
            int weekendDaysSkipped,
            int publicHolidaysSkipped,
            LocalDate leaveEndDate,
            LocalDate resumeDutiesDate
    ) {}

    public record PolicyEvaluation(
            Integer continuousLeaveLimit,
            Integer accumulationLimit,
            Integer forfeitedDays,
            String policyViolationFlag
    ) {}

    public record BalanceProjection(
            Integer currentLeaveBalance,
            Integer remainingBalanceAfterApproval,
            boolean deductsFromAccruedBalance,
            String balanceBucket
    ) {}

    public record AllowanceEvaluation(
            boolean eligible,
            String reason,
            Integer thresholdDays,
            Integer frequencyMonths
    ) {
        public static AllowanceEvaluation none() {
            return new AllowanceEvaluation(false, null, null, null);
        }
    }
}
