package com.localgov.service.security;

/**
 * Immutable record representing the fully-resolved identity of the currently
 * authenticated user, derived exclusively from Spring Security context and
 * ERP domain data.
 */
public record AuthenticatedUserContext(
        String username,
        Long employeeId,
        String authorityCode,
        String authorityType,
        String role,
        String division
) {
}
