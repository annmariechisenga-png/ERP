package com.localgov.web.reporting;

import com.localgov.service.exception.BusinessValidationException;
import com.localgov.web.reporting.dto.ViewReportResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class ReportingService {

    private static final int DEFAULT_LIMIT = 100;
    private static final int MAX_LIMIT = 5000;
    private static final Pattern SAFE_SQL_IDENTIFIER = Pattern.compile("^[A-Za-z_][A-Za-z0-9_]*$");

    private final JdbcTemplate jdbcTemplate;

    public ReportingService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<String> getAvailableViews() {
        return jdbcTemplate.queryForList(
                """
                SELECT table_name
                FROM information_schema.views
                WHERE table_schema = 'public'
                ORDER BY table_name
                """,
                String.class
        );
    }

    public ViewReportResponse readView(String viewName, Integer offset, Integer limit) {
        String normalizedViewName = normalizeViewName(viewName);
        int resolvedOffset = offset == null ? 0 : Math.max(offset, 0);
        int resolvedLimit = limit == null ? DEFAULT_LIMIT : Math.min(Math.max(limit, 1), MAX_LIMIT);

        String query = "SELECT * FROM " + normalizedViewName + " OFFSET ? LIMIT ?";
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(query, resolvedOffset, resolvedLimit);

        Long totalRows = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM " + normalizedViewName, Long.class);

        return new ViewReportResponse(
                normalizedViewName,
                resolvedOffset,
                resolvedLimit,
                rows.size(),
                totalRows == null ? 0L : totalRows,
                rows
        );
    }

    private String normalizeViewName(String viewName) {
        if (viewName == null || viewName.isBlank()) {
            throw new BusinessValidationException("View name is required");
        }

        if (!SAFE_SQL_IDENTIFIER.matcher(viewName).matches()) {
            throw new BusinessValidationException("Invalid view name format");
        }

        Set<String> availableViews = getAvailableViews().stream()
                .map(value -> value.toLowerCase(Locale.ROOT))
                .collect(Collectors.toSet());

        String normalized = viewName.toLowerCase(Locale.ROOT);
        if (!availableViews.contains(normalized)) {
            String preview = getAvailableViews().stream().sorted(Comparator.naturalOrder()).limit(20)
                    .collect(Collectors.joining(", "));
            throw new BusinessValidationException("View not found: " + viewName + ". Available sample: " + preview);
        }

        return normalized;
    }
}
