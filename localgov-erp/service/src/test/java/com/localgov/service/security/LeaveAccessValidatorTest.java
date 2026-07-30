package com.localgov.service.security;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.UserAccount;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.UserAccountRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LeaveAccessValidatorTest {

    @Mock private EmployeeRepository employeeRepository;
    @Mock private UserAccountRepository userAccountRepository;

    private LeaveAccessValidator validator;

    @BeforeEach
    void setUp() {
        validator = new LeaveAccessValidator(employeeRepository, userAccountRepository);
    }

    // ── Read Access ──

    @Test
    void adminCanReadAnyEmployeeData() {
        AuthenticatedUserContext admin = ctx(1L, "ADMIN", "LA001");
        assertThatCode(() -> validator.validateReadAccess(admin, 99L))
                .doesNotThrowAnyException();
    }

    @Test
    void employeeCanReadOwnData() {
        AuthenticatedUserContext self = ctx(5L, "EMPLOYEE", "LA001");
        assertThatCode(() -> validator.validateReadAccess(self, 5L))
                .doesNotThrowAnyException();
    }

    @Test
    void supervisorCanReadSubordinateData() {
        AuthenticatedUserContext supervisor = ctx(10L, "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId(10L);
        when(employeeRepository.findById(20L)).thenReturn(Optional.of(target));

        assertThatCode(() -> validator.validateReadAccess(supervisor, 20L))
                .doesNotThrowAnyException();
    }

    @Test
    void hodCanReadDepartmentEmployeeData() {
        AuthenticatedUserContext hod = ctx(10L, "HEAD", "LA001");
        Employee target = new Employee();
        target.setHodId(10L);
        when(employeeRepository.findById(30L)).thenReturn(Optional.of(target));

        assertThatCode(() -> validator.validateReadAccess(hod, 30L))
                .doesNotThrowAnyException();
    }

    @Test
    void hrSameAuthorityCanReadData() {
        AuthenticatedUserContext hr = ctx(10L, "HR", "LA001");
        Employee target = new Employee();
        target.setSupervisorId(99L);
        target.setHodId(99L);
        when(employeeRepository.findById(40L)).thenReturn(Optional.of(target));

        UserAccount targetAccount = new UserAccount();
        targetAccount.setAuthorityCode("LA001");
        when(userAccountRepository.findByEmployeeId(40L)).thenReturn(Optional.of(targetAccount));

        assertThatCode(() -> validator.validateReadAccess(hr, 40L))
                .doesNotThrowAnyException();
    }

    @Test
    void unrelatedEmployeeCannotReadOtherData() {
        AuthenticatedUserContext other = ctx(10L, "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId(99L);
        target.setHodId(99L);
        when(employeeRepository.findById(50L)).thenReturn(Optional.of(target));

        assertThatThrownBy(() -> validator.validateReadAccess(other, 50L))
                .isInstanceOf(AccessDeniedException.class);
    }

    // ── Approval Access ──

    @Test
    void employeeCannotSelfApprove() {
        AuthenticatedUserContext self = ctx(5L, "EMPLOYEE", "LA001");
        assertThatThrownBy(() -> validator.validateApprovalAccess(self, 5L))
                .isInstanceOf(AccessDeniedException.class)
                .hasMessageContaining("own leave");
    }

    @Test
    void adminCanApproveAnyLeave() {
        AuthenticatedUserContext admin = ctx(1L, "ADMIN", "LA001");
        assertThatCode(() -> validator.validateApprovalAccess(admin, 99L))
                .doesNotThrowAnyException();
    }

    @Test
    void supervisorCanApproveSubordinateLeave() {
        AuthenticatedUserContext supervisor = ctx(10L, "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId(10L);
        when(employeeRepository.findById(20L)).thenReturn(Optional.of(target));

        assertThatCode(() -> validator.validateApprovalAccess(supervisor, 20L))
                .doesNotThrowAnyException();
    }

    @Test
    void unrelatedUserCannotApproveLeave() {
        AuthenticatedUserContext other = ctx(10L, "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId(99L);
        target.setHodId(99L);
        when(employeeRepository.findById(50L)).thenReturn(Optional.of(target));

        assertThatThrownBy(() -> validator.validateApprovalAccess(other, 50L))
                .isInstanceOf(AccessDeniedException.class);
    }

    @Test
    void hrDifferentAuthorityCannotApprove() {
        AuthenticatedUserContext hr = ctx(10L, "HR", "LA002");
        Employee target = new Employee();
        target.setSupervisorId(99L);
        target.setHodId(99L);
        when(employeeRepository.findById(60L)).thenReturn(Optional.of(target));

        UserAccount targetAccount = new UserAccount();
        targetAccount.setAuthorityCode("LA001");
        when(userAccountRepository.findByEmployeeId(60L)).thenReturn(Optional.of(targetAccount));

        assertThatThrownBy(() -> validator.validateApprovalAccess(hr, 60L))
                .isInstanceOf(AccessDeniedException.class);
    }

    // ── Submission Access ──

    @Test
    void employeeCanSubmitOwnLeave() {
        AuthenticatedUserContext self = ctx(5L, "EMPLOYEE", "LA001");
        assertThatCode(() -> validator.validateSubmissionAccess(self, 5L))
                .doesNotThrowAnyException();
    }

    @Test
    void hrSameAuthorityCanSubmitForEmployee() {
        AuthenticatedUserContext hr = ctx(10L, "HR", "LA001");
        UserAccount targetAccount = new UserAccount();
        targetAccount.setAuthorityCode("LA001");
        when(userAccountRepository.findByEmployeeId(40L)).thenReturn(Optional.of(targetAccount));

        assertThatCode(() -> validator.validateSubmissionAccess(hr, 40L))
                .doesNotThrowAnyException();
    }

    @Test
    void otherEmployeeCannotSubmitForAnother() {
        AuthenticatedUserContext other = ctx(10L, "EMPLOYEE", "LA001");

        assertThatThrownBy(() -> validator.validateSubmissionAccess(other, 50L))
                .isInstanceOf(AccessDeniedException.class);
    }

    // ── helper ──

    private AuthenticatedUserContext ctx(Long employeeId, String role, String authorityCode) {
        return new AuthenticatedUserContext("testuser", employeeId, authorityCode, "Town Council", role, "I");
    }
}
