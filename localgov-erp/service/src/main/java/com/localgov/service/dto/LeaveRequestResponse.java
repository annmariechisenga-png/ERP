package com.localgov.service.dto;

import com.localgov.domain.model.CompassionateLeaveRelation;
import com.localgov.domain.model.LeaveStatus;
import com.localgov.domain.model.LeaveType;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record LeaveRequestResponse(
        Long id,
        Long employeeId,
        String employeeCode,
        LeaveType leaveType,
        CompassionateLeaveRelation compassionateRelation,
        LeaveStatus status,
        LocalDate startDate,
        LocalDate endDate,
        Integer daysRequested,
        Integer leaveDaysDeducted,
        Boolean deductedFromAccruedBalance,
        String balanceType,
        Integer remainingBalance,
        String reason,
        String supportingDocumentName,
        Boolean supportingDocumentAttached,
        String approvedBy,
        LocalDateTime approvedAt,
        LocalDateTime createdAt
) {
}
