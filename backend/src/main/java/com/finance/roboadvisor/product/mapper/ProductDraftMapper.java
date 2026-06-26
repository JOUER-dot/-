package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductDraft;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProductDraftMapper {

    int insert(AdvisorProductDraft draft);

    int updateByProductId(AdvisorProductDraft draft);

    AdvisorProductDraft selectByProductId(@Param("productId") Long productId);

    int deleteByProductId(@Param("productId") Long productId);
}
