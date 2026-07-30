package com.localgov.service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;

/**
 * One row returned by detect_suspicious_salary_changes().
 */
public record SuspiciousChangeResponse(

        @JsonProperty("officer_name")
        String officerName,

        @JsonProperty("authority_name")
        String authorityName,

        @JsonProperty("changes_count")
        long changesCount,

        @JsonProperty("total_increase")
        BigDecimal totalIncrease,

        @JsonProperty("avg_risk_score")
        BigDecimal avgRiskScore,

        @JsonProperty("flagged_count")
        long flaggedCount,

        @JsonProperty("risk_level")
        String riskLevel
) {}
