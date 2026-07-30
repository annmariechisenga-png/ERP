package com.localgov.web.reporting.dto;

import java.util.List;
import java.util.Map;

public record ViewReportResponse(
        String viewName,
        Integer offset,
        Integer limit,
        Integer returnedRows,
        Long totalRows,
        List<Map<String, Object>> rows
) {
}
