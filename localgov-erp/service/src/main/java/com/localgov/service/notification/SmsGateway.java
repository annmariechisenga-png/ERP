package com.localgov.service.notification;

public interface SmsGateway {
    void sendSms(String phoneNumber, String message);
}
