package com.localgov.repository;

import com.localgov.domain.model.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserAccountRepository extends JpaRepository<UserAccount, Long> {
    Optional<UserAccount> findByUsernameIgnoreCase(String username);

    Optional<UserAccount> findByEmployeeId(Long employeeId);

    boolean existsByUsernameIgnoreCase(String username);
}
