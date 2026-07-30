package com.localgov.service;

import com.localgov.service.dto.SuspiciousChangeResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

/**
 * Provides access to salary_change_audit data and the
 * detect_suspicious_salary_changes() PostgreSQL function (V17 migration).
 */
@Service
@Transactional(readOnly = true)
public class SalaryAuditService {

    private final JdbcTemplate jdbcTemplate;

    public SalaryAuditService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * Calls detect_suspicious_salary_changes(p_days) and maps results to DTOs.
     *
     * @param days look-back window in days (default 30)
     * @return officers with suspicious salary-change patterns, highest risk first
     */
    public List<SuspiciousChangeResponse> getSuspiciousChanges(int days) {
        return jdbcTemplate.query(
                "SELECT * FROM detect_suspicious_salary_changes(?)",
                (rs, rowNum) -> new SuspiciousChangeResponse(
                        rs.getString("officer_name"),
                        rs.getString("authority_name"),
                        rs.getLong("changes_count"),
                        rs.getBigDecimal("total_increase"),
                        rs.getBigDecimal("avg_risk_score"),
                        rs.getLong("flagged_count"),
                        rs.getString("risk_level")
                ),
                days
        );
    }

    /**
     * Returns the full salary_change_audit history for one officer, most-recent first.
     * Useful for a per-officer drill-down view.
     *
     * @param officerId erp_employee.id
     * @param limit     max rows to return (cap at 200)
     */
    public List<java.util.Map<String, Object>> getOfficerAuditHistory(Long officerId, int limit) {
        int safeLimit = Math.min(Math.max(limit, 1), 200);
        return jdbcTemplate.queryForList(
                """
                SELECT audit_id, changed_by, changed_at,
                       old_scale, old_notch, old_salary,
                       new_scale, new_notch, new_salary,
                       change_reason, approval_reference,
                       risk_score, flagged, flag_reason
                  FROM salary_change_audit
                 WHERE officer_id = ?
                 ORDER BY changed_at DESC
                 LIMIT ?
                """,
                officerId, safeLimit
        );
    }
}
