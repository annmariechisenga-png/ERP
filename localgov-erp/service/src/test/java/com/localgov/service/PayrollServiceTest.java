package com.localgov.service;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.PayrollRecord;
import com.localgov.repository.PayrollRecordRepository;
import com.localgov.repository.SalaryAdvanceDeductionRepository;
import com.localgov.service.dto.PayrollCalculationRequest;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.mapper.PayrollMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PayrollServiceTest {

    @Mock
    private PayrollRecordRepository payrollRecordRepository;

    @Mock
    private EmployeeService employeeService;

    @Mock
    private SalaryAdvanceDeductionRepository salaryAdvanceDeductionRepository;

    @Mock
    private PayrollMapper payrollMapper;

    @InjectMocks
    private PayrollService payrollService;

    @Test
    void calculatePayrollComputesNetPayAndReturnsResponse() {
        Employee employee = new Employee();
        employee.setId(1L);
        employee.setEmployeeCode("EMP-1001");
        employee.setBaseSalary(new BigDecimal("2500.00"));

        when(employeeService.getEmployeeEntity(1L)).thenReturn(employee);
        when(payrollRecordRepository.existsByEmployeeIdAndPayPeriod(1L, LocalDate.of(2026, 3, 1))).thenReturn(false);
        when(salaryAdvanceDeductionRepository.findByEmployee_IdAndStatusAndScheduledPayPeriodLessThanEqualOrderByScheduledPayPeriodAsc(
            any(), any(), any()
        )).thenReturn(List.of());
        when(payrollRecordRepository.save(any(PayrollRecord.class))).thenAnswer(invocation -> {
            PayrollRecord record = invocation.getArgument(0);
            record.setId(10L);
            record.setGeneratedAt(LocalDateTime.now());
            return record;
        });
        when(payrollMapper.toResponse(any(PayrollRecord.class))).thenAnswer(invocation -> {
            PayrollRecord record = invocation.getArgument(0);
            return new com.localgov.service.dto.PayrollRecordResponse(
                record.getId(),
                record.getEmployee().getId(),
                record.getEmployee().getEmployeeCode(),
                record.getPayPeriod(),
                record.getBaseSalary(),
                record.getOvertimeHours(),
                record.getOvertimeRate(),
                record.getDeductions(),
                record.getNetPay(),
                record.getGeneratedAt()
            );
        });

        PayrollCalculationRequest request = new PayrollCalculationRequest(
                1L,
                LocalDate.of(2026, 3, 1),
                new BigDecimal("4.00"),
                new BigDecimal("20.00"),
                new BigDecimal("20.00")
        );

        var response = payrollService.calculatePayroll(request);

        assertThat(response.id()).isEqualTo(10L);
        assertThat(response.employeeId()).isEqualTo(1L);
        assertThat(response.netPay()).isEqualByComparingTo("2560.00");
    }

        @Test
        void calculatePayrollThrowsWhenPayrollAlreadyExistsForPeriod() {
        Employee employee = new Employee();
        employee.setId(1L);
        employee.setEmployeeCode("EMP-1001");
        employee.setBaseSalary(new BigDecimal("2500.00"));

        when(employeeService.getEmployeeEntity(1L)).thenReturn(employee);
        when(payrollRecordRepository.existsByEmployeeIdAndPayPeriod(1L, LocalDate.of(2026, 4, 1))).thenReturn(true);

        PayrollCalculationRequest request = new PayrollCalculationRequest(
            1L,
            LocalDate.of(2026, 4, 18),
            new BigDecimal("1.00"),
            new BigDecimal("20.00"),
            new BigDecimal("10.00")
        );

        assertThatThrownBy(() -> payrollService.calculatePayroll(request))
            .isInstanceOf(BusinessValidationException.class)
            .hasMessageContaining("Payroll already exists");
        }

        @Test
        void calculatePayrollThrowsWhenDeductionsExceedGrossPay() {
        Employee employee = new Employee();
        employee.setId(1L);
        employee.setEmployeeCode("EMP-1001");
        employee.setBaseSalary(new BigDecimal("2500.00"));

        when(employeeService.getEmployeeEntity(1L)).thenReturn(employee);
        when(payrollRecordRepository.existsByEmployeeIdAndPayPeriod(1L, LocalDate.of(2026, 5, 1))).thenReturn(false);
        when(salaryAdvanceDeductionRepository.findByEmployee_IdAndStatusAndScheduledPayPeriodLessThanEqualOrderByScheduledPayPeriodAsc(
            any(), any(), any()
        )).thenReturn(List.of());

        PayrollCalculationRequest request = new PayrollCalculationRequest(
            1L,
            LocalDate.of(2026, 5, 1),
            new BigDecimal("0.00"),
            new BigDecimal("0.00"),
            new BigDecimal("5000.00")
        );

        assertThatThrownBy(() -> payrollService.calculatePayroll(request))
            .isInstanceOf(BusinessValidationException.class)
            .hasMessageContaining("Total deductions cannot exceed gross pay");
        }
}