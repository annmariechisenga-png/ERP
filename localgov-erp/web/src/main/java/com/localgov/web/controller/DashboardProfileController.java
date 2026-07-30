package com.localgov.web.controller;

import com.localgov.web.dashboard.DashboardProfileResponse;
import com.localgov.web.dashboard.DashboardProfileService;
import com.localgov.web.dashboard.DashboardProfilesResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/dashboard")
@Tag(name = "Dashboard Profiles", description = "Position-specific ERP dashboard profiles")
public class DashboardProfileController {

    private final DashboardProfileService dashboardProfileService;

    public DashboardProfileController(DashboardProfileService dashboardProfileService) {
        this.dashboardProfileService = dashboardProfileService;
    }

    @GetMapping("/profiles")
    @Operation(summary = "List available dashboard profiles and authority types")
    public DashboardProfilesResponse getProfiles() {
        return dashboardProfileService.getProfiles();
    }

    @GetMapping("/profile")
    @Operation(summary = "Get a position-specific dashboard profile")
    public DashboardProfileResponse getProfile(
            @RequestParam String positionId,
            @RequestParam String authorityType
    ) {
        return dashboardProfileService.getProfile(positionId, authorityType);
    }
}