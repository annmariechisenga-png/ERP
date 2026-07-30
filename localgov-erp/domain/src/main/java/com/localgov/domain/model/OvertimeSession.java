package com.localgov.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "overtime_sessions")
public class OvertimeSession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "employee_id", nullable = false)
    private Long employeeId;

    @Column(name = "team_id")
    private Long teamId;

    @Column(name = "session_date", nullable = false)
    private LocalDate sessionDate;

    @Column(name = "overtime_start", nullable = false)
    private LocalDateTime overtimeStart;

    @Column(name = "overtime_end", nullable = false)
    private LocalDateTime overtimeEnd;

    @Column(name = "overtime_hours", nullable = false, precision = 8, scale = 2)
    private BigDecimal overtimeHours;

    /** weekday | saturday | sunday | public_holiday | night_work */
    @Column(name = "overtime_type", nullable = false, length = 20)
    private String overtimeType;

    @Column(name = "rate_multiplier", nullable = false, precision = 4, scale = 2)
    private BigDecimal rateMultiplier;

    @Column(name = "hourly_rate", nullable = false, precision = 18, scale = 2)
    private BigDecimal hourlyRate;

    @Column(name = "amount_due", nullable = false, precision = 18, scale = 2)
    private BigDecimal amountDue;

    @Column(name = "paid", nullable = false)
    private Boolean paid;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "payroll_reference", length = 80)
    private String payrollReference;

    @Column(name = "payroll_processed_in")
    private LocalDate payrollProcessedIn;

    /** auto_clock_out | manual */
    @Column(nullable = false, length = 20)
    private String source;

    /** pending_supervisor | approved | rejected | paid | cancelled */
    @Column(nullable = false, length = 25)
    private String status;

    @Column(name = "supervisor_id")
    private Long supervisorId;

    @Column(name = "work_description")
    private String workDescription;

    @Column(name = "rejection_reason")
    private String rejectionReason;

    @Column(name = "approved_at")
    private LocalDateTime approvedAt;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
        if (status == null) {
            status = "pending_supervisor";
        }
        if (source == null) {
            source = "auto_clock_out";
        }
        if (paid == null) {
            paid = false;
        }
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getEmployeeId() { return employeeId; }
    public void setEmployeeId(Long employeeId) { this.employeeId = employeeId; }

    public Long getTeamId() { return teamId; }
    public void setTeamId(Long teamId) { this.teamId = teamId; }

    public LocalDate getSessionDate() { return sessionDate; }
    public void setSessionDate(LocalDate sessionDate) { this.sessionDate = sessionDate; }

    public LocalDateTime getOvertimeStart() { return overtimeStart; }
    public void setOvertimeStart(LocalDateTime overtimeStart) { this.overtimeStart = overtimeStart; }

    public LocalDateTime getOvertimeEnd() { return overtimeEnd; }
    public void setOvertimeEnd(LocalDateTime overtimeEnd) { this.overtimeEnd = overtimeEnd; }

    public BigDecimal getOvertimeHours() { return overtimeHours; }
    public void setOvertimeHours(BigDecimal overtimeHours) { this.overtimeHours = overtimeHours; }

    public String getOvertimeType() { return overtimeType; }
    public void setOvertimeType(String overtimeType) { this.overtimeType = overtimeType; }

    public BigDecimal getRateMultiplier() { return rateMultiplier; }
    public void setRateMultiplier(BigDecimal rateMultiplier) { this.rateMultiplier = rateMultiplier; }

    public BigDecimal getHourlyRate() { return hourlyRate; }
    public void setHourlyRate(BigDecimal hourlyRate) { this.hourlyRate = hourlyRate; }

    public BigDecimal getAmountDue() { return amountDue; }
    public void setAmountDue(BigDecimal amountDue) { this.amountDue = amountDue; }

    public Boolean getPaid() { return paid; }
    public void setPaid(Boolean paid) { this.paid = paid; }

    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }

    public String getPayrollReference() { return payrollReference; }
    public void setPayrollReference(String payrollReference) { this.payrollReference = payrollReference; }

    public LocalDate getPayrollProcessedIn() { return payrollProcessedIn; }
    public void setPayrollProcessedIn(LocalDate payrollProcessedIn) { this.payrollProcessedIn = payrollProcessedIn; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getSupervisorId() { return supervisorId; }
    public void setSupervisorId(Long supervisorId) { this.supervisorId = supervisorId; }

    public String getWorkDescription() { return workDescription; }
    public void setWorkDescription(String workDescription) { this.workDescription = workDescription; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public LocalDateTime getApprovedAt() { return approvedAt; }
    public void setApprovedAt(LocalDateTime approvedAt) { this.approvedAt = approvedAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
