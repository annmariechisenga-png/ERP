package com.localgov.repository;

import com.localgov.domain.model.LeaveCalculationAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LeaveCalculationAuditLogRepository extends JpaRepository<LeaveCalculationAuditLog, Long> {
    List<LeaveCalculationAuditLog> findByEmployeeIdOrderByCreatedAtDesc(Long employeeId);
    List<LeaveCalculationAuditLog> findByLeaveRequestId(Long leaveRequestId);
}
