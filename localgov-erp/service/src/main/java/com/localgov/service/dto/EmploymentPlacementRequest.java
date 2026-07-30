package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public record EmploymentPlacementRequest(
        @JsonProperty("officer_id") @NotNull @Positive Long officerId,
        @JsonProperty("authority_id") @NotBlank String authorityId,
        @JsonProperty("salary_scale") @NotBlank String salaryScale,
        @JsonProperty("notch_number") @NotNull @Positive Integer notchNumber,
        @JsonProperty("approved_by") @NotBlank String approvedBy,
        @JsonProperty("approval_date") @NotNull LocalDate approvalDate,
        @JsonProperty("approval_reference") String approvalReference,
        @JsonProperty("letter_url") String letterUrl,
        @JsonProperty("effective_date") @NotNull LocalDate effectiveDate,
        @JsonProperty("user_id") @NotBlank String userId
) {
}
