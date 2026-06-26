package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorStrategyRule;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface StrategyRuleMapper {

    AdvisorStrategyRule selectEnabledByStrategyAndType(@Param("strategyCode") String strategyCode,
                                                       @Param("productType") String productType);

    List<AdvisorStrategyRule> selectAllEnabled();
}
