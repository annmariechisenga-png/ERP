package com.localgov.service;

import com.localgov.domain.model.WorkLocationAudit;
import com.localgov.domain.model.WorkLocation;
import com.localgov.domain.model.Employee;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.WorkLocationAuditRepository;
import com.localgov.repository.WorkLocationRepository;
import com.localgov.service.dto.WorkLocationAuditFilterOptionsResponse;
import com.localgov.service.dto.WorkLocationAuditResponse;
import com.localgov.service.dto.WorkLocationBulkImportResponse;
import com.localgov.service.dto.WorkLocationUpsertRequest;
import com.localgov.service.dto.WorkLocationResponse;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.exception.ResourceNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class WorkLocationService {

    private static final List<String> ALLOWED_AUDIT_ACTIONS = List.of("CREATE", "UPDATE", "DELETE", "ACTIVATE", "DEACTIVATE");
    private static final List<String> REQUIRED_BULK_HEADERS = List.of(
            "location_code",
            "location_name",
            "location_type",
            "latitude",
            "longitude",
            "geofence_radius",
            "address",
            "applicable_divisions",
            "department"
    );

    private final WorkLocationRepository workLocationRepository;
    private final WorkLocationAuditRepository workLocationAuditRepository;
    private final EmployeeRepository employeeRepository;

    public WorkLocationService(
            WorkLocationRepository workLocationRepository,
            WorkLocationAuditRepository workLocationAuditRepository,
            EmployeeRepository employeeRepository
    ) {
        this.workLocationRepository = workLocationRepository;
        this.workLocationAuditRepository = workLocationAuditRepository;
        this.employeeRepository = employeeRepository;
    }

    public List<WorkLocationResponse> getWorkLocations(boolean activeOnly, String locationType, String authorityCode) {
        List<WorkLocation> rows;
        String normalizedAuthority = normalizeAuthorityCode(authorityCode);
        boolean hasAuthorityFilter = normalizedAuthority != null && !"ALL".equalsIgnoreCase(normalizedAuthority);

        if (locationType != null && !locationType.isBlank() && hasAuthorityFilter) {
            rows = activeOnly
                    ? workLocationRepository.findByAuthorityCodeIgnoreCaseAndLocationTypeIgnoreCaseAndActiveTrueOrderByLocationNameAsc(normalizedAuthority, locationType)
                    : workLocationRepository.findByAuthorityCodeIgnoreCaseAndLocationTypeIgnoreCaseOrderByLocationNameAsc(normalizedAuthority, locationType);
        } else if (locationType != null && !locationType.isBlank()) {
            rows = activeOnly
                    ? workLocationRepository.findByLocationTypeIgnoreCaseAndActiveTrueOrderByLocationNameAsc(locationType)
                    : workLocationRepository.findByLocationTypeIgnoreCaseOrderByLocationNameAsc(locationType);
        } else if (activeOnly && hasAuthorityFilter) {
            rows = workLocationRepository.findByAuthorityCodeIgnoreCaseAndActiveTrueOrderByLocationTypeAscLocationNameAsc(normalizedAuthority);
        } else if (hasAuthorityFilter) {
            rows = workLocationRepository.findByAuthorityCodeIgnoreCaseOrderByLocationTypeAscLocationNameAsc(normalizedAuthority);
        } else if (activeOnly) {
            rows = workLocationRepository.findByActiveTrueOrderByLocationTypeAscLocationNameAsc();
        } else {
            rows = workLocationRepository.findAll()
                    .stream()
                    .sorted((a, b) -> {
                        int typeCompare = nullSafe(a.getLocationType()).compareToIgnoreCase(nullSafe(b.getLocationType()));
                        if (typeCompare != 0) {
                            return typeCompare;
                        }
                        return nullSafe(a.getLocationName()).compareToIgnoreCase(nullSafe(b.getLocationName()));
                    })
                    .toList();
        }

        return rows.stream()
                .map(this::toResponse)
                .toList();
    }

    public WorkLocationAuditFilterOptionsResponse getWorkLocationAuditFilterOptions(Long locationId) {
        if (!workLocationRepository.existsById(locationId)) {
            throw new ResourceNotFoundException("Work location not found: " + locationId);
        }
        List<String> actions = workLocationAuditRepository.findDistinctActionsByLocationId(locationId);
        LocalDateTime earliest = workLocationAuditRepository.findEarliestPerformedAtByLocationId(locationId).orElse(null);
        LocalDateTime latest = workLocationAuditRepository.findLatestPerformedAtByLocationId(locationId).orElse(null);
        return new WorkLocationAuditFilterOptionsResponse(actions, earliest, latest);
    }

    public List<WorkLocationAuditResponse> getWorkLocationAuditHistory(Long locationId) {
        return getWorkLocationAuditHistoryPage(locationId, 0, 100, null, null, null).getContent();
    }

    public Page<WorkLocationAuditResponse> getWorkLocationAuditHistoryPage(Long locationId, int page, int size) {
        return getWorkLocationAuditHistoryPage(locationId, page, size, null, null, null);
    }

    public Page<WorkLocationAuditResponse> getWorkLocationAuditHistoryPage(
            Long locationId,
            int page,
            int size,
            String action,
            LocalDateTime fromAt,
            LocalDateTime toAt
    ) {
        if (!workLocationRepository.existsById(locationId)) {
            throw new ResourceNotFoundException("Work location not found: " + locationId);
        }

        if (fromAt != null && toAt != null && fromAt.isAfter(toAt)) {
            throw new BusinessValidationException("fromAt cannot be after toAt");
        }

        String normalizedAction = normalizeAuditAction(action);

        int safePage = Math.max(page, 0);
        int safeSize = size <= 0 ? 50 : Math.min(size, 200);
        Pageable pageable = PageRequest.of(safePage, safeSize);

        Page<WorkLocationAudit> rows = workLocationAuditRepository
                .findHistoryByLocationIdWithFilters(locationId, normalizedAction, fromAt, toAt, pageable);

        Map<Long, Employee> employees = employeeRepository.findAllById(
                        rows.getContent().stream().map(WorkLocationAudit::getPerformedBy).distinct().toList())
                .stream()
                .collect(Collectors.toMap(Employee::getId, Function.identity()));

        return rows.map(row -> {
            Employee actor = employees.get(row.getPerformedBy());
            String actorName = null;
            if (actor != null) {
                actorName = (actor.getFirstName() + " " + actor.getLastName()).trim();
            }
            return new WorkLocationAuditResponse(
                    row.getId(),
                    row.getLocationId(),
                    row.getAction(),
                    row.getFieldChanged(),
                    row.getOldValue(),
                    row.getNewValue(),
                    row.getPerformedBy(),
                    actor == null ? null : actor.getEmployeeCode(),
                    actorName,
                    row.getPerformedAt()
            );
        });
    }

    private String normalizeAuditAction(String action) {
        if (action == null || action.isBlank()) {
            return null;
        }
        String normalized = action.trim().toUpperCase(Locale.ROOT);
        if (!ALLOWED_AUDIT_ACTIONS.contains(normalized)) {
            throw new BusinessValidationException("Invalid audit action. Use CREATE, UPDATE, DELETE, ACTIVATE, or DEACTIVATE");
        }
        return normalized;
    }

    public String exportWorkLocationAuditLogCsv(
            Long locationId,
            String action,
            LocalDateTime fromAt,
            LocalDateTime toAt
    ) {
        if (!workLocationRepository.existsById(locationId)) {
            throw new ResourceNotFoundException("Work location not found: " + locationId);
        }

        if (fromAt != null && toAt != null && fromAt.isAfter(toAt)) {
            throw new BusinessValidationException("fromAt cannot be after toAt");
        }

        String normalizedAction = normalizeAuditAction(action);

        Pageable all = Pageable.unpaged();
        Page<WorkLocationAudit> rows = workLocationAuditRepository
                .findHistoryByLocationIdWithFilters(locationId, normalizedAction, fromAt, toAt, all);

        Map<Long, Employee> employees = employeeRepository.findAllById(
                        rows.getContent().stream().map(WorkLocationAudit::getPerformedBy).distinct().toList())
                .stream()
                .collect(Collectors.toMap(Employee::getId, Function.identity()));

        StringBuilder csv = new StringBuilder();
        csv.append("Date & Time,User Code,User Name,Action,Field Changed,Old Value,New Value\r\n");

        java.time.format.DateTimeFormatter fmt =
                java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy HH:mm");

        for (WorkLocationAudit row : rows.getContent()) {
            Employee actor = employees.get(row.getPerformedBy());
            String userCode = actor == null ? "" : nullSafe(actor.getEmployeeCode());
            String userName = actor == null ? "" : (actor.getFirstName() + " " + actor.getLastName()).trim();
            csv.append(csvEscape(row.getPerformedAt() == null ? "" : row.getPerformedAt().format(fmt))).append(',');
            csv.append(csvEscape(userCode)).append(',');
            csv.append(csvEscape(userName)).append(',');
            csv.append(csvEscape(nullSafe(row.getAction()))).append(',');
            csv.append(csvEscape(row.getFieldChanged() == null ? "-" : row.getFieldChanged())).append(',');
            csv.append(csvEscape(row.getOldValue() == null ? "-" : row.getOldValue())).append(',');
            csv.append(csvEscape(row.getNewValue() == null ? "-" : row.getNewValue())).append("\r\n");
        }

        return csv.toString();
    }

    private String csvEscape(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(",") || value.contains("\"") || value.contains("\r") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }

    public String generateBulkImportTemplate() {
        return "location_code,location_name,location_type,latitude,longitude,geofence_radius,address,applicable_divisions,department\r\n"
                + "CEM01,Example Cemetery,cemetery,-15.387526,28.322857,100,Example Road Lusaka,\"['IV']\",Works\r\n"
                + "DPOT01,Example Depot,depot,-15.412345,28.234567,150,Great North Road,\"['II','III','IV']\",Works\r\n"
                + "MKT01,Example Market,market,-15.398765,28.287654,80,Example Street,\"['IV']\",Markets\r\n";
    }

    @Transactional
    public WorkLocationBulkImportResponse bulkImportWorkLocationsCsv(String csvContent, Long performedBy, String authorityCode) {
        if (csvContent == null || csvContent.isBlank()) {
            throw new BusinessValidationException("CSV content is required");
        }

        Long actorId = resolvePerformedBy(performedBy);
        String normalizedAuthority = normalizeAuthorityCodeOrThrow(authorityCode);

        String[] rawLines = csvContent.replace("\r", "").split("\n");
        if (rawLines.length == 0 || rawLines[0].isBlank()) {
            throw new BusinessValidationException("CSV header row is required");
        }

        List<String> header = parseCsvLine(removeBom(rawLines[0]));
        validateBulkHeaders(header);

        int totalRows = 0;
        int importedRows = 0;
        List<String> errors = new ArrayList<>();

        for (int i = 1; i < rawLines.length; i++) {
            String line = rawLines[i];
            if (line == null || line.isBlank()) {
                continue;
            }
            totalRows++;
            int rowNumber = i + 1;

            try {
                WorkLocationUpsertRequest request = mapBulkCsvRow(line, rowNumber, actorId, normalizedAuthority);
                createWorkLocation(request);
                importedRows++;
            } catch (BusinessValidationException ex) {
                errors.add("Row " + rowNumber + ": " + ex.getMessage());
            } catch (RuntimeException ex) {
                errors.add("Row " + rowNumber + ": Invalid data format");
            }
        }

        return new WorkLocationBulkImportResponse(totalRows, importedRows, errors.size(), errors);
    }

    @Transactional
    public WorkLocationResponse createWorkLocation(WorkLocationUpsertRequest request) {
        validateRequest(request, null);
        Long performedBy = resolvePerformedBy(request.performedBy());

        String normalizedCode = request.locationCode().trim().toUpperCase(Locale.ROOT);
        if (workLocationRepository.existsByLocationCodeIgnoreCase(normalizedCode)) {
            throw new BusinessValidationException("Location code already exists: " + normalizedCode);
        }

        WorkLocation row = new WorkLocation();
        applyRequest(row, request, normalizedCode);
        WorkLocation saved = workLocationRepository.save(row);
        writeAudit(saved.getId(), "CREATE", null, null, summarizeLocation(saved), performedBy);
        return toResponse(saved);
    }

    @Transactional
    public WorkLocationResponse updateWorkLocation(Long id, WorkLocationUpsertRequest request) {
        validateRequest(request, id);
        Long performedBy = resolvePerformedBy(request.performedBy());

        WorkLocation row = workLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Work location not found: " + id));
        WorkLocation before = copyOf(row);

        String normalizedCode = request.locationCode().trim().toUpperCase(Locale.ROOT);
        workLocationRepository.findByLocationCodeIgnoreCase(normalizedCode)
                .ifPresent(existing -> {
                    if (!existing.getId().equals(id)) {
                        throw new BusinessValidationException("Location code already exists: " + normalizedCode);
                    }
                });

        applyRequest(row, request, normalizedCode);
        WorkLocation saved = workLocationRepository.save(row);
        auditChanges(before, saved, performedBy);
        return toResponse(saved);
    }

    @Transactional
    public void deleteWorkLocation(Long id, boolean hardDelete, Long performedBy) {
        Long actorId = resolvePerformedBy(performedBy);
        WorkLocation row = workLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Work location not found: " + id));

        if (!hardDelete) {
            Boolean wasActive = row.getActive();
            row.setActive(false);
            workLocationRepository.save(row);
            if (Boolean.TRUE.equals(wasActive)) {
                writeAudit(row.getId(), "DEACTIVATE", "active", "true", "false", actorId);
            }
            return;
        }

        long primaryAssignments = workLocationRepository.countEmployeePrimaryAssignments(id);
        long locationAssignments = workLocationRepository.countEmployeeLocationAssignments(id);
        if (primaryAssignments > 0 || locationAssignments > 0) {
            throw new BusinessValidationException(
                    "Cannot hard delete location with existing employee assignments. Deactivate it instead."
            );
        }

        writeAudit(row.getId(), "DELETE", null, summarizeLocation(row), null, actorId);
        workLocationRepository.delete(row);
    }

    private void auditChanges(WorkLocation before, WorkLocation after, Long performedBy) {
        auditChange(after.getId(), "locationCode", before.getLocationCode(), after.getLocationCode(), performedBy);
        auditChange(after.getId(), "locationName", before.getLocationName(), after.getLocationName(), performedBy);
        auditChange(after.getId(), "locationType", before.getLocationType(), after.getLocationType(), performedBy);
        auditChange(after.getId(), "authorityCode", before.getAuthorityCode(), after.getAuthorityCode(), performedBy);
        auditChange(after.getId(), "departmentName", before.getDepartmentName(), after.getDepartmentName(), performedBy);
        auditChange(after.getId(), "latitude", before.getLatitude(), after.getLatitude(), performedBy);
        auditChange(after.getId(), "longitude", before.getLongitude(), after.getLongitude(), performedBy);
        auditChange(after.getId(), "geofenceRadiusMeters", before.getGeofenceRadiusMeters(), after.getGeofenceRadiusMeters(), performedBy);
        auditChange(after.getId(), "address", before.getAddress(), after.getAddress(), performedBy);
        auditChange(after.getId(), "opensAt", before.getOpensAt(), after.getOpensAt(), performedBy);
        auditChange(after.getId(), "closesAt", before.getClosesAt(), after.getClosesAt(), performedBy);
        auditChange(after.getId(), "primary", before.getPrimary(), after.getPrimary(), performedBy);
        auditChange(after.getId(), "applicableDivisions", before.getApplicableDivisions(), after.getApplicableDivisions(), performedBy);
        auditChange(after.getId(), "applicableRoleCategories", before.getApplicableRoleCategories(), after.getApplicableRoleCategories(), performedBy);

        if (!Objects.equals(before.getActive(), after.getActive())) {
            String action = Boolean.TRUE.equals(after.getActive()) ? "ACTIVATE" : "DEACTIVATE";
            writeAudit(after.getId(), action, "active", stringify(before.getActive()), stringify(after.getActive()), performedBy);
        }
    }

    private void auditChange(Long locationId, String field, Object before, Object after, Long performedBy) {
        if (Objects.equals(before, after)) {
            return;
        }
        writeAudit(locationId, "UPDATE", field, stringify(before), stringify(after), performedBy);
    }

    private void writeAudit(Long locationId, String action, String fieldChanged, String oldValue, String newValue, Long performedBy) {
        WorkLocationAudit audit = new WorkLocationAudit();
        audit.setLocationId(locationId);
        audit.setAction(action);
        audit.setFieldChanged(fieldChanged);
        audit.setOldValue(oldValue);
        audit.setNewValue(newValue);
        audit.setPerformedBy(performedBy);
        workLocationAuditRepository.save(audit);
    }

    private Long resolvePerformedBy(Long performedBy) {
        if (performedBy == null) {
            throw new BusinessValidationException("performedBy is required for work location audit");
        }
        if (!employeeRepository.existsById(performedBy)) {
            throw new BusinessValidationException("performedBy employee not found: " + performedBy);
        }
        return performedBy;
    }

    private WorkLocation copyOf(WorkLocation source) {
        WorkLocation copy = new WorkLocation();
        copy.setId(source.getId());
        copy.setLocationCode(source.getLocationCode());
        copy.setLocationName(source.getLocationName());
        copy.setLocationType(source.getLocationType());
        copy.setAuthorityCode(source.getAuthorityCode());
        copy.setDepartmentName(source.getDepartmentName());
        copy.setLatitude(source.getLatitude());
        copy.setLongitude(source.getLongitude());
        copy.setGeofenceRadiusMeters(source.getGeofenceRadiusMeters());
        copy.setAddress(source.getAddress());
        copy.setOpensAt(source.getOpensAt());
        copy.setClosesAt(source.getClosesAt());
        copy.setActive(source.getActive());
        copy.setPrimary(source.getPrimary());
        copy.setApplicableDivisions(source.getApplicableDivisions() == null ? null : new ArrayList<>(source.getApplicableDivisions()));
        copy.setApplicableRoleCategories(source.getApplicableRoleCategories() == null ? null : new ArrayList<>(source.getApplicableRoleCategories()));
        return copy;
    }

    private String stringify(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof BigDecimal decimal) {
            return decimal.stripTrailingZeros().toPlainString();
        }
        return String.valueOf(value);
    }

    private String summarizeLocation(WorkLocation row) {
        return "code=" + nullSafe(row.getLocationCode()) + ", name=" + nullSafe(row.getLocationName())
                + ", type=" + nullSafe(row.getLocationType()) + ", authority=" + nullSafe(row.getAuthorityCode());
    }

    private WorkLocationResponse toResponse(WorkLocation row) {
        return new WorkLocationResponse(
                row.getId(),
                row.getLocationCode(),
                row.getLocationName(),
                row.getLocationType(),
                row.getAuthorityCode(),
                row.getDepartmentName(),
                row.getLatitude(),
                row.getLongitude(),
                row.getGeofenceRadiusMeters(),
                row.getAddress(),
                row.getOpensAt(),
                row.getClosesAt(),
                row.getActive(),
                row.getPrimary(),
                row.getApplicableDivisions(),
                row.getApplicableRoleCategories()
        );
    }

    private WorkLocationUpsertRequest mapBulkCsvRow(String line, int rowNumber, Long performedBy, String authorityCode) {
        List<String> columns = parseCsvLine(line);
        if (columns.size() != REQUIRED_BULK_HEADERS.size()) {
            throw new BusinessValidationException(
                    "Expected " + REQUIRED_BULK_HEADERS.size() + " columns but found " + columns.size());
        }

        BigDecimal latitude = parseDecimal(columns.get(3), "latitude");
        BigDecimal longitude = parseDecimal(columns.get(4), "longitude");
        Integer geofenceRadius = parseInteger(columns.get(5), "geofence_radius");

        return new WorkLocationUpsertRequest(
                columns.get(0),
                columns.get(1),
                columns.get(2),
                authorityCode,
                performedBy,
                trimToNull(columns.get(8)),
                latitude,
                longitude,
                geofenceRadius,
                trimToNull(columns.get(6)),
                null,
                null,
                true,
                false,
                parseApplicableDivisions(columns.get(7), rowNumber),
                null
        );
    }

    private void validateBulkHeaders(List<String> headerColumns) {
        if (headerColumns.size() != REQUIRED_BULK_HEADERS.size()) {
            throw new BusinessValidationException("CSV header does not match required import format");
        }

        for (int i = 0; i < REQUIRED_BULK_HEADERS.size(); i++) {
            String actual = headerColumns.get(i) == null ? "" : headerColumns.get(i).trim().toLowerCase(Locale.ROOT);
            if (!REQUIRED_BULK_HEADERS.get(i).equals(actual)) {
                throw new BusinessValidationException(
                        "CSV header mismatch at column " + (i + 1) + ". Expected '" + REQUIRED_BULK_HEADERS.get(i) + "'");
            }
        }
    }

    private List<String> parseCsvLine(String line) {
        List<String> result = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean inQuotes = false;

        for (int i = 0; i < line.length(); i++) {
            char ch = line.charAt(i);
            if (ch == '"') {
                if (inQuotes && i + 1 < line.length() && line.charAt(i + 1) == '"') {
                    current.append('"');
                    i++;
                } else {
                    inQuotes = !inQuotes;
                }
            } else if (ch == ',' && !inQuotes) {
                result.add(current.toString().trim());
                current.setLength(0);
            } else {
                current.append(ch);
            }
        }
        result.add(current.toString().trim());

        return result;
    }

    private List<String> parseApplicableDivisions(String rawValue, int rowNumber) {
        String value = trimToNull(rawValue);
        if (value == null) {
            return null;
        }

        if (!value.startsWith("[") || !value.endsWith("]")) {
            throw new BusinessValidationException("Invalid applicable_divisions format at row " + rowNumber + ". Use ['II','III']");
        }

        String inner = value.substring(1, value.length() - 1).trim();
        if (inner.isEmpty()) {
            return null;
        }

        String[] tokens = inner.split(",");
        List<String> divisions = new ArrayList<>();
        for (String token : tokens) {
            String cleaned = stripWrappingQuotes(token.trim());
            if (cleaned != null && !cleaned.isBlank()) {
                divisions.add(cleaned.trim());
            }
        }
        return divisions.isEmpty() ? null : divisions;
    }

    private BigDecimal parseDecimal(String raw, String fieldName) {
        String value = trimToNull(raw);
        if (value == null) {
            throw new BusinessValidationException(fieldName + " is required");
        }
        try {
            return new BigDecimal(value);
        } catch (NumberFormatException ex) {
            throw new BusinessValidationException("Invalid " + fieldName + " value: " + value);
        }
    }

    private Integer parseInteger(String raw, String fieldName) {
        String value = trimToNull(raw);
        if (value == null) {
            throw new BusinessValidationException(fieldName + " is required");
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException ex) {
            throw new BusinessValidationException("Invalid " + fieldName + " value: " + value);
        }
    }

    private String removeBom(String value) {
        if (value != null && !value.isEmpty() && value.charAt(0) == '\uFEFF') {
            return value.substring(1);
        }
        return value;
    }

    private String stripWrappingQuotes(String value) {
        if (value == null || value.length() < 2) {
            return value;
        }
        if ((value.startsWith("\"") && value.endsWith("\"")) || (value.startsWith("'") && value.endsWith("'"))) {
            return value.substring(1, value.length() - 1);
        }
        return value;
    }

    private void validateRequest(WorkLocationUpsertRequest request, Long id) {
        if (request == null) {
            throw new BusinessValidationException("Request payload is required");
        }
        if (isBlank(request.locationCode())) {
            throw new BusinessValidationException("Location code is required");
        }
        if (isBlank(request.locationName())) {
            throw new BusinessValidationException("Location name is required");
        }
        if (isBlank(request.locationType())) {
            throw new BusinessValidationException("Location type is required");
        }
        if (isBlank(request.authorityCode())) {
            throw new BusinessValidationException("Authority code is required");
        }
        if (request.latitude() == null || request.longitude() == null) {
            throw new BusinessValidationException("Latitude and longitude are required");
        }
        if (request.geofenceRadiusMeters() != null && request.geofenceRadiusMeters() < 10) {
            throw new BusinessValidationException("Geofence radius must be at least 10 meters");
        }
    }

    private void applyRequest(WorkLocation row, WorkLocationUpsertRequest request, String normalizedCode) {
        row.setLocationCode(normalizedCode);
        row.setLocationName(request.locationName().trim());
        row.setLocationType(request.locationType().trim().toLowerCase(Locale.ROOT));
        row.setAuthorityCode(normalizeAuthorityCodeOrThrow(request.authorityCode()));
        row.setDepartmentName(trimToNull(request.departmentName()));
        row.setLatitude(request.latitude());
        row.setLongitude(request.longitude());
        row.setGeofenceRadiusMeters(request.geofenceRadiusMeters() == null ? 100 : request.geofenceRadiusMeters());
        row.setAddress(trimToNull(request.address()));
        row.setOpensAt(request.opensAt());
        row.setClosesAt(request.closesAt());
        row.setActive(request.active() == null || request.active());
        row.setPrimary(request.primary() != null && request.primary());
        row.setApplicableDivisions(normalizeList(request.applicableDivisions()));
        row.setApplicableRoleCategories(normalizeList(request.applicableRoleCategories()));
    }

    private List<String> normalizeList(List<String> values) {
        if (values == null || values.isEmpty()) {
            return null;
        }
        List<String> cleaned = new ArrayList<>();
        for (String value : values) {
            String normalized = trimToNull(value);
            if (normalized != null) {
                cleaned.add(normalized);
            }
        }
        return cleaned.isEmpty() ? null : cleaned;
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeAuthorityCode(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim().toUpperCase(Locale.ROOT);
    }

    private String normalizeAuthorityCodeOrThrow(String value) {
        String normalized = normalizeAuthorityCode(value);
        if (normalized == null) {
            throw new BusinessValidationException("Authority code is required");
        }
        if ("ALL".equals(normalized)) {
            return normalized;
        }
        if (!normalized.matches("LA\\d{3}")) {
            throw new BusinessValidationException("Invalid authority code. Use ALL or LA001-LA116");
        }
        int valueNumber = Integer.parseInt(normalized.substring(2));
        if (valueNumber < 1 || valueNumber > 116) {
            throw new BusinessValidationException("Invalid authority code. Use ALL or LA001-LA116");
        }
        return normalized;
    }

    private String nullSafe(String value) {
        return value == null ? "" : value;
    }
}
