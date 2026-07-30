package com.localgov.repository;

import com.localgov.domain.model.SalaryScaleOfficial;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SalaryScaleOfficialRepository extends JpaRepository<SalaryScaleOfficial, Long> {

    @Query("""
            SELECT s
            FROM SalaryScaleOfficial s
            WHERE s.isActive = true
              AND s.effectiveFrom = (
                  SELECT MAX(s2.effectiveFrom)
                  FROM SalaryScaleOfficial s2
                  WHERE s2.salaryScale = s.salaryScale
                    AND s2.isActive = true
                    AND s2.effectiveFrom <= CURRENT_DATE
              )
            ORDER BY s.salaryScale
            """)
    List<SalaryScaleOfficial> findCurrentActiveScales();

    @Query("""
            SELECT s
            FROM SalaryScaleOfficial s
            WHERE s.salaryScale = :salaryScale
              AND s.isActive = true
              AND s.effectiveFrom = (
                  SELECT MAX(s2.effectiveFrom)
                  FROM SalaryScaleOfficial s2
                  WHERE s2.salaryScale = :salaryScale
                    AND s2.isActive = true
                    AND s2.effectiveFrom <= CURRENT_DATE
              )
            """)
    Optional<SalaryScaleOfficial> findCurrentBySalaryScale(String salaryScale);

    @Query("""
            SELECT s.division
            FROM SalaryScaleOfficial s
            WHERE UPPER(s.salaryScale) = UPPER(:salaryScale)
              AND s.isActive = true
              AND s.effectiveFrom = (
                  SELECT MAX(s2.effectiveFrom)
                  FROM SalaryScaleOfficial s2
                  WHERE UPPER(s2.salaryScale) = UPPER(:salaryScale)
                    AND s2.isActive = true
                    AND s2.effectiveFrom <= CURRENT_DATE
              )
            """)
    Optional<String> findDivisionBySalaryScale(@Param("salaryScale") String salaryScale);
}
