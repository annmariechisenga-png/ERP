package com.localgov.service.mapper;

import com.localgov.domain.model.PayrollRecord;
import com.localgov.service.dto.PayrollRecordResponse;
import org.springframework.stereotype.Component;

@Component
public class PayrollMapper {

    public PayrollRecordResponse toResponse(PayrollRecord record) {
        return new PayrollRecordResponse(
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
    }
}