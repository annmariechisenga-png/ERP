package com.localgov.service.dto;

import com.localgov.domain.model.CompassionateLeaveRelation;
import com.localgov.domain.model.LeaveType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public record LeaveCalculationRequest(
        @NotNull @Positive Long employeeId,
        @NotNull LeaveType leaveType,
        @NotNull LocalDate startDate,
        @Min(1) Integer requestedDays,
        CompassionateLeaveRelation compassionateRelation
) {
}
