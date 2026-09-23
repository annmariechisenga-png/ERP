package com.localgov.service.dto;

import com.localgov.domain.model.SalaryAdvanceDisburserTitle;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record SalaryAdvanceDisbursementRequest(
        @NotNull SalaryAdvanceDisburserTitle disbursedByTitle,
        @NotBlank @Size(max = 120) String disbursedBy,
        @NotBlank @Size(max = 80) String disbursementReference
) {
}