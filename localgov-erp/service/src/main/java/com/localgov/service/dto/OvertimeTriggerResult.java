package com.localgov.service.dto;

/**
 * Returned by {@code OvertimeService#checkOvertimeTrigger}.
 * When {@code sessionCreated} is true the {@code session} field is populated.
 * When false, {@code skipReason} explains why no session was created.
 */
public record OvertimeTriggerResult(
        Long employeeId,
        boolean sessionCreated,
        String skipReason,
        OvertimeSessionResponse session
) {
    public static OvertimeTriggerResult created(OvertimeSessionResponse session) {
        return new OvertimeTriggerResult(session.employeeId(), true, null, session);
    }

    public static OvertimeTriggerResult skipped(Long employeeId, String reason) {
        return new OvertimeTriggerResult(employeeId, false, reason, null);
    }
}
