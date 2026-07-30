package com.localgov.service.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record SalaryAdvancePendingDeductionItemResponse(
        Long deductionId,
        Long salaryAdvanceRequestId,
        String requestNumber,
        Long employeeId,
        String employeeCode,
        Integer installmentNo,
        Integer totalInstallments,
        LocalDate scheduledPayPeriod,
        BigDecimal deductionAmount
) {
}