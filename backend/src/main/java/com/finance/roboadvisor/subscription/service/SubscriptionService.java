package com.finance.roboadvisor.subscription.service;

import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;

import java.util.List;

public interface SubscriptionService {

    void subscribe(Long productId);

    void unsubscribe(Long productId);

    List<MySubscriptionItemVO> listMySubscriptions();
}
