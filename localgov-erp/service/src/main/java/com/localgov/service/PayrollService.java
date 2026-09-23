package com.localgov.service;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.PayrollRecord;
import com.localgov.domain.model.SalaryAdvanceDeduction;
import com.localgov.domain.model.SalaryAdvanceDeductionStatus;
import com.localgov.repository.PayrollRecordRepository;
import com.localgov.repository.SalaryAdvanceDeductionRepository;
import com.localgov.service.dto.PayrollCalculationRequest;
import com.localgov.service.dto.PayrollRecordResponse;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.mapper.PayrollMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class PayrollService {

    private static final int MONEY_SCALE = 2;
    private static final RoundingMode MONEY_ROUNDING = RoundingMode.HALF_UP;

    private final PayrollRecordRepository payrollRecordRepository;
    private final SalaryAdvanceDeductionRepository salaryAdvanceDeductionRepository;
    private final EmployeeService employeeService;
    private final PayrollMapper payrollMapper;

    public PayrollService(
            PayrollRecordRepository payrollRecordRepository,
            SalaryAdvanceDeductionRepository salaryAdvanceDeductionRepository,
            EmployeeService employeeService,
            PayrollMapper payrollMapper
    ) {
        this.payrollRecordRepository = payrollRecordRepository;
        this.salaryAdvanceDeductionRepository = salaryAdvanceDeductionRepository;
        this.employeeService = employeeService;
        this.payrollMapper = payrollMapper;
    }

    @Transactional
    public PayrollRecordResponse calculatePayroll(PayrollCalculationRequest request) {
        Employee employee = employeeService.getEmployeeEntity(request.employeeId());
        var normalizedPayPeriod = request.payPeriod().withDayOfMonth(1);

        if (payrollRecordRepository.existsByEmployeeIdAndPayPeriod(request.employeeId(), normalizedPayPeriod)) {
            throw new BusinessValidationException("Payroll already exists for employee and pay period");
        }

        List<SalaryAdvanceDeduction> dueSalaryAdvanceDeductions = salaryAdvanceDeductionRepository
            .findByEmployee_IdAndStatusAndScheduledPayPeriodLessThanEqualOrderByScheduledPayPeriodAsc(
                        request.employeeId(),
                        SalaryAdvanceDeductionStatus.PENDING,
                        normalizedPayPeriod
                );

        BigDecimal autoSalaryAdvanceDeductions = dueSalaryAdvanceDeductions.stream()
                .map(SalaryAdvanceDeduction::getDeductionAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal baseSalary = normalizeMoney(employee.getBaseSalary());
        BigDecimal overtimePay = request.overtimeHours().multiply(request.overtimeRate());
        BigDecimal gross = baseSalary.add(normalizeMoney(overtimePay));
        BigDecimal totalDeductions = normalizeMoney(request.deductions().add(autoSalaryAdvanceDeductions));

        if (totalDeductions.compareTo(gross) > 0) {
            throw new BusinessValidationException("Total deductions cannot exceed gross pay");
        }

        BigDecimal netPay = normalizeMoney(gross.subtract(totalDeductions));

        PayrollRecord record = new PayrollRecord();
        record.setEmployee(employee);
        record.setPayPeriod(normalizedPayPeriod);
        record.setBaseSalary(baseSalary);
        record.setOvertimeHours(request.overtimeHours());
        record.setOvertimeRate(normalizeMoney(request.overtimeRate()));
        record.setDeductions(totalDeductions);
        record.setNetPay(netPay);

        PayrollRecord savedRecord = payrollRecordRepository.save(record);

        for (SalaryAdvanceDeduction deduction : dueSalaryAdvanceDeductions) {
            deduction.setStatus(SalaryAdvanceDeductionStatus.APPLIED);
            deduction.setAppliedAt(LocalDateTime.now());
            deduction.setPayrollRecord(savedRecord);
        }
        salaryAdvanceDeductionRepository.saveAll(dueSalaryAdvanceDeductions);

        return payrollMapper.toResponse(savedRecord);
    }

    public List<PayrollRecordResponse> getEmployeePayrollHistory(Long employeeId) {
        employeeService.getEmployeeEntity(employeeId);
        return payrollRecordRepository.findByEmployeeIdOrderByPayPeriodDesc(employeeId)
                .stream()
            .map(payrollMapper::toResponse)
                .toList();
    }

    private BigDecimal normalizeMoney(BigDecimal value) {
        return value.setScale(MONEY_SCALE, MONEY_ROUNDING);
    }
}
