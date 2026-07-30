package com.localgov.repository;

import com.localgov.domain.model.PrivacyDataRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PrivacyDataRequestRepository extends JpaRepository<PrivacyDataRequest, Long> {
    Page<PrivacyDataRequest> findAllByUsernameIgnoreCaseOrderByCreatedAtDesc(String username, Pageable pageable);
}
