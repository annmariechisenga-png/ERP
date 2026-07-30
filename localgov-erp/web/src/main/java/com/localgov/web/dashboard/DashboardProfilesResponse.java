package com.localgov.web.dashboard;

import java.util.List;

public record DashboardProfilesResponse(
        List<String> authorityTypes,
        List<DashboardProfileResponse> profiles
) {
}