package com.finance.roboadvisor.riskprofile.mapper;

import com.finance.roboadvisor.riskprofile.entity.UserRiskAssessment;
import com.finance.roboadvisor.riskprofile.entity.UserRiskAssessmentAnswer;
import com.finance.roboadvisor.riskprofile.entity.UserRiskProfile;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserRiskProfileMapper {

    UserRiskProfile selectProfileByUserId(@Param("userId") Long userId);

    int insertProfile(UserRiskProfile profile);

    int updateProfile(UserRiskProfile profile);

    int insertAssessment(UserRiskAssessment assessment);

    int insertAssessmentAnswer(UserRiskAssessmentAnswer answer);
}
