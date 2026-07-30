package com.localgov.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class AnnualIncrementService {

    private final JdbcTemplate jdbcTemplate;

    public AnnualIncrementService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public String processAnnualIncrement(Long officerId, UUID appraisalId, LocalDate effectiveDate) {
        LocalDate resolvedDate = effectiveDate == null ? LocalDate.now() : effectiveDate;
        return jdbcTemplate.queryForObject(
                "SELECT process_annual_increment(?, ?, ?)::TEXT",
                String.class,
                officerId,
                appraisalId,
                resolvedDate
        );
    }

    public List<Map<String, Object>> processBatchIncrements(String authorityId, Integer year) {
        Integer resolvedYear = year == null ? LocalDate.now().getYear() : year;
        return jdbcTemplate.queryForList(
                "SELECT * FROM process_batch_increments(?, ?)",
                authorityId,
                resolvedYear
        );
    }
}
