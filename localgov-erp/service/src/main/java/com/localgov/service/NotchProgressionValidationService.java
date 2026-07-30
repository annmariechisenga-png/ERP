package com.localgov.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

/**
 * Calls the validate_notch_progression() PostgreSQL function (V16 migration)
 * and returns its JSONB result as a raw JSON string.
 *
 * Using JdbcTemplate (available transitively through the repository module's
 * spring-boot-starter-data-jpa dependency) to avoid coupling business rules
 * to a JPA entity or stored-procedure mapping.
 */
@Service
public class NotchProgressionValidationService {

    private final JdbcTemplate jdbcTemplate;

    public NotchProgressionValidationService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Returns the raw JSONB payload produced by validate_notch_progression().
     * The caller (controller) forwards it directly as an application/json response,
     * so no intermediate DTO deserialization is needed here.
     *
     * @param officerId     BIGINT PK of erp_employee
     * @param newScale      target salary scale code (e.g. "LGSS08")
     * @param newNotch      target notch number
     * @param effectiveDate proposed effective date for the new placement
     * @return JSON string, e.g. {"valid":true} or {"valid":false,"reason":"...","severity":"HIGH"}
     */
    public String validateProgression(
            Long officerId,
            String newScale,
            Integer newNotch,
            LocalDate effectiveDate
    ) {
        return jdbcTemplate.queryForObject(
                "SELECT validate_notch_progression(?, ?, ?, ?)::TEXT",
                String.class,
                officerId,
                newScale,
                newNotch,
                effectiveDate
        );
    }
}
