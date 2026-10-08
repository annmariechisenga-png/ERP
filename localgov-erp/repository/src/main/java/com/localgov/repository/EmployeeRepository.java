package com.localgov.repository;

import com.localgov.domain.model.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Employee (mapped to {@code employees} table).
 *
 * <p>The primary key is the council-scoped text {@code employee_id}.
 * All finder methods use the new field names from the V115 schema.
 */
public interface EmployeeRepository extends JpaRepository<Employee, String> {

    Optional<Employee> findByEmployeeId(String employeeId);

    Optional<Employee> findByEmployeeIdIgnoreCase(String employeeId);

    Optional<Employee> findByEmailIgnoreCase(String email);

    boolean existsByEmployeeId(String employeeId);

    boolean existsByEmail(String email);

    boolean existsByEmailIgnoreCaseAndEmployeeIdNot(String email, String employeeId);

    List<Employee> findByIsActiveTrue();

    List<Employee> findByAuthorityCodeAndIsActiveTrue(String authorityCode);

    List<Employee> findBySupervisorIdAndIsActiveTrue(String supervisorId);
}
