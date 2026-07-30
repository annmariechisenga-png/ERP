package com.localgov.service.dto;

import java.util.List;

public record SalaryAdvanceTrackingSummaryPageResponse(
        Integer page,
        Integer size,
        Long totalElements,
        Integer totalPages,
        Boolean hasNext,
        Boolean hasPrevious,
        List<SalaryAdvanceTrackingSummaryResponse> content
) {
}