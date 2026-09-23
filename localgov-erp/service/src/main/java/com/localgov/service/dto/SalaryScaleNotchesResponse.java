package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record SalaryScaleNotchesResponse(
        @JsonProperty("salary_scale") String salaryScale,
        List<SalaryScaleNotchRowResponse> notches,
        @JsonProperty("min_notch") Integer minNotch,
        @JsonProperty("max_notch") Integer maxNotch
) {
}
