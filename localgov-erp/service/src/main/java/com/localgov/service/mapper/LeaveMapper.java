package com.localgov.service.mapper;

import com.localgov.domain.model.LeaveRequest;
import com.localgov.service.dto.LeaveRequestResponse;
import org.springframework.stereotype.Component;

@Component
public class LeaveMapper {

    public LeaveRequestResponse toResponse(LeaveRequest leaveRequest) {
        return toResponse(leaveRequest, 0, false, "NONE", null);
        }

        public LeaveRequestResponse toResponse(
            LeaveRequest leaveRequest,
            int leaveDaysDeducted,
            boolean deductedFromAccruedBalance,
            String balanceType,
            Integer remainingBalance
        ) {
        return new LeaveRequestResponse(
                leaveRequest.getId(),
                leaveRequest.getEmployee().getId(),
                leaveRequest.getEmployee().getEmployeeCode(),
                leaveRequest.getLeaveType(),
            leaveRequest.getCompassionateRelation(),
                leaveRequest.getStatus(),
                leaveRequest.getStartDate(),
                leaveRequest.getEndDate(),
                leaveRequest.getDaysRequested(),
            leaveDaysDeducted,
            deductedFromAccruedBalance,
            balanceType,
            remainingBalance,
                leaveRequest.getReason(),
                leaveRequest.getSupportingDocumentName(),
                leaveRequest.getSupportingDocumentData() != null && leaveRequest.getSupportingDocumentData().length > 0,
                leaveRequest.getApprovedBy(),
                leaveRequest.getApprovedAt(),
                leaveRequest.getCreatedAt()
        );
    }
}