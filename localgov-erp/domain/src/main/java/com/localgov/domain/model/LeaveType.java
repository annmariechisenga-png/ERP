package com.localgov.domain.model;

public enum LeaveType {
    SICK("Sick Leave"),
    MATERNITY("Maternity Leave"),
    PATERNITY("Paternity Leave"),
    LOCAL("Local Leave"),
    VACATION("Vacation Leave"),
    COMPASSIONATE("Compassionate Leave"),
    FAMILY_CARE("Family Care Leave"),
    MOTHERS_DAY("Mother's Day Leave"),
    UNPAID("Unpaid Leave"),
    STUDY("Study Leave");

    private final String displayName;

    LeaveType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    /**
     * Returns the canonical {@code leave_type} string stored in the
     * {@code leave_policy} PostgreSQL table.
     */
    public String policyKey() {
        return displayName;
    }
}
