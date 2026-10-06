package com.localgov.service.pii.impl;

import com.localgov.service.pii.*;
import com.localgov.service.security.AuthenticatedUserContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import javax.crypto.Cipher;
import javax.crypto.Mac;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.*;

/**
 * Default implementation of {@link PiiEncryptionService}.
 *
 * Encryption: AES-256-GCM with random 96-bit IV per value. The IV is
 * prepended to the ciphertext and the whole thing is base64-encoded.
 * The field name is used as Additional Authenticated Data (AAD) so that
 * ciphertexts cannot be swapped between fields.
 *
 * Hashing: per-tenant HMAC-SHA256. The HMAC key (PII_HMAC_KEY) is used
 * to derive a tenant-specific salt from authority_code, which is then
 * used as the key for a second HMAC over the normalized plaintext.
 * This gives deterministic, tenant-scoped hashes suitable for uniqueness
 * constraints and lookups.
 *
 * Keys are loaded from environment at startup and validated:
 *   - PII_ENCRYPTION_KEY must be base64 of exactly 32 bytes
 *   - PII_HMAC_KEY       must be base64 of exactly 32 bytes
 *
 * The application refuses to start if either key is missing or invalid.
 */
@Service
public class PiiEncryptionServiceImpl implements PiiEncryptionService {

    private static final Logger log = LoggerFactory.getLogger(PiiEncryptionServiceImpl.class);

    private static final String AES_ALGORITHM = "AES";
    private static final String AES_GCM_TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12;       // 96 bits, recommended for GCM
    private static final int GCM_TAG_LENGTH_BITS = 128; // 16 bytes
    private static final String HMAC_ALGORITHM = "HmacSHA256";

    private final String encryptionKeyBase64;
    private final String hmacKeyBase64;
    private final SecureRandom secureRandom;

    private SecretKeySpec encryptionKey;
    private SecretKeySpec hmacKey;

    public PiiEncryptionServiceImpl(
            @Value("${pii.encryption.key:}") String encryptionKeyBase64,
            @Value("${pii.hmac.key:}") String hmacKeyBase64) {
        this.encryptionKeyBase64 = encryptionKeyBase64;
        this.hmacKeyBase64 = hmacKeyBase64;
        this.secureRandom = new SecureRandom();
    }

    @PostConstruct
    public void validateAndInit() {
        if (encryptionKeyBase64 == null || encryptionKeyBase64.isBlank()) {
            throw new PiiException("PII_ENCRYPTION_KEY is not set. Application cannot start.");
        }
        if (hmacKeyBase64 == null || hmacKeyBase64.isBlank()) {
            throw new PiiException("PII_HMAC_KEY is not set. Application cannot start.");
        }

        byte[] encBytes;
        byte[] hmacBytes;
        try {
            encBytes = Base64.getDecoder().decode(encryptionKeyBase64);
            hmacBytes = Base64.getDecoder().decode(hmacKeyBase64);
        } catch (IllegalArgumentException e) {
            throw new PiiException("PII keys are not valid base64", e);
        }

        if (encBytes.length != 32) {
            throw new PiiException("PII_ENCRYPTION_KEY must decode to 32 bytes (256 bits). Got: " + encBytes.length);
        }
        if (hmacBytes.length != 32) {
            throw new PiiException("PII_HMAC_KEY must decode to 32 bytes (256 bits). Got: " + hmacBytes.length);
        }

        this.encryptionKey = new SecretKeySpec(encBytes, AES_ALGORITHM);
        this.hmacKey = new SecretKeySpec(hmacBytes, HMAC_ALGORITHM);

        log.info("PiiEncryptionService initialized — encryption and HMAC keys loaded");
    }

    // -----------------------------------------------------------------
    // Hash
    // -----------------------------------------------------------------
    @Override
    public String hash(PiiField field, String authorityCode, String plaintext) {
        if (plaintext == null || plaintext.isBlank()) return null;
        if (authorityCode == null || authorityCode.isBlank()) {
            throw new PiiException("authorityCode is required for hashing");
        }

        try {
            // Step 1: derive per-tenant salt = HMAC(hmacKey, authorityCode)
            Mac saltMac = Mac.getInstance(HMAC_ALGORITHM);
            saltMac.init(hmacKey);
            byte[] tenantSalt = saltMac.doFinal(authorityCode.getBytes(StandardCharsets.UTF_8));

            // Step 2: hash the normalized value using the tenant salt as the HMAC key
            Mac valueMac = Mac.getInstance(HMAC_ALGORITHM);
            valueMac.init(new SecretKeySpec(tenantSalt, HMAC_ALGORITHM));
            byte[] hashBytes = valueMac.doFinal(normalize(field, plaintext).getBytes(StandardCharsets.UTF_8));

            return Base64.getEncoder().encodeToString(hashBytes);
        } catch (Exception e) {
            throw new PiiException("Hashing failed for field " + field, e);
        }
    }

    // -----------------------------------------------------------------
    // Encrypt
    // -----------------------------------------------------------------
    @Override
    public String encrypt(PiiField field, String plaintext) {
        if (plaintext == null || plaintext.isBlank()) return null;

        try {
            byte[] iv = new byte[GCM_IV_LENGTH];
            secureRandom.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(AES_GCM_TRANSFORMATION);
            GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv);
            cipher.init(Cipher.ENCRYPT_MODE, encryptionKey, spec);

            // Field name as AAD — binds ciphertext to its semantic field
            cipher.updateAAD(field.name().getBytes(StandardCharsets.UTF_8));

            byte[] ciphertext = cipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));

            // Output: base64( IV || ciphertext+tag )
            byte[] combined = new byte[iv.length + ciphertext.length];
            System.arraycopy(iv, 0, combined, 0, iv.length);
            System.arraycopy(ciphertext, 0, combined, iv.length, ciphertext.length);

            return Base64.getEncoder().encodeToString(combined);
        } catch (Exception e) {
            throw new PiiException("Encryption failed for field " + field, e);
        }
    }

    // -----------------------------------------------------------------
    // Decrypt
    // -----------------------------------------------------------------
    @Override
    public String decrypt(PiiField field, String ciphertextBase64, AuthenticatedUserContext ctx) {
        if (ciphertextBase64 == null || ciphertextBase64.isBlank()) return null;
        if (ctx == null) {
            throw new PiiException("Cannot decrypt without an authenticated user context");
        }

        try {
            byte[] combined = Base64.getDecoder().decode(ciphertextBase64);
            if (combined.length < GCM_IV_LENGTH + (GCM_TAG_LENGTH_BITS / 8)) {
                throw new PiiException("Ciphertext is too short to be valid");
            }

            byte[] iv = Arrays.copyOfRange(combined, 0, GCM_IV_LENGTH);
            byte[] ciphertext = Arrays.copyOfRange(combined, GCM_IV_LENGTH, combined.length);

            Cipher cipher = Cipher.getInstance(AES_GCM_TRANSFORMATION);
            GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv);
            cipher.init(Cipher.DECRYPT_MODE, encryptionKey, spec);
            cipher.updateAAD(field.name().getBytes(StandardCharsets.UTF_8));

            byte[] plaintext = cipher.doFinal(ciphertext);

            // Audit log — record the access WITHOUT logging the value
            log.info("PII_DECRYPT field={} user={} authority={}",
                    field, ctx.username(), ctx.authorityCode());

            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (PiiException e) {
            throw e;
        } catch (Exception e) {
            throw new PiiException("Decryption failed for field " + field, e);
        }
    }

    // -----------------------------------------------------------------
    // Mask
    // -----------------------------------------------------------------
    @Override
    public String mask(PiiField field, String plaintext) {
        if (plaintext == null || plaintext.isBlank()) return "";
        return field.maskingRule().mask(plaintext);
    }

    // -----------------------------------------------------------------
    // Protect (combined)
    // -----------------------------------------------------------------
    @Override
    public PiiValue protect(PiiField field, String authorityCode, String plaintext) {
        if (plaintext == null || plaintext.isBlank()) return PiiValue.empty();

        String hash = field.hasHash() ? hash(field, authorityCode, plaintext) : null;
        String masked = mask(field, plaintext);
        String encrypted = encrypt(field, plaintext);

        return new PiiValue(hash, masked, encrypted);
    }

    // -----------------------------------------------------------------
    // Bulk hash
    // -----------------------------------------------------------------
    @Override
    public Map<String, String> hashMany(PiiField field, String authorityCode, Collection<String> values) {
        Map<String, String> result = new HashMap<>();
        for (String value : values) {
            if (value != null && !value.isBlank()) {
                result.put(value, hash(field, authorityCode, value));
            }
        }
        return result;
    }

    // -----------------------------------------------------------------
    // Normalization — deterministic input for hashing
    // -----------------------------------------------------------------
    private String normalize(PiiField field, String value) {
        String trimmed = value.trim();
        return switch (field) {
            case EMAIL -> trimmed.toLowerCase(Locale.ROOT);
            case PHONE -> trimmed.replaceAll("[^0-9]", "");
            default -> trimmed;
        };
    }
}
