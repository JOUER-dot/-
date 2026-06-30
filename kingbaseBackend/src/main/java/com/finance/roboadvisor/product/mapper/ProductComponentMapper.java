package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductComponent;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductComponentMapper {

    int batchInsert(@Param("items") List<AdvisorProductComponent> items);

    List<DraftComponentVO> selectByVersionId(@Param("productVersionId") Long productVersionId);
}
