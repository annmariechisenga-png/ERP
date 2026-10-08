package com.localgov.service.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Response DTO for Employee. Includes derived fields like {@code division}
 * (computed from salaryScale).
 *
 * <p>This DTO intentionally does NOT expose raw PII. When PII display is
 * required (e.g., admin screens), add masked versions of the sensitive
 * fields — nrcMasked, phoneMasked, tpinMasked, etc. — rather than the
 * plaintext values.
 */
public record EmployeeResponse(
        String employeeId,
        String firstName,
        String middleName,
        String lastName,
        String email,
        String department,
        String position,
        LocalDate dateOfFirstAppointment,
        String sex,
        String salaryScale,
        String authorityCode,
        String division,          // derived from salaryScale
        LocalDateTime createdAt
) {
}
