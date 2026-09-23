package com.localgov.service.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record OvertimeSessionResponse(
        Long id,
        Long employeeId,
        Long teamId,
        LocalDate sessionDate,
        LocalDateTime overtimeStart,
        LocalDateTime overtimeEnd,
        BigDecimal overtimeHours,
        String overtimeType,
        BigDecimal rateMultiplier,
        BigDecimal hourlyRate,
        BigDecimal amountDue,
        Boolean paid,
        LocalDateTime paidAt,
        String payrollReference,
        LocalDate payrollProcessedIn,
        String source,
        String status,
        Long supervisorId,
        String workDescription,
        String rejectionReason,
        LocalDateTime approvedAt,
        LocalDateTime createdAt
) {
}
