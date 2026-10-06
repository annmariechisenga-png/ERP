package com.localgov.service.pii;

import com.localgov.service.pii.impl.PiiEncryptionServiceImpl;
import com.localgov.service.security.AuthenticatedUserContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.Base64;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class PiiEncryptionServiceTest {

    private static final String TEST_ENC_KEY =
        Base64.getEncoder().encodeToString(new byte[32]);

    private static final String TEST_HMAC_KEY =
        Base64.getEncoder().encodeToString(new byte[]{
            1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
            17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
        });

    private PiiEncryptionServiceImpl service;
    private AuthenticatedUserContext ctx;

    @BeforeEach
    void setUp() {
        service = new PiiEncryptionServiceImpl(TEST_ENC_KEY, TEST_HMAC_KEY);
        service.validateAndInit();
        ctx = new AuthenticatedUserContext("testuser", 1L, "CHILANGA", "COUNCIL", "HR_OFFICER", "II");
    }

    @Test
    void hash_isDeterministic() {
        String h1 = service.hash(PiiField.NRC, "CHILANGA", "347087/67/1");
        String h2 = service.hash(PiiField.NRC, "CHILANGA", "347087/67/1");
        assertEquals(h1, h2);
    }

    @Test
    void hash_differsAcrossTenants() {
        String h1 = service.hash(PiiField.NRC, "CHILANGA", "347087/67/1");
        String h2 = service.hash(PiiField.NRC, "LUSAKA", "347087/67/1");
        assertNotEquals(h1, h2);
    }

    @Test
    void hash_returnsNullForBlank() {
        assertNull(service.hash(PiiField.NRC, "CHILANGA", null));
        assertNull(service.hash(PiiField.NRC, "CHILANGA", ""));
        assertNull(service.hash(PiiField.NRC, "CHILANGA", "   "));
    }

    @Test
    void hash_emailIsCaseInsensitive() {
        String h1 = service.hash(PiiField.EMAIL, "CHILANGA", "Stephen@Example.com");
        String h2 = service.hash(PiiField.EMAIL, "CHILANGA", "stephen@example.com");
        assertEquals(h1, h2);
    }

    @Test
    void hash_phoneIgnoresFormatting() {
        String h1 = service.hash(PiiField.PHONE, "CHILANGA", "260979531393");
        String h2 = service.hash(PiiField.PHONE, "CHILANGA", "+260 97 953 1393");
        assertEquals(h1, h2);
    }

    @Test
    void encrypt_decrypt_roundTrip() {
        String plaintext = "347087/67/1";
        String encrypted = service.encrypt(PiiField.NRC, plaintext);
        assertNotNull(encrypted);
        assertNotEquals(plaintext, encrypted);
        String decrypted = service.decrypt(PiiField.NRC, encrypted, ctx);
        assertEquals(plaintext, decrypted);
    }

    @Test
    void encrypt_isNonDeterministic() {
        String plaintext = "347087/67/1";
        String c1 = service.encrypt(PiiField.NRC, plaintext);
        String c2 = service.encrypt(PiiField.NRC, plaintext);
        assertNotEquals(c1, c2);
    }

    @Test
    void encrypt_returnsNullForBlank() {
        assertNull(service.encrypt(PiiField.NRC, null));
        assertNull(service.encrypt(PiiField.NRC, ""));
    }

    @Test
    void decrypt_requiresContext() {
        String encrypted = service.encrypt(PiiField.NRC, "347087/67/1");
        assertThrows(PiiException.class, () -> service.decrypt(PiiField.NRC, encrypted, null));
    }

    @Test
    void decrypt_detectsTampering() {
        String encrypted = service.encrypt(PiiField.NRC, "347087/67/1");
        byte[] bytes = Base64.getDecoder().decode(encrypted);
        bytes[bytes.length / 2] ^= (byte) 0xFF;
        String tampered = Base64.getEncoder().encodeToString(bytes);
        assertThrows(PiiException.class, () -> service.decrypt(PiiField.NRC, tampered, ctx));
    }

    @Test
    void encrypt_usesFieldAsAad() {
        String encrypted = service.encrypt(PiiField.NRC, "347087/67/1");
        assertThrows(PiiException.class, () -> service.decrypt(PiiField.PHONE, encrypted, ctx));
    }

    @Test
    void mask_nrc() {
        assertEquals("******/67/1", service.mask(PiiField.NRC, "347087/67/1"));
    }

    @Test
    void mask_phone() {
        assertEquals("+260 97***1393", service.mask(PiiField.PHONE, "260979531393"));
    }

    @Test
    void mask_bankAccount() {
        assertEquals("****1015", service.mask(PiiField.BANK_ACCOUNT, "0395867151015"));
    }

    @Test
    void mask_email() {
        assertEquals("s***@example.com", service.mask(PiiField.EMAIL, "stephen@example.com"));
    }

    @Test
    void mask_dateOfBirth() {
        assertEquals("1978-**-**", service.mask(PiiField.DATE_OF_BIRTH, "1978-01-10"));
    }

    @Test
    void mask_returnsEmptyForBlank() {
        assertEquals("", service.mask(PiiField.NRC, null));
        assertEquals("", service.mask(PiiField.NRC, ""));
    }

    @Test
    void protect_returnsAllThreeValues() {
        PiiValue v = service.protect(PiiField.NRC, "CHILANGA", "347087/67/1");
        assertNotNull(v.hash());
        assertEquals("******/67/1", v.masked());
        assertNotNull(v.encrypted());
    }

    @Test
    void protect_handlesNull() {
        PiiValue v = service.protect(PiiField.NRC, "CHILANGA", null);
        assertNull(v.hash());
        assertEquals("", v.masked());
        assertNull(v.encrypted());
    }

    @Test
    void hashMany_hashesAllNonBlankValues() {
        var result = service.hashMany(
            PiiField.NRC, "CHILANGA",
            List.of("347087/67/1", "203892/77/1", "", "913407/67/1")
        );
        assertEquals(3, result.size());
    }

    @Test
    void validate_failsOnMissingEncryptionKey() {
        PiiEncryptionServiceImpl bad = new PiiEncryptionServiceImpl("", TEST_HMAC_KEY);
        assertThrows(PiiException.class, bad::validateAndInit);
    }

    @Test
    void validate_failsOnMissingHmacKey() {
        PiiEncryptionServiceImpl bad = new PiiEncryptionServiceImpl(TEST_ENC_KEY, "");
        assertThrows(PiiException.class, bad::validateAndInit);
    }

    @Test
    void validate_failsOnWrongLengthEncryptionKey() {
        String shortKey = Base64.getEncoder().encodeToString(new byte[16]);
        PiiEncryptionServiceImpl bad = new PiiEncryptionServiceImpl(shortKey, TEST_HMAC_KEY);
        assertThrows(PiiException.class, bad::validateAndInit);
    }

    @Test
    void validate_failsOnInvalidBase64() {
        PiiEncryptionServiceImpl bad = new PiiEncryptionServiceImpl("not-base64!!!", TEST_HMAC_KEY);
        assertThrows(PiiException.class, bad::validateAndInit);
    }
}
