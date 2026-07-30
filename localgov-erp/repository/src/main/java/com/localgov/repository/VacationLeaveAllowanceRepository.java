package com.localgov.repository;

import com.localgov.domain.model.AllowanceStatus;
import com.localgov.domain.model.VacationLeaveAllowance;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Repository for {@link VacationLeaveAllowance} lifecycle records.
 */
public interface VacationLeaveAllowanceRepository extends JpaRepository<VacationLeaveAllowance, Long> {

    /**
     * Finds the most recent paid allowance record for an employee within a given window.
     * <p>
     * Used by the 24-month rule: only {@code PAID} records may block future allowance eligibility.
     */
    Optional<VacationLeaveAllowance> findFirstByEmployeeIdAndStatusAndCreatedAtAfterOrderByCreatedAtDesc(
            Long employeeId, AllowanceStatus status, LocalDateTime since);
}
