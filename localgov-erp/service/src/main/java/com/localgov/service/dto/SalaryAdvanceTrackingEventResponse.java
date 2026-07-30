package com.localgov.service.dto;

import java.time.LocalDateTime;

public record SalaryAdvanceTrackingEventResponse(
        String stage,
        String action,
        String actorRole,
        String actorName,
        String notes,
        LocalDateTime at
) {
}