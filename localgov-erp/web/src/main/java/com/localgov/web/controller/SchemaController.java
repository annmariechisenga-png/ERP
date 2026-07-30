package com.localgov.web.controller;

import com.localgov.domain.model.CompassionateLeaveRelation;
import com.localgov.web.schema.SchemaIntrospectionService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("/meta/schema")
public class SchemaController {

    private final SchemaIntrospectionService schemaIntrospectionService;

    public SchemaController(SchemaIntrospectionService schemaIntrospectionService) {
        this.schemaIntrospectionService = schemaIntrospectionService;
    }

    @GetMapping("/workflows")
    public Map<String, Object> workflowSchema() {
        return schemaIntrospectionService.getWorkflowSchemaSnapshot();
    }

    @GetMapping("/leave-policies")
    public Map<String, Object> leavePolicies() {
        return schemaIntrospectionService.getLeavePolicySnapshot();
    }

    @GetMapping("/holidays")
    public Map<String, Object> holidays() {
        return schemaIntrospectionService.getHolidayCalendarSnapshot();
    }

    @GetMapping("/global-policies")
    public Map<String, Object> globalPolicies() {
        return schemaIntrospectionService.getGlobalPolicySnapshot();
    }

    @GetMapping("/leave-return-date")
    public Map<String, Object> leaveReturnDate(
            @RequestParam String leaveType,
            @RequestParam(required = false) CompassionateLeaveRelation compassionateRelation,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(defaultValue = "1") int daysOff
    ) {
        return schemaIntrospectionService.calculateLeaveReturnDate(leaveType, compassionateRelation, startDate, daysOff);
    }
}