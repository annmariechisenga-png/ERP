package com.localgov.web.controller;

import com.localgov.service.AuthorityReferenceService;
import com.localgov.service.dto.AuthorityDistrictResponse;
import com.localgov.service.dto.AuthorityProvinceResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/authority-reference")
@Tag(name = "Authority Reference", description = "Read-only authority reference endpoints")
public class AuthorityReferenceController {

    private final AuthorityReferenceService authorityReferenceService;

    public AuthorityReferenceController(AuthorityReferenceService authorityReferenceService) {
        this.authorityReferenceService = authorityReferenceService;
    }

    @GetMapping("/provinces")
    @Operation(summary = "List provinces", description = "Returns all configured provinces.")
    public List<AuthorityProvinceResponse> getProvinces() {
        return authorityReferenceService.getProvinces();
    }

    @GetMapping("/districts")
    @Operation(summary = "List districts", description = "Returns district local authorities, optionally filtered by province code.")
    public List<AuthorityDistrictResponse> getDistricts(@RequestParam(required = false) String provinceCode) {
        return authorityReferenceService.getDistricts(provinceCode);
    }
}
