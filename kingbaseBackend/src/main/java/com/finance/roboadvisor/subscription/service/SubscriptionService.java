package com.finance.roboadvisor.subscription.service;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.subscription.dto.MySubscriptionQueryDTO;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;

import java.math.BigDecimal;
import java.util.List;

public interface SubscriptionService {

    void subscribe(Long productId, BigDecimal amount);

    void unsubscribe(Long productId);

    List<MySubscriptionItemVO> listMySubscriptions();

    PageResult<MySubscriptionItemVO> listMySubscriptions(MySubscriptionQueryDTO queryDTO);

    void createVersionActions(Long productId,
                              Long productVersionId,
                              String changeType,
                              String actionType,
                              String actionStatus,
                              String versionNote);

    void decideVersionAction(Long subscriptionId, String decision);
}
