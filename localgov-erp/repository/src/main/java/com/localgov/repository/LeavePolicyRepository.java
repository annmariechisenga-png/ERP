package com.localgov.repository;

import com.localgov.domain.model.LeavePolicy;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LeavePolicyRepository extends JpaRepository<LeavePolicy, Long> {

    Optional<LeavePolicy> findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase(
            String leaveType, String division);

    Optional<LeavePolicy> findFirstByLeaveTypeIgnoreCaseAndDivisionIsNull(
            String leaveType);

    List<LeavePolicy> findByLeaveTypeIgnoreCaseOrderByDivisionAsc(String leaveType);
}
