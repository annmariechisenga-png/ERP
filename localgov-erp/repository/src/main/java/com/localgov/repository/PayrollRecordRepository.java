package com.localgov.repository;

import com.localgov.domain.model.PayrollRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface PayrollRecordRepository extends JpaRepository<PayrollRecord, Long> {
    @Query("SELECT pr FROM PayrollRecord pr WHERE pr.employee.employeeId = :employeeId ORDER BY pr.payPeriod DESC")
    List<PayrollRecord> findByEmployeeIdOrderByPayPeriodDesc(@Param("employeeId") String employeeId);

    @Query("SELECT CASE WHEN COUNT(pr) > 0 THEN TRUE ELSE FALSE END FROM PayrollRecord pr WHERE pr.employee.employeeId = :employeeId AND pr.payPeriod = :payPeriod")
    boolean existsByEmployeeIdAndPayPeriod(@Param("employeeId") String employeeId, @Param("payPeriod") java.time.LocalDate payPeriod);
}
