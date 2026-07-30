package com.localgov.service.leave;

import com.localgov.domain.model.LeaveBalance;
import com.localgov.domain.model.LeaveType;
import com.localgov.repository.LeaveBalanceRepository;
import org.springframework.stereotype.Component;

import java.util.EnumSet;
import java.util.Set;

/**
 * Evaluates leave balance: reads current balance and determines the bucket.
 */
@Component
public class BalanceEvaluator {

    private static final Set<LeaveType> CONDITION_OF_SERVICE_TYPES = EnumSet.of(
            LeaveType.MATERNITY, LeaveType.PATERNITY, LeaveType.COMPASSIONATE,
            LeaveType.FAMILY_CARE, LeaveType.MOTHERS_DAY, LeaveType.SICK, LeaveType.STUDY);
    private static final int DEFAULT_LOCAL_LEAVE_BALANCE = 30;
    private static final int DEFAULT_VACATION_LEAVE_BALANCE = 30;

    private final LeaveBalanceRepository leaveBalanceRepository;

    public BalanceEvaluator(LeaveBalanceRepository leaveBalanceRepository) {
        this.leaveBalanceRepository = leaveBalanceRepository;
    }

    public String resolveBucket(LeaveType type) {
        if (type == LeaveType.LOCAL) return "LOCAL_LEAVE";
        if (type == LeaveType.VACATION) return "VACATION_LEAVE";
        return "NONE";
    }

    public boolean isConditionOfService(LeaveType type) {
        return CONDITION_OF_SERVICE_TYPES.contains(type);
    }

    public boolean deductsFromBalance(LeaveType type) {
        return !"NONE".equals(resolveBucket(type)) && !isConditionOfService(type);
    }

    public Integer readBalance(Long employeeId, String bucket) {
        if ("NONE".equals(bucket)) return null;
        LeaveBalance lb = leaveBalanceRepository.findById(employeeId).orElse(null);
        if (lb == null) return "LOCAL_LEAVE".equals(bucket) ? DEFAULT_LOCAL_LEAVE_BALANCE : DEFAULT_VACATION_LEAVE_BALANCE;
        return switch (bucket) {
            case "LOCAL_LEAVE" -> norm(lb.getLocalLeaveBalance());
            case "VACATION_LEAVE" -> norm(lb.getVacationLeaveBalance());
            default -> null;
        };
    }

    private static int norm(Integer v) { return v == null ? 0 : Math.max(0, v); }
}
