package com.localgov.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "leave_balances")
public class LeaveBalance {

    @Id
    @Column(name = "employee_id", nullable = false)
    private Long employeeId;

    @Column(name = "local_leave_balance")
    private Integer localLeaveBalance;

    @Column(name = "vacation_leave_balance")
    private Integer vacationLeaveBalance;

    public Long getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(Long employeeId) {
        this.employeeId = employeeId;
    }

    public Integer getLocalLeaveBalance() {
        return localLeaveBalance;
    }

    public void setLocalLeaveBalance(Integer localLeaveBalance) {
        this.localLeaveBalance = localLeaveBalance;
    }

    public Integer getVacationLeaveBalance() {
        return vacationLeaveBalance;
    }

    public void setVacationLeaveBalance(Integer vacationLeaveBalance) {
        this.vacationLeaveBalance = vacationLeaveBalance;
    }
}
