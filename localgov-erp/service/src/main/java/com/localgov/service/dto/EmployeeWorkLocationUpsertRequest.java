package com.localgov.service.dto;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record EmployeeWorkLocationUpsertRequest(
        @NotNull String employeeId,
        @NotNull Long locationId,
        String authorityCode,
        Boolean primary,
        String assignmentType,
        @NotNull LocalDate effectiveFrom,
        LocalDate effectiveTo,
        Long createdBy
) {
}
