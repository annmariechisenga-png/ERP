package com.localgov.web.schema;

import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class SchemaIntrospectionServiceTest {

    @Test
    void fallsBackToSqliteLeaveDataWhenPrimaryDatasourceHasNoLeaveTables() throws Exception {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.h2.Driver");
        dataSource.setUrl("jdbc:h2:mem:schema_introspection_test;MODE=PostgreSQL;DB_CLOSE_DELAY=-1");
        dataSource.setUsername("sa");
        dataSource.setPassword("");

        Path sqlitePath = Files.createTempFile("leave-policy-fallback", ".db");
        try {
            seedSqlite(sqlitePath);

            SchemaIntrospectionService service = new SchemaIntrospectionService(
                    new JdbcTemplate(dataSource),
                    sqlitePath.toString()
            );

            Map<String, Object> snapshot = service.getLeavePolicySnapshot();

            assertThat(snapshot.get("source")).isEqualTo("sqlite-fallback");
            assertThat(((Number) snapshot.get("leaveTypesCount")).intValue()).isGreaterThanOrEqualTo(4);
            assertThat(((Number) snapshot.get("leavePolicyRulesCount")).intValue()).isGreaterThanOrEqualTo(3);

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> leaveTypes = (List<Map<String, Object>>) snapshot.get("leaveTypes");

            assertThat(leaveTypes)
                    .extracting(item -> String.valueOf(item.get("leave_type_name")))
                    .contains("Annual Leave", "Mother's Day", "Local Leave", "Family Care Leave");
        } finally {
            Files.deleteIfExists(sqlitePath);
        }
    }

    @Test
    void fallsBackToSqliteHolidayDataWhenPrimaryDatasourceHasNoHolidayTables() throws Exception {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("org.h2.Driver");
        dataSource.setUrl("jdbc:h2:mem:holiday_introspection_test;MODE=PostgreSQL;DB_CLOSE_DELAY=-1");
        dataSource.setUsername("sa");
        dataSource.setPassword("");

        Path sqlitePath = Files.createTempFile("holiday-fallback", ".db");
        try {
            seedSqlite(sqlitePath);

            SchemaIntrospectionService service = new SchemaIntrospectionService(
                    new JdbcTemplate(dataSource),
                    sqlitePath.toString()
            );

            Map<String, Object> snapshot = service.getHolidayCalendarSnapshot();

            assertThat(snapshot.get("source")).isEqualTo("sqlite-fallback");
            assertThat(((Number) snapshot.get("holidayCount")).intValue()).isEqualTo(2);

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> holidays = (List<Map<String, Object>>) snapshot.get("holidays");

            assertThat(holidays)
                    .extracting(item -> String.valueOf(item.get("name")))
                    .containsExactly("New Year's Day", "Good Friday");
        } finally {
            Files.deleteIfExists(sqlitePath);
        }
    }

    private void seedSqlite(Path sqlitePath) throws Exception {
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite:" + sqlitePath.toAbsolutePath());
             Statement statement = connection.createStatement()) {
            statement.executeUpdate("""
                    CREATE TABLE leave_types (
                        leave_type_id INTEGER PRIMARY KEY,
                        leave_type_code TEXT NOT NULL,
                        leave_type_name TEXT NOT NULL,
                        description TEXT,
                        requires_approval BOOLEAN,
                        is_paid BOOLEAN,
                        is_cumulative BOOLEAN,
                        max_days_per_month INTEGER,
                        max_days_per_year INTEGER,
                        applicable_to TEXT,
                        requires_supervisor_notification BOOLEAN,
                        requires_hr_notification BOOLEAN
                    )
                    """);

            statement.executeUpdate("""
                    CREATE TABLE leave_policy (
                        leave_type TEXT,
                        division TEXT,
                        accrual_rate REAL,
                        max_days INTEGER,
                        carry_forward INTEGER,
                        eligibility TEXT,
                        fixed_days INTEGER,
                        max_accumulation INTEGER,
                        max_duration INTEGER,
                        advance_notice INTEGER
                    )
                    """);

            statement.executeUpdate("""
                    CREATE TABLE leave_balances (
                        employee_id INTEGER PRIMARY KEY,
                        local_leave_balance INTEGER,
                        vacation_leave_balance INTEGER
                    )
                    """);

            statement.executeUpdate("""
                    INSERT INTO leave_types (
                        leave_type_id,
                        leave_type_code,
                        leave_type_name,
                        description,
                        requires_approval,
                        is_paid,
                        is_cumulative,
                        applicable_to,
                        requires_supervisor_notification,
                        requires_hr_notification
                    ) VALUES (
                        1,
                        'MOTHERS_DAY',
                        'Mother''s Day',
                        'One day off per month for female officers.',
                        1,
                        1,
                        0,
                        'Female officers',
                        1,
                        1
                    )
                    """);

            statement.executeUpdate("""
                    INSERT INTO leave_policy (leave_type, division, accrual_rate, max_days)
                    VALUES
                        ('Annual Leave', 'Division I', 3.5, 42),
                        ('Sick Leave', NULL, NULL, 14)
                    """);

            statement.executeUpdate("""
                    INSERT INTO leave_balances (employee_id, local_leave_balance, vacation_leave_balance)
                    VALUES (101, 4, 12)
                    """);

            statement.executeUpdate("""
                    CREATE TABLE holidays (
                        holiday_date TEXT PRIMARY KEY,
                        description TEXT
                    )
                    """);

            statement.executeUpdate("""
                    INSERT INTO holidays (holiday_date, description)
                    VALUES
                        ('2026-01-01', 'New Year''s Day'),
                        ('2026-04-03', 'Good Friday')
                    """);
        }
    }
}
