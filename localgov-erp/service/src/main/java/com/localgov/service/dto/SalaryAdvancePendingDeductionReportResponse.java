package com.localgov.service.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record SalaryAdvancePendingDeductionReportResponse(
        LocalDate payPeriod,
        Long pendingInstallmentsCount,
        BigDecimal pendingInstallmentsTotal,
        List<SalaryAdvancePendingDeductionItemResponse> deductions
) {
}