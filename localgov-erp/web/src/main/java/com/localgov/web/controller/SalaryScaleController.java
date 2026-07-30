package com.localgov.web.controller;

import com.localgov.service.SalaryScaleService;
import com.localgov.service.dto.SalaryScaleNotchAmountResponse;
import com.localgov.service.dto.SalaryScaleNotchesResponse;
import com.localgov.service.dto.SalaryScaleOptionResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Positive;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/salary-scales")
@Validated
@Tag(name = "Salary Scales", description = "Salary scale, notch, and official amount lookup endpoints")
public class SalaryScaleController {

    private final SalaryScaleService salaryScaleService;

    public SalaryScaleController(SalaryScaleService salaryScaleService) {
        this.salaryScaleService = salaryScaleService;
    }

    @GetMapping("/active")
    @Operation(summary = "List active salary scales", description = "Allowed roles: ADMIN, HR, PAYROLL")
    public List<SalaryScaleOptionResponse> getActiveScales() {
        return salaryScaleService.getActiveScales();
    }

    @GetMapping("/{salaryScale}/notches")
    @Operation(summary = "Get valid notches for scale", description = "Allowed roles: ADMIN, HR, PAYROLL")
    public SalaryScaleNotchesResponse getScaleNotches(@PathVariable String salaryScale) {
        return salaryScaleService.getScaleNotches(salaryScale);
    }

    @GetMapping("/{salaryScale}/notch/{notchNumber}/amount")
    @Operation(summary = "Get official monthly salary amount", description = "Allowed roles: ADMIN, HR, PAYROLL")
    public SalaryScaleNotchAmountResponse getNotchAmount(
            @PathVariable String salaryScale,
            @PathVariable @Positive Integer notchNumber
    ) {
        return salaryScaleService.getNotchAmount(salaryScale, notchNumber);
    }
}
