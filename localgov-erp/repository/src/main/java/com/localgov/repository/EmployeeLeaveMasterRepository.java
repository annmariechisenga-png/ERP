package com.localgov.repository;

import com.localgov.domain.model.EmployeeLeaveMaster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeLeaveMasterRepository extends JpaRepository<EmployeeLeaveMaster, Long> {

    // Find by employee ID
    Optional<EmployeeLeaveMaster> findByEmployeeId(Long employeeId);

    // Find all active records
    List<EmployeeLeaveMaster> findByIsActiveTrue();

    // Your original SQL query
    @Query(value = "SELECT employee_id, opening_balance, total_taken_thirty_year, is_active " +
                   "FROM employee_leave_master WHERE employee_id = :empId", 
           nativeQuery = true)
    Optional<EmployeeLeaveMaster> getLeaveMasterByEmployeeId(@Param("empId") Long employeeId);

    // Get all active employees with their leave data
    @Query(value = "SELECT employee_id, opening_balance, total_taken_thirty_year, is_active " +
                   "FROM employee_leave_master WHERE is_active = true", 
           nativeQuery = true)
    List<EmployeeLeaveMaster> findAllActiveLeaveMasters();
}