package com.localgov.web.security.dto;

import com.localgov.web.dashboard.DashboardIdentityResponse;

import java.util.List;

public record CurrentUserResponse(
        String username,
        List<String> roles,
        DashboardIdentityResponse dashboardIdentity,
        boolean mfaEnabled
) {
}
