package com.localgov.repository;

import com.localgov.domain.model.SalaryAdvanceRequestStatus;
import com.localgov.domain.model.SalaryAdvanceRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface SalaryAdvanceRequestRepository extends JpaRepository<SalaryAdvanceRequest, Long> {
    List<SalaryAdvanceRequest> findByEmployeeIdOrderByCreatedAtDesc(Long employeeId);

    Page<SalaryAdvanceRequest> findByEmployeeId(Long employeeId, Pageable pageable);

        @Query("""
            SELECT r FROM SalaryAdvanceRequest r
            WHERE (:status IS NULL OR r.status = :status)
            ORDER BY r.createdAt DESC
            """)
        Page<SalaryAdvanceRequest> findAllWithStatus(
            @Param("status") SalaryAdvanceRequestStatus status,
            Pageable pageable);

    boolean existsByEmployeeIdAndStatusIn(Long employeeId, List<SalaryAdvanceRequestStatus> statuses);
}