package com.localgov.service.security;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.UserAccount;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.UserAccountRepository;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

/**
 * Validates whether the authenticated user is authorised to act on a given employee's
 * leave data. Uses ONLY the existing ERP hierarchy:
 * <ul>
 *   <li>Employee → own data only</li>
 *   <li>Supervisor → employee.supervisor_id = current user</li>
 *   <li>HR → same authority_code</li>
 *   <li>Admin → full access</li>
 * </ul>
 */
@Component
public class LeaveAccessValidator {

    private final EmployeeRepository employeeRepository;
    private final UserAccountRepository userAccountRepository;

    public LeaveAccessValidator(EmployeeRepository employeeRepository,
                                UserAccountRepository userAccountRepository) {
        this.employeeRepository = employeeRepository;
        this.userAccountRepository = userAccountRepository;
    }

    /**
     * Validates that the authenticated user can view/read the target employee's leave data.
     * Permitted: self, supervisor, HR (same authority), or ADMIN.
     */
    public void validateReadAccess(AuthenticatedUserContext caller, String targetEmployeeId) {
        if (isAdmin(caller)) return;
        if (isSelf(caller, targetEmployeeId)) return;
        if (isSupervisorOf(caller, targetEmployeeId)) return;
        if (isHrSameAuthority(caller, targetEmployeeId)) return;

        throw new AccessDeniedException("You are not authorised to access this employee's leave data.");
    }

    /**
     * Validates that the authenticated user can approve/reject the target employee's leave.
     * Permitted: supervisor, HR (same authority), or ADMIN.
     * NOT permitted: self-approval.
     */
    public void validateApprovalAccess(AuthenticatedUserContext caller, String targetEmployeeId) {
        if (isSelf(caller, targetEmployeeId)) {
            throw new AccessDeniedException("Employees cannot approve their own leave requests.");
        }
        if (isAdmin(caller)) return;
        if (isSupervisorOf(caller, targetEmployeeId)) return;
        if (isHrSameAuthority(caller, targetEmployeeId)) return;

        throw new AccessDeniedException("You are not authorised to approve this employee's leave request.");
    }

    /**
     * Validates that the authenticated user can submit leave on behalf of the target employee.
     * Permitted: self, HR (same authority), or ADMIN.
     */
    public void validateSubmissionAccess(AuthenticatedUserContext caller, String targetEmployeeId) {
        if (isAdmin(caller)) return;
        if (isSelf(caller, targetEmployeeId)) return;
        if (isHrSameAuthority(caller, targetEmployeeId)) return;

        throw new AccessDeniedException("You are not authorised to submit leave for this employee.");
    }

    private boolean isSelf(AuthenticatedUserContext caller, String targetEmployeeId) {
        return caller.employeeId() != null && caller.employeeId().equals(targetEmployeeId);
    }

    private boolean isAdmin(AuthenticatedUserContext caller) {
        return caller.role() != null && caller.role().contains("ADMIN");
    }

    private boolean isSupervisorOf(AuthenticatedUserContext caller, String targetEmployeeId) {
        return employeeRepository.findById(targetEmployeeId)
                .map(Employee::getSupervisorId)
                .map(supervisorId -> supervisorId.equals(caller.employeeId()))
                .orElse(false);
    }

    // NOTE: HOD-based access (isHodOf) was removed because Employee.getHodId()
    // is a deferred-feature stub that unconditionally returns null, so the branch
    // could never grant access. When HOD tracking is implemented, re-add the
    // method and its test together in the same commit.

    private boolean isHrSameAuthority(AuthenticatedUserContext caller, String targetEmployeeId) {
        if (caller.role() == null || !caller.role().contains("HR")) {
            return false;
        }
        if (caller.authorityCode() == null) {
            return false;
        }
        // If the target employee has no UserAccount yet (e.g. newly onboarded),
        // HR with a valid authority_code is permitted to act on their behalf.
        return userAccountRepository.findByEmployeeId(targetEmployeeId)
                .map(UserAccount::getAuthorityCode)
                .map(targetAuthCode -> caller.authorityCode().equals(targetAuthCode))
                .orElse(true);
    }
}
