package com.localgov.service.leave;

/**
 * Identifies the action that triggered a leave audit entry.
 */
public enum AuditTriggerType {
    PREVIEW,
    SUBMISSION,
    APPROVAL,
    REJECTION,
    SYSTEM
}
