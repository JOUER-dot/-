package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductRuleDecision;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProductRuleDecisionMapper {

    int insert(AdvisorProductRuleDecision decision);

    AdvisorProductRuleDecision selectByVersionId(@Param("productVersionId") Long productVersionId);
}
