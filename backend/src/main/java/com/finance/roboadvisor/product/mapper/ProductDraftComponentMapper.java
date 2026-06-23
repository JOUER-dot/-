package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.entity.AdvisorProductDraftComponent;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductDraftComponentMapper {

    int batchInsert(@Param("items") List<AdvisorProductDraftComponent> items);

    int deleteByDraftId(@Param("draftId") Long draftId);

    List<DraftComponentVO> selectByDraftId(@Param("draftId") Long draftId);
}
