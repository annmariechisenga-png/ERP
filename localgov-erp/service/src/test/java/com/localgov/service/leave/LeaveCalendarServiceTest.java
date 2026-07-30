package com.localgov.service.leave;

import com.localgov.domain.model.PublicHoliday;
import com.localgov.repository.PublicHolidayRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class LeaveCalendarServiceTest {

    private PublicHolidayRepository publicHolidayRepository;
    private LeaveCalendarService leaveCalendarService;

    @BeforeEach
    void setUp() {
        publicHolidayRepository = mock(PublicHolidayRepository.class);
        leaveCalendarService = new LeaveCalendarService(publicHolidayRepository);
    }

    @Test
    void countWorkingDaysExcludesWeekends() {
        LocalDate mon = LocalDate.of(2026, 7, 6);
        assertEquals(5, leaveCalendarService.countWorkingDays(mon, mon.plusDays(6), "AUTH"));
    }

    @Test
    void countWorkingDaysExcludesPublicHolidays() {
        LocalDate mon = LocalDate.of(2026, 7, 6);
        when(publicHolidayRepository.findByDateForAuthority(eq(LocalDate.of(2026, 7, 7)), any()))
                .thenReturn(List.of(new PublicHoliday()));

        assertEquals(4, leaveCalendarService.countWorkingDays(mon, mon.plusDays(6), "AUTH"));
    }

    @Test
    void countCalendarDaysIsInclusive() {
        LocalDate start = LocalDate.of(2026, 7, 1);
        LocalDate end = LocalDate.of(2026, 7, 5);
        assertEquals(5, leaveCalendarService.countCalendarDays(start, end));
    }

    @Test
    void excludeWeekendsCountsSaturdayAndSunday() {
        LocalDate fri = LocalDate.of(2026, 7, 3);
        assertEquals(2, leaveCalendarService.excludeWeekends(fri, fri.plusDays(2)));
    }

    @Test
    void excludePublicHolidaysDoesNotCountWeekendHolidaysTwice() {
        LocalDate holidayOnMonday = LocalDate.of(2026, 7, 6);
        when(publicHolidayRepository.findByDateForAuthority(eq(holidayOnMonday), any()))
                .thenReturn(List.of(new PublicHoliday()));

        assertEquals(1, leaveCalendarService.excludePublicHolidays(holidayOnMonday, holidayOnMonday.plusDays(1), "AUTH"));
        assertEquals(0, leaveCalendarService.excludePublicHolidays(holidayOnMonday.plusDays(1), holidayOnMonday.plusDays(1), "AUTH"));
    }

    @Test
    void isWeekendReturnsTrueForSaturdayAndSunday() {
        assertTrue(leaveCalendarService.isWeekend(LocalDate.of(2026, 7, 4)));
        assertTrue(leaveCalendarService.isWeekend(LocalDate.of(2026, 7, 5)));
        assertFalse(leaveCalendarService.isWeekend(LocalDate.of(2026, 7, 6)));
    }

    @Test
    void isPublicHolidayUsesAuthoritySpecificQuery() {
        LocalDate date = LocalDate.of(2026, 7, 6);
        when(publicHolidayRepository.findByDateForAuthority(date, "AUTH"))
                .thenReturn(List.of(new PublicHoliday()));
        when(publicHolidayRepository.findNationalByDate(date))
                .thenReturn(Collections.emptyList());

        assertTrue(leaveCalendarService.isPublicHoliday(date, "AUTH"));
    }

    @Test
    void isPublicHolidayFallsBackToNationalWhenNoAuthority() {
        LocalDate date = LocalDate.of(2026, 7, 6);
        when(publicHolidayRepository.findNationalByDate(date))
                .thenReturn(List.of(new PublicHoliday()));

        assertTrue(leaveCalendarService.isPublicHoliday(date, null));
        assertTrue(leaveCalendarService.isPublicHoliday(date, "   "));
    }

    @Test
    void nextWorkingDaySkipsWeekendAndHoliday() {
        LocalDate saturday = LocalDate.of(2026, 7, 4);
        LocalDate mondayHoliday = LocalDate.of(2026, 7, 6);
        when(publicHolidayRepository.findByDateForAuthority(mondayHoliday, "AUTH"))
                .thenReturn(List.of(new PublicHoliday()));

        assertEquals(LocalDate.of(2026, 7, 7), leaveCalendarService.nextWorkingDay(saturday, "AUTH"));
        assertEquals(LocalDate.of(2026, 7, 7), leaveCalendarService.nextWorkingDay(mondayHoliday, "AUTH"));
    }

    @Test
    void calculateResumeDateIsNextWorkingDayAfterEndDate() {
        LocalDate endFriday = LocalDate.of(2026, 7, 3);
        assertEquals(LocalDate.of(2026, 7, 6), leaveCalendarService.calculateResumeDate(endFriday, "AUTH"));
    }

    @Test
    void computeScheduleForWorkingDaysCountsForward() {
        LocalDate fri = LocalDate.of(2026, 7, 3);
        when(publicHolidayRepository.findByDateForAuthority(any(), any()))
                .thenReturn(Collections.emptyList());

        ScheduleResult result = leaveCalendarService.computeSchedule(fri, 3, true, false, "AUTH");

        assertEquals(fri, result.startDate());
        assertEquals(LocalDate.of(2026, 7, 7), result.endDate());
        assertEquals(LocalDate.of(2026, 7, 8), result.resumptionDate());
        assertEquals(3, result.chargeableDays());
        assertEquals(2, result.weekendDaysSkipped());
        assertEquals(0, result.publicHolidaysSkipped());
    }

    @Test
    void computeScheduleForFixedDurationUsesCalendarDays() {
        LocalDate start = LocalDate.of(2026, 8, 1);
        when(publicHolidayRepository.findByDateForAuthority(any(), any()))
                .thenReturn(Collections.emptyList());

        ScheduleResult result = leaveCalendarService.computeSchedule(start, 98, false, true, "AUTH");

        assertEquals(start, result.startDate());
        assertEquals(LocalDate.of(2026, 11, 6), result.endDate());
        assertEquals(LocalDate.of(2026, 11, 9), result.resumptionDate());
        assertEquals(98, result.chargeableDays());
    }
}
