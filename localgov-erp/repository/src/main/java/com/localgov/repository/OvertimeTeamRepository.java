package com.localgov.repository;

import com.localgov.domain.model.OvertimeTeam;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OvertimeTeamRepository extends JpaRepository<OvertimeTeam, Long> {
    Optional<OvertimeTeam> findByTeamCodeIgnoreCaseAndActiveTrue(String teamCode);
}
