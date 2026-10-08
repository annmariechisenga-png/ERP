package com.localgov.service.mapper;

import com.localgov.domain.model.Employee;
import com.localgov.service.dto.EmployeeResponse;
import com.localgov.service.dto.EmployeeUpsertRequest;
import org.springframework.stereotype.Component;

import java.util.Locale;

@Component
public class EmployeeMapper {

    /**
     * Applies an upsert request to an Employee entity.
     * Field names align with the employees table schema.
     */
    public void applyUpsertRequest(Employee employee, EmployeeUpsertRequest request) {
        if (request.employeeId() != null) {
            employee.setEmployeeId(request.employeeId());
        }
        employee.setFirstName(request.firstName());
        employee.setMiddleName(request.middleName());
        employee.setLastName(request.lastName());
        employee.setEmail(request.email());
        employee.setDepartment(request.department());
        employee.setPosition(request.position());
        employee.setDateOfFirstAppointment(request.dateOfFirstAppointment());
        employee.setSex(normalizeSex(request.sex()));
        employee.setSalaryScale(request.salaryScale());
        employee.setAuthorityCode(request.authorityCode());
    }

    /**
     * Normalizes the sex field to lowercase, defaulting to "other".
     */
    private String normalizeSex(String value) {
        if (value == null || value.isBlank()) {
            return "other";
        }
        return value.trim().toLowerCase(Locale.ROOT);
    }

    /**
     * Maps an Employee entity to a response DTO.
     * Division is computed on read via Employee.getDivision().
     */
    public EmployeeResponse toResponse(Employee employee) {
        return new EmployeeResponse(
                employee.getEmployeeId(),
                employee.getFirstName(),
                employee.getMiddleName(),
                employee.getLastName(),
                employee.getEmail(),
                employee.getDepartment(),
                employee.getPosition(),
                employee.getDateOfFirstAppointment(),
                employee.getSex(),
                employee.getSalaryScale(),
                employee.getAuthorityCode(),
                employee.getDivision(),
                employee.getCreatedAt()
        );
    }
}
