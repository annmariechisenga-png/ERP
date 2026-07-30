package com.localgov.web.security;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.EmployeeRole;
import com.localgov.domain.model.UserAccount;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.UserAccountRepository;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Component
@ConditionalOnProperty(value = "app.bootstrap.users.enabled", havingValue = "true", matchIfMissing = true)
public class UserAccountBootstrap implements ApplicationRunner {

    private final EmployeeRepository employeeRepository;
    private final UserAccountRepository userAccountRepository;
    private final PasswordEncoder passwordEncoder;

    public UserAccountBootstrap(
            EmployeeRepository employeeRepository,
            UserAccountRepository userAccountRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.employeeRepository = employeeRepository;
        this.userAccountRepository = userAccountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (userAccountRepository.count() > 0) {
            return;
        }

        List.of(
                new SeedUser("admin", "Admin@123", "EMP-ADMIN", "System", "Administrator", "admin@localgov.test", "Administration", "Director - Human Resource and Administration", EmployeeRole.ADMIN, new BigDecimal("52000.00"), "other", "ADMIN,HR,PAYROLL", "DIRECTOR_HR_ADMIN", "LA001", "Town Council", "LGSS01", "Division I"),
                new SeedUser("hr", "Hr@123", "EMP-HR-001", "Harriet", "Mbewe", "hr@localgov.test", "Human Resource and Administration", "Director - Human Resource and Administration", EmployeeRole.HR, new BigDecimal("41000.00"), "female", "HR", "DIRECTOR_HR_ADMIN", "LA001", "Town Council", "LGSS02", "Division I"),
                new SeedUser("payroll", "Payroll@123", "EMP-PAY-001", "Peter", "Phiri", "payroll@localgov.test", "Finance", "Director - Finance", EmployeeRole.PAYROLL, new BigDecimal("40000.00"), "male", "PAYROLL", "DIRECTOR_FINANCE", "LA001", "Town Council", "LGSS08", "Division II"),
                new SeedUser("head", "Head@123", "EMP-HOI-001", "Clara", "Banda", "head@localgov.test", "Office of the Head of Institution", "Council Secretary", EmployeeRole.HEAD, new BigDecimal("47000.00"), "female", "HEAD,MANAGER", "COUNCIL_SECRETARY", "LA001", "Town Council", "LGSS01", "Division I"),
                new SeedUser("finance", "Finance@123", "EMP-FIN-001", "Faith", "Zulu", "finance@localgov.test", "Finance", "Director - Finance", EmployeeRole.FINANCE, new BigDecimal("43000.00"), "female", "FINANCE", "DIRECTOR_FINANCE", "LA001", "Town Council", "LGSS09", "Division II"),
                new SeedUser("employee", "Employee@123", "EMP-ESS-001", "Evans", "Tembo", "employee@localgov.test", "Registry", "Records Officer", EmployeeRole.EMPLOYEE, new BigDecimal("15000.00"), "male", "EMPLOYEE", "EMPLOYEE_SELF_SERVICE", "LA001", "Town Council", "GRADE_01", "Division IV")
        ).forEach(this::seedUser);
    }

    private void seedUser(SeedUser definition) {
        Employee employee = employeeRepository.findByEmailIgnoreCase(definition.email())
                .or(() -> employeeRepository.findByEmployeeCodeIgnoreCase(definition.employeeCode()))
                .orElseGet(Employee::new);

        employee.setEmployeeCode(definition.employeeCode());
        employee.setFirstName(definition.firstName());
        employee.setLastName(definition.lastName());
        employee.setEmail(definition.email());
        employee.setDepartment(definition.department());
        employee.setPositionTitle(definition.positionTitle());
        employee.setGender(definition.gender());
        employee.setSalaryScale(definition.salaryScale());
        employee.setDivision(definition.division());
        employee.setBaseSalary(definition.baseSalary());
        employee.setHireDate(LocalDate.of(2024, 1, 1));
        employee.setRole(definition.employeeRole());
        employee.setActive(Boolean.TRUE);
        Employee savedEmployee = employeeRepository.save(employee);

        UserAccount account = new UserAccount();
        account.setUsername(definition.username());
        account.setPasswordHash(passwordEncoder.encode(definition.rawPassword()));
        account.setEmployeeId(savedEmployee.getId());
        account.setRolesCsv(definition.rolesCsv());
        account.setDashboardPositionId(definition.dashboardPositionId());
        account.setAuthorityCode(definition.authorityCode());
        account.setAuthorityType(definition.authorityType());
        account.setMfaEnabled(Boolean.FALSE);
        account.setPrivacyConsentAt(LocalDateTime.now());
        account.setPrivacyNoticeVersion("2026.04");
        account.setActive(Boolean.TRUE);
        userAccountRepository.save(account);
    }

    private record SeedUser(
            String username,
            String rawPassword,
            String employeeCode,
            String firstName,
            String lastName,
            String email,
            String department,
            String positionTitle,
            EmployeeRole employeeRole,
            BigDecimal baseSalary,
            String gender,
            String rolesCsv,
            String dashboardPositionId,
            String authorityCode,
            String authorityType,
            String salaryScale,
            String division
    ) {
    }
}
