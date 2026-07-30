package com.localgov.web.reporting.dto;

import java.time.LocalDateTime;

public record ReportJobResponse(
        String jobId,
        String status,
        String viewName,
        Integer offset,
        Integer limit,
        LocalDateTime submittedAt,
        LocalDateTime startedAt,
        LocalDateTime completedAt,
        String error,
        ViewReportResponse result
) {
}
