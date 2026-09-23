package com.localgov.service.dto;

public record OvertimeDecisionRequest(
        Long decidedBy,
        String reason
) {
}
