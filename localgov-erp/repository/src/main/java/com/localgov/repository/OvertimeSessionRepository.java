package com.localgov.repository;

import com.localgov.domain.model.OvertimeSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

public interface OvertimeSessionRepository extends JpaRepository<OvertimeSession, Long> {

    List<OvertimeSession> findByEmployeeIdOrderBySessionDateDesc(Long employeeId);

    Page<OvertimeSession> findByEmployeeIdOrderBySessionDateDesc(Long employeeId, Pageable pageable);

    List<OvertimeSession> findBySupervisorIdAndStatusOrderBySessionDateDesc(Long supervisorId, String status);

    boolean existsByEmployeeIdAndSessionDate(Long employeeId, LocalDate sessionDate);

    @Query("""
            SELECT s FROM OvertimeSession s
            WHERE s.employeeId = :employeeId
              AND s.sessionDate = :sessionDate
              AND s.status NOT IN ('rejected','cancelled')
            """)
    List<OvertimeSession> findActiveByEmployeeIdAndSessionDate(
            @Param("employeeId") Long employeeId,
            @Param("sessionDate") LocalDate sessionDate);

    @Query("""
            SELECT s FROM OvertimeSession s
            WHERE s.supervisorId = :supervisorId
              AND (:status IS NULL OR s.status = :status)
            ORDER BY s.sessionDate DESC
            """)
    Page<OvertimeSession> findBySupervisorWithFilter(
            @Param("supervisorId") Long supervisorId,
            @Param("status") String status,
            Pageable pageable);

    @Query("""
            SELECT s FROM OvertimeSession s
            WHERE (:status IS NULL OR s.status = :status)
            ORDER BY s.sessionDate DESC, s.id DESC
            """)
    Page<OvertimeSession> findAllWithStatus(
            @Param("status") String status,
            Pageable pageable);

    List<OvertimeSession> findByStatusInAndPaidFalseAndSessionDateBetweenOrderBySessionDateAscIdAsc(
            List<String> statuses,
            LocalDate startDate,
            LocalDate endDate);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("""
            UPDATE OvertimeSession s
            SET s.status = 'paid',
                s.paid = true,
                s.paidAt = :paidAt,
                s.payrollReference = :payrollReference,
                s.payrollProcessedIn = :payrollProcessedIn
            WHERE s.id IN :sessionIds
              AND s.paid = false
              AND s.status IN ('approved', 'approved_level3')
            """)
    int markSessionsPaid(
            @Param("sessionIds") List<Long> sessionIds,
            @Param("paidAt") LocalDateTime paidAt,
            @Param("payrollReference") String payrollReference,
            @Param("payrollProcessedIn") LocalDate payrollProcessedIn);
}
