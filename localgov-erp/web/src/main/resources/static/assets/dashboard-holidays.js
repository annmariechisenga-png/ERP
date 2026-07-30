/**
 * dashboard-holidays.js
 *
 * Extracted holiday-calendar logic from erp-dashboard.js:
 *   HOLIDAY_CALENDARS, getHolidayCalendarConfig, renderHolidayCalendar,
 *   formatWeekday, getUpcomingHolidays, getActiveHolidayEntries, getWeekendDaySet,
 *   and isNonWorkingLeaveDate.
 *
 * Exposes a global `DashboardHolidays` object so it can be wired into any HTML page.
 */
const DashboardHolidays = (function () {
    "use strict";

    var HOLIDAY_CALENDARS = {
        zambia: {
            label: {
                en: "Zambia national",
                fr: "Zambie nationale",
                ar: "العطل الوطنية في زامبيا",
                he: "חגים לאומיים בזמביה"
            },
            weekendDays: [0, 6],
            holidays: [
                { date: "2026-01-01", name: "New Year's Day" },
                { date: "2026-03-09", name: "International Women's Day (observed)" },
                { date: "2026-03-12", name: "Youth Day" },
                { date: "2026-04-03", name: "Good Friday" },
                { date: "2026-04-04", name: "Holy Saturday" },
                { date: "2026-04-05", name: "Easter Sunday" },
                { date: "2026-04-06", name: "Easter Monday" },
                { date: "2026-04-28", name: "Kenneth Kaunda Day" },
                { date: "2026-05-01", name: "Labour Day" },
                { date: "2026-05-25", name: "Africa Freedom Day" },
                { date: "2026-07-06", name: "Heroes' Day" },
                { date: "2026-07-07", name: "Unity Day" },
                { date: "2026-08-03", name: "Farmers' Day" },
                { date: "2026-08-13", name: "Election Day" },
                { date: "2026-10-19", name: "National Day of Prayer (observed)" },
                { date: "2026-10-24", name: "Independence Day" },
                { date: "2026-12-25", name: "Christmas Day" },
                { date: "2026-12-29", name: "Christian Nation Declaration Day" }
            ]
        }
    };

    var state = {
        holidayRegion: "zambia",
        locale: "en-ZM",
        language: "en",
        holidayCalendar: null
    };

    function $(selector) {
        return document.querySelector(selector);
    }

    function escapeHtml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    function t(key) {
        var fn = (typeof DashboardI18n !== "undefined" && DashboardI18n.t) ? DashboardI18n.t : null;
        return fn ? fn(key) : key;
    }

    function getLocalizedValue(value) {
        if (typeof value === "string") { return value; }
        if (value === null || typeof value !== "object") { return ""; }
        return value[state.language] || value.en || "";
    }

    function formatDate(dateString) {
        var date = new Date(dateString);
        if (Number.isNaN(date.getTime())) {
            return dateString;
        }
        return date.toLocaleDateString(state.locale || "en-ZM", {
            year: "numeric",
            month: "short",
            day: "numeric"
        });
    }

    function formatDateInputValue(date) {
        var year = date.getFullYear();
        var month = String(date.getMonth() + 1).padStart(2, "0");
        var day = String(date.getDate()).padStart(2, "0");
        return year + "-" + month + "-" + day;
    }

    function formatWeekday(index) {
        var date = new Date(Date.UTC(2026, 0, 4 + index));
        return new Intl.DateTimeFormat(state.locale, { weekday: "long" }).format(date);
    }

    function getHolidayCalendarConfig() {
        var fallback = HOLIDAY_CALENDARS[state.holidayRegion] || HOLIDAY_CALENDARS.zambia;
        var liveHolidays = Array.isArray(state.holidayCalendar && state.holidayCalendar.holidays)
            ? state.holidayCalendar.holidays
                .map(function (holiday) {
                    return {
                        date: holiday.date || holiday.holidayDate || holiday.holiday_date,
                        name: holiday.name || holiday.description || holiday.holiday_name || "Public Holiday"
                    };
                })
                .filter(function (holiday) { return holiday.date; })
            : [];

        if (!liveHolidays.length) {
            return fallback;
        }

        return {
            label: (state.holidayCalendar && state.holidayCalendar.label) || fallback.label,
            weekendDays: (state.holidayCalendar && state.holidayCalendar.weekendDays) || fallback.weekendDays || [0, 6],
            holidays: liveHolidays
        };
    }

    function getActiveHolidayEntries() {
        return (state.holidayCalendar && state.holidayCalendar.holidays) || getHolidayCalendarConfig().holidays || [];
    }

    function getWeekendDaySet() {
        var configured = (state.holidayCalendar && state.holidayCalendar.weekendDays) || getHolidayCalendarConfig().weekendDays || [0, 6];
        return new Set(configured.map(function (value) { return Number(value); }));
    }

    function isNonWorkingLeaveDate(date, holidayDates, weekendDays) {
        if (!(date instanceof Date) || Number.isNaN(date.getTime())) {
            return false;
        }
        return weekendDays.has(date.getDay()) || holidayDates.has(formatDateInputValue(date));
    }

    function getUpcomingHolidays(count) {
        count = count || 5;
        var calendar = getHolidayCalendarConfig();
        var today = formatDateInputValue(new Date());
        var holidays = (calendar.holidays || [])
            .filter(function (holiday) { return String(holiday.date).localeCompare(today) >= 0; })
            .sort(function (left, right) { return String(left.date).localeCompare(String(right.date)); });
        return holidays.slice(0, count);
    }

    function renderMetricCard(metric) {
        return '<article class="stat-card">' +
            '<div class="stat-value">' + escapeHtml(metric.value) + '</div>' +
            '<div class="stat-label">' + escapeHtml(metric.label) + '</div>' +
            (metric.note ? '<div class="stat-trend">' + escapeHtml(metric.note) + '</div>' : '') +
            '</article>';
    }

    function renderHolidayCalendar() {
        var root = $("#holidayCalendar");
        if (!root) {
            return;
        }

        var summaryRoot = $("#holidaySummary");
        var metaRoot = $("#holidayMeta");
        var calendar = getHolidayCalendarConfig();
        var holidays = (calendar.holidays || []).slice().sort(function (left, right) {
            return String(left.date).localeCompare(String(right.date));
        });
        var weekendDays = (calendar.weekendDays || [0, 6]).map(function (day) { return formatWeekday(day); }).join(" / ");
        var sourceLabel = (state.holidayCalendar && state.holidayCalendar.sourceLabel) || getLocalizedValue({
            en: "Configured 2026 Zambia holiday data",
            fr: "Jours fériés zambiens 2026 configurés",
            ar: "بيانات عطلات زامبيا 2026 المهيأة",
            he: "נתוני חגי זמביה 2026 שהוגדרו"
        });

        if (metaRoot) {
            metaRoot.textContent = sourceLabel;
        }

        if (summaryRoot) {
            summaryRoot.innerHTML = [
                {
                    value: String(holidays.length),
                    label: getLocalizedValue({ en: "2026 public holidays", fr: "Jours fériés 2026", ar: "عطلات 2026 الرسمية", he: "חגים ציבוריים 2026" }),
                    note: getLocalizedValue({ en: "Verified Zambia entries.", fr: "Entrées Zambie vérifiées.", ar: "إدخالات زامبيا المؤكدة.", he: "רשומות זמביה מאומתות." })
                },
                {
                    value: getLocalizedValue(calendar.label),
                    label: getLocalizedValue({ en: "Calendar scope", fr: "Portée du calendrier", ar: "نطاق التقويم", he: "טווח הלוח" }),
                    note: sourceLabel
                },
                {
                    value: weekendDays,
                    label: t("weekend"),
                    note: getLocalizedValue({ en: "Weekend days used by leave and overtime planning.", fr: "Week-ends utilisés pour la planification.", ar: "أيام عطلة نهاية الأسبوع المستخدمة في التخطيط.", he: "ימי סוף השבוע המשמשים לתכנון." })
                }
            ].map(renderMetricCard).join("");
        }

        if (!holidays.length) {
            root.innerHTML = '<div class="notice"><strong>' + escapeHtml(t("leaveHolidayHeading")) + '</strong><span>' + escapeHtml(t("holidayEmpty")) + '</span></div>';
            return;
        }

        var cards = ['<article class="list-card detail-card"><strong>' + escapeHtml(getLocalizedValue(calendar.label)) + '</strong><p>' + escapeHtml(t("weekend")) + ": " + escapeHtml(weekendDays) + '</p></article>']
            .concat(holidays.map(function (holiday) {
                return '<article class="list-card detail-card"><strong>' + escapeHtml(getLocalizedValue(holiday.name)) + '</strong><p>' + escapeHtml(formatDate(holiday.date)) + '</p></article>';
            }));

        root.innerHTML = cards.join("");
    }

    function renderUpcomingHolidays() {
        var root = $("#upcomingHolidays");
        if (!root) {
            return;
        }
        var upcoming = getUpcomingHolidays(5);
        if (!upcoming.length) {
            root.innerHTML = '<p class="table-note">No upcoming holidays.</p>';
            return;
        }
        root.innerHTML = '<ul style="list-style:none;padding:0;margin:0;">' + upcoming.map(function (holiday) {
            return '<li style="padding:6px 0;border-bottom:1px solid var(--border);"><strong>' + escapeHtml(getLocalizedValue(holiday.name)) + '</strong> <span style="color:var(--text-muted);">' + escapeHtml(formatDate(holiday.date)) + '</span></li>';
        }).join("") + '</ul>';
    }

    function init(options) {
        options = options || {};
        state.holidayRegion = options.region || localStorage.getItem("erp.holidayRegion") || "zambia";
        state.locale = options.locale || "en-ZM";
        state.language = options.language || "en";
        state.holidayCalendar = options.holidayCalendar || null;
        renderHolidayCalendar();
        renderUpcomingHolidays();
    }

    return {
        init: init,
        HOLIDAY_CALENDARS: HOLIDAY_CALENDARS,
        getHolidayCalendarConfig: getHolidayCalendarConfig,
        renderHolidayCalendar: renderHolidayCalendar,
        renderUpcomingHolidays: renderUpcomingHolidays,
        formatWeekday: formatWeekday,
        getUpcomingHolidays: getUpcomingHolidays,
        getActiveHolidayEntries: getActiveHolidayEntries,
        getWeekendDaySet: getWeekendDaySet,
        isNonWorkingLeaveDate: isNonWorkingLeaveDate,
        state: state
    };
})();
