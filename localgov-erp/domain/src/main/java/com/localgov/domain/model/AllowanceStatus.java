package com.localgov.domain.model;

/**
 * Lifecycle statuses for a Vacation Leave allowance.
 * <p>
 * Phase 1 supports {@code NOT_ELIGIBLE} and {@code ELIGIBLE} only.
 * Future phases will introduce {@code APPROVED}, {@code PAID} and {@code REVERSED}.
 */
public enum AllowanceStatus {
    NOT_ELIGIBLE,
    ELIGIBLE,
    APPROVED,
    PAID,
    REVERSED
}
