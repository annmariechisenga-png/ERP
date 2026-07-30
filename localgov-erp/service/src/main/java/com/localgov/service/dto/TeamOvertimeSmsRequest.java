package com.localgov.service.dto;

import java.math.BigDecimal;

public record TeamOvertimeSmsRequest(
        Long supervisorId,
        String teamCode,
        BigDecimal overtimeHours,
        String reason
) {
}
