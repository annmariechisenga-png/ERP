package com.localgov.web.controller;

import com.localgov.domain.model.PrivacyDataRequest;
import com.localgov.repository.PrivacyDataRequestRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/privacy")
public class PrivacyComplianceController {

    private static final Set<String> ALLOWED_REQUEST_TYPES = Set.of("ACCESS", "EXPORT", "DELETION", "CORRECTION", "OPT_OUT");

    private final PrivacyDataRequestRepository privacyDataRequestRepository;

    @Value("${app.security.privacy.retention-days:365}")
    private int retentionDays;

    @Value("${app.security.privacy.notice-version:2026.04}")
    private String noticeVersion;

    @Value("${app.security.privacy.dpo-contact:dpo@localgov.test}")
    private String dpoContact;

    public PrivacyComplianceController(PrivacyDataRequestRepository privacyDataRequestRepository) {
        this.privacyDataRequestRepository = privacyDataRequestRepository;
    }

    @GetMapping("/compliance")
    public Map<String, Object> complianceSummary() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("gdprSupported", true);
        response.put("ccpaSupported", true);
        response.put("privacyNoticeVersion", noticeVersion);
        response.put("retentionDays", retentionDays);
        response.put("dataProtectionOfficer", dpoContact);
        response.put("dataSubjectRights", List.of("access", "correction", "export", "deletion", "opt_out"));
        response.put("securityControls", List.of("MFA", "RBAC", "TLS", "Audit logging", "CSRF protection", "Session timeout"));
        return response;
    }

    @PostMapping("/data-requests")
    public ResponseEntity<PrivacyDataRequest> submitDataRequest(
            Authentication authentication,
            @Valid @RequestBody PrivacyRequestPayload payload
    ) {
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication is required to submit a privacy request.");
        }

        String normalizedType = payload.requestType().trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_REQUEST_TYPES.contains(normalizedType)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported requestType. Use ACCESS, EXPORT, DELETION, CORRECTION, or OPT_OUT.");
        }

        PrivacyDataRequest request = new PrivacyDataRequest();
        request.setUsername(authentication.getName());
        request.setRequestType(normalizedType);
        request.setStatus("SUBMITTED");
        request.setDetails(payload.details());

        return ResponseEntity.status(HttpStatus.CREATED).body(privacyDataRequestRepository.save(request));
    }

    @GetMapping("/data-requests")
    public List<PrivacyDataRequest> listDataRequests(
            Authentication authentication,
            @RequestParam(defaultValue = "50") int limit
    ) {
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication is required to view privacy requests.");
        }

        int safeLimit = Math.max(1, Math.min(limit, 200));
        PageRequest pageRequest = PageRequest.of(0, safeLimit, Sort.by(Sort.Direction.DESC, "createdAt"));

        boolean canViewAll = authentication.getAuthorities().stream().anyMatch(authority -> {
            String value = authority.getAuthority();
            return "ROLE_ADMIN".equals(value) || "ROLE_HR".equals(value);
        });

        if (canViewAll) {
            return privacyDataRequestRepository.findAll(pageRequest).getContent();
        }
        return privacyDataRequestRepository.findAllByUsernameIgnoreCaseOrderByCreatedAtDesc(authentication.getName(), pageRequest).getContent();
    }

    private record PrivacyRequestPayload(
            @NotBlank String requestType,
            String details
    ) {
    }
}
