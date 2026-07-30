package com.localgov.service.security;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.UserAccount;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.UserAccountRepository;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

/**
 * Resolves the current authenticated user's full ERP identity from the
 * Spring Security context. Never trusts client-provided identity.
 */
@Component
public class AuthenticatedUserContextResolver {

    private final UserAccountRepository userAccountRepository;
    private final EmployeeRepository employeeRepository;

    public AuthenticatedUserContextResolver(UserAccountRepository userAccountRepository,
                                            EmployeeRepository employeeRepository) {
        this.userAccountRepository = userAccountRepository;
        this.employeeRepository = employeeRepository;
    }

    /**
     * Resolves the authenticated user context from SecurityContextHolder.
     * @throws IllegalStateException if no valid authentication is present.
     */
    public AuthenticatedUserContext resolve() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            throw new IllegalStateException("No authenticated user in security context");
        }

        String username;
        String roles;
        if (auth.getPrincipal() instanceof UserDetails userDetails) {
            username = userDetails.getUsername();
            roles = userDetails.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .map(r -> r.startsWith("ROLE_") ? r.substring(5) : r)
                    .collect(Collectors.joining(","));
        } else {
            username = auth.getName();
            roles = auth.getAuthorities().stream()
                    .map(GrantedAuthority::getAuthority)
                    .map(r -> r.startsWith("ROLE_") ? r.substring(5) : r)
                    .collect(Collectors.joining(","));
        }

        UserAccount account = userAccountRepository.findByUsernameIgnoreCase(username)
                .orElseThrow(() -> new IllegalStateException("No user account found for: " + username));

        Long employeeId = null;
        String division = null;
        if (account.getEmployeeId() != null) {
            Employee employee = employeeRepository.findById(account.getEmployeeId()).orElse(null);
            if (employee != null) {
                employeeId = employee.getId();
                division = employee.getDivision();
            }
        }

        return new AuthenticatedUserContext(
                username,
                employeeId,
                account.getAuthorityCode(),
                account.getAuthorityType(),
                roles,
                division
        );
    }
}
