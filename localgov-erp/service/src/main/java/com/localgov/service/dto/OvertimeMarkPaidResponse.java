package com.localgov.service.dto;

import java.time.LocalDate;
import java.util.List;

public record OvertimeMarkPaidResponse(
        int requestedCount,
        int updatedCount,
        int notificationsSent,
        int notificationsSkipped,
        String payrollReference,
        LocalDate payrollDate,
        List<Long> updatedSessionIds,
        String message
) {
}
