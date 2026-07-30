package com.localgov.service.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record SalaryAdvanceRequestCreateRequest(
        @NotNull @Positive Long employeeId,
        @NotBlank @Size(max = 30) String authorityRef,
        @NotNull @DecimalMin(value = "0.01") BigDecimal requestedAmount,
        @NotNull @Positive Integer requestedInstallments,
        @NotBlank @Size(max = 500) String reason,
        @NotBlank @Size(max = 120) String applicantName
) {
}