package com.localgov.service.dto;

import java.time.LocalDateTime;
import java.util.List;

public record WorkLocationAuditFilterOptionsResponse(
        List<String> availableActions,
        LocalDateTime earliestEntryAt,
        LocalDateTime latestEntryAt
) {
}
