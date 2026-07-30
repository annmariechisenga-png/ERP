package com.localgov.web.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.localgov.web.exception.ApiErrorResponse;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDateTime;

@Component
public class RestAuthenticationEntryPoint implements AuthenticationEntryPoint {

    public static final String AUTH_ERROR_CODE_ATTR = "auth.error.code";
    public static final String AUTH_ERROR_MESSAGE_ATTR = "auth.error.message";

    private final ObjectMapper objectMapper;

    public RestAuthenticationEntryPoint(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException)
            throws IOException, ServletException {
        String errorCode = (String) request.getAttribute(AUTH_ERROR_CODE_ATTR);
        String errorMessage = (String) request.getAttribute(AUTH_ERROR_MESSAGE_ATTR);

        if (errorCode == null || errorCode.isBlank()) {
            errorCode = "AUTH_UNAUTHORIZED";
        }
        if (errorMessage == null || errorMessage.isBlank()) {
            errorMessage = "Authentication is required to access this resource";
        }

        ApiErrorResponse body = new ApiErrorResponse(
                LocalDateTime.now(),
                HttpStatus.UNAUTHORIZED.value(),
                HttpStatus.UNAUTHORIZED.getReasonPhrase(),
                errorCode,
                errorMessage,
                request.getRequestURI(),
                null
        );

        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        objectMapper.writeValue(response.getOutputStream(), body);
    }
}