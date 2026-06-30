package com.finance.roboadvisor.review.mapper;

import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewHistoryItemVO;
import com.finance.roboadvisor.review.vo.ReviewPendingListItemVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ReviewMapper {

    List<ReviewPendingListItemVO> selectPendingProducts(@Param("keyword") String keyword,
                                                        @Param("type") String type,
                                                        @Param("riskLevel") String riskLevel,
                                                        @Param("offset") Integer offset,
                                                        @Param("pageSize") Integer pageSize);

    Long countPendingProducts(@Param("keyword") String keyword,
                              @Param("type") String type,
                              @Param("riskLevel") String riskLevel);

    ReviewDetailVO selectPendingProductDetail(@Param("productId") Long productId);

    List<ReviewHistoryItemVO> selectReviewHistoryByReviewer(@Param("reviewerId") Long reviewerId,
                                                             @Param("offset") Integer offset,
                                                             @Param("pageSize") Integer pageSize);
}
