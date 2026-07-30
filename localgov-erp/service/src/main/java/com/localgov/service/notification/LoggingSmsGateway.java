package com.localgov.service.notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class LoggingSmsGateway implements SmsGateway {

    private static final Logger log = LoggerFactory.getLogger(LoggingSmsGateway.class);

    @Override
    public void sendSms(String phoneNumber, String message) {
        // Placeholder transport: keeps behavior testable until an SMS provider is integrated.
        log.info("SMS queued to {}: {}", phoneNumber, message);
    }
}
