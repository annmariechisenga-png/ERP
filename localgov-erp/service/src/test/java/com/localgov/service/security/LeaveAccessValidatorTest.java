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
        AuthenticatedUserContext admin = ctx("EMP-0001", "ADMIN", "LA001");
        assertThatCode(() -> validator.validateReadAccess(admin, "EMP-0099"))
                .doesNotThrowAnyException();
    }

    @Test
    void employeeCanReadOwnData() {
        AuthenticatedUserContext self = ctx("EMP-0005", "EMPLOYEE", "LA001");
        assertThatCode(() -> validator.validateReadAccess(self, "EMP-0005"))
                .doesNotThrowAnyException();
    }

    @Test
    void supervisorCanReadSubordinateData() {
        AuthenticatedUserContext supervisor = ctx("EMP-0010", "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId("EMP-0010");
        when(employeeRepository.findById("EMP-0020")).thenReturn(Optional.of(target));

        assertThatCode(() -> validator.validateReadAccess(supervisor, "EMP-0020"))
                .doesNotThrowAnyException();
    }

    @Test
    void hrSameAuthorityCanReadData() {
        AuthenticatedUserContext hr = ctx("EMP-0010", "HR", "LA001");
        Employee target = new Employee();
        target.setSupervisorId("EMP-0099");
        when(employeeRepository.findById("EMP-0040")).thenReturn(Optional.of(target));

        UserAccount targetAccount = new UserAccount();
        targetAccount.setEmployeeId("EMP-0040");
        targetAccount.setAuthorityCode("LA001");
        when(userAccountRepository.findByEmployeeId("EMP-0040")).thenReturn(Optional.of(targetAccount));

        assertThatCode(() -> validator.validateReadAccess(hr, "EMP-0040"))
                .doesNotThrowAnyException();
    }

    @Test
    void unrelatedEmployeeCannotReadOtherData() {
        AuthenticatedUserContext other = ctx("EMP-0010", "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId("EMP-0099");
        when(employeeRepository.findById("EMP-0050")).thenReturn(Optional.of(target));

        assertThatThrownBy(() -> validator.validateReadAccess(other, "EMP-0050"))
                .isInstanceOf(AccessDeniedException.class);
    }

    // ── Approval Access ──

    @Test
    void employeeCannotSelfApprove() {
        AuthenticatedUserContext self = ctx("EMP-0005", "EMPLOYEE", "LA001");
        assertThatThrownBy(() -> validator.validateApprovalAccess(self, "EMP-0005"))
                .isInstanceOf(AccessDeniedException.class)
                .hasMessageContaining("own leave");
    }

    @Test
    void adminCanApproveAnyLeave() {
        AuthenticatedUserContext admin = ctx("EMP-0001", "ADMIN", "LA001");
        assertThatCode(() -> validator.validateApprovalAccess(admin, "EMP-0099"))
                .doesNotThrowAnyException();
    }

    @Test
    void supervisorCanApproveSubordinateLeave() {
        AuthenticatedUserContext supervisor = ctx("EMP-0010", "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId("EMP-0010");
        when(employeeRepository.findById("EMP-0020")).thenReturn(Optional.of(target));

        assertThatCode(() -> validator.validateApprovalAccess(supervisor, "EMP-0020"))
                .doesNotThrowAnyException();
    }

    @Test
    void unrelatedUserCannotApproveLeave() {
        AuthenticatedUserContext other = ctx("EMP-0010", "EMPLOYEE", "LA001");
        Employee target = new Employee();
        target.setSupervisorId("EMP-0099");
        when(employeeRepository.findById("EMP-0050")).thenReturn(Optional.of(target));

        assertThatThrownBy(() -> validator.validateApprovalAccess(other, "EMP-0050"))
                .isInstanceOf(AccessDeniedException.class);
    }

    @Test
    void hrDifferentAuthorityCannotApprove() {
        AuthenticatedUserContext hr = ctx("EMP-0010", "HR", "LA002");
        Employee target = new Employee();
        target.setSupervisorId("EMP-0099");
        when(employeeRepository.findById("EMP-0060")).thenReturn(Optional.of(target));

        UserAccount targetAccount = new UserAccount();
        targetAccount.setEmployeeId("EMP-0060");
        targetAccount.setAuthorityCode("LA001");
        when(userAccountRepository.findByEmployeeId("EMP-0060")).thenReturn(Optional.of(targetAccount));

        assertThatThrownBy(() -> validator.validateApprovalAccess(hr, "EMP-0060"))
                .isInstanceOf(AccessDeniedException.class);
    }

    // ── Submission Access ──

    @Test
    void employeeCanSubmitOwnLeave() {
        AuthenticatedUserContext self = ctx("EMP-0005", "EMPLOYEE", "LA001");
        assertThatCode(() -> validator.validateSubmissionAccess(self, "EMP-0005"))
                .doesNotThrowAnyException();
    }

    @Test
    void hrSameAuthorityCanSubmitForEmployee() {
        AuthenticatedUserContext hr = ctx("EMP-0010", "HR", "LA001");
        UserAccount targetAccount = new UserAccount();
        targetAccount.setEmployeeId("EMP-0040");
        targetAccount.setAuthorityCode("LA001");
        when(userAccountRepository.findByEmployeeId("EMP-0040")).thenReturn(Optional.of(targetAccount));

        assertThatCode(() -> validator.validateSubmissionAccess(hr, "EMP-0040"))
                .doesNotThrowAnyException();
    }

    @Test
    void otherEmployeeCannotSubmitForAnother() {
        AuthenticatedUserContext other = ctx("EMP-0010", "EMPLOYEE", "LA001");

        assertThatThrownBy(() -> validator.validateSubmissionAccess(other, "EMP-0050"))
                .isInstanceOf(AccessDeniedException.class);
    }

    // ── helper ──

    private AuthenticatedUserContext ctx(String employeeId, String role, String authorityCode) {
        return new AuthenticatedUserContext("testuser", employeeId, authorityCode, "Town Council", role, "I");
    }
}
