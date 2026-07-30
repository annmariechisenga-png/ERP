package com.localgov.repository;

import com.localgov.domain.model.WorkLocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface WorkLocationRepository extends JpaRepository<WorkLocation, Long> {
    List<WorkLocation> findByActiveTrueOrderByLocationTypeAscLocationNameAsc();
    List<WorkLocation> findByLocationTypeIgnoreCaseOrderByLocationNameAsc(String locationType);
    List<WorkLocation> findByLocationTypeIgnoreCaseAndActiveTrueOrderByLocationNameAsc(String locationType);
    List<WorkLocation> findByAuthorityCodeIgnoreCaseOrderByLocationTypeAscLocationNameAsc(String authorityCode);
    List<WorkLocation> findByAuthorityCodeIgnoreCaseAndActiveTrueOrderByLocationTypeAscLocationNameAsc(String authorityCode);
    List<WorkLocation> findByAuthorityCodeIgnoreCaseAndLocationTypeIgnoreCaseOrderByLocationNameAsc(String authorityCode, String locationType);
    List<WorkLocation> findByAuthorityCodeIgnoreCaseAndLocationTypeIgnoreCaseAndActiveTrueOrderByLocationNameAsc(String authorityCode, String locationType);
    boolean existsByLocationCodeIgnoreCase(String locationCode);
    Optional<WorkLocation> findByLocationCodeIgnoreCase(String locationCode);

    @Query(value = "SELECT COUNT(*) FROM erp_employee WHERE primary_location_id = :locationId", nativeQuery = true)
    long countEmployeePrimaryAssignments(@Param("locationId") Long locationId);

    @Query(value = "SELECT COUNT(*) FROM employee_work_locations WHERE location_id = :locationId", nativeQuery = true)
    long countEmployeeLocationAssignments(@Param("locationId") Long locationId);
}
