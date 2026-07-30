package com.localgov.service.dto;

import java.time.LocalDate;
import java.util.List;

public record OvertimeMarkPaidRequest(
        List<Long> sessionIds,
        String payrollReference,
        LocalDate payrollDate
) {
}
