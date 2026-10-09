package com.localgov.web.dashboard;

public record DashboardIdentityResponse(
        String employeeId,
        String employeeCode,
        String employeeName,
        String email,
        String department,
        String positionId,
        String positionTitle,
        String authorityCode,
        String authorityType,
        String gender,
        String source
) {
}
