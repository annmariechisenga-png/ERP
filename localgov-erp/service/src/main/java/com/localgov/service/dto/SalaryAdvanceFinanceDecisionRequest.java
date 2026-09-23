package com.localgov.service.dto;

import com.localgov.domain.model.SalaryAdvanceDecision;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SalaryAdvanceFinanceDecisionRequest(
        @NotBlank @Size(max = 120) String financeOfficerName,
        @NotNull SalaryAdvanceDecision decision,
        @Size(max = 500) String notes
) {
}