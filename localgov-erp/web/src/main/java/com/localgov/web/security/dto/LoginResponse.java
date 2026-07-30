package com.localgov.web.security.dto;

import com.localgov.web.dashboard.DashboardIdentityResponse;

import java.util.List;

public record LoginResponse(
        String token,
        String tokenType,
        long expiresInMillis,
        String username,
        List<String> roles,
        DashboardIdentityResponse dashboardIdentity,
        boolean mfaRequired,
        String message
) {
}
