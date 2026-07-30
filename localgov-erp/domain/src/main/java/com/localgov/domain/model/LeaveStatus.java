package com.localgov.domain.model;

public enum LeaveStatus {
    PENDING,
    APPROVED,
    REJECTED,
    CANCELLED,

    // Workflow states – prepared for future multi-step approval engine.
    // Not used by current approval logic.
    PENDING_SUPERVISOR,
    PENDING_HOD,
    PENDING_PRINCIPAL_OFFICER,
    COMPLETED
}
