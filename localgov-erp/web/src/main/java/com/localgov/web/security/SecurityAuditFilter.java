package com.localgov.web.security;

import com.localgov.domain.model.SecurityAuditLog;
import com.localgov.repository.SecurityAuditLogRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
public class SecurityAuditFilter extends OncePerRequestFilter {

    private static final Logger LOGGER = LoggerFactory.getLogger(SecurityAuditFilter.class);

    private final SecurityAuditLogRepository securityAuditLogRepository;

    @Value("${app.security.audit.enabled:true}")
    private boolean auditEnabled;

    public SecurityAuditFilter(SecurityAuditLogRepository securityAuditLogRepository) {
        this.securityAuditLogRepository = securityAuditLogRepository;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        if (!auditEnabled) {
            return true;
        }

        String path = request.getRequestURI();
        return path.contains("/assets/")
                || path.contains("/swagger-ui")
                || path.contains("/v3/api-docs")
                || path.contains("/actuator");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String correlationId = request.getHeader("X-Request-ID");
        if (correlationId == null || correlationId.isBlank()) {
            correlationId = UUID.randomUUID().toString();
        }
        response.setHeader("X-Request-ID", correlationId);

        try {
            filterChain.doFilter(request, response);
        } finally {
            try {
                SecurityAuditLog auditLog = new SecurityAuditLog();
                auditLog.setAction(resolveAction(request, response));
                auditLog.setHttpMethod(request.getMethod());
                auditLog.setPath(trimToLength(request.getRequestURI(), 255));
                auditLog.setStatusCode(response.getStatus());
                auditLog.setSuccess(response.getStatus() < 400);
                auditLog.setClientIp(trimToLength(resolveClientIp(request), 80));
                auditLog.setUserAgent(trimToLength(request.getHeader("User-Agent"), 255));
                auditLog.setCorrelationId(trimToLength(correlationId, 80));

                Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
                if (authentication != null
                        && authentication.isAuthenticated()
                        && !(authentication instanceof AnonymousAuthenticationToken)) {
                    auditLog.setUsername(authentication.getName());
                    auditLog.setRolesCsv(authentication.getAuthorities().stream()
                            .map(GrantedAuthority::getAuthority)
                            .collect(Collectors.joining(",")));
                } else {
                    auditLog.setUsername("anonymous");
                    auditLog.setRolesCsv("");
                }

                securityAuditLogRepository.save(auditLog);
            } catch (Exception exception) {
                LOGGER.warn("Unable to persist security audit log for {} {}", request.getMethod(), request.getRequestURI(), exception);
            }
        }
    }

    private String resolveAction(HttpServletRequest request, HttpServletResponse response) {
        String path = request.getRequestURI();
        if (path.endsWith("/auth/login")) {
            return response.getStatus() < 400 ? "LOGIN_SUCCESS" : "LOGIN_FAILURE";
        }
        if (path.endsWith("/auth/me")) {
            return "READ_SESSION";
        }
        return trimToLength(request.getMethod() + " " + path, 160);
    }

    private String resolveClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    private String trimToLength(String value, int maxLength) {
        if (value == null) {
            return null;
        }
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }
}
