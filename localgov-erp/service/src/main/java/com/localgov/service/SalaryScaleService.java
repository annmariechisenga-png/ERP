package com.localgov.service;

import com.localgov.domain.model.SalaryNotchValue;
import com.localgov.domain.model.SalaryScaleOfficial;
import com.localgov.repository.SalaryNotchValueRepository;
import com.localgov.repository.SalaryScaleOfficialRepository;
import com.localgov.service.dto.SalaryScaleNotchAmountResponse;
import com.localgov.service.dto.SalaryScaleNotchRowResponse;
import com.localgov.service.dto.SalaryScaleNotchesResponse;
import com.localgov.service.dto.SalaryScaleOptionResponse;
import com.localgov.service.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional(readOnly = true)
public class SalaryScaleService {

    private final SalaryScaleOfficialRepository salaryScaleOfficialRepository;
    private final SalaryNotchValueRepository salaryNotchValueRepository;

    public SalaryScaleService(
            SalaryScaleOfficialRepository salaryScaleOfficialRepository,
            SalaryNotchValueRepository salaryNotchValueRepository
    ) {
        this.salaryScaleOfficialRepository = salaryScaleOfficialRepository;
        this.salaryNotchValueRepository = salaryNotchValueRepository;
    }

    public List<SalaryScaleOptionResponse> getActiveScales() {
        return salaryScaleOfficialRepository.findCurrentActiveScales()
                .stream()
                .map(scale -> {
                    long populatedNotches = salaryNotchValueRepository.findCurrentNotchRowsByScale(scale.getSalaryScale()).size();
                    return new SalaryScaleOptionResponse(
                            scale.getSalaryScale(),
                            scale.getDivision(),
                            scale.getMinNotch(),
                            scale.getMaxNotch(),
                            populatedNotches
                    );
                })
                .toList();
    }

    public SalaryScaleNotchesResponse getScaleNotches(String salaryScale) {
        SalaryScaleOfficial scale = salaryScaleOfficialRepository.findCurrentBySalaryScale(salaryScale)
                .orElseThrow(() -> new ResourceNotFoundException("Scale not found"));

        List<SalaryScaleNotchRowResponse> notches = salaryNotchValueRepository.findCurrentNotchRowsByScale(salaryScale)
                .stream()
                .filter(notch -> notch.getNotchNo() >= scale.getMinNotch() && notch.getNotchNo() <= scale.getMaxNotch())
                .map(notch -> new SalaryScaleNotchRowResponse(
                        notch.getNotchNo(),
                        notch.getMonthlySalary(),
                        notch.getAnnualSalary(),
                        notch.getEffectiveFrom()
                ))
                .toList();

        if (notches.isEmpty()) {
            throw new ResourceNotFoundException("Scale not found");
        }

        int minNotch = notches.stream().map(SalaryScaleNotchRowResponse::notchNumber).min(Integer::compareTo).orElse(scale.getMinNotch());
        int maxNotch = notches.stream().map(SalaryScaleNotchRowResponse::notchNumber).max(Integer::compareTo).orElse(scale.getMaxNotch());

        return new SalaryScaleNotchesResponse(
                scale.getSalaryScale(),
                notches,
                minNotch,
                maxNotch
        );
    }

    public SalaryScaleNotchAmountResponse getNotchAmount(String salaryScale, Integer notchNumber) {
        SalaryNotchValue notch = salaryNotchValueRepository.findCurrentByScaleAndNotch(salaryScale, notchNumber)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Salary amount not found for scale " + salaryScale + " notch " + notchNumber
                ));

        return new SalaryScaleNotchAmountResponse(
                notch.getSalaryScale(),
                notch.getNotchNo(),
                notch.getMonthlySalary()
        );
    }
}
