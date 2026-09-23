package com.localgov.repository;

import com.localgov.domain.model.PayrollConfig;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PayrollConfigRepository extends JpaRepository<PayrollConfig, Long> {
    Optional<PayrollConfig> findByConfigKey(String configKey);
}
