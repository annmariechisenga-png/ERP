package com.localgov.service.pii;

/**
 * Standard masking rules for PII fields.
 *
 * Each rule returns a masked string suitable for display in lists,
 * reports, and UI. Rules are defensive: null or short input returns
 * a safe default.
 */
public final class MaskingRules {

    private MaskingRules() {}

    /**
     * NRC format: NNNNNN/NN/N (e.g., 347087/67/1)
     * Masked output: six asterisks, then slash, then last 4 characters.
     * Example output: ****** slash 67 slash 1
     */
    public static final MaskingRule NRC = value -> {
        if (value == null || value.isBlank()) return "";
        String trimmed = value.trim();
        if (trimmed.length() <= 4) return "****";
        return "******/" + trimmed.substring(trimmed.length() - 4);
    };

    /**
     * Phone format: 260XXXXXXXXX (12 digits, country code + network + subscriber)
     * Masked output: + country + space + network prefix + three asterisks + last 4
     * Example output: +260 97 asterisk asterisk asterisk 1393
     */
    public static final MaskingRule PHONE = value -> {
        if (value == null || value.isBlank()) return "";
        String digits = value.replaceAll("[^0-9]", "");
        if (digits.length() < 10) return "****";
        if (digits.length() >= 12) {
            String country = digits.substring(0, 3);
            String network = digits.substring(3, 5);
            String last4 = digits.substring(digits.length() - 4);
            return "+" + country + " " + network + "***" + last4;
        }
        String last4 = digits.substring(digits.length() - 4);
        return "****" + last4;
    };

    /**
     * Standard masking: show last 4 characters, mask the rest.
     * Used for TIN, NAPSA, NHIMA, LASF, bank account.
     */
    public static final MaskingRule STANDARD_LAST_FOUR = value -> {
        if (value == null || value.isBlank()) return "";
        String trimmed = value.trim();
        if (trimmed.length() <= 4) return "****";
        return "****" + trimmed.substring(trimmed.length() - 4);
    };

    /**
     * Email format: local@domain
     * Masked output: first char + three asterisks + domain
     * Example output: s asterisk asterisk asterisk @example.com
     */
    public static final MaskingRule EMAIL = value -> {
        if (value == null || value.isBlank()) return "";
        String trimmed = value.trim();
        int at = trimmed.indexOf('@');
        if (at <= 0) return "****";
        String local = trimmed.substring(0, at);
        String domain = trimmed.substring(at);
        if (local.length() <= 1) return "*" + domain;
        return local.charAt(0) + "***" + domain;
    };

    /**
     * Date of birth format: YYYY-MM-DD
     * Masked output: YYYY + hyphen + two asterisks + hyphen + two asterisks
     * Example output: 1978 asterisk asterisk asterisk asterisk asterisk
     */
    public static final MaskingRule DATE_OF_BIRTH = value -> {
        if (value == null || value.isBlank()) return "";
        String trimmed = value.trim();
        if (trimmed.length() < 4) return "****-**-**";
        String year = trimmed.substring(0, 4);
        return year + "-**-**";
    };
}
