package com.localgov.repository;

import com.localgov.domain.model.LeaveRequest;
import com.localgov.domain.model.LeaveStatus;
import com.localgov.domain.model.LeaveType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

public interface LeaveRequestRepository extends JpaRepository<LeaveRequest, Long> {
    @Query("SELECT lr FROM LeaveRequest lr WHERE lr.employee.employeeId = :employeeId ORDER BY lr.createdAt DESC")
    List<LeaveRequest> findByEmployeeIdOrderByCreatedAtDesc(@Param("employeeId") String employeeId);

    List<LeaveRequest> findByStatusOrderByCreatedAtAsc(LeaveStatus status);

    Page<LeaveRequest> findByStatusOrderByCreatedAtAsc(LeaveStatus status, Pageable pageable);

    @Query("SELECT CASE WHEN COUNT(lr) > 0 THEN TRUE ELSE FALSE END FROM LeaveRequest lr WHERE lr.employee.employeeId = :employeeId AND lr.leaveType = :leaveType AND lr.status IN :statuses AND lr.startDate BETWEEN :startDate AND :endDate")
    boolean existsByEmployeeIdAndLeaveTypeAndStatusInAndStartDateBetween(
            @Param("employeeId") String employeeId,
            @Param("leaveType") LeaveType leaveType,
            @Param("statuses") Collection<LeaveStatus> statuses,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
