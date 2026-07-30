package com.localgov.service.leave;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.LeaveBalance;
import com.localgov.domain.model.LeavePolicy;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.LeaveBalanceRepository;
import com.localgov.repository.LeavePolicyRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * Leave accrual service that credits monthly leave balances for active employees.
 * <p>
 * Rules:
 * <ul>
 *   <li>Accrual rates come ONLY from {@code leave_policy.accrual_rate} — never hardcoded.</li>
 *   <li>Vacation leave balance is capped at {@code leave_policy.max_accumulation}.</li>
 *   <li>Employees are resolved from the existing ERP hierarchy: division determines policy.</li>
 *   <li>This service is callable by a future {@code @Scheduled} job — no scheduler here.</li>
 * </ul>
 */
@Service
public class LeaveAccrualService {

    private static final Logger log = LoggerFactory.getLogger(LeaveAccrualService.class);

    private static final String VACATION_LEAVE_TYPE = "Vacation Leave";
    private static final String LOCAL_LEAVE_TYPE = "Local Leave";

    private final EmployeeRepository employeeRepository;
    private final LeaveBalanceRepository leaveBalanceRepository;
    private final LeavePolicyRepository leavePolicyRepository;

    public LeaveAccrualService(EmployeeRepository employeeRepository,
                               LeaveBalanceRepository leaveBalanceRepository,
                               LeavePolicyRepository leavePolicyRepository) {
        this.employeeRepository = employeeRepository;
        this.leaveBalanceRepository = leaveBalanceRepository;
        this.leavePolicyRepository = leavePolicyRepository;
    }

    /**
     * Processes monthly leave accrual for all active employees.
     * Intended to be called by a future scheduler at the start of each month.
     *
     * @return the number of employees whose balances were updated
     */
    @Transactional
    public int processMonthlyAccrual() {
        List<Employee> activeEmployees = employeeRepository.findByActiveTrue();
        int updated = 0;

        for (Employee employee : activeEmployees) {
            boolean changed = accrueForEmployee(employee);
            if (changed) {
                updated++;
            }
        }

        log.info("Monthly leave accrual completed: {} of {} active employees updated",
                updated, activeEmployees.size());
        return updated;
    }

    /**
     * Processes monthly leave accrual for a single employee.
     *
     * @param employeeId the employee to accrue for
     * @return true if the balance was updated
     */
    @Transactional
    public boolean accrueForEmployee(Long employeeId) {
        Employee employee = employeeRepository.findById(employeeId)
                .orElseThrow(() -> new IllegalArgumentException("Employee not found: " + employeeId));
        return accrueForEmployee(employee);
    }

    private boolean accrueForEmployee(Employee employee) {
        String division = employee.getDivision();
        if (division == null || division.isBlank() || "N/A".equalsIgnoreCase(division.trim())) {
            log.debug("Skipping accrual for employee {} — no division assigned", employee.getId());
            return false;
        }

        boolean changed = false;

        // Vacation leave accrual
        changed |= accrueLeaveType(employee, VACATION_LEAVE_TYPE, division, true);

        // Local leave accrual
        changed |= accrueLeaveType(employee, LOCAL_LEAVE_TYPE, division, false);

        return changed;
    }

    private boolean accrueLeaveType(Employee employee, String leaveType, String division,
                                     boolean isVacation) {
        Optional<LeavePolicy> policyOpt = resolvePolicy(leaveType, division);
        if (policyOpt.isEmpty()) {
            log.debug("No {} policy for division {} — skipping employee {}",
                    leaveType, division, employee.getId());
            return false;
        }

        LeavePolicy policy = policyOpt.get();
        Double accrualRate = policy.getAccrualRate();
        if (accrualRate == null || accrualRate <= 0) {
            log.debug("{} policy for division {} has no accrual rate — skipping employee {}",
                    leaveType, division, employee.getId());
            return false;
        }

        LeaveBalance balance = leaveBalanceRepository.findById(employee.getId())
                .orElseGet(() -> {
                    LeaveBalance newBalance = new LeaveBalance();
                    newBalance.setEmployeeId(employee.getId());
                    newBalance.setLocalLeaveBalance(0);
                    newBalance.setVacationLeaveBalance(0);
                    return newBalance;
                });

        int currentBalance = isVacation
                ? (balance.getVacationLeaveBalance() != null ? balance.getVacationLeaveBalance() : 0)
                : (balance.getLocalLeaveBalance() != null ? balance.getLocalLeaveBalance() : 0);

        // Apply accrual rate (truncate fractional days — they accumulate over months)
        int accrualDays = accrualRate.intValue();
        int newBalance = currentBalance + accrualDays;

        // Enforce max accumulation from policy
        Integer maxAccumulation = policy.getMaxAccumulation();
        if (maxAccumulation != null && newBalance > maxAccumulation) {
            log.debug("Employee {} {} balance {} would exceed max accumulation {} — capping",
                    employee.getId(), leaveType, newBalance, maxAccumulation);
            newBalance = maxAccumulation;
        }

        if (newBalance == currentBalance) {
            return false;
        }

        if (isVacation) {
            balance.setVacationLeaveBalance(newBalance);
        } else {
            balance.setLocalLeaveBalance(newBalance);
        }

        leaveBalanceRepository.save(balance);
        log.debug("Accrued {} days {} for employee {} (division {}): {} → {}",
                accrualDays, leaveType, employee.getId(), division, currentBalance, newBalance);
        return true;
    }

    private Optional<LeavePolicy> resolvePolicy(String leaveType, String division) {
        Optional<LeavePolicy> specific = leavePolicyRepository
                .findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase(leaveType, division.trim());
        if (specific.isPresent()) {
            return specific;
        }
        return leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIsNull(leaveType);
    }
}
