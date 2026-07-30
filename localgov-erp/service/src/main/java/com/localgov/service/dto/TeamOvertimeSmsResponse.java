package com.localgov.service.dto;

import java.util.List;

public record TeamOvertimeSmsResponse(
        Long teamId,
        String teamCode,
        int memberCount,
        int sessionsCreated,
        Long hodId,
        String message,
        List<Long> sessionIds
) {
}
