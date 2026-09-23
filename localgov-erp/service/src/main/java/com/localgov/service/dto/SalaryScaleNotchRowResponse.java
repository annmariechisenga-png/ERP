package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.time.LocalDate;

public record SalaryScaleNotchRowResponse(
        @JsonProperty("notch_number") Integer notchNumber,
        @JsonProperty("monthly_amount") BigDecimal monthlyAmount,
        @JsonProperty("annual_amount") BigDecimal annualAmount,
        @JsonProperty("effective_from") LocalDate effectiveFrom
) {
}
