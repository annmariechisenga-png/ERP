package com.localgov.web.controller;

import com.localgov.service.EmploymentPlacementService;
import com.localgov.service.NotchProgressionValidationService;
import com.localgov.service.AnnualIncrementService;
import com.localgov.service.SalaryAuditService;
import com.localgov.service.dto.AnnualIncrementRequest;
import com.localgov.service.dto.BatchIncrementRequest;
import com.localgov.service.dto.EmploymentPlacementRequest;
import com.localgov.service.dto.EmploymentPlacementResponse;
import com.localgov.service.dto.SuspiciousChangeResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/employment")
@Validated
@Tag(name = "Employment Placement", description = "Officer salary scale placement endpoints")
public class EmploymentPlacementController {

    private final EmploymentPlacementService employmentPlacementService;
    private final NotchProgressionValidationService progressionValidationService;
    private final AnnualIncrementService annualIncrementService;
    private final SalaryAuditService salaryAuditService;

    public EmploymentPlacementController(
            EmploymentPlacementService employmentPlacementService,
            NotchProgressionValidationService progressionValidationService,
            AnnualIncrementService annualIncrementService,
            SalaryAuditService salaryAuditService
    ) {
        this.employmentPlacementService = employmentPlacementService;
        this.progressionValidationService = progressionValidationService;
        this.annualIncrementService = annualIncrementService;
        this.salaryAuditService = salaryAuditService;
    }

    @PostMapping("/place-officer")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Place officer at official salary scale/notch", description = "Allowed roles: ADMIN, HR, PAYROLL")
    public EmploymentPlacementResponse placeOfficer(@Valid @RequestBody EmploymentPlacementRequest request) {
        return employmentPlacementService.placeOfficer(request);
    }

    /**
     * Validate a proposed notch progression before committing the placement.
     * Calls the validate_notch_progression() PostgreSQL function (V16 migration)
     * and returns its JSONB payload verbatim so the front-end receives the same
     * shape regardless of which rule triggered.
     *
     * <pre>
     * GET /api/employment/validate-progression
     *   ?officerId=42
     *   &newScale=LGSS08
     *   &newNotch=4
     *   &effectiveDate=2026-04-01
     *
     * 200 OK — {"valid":true,"severity":"INFO","current_scale":"LGSS08","current_notch":3}
     * 200 OK — {"valid":false,"reason":"Cannot skip notches...","severity":"MEDIUM",...}
     * </pre>
     *
     * Always returns HTTP 200; the front-end reads the {@code valid} field to decide
     * whether to enable the confirm button.
     */
    @GetMapping(value = "/validate-progression", produces = MediaType.APPLICATION_JSON_VALUE)
    @Operation(
        summary = "Validate proposed notch progression",
        description = "Checks Rules 1-3 (demotion, skip, cross-scale adjacency) against the "
            + "officer's current employment_history record. Returns JSONB with valid/reason/severity. "
            + "Allowed roles: ADMIN, HR, PAYROLL"
    )
    public ResponseEntity<String> validateProgression(
            @Parameter(description = "BIGINT PK of the officer in erp_employee", example = "42")
            @RequestParam @NotNull @Positive Long officerId,

            @Parameter(description = "Target salary scale code", example = "LGSS08")
            @RequestParam @NotBlank String newScale,

            @Parameter(description = "Target notch number", example = "4")
            @RequestParam @NotNull @Positive Integer newNotch,

            @Parameter(description = "Proposed effective date (ISO-8601)", example = "2026-04-01")
            @RequestParam @NotNull @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate effectiveDate
    ) {
        String json = progressionValidationService.validateProgression(
                officerId, newScale, newNotch, effectiveDate);
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(json);
    }

    /**
     * Returns officers with suspicious salary-change patterns over the last {@code days} days.
     * Calls the detect_suspicious_salary_changes(p_days) PostgreSQL function (V17 migration).
     *
     * <pre>
     * GET /api/employment/suspicious-changes?days=30
     * GET /api/employment/suspicious-changes          (defaults to 30 days)
     *
     * 200 OK
     * [
     *   { "officer_name":"Jane Banda", "authority_name":"Lusaka City Council",
     *     "changes_count":3, "total_increase":12500.00, "avg_risk_score":65.0,
     *     "flagged_count":2, "risk_level":"HIGH" }
     * ]
     * </pre>
     */
    @GetMapping("/suspicious-changes")
    @Operation(
        summary = "Detect suspicious salary change patterns",
        description = "Officers with >1 change or total increase >ZMW 5 000 in the look-back window. "
            + "Allowed roles: ADMIN, HR"
    )
    public List<SuspiciousChangeResponse> suspiciousChanges(
            @Parameter(description = "Look-back window in days", example = "30")
            @RequestParam(defaultValue = "30") @Positive int days
    ) {
        return salaryAuditService.getSuspiciousChanges(days);
    }

    /**
     * Returns the full salary_change_audit trail for one officer, most-recent first.
     *
     * <pre>
     * GET /api/employment/audit-history?officerId=42&limit=50
     * </pre>
     */
    @GetMapping("/audit-history")
    @Operation(
        summary = "Salary change audit history for an officer",
        description = "Full audit trail from salary_change_audit. Allowed roles: ADMIN, HR"
    )
    public List<Map<String, Object>> auditHistory(
            @Parameter(description = "BIGINT PK of the officer in erp_employee", example = "42")
            @RequestParam @NotNull @Positive Long officerId,

            @Parameter(description = "Max rows to return (capped at 200)", example = "50")
            @RequestParam(defaultValue = "50") @Positive int limit
    ) {
        return salaryAuditService.getOfficerAuditHistory(officerId, limit);
    }

    @PostMapping(value = "/process-annual-increment", produces = MediaType.APPLICATION_JSON_VALUE)
    @Operation(
        summary = "Process annual increment for one officer",
        description = "Calls process_annual_increment() and returns the JSONB response. Allowed roles: ADMIN, HR"
    )
    public ResponseEntity<String> processAnnualIncrement(@Valid @RequestBody AnnualIncrementRequest request) {
        String json = annualIncrementService.processAnnualIncrement(
                request.officerId(),
                request.appraisalId(),
                request.effectiveDate()
        );
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(json);
    }

    @PostMapping("/process-batch-increments")
    @Operation(
        summary = "Process annual increments in batch",
        description = "Calls process_batch_increments(authority_id, year). Allowed roles: ADMIN, HR"
    )
    public List<Map<String, Object>> processBatchIncrements(
            @RequestBody(required = false) BatchIncrementRequest request
    ) {
        if (request == null) {
            return annualIncrementService.processBatchIncrements(null, null);
        }
        return annualIncrementService.processBatchIncrements(request.authorityId(), request.year());
    }
}
