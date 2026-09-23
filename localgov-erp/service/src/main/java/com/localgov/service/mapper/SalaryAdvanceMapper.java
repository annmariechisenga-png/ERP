package com.localgov.service.mapper;

import com.localgov.domain.model.SalaryAdvanceDeduction;
import com.localgov.domain.model.SalaryAdvanceRequest;
import com.localgov.domain.model.SalaryAdvanceWorkflowEvent;
import com.localgov.service.dto.SalaryAdvancePendingDeductionItemResponse;
import com.localgov.service.dto.SalaryAdvanceRequestResponse;
import com.localgov.service.dto.SalaryAdvanceTrackingEventResponse;
import com.localgov.service.dto.SalaryAdvanceTrackingSummaryResponse;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class SalaryAdvanceMapper {

    public SalaryAdvanceRequestResponse toRequestResponse(SalaryAdvanceRequest request, long scheduledDeductionCount) {
        return new SalaryAdvanceRequestResponse(
                request.getId(),
                request.getRequestNumber(),
                request.getEmployee().getId(),
                request.getEmployee().getEmployeeCode(),
            request.getAuthorityRef(),
            request.getAuthorityTypeAtRequest(),
                request.getRequestedAmount(),
                request.getRequestedInstallments(),
                request.getReason(),
                request.getEligibilityStatus(),
                request.getEligibilityNotes(),
                request.getStatus(),
                request.getDisbursedAmount(),
                request.getDisbursedAt(),
                scheduledDeductionCount,
                request.getCreatedAt(),
                request.getUpdatedAt()
        );
    }

    public SalaryAdvanceTrackingEventResponse toTrackingEventResponse(SalaryAdvanceWorkflowEvent event) {
        return new SalaryAdvanceTrackingEventResponse(
                event.getEventStage(),
                event.getEventAction(),
                event.getActorRole(),
                event.getActorName(),
                event.getEventNotes(),
                event.getCreatedAt()
        );
    }

    public SalaryAdvanceTrackingSummaryResponse toTrackingSummaryResponse(
            SalaryAdvanceRequest request,
            String currentStage,
            String progressLabel,
            long appliedInstallments,
            long pendingInstallments,
            LocalDateTime lastUpdatedAt
    ) {
        return new SalaryAdvanceTrackingSummaryResponse(
                request.getId(),
                request.getRequestNumber(),
                request.getStatus(),
                request.getEligibilityStatus(),
                currentStage,
                progressLabel,
                request.getRequestedAmount(),
                request.getDisbursedAmount(),
                appliedInstallments,
                pendingInstallments,
                request.getCreatedAt(),
                lastUpdatedAt
        );
    }

    public SalaryAdvancePendingDeductionItemResponse toPendingDeductionItemResponse(SalaryAdvanceDeduction deduction) {
        return new SalaryAdvancePendingDeductionItemResponse(
                deduction.getId(),
                deduction.getSalaryAdvanceRequest().getId(),
                deduction.getSalaryAdvanceRequest().getRequestNumber(),
                deduction.getEmployee().getId(),
                deduction.getEmployee().getEmployeeCode(),
                deduction.getInstallmentNo(),
                deduction.getTotalInstallments(),
                deduction.getScheduledPayPeriod(),
                deduction.getDeductionAmount()
        );
    }
}