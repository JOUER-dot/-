package com.finance.roboadvisor.review.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.review.dto.ReviewApproveDTO;
import com.finance.roboadvisor.review.dto.ReviewRejectDTO;
import com.finance.roboadvisor.review.service.ReviewService;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewPendingListItemVO;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/reviewer/products")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping("/pending")
    public ApiResult<PageResult<ReviewPendingListItemVO>> listPendingProducts(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String riskLevel,
            @RequestParam(required = false) Integer pageNum,
            @RequestParam(required = false) Integer pageSize) {
        return ApiResult.success(reviewService.listPendingProducts(keyword, type, riskLevel, pageNum, pageSize));
    }

    @GetMapping("/{id}")
    public ApiResult<ReviewDetailVO> getPendingProductDetail(@PathVariable("id") Long productId) {
        return ApiResult.success(reviewService.getPendingProductDetail(productId));
    }

    @PostMapping("/{id}/approve")
    public ApiResult<Void> approveProduct(@PathVariable("id") Long productId,
                                          @RequestBody(required = false) ReviewApproveDTO dto) {
        reviewService.approveProduct(productId, dto);
        return ApiResult.success("审核通过");
    }

    @PostMapping("/{id}/reject")
    public ApiResult<Void> rejectProduct(@PathVariable("id") Long productId,
                                         @Valid @RequestBody ReviewRejectDTO dto) {
        reviewService.rejectProduct(productId, dto);
        return ApiResult.success("审核驳回成功");
    }
}
