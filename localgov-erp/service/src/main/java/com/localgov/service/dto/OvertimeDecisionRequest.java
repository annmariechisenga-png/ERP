package com.localgov.service.dto;

public record OvertimeDecisionRequest(
        String decidedBy,
        String reason
) {
}
