package com.localgov.service.pii;

/**
 * Enumerates the fields that require PII protection.
 *
 * Each field has:
 *   - a masking rule (how to obscure it for display)
 *   - a boolean indicating whether it needs a deterministic hash
 *     (used for lookup and uniqueness) in addition to encryption
 *   - the corresponding column names on the employees table
 */
public enum PiiField {

    NRC("nrc_hash", "nrc_masked", "nrc_encrypted", true,
        MaskingRules.NRC),

    PHONE("phone_hash", "phone_masked", "phone_encrypted", true,
          MaskingRules.PHONE),

    TPIN("tpin_hash", "tpin_masked", "tpin_encrypted", true,
         MaskingRules.STANDARD_LAST_FOUR),

    NAPSA("napsa_hash", "napsa_masked", "napsa_encrypted", true,
          MaskingRules.STANDARD_LAST_FOUR),

    NHIMA("nhima_hash", "nhima_masked", "nhima_encrypted", true,
          MaskingRules.STANDARD_LAST_FOUR),

    LASF("lasf_hash", "lasf_masked", "lasf_encrypted", true,
         MaskingRules.STANDARD_LAST_FOUR),

    BANK_ACCOUNT("bank_account_hash", "bank_account_masked", "bank_account_encrypted", true,
                 MaskingRules.STANDARD_LAST_FOUR),

    EMAIL("email_hash", "email_masked", "email_encrypted", true,
          MaskingRules.EMAIL),

    DATE_OF_BIRTH(null, "dob_masked", "dob_encrypted", false,
                  MaskingRules.DATE_OF_BIRTH);

    private final String hashColumn;
    private final String maskedColumn;
    private final String encryptedColumn;
    private final boolean hasHash;
    private final MaskingRule maskingRule;

    PiiField(String hashColumn, String maskedColumn, String encryptedColumn,
             boolean hasHash, MaskingRule maskingRule) {
        this.hashColumn = hashColumn;
        this.maskedColumn = maskedColumn;
        this.encryptedColumn = encryptedColumn;
        this.hasHash = hasHash;
        this.maskingRule = maskingRule;
    }

    public String hashColumn() { return hashColumn; }
    public String maskedColumn() { return maskedColumn; }
    public String encryptedColumn() { return encryptedColumn; }
    public boolean hasHash() { return hasHash; }
    public MaskingRule maskingRule() { return maskingRule; }
}
