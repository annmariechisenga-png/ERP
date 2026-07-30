package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;

public record EmploymentPlacementResponse(
        boolean success,
        @JsonProperty("employment_id") Long employmentId,
        @JsonProperty("monthly_salary") BigDecimal monthlySalary
) {
}
