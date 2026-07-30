package com.localgov.service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record LeaveApprovalRequest(
        @NotNull Boolean approved,
        @NotBlank @Size(max = 100) String approvedBy
) {
}
