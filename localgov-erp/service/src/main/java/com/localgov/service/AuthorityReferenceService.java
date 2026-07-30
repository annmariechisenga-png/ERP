package com.localgov.service;

import com.localgov.repository.AuthorityMasterRepository;
import com.localgov.service.dto.AuthorityDistrictResponse;
import com.localgov.service.dto.AuthorityProvinceResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;

@Service
@Transactional(readOnly = true)
public class AuthorityReferenceService {

    private final AuthorityMasterRepository authorityMasterRepository;

    public AuthorityReferenceService(AuthorityMasterRepository authorityMasterRepository) {
        this.authorityMasterRepository = authorityMasterRepository;
    }

    public List<AuthorityProvinceResponse> getProvinces() {
        return authorityMasterRepository.findAllProvinces()
                .stream()
                .map(row -> new AuthorityProvinceResponse(row.getProvinceCode(), row.getProvinceName()))
                .toList();
    }

    public List<AuthorityDistrictResponse> getDistricts(String provinceCode) {
        String normalizedProvinceCode = normalizeProvinceCode(provinceCode);
        return authorityMasterRepository.findDistrictsByProvince(normalizedProvinceCode)
                .stream()
                .map(row -> new AuthorityDistrictResponse(
                        toLaCode(row.getAuthorityNumber()),
                        row.getAuthorityId(),
                        row.getAuthorityRef(),
                        row.getProvinceCode(),
                        row.getProvinceName(),
                        row.getDistrictName(),
                        row.getAuthorityType()
                ))
                .toList();
    }

    private String toLaCode(Long authorityNumber) {
        long value = authorityNumber == null ? 0L : authorityNumber;
        return String.format(Locale.ROOT, "LA%03d", value);
    }

    private String normalizeProvinceCode(String provinceCode) {
        if (provinceCode == null || provinceCode.isBlank()) {
            return null;
        }
        return provinceCode.trim().toUpperCase(Locale.ROOT);
    }
}
