package com.localgov.web.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HomeController {
    
    @GetMapping
    public String home() {
        return "Welcome to LocalGov ERP System!";
    }
    
    @GetMapping("/health")
    public String health() {
        return "Application is running!";
    }
    
    @GetMapping("/status")
    public StatusResponse status() {
        return new StatusResponse("UP", "LocalGov ERP is operational");
    }
    
    // Inner class for status response
    static class StatusResponse {
        private String status;
        private String message;
        
        public StatusResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
        
        // Getters and setters
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
}
