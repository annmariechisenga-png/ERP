package com.localgov.service.dto;

import com.localgov.domain.model.EmployeeRole;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record EmployeeResponse(
        Long id,
        String employeeCode,
        String firstName,
        String lastName,
        String email,
        String department,
        String positionTitle,
        BigDecimal baseSalary,
        LocalDate hireDate,
        EmployeeRole role,
        String gender,
        LocalDateTime createdAt
) {
}
