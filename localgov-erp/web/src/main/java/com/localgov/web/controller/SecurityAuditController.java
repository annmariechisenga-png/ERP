package com.localgov.web.controller;

import com.localgov.domain.model.SecurityAuditLog;
import com.localgov.repository.SecurityAuditLogRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/security")
public class SecurityAuditController {

    private final SecurityAuditLogRepository securityAuditLogRepository;

    public SecurityAuditController(SecurityAuditLogRepository securityAuditLogRepository) {
        this.securityAuditLogRepository = securityAuditLogRepository;
    }

    @GetMapping("/audit-logs")
    public List<SecurityAuditLog> auditLogs(
            @RequestParam(required = false) String username,
            @RequestParam(defaultValue = "100") int limit
    ) {
        int safeLimit = Math.max(1, Math.min(limit, 500));
        PageRequest pageRequest = PageRequest.of(0, safeLimit, Sort.by(Sort.Direction.DESC, "createdAt"));

        if (username != null && !username.isBlank()) {
            return securityAuditLogRepository.findAllByUsernameIgnoreCase(username, pageRequest).getContent();
        }
        return securityAuditLogRepository.findAll(pageRequest).getContent();
    }
}
