package com.localgov.service;

import com.localgov.domain.model.Employee;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.LeaveBalanceRepository;
import com.localgov.service.dto.EmployeeUpsertRequest;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.mapper.EmployeeMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EmployeeServiceTest {

    @Mock
    private EmployeeRepository employeeRepository;

    @Mock
    private LeaveBalanceRepository leaveBalanceRepository;

    @Mock
    private EmployeeMapper employeeMapper;

    @InjectMocks
    private EmployeeService employeeService;

    private EmployeeUpsertRequest request;

    @BeforeEach
    void setUp() {
        request = new EmployeeUpsertRequest(
                "EMP-2001",
                "Jane",
                null,
                "Doe",
                "jane.doe@localgov.test",
                "Finance",
                "Accountant",
                LocalDate.now().minusDays(1),
                "female",
                null,
                "LA001"
        );
    }

    @Test
    void createEmployeeThrowsWhenCodeAlreadyExists() {
        when(employeeRepository.existsByEmployeeId("EMP-2001")).thenReturn(true);

        assertThatThrownBy(() -> employeeService.createEmployee(request))
                .isInstanceOf(BusinessValidationException.class)
                .hasMessageContaining("Employee code already exists");
    }

    @Test
    void createEmployeeSavesAndReturnsCreatedEmployee() {
        when(employeeRepository.existsByEmployeeId("EMP-2001")).thenReturn(false);
        when(employeeRepository.existsByEmail("jane.doe@localgov.test")).thenReturn(false);
        when(employeeMapper.toResponse(any(Employee.class))).thenAnswer(invocation -> {
            Employee employee = invocation.getArgument(0);
            return new com.localgov.service.dto.EmployeeResponse(
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
        });
        when(employeeRepository.save(any(Employee.class))).thenAnswer(invocation -> {
            Employee employee = invocation.getArgument(0);
            employee.setEmployeeId("EMP-2001");
            employee.setEmail(request.email());
            employee.setCreatedAt(LocalDateTime.now());
            return employee;
        });

        var response = employeeService.createEmployee(request);

        assertThat(response.employeeId()).isEqualTo("EMP-2001");
        assertThat(response.email()).isEqualTo("jane.doe@localgov.test");
    }

    @Test
    void updateEmployeeThrowsWhenCodeUsedByAnotherEmployee() {
        Employee existing = new Employee();
        existing.setEmployeeId("EMP-1000");

        Employee other = new Employee();
        other.setEmployeeId("EMP-2001");

        when(employeeRepository.findById("EMP-1000")).thenReturn(Optional.of(existing));
        when(employeeRepository.findByEmployeeId("EMP-2001")).thenReturn(Optional.of(other));

        assertThatThrownBy(() -> employeeService.updateEmployee("EMP-1000", request))
                .isInstanceOf(BusinessValidationException.class)
                .hasMessageContaining("Employee code already exists");
    }
}