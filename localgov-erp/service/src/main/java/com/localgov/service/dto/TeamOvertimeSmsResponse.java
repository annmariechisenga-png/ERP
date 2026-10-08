package com.localgov.service.dto;

import java.util.List;

public record TeamOvertimeSmsResponse(
        String teamId,
        String teamCode,
        int memberCount,
        int sessionsCreated,
        String hodId,
        String message,
        List<String> sessionIds
) {
}
