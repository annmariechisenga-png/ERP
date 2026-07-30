package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;
import java.util.UUID;

public record AnnualIncrementRequest(

        @JsonProperty("officer_id")
        @NotNull
        @Positive
        Long officerId,

        @JsonProperty("appraisal_id")
        UUID appraisalId,

        @JsonProperty("effective_date")
        LocalDate effectiveDate
) {}
