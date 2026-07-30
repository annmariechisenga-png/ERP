package com.localgov.web.controller;

import com.localgov.service.exception.ResourceNotFoundException;
import com.localgov.web.reporting.ReportJobService;
import com.localgov.web.reporting.ReportingService;
import com.localgov.web.reporting.dto.ReportJobCreateRequest;
import com.localgov.web.reporting.dto.ReportJobResponse;
import com.localgov.web.reporting.dto.ViewReportResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/reports")
@Validated
@Tag(name = "Reporting", description = "Reporting from existing database views")
public class ReportingController {

    private final ReportingService reportingService;
    private final ReportJobService reportJobService;

    public ReportingController(ReportingService reportingService, ReportJobService reportJobService) {
        this.reportingService = reportingService;
        this.reportJobService = reportJobService;
    }

    @GetMapping("/views")
    @Operation(summary = "List available SQL views", description = "Allowed roles: ADMIN, HR, HEAD, FINANCE, PAYROLL")
    public List<String> getViews() {
        return reportingService.getAvailableViews();
    }

    @GetMapping("/views/{viewName}")
    @Operation(summary = "Read rows from a SQL view", description = "Allowed roles: ADMIN, HR, HEAD, FINANCE, PAYROLL")
        @ApiResponses({
            @ApiResponse(
                responseCode = "200",
                description = "View report rows",
                content = @Content(
                    mediaType = "application/json",
                    examples = @ExampleObject(
                        name = "ViewReportResponseExample",
                        value = """
                            {
                              "viewName": "eng_summary_by_council",
                              "offset": 0,
                              "limit": 5,
                              "returnedRows": 1,
                              "totalRows": 1,
                              "rows": [
                            {
                              "department": "Finance",
                              "employee_count": 2,
                              "average_salary": 3250.00,
                              "min_salary": 2500.00,
                              "max_salary": 4000.00
                            }
                              ]
                            }
                            """
                    )
                )
            ),
            @ApiResponse(responseCode = "400", description = "Invalid or unknown view name")
        })
    public ViewReportResponse readView(
            @PathVariable String viewName,
            @RequestParam(defaultValue = "0") @Min(0) Integer offset,
            @RequestParam(defaultValue = "100") @Min(1) @Max(5000) Integer limit
    ) {
        return reportingService.readView(viewName, offset, limit);
    }

    @PostMapping("/jobs/views")
    @ResponseStatus(HttpStatus.ACCEPTED)
        @Operation(
            summary = "Submit async view report job",
            description = "Allowed roles: ADMIN, HR, HEAD, FINANCE, PAYROLL",
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                required = true,
                content = @Content(
                    mediaType = "application/json",
                    examples = @ExampleObject(
                        name = "ReportJobCreateRequestExample",
                        value = """
                            {
                              "viewName": "eng_summary_by_council",
                              "offset": 0,
                              "limit": 10
                            }
                            """
                    )
                )
            )
        )
        @ApiResponses({
            @ApiResponse(
                responseCode = "202",
                description = "Job accepted",
                content = @Content(
                    mediaType = "application/json",
                    examples = @ExampleObject(
                        name = "ReportJobSubmittedExample",
                        value = """
                            {
                              "jobId": "05a1e9cf-4791-4de9-80a8-43c8896769a4",
                              "status": "SUBMITTED",
                              "viewName": "eng_summary_by_council",
                              "offset": 0,
                              "limit": 10,
                              "submittedAt": "2026-03-09T22:34:25.008629",
                              "startedAt": null,
                              "completedAt": null,
                              "error": null,
                              "result": null
                            }
                            """
                    )
                )
            )
        })
    public ReportJobResponse submitViewJob(@Valid @RequestBody ReportJobCreateRequest request) {
        return reportJobService.submitViewJob(request.viewName(), request.offset(), request.limit());
    }

    @GetMapping("/jobs/{jobId}")
    @Operation(summary = "Get async report job status", description = "Allowed roles: ADMIN, HR, HEAD, FINANCE, PAYROLL")
        @ApiResponses({
            @ApiResponse(
                responseCode = "200",
                description = "Job status",
                content = @Content(
                    mediaType = "application/json",
                    examples = {
                        @ExampleObject(
                            name = "ReportJobCompletedExample",
                            value = """
                                {
                                  "jobId": "05a1e9cf-4791-4de9-80a8-43c8896769a4",
                                  "status": "COMPLETED",
                                  "viewName": "eng_summary_by_council",
                                  "offset": 0,
                                  "limit": 10,
                                  "submittedAt": "2026-03-09T22:34:25.008629",
                                  "startedAt": "2026-03-09T22:34:25.010361",
                                  "completedAt": "2026-03-09T22:34:25.033095",
                                  "error": null,
                                  "result": {
                                "viewName": "eng_summary_by_council",
                                "offset": 0,
                                "limit": 10,
                                "returnedRows": 1,
                                "totalRows": 1,
                                "rows": [
                                  {
                                    "department": "Finance",
                                    "employee_count": 2
                                  }
                                ]
                                  }
                                }
                                """
                        ),
                        @ExampleObject(
                            name = "ReportJobFailedExample",
                            value = """
                                {
                                  "jobId": "65ff8288-7aef-4b49-88a3-f2a98e6f4d4f",
                                  "status": "FAILED",
                                  "viewName": "vw_nonexistent",
                                  "offset": 0,
                                  "limit": 100,
                                  "submittedAt": "2026-03-09T22:14:44.942498",
                                  "startedAt": "2026-03-09T22:14:44.945519",
                                  "completedAt": "2026-03-09T22:14:44.975203",
                                  "error": "View not found: vw_nonexistent",
                                  "result": null
                                }
                                """
                        )
                    }
                )
            ),
            @ApiResponse(responseCode = "404", description = "Report job not found")
        })
    public ReportJobResponse getJob(@PathVariable String jobId) {
        ReportJobResponse response = reportJobService.getJob(jobId);
        if (response == null) {
            throw new ResourceNotFoundException("Report job not found: " + jobId);
        }
        return response;
    }
}
