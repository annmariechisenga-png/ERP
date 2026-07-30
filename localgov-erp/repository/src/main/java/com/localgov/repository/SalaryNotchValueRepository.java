package com.localgov.repository;

import com.localgov.domain.model.SalaryNotchValue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface SalaryNotchValueRepository extends JpaRepository<SalaryNotchValue, Long> {

    @Query("""
            SELECT n
            FROM SalaryNotchValue n
            WHERE n.salaryScale = :salaryScale
              AND n.effectiveFrom = (
                  SELECT MAX(n2.effectiveFrom)
                  FROM SalaryNotchValue n2
                  WHERE n2.salaryScale = :salaryScale
                    AND n2.notchNo = n.notchNo
                    AND n2.effectiveFrom <= CURRENT_DATE
              )
            ORDER BY n.notchNo
            """)
    List<SalaryNotchValue> findCurrentNotchRowsByScale(String salaryScale);

    @Query("""
            SELECT n
            FROM SalaryNotchValue n
            WHERE n.salaryScale = :salaryScale
              AND n.notchNo = :notchNo
              AND n.effectiveFrom = (
                  SELECT MAX(n2.effectiveFrom)
                  FROM SalaryNotchValue n2
                  WHERE n2.salaryScale = :salaryScale
                    AND n2.notchNo = :notchNo
                    AND n2.effectiveFrom <= CURRENT_DATE
              )
            """)
    Optional<SalaryNotchValue> findCurrentByScaleAndNotch(String salaryScale, Integer notchNo);
}
