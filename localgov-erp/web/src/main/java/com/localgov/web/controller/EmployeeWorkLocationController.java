package com.localgov.web.controller;

import com.localgov.service.EmployeeWorkLocationService;
import com.localgov.service.dto.EmployeeWorkLocationResponse;
import com.localgov.service.dto.EmployeeWorkLocationUpsertRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/employee-work-locations")
@Validated
@Tag(name = "Employee Work Locations", description = "Employee assignment to work location endpoints")
public class EmployeeWorkLocationController {

    private final EmployeeWorkLocationService assignmentService;

    public EmployeeWorkLocationController(EmployeeWorkLocationService assignmentService) {
        this.assignmentService = assignmentService;
    }

    @GetMapping
    @Operation(summary = "List assignments", description = "Filter by employeeId, locationId, and activeOnly.")
    public List<EmployeeWorkLocationResponse> getAssignments(
            @RequestParam(required = false) Long employeeId,
            @RequestParam(required = false) Long locationId,
            @RequestParam(defaultValue = "false") boolean activeOnly,
            @RequestParam(required = false) String authorityCode
    ) {
        return assignmentService.getAssignments(employeeId, locationId, activeOnly, authorityCode);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create assignment", description = "Assign employee to work location.")
    public EmployeeWorkLocationResponse createAssignment(@Valid @RequestBody EmployeeWorkLocationUpsertRequest request) {
        return assignmentService.createAssignment(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update assignment", description = "Update assignment details.")
    public EmployeeWorkLocationResponse updateAssignment(@PathVariable Long id, @Valid @RequestBody EmployeeWorkLocationUpsertRequest request) {
        return assignmentService.updateAssignment(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete assignment", description = "Remove assignment record.")
    public void deleteAssignment(@PathVariable Long id) {
        assignmentService.deleteAssignment(id);
    }
}
