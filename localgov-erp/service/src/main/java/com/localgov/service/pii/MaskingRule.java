package com.localgov.service.pii;

/**
 * A functional interface for masking a PII value for safe display.
 * Implementations must never throw on malformed input — return a safe
 * default like "****" instead.
 */
@FunctionalInterface
public interface MaskingRule {
    String mask(String plaintext);
}
