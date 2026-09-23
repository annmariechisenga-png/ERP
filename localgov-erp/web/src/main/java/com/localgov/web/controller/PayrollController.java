package com.localgov.web.controller;

import com.localgov.service.PayrollService;
import com.localgov.service.dto.PayrollCalculationRequest;
import com.localgov.service.dto.PayrollRecordResponse;
import com.localgov.web.dashboard.DashboardIdentityService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/payroll")
@Validated
@Tag(name = "Payroll", description = "Payroll calculation and history endpoints")
public class PayrollController {

    private final PayrollService payrollService;
    private final DashboardIdentityService dashboardIdentityService;

    public PayrollController(PayrollService payrollService, DashboardIdentityService dashboardIdentityService) {
        this.payrollService = payrollService;
        this.dashboardIdentityService = dashboardIdentityService;
    }

    @PostMapping("/calculate")
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Calculate payroll", description = "Allowed roles: ADMIN, PAYROLL")
    public PayrollRecordResponse calculatePayroll(@Valid @RequestBody PayrollCalculationRequest request) {
        return payrollService.calculatePayroll(request);
    }

    @GetMapping("/me")
    @Operation(summary = "Get current user's payslip history", description = "Allowed roles: ADMIN, HR, PAYROLL, EMPLOYEE")
    public List<PayrollRecordResponse> getMyPayrollHistory(Authentication authentication) {
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authentication is required to view payslips.");
        }

        var identity = dashboardIdentityService.resolveIdentity(authentication.getName());
        if (identity == null || identity.employeeId() == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "No employee profile is linked to this account.");
        }

        return payrollService.getEmployeePayrollHistory(identity.employeeId());
    }

    @GetMapping("/employee/{employeeId}")
    @Operation(summary = "Get employee payroll history", description = "Allowed roles: ADMIN, PAYROLL")
    public List<PayrollRecordResponse> getPayrollHistory(@PathVariable @Positive Long employeeId) {
        return payrollService.getEmployeePayrollHistory(employeeId);
    }
}
