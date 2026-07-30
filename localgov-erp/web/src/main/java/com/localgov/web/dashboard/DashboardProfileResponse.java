package com.localgov.web.dashboard;

import java.util.List;

public record DashboardProfileResponse(
        String positionId,
        String positionTitle,
        String authorityType,
        String dashboardTitle,
        String dashboardSummary,
        List<String> focusAreas,
        List<String> priorityMetrics,
        List<String> tabOrder
) {
}