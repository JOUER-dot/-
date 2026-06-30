package com.finance.roboadvisor.subscription.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.subscription.dto.MySubscriptionQueryDTO;
import com.finance.roboadvisor.subscription.dto.SubscriptionVersionDecisionDTO;
import com.finance.roboadvisor.subscription.service.SubscriptionService;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @PostMapping("/api/public/advisor-products/{id}/subscribe")
    public ApiResult<Void> subscribe(@PathVariable("id") Long productId,
                                     @RequestBody(required = false) Map<String, Object> body) {
        BigDecimal amount = body != null && body.get("amount") != null
                ? new BigDecimal(body.get("amount").toString())
                : null;
        subscriptionService.subscribe(productId, amount);
        return ApiResult.success("订阅成功");
    }

    @PostMapping("/api/public/advisor-products/{id}/unsubscribe")
    public ApiResult<Void> unsubscribe(@PathVariable("id") Long productId) {
        subscriptionService.unsubscribe(productId);
        return ApiResult.success("取消订阅成功");
    }

    @GetMapping("/api/auth/my-subscriptions")
    public ApiResult<PageResult<MySubscriptionItemVO>> listMySubscriptions(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String subscriptionStatus,
            @RequestParam(required = false) String productStatus,
            @RequestParam(required = false) String sortBy,
            @RequestParam(required = false) Integer pageNum,
            @RequestParam(required = false) Integer pageSize
    ) {
        MySubscriptionQueryDTO queryDTO = new MySubscriptionQueryDTO();
        queryDTO.setKeyword(keyword);
        queryDTO.setSubscriptionStatus(subscriptionStatus);
        queryDTO.setProductStatus(productStatus);
        queryDTO.setSortBy(sortBy);
        queryDTO.setPageNum(pageNum);
        queryDTO.setPageSize(pageSize);
        return ApiResult.success(subscriptionService.listMySubscriptions(queryDTO));
    }

    @PostMapping("/api/auth/my-subscriptions/{subscriptionId}/version-decision")
    public ApiResult<Void> decideVersionAction(@PathVariable Long subscriptionId,
                                               @RequestBody(required = false) SubscriptionVersionDecisionDTO dto) {
        subscriptionService.decideVersionAction(subscriptionId, dto == null ? null : dto.getDecision());
        return ApiResult.success("处理订阅决策成功");
    }
}
