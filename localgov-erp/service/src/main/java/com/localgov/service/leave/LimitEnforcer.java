package com.localgov.service.leave;

import com.localgov.domain.model.LeavePolicy;
import org.springframework.stereotype.Component;

/**
 * Enforces continuous leave limits and accumulation caps.
 * Returns adjustment details for audit logging.
 */
@Component
public class LimitEnforcer {

    public LimitResult enforce(LeavePolicy policy, int requestedDays, Integer currentBalance) {
        Integer continuousLimit = policy.getContinuousLeaveLimit();
        Integer accumulationLimit = policy.getMaxAccumulation();
        int adjustedDays = requestedDays;
        Integer forfeitedDays = null;
        String violationFlag = null;

        if (continuousLimit != null && requestedDays > continuousLimit) {
            forfeitedDays = requestedDays - continuousLimit;
            adjustedDays = continuousLimit;
            violationFlag = "CONTINUOUS_LEAVE_LIMIT_EXCEEDED";
        }

        if (accumulationLimit != null && currentBalance != null && currentBalance > accumulationLimit) {
            int excess = currentBalance - accumulationLimit;
            if (forfeitedDays == null) {
                forfeitedDays = excess;
                violationFlag = "ACCUMULATION_LIMIT_EXCEEDED";
            } else {
                forfeitedDays += excess;
                violationFlag = "CONTINUOUS_AND_ACCUMULATION_LIMITS_EXCEEDED";
            }
        }

        return new LimitResult(adjustedDays, continuousLimit, accumulationLimit, forfeitedDays, violationFlag);
    }

    public record LimitResult(int adjustedDays, Integer continuousLimit, Integer accumulationLimit,
                               Integer forfeitedDays, String violationFlag) {
        public boolean wasAdjusted() { return violationFlag != null; }
    }
}
