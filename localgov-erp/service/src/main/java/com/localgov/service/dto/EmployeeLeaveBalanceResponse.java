package com.localgov.service.dto;

public record EmployeeLeaveBalanceResponse(
        String employeeId,
        Integer localLeaveBalance,
        Integer vacationLeaveBalance
) {
}
