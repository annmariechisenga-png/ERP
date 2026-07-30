package com.localgov.service.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDate;

public record PayrollCalculationRequest(
        @NotNull @Positive Long employeeId,
        @NotNull LocalDate payPeriod,
        @NotNull @DecimalMin(value = "0.0") BigDecimal overtimeHours,
        @NotNull @DecimalMin(value = "0.0") BigDecimal overtimeRate,
        @NotNull @DecimalMin(value = "0.0") BigDecimal deductions
) {
}
