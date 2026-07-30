package com.localgov.service.leave;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.EmployeeRole;
import com.localgov.domain.model.LeaveBalance;
import com.localgov.domain.model.LeavePolicy;
import com.localgov.repository.EmployeeRepository;
import com.localgov.repository.LeaveBalanceRepository;
import com.localgov.repository.LeavePolicyRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class LeaveAccrualServiceTest {

    @Mock private EmployeeRepository employeeRepository;
    @Mock private LeaveBalanceRepository leaveBalanceRepository;
    @Mock private LeavePolicyRepository leavePolicyRepository;

    private LeaveAccrualService accrualService;

    @BeforeEach
    void setUp() {
        accrualService = new LeaveAccrualService(employeeRepository, leaveBalanceRepository, leavePolicyRepository);
    }

    @Test
    void accruesVacationLeaveFromPolicyRate() {
        Employee emp = buildEmployee(1L, "I");
        LeaveBalance balance = buildBalance(1L, 0, 0);
        LeavePolicy vacationPolicy = buildPolicy("Vacation Leave", "I", 3.5, 230);

        when(employeeRepository.findByActiveTrue()).thenReturn(List.of(emp));
        when(leaveBalanceRepository.findById(1L)).thenReturn(Optional.of(balance));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Vacation Leave", "I"))
                .thenReturn(Optional.of(vacationPolicy));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Local Leave", "I"))
                .thenReturn(Optional.empty());
        when(leaveBalanceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        int updated = accrualService.processMonthlyAccrual();

        assertThat(updated).isEqualTo(1);
        ArgumentCaptor<LeaveBalance> captor = ArgumentCaptor.forClass(LeaveBalance.class);
        verify(leaveBalanceRepository).save(captor.capture());
        assertThat(captor.getValue().getVacationLeaveBalance()).isEqualTo(3); // floor(3.5)
    }

    @Test
    void respectsMaxAccumulationCap() {
        Employee emp = buildEmployee(2L, "II");
        LeaveBalance balance = buildBalance(2L, 0, 204);
        LeavePolicy policy = buildPolicy("Vacation Leave", "II", 3.0, 205);

        when(employeeRepository.findByActiveTrue()).thenReturn(List.of(emp));
        when(leaveBalanceRepository.findById(2L)).thenReturn(Optional.of(balance));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Vacation Leave", "II"))
                .thenReturn(Optional.of(policy));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Local Leave", "II"))
                .thenReturn(Optional.empty());
        when(leaveBalanceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        accrualService.processMonthlyAccrual();

        ArgumentCaptor<LeaveBalance> captor = ArgumentCaptor.forClass(LeaveBalance.class);
        verify(leaveBalanceRepository).save(captor.capture());
        assertThat(captor.getValue().getVacationLeaveBalance()).isEqualTo(205); // capped at max
    }

    @Test
    void skipsEmployeesWithNoDivision() {
        Employee emp = buildEmployee(3L, "N/A");

        when(employeeRepository.findByActiveTrue()).thenReturn(List.of(emp));

        int updated = accrualService.processMonthlyAccrual();

        assertThat(updated).isEqualTo(0);
        verify(leaveBalanceRepository, never()).save(any());
    }

    @Test
    void skipsEmployeesWithNullDivision() {
        Employee emp = buildEmployee(4L, null);

        when(employeeRepository.findByActiveTrue()).thenReturn(List.of(emp));

        int updated = accrualService.processMonthlyAccrual();

        assertThat(updated).isEqualTo(0);
        verify(leaveBalanceRepository, never()).save(any());
    }

    @Test
    void createsBalanceRowIfNoneExists() {
        Employee emp = buildEmployee(5L, "IV");
        LeavePolicy policy = buildPolicy("Vacation Leave", "IV", 2.0, 160);

        when(employeeRepository.findByActiveTrue()).thenReturn(List.of(emp));
        when(leaveBalanceRepository.findById(5L)).thenReturn(Optional.empty());
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Vacation Leave", "IV"))
                .thenReturn(Optional.of(policy));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Local Leave", "IV"))
                .thenReturn(Optional.empty());
        when(leaveBalanceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        int updated = accrualService.processMonthlyAccrual();

        assertThat(updated).isEqualTo(1);
        ArgumentCaptor<LeaveBalance> captor = ArgumentCaptor.forClass(LeaveBalance.class);
        verify(leaveBalanceRepository).save(captor.capture());
        assertThat(captor.getValue().getEmployeeId()).isEqualTo(5L);
        assertThat(captor.getValue().getVacationLeaveBalance()).isEqualTo(2);
    }

    @Test
    void accruesLocalLeaveWhenPolicyExists() {
        Employee emp = buildEmployee(6L, "III");
        LeaveBalance balance = buildBalance(6L, 10, 20);
        LeavePolicy vacationPolicy = buildPolicy("Vacation Leave", "III", 2.5, 160);
        LeavePolicy localPolicy = buildPolicy("Local Leave", "III", 2.0, 30);

        when(employeeRepository.findByActiveTrue()).thenReturn(List.of(emp));
        when(leaveBalanceRepository.findById(6L)).thenReturn(Optional.of(balance));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Vacation Leave", "III"))
                .thenReturn(Optional.of(vacationPolicy));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Local Leave", "III"))
                .thenReturn(Optional.of(localPolicy));
        when(leaveBalanceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        int updated = accrualService.processMonthlyAccrual();

        assertThat(updated).isEqualTo(1);
        ArgumentCaptor<LeaveBalance> captor = ArgumentCaptor.forClass(LeaveBalance.class);
        verify(leaveBalanceRepository, atLeastOnce()).save(captor.capture());
        LeaveBalance saved = captor.getValue();
        assertThat(saved.getLocalLeaveBalance()).isEqualTo(12); // 10 + 2
        assertThat(saved.getVacationLeaveBalance()).isEqualTo(22); // 20 + 2 (floor(2.5))
    }

    @Test
    void accrueForSingleEmployeeWorks() {
        Employee emp = buildEmployee(7L, "I");
        LeaveBalance balance = buildBalance(7L, 0, 0);
        LeavePolicy policy = buildPolicy("Vacation Leave", "I", 3.5, 230);

        when(employeeRepository.findById(7L)).thenReturn(Optional.of(emp));
        when(leaveBalanceRepository.findById(7L)).thenReturn(Optional.of(balance));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Vacation Leave", "I"))
                .thenReturn(Optional.of(policy));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Local Leave", "I"))
                .thenReturn(Optional.empty());
        when(leaveBalanceRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        boolean result = accrualService.accrueForEmployee(7L);

        assertThat(result).isTrue();
        verify(leaveBalanceRepository).save(any());
    }

    @Test
    void doesNotAccrueWhenPolicyHasNullRate() {
        Employee emp = buildEmployee(8L, "I");
        LeavePolicy policy = buildPolicy("Vacation Leave", "I", null, 230);

        when(employeeRepository.findByActiveTrue()).thenReturn(List.of(emp));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Vacation Leave", "I"))
                .thenReturn(Optional.of(policy));
        when(leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase("Local Leave", "I"))
                .thenReturn(Optional.empty());

        int updated = accrualService.processMonthlyAccrual();

        assertThat(updated).isEqualTo(0);
        verify(leaveBalanceRepository, never()).save(any());
    }

    // ── helpers ──

    private Employee buildEmployee(Long id, String division) {
        Employee e = new Employee();
        e.setId(id);
        e.setEmployeeCode("EMP-" + id);
        e.setFirstName("Test");
        e.setLastName("User");
        e.setEmail("test" + id + "@test.com");
        e.setDepartment("HR");
        e.setPositionTitle("Officer");
        e.setBaseSalary(BigDecimal.valueOf(15000));
        e.setHireDate(LocalDate.of(2024, 1, 1));
        e.setRole(EmployeeRole.EMPLOYEE);
        e.setDivision(division);
        e.setActive(true);
        return e;
    }

    private LeaveBalance buildBalance(Long empId, int local, int vacation) {
        LeaveBalance b = new LeaveBalance();
        b.setEmployeeId(empId);
        b.setLocalLeaveBalance(local);
        b.setVacationLeaveBalance(vacation);
        return b;
    }

    private LeavePolicy buildPolicy(String leaveType, String division, Double accrualRate, Integer maxAccumulation) {
        // Use reflection-free approach: LeavePolicy has no public setters, use the test-visible constructor
        // Since LeavePolicy only has private fields with getters, we'll use a test subclass approach
        return new LeavePolicy() {
            @Override public String getLeaveType() { return leaveType; }
            @Override public String getDivision() { return division; }
            @Override public Double getAccrualRate() { return accrualRate; }
            @Override public Integer getMaxAccumulation() { return maxAccumulation; }
        };
    }
}
