package com.localgov.web.dashboard;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.UserAccount;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.UserAccountRepository;
import com.localgov.service.exception.BusinessValidationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
@Transactional(readOnly = true)
public class DashboardIdentityService {

    private final UserAccountRepository userAccountRepository;
    private final EmployeeRepository employeeRepository;
    private final DashboardProfileService dashboardProfileService;

    public DashboardIdentityService(
            UserAccountRepository userAccountRepository,
            EmployeeRepository employeeRepository,
            DashboardProfileService dashboardProfileService
    ) {
        this.userAccountRepository = userAccountRepository;
        this.employeeRepository = employeeRepository;
        this.dashboardProfileService = dashboardProfileService;
    }

    public DashboardIdentityResponse resolveIdentity(String username) {
        UserAccount account = userAccountRepository.findByUsernameIgnoreCase(username)
                .filter(item -> Boolean.TRUE.equals(item.getActive()))
                .orElseThrow(() -> new UsernameNotFoundException("Persisted user account not found: " + username));

        Employee employee = employeeRepository.findById(account.getEmployeeId())
                .orElseThrow(() -> new BusinessValidationException("No employee mapping exists for username: " + username));

        String positionId = normalizePositionId(account.getDashboardPositionId());
        String positionTitle = hasText(employee.getPositionTitle())
                ? employee.getPositionTitle()
                : dashboardProfileService.resolvePositionTitle(positionId);

        return new DashboardIdentityResponse(
                employee.getId(),
                employee.getEmployeeCode(),
                employeeName(employee),
                employee.getEmail(),
                employee.getDepartment(),
                positionId,
                positionTitle,
                account.getAuthorityCode(),
                account.getAuthorityType(),
                employee.getGender(),
                "user-account"
        );
    }

    private String normalizePositionId(String value) {
        if (!hasText(value)) {
            throw new BusinessValidationException("Dashboard position mapping is missing on the user account");
        }
        return value.trim().toUpperCase(Locale.ROOT);
    }

    private String employeeName(Employee employee) {
        return (String.join(" ",
                employee.getFirstName() == null ? "" : employee.getFirstName().trim(),
                employee.getLastName() == null ? "" : employee.getLastName().trim()
        )).trim();
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
