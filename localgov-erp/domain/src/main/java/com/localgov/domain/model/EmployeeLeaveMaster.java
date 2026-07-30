package com.localgov.domain.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "employee_leave_master")
public class EmployeeLeaveMaster {

    @Id
    @Column(name = "employee_id", nullable = false)
    private Long employeeId;

    @Column(name = "opening_balance", precision = 10, scale = 2)
    private BigDecimal openingBalance;

    @Column(name = "total_taken_thirty_year", precision = 10, scale = 2)
    private BigDecimal totalTakenThirtyYear;

    @Column(name = "is_active")
    private Boolean isActive;

    // Default constructor
    public EmployeeLeaveMaster() {
    }

    // Parameterized constructor
    public EmployeeLeaveMaster(Long employeeId, BigDecimal openingBalance, 
                               BigDecimal totalTakenThirtyYear, Boolean isActive) {
        this.employeeId = employeeId;
        this.openingBalance = openingBalance;
        this.totalTakenThirtyYear = totalTakenThirtyYear;
        this.isActive = isActive;
    }

    // Getters and Setters
    public Long getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(Long employeeId) {
        this.employeeId = employeeId;
    }

    public BigDecimal getOpeningBalance() {
        return openingBalance;
    }

    public void setOpeningBalance(BigDecimal openingBalance) {
        this.openingBalance = openingBalance;
    }

    public BigDecimal getTotalTakenThirtyYear() {
        return totalTakenThirtyYear;
    }

    public void setTotalTakenThirtyYear(BigDecimal totalTakenThirtyYear) {
        this.totalTakenThirtyYear = totalTakenThirtyYear;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    // Optional: toString() method for debugging
    @Override
    public String toString() {
        return "EmployeeLeaveMaster{" +
                "employeeId=" + employeeId +
                ", openingBalance=" + openingBalance +
                ", totalTakenThirtyYear=" + totalTakenThirtyYear +
                ", isActive=" + isActive +
                '}';
    }
}