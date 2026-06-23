package com.finance.roboadvisor.subscription.service.impl;

import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.subscription.entity.AdvisorProductSubscription;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import com.finance.roboadvisor.subscription.service.SubscriptionService;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class SubscriptionServiceImpl implements SubscriptionService {

    private static final String STATUS_ACTIVE = "ACTIVE";

    private final SubscriptionMapper subscriptionMapper;
    private final PublicProductMapper publicProductMapper;

    public SubscriptionServiceImpl(SubscriptionMapper subscriptionMapper,
                                   PublicProductMapper publicProductMapper) {
        this.subscriptionMapper = subscriptionMapper;
        this.publicProductMapper = publicProductMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void subscribe(Long productId) {
        Long userId = SecurityUtil.getCurrentUserId();
        Long publishedCount = publicProductMapper.countPublishedProductById(productId);
        if (publishedCount == null || publishedCount == 0) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "产品不存在或未上架");
        }

        AdvisorProductSubscription existing = subscriptionMapper.selectByUserIdAndProductId(userId, productId);
        if (existing == null) {
            AdvisorProductSubscription subscription = new AdvisorProductSubscription();
            subscription.setProductId(productId);
            subscription.setUserId(userId);
            subscription.setStatus(STATUS_ACTIVE);
            subscriptionMapper.insert(subscription);
            return;
        }
        if (STATUS_ACTIVE.equals(existing.getStatus())) {
            return;
        }
        subscriptionMapper.updateStatusToActive(existing.getId());
    }

    @Override
    public List<MySubscriptionItemVO> listMySubscriptions() {
        Long userId = SecurityUtil.getCurrentUserId();
        return subscriptionMapper.selectActiveSubscriptionsByUserId(userId);
    }
}
