package com.localgov.service.leave;

import com.localgov.repository.PublicHolidayRepository;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.EnumSet;
import java.util.Set;

/**
 * Single authoritative service for all leave-related calendar and date arithmetic.
 * <p>
 * Responsibilities:
 * <ul>
 *   <li>working day counting</li>
 *   <li>calendar day counting</li>
 *   <li>weekend exclusion</li>
 *   <li>public holiday exclusion</li>
 *   <li>resume date derivation</li>
 *   <li>working-day predicates</li>
 *   <li>next-working-day resolution</li>
 *   <li>complete schedule computation</li>
 * </ul>
 *
 * @see ScheduleResult
 */
@Service
public class LeaveCalendarService {

    private static final Set<DayOfWeek> WEEKEND = EnumSet.of(DayOfWeek.SATURDAY, DayOfWeek.SUNDAY);

    private final PublicHolidayRepository publicHolidayRepository;

    public LeaveCalendarService(PublicHolidayRepository publicHolidayRepository) {
        this.publicHolidayRepository = publicHolidayRepository;
    }

    /**
     * Counts working days (excluding weekends and public holidays) in the inclusive range.
     */
    public int countWorkingDays(LocalDate start, LocalDate end, String authorityCode) {
        int count = 0;
        LocalDate d = start;
        while (!d.isAfter(end)) {
            if (isWorkingDay(d, authorityCode)) {
                count++;
            }
            d = d.plusDays(1);
        }
        return count;
    }

    /**
     * Counts calendar days in the inclusive range.
     */
    public int countCalendarDays(LocalDate start, LocalDate end) {
        return (int) start.until(end, java.time.temporal.ChronoUnit.DAYS) + 1;
    }

    /**
     * Returns the number of weekend days in the inclusive date range.
     */
    public int excludeWeekends(LocalDate start, LocalDate end) {
        int count = 0;
        LocalDate d = start;
        while (!d.isAfter(end)) {
            if (isWeekend(d)) {
                count++;
            }
            d = d.plusDays(1);
        }
        return count;
    }

    /**
     * Returns the number of public holidays in the inclusive date range.
     */
    public int excludePublicHolidays(LocalDate start, LocalDate end, String authorityCode) {
        int count = 0;
        LocalDate d = start;
        while (!d.isAfter(end)) {
            if (!isWeekend(d) && isPublicHoliday(d, authorityCode)) {
                count++;
            }
            d = d.plusDays(1);
        }
        return count;
    }

    /**
     * Returns the next working day on or after the given date.
     */
    public LocalDate nextWorkingDay(LocalDate date, String authorityCode) {
        LocalDate current = date;
        while (!isWorkingDay(current, authorityCode)) {
            current = current.plusDays(1);
        }
        return current;
    }

    /**
     * Calculates the resume date (next working day after leave ends).
     */
    public LocalDate calculateResumeDate(LocalDate endDate, String authorityCode) {
        return nextWorkingDay(endDate.plusDays(1), authorityCode);
    }

    /**
     * True if the date is not a weekend and not a public holiday.
     */
    public boolean isWorkingDay(LocalDate date, String authorityCode) {
        return !isWeekend(date) && !isPublicHoliday(date, authorityCode);
    }

    /**
     * True if the date falls on Saturday or Sunday.
     */
    public boolean isWeekend(LocalDate date) {
        return WEEKEND.contains(date.getDayOfWeek());
    }

    /**
     * True if the date is a public holiday for the given authority, or a national holiday
     * when no authority is supplied.
     */
    public boolean isPublicHoliday(LocalDate date, String authorityCode) {
        if (authorityCode != null && !authorityCode.isBlank()) {
            return !publicHolidayRepository.findByDateForAuthority(date, authorityCode).isEmpty();
        }
        return !publicHolidayRepository.findNationalByDate(date).isEmpty();
    }

    /**
     * Computes the full leave schedule from a start date and requested day count.
     */
    public ScheduleResult computeSchedule(LocalDate startDate, int days,
                                           boolean isWorkingDays, boolean isFixed, String authorityCode) {
        if (isFixed) {
            LocalDate endDate = startDate.plusDays(days - 1L);
            return new ScheduleResult(
                    startDate, endDate, calculateResumeDate(endDate, authorityCode),
                    days, 0, 0);
        }
        if (!isWorkingDays) {
            LocalDate endDate = startDate.plusDays(days - 1L);
            return new ScheduleResult(
                    startDate, endDate, calculateResumeDate(endDate, authorityCode),
                    days, 0, 0);
        }
        return forwardCountWorkingDays(startDate, days, authorityCode);
    }

    private ScheduleResult forwardCountWorkingDays(LocalDate startDate, int workingDays, String authorityCode) {
        LocalDate current = startDate;
        LocalDate firstWorkingDay = null;
        LocalDate lastWorkingDay = null;
        int remaining = workingDays;
        int weekendSkipped = 0;
        int holidaySkipped = 0;

        while (remaining > 0) {
            boolean weekend = isWeekend(current);
            boolean holiday = !weekend && isPublicHoliday(current, authorityCode);
            if (!weekend && !holiday) {
                if (firstWorkingDay == null) {
                    firstWorkingDay = current;
                }
                lastWorkingDay = current;
                remaining--;
            } else {
                if (weekend) {
                    weekendSkipped++;
                }
                if (holiday) {
                    holidaySkipped++;
                }
            }
            if (remaining > 0) {
                current = current.plusDays(1);
            }
        }

        LocalDate effectiveStart = firstWorkingDay != null ? firstWorkingDay : startDate;
        LocalDate endDate = lastWorkingDay != null ? lastWorkingDay : startDate;
        return new ScheduleResult(
                effectiveStart, endDate, calculateResumeDate(endDate, authorityCode),
                workingDays, weekendSkipped, holidaySkipped);
    }
}
