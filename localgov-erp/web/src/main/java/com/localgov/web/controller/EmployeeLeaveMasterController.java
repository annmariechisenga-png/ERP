package com.localgov.web.controller;

import com.localgov.domain.model.EmployeeLeaveMaster;
import com.localgov.repository.EmployeeLeaveMasterRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/leave-master")
public class EmployeeLeaveMasterController {

    @Autowired
    private EmployeeLeaveMasterRepository leaveMasterRepository;

    // GET all active leave records
    // URL: http://localhost:8086/api/leave-master/active
    @GetMapping("/active")
    public ResponseEntity<List<EmployeeLeaveMaster>> getAllActiveRecords() {
        List<EmployeeLeaveMaster> activeRecords = leaveMasterRepository.findAllActiveLeaveMasters();
        return ResponseEntity.ok(activeRecords);
    }

    // GET a specific employee's leave record by ID
    // URL: http://localhost:8086/api/leave-master/employee/{employeeId}
    @GetMapping("/employee/{employeeId}")
    public ResponseEntity<EmployeeLeaveMaster> getByEmployeeId(@PathVariable Long employeeId) {
        return leaveMasterRepository.findByEmployeeId(employeeId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // GET all records (optional)
    // URL: http://localhost:8086/api/leave-master/all
    @GetMapping("/all")
    public ResponseEntity<List<EmployeeLeaveMaster>> getAllRecords() {
        List<EmployeeLeaveMaster> allRecords = leaveMasterRepository.findAll();
        return ResponseEntity.ok(allRecords);
    }
}