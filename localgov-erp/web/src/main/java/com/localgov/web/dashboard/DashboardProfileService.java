package com.localgov.web.dashboard;

import com.localgov.repository.AuthorityMasterRepository;
import com.localgov.service.exception.BusinessValidationException;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class DashboardProfileService {

    private static final String TOWN_COUNCIL = "Town Council";
    private static final String MUNICIPAL_COUNCIL = "Municipal Council";
    private static final String CITY_COUNCIL = "City Council";

    private final AuthorityMasterRepository authorityMasterRepository;

    public DashboardProfileService(AuthorityMasterRepository authorityMasterRepository) {
        this.authorityMasterRepository = authorityMasterRepository;
    }

    public DashboardProfilesResponse getProfiles() {
        List<String> authorityTypes = availableAuthorityTypes();
        List<DashboardProfileResponse> profiles = profileTemplates().values().stream()
                .flatMap(template -> authorityTypes.stream().map(authorityType -> toResponse(template, authorityType)))
                .toList();
        return new DashboardProfilesResponse(authorityTypes, profiles);
    }

    public DashboardProfileResponse getProfile(String positionId, String authorityType) {
        if (positionId == null || positionId.isBlank()) {
            throw new BusinessValidationException("positionId is required");
        }
        if (authorityType == null || authorityType.isBlank()) {
            throw new BusinessValidationException("authorityType is required");
        }

        DashboardProfileTemplate template = profileTemplates().get(normalizePositionId(positionId));
        if (template == null) {
            throw new BusinessValidationException("Unsupported dashboard positionId: " + positionId);
        }

        String matchedAuthorityType = availableAuthorityTypes().stream()
                .filter(item -> item.equalsIgnoreCase(authorityType.trim()))
                .findFirst()
                .orElseThrow(() -> new BusinessValidationException("Unsupported authorityType: " + authorityType));

        return toResponse(template, matchedAuthorityType);
    }

    public String resolvePositionId(String positionTitle, List<String> roles) {
        if (positionTitle == null || positionTitle.isBlank()) {
            return defaultPositionIdForRoles(roles);
        }

        String normalized = positionTitle.trim()
                .replace('-', ' ')
                .replace('/', ' ')
                .replace('&', ' ')
                .replaceAll("\\s+", " ")
                .toUpperCase(Locale.ROOT);
        String padded = " " + normalized + " ";

        if (padded.contains(" TOWN CLERK ")) {
            return "TOWN_CLERK";
        }
        if (padded.contains(" COUNCIL SECRETARY ") || padded.contains(" HEAD OF INSTITUTION ")) {
            return "COUNCIL_SECRETARY";
        }
        if (padded.contains(" DIRECTOR ") && (padded.contains(" FINANCE ") || padded.contains(" ACCOUNT "))) {
            return "DIRECTOR_FINANCE";
        }

        boolean hrMatch = padded.contains(" HUMAN RESOURCE ")
                || padded.contains(" HUMAN RESOURCES ")
                || padded.contains(" PERSONNEL ")
                || padded.contains(" HR ");
        boolean adminMatch = padded.contains(" ADMINISTRATION ") || padded.contains(" ADMIN ");
        if ((padded.contains(" DIRECTOR ") || padded.contains(" HEAD ")) && hrMatch && adminMatch) {
            return "DIRECTOR_HR_ADMIN";
        }

        return defaultPositionIdForRoles(roles);
    }

    public String defaultPositionIdForRoles(List<String> roles) {
        List<String> normalizedRoles = normalizeRoles(roles);
        if (normalizedRoles.contains("HEAD")) {
            return "COUNCIL_SECRETARY";
        }
        if (normalizedRoles.contains("HR") || normalizedRoles.contains("ADMIN")) {
            return "DIRECTOR_HR_ADMIN";
        }
        if (normalizedRoles.contains("FINANCE") || normalizedRoles.contains("PAYROLL")) {
            return "DIRECTOR_FINANCE";
        }
        if (normalizedRoles.contains("EMPLOYEE")) {
            return "EMPLOYEE_SELF_SERVICE";
        }
        return "DIRECTOR_HR_ADMIN";
    }

    public String resolvePositionTitle(String positionId) {
        DashboardProfileTemplate template = profileTemplates().get(normalizePositionId(positionId));
        return template == null ? positionId : template.positionTitle();
    }

    public String defaultAuthorityType() {
        List<String> authorityTypes = availableAuthorityTypes();
        return authorityTypes.stream()
                .filter(type -> TOWN_COUNCIL.equalsIgnoreCase(type))
                .findFirst()
                .orElseGet(authorityTypes::getFirst);
    }

    private List<String> availableAuthorityTypes() {
        try {
            List<String> authorityTypes = authorityMasterRepository.findDistinctAuthorityTypes().stream()
                    .filter(item -> item != null && !item.isBlank())
                    .distinct()
                    .toList();
            if (!authorityTypes.isEmpty()) {
                return authorityTypes;
            }
        } catch (RuntimeException ignored) {
        }
        return List.of(TOWN_COUNCIL, MUNICIPAL_COUNCIL, CITY_COUNCIL);
    }

    private List<String> normalizeRoles(List<String> roles) {
        if (roles == null) {
            return List.of();
        }
        return roles.stream()
                .filter(item -> item != null && !item.isBlank())
                .map(this::normalizeRole)
                .distinct()
                .toList();
    }

    private String normalizeRole(String role) {
        String normalized = role.trim().toUpperCase(Locale.ROOT);
        return normalized.startsWith("ROLE_") ? normalized.substring(5) : normalized;
    }

    private DashboardProfileResponse toResponse(DashboardProfileTemplate template, String authorityType) {
        AuthorityProfileProfile authorityProfile = template.authorityProfiles().getOrDefault(authorityType, template.defaultProfile());
        return new DashboardProfileResponse(
                template.positionId(),
                template.positionTitle(),
                authorityType,
                authorityProfile.dashboardTitle(),
                authorityProfile.dashboardSummary(),
                authorityProfile.focusAreas(),
                authorityProfile.priorityMetrics(),
                List.of("leave-types", "overtime", "performance", "salary-advance")
        );
    }

    private String normalizePositionId(String positionId) {
        return positionId.trim().toUpperCase(Locale.ROOT);
    }

    private Map<String, DashboardProfileTemplate> profileTemplates() {
        Map<String, DashboardProfileTemplate> templates = new LinkedHashMap<>();

        templates.put("DIRECTOR_HR_ADMIN", new DashboardProfileTemplate(
                "DIRECTOR_HR_ADMIN",
                "Director - Human Resource and Administration",
                new AuthorityProfileProfile(
                        "Human Capital Operations Dashboard",
                        "Position-specific workspace for human resource governance, establishment control, leave oversight, APAS coordination, and staff financial support workflows.",
                        List.of("Leave policy enforcement", "Overtime compliance", "JD and APAS governance", "Salary advance workflow oversight"),
                        List.of("Pending leave requests", "Overtime approval backlog", "Department JD coverage", "Salary advance workflow exposure")
                ),
                Map.of(
                        TOWN_COUNCIL, new AuthorityProfileProfile(
                                "Town Council HR Administration Dashboard",
                                "Tailored for Director - Human Resource and Administration in a Town Council, with emphasis on lean HR teams, manual escalations, and establishment visibility across smaller departments.",
                                List.of("Town staffing controls", "Small-team leave continuity", "Department org coverage", "Advance approvals before council secretary escalation"),
                                List.of("Pending leave requests", "Unassigned positions", "Overtime pending supervisor", "Eligibility failed salary advances")
                        ),
                        MUNICIPAL_COUNCIL, new AuthorityProfileProfile(
                                "Municipal HR Administration Dashboard",
                                "Tailored for Director - Human Resource and Administration in a Municipal Council, with focus on cross-department workforce management and escalated overtime governance.",
                                List.of("Municipal workforce balancing", "Cross-unit APAS tracking", "Expanded overtime register", "Salary advance pipeline monitoring"),
                                List.of("Municipal leave queue", "Approved overtime value", "JD coverage by department", "Pending finance approvals")
                        ),
                        CITY_COUNCIL, new AuthorityProfileProfile(
                                "City Council HR Administration Dashboard",
                                "Tailored for Director - Human Resource and Administration in a City Council, prioritizing high-volume staffing workflows, policy consistency, and executive monitoring across large service departments.",
                                List.of("City-wide policy consistency", "High-volume leave governance", "Executive APAS oversight", "Large-scale staff welfare controls"),
                                List.of("Total leave register", "Paid overtime exposure", "APAS cycle readiness", "Disbursed salary advances")
                        )
                )
        ));

        templates.put("DIRECTOR_FINANCE", new DashboardProfileTemplate(
                "DIRECTOR_FINANCE",
                "Director - Finance",
                new AuthorityProfileProfile(
                        "Finance Leadership Dashboard",
                        "Position-specific finance dashboard covering salary advances, overtime liability, and payroll-sensitive staff workflows.",
                        List.of("Salary advance exposure", "Overtime payment liability", "Payroll risk monitoring", "Workforce cost trend visibility"),
                        List.of("Advance requests by status", "Pending deductions", "Overtime amount due", "Payroll-linked approvals")
                ),
                Map.of()
        ));

        templates.put("COUNCIL_SECRETARY", new DashboardProfileTemplate(
                "COUNCIL_SECRETARY",
                "Council Secretary",
                new AuthorityProfileProfile(
                        "Institution Head Dashboard",
                        "Head-of-institution view for workforce approvals, salary advance head decisions, and organizational accountability.",
                        List.of("Strategic HR decisions", "Head approval pipeline", "Policy compliance", "Department accountability"),
                        List.of("Requests pending head approval", "Department headcount", "Policy exceptions", "Organization structure coverage")
                ),
                Map.of()
        ));

        templates.put("TOWN_CLERK", new DashboardProfileTemplate(
                "TOWN_CLERK",
                "Town Clerk",
                new AuthorityProfileProfile(
                        "Local Authority Executive Dashboard",
                        "Executive workforce dashboard for Town Clerk roles in Municipal and City Councils with oversight on approvals, performance readiness, and institutional staffing risk.",
                        List.of("Executive decision pipeline", "Performance governance", "Departmental organization", "Advance and overtime exception review"),
                        List.of("Head approval queue", "APAS readiness", "Department staffing mix", "High-value requests")
                ),
                Map.of()
        ));

        templates.put("EMPLOYEE_SELF_SERVICE", new DashboardProfileTemplate(
                "EMPLOYEE_SELF_SERVICE",
                "Employee Self-Service",
                new AuthorityProfileProfile(
                        "Employee Self-Service Dashboard",
                        "Staff workspace for personal leave visibility, overtime submissions, APAS follow-up, and salary advance tracking.",
                        List.of("Leave application progress", "Overtime submissions", "APAS action items", "Salary advance status"),
                        List.of("Open leave requests", "Overtime hours submitted", "APAS review stage", "Advance repayment visibility")
                ),
                Map.of()
        ));

        return templates;
    }

    private record DashboardProfileTemplate(
            String positionId,
            String positionTitle,
            AuthorityProfileProfile defaultProfile,
            Map<String, AuthorityProfileProfile> authorityProfiles
    ) {
    }

    private record AuthorityProfileProfile(
            String dashboardTitle,
            String dashboardSummary,
            List<String> focusAreas,
            List<String> priorityMetrics
    ) {
    }
}