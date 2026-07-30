package com.localgov.repository;

import com.localgov.domain.model.WorkLocationAudit;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface WorkLocationAuditRepository extends JpaRepository<WorkLocationAudit, Long> {
    List<WorkLocationAudit> findByLocationIdOrderByPerformedAtDesc(Long locationId);

    Page<WorkLocationAudit> findByLocationIdOrderByPerformedAtDesc(Long locationId, Pageable pageable);

        @Query("""
                        SELECT a
                        FROM WorkLocationAudit a
                        WHERE a.locationId = :locationId
                            AND (:action IS NULL OR UPPER(a.action) = UPPER(:action))
                            AND (:fromAt IS NULL OR a.performedAt >= :fromAt)
                            AND (:toAt IS NULL OR a.performedAt <= :toAt)
                        ORDER BY a.performedAt DESC
                        """)
        Page<WorkLocationAudit> findHistoryByLocationIdWithFilters(
                        @Param("locationId") Long locationId,
                        @Param("action") String action,
                        @Param("fromAt") LocalDateTime fromAt,
                        @Param("toAt") LocalDateTime toAt,
                        Pageable pageable
        );

    @Query("SELECT DISTINCT UPPER(a.action) FROM WorkLocationAudit a WHERE a.locationId = :locationId ORDER BY UPPER(a.action) ASC")
    List<String> findDistinctActionsByLocationId(@Param("locationId") Long locationId);

    @Query("SELECT MIN(a.performedAt) FROM WorkLocationAudit a WHERE a.locationId = :locationId")
    Optional<LocalDateTime> findEarliestPerformedAtByLocationId(@Param("locationId") Long locationId);

    @Query("SELECT MAX(a.performedAt) FROM WorkLocationAudit a WHERE a.locationId = :locationId")
    Optional<LocalDateTime> findLatestPerformedAtByLocationId(@Param("locationId") Long locationId);
}
