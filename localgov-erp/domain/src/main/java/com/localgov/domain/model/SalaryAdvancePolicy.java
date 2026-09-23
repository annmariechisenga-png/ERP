package com.localgov.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;

@Entity
@Table(name = "salary_advance_policy")
public class SalaryAdvancePolicy {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "policy_code", nullable = false)
    private String policyCode;

    @Column(name = "max_advance_percent", nullable = false, precision = 5, scale = 2)
    private BigDecimal maxAdvancePercent;

    @Column(name = "max_installments", nullable = false)
    private Integer maxInstallments;

    @Column(name = "minimum_service_months", nullable = false)
    private Integer minimumServiceMonths;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;

    @Column(name = "version_no", nullable = false)
    private Integer versionNo;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPolicyCode() {
        return policyCode;
    }

    public void setPolicyCode(String policyCode) {
        this.policyCode = policyCode;
    }

    public BigDecimal getMaxAdvancePercent() {
        return maxAdvancePercent;
    }

    public void setMaxAdvancePercent(BigDecimal maxAdvancePercent) {
        this.maxAdvancePercent = maxAdvancePercent;
    }

    public Integer getMaxInstallments() {
        return maxInstallments;
    }

    public void setMaxInstallments(Integer maxInstallments) {
        this.maxInstallments = maxInstallments;
    }

    public Integer getMinimumServiceMonths() {
        return minimumServiceMonths;
    }

    public void setMinimumServiceMonths(Integer minimumServiceMonths) {
        this.minimumServiceMonths = minimumServiceMonths;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean active) {
        isActive = active;
    }

    public Integer getVersionNo() {
        return versionNo;
    }

    public void setVersionNo(Integer versionNo) {
        this.versionNo = versionNo;
    }
}