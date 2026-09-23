package com.localgov.service.dto;

import java.math.BigDecimal;

public record OvertimePayrollExportRow(
        String employeeNumber,
        String name,
        String department,
        String bankAccount,
        BigDecimal totalHours,
        BigDecimal totalAmount,
        String details
) {
}
