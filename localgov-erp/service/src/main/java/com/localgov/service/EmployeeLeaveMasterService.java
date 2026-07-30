package com.localgov.service;

import com.localgov.repository.EmployeeLeaveMasterRepository;
import com.localgov.domain.model.EmployeeLeaveMaster;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class EmployeeLeaveMasterService {
    
    @Autowired
    private EmployeeLeaveMasterRepository leaveMasterRepository;
    
    // Your original query - gets all active records
    public List<EmployeeLeaveMaster> getAllActiveLeaveMasters() {
        return leaveMasterRepository.findAllActiveLeaveMasters();
    }
    
    // Get by specific employee
    public EmployeeLeaveMaster getByEmployeeId(Long employeeId) {
        return leaveMasterRepository.findByEmployeeId(employeeId)
            .orElseThrow(() -> new RuntimeException("Employee not found"));
    }
}