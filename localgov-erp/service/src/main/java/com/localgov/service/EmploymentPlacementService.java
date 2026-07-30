package com.localgov.service;

import com.localgov.domain.model.EmploymentHistory;
import com.localgov.domain.model.EmploymentPlacementAuditLog;
import com.localgov.domain.model.SalaryNotchValue;
import com.localgov.repository.AuthorityMasterRepository;
import com.localgov.repository.EmploymentHistoryRepository;
import com.localgov.repository.EmploymentPlacementAuditLogRepository;
import com.localgov.repository.SalaryNotchValueRepository;
import com.localgov.service.dto.EmploymentPlacementRequest;
import com.localgov.service.dto.EmploymentPlacementResponse;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@Transactional
public class EmploymentPlacementService {

    private final EmployeeService employeeService;
    private final AuthorityMasterRepository authorityMasterRepository;
    private final SalaryNotchValueRepository salaryNotchValueRepository;
    private final EmploymentHistoryRepository employmentHistoryRepository;
    private final EmploymentPlacementAuditLogRepository auditLogRepository;

    public EmploymentPlacementService(
            EmployeeService employeeService,
            AuthorityMasterRepository authorityMasterRepository,
            SalaryNotchValueRepository salaryNotchValueRepository,
            EmploymentHistoryRepository employmentHistoryRepository,
            EmploymentPlacementAuditLogRepository auditLogRepository
    ) {
        this.employeeService = employeeService;
        this.authorityMasterRepository = authorityMasterRepository;
        this.salaryNotchValueRepository = salaryNotchValueRepository;
        this.employmentHistoryRepository = employmentHistoryRepository;
        this.auditLogRepository = auditLogRepository;
    }

    public EmploymentPlacementResponse placeOfficer(EmploymentPlacementRequest request) {
        employeeService.getEmployeeEntity(request.officerId());

        authorityMasterRepository.findById(request.authorityId())
                .orElseThrow(() -> new ResourceNotFoundException("Authority not found: " + request.authorityId()));

        SalaryNotchValue notchValue = salaryNotchValueRepository
                .findCurrentByScaleAndNotch(request.salaryScale(), request.notchNumber())
                .orElseThrow(() -> new BusinessValidationException("Invalid scale/notch combination"));

        EmploymentHistory history = new EmploymentHistory();
        history.setOfficerId(request.officerId());
        history.setAuthorityId(request.authorityId());
        history.setSalaryScale(request.salaryScale());
        history.setNotchNumber(request.notchNumber());
        history.setMonthlySalary(notchValue.getMonthlySalary());
        history.setApprovedBy(request.approvedBy());
        history.setApprovalDate(request.approvalDate());
        history.setApprovalReference(request.approvalReference());
        history.setAppointmentLetterUrl(request.letterUrl());
        history.setEffectiveDate(request.effectiveDate());
        history.setCurrent(true);
        history.setCreatedBy(request.userId());
        history.setCreatedAt(LocalDateTime.now());

        EmploymentHistory saved = employmentHistoryRepository.save(history);

        EmploymentPlacementAuditLog audit = new EmploymentPlacementAuditLog();
        audit.setEventType("EMPLOYMENT_PLACEMENT");
        audit.setOfficerId(request.officerId());
        audit.setDetails("Placed at " + request.salaryScale() + " Notch " + request.notchNumber());
        audit.setCreatedBy(request.userId());
        audit.setCreatedAt(LocalDateTime.now());
        auditLogRepository.save(audit);

        return new EmploymentPlacementResponse(true, saved.getId(), saved.getMonthlySalary());
    }
}
