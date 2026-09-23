package com.localgov.service.dto;

public record EmployeeLeaveBalanceResponse(
        Long employeeId,
        Integer localLeaveBalance,
        Integer vacationLeaveBalance
) {
}
