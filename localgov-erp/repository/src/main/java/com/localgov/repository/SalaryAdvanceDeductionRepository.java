package com.localgov.repository;

import com.localgov.domain.model.SalaryAdvanceDeduction;
import com.localgov.domain.model.SalaryAdvanceDeductionStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface SalaryAdvanceDeductionRepository extends JpaRepository<SalaryAdvanceDeduction, Long> {
    boolean existsByEmployee_IdAndStatus(Long employeeId, SalaryAdvanceDeductionStatus status);

    List<SalaryAdvanceDeduction> findByEmployee_IdAndStatusAndScheduledPayPeriodLessThanEqualOrderByScheduledPayPeriodAsc(
            Long employeeId,
            SalaryAdvanceDeductionStatus status,
            LocalDate scheduledPayPeriod
    );

        List<SalaryAdvanceDeduction> findByStatusAndScheduledPayPeriodLessThanEqual(
            SalaryAdvanceDeductionStatus status,
            LocalDate scheduledPayPeriod
        );

            List<SalaryAdvanceDeduction> findByStatusAndScheduledPayPeriodLessThanEqualAndEmployee_Id(
                SalaryAdvanceDeductionStatus status,
                LocalDate scheduledPayPeriod,
                Long employeeId
            );

                List<SalaryAdvanceDeduction> findByScheduledPayPeriodLessThanEqualAndEmployee_Id(
                    LocalDate scheduledPayPeriod,
                    Long employeeId
                );

                List<SalaryAdvanceDeduction> findByScheduledPayPeriodLessThanEqual(LocalDate scheduledPayPeriod);

    long countBySalaryAdvanceRequest_Id(Long salaryAdvanceRequestId);

                long countBySalaryAdvanceRequest_IdAndStatus(Long salaryAdvanceRequestId, SalaryAdvanceDeductionStatus status);
}