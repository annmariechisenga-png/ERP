package com.localgov.service.dto;

import java.time.LocalDateTime;

public record WorkLocationAuditResponse(
        Long id,
        Long locationId,
        String action,
        String fieldChanged,
        String oldValue,
        String newValue,
        Long performedBy,
        String performedByEmployeeCode,
        String performedByName,
        LocalDateTime performedAt
) {
}
