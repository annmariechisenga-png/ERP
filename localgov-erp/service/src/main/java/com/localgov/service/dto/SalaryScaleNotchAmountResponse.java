package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;

public record SalaryScaleNotchAmountResponse(
        @JsonProperty("salary_scale") String salaryScale,
        @JsonProperty("notch_number") Integer notchNumber,
        @JsonProperty("monthly_amount") BigDecimal monthlyAmount
) {
}
