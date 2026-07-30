package com.localgov.service;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.LeaveBalance;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.LeaveBalanceRepository;
import com.localgov.service.dto.EmployeeResponse;
import com.localgov.service.dto.EmployeeUpsertRequest;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.exception.ResourceNotFoundException;
import com.localgov.service.mapper.EmployeeMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class EmployeeService {

    private static final int DEFAULT_LOCAL_LEAVE_BALANCE = 30;
    private static final int DEFAULT_VACATION_LEAVE_BALANCE = 30;

    private final EmployeeRepository employeeRepository;
    private final LeaveBalanceRepository leaveBalanceRepository;
    private final EmployeeMapper employeeMapper;

    public EmployeeService(EmployeeRepository employeeRepository, LeaveBalanceRepository leaveBalanceRepository, EmployeeMapper employeeMapper) {
        this.employeeRepository = employeeRepository;
        this.leaveBalanceRepository = leaveBalanceRepository;
        this.employeeMapper = employeeMapper;
    }

    public List<EmployeeResponse> getAllEmployees() {
        return employeeRepository.findAll().stream().map(employeeMapper::toResponse).toList();
    }

    public EmployeeResponse getEmployeeById(Long id) {
        return employeeMapper.toResponse(getEmployeeEntity(id));
    }

    @Transactional
    public EmployeeResponse createEmployee(EmployeeUpsertRequest request) {
        if (employeeRepository.existsByEmployeeCode(request.employeeCode())) {
            throw new BusinessValidationException("Employee code already exists: " + request.employeeCode());
        }
        if (employeeRepository.existsByEmail(request.email())) {
            throw new BusinessValidationException("Employee email already exists: " + request.email());
        }

        Employee employee = new Employee();
        employeeMapper.applyUpsertRequest(employee, request);
        Employee savedEmployee = employeeRepository.save(employee);
        ensureDefaultLeaveBalance(savedEmployee.getId());
        return employeeMapper.toResponse(savedEmployee);
    }

    @Transactional
    public EmployeeResponse updateEmployee(Long id, EmployeeUpsertRequest request) {
        Employee employee = getEmployeeEntity(id);

        employeeRepository.findByEmployeeCode(request.employeeCode())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new BusinessValidationException("Employee code already exists: " + request.employeeCode());
                });

        if (employeeRepository.existsByEmailIgnoreCaseAndIdNot(request.email(), id)) {
            throw new BusinessValidationException("Employee email already exists: " + request.email());
        }

        employeeMapper.applyUpsertRequest(employee, request);
        return employeeMapper.toResponse(employeeRepository.save(employee));
    }

    @Transactional
    public void deleteEmployee(Long id) {
        if (!employeeRepository.existsById(id)) {
            throw new ResourceNotFoundException("Employee not found with id: " + id);
        }
        employeeRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public Employee getEmployeeEntity(Long id) {
        return employeeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + id));
    }

    private void ensureDefaultLeaveBalance(Long employeeId) {
        if (leaveBalanceRepository.existsById(employeeId)) {
            return;
        }

        LeaveBalance leaveBalance = new LeaveBalance();
        leaveBalance.setEmployeeId(employeeId);
        leaveBalance.setLocalLeaveBalance(DEFAULT_LOCAL_LEAVE_BALANCE);
        leaveBalance.setVacationLeaveBalance(DEFAULT_VACATION_LEAVE_BALANCE);
        leaveBalanceRepository.save(leaveBalance);
    }
}
