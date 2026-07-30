package com.localgov.repository;

import com.localgov.domain.model.EmploymentPlacementAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmploymentPlacementAuditLogRepository extends JpaRepository<EmploymentPlacementAuditLog, Long> {
}
