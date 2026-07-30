package com.localgov.service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LeaveCancellationRequest(
        @NotBlank @Size(max = 100) String cancelledBy,
        @Size(max = 500) String reason
) {
}
