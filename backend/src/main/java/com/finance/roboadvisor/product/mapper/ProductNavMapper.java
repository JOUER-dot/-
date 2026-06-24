package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductNav;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductNavMapper {

    int deleteByProductId(@Param("productId") Long productId);

    int batchInsert(@Param("items") List<AdvisorProductNav> items);
}
