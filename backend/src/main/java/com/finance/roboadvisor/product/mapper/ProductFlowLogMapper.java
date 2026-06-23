package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ProductFlowLogMapper {

    int insert(AdvisorProductFlowLog flowLog);
}
