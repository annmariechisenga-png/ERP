package com.localgov.service.leave;

import com.localgov.domain.model.Employee;
import com.localgov.domain.model.LeavePolicy;
import com.localgov.domain.model.LeaveType;
import com.localgov.repository.LeavePolicyRepository;
import com.localgov.repository.SalaryScaleOfficialRepository;
import com.localgov.service.exception.BusinessValidationException;
import org.springframework.stereotype.Component;

import java.util.Locale;
import java.util.Optional;

/**
 * Resolves the applicable LeavePolicy for a given leave type and employee,
 * and enforces gender restrictions.
 *
 * <p>Division resolution order (authoritative first):
 * <ol>
 *   <li>Derive from {@code employee.salaryScale} via {@code salary_scales_official}.</li>
 *   <li>Fall back to the stored {@code employee.division} value (reporting metadata),
 *       normalised to the canonical leave_policy label format.</li>
 *   <li>Fall back to the null-division catch-all policy if neither resolves.</li>
 * </ol>
 */
@Component
public class PolicyResolver {

    private final LeavePolicyRepository         leavePolicyRepository;
    private final SalaryScaleOfficialRepository salaryScaleOfficialRepository;

    public PolicyResolver(LeavePolicyRepository         leavePolicyRepository,
                          SalaryScaleOfficialRepository salaryScaleOfficialRepository) {
        this.leavePolicyRepository         = leavePolicyRepository;
        this.salaryScaleOfficialRepository = salaryScaleOfficialRepository;
    }

    /**
     * Primary entry point — resolves by employee, using salary scale as the
     * authoritative division source with stored division as fallback.
     */
    public LeavePolicy resolve(LeaveType leaveType, Employee employee) {
        String key = leaveType.policyKey();

        // 1. Authoritative: derive division from active salary scale
        String derived = deriveFromSalaryScale(employee.getSalaryScale());
        if (derived != null) {
            Optional<LeavePolicy> p = leavePolicyRepository
                    .findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase(key, derived);
            if (p.isPresent()) return p.get();
        }

        // 2. Fallback: normalise stored employee.division
        String canonical = canonicalize(employee.getDivision());
        if (canonical != null) {
            Optional<LeavePolicy> p = leavePolicyRepository
                    .findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase(key, canonical);
            if (p.isPresent()) return p.get();
        }

        // 3. Catch-all: null-division policy
        return leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIsNull(key)
                .orElseThrow(() -> new BusinessValidationException(
                        "No leave policy found for: " + leaveType.getDisplayName()
                        + " (Division: " + effectiveDivisionLabel(derived, employee.getDivision()) + ")"));
    }

    /**
     * Legacy entry point for callers that only have a division string.
     * Normalises variant forms before lookup; no salary-scale derivation.
     */
    public LeavePolicy resolve(LeaveType leaveType, String division) {
        String key = leaveType.policyKey();
        String canonical = canonicalize(division);
        if (canonical != null) {
            Optional<LeavePolicy> p = leavePolicyRepository
                    .findFirstByLeaveTypeIgnoreCaseAndDivisionIgnoreCase(key, canonical);
            if (p.isPresent()) return p.get();
        }
        return leavePolicyRepository.findFirstByLeaveTypeIgnoreCaseAndDivisionIsNull(key)
                .orElseThrow(() -> new BusinessValidationException(
                        "No leave policy found for: " + leaveType.getDisplayName()
                        + (division != null ? " (Division: " + division + ")" : "")));
    }

    public void enforceGenderRestriction(LeavePolicy policy, Employee employee, LeaveType leaveType) {
        String gender = employee.getGender() == null ? "other" : employee.getGender().trim().toLowerCase(Locale.ROOT);
        if (policy.isFemaleOnly() && !"female".equals(gender))
            throw new BusinessValidationException(leaveType.getDisplayName() + " is available to female employees only.");
        if (policy.isMaleOnly() && !"male".equals(gender))
            throw new BusinessValidationException(leaveType.getDisplayName() + " is available to male employees only.");
    }

    // ── private helpers ───────────────────────────────────────────────────

    /**
     * Looks up the salary scale in salary_scales_official and maps the stored
     * DIVISION_I/II/III/IV value to the leave_policy "Division I" label format.
     * Returns null when salaryScale is blank or not found in the official table.
     */
    private String deriveFromSalaryScale(String salaryScale) {
        if (salaryScale == null || salaryScale.isBlank()) return null;
        return salaryScaleOfficialRepository
                .findDivisionBySalaryScale(salaryScale.trim())
                .map(PolicyResolver::officialDivisionToLabel)
                .orElse(null);
    }

    /**
     * Maps salary_scales_official.division format ("DIVISION_I") to the
     * leave_policy.division label format ("Division I").
     */
    private static String officialDivisionToLabel(String official) {
        if (official == null) return null;
        return switch (official.toUpperCase(Locale.ROOT).replace(" ", "_")) {
            case "DIVISION_I"   -> "Division I";
            case "DIVISION_II"  -> "Division II";
            case "DIVISION_III" -> "Division III";
            case "DIVISION_IV"  -> "Division IV";
            default             -> null;
        };
    }

    /**
     * Normalises any known variant of a division string to the canonical
     * "Division I" – "Division IV" label used in leave_policy.division.
     * Returns null for unrecognised or sentinel values ("N/A", blank, null).
     */
    private static String canonicalize(String division) {
        if (division == null || division.isBlank()) return null;
        return switch (division.trim().toUpperCase(Locale.ROOT).replace(" ", "_").replace("-", "_")) {
            case "I",   "DIVISION_I",   "DIV_I",   "DIV_1"  -> "Division I";
            case "II",  "DIVISION_II",  "DIV_II",  "DIV_2"  -> "Division II";
            case "III", "DIVISION_III", "DIV_III", "DIV_3"  -> "Division III";
            case "IV",  "DIVISION_IV",  "DIV_IV",  "DIV_4"  -> "Division IV";
            default -> null;
        };
    }

    private static String effectiveDivisionLabel(String derived, String stored) {
        if (derived != null) return derived;
        if (stored != null && !stored.isBlank()) return stored;
        return "none";
    }
}
