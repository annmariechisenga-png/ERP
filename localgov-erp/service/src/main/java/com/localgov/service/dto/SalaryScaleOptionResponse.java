package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public record SalaryScaleOptionResponse(
        @JsonProperty("salary_scale") String salaryScale,
        String division,
        @JsonProperty("min_notch") Integer minNotch,
        @JsonProperty("max_notch") Integer maxNotch,
        @JsonProperty("populated_notches") Long populatedNotches
) {
}
