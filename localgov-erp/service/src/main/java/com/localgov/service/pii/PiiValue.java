package com.localgov.service.pii;

/**
 * The protected form of a PII value: hash, masked, encrypted.
 *
 * - hash:      deterministic, used for lookup. null for fields without hash.
 * - masked:    safe for display. Never null (empty string if input was null).
 * - encrypted: reversible, for authorized users. null if input was null.
 */
public record PiiValue(
    String hash,
    String masked,
    String encrypted
) {
    public static PiiValue empty() {
        return new PiiValue(null, "", null);
    }
}
