package com.localgov.web.exception;

import java.time.LocalDateTime;

public record ApiErrorResponse(
        LocalDateTime timestamp,
        Integer status,
        String error,
        String code,
        String message,
        String path,
        Object details
) {
}