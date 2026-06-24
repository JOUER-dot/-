package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductHoldingSnapshot;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ProductHoldingSnapshotMapper {

    int upsert(AdvisorProductHoldingSnapshot snapshot);
}
