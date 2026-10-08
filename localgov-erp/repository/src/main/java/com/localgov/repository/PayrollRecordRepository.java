package com.localgov.repository;

import com.localgov.domain.model.PayrollRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PayrollRecordRepository extends JpaRepository<PayrollRecord, Long> {
    List<PayrollRecord> findByEmployeeIdOrderByPayPeriodDesc(String employeeId);

    boolean existsByEmployeeIdAndPayPeriod(String employeeId, java.time.LocalDate payPeriod);
}
