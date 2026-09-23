package com.localgov.service.dto;

import com.localgov.domain.model.SalaryAdvanceEligibilityStatus;
import com.localgov.domain.model.SalaryAdvanceRequestStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record SalaryAdvanceRequestResponse(
        Long id,
        String requestNumber,
        Long employeeId,
        String employeeCode,
        String authorityRef,
        String authorityTypeAtRequest,
        BigDecimal requestedAmount,
        Integer requestedInstallments,
        String reason,
        SalaryAdvanceEligibilityStatus eligibilityStatus,
        String eligibilityNotes,
        SalaryAdvanceRequestStatus status,
        BigDecimal disbursedAmount,
        LocalDateTime disbursedAt,
        Long scheduledDeductionCount,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}