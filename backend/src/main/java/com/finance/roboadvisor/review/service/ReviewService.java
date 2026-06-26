package com.finance.roboadvisor.review.service;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.review.dto.ReviewApproveDTO;
import com.finance.roboadvisor.review.dto.ReviewRejectDTO;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewHistoryItemVO;
import com.finance.roboadvisor.review.vo.ReviewPendingListItemVO;

import java.util.List;

public interface ReviewService {

    PageResult<ReviewPendingListItemVO> listPendingProducts(String keyword,
                                                            String type,
                                                            String riskLevel,
                                                            Integer pageNum,
                                                            Integer pageSize);

    ReviewDetailVO getPendingProductDetail(Long productId);

    void approveProduct(Long productId, ReviewApproveDTO dto);

    void rejectProduct(Long productId, ReviewRejectDTO dto);

    void batchApprove(List<Long> productIds, ReviewApproveDTO dto);

    void batchReject(List<Long> productIds, ReviewRejectDTO dto);

    List<ReviewHistoryItemVO> getMyReviewHistory(Integer pageNum, Integer pageSize);
}
