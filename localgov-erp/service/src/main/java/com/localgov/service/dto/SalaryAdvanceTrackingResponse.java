package com.localgov.service.dto;

import com.localgov.domain.model.SalaryAdvanceEligibilityStatus;
import com.localgov.domain.model.SalaryAdvanceRequestStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record SalaryAdvanceTrackingResponse(
        Long requestId,
        String requestNumber,
        Long employeeId,
        String employeeCode,
        SalaryAdvanceRequestStatus status,
        SalaryAdvanceEligibilityStatus eligibilityStatus,
        String currentStage,
        String progressLabel,
        BigDecimal requestedAmount,
        BigDecimal disbursedAmount,
        Integer requestedInstallments,
        Long appliedInstallmentsCount,
        Long pendingInstallmentsCount,
        LocalDateTime submittedAt,
        LocalDateTime lastUpdatedAt,
        List<SalaryAdvanceTrackingEventResponse> timeline
) {
}