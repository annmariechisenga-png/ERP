package com.localgov.repository;

import com.localgov.domain.model.PublicHoliday;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface PublicHolidayRepository extends JpaRepository<PublicHoliday, Long> {

    List<PublicHoliday> findByHolidayDateOrderByNameAsc(LocalDate holidayDate);

    /**
     * Returns national holidays (authority_code IS NULL) OR authority-specific holidays
     * for the given authority on the given date.
     */
    @Query("""
            SELECT h FROM PublicHoliday h
            WHERE h.holidayDate = :date
              AND (h.authorityCode IS NULL OR h.authorityCode = :authorityCode)
            """)
    List<PublicHoliday> findByDateForAuthority(
            @Param("date") LocalDate date,
            @Param("authorityCode") String authorityCode);

    @Query("""
            SELECT h FROM PublicHoliday h
            WHERE h.holidayDate = :date
              AND h.authorityCode IS NULL
            """)
    List<PublicHoliday> findNationalByDate(@Param("date") LocalDate date);
}
