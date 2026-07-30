package com.localgov.repository;

import com.localgov.domain.model.CompanyDocument;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CompanyDocumentRepository extends JpaRepository<CompanyDocument, Long> {
    List<CompanyDocument> findAllByOrderByIdAsc();

    Optional<CompanyDocument> findByDocumentKeyIgnoreCase(String documentKey);
}
