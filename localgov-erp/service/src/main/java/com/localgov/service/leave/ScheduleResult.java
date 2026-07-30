package com.localgov.service.leave;

import java.time.LocalDate;

/**
 * Result of a leave schedule computation.
 */
public record ScheduleResult(
        LocalDate startDate,
        LocalDate endDate,
        LocalDate resumptionDate,
        int chargeableDays,
        int weekendDaysSkipped,
        int publicHolidaysSkipped
) {
}
