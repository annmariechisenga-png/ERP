package com.localgov.repository;

import com.localgov.domain.model.SalaryAdvancePolicy;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SalaryAdvancePolicyRepository extends JpaRepository<SalaryAdvancePolicy, Long> {
    Optional<SalaryAdvancePolicy> findFirstByIsActiveTrueOrderByVersionNoDesc();
}