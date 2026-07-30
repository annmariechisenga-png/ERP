package com.localgov.service.mapper;

import com.localgov.domain.model.Employee;
import com.localgov.service.dto.EmployeeResponse;
import com.localgov.service.dto.EmployeeUpsertRequest;
import org.springframework.stereotype.Component;

import java.util.Locale;

@Component
public class EmployeeMapper {

    public void applyUpsertRequest(Employee employee, EmployeeUpsertRequest request) {
        employee.setEmployeeCode(request.employeeCode());
        employee.setFirstName(request.firstName());
        employee.setLastName(request.lastName());
        employee.setEmail(request.email());
        employee.setDepartment(request.department());
        employee.setPositionTitle(request.positionTitle());
        employee.setBaseSalary(request.baseSalary());
        employee.setHireDate(request.hireDate());
        employee.setGender(normalizeGender(request.gender()));
        employee.setDivision(request.division());
        employee.setRole(request.role());
    }

    private String normalizeGender(String value) {
        if (value == null || value.isBlank()) {
            return "other";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }

    public EmployeeResponse toResponse(Employee employee) {
        return new EmployeeResponse(
                employee.getId(),
                employee.getEmployeeCode(),
                employee.getFirstName(),
                employee.getLastName(),
                employee.getEmail(),
                employee.getDepartment(),
                employee.getPositionTitle(),
                employee.getBaseSalary(),
                employee.getHireDate(),
                employee.getRole(),
                employee.getGender(),
                employee.getCreatedAt()
        );
    }
}