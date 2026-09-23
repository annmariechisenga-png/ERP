package com.localgov.service;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.EmployeeWorkLocation;
import com.localgov.domain.model.WorkLocation;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.EmployeeWorkLocationRepository;
import com.localgov.repository.WorkLocationRepository;
import com.localgov.service.dto.EmployeeWorkLocationResponse;
import com.localgov.service.dto.EmployeeWorkLocationUpsertRequest;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class EmployeeWorkLocationService {

    private static final List<String> ALLOWED_ASSIGNMENT_TYPES = List.of("permanent", "temporary", "rotational");

    private final EmployeeWorkLocationRepository assignmentRepository;
    private final EmployeeRepository employeeRepository;
    private final WorkLocationRepository workLocationRepository;

    public EmployeeWorkLocationService(
            EmployeeWorkLocationRepository assignmentRepository,
            EmployeeRepository employeeRepository,
            WorkLocationRepository workLocationRepository
    ) {
        this.assignmentRepository = assignmentRepository;
        this.employeeRepository = employeeRepository;
        this.workLocationRepository = workLocationRepository;
    }

    public List<EmployeeWorkLocationResponse> getAssignments(Long employeeId, Long locationId, boolean activeOnly, String authorityCode) {
        List<EmployeeWorkLocation> rows;
        String normalizedAuthority = normalizeAuthorityCode(authorityCode);
        boolean hasAuthorityFilter = normalizedAuthority != null && !"ALL".equalsIgnoreCase(normalizedAuthority);

        if (employeeId != null && hasAuthorityFilter) {
            rows = assignmentRepository.findByEmployeeIdAndAuthorityCodeIgnoreCaseOrderByEffectiveFromDesc(employeeId, normalizedAuthority);
        } else if (employeeId != null) {
            rows = assignmentRepository.findByEmployeeIdOrderByEffectiveFromDesc(employeeId);
        } else if (locationId != null) {
            rows = assignmentRepository.findByLocationIdOrderByEffectiveFromDesc(locationId);
            if (hasAuthorityFilter) {
                rows = rows.stream()
                        .filter(x -> normalizedAuthority.equalsIgnoreCase(x.getAuthorityCode()))
                        .toList();
            }
        } else if (hasAuthorityFilter) {
            rows = assignmentRepository.findByAuthorityCodeIgnoreCaseOrderByEmployeeIdAscEffectiveFromDesc(normalizedAuthority);
        } else {
            rows = assignmentRepository.findAll().stream()
                    .sorted((a, b) -> {
                        int employeeCompare = Long.compare(a.getEmployeeId(), b.getEmployeeId());
                        if (employeeCompare != 0) {
                            return employeeCompare;
                        }
                        return b.getEffectiveFrom().compareTo(a.getEffectiveFrom());
                    })
                    .toList();
        }

        if (activeOnly) {
            LocalDate today = LocalDate.now();
            rows = rows.stream()
                    .filter(x -> !x.getEffectiveFrom().isAfter(today))
                    .filter(x -> x.getEffectiveTo() == null || !x.getEffectiveTo().isBefore(today))
                    .toList();
        }

        return mapResponses(rows);
    }

    @Transactional
    public EmployeeWorkLocationResponse createAssignment(EmployeeWorkLocationUpsertRequest request) {
        WorkLocation location = validateRequest(request, null);

        if (assignmentRepository.existsByEmployeeIdAndLocationIdAndEffectiveFrom(
                request.employeeId(), request.locationId(), request.effectiveFrom())) {
            throw new BusinessValidationException("Assignment already exists for employee, location, and effective_from date");
        }

        EmployeeWorkLocation row = new EmployeeWorkLocation();
        applyRequest(row, request, location);
        EmployeeWorkLocation saved = assignmentRepository.save(row);
        return mapResponses(List.of(saved)).getFirst();
    }

    @Transactional
    public EmployeeWorkLocationResponse updateAssignment(Long id, EmployeeWorkLocationUpsertRequest request) {
        WorkLocation location = validateRequest(request, id);

        EmployeeWorkLocation row = assignmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found: " + id));

        if (!(row.getEmployeeId().equals(request.employeeId())
                && row.getLocationId().equals(request.locationId())
                && row.getEffectiveFrom().equals(request.effectiveFrom()))
                && assignmentRepository.existsByEmployeeIdAndLocationIdAndEffectiveFrom(
                request.employeeId(), request.locationId(), request.effectiveFrom())) {
            throw new BusinessValidationException("Assignment already exists for employee, location, and effective_from date");
        }

        applyRequest(row, request, location);
        EmployeeWorkLocation saved = assignmentRepository.save(row);
        return mapResponses(List.of(saved)).getFirst();
    }

    @Transactional
    public void deleteAssignment(Long id) {
        if (!assignmentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Assignment not found: " + id);
        }
        assignmentRepository.deleteById(id);
    }

    private WorkLocation validateRequest(EmployeeWorkLocationUpsertRequest request, Long id) {
        if (request == null) {
            throw new BusinessValidationException("Request payload is required");
        }

        if (!employeeRepository.existsById(request.employeeId())) {
            throw new BusinessValidationException("Employee not found: " + request.employeeId());
        }

        WorkLocation location = workLocationRepository.findById(request.locationId())
                .orElseThrow(() -> new BusinessValidationException("Work location not found: " + request.locationId()));

        String authority = normalizeAuthorityCodeOrThrow(request.authorityCode());
        String locationAuthority = normalizeAuthorityCode(location.getAuthorityCode());
        if (locationAuthority == null) {
            throw new BusinessValidationException("Work location authority code is missing");
        }
        if (!authority.equals(locationAuthority)) {
            throw new BusinessValidationException("Assignment authority code must match the selected work location authority code");
        }

        if (request.createdBy() != null && !employeeRepository.existsById(request.createdBy())) {
            throw new BusinessValidationException("createdBy employee not found: " + request.createdBy());
        }

        String assignmentType = normalizeAssignmentType(request.assignmentType());
        if (!ALLOWED_ASSIGNMENT_TYPES.contains(assignmentType)) {
            throw new BusinessValidationException("Invalid assignment type: " + request.assignmentType());
        }

        if (request.effectiveTo() != null && request.effectiveTo().isBefore(request.effectiveFrom())) {
            throw new BusinessValidationException("effectiveTo cannot be before effectiveFrom");
        }

        validatePrimaryOverlap(request, id, authority);
        return location;
    }

    private void applyRequest(EmployeeWorkLocation row, EmployeeWorkLocationUpsertRequest request, WorkLocation location) {
        row.setEmployeeId(request.employeeId());
        row.setLocationId(request.locationId());
        row.setAuthorityCode(normalizeAuthorityCode(location.getAuthorityCode()));
        row.setPrimary(request.primary() != null && request.primary());
        row.setAssignmentType(normalizeAssignmentType(request.assignmentType()));
        row.setEffectiveFrom(request.effectiveFrom());
        row.setEffectiveTo(request.effectiveTo());
        row.setCreatedBy(request.createdBy());
    }

    private String normalizeAssignmentType(String value) {
        if (value == null || value.isBlank()) {
            return "permanent";
        }
        return value.trim().toLowerCase(Locale.ROOT);
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

    private void validatePrimaryOverlap(EmployeeWorkLocationUpsertRequest request, Long currentId, String authorityCode) {
        if (request.primary() == null || !request.primary()) {
            return;
        }

        List<EmployeeWorkLocation> scopedAssignments = assignmentRepository
                .findByEmployeeIdAndAuthorityCodeIgnoreCaseOrderByEffectiveFromDesc(request.employeeId(), authorityCode);

        LocalDate requestTo = request.effectiveTo() == null ? LocalDate.of(9999, 12, 31) : request.effectiveTo();

        boolean overlapExists = scopedAssignments.stream()
                .filter(EmployeeWorkLocation::getPrimary)
                .filter(existing -> currentId == null || !existing.getId().equals(currentId))
                .anyMatch(existing -> {
                    LocalDate existingTo = existing.getEffectiveTo() == null ? LocalDate.of(9999, 12, 31) : existing.getEffectiveTo();
                    return !request.effectiveFrom().isAfter(existingTo) && !existing.getEffectiveFrom().isAfter(requestTo);
                });

        if (overlapExists) {
            throw new BusinessValidationException("Employee already has an overlapping primary assignment for this authority");
        }
    }

    private List<EmployeeWorkLocationResponse> mapResponses(List<EmployeeWorkLocation> rows) {
        Map<Long, Employee> employees = employeeRepository.findAllById(
                        rows.stream().map(EmployeeWorkLocation::getEmployeeId).distinct().toList())
                .stream()
                .collect(Collectors.toMap(Employee::getId, Function.identity()));

        Map<Long, WorkLocation> locations = workLocationRepository.findAllById(
                        rows.stream().map(EmployeeWorkLocation::getLocationId).distinct().toList())
                .stream()
                .collect(Collectors.toMap(WorkLocation::getId, Function.identity()));

        return rows.stream().map(row -> {
            Employee employee = employees.get(row.getEmployeeId());
            WorkLocation location = locations.get(row.getLocationId());

            return new EmployeeWorkLocationResponse(
                    row.getId(),
                    row.getEmployeeId(),
                    employee == null ? null : employee.getEmployeeCode(),
                    employee == null ? null : (employee.getFirstName() + " " + employee.getLastName()).trim(),
                    row.getLocationId(),
                    location == null ? null : location.getLocationCode(),
                    location == null ? null : location.getLocationName(),
                    row.getAuthorityCode(),
                    row.getPrimary(),
                    row.getAssignmentType(),
                    row.getEffectiveFrom(),
                    row.getEffectiveTo(),
                    row.getCreatedBy(),
                    row.getCreatedAt()
            );
        }).toList();
    }
}
