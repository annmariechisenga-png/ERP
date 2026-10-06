package com.localgov.service.pii;

/**
 * Thrown when a PII operation fails: missing key, invalid ciphertext,
 * decryption failure, or unauthorized access.
 *
 * Never includes the sensitive value in the message.
 */
public class PiiException extends RuntimeException {
    public PiiException(String message) {
        super(message);
    }
    public PiiException(String message, Throwable cause) {
        super(message, cause);
    }
}
