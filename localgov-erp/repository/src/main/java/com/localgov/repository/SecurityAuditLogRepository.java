package com.localgov.repository;

import com.localgov.domain.model.SecurityAuditLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SecurityAuditLogRepository extends JpaRepository<SecurityAuditLog, Long> {
    Page<SecurityAuditLog> findAllByUsernameIgnoreCase(String username, Pageable pageable);
}
