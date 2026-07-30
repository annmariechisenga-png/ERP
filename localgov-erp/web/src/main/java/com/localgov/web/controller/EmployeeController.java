package com.localgov.web.controller;

import com.localgov.service.EmployeeService;
import com.localgov.service.dto.EmployeeResponse;
import com.localgov.service.dto.EmployeeUpsertRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/employees")
@Validated
@Tag(name = "Employees", description = "Employee management endpoints")
public class EmployeeController {

    private final EmployeeService employeeService;

    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping
    @Operation(summary = "List employees", description = "Allowed roles: ADMIN, HR")
    public List<EmployeeResponse> getAllEmployees() {
        return employeeService.getAllEmployees();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get employee by ID", description = "Allowed roles: ADMIN, HR")
    public EmployeeResponse getEmployeeById(@PathVariable @Positive Long id) {
        return employeeService.getEmployeeById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create employee", description = "Allowed roles: ADMIN, HR")
    public EmployeeResponse createEmployee(@Valid @RequestBody EmployeeUpsertRequest request) {
        return employeeService.createEmployee(request);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update employee", description = "Allowed roles: ADMIN, HR")
    public EmployeeResponse updateEmployee(@PathVariable @Positive Long id, @Valid @RequestBody EmployeeUpsertRequest request) {
        return employeeService.updateEmployee(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @Operation(summary = "Delete employee", description = "Allowed roles: ADMIN, HR")
    public void deleteEmployee(@PathVariable @Positive Long id) {
        employeeService.deleteEmployee(id);
    }
}
