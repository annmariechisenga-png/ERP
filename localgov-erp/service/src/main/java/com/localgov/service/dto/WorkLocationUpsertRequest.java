package com.localgov.service.dto;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;

public record WorkLocationUpsertRequest(
        String locationCode,
        String locationName,
        String locationType,
        String authorityCode,
        Long performedBy,
        String departmentName,
        BigDecimal latitude,
        BigDecimal longitude,
        Integer geofenceRadiusMeters,
        String address,
        LocalTime opensAt,
        LocalTime closesAt,
        Boolean active,
        Boolean primary,
        List<String> applicableDivisions,
        List<String> applicableRoleCategories
) {
}
