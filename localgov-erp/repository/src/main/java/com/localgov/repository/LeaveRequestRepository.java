package com.localgov.repository;

import com.localgov.domain.model.LeaveRequest;
import com.localgov.domain.model.LeaveStatus;
import com.localgov.domain.model.LeaveType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {
    List<LeaveRequest> findByEmployeeIdOrderByCreatedAtDesc(Long employeeId);

    List<LeaveRequest> findByStatusOrderByCreatedAtAsc(LeaveStatus status);

    Page<LeaveRequest> findByStatusOrderByCreatedAtAsc(LeaveStatus status, Pageable pageable);

    boolean existsByEmployeeIdAndLeaveTypeAndStatusInAndStartDateBetween(
            Long employeeId,
            LeaveType leaveType,
            Collection<LeaveStatus> statuses,
            LocalDate startDate,
            LocalDate endDate
    );
}
