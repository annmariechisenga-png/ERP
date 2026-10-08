package com.localgov.service.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PastOrPresent;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

/**
 * Request DTO for creating or updating an Employee.
 *
 * <p>Fields match the {@code employees} table schema. Derived or computed
 * fields (division, role, base salary) are NOT part of this request; they
 * are either computed on read or defined elsewhere.
 *
 * <p>PII fields (NRC, phone, TIN, NAPSA, NHIMA, LASF, bank account) are
 * not included here. They are managed separately by the PiiEncryptionService
 * through a dedicated admin flow (see V114).
 */
public record EmployeeUpsertRequest(
        @NotBlank @Size(max = 50) String employeeId,
        @NotBlank @Size(max = 100) String firstName,
        @Size(max = 100) String middleName,
        @NotBlank @Size(max = 100) String lastName,
        @NotBlank @Email @Size(max = 150) String email,
        @Size(max = 200) String department,
        @Size(max = 200) String position,
        @PastOrPresent LocalDate dateOfFirstAppointment,
        @Pattern(regexp = "(?i)male|female|other",
                 message = "sex must be male, female, or other")
        String sex,
        @Size(max = 20) String salaryScale,
        @NotBlank @Size(max = 50) String authorityCode
) {
}
