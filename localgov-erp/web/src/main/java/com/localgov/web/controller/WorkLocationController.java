package com.localgov.web.controller;

import com.localgov.service.WorkLocationService;
import com.localgov.service.dto.WorkLocationAuditFilterOptionsResponse;
import com.localgov.service.dto.WorkLocationAuditResponse;
import com.localgov.service.dto.WorkLocationBulkImportResponse;
import com.localgov.service.dto.WorkLocationResponse;
import com.localgov.service.dto.WorkLocationUpsertRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/work-locations")
@Tag(name = "Work Locations", description = "Employee and operational work location lookup endpoints")
public class WorkLocationController {

    private final WorkLocationService workLocationService;

    public WorkLocationController(WorkLocationService workLocationService) {
        this.workLocationService = workLocationService;
    }

    @GetMapping
    @Operation(summary = "List work locations", description = "Allowed for authenticated users. Supports active-only and location type filtering.")
    public List<WorkLocationResponse> getWorkLocations(
            @RequestParam(defaultValue = "true") boolean activeOnly,
            @RequestParam(required = false) String locationType,
            @RequestParam(required = false) String authorityCode
    ) {
        return workLocationService.getWorkLocations(activeOnly, locationType, authorityCode);
    }

    @GetMapping("/{id}/audit/filter-options")
    @Operation(summary = "Get audit log filter options", description = "Returns distinct action types present in the audit log and the earliest/latest entry timestamps, for populating the filter panel.")
    public WorkLocationAuditFilterOptionsResponse getWorkLocationAuditFilterOptions(@PathVariable Long id) {
        return workLocationService.getWorkLocationAuditFilterOptions(id);
    }

    @GetMapping("/{id}/audit")
    @Operation(summary = "Get work location audit history", description = "Returns paginated audit history entries for a work location in reverse chronological order. Optional filters: action, fromAt, toAt.")
    public Page<WorkLocationAuditResponse> getWorkLocationAuditHistory(
            @PathVariable Long id,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size,
            @RequestParam(required = false) String action,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fromAt,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime toAt
    ) {
        return workLocationService.getWorkLocationAuditHistoryPage(id, page, size, action, fromAt, toAt);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create work location", description = "Creates a new work location record.")
    public WorkLocationResponse createWorkLocation(@RequestBody WorkLocationUpsertRequest request) {
        return workLocationService.createWorkLocation(request);
    }

    @GetMapping("/{id}/audit/export")
    @Operation(summary = "Export work location audit log as CSV", description = "Downloads the full audit log for a location as a CSV file. Supports the same action/date filters as the paged audit endpoint.")
    public ResponseEntity<byte[]> exportWorkLocationAuditLog(
            @PathVariable Long id,
            @RequestParam(required = false) String action,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fromAt,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime toAt
    ) {
        String csv = workLocationService.exportWorkLocationAuditLogCsv(id, action, fromAt, toAt);
        byte[] bytes = csv.getBytes(StandardCharsets.UTF_8);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv; charset=UTF-8"));
        headers.setContentDisposition(
                ContentDisposition.attachment().filename("audit_log_location_" + id + ".csv").build());
        headers.setContentLength(bytes.length);
        return new ResponseEntity<>(bytes, headers, HttpStatus.OK);
    }

    @GetMapping("/bulk-import/template")
    @Operation(summary = "Download bulk import CSV template", description = "Returns a ready-to-fill CSV template with the correct headers and example rows.")
    public ResponseEntity<byte[]> downloadBulkImportTemplate() {
        String csv = workLocationService.generateBulkImportTemplate();
        byte[] bytes = csv.getBytes(StandardCharsets.UTF_8);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv; charset=UTF-8"));
        headers.setContentDisposition(
                ContentDisposition.attachment().filename("work_locations_import_template.csv").build());
        headers.setContentLength(bytes.length);
        return new ResponseEntity<>(bytes, headers, HttpStatus.OK);
    }

    @PostMapping(value = "/bulk-import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Bulk import work locations from CSV", description = "Imports work locations from a CSV file with headers: location_code,location_name,location_type,latitude,longitude,geofence_radius,address,applicable_divisions,department")
    public WorkLocationBulkImportResponse bulkImportWorkLocations(
            @RequestParam("file") MultipartFile file,
            @RequestParam Long performedBy,
            @RequestParam String authorityCode
    ) throws java.io.IOException {
        String csvContent = new String(file.getBytes(), java.nio.charset.StandardCharsets.UTF_8);
        return workLocationService.bulkImportWorkLocationsCsv(csvContent, performedBy, authorityCode);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update work location", description = "Updates an existing work location record.")
    public WorkLocationResponse updateWorkLocation(@PathVariable Long id, @RequestBody WorkLocationUpsertRequest request) {
        return workLocationService.updateWorkLocation(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Deactivate or delete work location", description = "Soft-deletes by default (set active=false). Use hardDelete=true to physically delete when unreferenced. performedBy is required for audit.")
    public void deleteWorkLocation(
            @PathVariable Long id,
            @RequestParam(defaultValue = "false") boolean hardDelete,
            @RequestParam Long performedBy
    ) {
        workLocationService.deleteWorkLocation(id, hardDelete, performedBy);
    }
}
