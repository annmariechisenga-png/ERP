package com.localgov.service.dto;

import java.util.List;

public record WorkLocationBulkImportResponse(
        int totalRows,
        int importedRows,
        int failedRows,
        List<String> errors
) {
}
