package com.localgov.repository;

import com.localgov.domain.model.EmployeeWorkLocation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface EmployeeWorkLocationRepository extends JpaRepository<EmployeeWorkLocation, Long> {
    boolean existsByEmployeeIdAndLocationIdAndEffectiveFrom(Long employeeId, Long locationId, LocalDate effectiveFrom);
    List<EmployeeWorkLocation> findByEmployeeIdOrderByEffectiveFromDesc(Long employeeId);
    List<EmployeeWorkLocation> findByLocationIdOrderByEffectiveFromDesc(Long locationId);
    List<EmployeeWorkLocation> findByEmployeeIdAndAuthorityCodeIgnoreCaseOrderByEffectiveFromDesc(Long employeeId, String authorityCode);
    List<EmployeeWorkLocation> findByAuthorityCodeIgnoreCaseOrderByEmployeeIdAscEffectiveFromDesc(String authorityCode);
}
