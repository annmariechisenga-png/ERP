package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Min;

public record BatchIncrementRequest(

        @JsonProperty("authority_id")
        String authorityId,

        @JsonProperty("year")
        @Min(2000)
        Integer year
) {}
