package com.localgov.service.dto;

public record AuthorityDistrictResponse(
        String authorityCode,
        String authorityId,
        String authorityRef,
        String provinceCode,
        String provinceName,
        String districtName,
        String authorityType
) {
}
