package com.localgov.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.time.LocalDate;

/**
 * Audit log for all leave calculation events.
 * Required for government ERP compliance and dispute resolution.
 */
@Entity
@Table(name = "leave_calculation_audit_log")
public class LeaveCalculationAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "employee_id", nullable = false)
    private Long employeeId;

    @Column(name = "leave_request_id")
    private Long leaveRequestId;

    @Column(name = "leave_type", nullable = false)
    private String leaveType;

    @Column(name = "division")
    private String division;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "requested_days", nullable = false)
    private int requestedDays;

    @Column(name = "adjusted_days")
    private Integer adjustedDays;

    @Column(name = "forfeited_days")
    private Integer forfeitedDays;

    @Column(name = "reason")
    private String reason;

    @Column(name = "balance_before")
    private Integer balanceBefore;

    @Column(name = "balance_after")
    private Integer balanceAfter;

    @Column(name = "calculation_mode")
    private String calculationMode;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "triggered_by")
    private String triggeredBy;

    @Column(name = "username")
    private String username;

    @Column(name = "authority_code")
    private String authorityCode;

    @Column(name = "authority_type")
    private String authorityType;

    @Column(name = "role")
    private String role;

    protected LeaveCalculationAuditLog() {}

    private LeaveCalculationAuditLog(Builder b) {
        this.employeeId = b.employeeId;
        this.leaveRequestId = b.leaveRequestId;
        this.leaveType = b.leaveType;
        this.division = b.division;
        this.startDate = b.startDate;
        this.requestedDays = b.requestedDays;
        this.adjustedDays = b.adjustedDays;
        this.forfeitedDays = b.forfeitedDays;
        this.reason = b.reason;
        this.balanceBefore = b.balanceBefore;
        this.balanceAfter = b.balanceAfter;
        this.calculationMode = b.calculationMode;
        this.createdAt = Instant.now();
        this.triggeredBy = b.triggeredBy;
        this.username = b.username;
        this.authorityCode = b.authorityCode;
        this.authorityType = b.authorityType;
        this.role = b.role;
    }

    public Long getId() { return id; }
    public Long getEmployeeId() { return employeeId; }
    public Long getLeaveRequestId() { return leaveRequestId; }
    public String getLeaveType() { return leaveType; }
    public String getDivision() { return division; }
    public LocalDate getStartDate() { return startDate; }
    public int getRequestedDays() { return requestedDays; }
    public Integer getAdjustedDays() { return adjustedDays; }
    public Integer getForfeitedDays() { return forfeitedDays; }
    public String getReason() { return reason; }
    public Integer getBalanceBefore() { return balanceBefore; }
    public Integer getBalanceAfter() { return balanceAfter; }
    public String getCalculationMode() { return calculationMode; }
    public Instant getCreatedAt() { return createdAt; }
    public String getTriggeredBy() { return triggeredBy; }
    public String getUsername() { return username; }
    public String getAuthorityCode() { return authorityCode; }
    public String getAuthorityType() { return authorityType; }
    public String getRole() { return role; }

    public void setLeaveRequestId(Long leaveRequestId) { this.leaveRequestId = leaveRequestId; }

    public static Builder builder() { return new Builder(); }

    public static class Builder {
        private Long employeeId;
        private Long leaveRequestId;
        private String leaveType;
        private String division;
        private LocalDate startDate;
        private int requestedDays;
        private Integer adjustedDays;
        private Integer forfeitedDays;
        private String reason;
        private Integer balanceBefore;
        private Integer balanceAfter;
        private String calculationMode;
        private String triggeredBy;
        private String username;
        private String authorityCode;
        private String authorityType;
        private String role;

        public Builder employeeId(Long v) { this.employeeId = v; return this; }
        public Builder leaveRequestId(Long v) { this.leaveRequestId = v; return this; }
        public Builder leaveType(String v) { this.leaveType = v; return this; }
        public Builder division(String v) { this.division = v; return this; }
        public Builder startDate(LocalDate v) { this.startDate = v; return this; }
        public Builder requestedDays(int v) { this.requestedDays = v; return this; }
        public Builder adjustedDays(Integer v) { this.adjustedDays = v; return this; }
        public Builder forfeitedDays(Integer v) { this.forfeitedDays = v; return this; }
        public Builder reason(String v) { this.reason = v; return this; }
        public Builder balanceBefore(Integer v) { this.balanceBefore = v; return this; }
        public Builder balanceAfter(Integer v) { this.balanceAfter = v; return this; }
        public Builder calculationMode(String v) { this.calculationMode = v; return this; }
        public Builder triggeredBy(String v) { this.triggeredBy = v; return this; }
        public Builder username(String v) { this.username = v; return this; }
        public Builder authorityCode(String v) { this.authorityCode = v; return this; }
        public Builder authorityType(String v) { this.authorityType = v; return this; }
        public Builder role(String v) { this.role = v; return this; }

        public LeaveCalculationAuditLog build() { return new LeaveCalculationAuditLog(this); }
    }
}
