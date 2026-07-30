package com.localgov.service;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.SalaryAdvanceDecision;
import com.localgov.domain.model.SalaryAdvanceDeduction;
import com.localgov.domain.model.SalaryAdvanceDeductionStatus;
import com.localgov.domain.model.SalaryAdvanceDisburserTitle;
import com.localgov.domain.model.SalaryAdvanceHeadApproverTitle;
import com.localgov.domain.model.SalaryAdvanceEligibilityStatus;
import com.localgov.domain.model.SalaryAdvancePolicy;
import com.localgov.domain.model.SalaryAdvanceRequest;
import com.localgov.domain.model.SalaryAdvanceRequestStatus;
import com.localgov.domain.model.SalaryAdvanceWorkflowEvent;
import com.localgov.repository.AuthorityMasterRepository;
import com.localgov.repository.SalaryAdvanceDeductionRepository;
import com.localgov.repository.SalaryAdvancePolicyRepository;
import com.localgov.repository.SalaryAdvanceRequestRepository;
import com.localgov.repository.SalaryAdvanceWorkflowEventRepository;
import com.localgov.service.dto.SalaryAdvanceDisbursementRequest;
import com.localgov.service.dto.SalaryAdvanceFinanceDecisionRequest;
import com.localgov.service.dto.SalaryAdvanceHeadDecisionRequest;
import com.localgov.service.dto.SalaryAdvancePendingDeductionItemResponse;
import com.localgov.service.dto.SalaryAdvancePendingDeductionReportResponse;
import com.localgov.service.dto.SalaryAdvanceRequestCreateRequest;
import com.localgov.service.dto.SalaryAdvanceRequestResponse;
import com.localgov.service.dto.SalaryAdvanceTrackingEventResponse;
import com.localgov.service.dto.SalaryAdvanceTrackingResponse;
import com.localgov.service.dto.SalaryAdvanceTrackingSummaryPageResponse;
import com.localgov.service.dto.SalaryAdvanceTrackingSummaryResponse;
import com.localgov.service.exception.BusinessValidationException;
import com.localgov.service.exception.ResourceNotFoundException;
import com.localgov.service.mapper.SalaryAdvanceMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@Transactional(readOnly = true)
public class SalaryAdvanceService {

    private static final int MONEY_SCALE = 2;
    private static final int DEFAULT_PAGE_SIZE = 20;
    private static final int MAX_PAGE_SIZE = 100;
    private static final RoundingMode MONEY_ROUNDING = RoundingMode.HALF_UP;
        private static final String AUTHORITY_TYPE_TOWN_COUNCIL = "Town Council";
        private static final String AUTHORITY_TYPE_MUNICIPAL_COUNCIL = "Municipal Council";
        private static final String AUTHORITY_TYPE_CITY_COUNCIL = "City Council";
        private static final List<SalaryAdvanceRequestStatus> ACTIVE_ADVANCE_STATUSES = List.of(
            SalaryAdvanceRequestStatus.SUBMITTED,
            SalaryAdvanceRequestStatus.PENDING_HEAD_APPROVAL,
            SalaryAdvanceRequestStatus.PENDING_FINANCE_APPROVAL,
            SalaryAdvanceRequestStatus.APPROVED_FOR_DISBURSEMENT,
            SalaryAdvanceRequestStatus.DISBURSED
        );

        private final AuthorityMasterRepository authorityMasterRepository;
    private final SalaryAdvanceRequestRepository salaryAdvanceRequestRepository;
    private final SalaryAdvancePolicyRepository salaryAdvancePolicyRepository;
    private final SalaryAdvanceWorkflowEventRepository salaryAdvanceWorkflowEventRepository;
    private final SalaryAdvanceDeductionRepository salaryAdvanceDeductionRepository;
    private final EmployeeService employeeService;
    private final SalaryAdvanceMapper salaryAdvanceMapper;

    public SalaryAdvanceService(
            AuthorityMasterRepository authorityMasterRepository,
            SalaryAdvanceRequestRepository salaryAdvanceRequestRepository,
            SalaryAdvancePolicyRepository salaryAdvancePolicyRepository,
            SalaryAdvanceWorkflowEventRepository salaryAdvanceWorkflowEventRepository,
            SalaryAdvanceDeductionRepository salaryAdvanceDeductionRepository,
            EmployeeService employeeService,
            SalaryAdvanceMapper salaryAdvanceMapper
    ) {
        this.authorityMasterRepository = authorityMasterRepository;
        this.salaryAdvanceRequestRepository = salaryAdvanceRequestRepository;
        this.salaryAdvancePolicyRepository = salaryAdvancePolicyRepository;
        this.salaryAdvanceWorkflowEventRepository = salaryAdvanceWorkflowEventRepository;
        this.salaryAdvanceDeductionRepository = salaryAdvanceDeductionRepository;
        this.employeeService = employeeService;
        this.salaryAdvanceMapper = salaryAdvanceMapper;
    }

    @Transactional
    public SalaryAdvanceRequestResponse submitRequest(SalaryAdvanceRequestCreateRequest request) {
        Employee employee = employeeService.getEmployeeEntity(request.employeeId());

        boolean hasActiveAdvanceRequest = salaryAdvanceRequestRepository.existsByEmployeeIdAndStatusIn(
                employee.getId(),
                ACTIVE_ADVANCE_STATUSES
        );
        if (hasActiveAdvanceRequest) {
            throw new BusinessValidationException("Officer already has an active salary advance request");
        }

        var authority = authorityMasterRepository.findByAuthorityRef(request.authorityRef())
            .orElseThrow(() -> new BusinessValidationException("Unknown authority reference: " + request.authorityRef()));

        SalaryAdvanceRequest salaryAdvanceRequest = new SalaryAdvanceRequest();
        salaryAdvanceRequest.setRequestNumber(generateRequestNumber());
        salaryAdvanceRequest.setEmployee(employee);
        salaryAdvanceRequest.setAuthorityRef(authority.getAuthorityRef());
        salaryAdvanceRequest.setAuthorityTypeAtRequest(authority.getAuthorityType());
        salaryAdvanceRequest.setRequestedAmount(normalizeMoney(request.requestedAmount()));
        salaryAdvanceRequest.setRequestedInstallments(request.requestedInstallments());
        salaryAdvanceRequest.setReason(request.reason());
        salaryAdvanceRequest.setStatus(SalaryAdvanceRequestStatus.SUBMITTED);
        salaryAdvanceRequest.setEligibilityStatus(SalaryAdvanceEligibilityStatus.PENDING);
        salaryAdvanceRequest.setEligibilityChecked(false);
        salaryAdvanceRequest.setRequestedAt(LocalDateTime.now());

        SalaryAdvanceRequest savedRequest = salaryAdvanceRequestRepository.save(salaryAdvanceRequest);
        addWorkflowEvent(savedRequest, "APPLICATION", "SUBMITTED", "APPLICANT", request.applicantName(), request.reason());

        runEligibilityGate(savedRequest);
        return toResponseDto(savedRequest);
    }

    @Transactional
    public SalaryAdvanceRequestResponse headDecision(Long requestId, SalaryAdvanceHeadDecisionRequest request) {
        SalaryAdvanceRequest salaryAdvanceRequest = getRequestEntity(requestId);

        if (salaryAdvanceRequest.getStatus() != SalaryAdvanceRequestStatus.PENDING_HEAD_APPROVAL) {
            throw new BusinessValidationException("Head decision allowed only when request is pending head approval");
        }

        if (salaryAdvanceRequest.getEligibilityStatus() != SalaryAdvanceEligibilityStatus.ELIGIBLE) {
            throw new BusinessValidationException("Request is not eligible for head approval");
        }

        SalaryAdvanceHeadApproverTitle expectedTitle = expectedHeadTitleForAuthorityType(
            salaryAdvanceRequest.getAuthorityTypeAtRequest()
        );
        if (request.headApproverTitle() != expectedTitle) {
            throw new BusinessValidationException(
                "Head approver title must be " + expectedTitle +
                    " for authority type " + salaryAdvanceRequest.getAuthorityTypeAtRequest()
            );
        }

        salaryAdvanceRequest.setHeadApproverTitle(request.headApproverTitle());
        salaryAdvanceRequest.setHeadApproverName(request.headApproverName());
        salaryAdvanceRequest.setHeadDecision(request.decision());
        salaryAdvanceRequest.setHeadDecisionAt(LocalDateTime.now());
        salaryAdvanceRequest.setHeadDecisionNotes(request.notes());

        if (request.decision() == SalaryAdvanceDecision.APPROVED) {
            salaryAdvanceRequest.setStatus(SalaryAdvanceRequestStatus.PENDING_FINANCE_APPROVAL);
            addWorkflowEvent(salaryAdvanceRequest, "HEAD_APPROVAL", "APPROVED", "HEAD_OF_INSTITUTION", request.headApproverName(), request.notes());
        } else {
            salaryAdvanceRequest.setStatus(SalaryAdvanceRequestStatus.REJECTED_BY_HEAD);
            addWorkflowEvent(salaryAdvanceRequest, "HEAD_APPROVAL", "REJECTED", "HEAD_OF_INSTITUTION", request.headApproverName(), request.notes());
        }

        return toResponseDto(salaryAdvanceRequestRepository.save(salaryAdvanceRequest));
    }

    @Transactional
    public SalaryAdvanceRequestResponse financeDecision(Long requestId, SalaryAdvanceFinanceDecisionRequest request) {
        SalaryAdvanceRequest salaryAdvanceRequest = getRequestEntity(requestId);

        if (salaryAdvanceRequest.getStatus() != SalaryAdvanceRequestStatus.PENDING_FINANCE_APPROVAL) {
            throw new BusinessValidationException("Finance decision allowed only when request is pending finance approval");
        }

        salaryAdvanceRequest.setFinanceOfficerName(request.financeOfficerName());
        salaryAdvanceRequest.setFinanceDecision(request.decision());
        salaryAdvanceRequest.setFinanceDecisionAt(LocalDateTime.now());
        salaryAdvanceRequest.setFinanceDecisionNotes(request.notes());

        if (request.decision() == SalaryAdvanceDecision.APPROVED) {
            salaryAdvanceRequest.setStatus(SalaryAdvanceRequestStatus.APPROVED_FOR_DISBURSEMENT);
            addWorkflowEvent(salaryAdvanceRequest, "FINANCE_APPROVAL", "APPROVED", "FINANCE", request.financeOfficerName(), request.notes());
        } else {
            salaryAdvanceRequest.setStatus(SalaryAdvanceRequestStatus.REJECTED_BY_FINANCE);
            addWorkflowEvent(salaryAdvanceRequest, "FINANCE_APPROVAL", "REJECTED", "FINANCE", request.financeOfficerName(), request.notes());
        }

        return toResponseDto(salaryAdvanceRequestRepository.save(salaryAdvanceRequest));
    }

    @Transactional
    public SalaryAdvanceRequestResponse disburse(Long requestId, SalaryAdvanceDisbursementRequest request) {
        SalaryAdvanceRequest salaryAdvanceRequest = getRequestEntity(requestId);

        if (salaryAdvanceRequest.getStatus() != SalaryAdvanceRequestStatus.APPROVED_FOR_DISBURSEMENT) {
            throw new BusinessValidationException("Disbursement allowed only when request is approved for disbursement");
        }

        salaryAdvanceRequest.setDisbursedAmount(salaryAdvanceRequest.getRequestedAmount());
        salaryAdvanceRequest.setDisbursedAt(LocalDateTime.now());
        if (request.disbursedByTitle() != SalaryAdvanceDisburserTitle.DIRECTOR_OF_FINANCE) {
            throw new BusinessValidationException("Disbursement must be done by Director of Finance");
        }
        salaryAdvanceRequest.setDisbursedByTitle(request.disbursedByTitle());
        salaryAdvanceRequest.setDisbursedBy(request.disbursedBy());
        salaryAdvanceRequest.setDisbursementReference(request.disbursementReference());
        salaryAdvanceRequest.setStatus(SalaryAdvanceRequestStatus.DISBURSED);

        SalaryAdvanceRequest savedRequest = salaryAdvanceRequestRepository.save(salaryAdvanceRequest);
        addWorkflowEvent(savedRequest, "DISBURSEMENT", "DISBURSED", "FINANCE", request.disbursedBy(), request.disbursementReference());

        createDeductionSchedule(savedRequest);
        return toResponseDto(savedRequest);
    }

    public SalaryAdvanceRequestResponse getRequest(Long requestId) {
        return toResponseDto(getRequestEntity(requestId));
    }

    public List<SalaryAdvanceRequestResponse> getEmployeeRequests(Long employeeId) {
        employeeService.getEmployeeEntity(employeeId);
        return salaryAdvanceRequestRepository.findByEmployeeIdOrderByCreatedAtDesc(employeeId)
                .stream()
                .map(this::toResponseDto)
                .toList();
    }

        public Page<SalaryAdvanceRequestResponse> getRequests(String status, Integer page, Integer size) {
        int resolvedPage = page == null ? 0 : Math.max(page, 0);
        int resolvedSize = size == null ? DEFAULT_PAGE_SIZE : Math.min(Math.max(size, 1), MAX_PAGE_SIZE);
        SalaryAdvanceRequestStatus requestStatus = resolveRequestStatus(status);

        return salaryAdvanceRequestRepository
            .findAllWithStatus(
                requestStatus,
                PageRequest.of(resolvedPage, resolvedSize, Sort.by(Sort.Direction.DESC, "createdAt"))
            )
            .map(this::toResponseDto);
        }

        public SalaryAdvancePendingDeductionReportResponse getPendingDeductionsReport(
            LocalDate payPeriod,
            Long employeeId,
            String status
        ) {
        if (payPeriod == null) {
            throw new BusinessValidationException("Pay period is required");
        }

        LocalDate normalizedPayPeriod = payPeriod.withDayOfMonth(1);
        SalaryAdvanceDeductionStatus deductionStatus = resolveDeductionStatus(status);

            List<SalaryAdvanceDeduction> pendingDeductions;
            if (employeeId == null) {
            if (deductionStatus == null) {
            pendingDeductions = salaryAdvanceDeductionRepository
                .findByScheduledPayPeriodLessThanEqual(normalizedPayPeriod);
            } else {
            pendingDeductions = salaryAdvanceDeductionRepository
                .findByStatusAndScheduledPayPeriodLessThanEqual(
                    deductionStatus,
                    normalizedPayPeriod
                );
            }
            } else {
                employeeService.getEmployeeEntity(employeeId);
            if (deductionStatus == null) {
            pendingDeductions = salaryAdvanceDeductionRepository
                .findByScheduledPayPeriodLessThanEqualAndEmployee_Id(
                    normalizedPayPeriod,
                    employeeId
                );
            } else {
            pendingDeductions = salaryAdvanceDeductionRepository
                .findByStatusAndScheduledPayPeriodLessThanEqualAndEmployee_Id(
                    deductionStatus,
                    normalizedPayPeriod,
                    employeeId
                );
            }
            }

        List<SalaryAdvancePendingDeductionItemResponse> items = pendingDeductions.stream()
            .sorted(Comparator
                .comparing(SalaryAdvanceDeduction::getScheduledPayPeriod)
                .thenComparing(deduction -> deduction.getEmployee().getEmployeeCode())
                .thenComparing(SalaryAdvanceDeduction::getInstallmentNo))
            .map(salaryAdvanceMapper::toPendingDeductionItemResponse)
            .toList();

        BigDecimal total = items.stream()
            .map(SalaryAdvancePendingDeductionItemResponse::deductionAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add)
            .setScale(MONEY_SCALE, MONEY_ROUNDING);

        return new SalaryAdvancePendingDeductionReportResponse(
            normalizedPayPeriod,
            (long) items.size(),
            total,
            items
        );
        }

        public SalaryAdvanceTrackingResponse getTracking(Long requestId) {
        SalaryAdvanceRequest request = getRequestEntity(requestId);

        List<SalaryAdvanceTrackingEventResponse> timeline = salaryAdvanceWorkflowEventRepository
            .findBySalaryAdvanceRequest_IdOrderByCreatedAtAsc(requestId)
            .stream()
            .map(salaryAdvanceMapper::toTrackingEventResponse)
            .toList();

        long appliedInstallments = salaryAdvanceDeductionRepository
            .countBySalaryAdvanceRequest_IdAndStatus(requestId, SalaryAdvanceDeductionStatus.APPLIED);
        long pendingInstallments = salaryAdvanceDeductionRepository
            .countBySalaryAdvanceRequest_IdAndStatus(requestId, SalaryAdvanceDeductionStatus.PENDING);

        LocalDateTime lastUpdatedAt = request.getUpdatedAt() != null
            ? request.getUpdatedAt()
            : request.getCreatedAt();

        return new SalaryAdvanceTrackingResponse(
            request.getId(),
            request.getRequestNumber(),
            request.getEmployee().getId(),
            request.getEmployee().getEmployeeCode(),
            request.getStatus(),
            request.getEligibilityStatus(),
            resolveCurrentStage(request.getStatus()),
            resolveProgressLabel(request.getStatus()),
            request.getRequestedAmount(),
            request.getDisbursedAmount(),
            request.getRequestedInstallments(),
            appliedInstallments,
            pendingInstallments,
            request.getCreatedAt(),
            lastUpdatedAt,
            timeline
        );
        }

        public SalaryAdvanceTrackingSummaryPageResponse getEmployeeTrackingSummaries(Long employeeId, Integer page, Integer size) {
        employeeService.getEmployeeEntity(employeeId);

        int resolvedPage = page == null ? 0 : page;
        int resolvedSize = size == null ? DEFAULT_PAGE_SIZE : size;

        if (resolvedPage < 0) {
            throw new BusinessValidationException("Page cannot be negative");
        }
        if (resolvedSize <= 0) {
            throw new BusinessValidationException("Size must be greater than zero");
        }
        if (resolvedSize > MAX_PAGE_SIZE) {
            resolvedSize = MAX_PAGE_SIZE;
        }

        PageRequest pageable = PageRequest.of(resolvedPage, resolvedSize, Sort.by(Sort.Direction.DESC, "createdAt"));

        Page<SalaryAdvanceRequest> requestPage = salaryAdvanceRequestRepository.findByEmployeeId(employeeId, pageable);

        List<SalaryAdvanceTrackingSummaryResponse> content = requestPage.getContent()
            .stream()
            .map(this::toTrackingSummary)
            .toList();

        return new SalaryAdvanceTrackingSummaryPageResponse(
            requestPage.getNumber(),
            requestPage.getSize(),
            requestPage.getTotalElements(),
            requestPage.getTotalPages(),
            requestPage.hasNext(),
            requestPage.hasPrevious(),
            content
        );
        }

        private SalaryAdvanceTrackingSummaryResponse toTrackingSummary(SalaryAdvanceRequest request) {
        long appliedInstallments = salaryAdvanceDeductionRepository
                .countBySalaryAdvanceRequest_IdAndStatus(request.getId(), SalaryAdvanceDeductionStatus.APPLIED);
        long pendingInstallments = salaryAdvanceDeductionRepository
                .countBySalaryAdvanceRequest_IdAndStatus(request.getId(), SalaryAdvanceDeductionStatus.PENDING);

        LocalDateTime lastUpdatedAt = request.getUpdatedAt() != null
                ? request.getUpdatedAt()
                : request.getCreatedAt();

        return salaryAdvanceMapper.toTrackingSummaryResponse(
            request,
            resolveCurrentStage(request.getStatus()),
            resolveProgressLabel(request.getStatus()),
            appliedInstallments,
            pendingInstallments,
            lastUpdatedAt
        );
    }

    private SalaryAdvanceRequest getRequestEntity(Long requestId) {
        return salaryAdvanceRequestRepository.findById(requestId)
                .orElseThrow(() -> new ResourceNotFoundException("Salary advance request not found with id: " + requestId));
    }

    private void runEligibilityGate(SalaryAdvanceRequest request) {
        SalaryAdvancePolicy policy = salaryAdvancePolicyRepository.findFirstByIsActiveTrueOrderByVersionNoDesc()
                .orElseThrow(() -> new BusinessValidationException("No active salary advance policy configured"));

        Employee employee = request.getEmployee();
        boolean hasRunningAdvance = salaryAdvanceDeductionRepository.existsByEmployee_IdAndStatus(
                employee.getId(),
                SalaryAdvanceDeductionStatus.PENDING
        );

        long serviceMonths = ChronoUnit.MONTHS.between(employee.getHireDate(), LocalDate.now());
        BigDecimal maximumAllowed = employee.getBaseSalary()
                .multiply(policy.getMaxAdvancePercent())
                .divide(BigDecimal.valueOf(100), MONEY_SCALE, MONEY_ROUNDING);

        List<String> reasons = new ArrayList<>();
        if (hasRunningAdvance) {
            reasons.add("Officer has a running advance");
        }
        if (serviceMonths < policy.getMinimumServiceMonths()) {
            reasons.add("Minimum service months not met");
        }
        if (request.getRequestedAmount().compareTo(maximumAllowed) > 0) {
            reasons.add("Requested amount exceeds policy cap of " + maximumAllowed);
        }
        if (request.getRequestedInstallments() > policy.getMaxInstallments()) {
            reasons.add("Requested installments exceed policy maximum of " + policy.getMaxInstallments());
        }
        if (request.getRequestedInstallments() > 6) {
            reasons.add("Requested installments exceed Rules 89-90 maximum of 6");
        }

        boolean eligible = reasons.isEmpty();
        request.setEligibilityChecked(true);
        request.setEligibilityCheckedAt(LocalDateTime.now());
        request.setEligibilityCheckedBy("SYSTEM");
        request.setHasRunningAdvanceAtCheck(hasRunningAdvance);

        if (eligible) {
            request.setEligibilityStatus(SalaryAdvanceEligibilityStatus.ELIGIBLE);
            request.setEligibilityNotes("Eligible under active salary advance policy " + policy.getPolicyCode());
            request.setStatus(SalaryAdvanceRequestStatus.PENDING_HEAD_APPROVAL);
            addWorkflowEvent(request, "ELIGIBILITY_CHECK", "PASSED", "SYSTEM", "SYSTEM", request.getEligibilityNotes());
        } else {
            request.setEligibilityStatus(SalaryAdvanceEligibilityStatus.INELIGIBLE);
            request.setEligibilityNotes(String.join("; ", reasons));
            request.setStatus(SalaryAdvanceRequestStatus.ELIGIBILITY_FAILED);
            addWorkflowEvent(request, "ELIGIBILITY_CHECK", "FAILED", "SYSTEM", "SYSTEM", request.getEligibilityNotes());
        }

        salaryAdvanceRequestRepository.save(request);
    }

    private SalaryAdvanceHeadApproverTitle expectedHeadTitleForAuthorityType(String authorityType) {
        if (AUTHORITY_TYPE_TOWN_COUNCIL.equalsIgnoreCase(authorityType)) {
            return SalaryAdvanceHeadApproverTitle.COUNCIL_SECRETARY;
        }
        if (AUTHORITY_TYPE_MUNICIPAL_COUNCIL.equalsIgnoreCase(authorityType)
                || AUTHORITY_TYPE_CITY_COUNCIL.equalsIgnoreCase(authorityType)) {
            return SalaryAdvanceHeadApproverTitle.TOWN_CLERK;
        }
        throw new BusinessValidationException("Unsupported authority type for salary advance approvals: " + authorityType);
    }

    private void createDeductionSchedule(SalaryAdvanceRequest request) {
        BigDecimal totalAmount = normalizeMoney(request.getDisbursedAmount());
        int installmentCount = request.getRequestedInstallments();
        BigDecimal installmentAmount = totalAmount.divide(BigDecimal.valueOf(installmentCount), MONEY_SCALE, MONEY_ROUNDING);
        BigDecimal assigned = BigDecimal.ZERO.setScale(MONEY_SCALE, MONEY_ROUNDING);

        LocalDate firstPayPeriod = request.getDisbursedAt().toLocalDate().withDayOfMonth(1).plusMonths(1);

        for (int installmentNo = 1; installmentNo <= installmentCount; installmentNo++) {
            BigDecimal amountForInstallment = installmentAmount;
            if (installmentNo == installmentCount) {
                amountForInstallment = totalAmount.subtract(assigned).setScale(MONEY_SCALE, MONEY_ROUNDING);
            }

            SalaryAdvanceDeduction deduction = new SalaryAdvanceDeduction();
            deduction.setSalaryAdvanceRequest(request);
            deduction.setEmployee(request.getEmployee());
            deduction.setInstallmentNo(installmentNo);
            deduction.setTotalInstallments(installmentCount);
            deduction.setScheduledPayPeriod(firstPayPeriod.plusMonths(installmentNo - 1L));
            deduction.setDeductionAmount(amountForInstallment);
            deduction.setStatus(SalaryAdvanceDeductionStatus.PENDING);
            salaryAdvanceDeductionRepository.save(deduction);

            assigned = assigned.add(amountForInstallment).setScale(MONEY_SCALE, MONEY_ROUNDING);
        }
    }

    private void addWorkflowEvent(
            SalaryAdvanceRequest request,
            String stage,
            String action,
            String actorRole,
            String actorName,
            String notes
    ) {
        SalaryAdvanceWorkflowEvent event = new SalaryAdvanceWorkflowEvent();
        event.setSalaryAdvanceRequest(request);
        event.setEventStage(stage);
        event.setEventAction(action);
        event.setActorRole(actorRole);
        event.setActorName(actorName);
        event.setEventNotes(notes);
        salaryAdvanceWorkflowEventRepository.save(event);
    }

    private SalaryAdvanceRequestResponse toResponseDto(SalaryAdvanceRequest request) {
        return salaryAdvanceMapper.toRequestResponse(
                request,
                salaryAdvanceDeductionRepository.countBySalaryAdvanceRequest_Id(request.getId())
        );
    }

    private String generateRequestNumber() {
        String suffix = UUID.randomUUID().toString().replace("-", "").substring(0, 10).toUpperCase();
        return "SADV-" + suffix;
    }

    private BigDecimal normalizeMoney(BigDecimal value) {
        return value.setScale(MONEY_SCALE, MONEY_ROUNDING);
    }

    private SalaryAdvanceDeductionStatus resolveDeductionStatus(String status) {
        if (status == null || status.isBlank()) {
            return SalaryAdvanceDeductionStatus.PENDING;
        }

        if ("all".equalsIgnoreCase(status)) {
            return null;
        }

        try {
            return SalaryAdvanceDeductionStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException exception) {
            throw new BusinessValidationException("Invalid status filter. Use pending, applied, or all");
        }
    }

    private SalaryAdvanceRequestStatus resolveRequestStatus(String status) {
        if (status == null || status.isBlank() || "all".equalsIgnoreCase(status)) {
            return null;
        }

        try {
            return SalaryAdvanceRequestStatus.valueOf(status.trim().toUpperCase());
        } catch (IllegalArgumentException exception) {
            throw new BusinessValidationException("Invalid request status filter: " + status);
        }
    }

    private String resolveCurrentStage(SalaryAdvanceRequestStatus status) {
        return switch (status) {
            case SUBMITTED, ELIGIBILITY_FAILED, PENDING_HEAD_APPROVAL -> "Eligibility / Head Approval";
            case REJECTED_BY_HEAD -> "Rejected by Head of Institution";
            case PENDING_FINANCE_APPROVAL -> "Finance Approval";
            case REJECTED_BY_FINANCE -> "Rejected by Finance";
            case APPROVED_FOR_DISBURSEMENT -> "Ready for Disbursement";
            case DISBURSED -> "Disbursed / Payroll Deductions Ongoing";
            case CANCELLED -> "Cancelled";
        };
    }

    private String resolveProgressLabel(SalaryAdvanceRequestStatus status) {
        return switch (status) {
            case SUBMITTED -> "Application received";
            case ELIGIBILITY_FAILED -> "Stopped at eligibility check";
            case PENDING_HEAD_APPROVAL -> "Waiting for Head of Institution decision";
            case REJECTED_BY_HEAD -> "Rejected at Head of Institution stage";
            case PENDING_FINANCE_APPROVAL -> "Waiting for Finance approval";
            case REJECTED_BY_FINANCE -> "Rejected at Finance stage";
            case APPROVED_FOR_DISBURSEMENT -> "Approved and waiting disbursement";
            case DISBURSED -> "Disbursed and scheduled for payroll deductions";
            case CANCELLED -> "Application cancelled";
        };
    }
}