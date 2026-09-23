package com.localgov.service.dto;

import com.localgov.domain.model.SalaryAdvanceDecision;
import com.localgov.domain.model.SalaryAdvanceHeadApproverTitle;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SalaryAdvanceHeadDecisionRequest(
        @NotNull SalaryAdvanceHeadApproverTitle headApproverTitle,
        @NotBlank @Size(max = 120) String headApproverName,
        @NotNull SalaryAdvanceDecision decision,
        @Size(max = 500) String notes
) {
}