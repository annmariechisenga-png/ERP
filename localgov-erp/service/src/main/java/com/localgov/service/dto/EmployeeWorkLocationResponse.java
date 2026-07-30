package com.localgov.service.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record EmployeeWorkLocationResponse(
        Long id,
        Long employeeId,
        String employeeCode,
        String employeeName,
        Long locationId,
        String locationCode,
        String locationName,
        String authorityCode,
        Boolean primary,
        String assignmentType,
        LocalDate effectiveFrom,
        LocalDate effectiveTo,
        Long createdBy,
        LocalDateTime createdAt
) {
}
