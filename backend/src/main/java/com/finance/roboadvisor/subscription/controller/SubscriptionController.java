package com.finance.roboadvisor.subscription.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.subscription.service.SubscriptionService;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @PostMapping("/api/public/advisor-products/{id}/subscribe")
    public ApiResult<Void> subscribe(@PathVariable("id") Long productId) {
        subscriptionService.subscribe(productId);
        return ApiResult.success("订阅成功");
    }

    @PostMapping("/api/public/advisor-products/{id}/unsubscribe")
    public ApiResult<Void> unsubscribe(@PathVariable("id") Long productId) {
        subscriptionService.unsubscribe(productId);
        return ApiResult.success("取消订阅成功");
    }

    @GetMapping("/api/auth/my-subscriptions")
    public ApiResult<List<MySubscriptionItemVO>> listMySubscriptions() {
        return ApiResult.success(subscriptionService.listMySubscriptions());
    }
}
