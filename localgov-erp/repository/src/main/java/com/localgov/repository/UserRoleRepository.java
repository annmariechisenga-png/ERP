package com.localgov.repository;

import com.localgov.domain.model.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface UserRoleRepository extends JpaRepository<UserRole, Long> {

    List<UserRole> findByUserId(Long userId);

    Optional<UserRole> findByUserIdAndRole(Long userId, String role);

    boolean existsByUserIdAndRole(Long userId, String role);

    List<UserRole> findByRole(String role);

    @Query("SELECT ur FROM UserRole ur WHERE ur.userId = :userId ORDER BY ur.createdAt DESC")
    List<UserRole> findAllByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId);
}
