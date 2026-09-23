package com.localgov.service.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record PayrollRecordResponse(
        Long id,
        Long employeeId,
        String employeeCode,
        LocalDate payPeriod,
        BigDecimal baseSalary,
        BigDecimal overtimeHours,
        BigDecimal overtimeRate,
        BigDecimal deductions,
        BigDecimal netPay,
        LocalDateTime generatedAt
) {
}
