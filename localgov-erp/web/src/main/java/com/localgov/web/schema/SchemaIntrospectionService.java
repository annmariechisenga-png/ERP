package com.localgov.web.schema;

import com.localgov.domain.model.CompassionateLeaveRelation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

@Service
public class SchemaIntrospectionService {

    private static final Logger LOGGER = LoggerFactory.getLogger(SchemaIntrospectionService.class);
    private static final String WORKFLOW_REGEX = "(leave|approval|supervis|hierarch|reporting|position|council|salary|advance|disburse)";

    private final JdbcTemplate jdbcTemplate;
    private final String configuredSqliteFallbackPath;

    public SchemaIntrospectionService(
            JdbcTemplate jdbcTemplate,
            @Value("${erp.sqlite.fallback-path:}") String configuredSqliteFallbackPath
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.configuredSqliteFallbackPath = configuredSqliteFallbackPath == null ? "" : configuredSqliteFallbackPath.trim();
    }

    @Cacheable(cacheNames = "schemaSnapshots", key = "'workflow'", sync = true)
    public Map<String, Object> getWorkflowSchemaSnapshot() {
        List<String> tables = jdbcTemplate.queryForList(
                """
                SELECT table_name
                FROM information_schema.tables
                WHERE LOWER(table_schema) = 'public'
                  AND table_type = 'BASE TABLE'
                  AND table_name ~* ?
                ORDER BY table_name
                """,
                String.class,
                WORKFLOW_REGEX
        );

        Map<String, List<Map<String, String>>> columnsByTable = new LinkedHashMap<>();
        for (String table : tables) {
            columnsByTable.put(table, new ArrayList<>());
        }

        jdbcTemplate.query(
                """
                SELECT table_name, column_name, data_type
                FROM information_schema.columns
                WHERE LOWER(table_schema) = 'public'
                  AND table_name ~* ?
                ORDER BY table_name, ordinal_position
                """,
                rs -> {
                    String tableName = rs.getString("table_name");
                    if (columnsByTable.containsKey(tableName)) {
                        Map<String, String> column = new LinkedHashMap<>();
                        column.put("name", rs.getString("column_name"));
                        column.put("type", rs.getString("data_type"));
                        columnsByTable.get(tableName).add(column);
                    }
                },
                WORKFLOW_REGEX
        );

        List<Map<String, Object>> tableDetails = new ArrayList<>();
        for (Map.Entry<String, List<Map<String, String>>> entry : columnsByTable.entrySet()) {
            Map<String, Object> detail = new LinkedHashMap<>();
            detail.put("table", entry.getKey());
            detail.put("columnCount", entry.getValue().size());
            detail.put("columns", entry.getValue());
            tableDetails.add(detail);
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("regex", WORKFLOW_REGEX);
        response.put("tableCount", tableDetails.size());
        response.put("tables", tableDetails);
        response.put("recommendedCanonicalTargets", List.of(
                Map.of("domain", "Leave", "target", "erp_leave_request"),
                Map.of("domain", "Approval Workflow", "target", "leave_approval_chain"),
                Map.of("domain", "Supervision", "target", "position_supervisors"),
            Map.of("domain", "Org Hierarchy", "target", "eng_position_hierarchy"),
            Map.of("domain", "Salary Advance Workflow", "target", "salary_advance_request")
        ));
        return response;
    }

    @Cacheable(cacheNames = "schemaSnapshots", key = "'leavePolicies'", sync = true)
    public Map<String, Object> getLeavePolicySnapshot() {
        Map<String, Object> response = new LinkedHashMap<>();

        LeavePolicyDataSnapshot snapshot = loadLeavePolicyData();
        List<Map<String, Object>> leaveTypes = snapshot.leaveTypes();
        List<Map<String, Object>> leavePolicy = snapshot.leavePolicyRules();

        List<Map<String, Object>> mergedLeaveTypes = new ArrayList<>(leaveTypes);
        Set<String> knownLeaveNames = new HashSet<>();
        for (Map<String, Object> leaveType : leaveTypes) {
            knownLeaveNames.add(normalizeLeaveKey(leaveType.get("leave_type_name")));
            knownLeaveNames.add(normalizeLeaveKey(leaveType.get("leave_type_code")));
        }

        for (Map<String, Object> policyRule : leavePolicy) {
            String policyLeaveName = String.valueOf(policyRule.get("leave_type") == null ? "" : policyRule.get("leave_type")).trim();
            String normalizedPolicyLeaveName = normalizeLeaveKey(policyLeaveName);
            if (normalizedPolicyLeaveName.isBlank() || knownLeaveNames.contains(normalizedPolicyLeaveName)) {
                continue;
            }

            Map<String, Object> syntheticLeaveType = new LinkedHashMap<>();
            syntheticLeaveType.put("leave_type_id", null);
            syntheticLeaveType.put("leave_type_code", toSyntheticLeaveCode(policyLeaveName));
            syntheticLeaveType.put("leave_type_name", policyLeaveName);
            syntheticLeaveType.put("description", "Loaded from ERP leave policy rules.");
            syntheticLeaveType.put("requires_approval", Boolean.TRUE);
            syntheticLeaveType.put("is_paid", !normalizedPolicyLeaveName.contains("UNPAID"));
            syntheticLeaveType.put("is_cumulative", normalizedPolicyLeaveName.contains("ANNUAL") || normalizedPolicyLeaveName.contains("VACATION"));
            syntheticLeaveType.put("max_days_per_month", null);
            syntheticLeaveType.put("max_days_per_year", null);
            syntheticLeaveType.put("applicable_to", "As configured in ERP policy");
            syntheticLeaveType.put("requires_supervisor_notification", Boolean.TRUE);
            syntheticLeaveType.put("requires_hr_notification", Boolean.TRUE);
            mergedLeaveTypes.add(syntheticLeaveType);
            knownLeaveNames.add(normalizedPolicyLeaveName);
        }

        if ((snapshot.localLeaveBalanceConfigured() || containsLeaveRule(leavePolicy, "LOCAL_LEAVE")) && !knownLeaveNames.contains("LOCAL_LEAVE")) {
            Map<String, Object> localLeaveType = new LinkedHashMap<>();
            localLeaveType.put("leave_type_id", null);
            localLeaveType.put("leave_type_code", "LOCAL_LEAVE");
            localLeaveType.put("leave_type_name", "Local Leave");
            localLeaveType.put("description", "Loaded from ERP leave balances configuration.");
            localLeaveType.put("requires_approval", Boolean.TRUE);
            localLeaveType.put("is_paid", Boolean.TRUE);
            localLeaveType.put("is_cumulative", Boolean.FALSE);
            localLeaveType.put("max_days_per_month", null);
            localLeaveType.put("max_days_per_year", null);
            localLeaveType.put("applicable_to", "As configured in ERP balances");
            localLeaveType.put("requires_supervisor_notification", Boolean.TRUE);
            localLeaveType.put("requires_hr_notification", Boolean.TRUE);
            mergedLeaveTypes.add(localLeaveType);
            knownLeaveNames.add("LOCAL_LEAVE");
        }

        mergedLeaveTypes.sort(Comparator.comparing(item -> String.valueOf(item.get("leave_type_name") == null ? "" : item.get("leave_type_name")), String.CASE_INSENSITIVE_ORDER));

        response.put("tables", Map.of(
                "leave_types_exists", snapshot.leaveTypesTableExists(),
                "leave_policy_exists", snapshot.leavePolicyTableExists()
        ));
        response.put("source", snapshot.source());
        response.put("sourceLabel", snapshot.sourceLabel());
        response.put("uniformAcrossAuthorities", true);
        response.put("authoritiesCovered", 116);
        response.put("leaveTypesCount", mergedLeaveTypes.size());
        response.put("leavePolicyRulesCount", leavePolicy.size());
        response.put("leaveTypes", mergedLeaveTypes);
        response.put("leavePolicyRules", leavePolicy);

        return response;
    }

    @Cacheable(cacheNames = "schemaSnapshots", key = "'globalPolicies'", sync = true)
    public Map<String, Object> getGlobalPolicySnapshot() {
        Map<String, Object> response = new LinkedHashMap<>();

        response.put("uniformAcrossAuthorities", true);
        response.put("authoritiesCovered", 116);

        Map<String, Object> leave = new LinkedHashMap<>();
        leave.put("tableExists", tableExists("leave_policy"));
        leave.put("policyRulesCount", countRowsIfTableExists("leave_policy"));
        leave.put("uniformAcrossAuthorities", true);
        leave.put("authoritiesCovered", 116);

        Map<String, Object> salaryAdvance = new LinkedHashMap<>();
        salaryAdvance.put("policyTableExists", tableExists("salary_advance_policy"));
        salaryAdvance.put("policyCount", countRowsIfTableExists("salary_advance_policy"));
        salaryAdvance.put("requestTableExists", tableExists("salary_advance_request"));
        salaryAdvance.put("requestCount", countRowsIfTableExists("salary_advance_request"));
        salaryAdvance.put("workflowEventTableExists", tableExists("salary_advance_workflow_event"));
        salaryAdvance.put("workflowEventCount", countRowsIfTableExists("salary_advance_workflow_event"));
        salaryAdvance.put("deductionTableExists", tableExists("salary_advance_deduction"));
        salaryAdvance.put("pendingDeductionCount", countPendingDeductions());
        salaryAdvance.put("eligibilityCheckBeforeHeadApproval", true);
        salaryAdvance.put("workflowPath", List.of(
            "Applicant",
            "Eligibility Check (running advance + policy checks)",
            "Head of Institution (Council Secretary or Town Clerk)",
            "Finance",
            "Disbursement"
        ));
        salaryAdvance.put("uniformAcrossAuthorities", true);
        salaryAdvance.put("authoritiesCovered", 116);

        Map<String, Object> payroll = new LinkedHashMap<>();
        payroll.put("tableExists", tableExists("erp_payroll_record"));
        payroll.put("recordsCount", countRowsIfTableExists("erp_payroll_record"));
        payroll.put("salaryStructureUniformAcrossAuthorities", true);
        payroll.put("authoritiesCovered", 116);

        Map<String, Object> performanceManagement = new LinkedHashMap<>();
        performanceManagement.put("tableExists", tableExists("performance_management_policy"));
        performanceManagement.put("policyCount", countRowsIfTableExists("performance_management_policy"));
        performanceManagement.put("uniformAcrossAuthorities", true);
        performanceManagement.put("authoritiesCovered", 116);

        response.put("policies", Map.of(
                "leave", leave,
                "salaryAdvance", salaryAdvance,
                "payroll", payroll,
                "performanceManagement", performanceManagement
        ));

        return response;
    }

    @Cacheable(cacheNames = "schemaSnapshots", key = "'holidayCalendar'", sync = true)
    public Map<String, Object> getHolidayCalendarSnapshot() {
        HolidayCalendarDataSnapshot snapshot = loadHolidayCalendarData();

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("source", snapshot.source());
        response.put("sourceLabel", snapshot.sourceLabel());
        response.put("holidayCount", snapshot.holidays().size());
        response.put("label", "Zambia national");
        response.put("regions", List.of(Map.of("code", "zambia", "label", "Zambia national")));
        response.put("weekendDays", List.of(0, 6));
        response.put("holidays", snapshot.holidays());
        return response;
    }

    public Map<String, Object> calculateLeaveReturnDate(String leaveType, CompassionateLeaveRelation compassionateRelation, LocalDate startDate, int daysOff) {
        if (startDate == null) {
            throw new IllegalArgumentException("Start date is required for leave calculation");
        }
        if (daysOff < 1) {
            throw new IllegalArgumentException("Days off must be at least 1");
        }

        String normalizedLeaveType = normalizeLeaveKey(leaveType);
        if ("MATERNITY".equals(normalizedLeaveType)) {
            return buildFixedInclusiveLeaveResponse(startDate, 98, normalizedLeaveType);
        }
        if ("PATERNITY".equals(normalizedLeaveType)) {
            return buildFixedInclusiveLeaveResponse(startDate, 10, normalizedLeaveType);
        }
        if ("COMPASSIONATE".equals(normalizedLeaveType)) {
            int maxDays = compassionateRelation == CompassionateLeaveRelation.SPOUSE ? 21 : 14;
            if (daysOff > maxDays) {
                throw new IllegalArgumentException(
                        compassionateRelation == CompassionateLeaveRelation.SPOUSE
                                ? "Compassionate leave for a spouse cannot exceed 21 calendar days."
                                : "Compassionate leave for a child or parent cannot exceed 14 calendar days."
                );
            }

            Map<String, Object> response = new LinkedHashMap<>();
            response.put("leaveType", normalizedLeaveType);
            response.put("source", loadLeavePolicyData().source());
            response.put("requestedDaysOff", daysOff);
            response.put("policyFixedDays", null);
            response.put("policyMaxDays", maxDays);
            response.put("startDate", startDate.toString());
            response.put("effectiveStartDate", startDate.toString());
            response.put("endDate", startDate.plusDays(daysOff - 1L).toString());
            response.put("returnToWorkDate", startDate.plusDays(daysOff).toString());
            response.put("weekendDaysSkipped", 0);
            response.put("publicHolidaysSkipped", 0);
            response.put("startAdjusted", false);
            response.put("usesHolidayCalendar", false);
            response.put("calculationMode", "INCLUSIVE_CALENDAR_DAYS");
            response.put("deductsAccruedBalance", false);
            return response;
        }

        LeavePolicyDataSnapshot leaveSnapshot = loadLeavePolicyData();
        HolidayCalendarDataSnapshot holidaySnapshot = loadHolidayCalendarData();
        Map<String, Object> matchingRule = findMatchingLeaveRule(leaveSnapshot.leavePolicyRules(), leaveType);
        Integer fixedDays = firstPositiveInteger(matchingRule, "fixed_days");
        Integer maxDays = firstPositiveInteger(matchingRule, "max_duration", "max_days", "fixed_days");

        Set<DayOfWeek> weekendDays = Set.of(DayOfWeek.SATURDAY, DayOfWeek.SUNDAY);
        Set<LocalDate> publicHolidays = new LinkedHashSet<>();
        for (Map<String, Object> holiday : holidaySnapshot.holidays()) {
            LocalDate date = parseIsoLocalDate(holiday.get("date"));
            if (date != null) {
                publicHolidays.add(date);
            }
        }

        int remainingDays = daysOff;
        int skippedWeekendDays = 0;
        int skippedHolidayDays = 0;
        LocalDate current = startDate;
        LocalDate effectiveStartDate = null;
        LocalDate endDate = null;

        while (remainingDays > 0) {
            boolean weekend = weekendDays.contains(current.getDayOfWeek());
            boolean holiday = publicHolidays.contains(current);
            if (!weekend && !holiday) {
                if (effectiveStartDate == null) {
                    effectiveStartDate = current;
                }
                endDate = current;
                remainingDays -= 1;
            } else {
                if (weekend) {
                    skippedWeekendDays += 1;
                }
                if (holiday) {
                    skippedHolidayDays += 1;
                }
            }

            if (remainingDays > 0) {
                current = current.plusDays(1);
            }
        }

        LocalDate returnToWorkDate = endDate == null ? startDate : endDate.plusDays(1);
        while (isNonWorkingDay(returnToWorkDate, weekendDays, publicHolidays)) {
            if (weekendDays.contains(returnToWorkDate.getDayOfWeek())) {
                skippedWeekendDays += 1;
            }
            if (publicHolidays.contains(returnToWorkDate)) {
                skippedHolidayDays += 1;
            }
            returnToWorkDate = returnToWorkDate.plusDays(1);
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("leaveType", normalizedLeaveType);
        response.put("source", leaveSnapshot.source());
        response.put("requestedDaysOff", daysOff);
        response.put("policyFixedDays", fixedDays);
        response.put("policyMaxDays", maxDays);
        response.put("startDate", startDate.toString());
        response.put("effectiveStartDate", effectiveStartDate == null ? startDate.toString() : effectiveStartDate.toString());
        response.put("endDate", endDate == null ? startDate.toString() : endDate.toString());
        response.put("returnToWorkDate", returnToWorkDate.toString());
        response.put("weekendDaysSkipped", skippedWeekendDays);
        response.put("publicHolidaysSkipped", skippedHolidayDays);
        response.put("startAdjusted", effectiveStartDate != null && !startDate.equals(effectiveStartDate));
        response.put("usesHolidayCalendar", !publicHolidays.isEmpty());
        response.put("calculationMode", "WORKING_DAYS_ONLY");
        response.put("deductsAccruedBalance", "LOCAL".equals(normalizedLeaveType) || "ANNUAL".equals(normalizedLeaveType) || "VACATION".equals(normalizedLeaveType));
        if (maxDays != null && daysOff > maxDays) {
            response.put("policyWarning", "Requested days exceed the configured ERP maximum for this leave type.");
        }
        return response;
    }

    private Map<String, Object> buildFixedInclusiveLeaveResponse(LocalDate startDate, int fixedDays, String normalizedLeaveType) {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("leaveType", normalizedLeaveType);
        response.put("source", loadLeavePolicyData().source());
        response.put("requestedDaysOff", fixedDays);
        response.put("policyFixedDays", fixedDays);
        response.put("policyMaxDays", fixedDays);
        response.put("startDate", startDate.toString());
        response.put("effectiveStartDate", startDate.toString());
        response.put("endDate", startDate.plusDays(fixedDays - 1L).toString());
        response.put("returnToWorkDate", startDate.plusDays(fixedDays).toString());
        response.put("weekendDaysSkipped", 0);
        response.put("publicHolidaysSkipped", 0);
        response.put("startAdjusted", false);
        response.put("usesHolidayCalendar", false);
        response.put("calculationMode", "FIXED_INCLUSIVE");
        response.put("deductsAccruedBalance", false);
        return response;
    }

    private LeavePolicyDataSnapshot loadLeavePolicyData() {
        boolean leaveTypesTableExists = tableExists("leave_types");
        boolean leavePolicyTableExists = tableExists("leave_policy");
        boolean localLeaveBalanceConfigured = columnExists("leave_balances", "local_leave_balance");

        List<Map<String, Object>> leaveTypes = leaveTypesTableExists
                ? jdbcTemplate.queryForList(
                """
                SELECT leave_type_id,
                       leave_type_code,
                       leave_type_name,
                       description,
                       requires_approval,
                       is_paid,
                       is_cumulative,
                       max_days_per_month,
                       max_days_per_year,
                       applicable_to,
                       requires_supervisor_notification,
                       requires_hr_notification
                FROM leave_types
                ORDER BY leave_type_name
                """
        )
                : new ArrayList<>();

        List<Map<String, Object>> leavePolicy = leavePolicyTableExists
                ? jdbcTemplate.queryForList(
                """
                SELECT leave_type,
                       division,
                       accrual_rate,
                       max_days,
                       carry_forward,
                       eligibility,
                       fixed_days,
                       max_accumulation,
                       max_duration,
                       advance_notice
                FROM leave_policy
                ORDER BY leave_type, division NULLS LAST
                """
        )
                : new ArrayList<>();

        boolean usedFallback = false;
        boolean primaryHasAnyData = !leaveTypes.isEmpty() || !leavePolicy.isEmpty();

        if (leaveTypes.isEmpty() || leavePolicy.isEmpty()) {
            Optional<LeavePolicyDataSnapshot> fallbackSnapshot = loadSqliteLeavePolicyData();
            if (fallbackSnapshot.isPresent()) {
                LeavePolicyDataSnapshot sqliteSnapshot = fallbackSnapshot.get();

                if (leaveTypes.isEmpty() && !sqliteSnapshot.leaveTypes().isEmpty()) {
                    leaveTypes = new ArrayList<>(sqliteSnapshot.leaveTypes());
                    leaveTypesTableExists = sqliteSnapshot.leaveTypesTableExists();
                    usedFallback = true;
                }
                if (leavePolicy.isEmpty() && !sqliteSnapshot.leavePolicyRules().isEmpty()) {
                    leavePolicy = new ArrayList<>(sqliteSnapshot.leavePolicyRules());
                    leavePolicyTableExists = sqliteSnapshot.leavePolicyTableExists();
                    usedFallback = true;
                }

                localLeaveBalanceConfigured = localLeaveBalanceConfigured || sqliteSnapshot.localLeaveBalanceConfigured();

                if (usedFallback) {
                    String source = primaryHasAnyData ? "hybrid" : sqliteSnapshot.source();
                    String sourceLabel = primaryHasAnyData
                            ? "Primary ERP + " + sqliteSnapshot.sourceLabel()
                            : sqliteSnapshot.sourceLabel();
                    return withAugmentedLeavePolicies(new LeavePolicyDataSnapshot(leaveTypes, leavePolicy, leaveTypesTableExists, leavePolicyTableExists, localLeaveBalanceConfigured, source, sourceLabel));
                }
            }
        }

        return withAugmentedLeavePolicies(new LeavePolicyDataSnapshot(
                leaveTypes,
                leavePolicy,
                leaveTypesTableExists,
                leavePolicyTableExists,
                localLeaveBalanceConfigured,
                "primary-datasource",
                "Primary ERP datasource"
        ));
    }

    private Optional<LeavePolicyDataSnapshot> loadSqliteLeavePolicyData() {
        Optional<Path> sqlitePath = resolveSqliteFallbackPath();
        if (sqlitePath.isEmpty()) {
            return Optional.empty();
        }

        Path path = sqlitePath.get();
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:" + path.toAbsolutePath())) {
            boolean leaveTypesTableExists = sqliteTableExists(connection, "leave_types");
            boolean leavePolicyTableExists = sqliteTableExists(connection, "leave_policy");
            boolean localLeaveBalanceConfigured = sqliteColumnExists(connection, "leave_balances", "local_leave_balance");

            List<Map<String, Object>> leaveTypes = leaveTypesTableExists
                    ? queryForList(connection,
                    """
                    SELECT leave_type_id,
                           leave_type_code,
                           leave_type_name,
                           description,
                           requires_approval,
                           is_paid,
                           is_cumulative,
                           max_days_per_month,
                           max_days_per_year,
                           applicable_to,
                           requires_supervisor_notification,
                           requires_hr_notification
                    FROM leave_types
                    ORDER BY leave_type_name
                    """
            )
                    : List.of();

            List<Map<String, Object>> leavePolicy = leavePolicyTableExists
                    ? queryForList(connection,
                    """
                    SELECT leave_type,
                           division,
                           accrual_rate,
                           max_days,
                           carry_forward,
                           eligibility,
                           fixed_days,
                           max_accumulation,
                           max_duration,
                           advance_notice
                    FROM leave_policy
                    ORDER BY leave_type, division
                    """
            )
                    : List.of();

            if (leaveTypes.isEmpty() && leavePolicy.isEmpty()) {
                return Optional.empty();
            }

            return Optional.of(new LeavePolicyDataSnapshot(
                    new ArrayList<>(leaveTypes),
                    new ArrayList<>(leavePolicy),
                    leaveTypesTableExists,
                    leavePolicyTableExists,
                    localLeaveBalanceConfigured,
                    "sqlite-fallback",
                    "SQLite fallback (" + path.getFileName() + ")"
            ));
        } catch (SQLException exception) {
            LOGGER.warn("Unable to read leave policy fallback from {}", path, exception);
            return Optional.empty();
        }
    }

    private HolidayCalendarDataSnapshot loadHolidayCalendarData() {
        boolean holidaysTableExists = tableExists("holidays");
        boolean publicHolidaysTableExists = tableExists("public_holidays");

        List<Map<String, Object>> holidays = new ArrayList<>();
        if (holidaysTableExists) {
            holidays = jdbcTemplate.query(
                    "SELECT holiday_date, description FROM holidays ORDER BY holiday_date",
                    (resultSet, rowNum) -> {
                        Map<String, Object> holiday = new LinkedHashMap<>();
                        holiday.put("date", resultSet.getString("holiday_date"));
                        holiday.put("name", resultSet.getString("description"));
                        holiday.put("regionCode", "zambia");
                        return holiday;
                    }
            );
        } else if (publicHolidaysTableExists) {
            holidays = jdbcTemplate.query(
                    """
                    SELECT holiday_date,
                           COALESCE(name, 'Public Holiday') AS holiday_name,
                           authority_code
                    FROM public_holidays
                    WHERE authority_code IS NULL
                    ORDER BY holiday_date, holiday_name
                    """,
                    (resultSet, rowNum) -> {
                        Map<String, Object> holiday = new LinkedHashMap<>();
                        holiday.put("date", resultSet.getString("holiday_date"));
                        holiday.put("name", resultSet.getString("holiday_name"));
                        holiday.put("regionCode", "zambia");
                        return holiday;
                    }
            );
        }

        if (!holidays.isEmpty()) {
            return new HolidayCalendarDataSnapshot(new ArrayList<>(holidays), "primary-datasource", "Primary ERP datasource");
        }

        return loadSqliteHolidayCalendarData().orElseGet(() -> new HolidayCalendarDataSnapshot(
                List.of(),
                "unavailable",
                "No holiday data available"
        ));
    }

    private Optional<HolidayCalendarDataSnapshot> loadSqliteHolidayCalendarData() {
        Optional<Path> sqlitePath = resolveSqliteFallbackPath();
        if (sqlitePath.isEmpty()) {
            return Optional.empty();
        }

        Path path = sqlitePath.get();
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:" + path.toAbsolutePath())) {
            if (!sqliteTableExists(connection, "holidays")) {
                return Optional.empty();
            }

            List<Map<String, Object>> holidays = queryForList(connection,
                    """
                    SELECT holiday_date AS date,
                           description AS name,
                           'zambia' AS regionCode
                    FROM holidays
                    ORDER BY holiday_date
                    """
            );

            if (holidays.isEmpty()) {
                return Optional.empty();
            }

            return Optional.of(new HolidayCalendarDataSnapshot(
                    new ArrayList<>(holidays),
                    "sqlite-fallback",
                    "SQLite fallback (" + path.getFileName() + ")"
            ));
        } catch (SQLException exception) {
            LOGGER.warn("Unable to read holiday fallback from {}", path, exception);
            return Optional.empty();
        }
    }

    private LeavePolicyDataSnapshot withAugmentedLeavePolicies(LeavePolicyDataSnapshot snapshot) {
        List<Map<String, Object>> leaveTypes = new ArrayList<>(snapshot.leaveTypes());
        List<Map<String, Object>> leavePolicy = new ArrayList<>(snapshot.leavePolicyRules());

        boolean hasFamilyCareType = leaveTypes.stream().anyMatch(item -> {
            String normalizedTypeName = normalizeLeaveKey(item.get("leave_type_name"));
            String normalizedTypeCode = normalizeLeaveKey(item.get("leave_type_code"));
            return "FAMILY_CARE".equals(normalizedTypeCode) || "FAMILY_CARE_LEAVE".equals(normalizedTypeName);
        });
        if (!hasFamilyCareType) {
            Map<String, Object> familyCareType = new LinkedHashMap<>();
            familyCareType.put("leave_type_id", null);
            familyCareType.put("leave_type_code", "FAMILY_CARE");
            familyCareType.put("leave_type_name", "Family Care Leave");
            familyCareType.put("description", "Family Care Leave is limited to 3 paid days in a year for the care, health, or education needs of an employee's child, spouse, dependent, or parent. It is not cumulative and does not reduce earned leave.");
            familyCareType.put("requires_approval", Boolean.TRUE);
            familyCareType.put("is_paid", Boolean.TRUE);
            familyCareType.put("is_cumulative", Boolean.FALSE);
            familyCareType.put("max_days_per_month", null);
            familyCareType.put("max_days_per_year", 3);
            familyCareType.put("applicable_to", "Employees caring for a child, spouse, dependent, or parent");
            familyCareType.put("requires_supervisor_notification", Boolean.TRUE);
            familyCareType.put("requires_hr_notification", Boolean.TRUE);
            leaveTypes.add(familyCareType);
        }

        if (!containsLeaveRule(leavePolicy, "FAMILY_CARE_LEAVE")) {
            Map<String, Object> familyCareRule = new LinkedHashMap<>();
            familyCareRule.put("leave_type", "Family Care Leave");
            familyCareRule.put("division", null);
            familyCareRule.put("accrual_rate", null);
            familyCareRule.put("max_days", 3);
            familyCareRule.put("carry_forward", 0);
            familyCareRule.put("eligibility", "Child, spouse, dependent, or parent");
            familyCareRule.put("fixed_days", null);
            familyCareRule.put("max_accumulation", 3);
            familyCareRule.put("max_duration", 3);
            familyCareRule.put("advance_notice", 0);
            leavePolicy.add(familyCareRule);
        }

        return new LeavePolicyDataSnapshot(
                leaveTypes,
                leavePolicy,
                snapshot.leaveTypesTableExists(),
                snapshot.leavePolicyTableExists(),
                snapshot.localLeaveBalanceConfigured(),
                snapshot.source(),
                snapshot.sourceLabel()
        );
    }

    private Optional<Path> resolveSqliteFallbackPath() {
        Set<Path> candidates = new LinkedHashSet<>();
        Path userDir = Paths.get(System.getProperty("user.dir", ".")).toAbsolutePath().normalize();

        if (!configuredSqliteFallbackPath.isBlank()) {
            candidates.add(userDir.resolve(configuredSqliteFallbackPath).normalize());
            candidates.add(Paths.get(configuredSqliteFallbackPath).toAbsolutePath().normalize());
        }

        candidates.add(userDir.resolve("hr_platform.db").normalize());
        candidates.add(userDir.resolve("../hr_platform.db").normalize());
        candidates.add(userDir.resolve("../../hr_platform.db").normalize());

        return candidates.stream().filter(Files::isRegularFile).findFirst();
    }

    private boolean sqliteTableExists(Connection connection, String tableName) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND LOWER(name) = LOWER(?)"
        )) {
            statement.setString(1, tableName);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() && resultSet.getInt(1) > 0;
            }
        }
    }

    private boolean sqliteColumnExists(Connection connection, String tableName, String columnName) throws SQLException {
        if (!sqliteTableExists(connection, tableName)) {
            return false;
        }

        try (PreparedStatement statement = connection.prepareStatement("PRAGMA table_info(" + tableName + ")");
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                if (columnName.equalsIgnoreCase(resultSet.getString("name"))) {
                    return true;
                }
            }
        }
        return false;
    }

    private List<Map<String, Object>> queryForList(Connection connection, String sql) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            List<Map<String, Object>> rows = new ArrayList<>();
            ResultSetMetaData metadata = resultSet.getMetaData();
            int columnCount = metadata.getColumnCount();

            while (resultSet.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                for (int index = 1; index <= columnCount; index++) {
                    row.put(metadata.getColumnLabel(index), resultSet.getObject(index));
                }
                rows.add(row);
            }
            return rows;
        }
    }

    private boolean containsLeaveRule(List<Map<String, Object>> leavePolicy, String leaveCode) {
        return leavePolicy.stream().anyMatch(item -> leaveCode.equals(normalizeLeaveKey(item.get("leave_type"))));
    }

    private Map<String, Object> findMatchingLeaveRule(List<Map<String, Object>> leavePolicy, String leaveType) {
        String normalized = normalizeLeaveKey(leaveType);
        Set<String> candidateKeys = new LinkedHashSet<>();
        candidateKeys.add(normalized);
        if (!normalized.endsWith("_LEAVE")) {
            candidateKeys.add(normalized + "_LEAVE");
        }
        candidateKeys.add(normalized.replace("_LEAVE", ""));

        return leavePolicy.stream()
                .filter(item -> candidateKeys.contains(normalizeLeaveKey(item.get("leave_type"))))
                .findFirst()
                .orElse(null);
    }

    private Integer firstPositiveInteger(Map<String, Object> row, String... keys) {
        if (row == null || keys == null) {
            return null;
        }

        for (String key : keys) {
            Object raw = row.get(key);
            if (raw == null) {
                continue;
            }
            try {
                int parsed = Integer.parseInt(String.valueOf(raw));
                if (parsed > 0) {
                    return parsed;
                }
            } catch (NumberFormatException ignored) {
            }
        }
        return null;
    }

    private LocalDate parseIsoLocalDate(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return LocalDate.parse(String.valueOf(value));
        } catch (Exception ignored) {
            return null;
        }
    }

    private boolean isNonWorkingDay(LocalDate date, Set<DayOfWeek> weekendDays, Set<LocalDate> publicHolidays) {
        return weekendDays.contains(date.getDayOfWeek()) || publicHolidays.contains(date);
    }

    private boolean tableExists(String tableName) {
        Integer count = jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE LOWER(table_schema) = 'public'
                  AND table_name = ?
                """,
                Integer.class,
                tableName
        );
        return count != null && count > 0;
    }

    private boolean columnExists(String tableName, String columnName) {
        Integer count = jdbcTemplate.queryForObject(
                """
                SELECT COUNT(*)
                FROM information_schema.columns
                WHERE LOWER(table_schema) = 'public'
                  AND table_name = ?
                  AND column_name = ?
                """,
                Integer.class,
                tableName,
                columnName
        );
        return count != null && count > 0;
    }

    private long countRowsIfTableExists(String tableName) {
        if (!tableExists(tableName)) {
            return 0L;
        }

        return jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM " + tableName,
                Long.class
        );
    }

    private long countPendingDeductions() {
        if (!tableExists("salary_advance_deduction")) {
            return 0L;
        }

        Long count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM salary_advance_deduction WHERE status = 'PENDING'",
                Long.class
        );
        return count == null ? 0L : count;
    }

    private String normalizeLeaveKey(Object value) {
        return String.valueOf(value == null ? "" : value)
                .trim()
                .replaceAll("[^A-Za-z0-9]+", "_")
                .replaceAll("^_+|_+$", "")
                .toUpperCase();
    }

    private String toSyntheticLeaveCode(String value) {
        return normalizeLeaveKey(value);
    }

    private record LeavePolicyDataSnapshot(
            List<Map<String, Object>> leaveTypes,
            List<Map<String, Object>> leavePolicyRules,
            boolean leaveTypesTableExists,
            boolean leavePolicyTableExists,
            boolean localLeaveBalanceConfigured,
            String source,
            String sourceLabel
    ) {
    }

    private record HolidayCalendarDataSnapshot(
            List<Map<String, Object>> holidays,
            String source,
            String sourceLabel
    ) {
    }
}