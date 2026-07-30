package com.localgov.repository;

import com.localgov.domain.model.CommutedOvertime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface CommutedOvertimeRepository extends JpaRepository<CommutedOvertime, Long> {

    List<CommutedOvertime> findByEmployeeIdOrderByEffectiveFromDesc(Long employeeId);

    /**
     * Returns any active commuted overtime record that covers the given date.
                 * Active means is_active = true and the date falls within
                 * [effectiveFrom, effectiveTo] (effectiveTo NULL means open-ended).
     */
    @Query("""
            SELECT c FROM CommutedOvertime c
            WHERE c.employeeId = :employeeId
                                                        AND c.active = true
              AND c.effectiveFrom <= :onDate
              AND (c.effectiveTo IS NULL OR c.effectiveTo >= :onDate)
            """)
    List<CommutedOvertime> findActiveOnDate(
            @Param("employeeId") Long employeeId,
            @Param("onDate") LocalDate onDate);
}
