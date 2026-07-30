package com.localgov.service.dto;

import com.localgov.domain.model.EmployeeRole;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.LocalDate;

public record EmployeeUpsertRequest(
        @NotBlank @Size(max = 50) String employeeCode,
        @NotBlank @Size(max = 100) String firstName,
        @NotBlank @Size(max = 100) String lastName,
        @NotBlank @Email @Size(max = 150) String email,
        @NotBlank @Size(max = 120) String department,
        @NotBlank @Size(max = 120) String positionTitle,
        @NotNull @DecimalMin(value = "0.0", inclusive = false) BigDecimal baseSalary,
        @NotNull @PastOrPresent LocalDate hireDate,
        @Pattern(regexp = "(?i)male|female|other", message = "gender must be male, female, or other") String gender,
        @Size(max = 120) String division,
        @NotNull EmployeeRole role
) {
}
