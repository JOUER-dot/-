package com.finance.roboadvisor.riskprofile.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.riskprofile.dto.RiskAssessmentSubmitDTO;
import com.finance.roboadvisor.riskprofile.service.RiskProfileService;
import com.finance.roboadvisor.riskprofile.vo.RiskProfileVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth/risk-profile")
public class RiskProfileController {

    private final RiskProfileService riskProfileService;

    public RiskProfileController(RiskProfileService riskProfileService) {
        this.riskProfileService = riskProfileService;
    }

    @GetMapping
    public ApiResult<RiskProfileVO> getCurrentProfile() {
        return ApiResult.success(riskProfileService.getCurrentProfile());
    }

    @PostMapping("/assessment")
    public ApiResult<RiskProfileVO> submitAssessment(@RequestBody RiskAssessmentSubmitDTO dto) {
        return ApiResult.success("风险测评已更新", riskProfileService.submitAssessment(dto));
    }
}
