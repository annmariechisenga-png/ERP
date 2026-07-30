package com.localgov.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "employment_history")
public class EmploymentHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "officer_id", nullable = false)
    private Long officerId;

    @Column(name = "authority_id", nullable = false, length = 40)
    private String authorityId;

    @Column(name = "salary_scale", nullable = false, length = 30)
    private String salaryScale;

    @Column(name = "notch_number", nullable = false)
    private Integer notchNumber;

    @Column(name = "monthly_salary", nullable = false, precision = 18, scale = 2)
    private BigDecimal monthlySalary;

    @Column(name = "approved_by", nullable = false, length = 120)
    private String approvedBy;

    @Column(name = "approval_date", nullable = false)
    private LocalDate approvalDate;

    @Column(name = "approval_reference", length = 100)
    private String approvalReference;

    @Column(name = "appointment_letter_url", length = 500)
    private String appointmentLetterUrl;

    @Column(name = "effective_date", nullable = false)
    private LocalDate effectiveDate;

    @Column(name = "is_current", nullable = false)
    private Boolean isCurrent;

    @Column(name = "created_by", nullable = false, length = 120)
    private String createdBy;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getOfficerId() {
        return officerId;
    }

    public void setOfficerId(Long officerId) {
        this.officerId = officerId;
    }

    public String getAuthorityId() {
        return authorityId;
    }

    public void setAuthorityId(String authorityId) {
        this.authorityId = authorityId;
    }

    public String getSalaryScale() {
        return salaryScale;
    }

    public void setSalaryScale(String salaryScale) {
        this.salaryScale = salaryScale;
    }

    public Integer getNotchNumber() {
        return notchNumber;
    }

    public void setNotchNumber(Integer notchNumber) {
        this.notchNumber = notchNumber;
    }

    public BigDecimal getMonthlySalary() {
        return monthlySalary;
    }

    public void setMonthlySalary(BigDecimal monthlySalary) {
        this.monthlySalary = monthlySalary;
    }

    public String getApprovedBy() {
        return approvedBy;
    }

    public void setApprovedBy(String approvedBy) {
        this.approvedBy = approvedBy;
    }

    public LocalDate getApprovalDate() {
        return approvalDate;
    }

    public void setApprovalDate(LocalDate approvalDate) {
        this.approvalDate = approvalDate;
    }

    public String getApprovalReference() {
        return approvalReference;
    }

    public void setApprovalReference(String approvalReference) {
        this.approvalReference = approvalReference;
    }

    public String getAppointmentLetterUrl() {
        return appointmentLetterUrl;
    }

    public void setAppointmentLetterUrl(String appointmentLetterUrl) {
        this.appointmentLetterUrl = appointmentLetterUrl;
    }

    public LocalDate getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(LocalDate effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public Boolean getCurrent() {
        return isCurrent;
    }

    public void setCurrent(Boolean current) {
        isCurrent = current;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
