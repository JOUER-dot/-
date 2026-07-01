package com.finance.roboadvisor.riskprofile.service;

import com.finance.roboadvisor.riskprofile.dto.RiskAssessmentSubmitDTO;
import com.finance.roboadvisor.riskprofile.vo.RiskProfileVO;

public interface RiskProfileService {

    RiskProfileVO getCurrentProfile();

    RiskProfileVO submitAssessment(RiskAssessmentSubmitDTO dto);
}
