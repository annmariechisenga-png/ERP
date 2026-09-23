package com.localgov.repository;

import com.localgov.domain.model.SalaryAdvanceWorkflowEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SalaryAdvanceWorkflowEventRepository extends JpaRepository<SalaryAdvanceWorkflowEvent, Long> {
	List<SalaryAdvanceWorkflowEvent> findBySalaryAdvanceRequest_IdOrderByCreatedAtAsc(Long requestId);
}