package com.localgov.web.reporting.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record ReportJobCreateRequest(
        @NotBlank String viewName,
        @Min(0) Integer offset,
        @Min(1) @Max(5000) Integer limit
) {
}
