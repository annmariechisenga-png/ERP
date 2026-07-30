package com.localgov.web.security;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.UserAccount;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.UserAccountRepository;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;

@Service
public class DatabaseUserDetailsService implements UserDetailsService {

    private final UserAccountRepository userAccountRepository;
    private final EmployeeRepository employeeRepository;

    public DatabaseUserDetailsService(UserAccountRepository userAccountRepository, EmployeeRepository employeeRepository) {
        this.userAccountRepository = userAccountRepository;
        this.employeeRepository = employeeRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Try to find by username first, then by employee ID (if numeric), then by employee code
        UserAccount account = userAccountRepository.findByUsernameIgnoreCase(username)
                .filter(item -> Boolean.TRUE.equals(item.getActive()))
                .or(() -> {
                    // Try to parse as employee ID if numeric
                    try {
                        Long empId = Long.parseLong(username);
                        return userAccountRepository.findByEmployeeId(empId)
                                .filter(item -> Boolean.TRUE.equals(item.getActive()));
                    } catch (NumberFormatException e) {
                        return java.util.Optional.empty();
                    }
                })
                .or(() -> {
                    // Try to find by employee code (e.g. ZM09-CHL-2024-000001)
                    return employeeRepository.findByEmployeeCode(username)
                            .flatMap(emp -> userAccountRepository.findByEmployeeId(emp.getId())
                                    .filter(item -> Boolean.TRUE.equals(item.getActive())));
                })
                .orElseThrow(() -> new UsernameNotFoundException("User account not found: " + username));

        List<String> roles = parseRoles(account.getRolesCsv());
        if (roles.isEmpty()) {
            throw new UsernameNotFoundException("No roles configured for user account: " + username);
        }

        return User.builder()
                .username(account.getUsername())
                .password(account.getPasswordHash())
                .roles(roles.toArray(String[]::new))
                .disabled(!Boolean.TRUE.equals(account.getActive()))
                .build();
    }

    private List<String> parseRoles(String rolesCsv) {
        if (rolesCsv == null || rolesCsv.isBlank()) {
            return List.of();
        }
        return Arrays.stream(rolesCsv.split(","))
                .map(String::trim)
                .filter(item -> !item.isBlank())
                .map(item -> item.toUpperCase(Locale.ROOT))
                .map(item -> item.startsWith("ROLE_") ? item.substring(5) : item)
                .distinct()
                .toList();
    }
}
