package com.finance.roboadvisor.product.mapper;

import com.finance.roboadvisor.product.vo.ReviewRecordVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProductReviewMapper {

    List<ReviewRecordVO> selectByProductId(@Param("productId") Long productId);
}
