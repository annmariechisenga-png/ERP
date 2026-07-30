package com.localgov.service.leave;

import com.localgov.domain.model.LeaveCalculationAuditLog;
import com.localgov.repository.LeaveCalculationAuditLogRepository;
import com.localgov.service.dto.LeaveCalculationResult;
import com.localgov.service.security.AuthenticatedUserContext;
import com.localgov.service.security.AuthenticatedUserContextResolver;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Persists audit entries for every leave calculation event.
 * Uses REQUIRES_NEW to ensure audit is logged even if the outer transaction rolls back.
 * Identity is ALWAYS derived from Spring Security context — never client-provided.
 */
@Component
public class CalculationAuditor {

    private final LeaveCalculationAuditLogRepository auditRepository;
    private final AuthenticatedUserContextResolver userContextResolver;

    public CalculationAuditor(LeaveCalculationAuditLogRepository auditRepository,
                              AuthenticatedUserContextResolver userContextResolver) {
        this.auditRepository = auditRepository;
        this.userContextResolver = userContextResolver;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public LeaveCalculationAuditLog log(Long employeeId, String division, LeaveCalculationResult result,
                                         int originalRequestedDays, AuditTriggerType triggerType) {
        AuthenticatedUserContext ctx = userContextResolver.resolve();

        LeaveCalculationAuditLog entry = LeaveCalculationAuditLog.builder()
                .employeeId(employeeId)
                .leaveType(result.leaveType().name())
                .division(division)
                .startDate(result.startDate())
                .requestedDays(originalRequestedDays)
                .adjustedDays(result.chargeableDays() != originalRequestedDays ? result.chargeableDays() : null)
                .forfeitedDays(result.forfeitedDays())
                .reason(result.policyViolationFlag())
                .balanceBefore(result.currentLeaveBalance())
                .balanceAfter(result.remainingBalanceAfterApproval())
                .calculationMode(result.calculationMode())
                .triggeredBy(triggerType.name())
                .username(ctx.username())
                .authorityCode(ctx.authorityCode())
                .authorityType(ctx.authorityType())
                .role(ctx.role())
                .build();
        return auditRepository.save(entry);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void attachLeaveRequestId(Long auditId, Long leaveRequestId) {
        auditRepository.findById(auditId).ifPresent(entry -> {
            entry.setLeaveRequestId(leaveRequestId);
            auditRepository.save(entry);
        });
    }
}
