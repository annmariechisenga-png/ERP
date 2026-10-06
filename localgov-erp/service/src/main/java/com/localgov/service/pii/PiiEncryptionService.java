package com.localgov.service.pii;

import com.localgov.service.security.AuthenticatedUserContext;

import java.util.Collection;
import java.util.Map;

/**
 * The core PII protection service.
 *
 * All PII operations in the system route through this interface. It is
 * responsible for:
 *   - Hashing:    deterministic, per-tenant, for lookup and uniqueness
 *   - Encrypting: random-IV authenticated encryption, for authorized reads
 *   - Decrypting: reversible, requires user context, logs access
 *   - Masking:    safe display values, no keys required
 *
 * Implementations must be thread-safe.
 */
public interface PiiEncryptionService {

    /**
     * Deterministic hash of a value, scoped to a tenant.
     *
     * Same (field, authorityCode, plaintext) always returns the same hash.
     * Different authorities produce different hashes for the same value.
     *
     * Returns null if plaintext is null or blank.
     */
    String hash(PiiField field, String authorityCode, String plaintext);

    /**
     * Non-deterministic encryption. Same plaintext produces different
     * ciphertext each time (random IV).
     *
     * Returns null if plaintext is null or blank.
     */
    String encrypt(PiiField field, String plaintext);

    /**
     * Reversible decryption. Requires an authenticated user context.
     * Every call writes an audit event.
     *
     * Throws PiiException if ciphertext is invalid or tampered.
     */
    String decrypt(PiiField field, String ciphertext, AuthenticatedUserContext ctx);

    /**
     * Safe display value. No key required, safe for any user.
     *
     * Never returns null — returns empty string if plaintext is null.
     */
    String mask(PiiField field, String plaintext);

    /**
     * Produces hash + masked + encrypted in one call.
     * Efficient — hashes and encrypts only once.
     */
    PiiValue protect(PiiField field, String authorityCode, String plaintext);

    /**
     * Bulk hash operation for imports and migrations.
     * Returns a map from plaintext → hash.
     */
    Map<String, String> hashMany(PiiField field, String authorityCode, Collection<String> values);
}
