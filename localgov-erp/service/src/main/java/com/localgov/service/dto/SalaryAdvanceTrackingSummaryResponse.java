package com.localgov.service.dto;

import com.localgov.domain.model.SalaryAdvanceEligibilityStatus;
import com.localgov.domain.model.SalaryAdvanceRequestStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record SalaryAdvanceTrackingSummaryResponse(
        Long requestId,
        String requestNumber,
        SalaryAdvanceRequestStatus status,
        SalaryAdvanceEligibilityStatus eligibilityStatus,
        String currentStage,
        String progressLabel,
        BigDecimal requestedAmount,
        BigDecimal disbursedAmount,
        Long appliedInstallmentsCount,
        Long pendingInstallmentsCount,
        LocalDateTime submittedAt,
        LocalDateTime lastUpdatedAt
) {
}