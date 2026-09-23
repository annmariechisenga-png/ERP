package com.localgov.service.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record EmployeeWorkLocationUpsertRequest(
        @NotNull Long employeeId,
        @NotNull Long locationId,
        String authorityCode,
        Boolean primary,
        String assignmentType,
        @NotNull LocalDate effectiveFrom,
        LocalDate effectiveTo,
        Long createdBy
) {
}
