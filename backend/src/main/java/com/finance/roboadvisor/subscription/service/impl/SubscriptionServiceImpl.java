package com.finance.roboadvisor.subscription.service.impl;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.api.ResultCode;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.notification.service.NotificationService;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.subscription.dto.MySubscriptionQueryDTO;
import com.finance.roboadvisor.transaction.service.TransactionService;
import com.finance.roboadvisor.subscription.entity.AdvisorProductSubscription;
import com.finance.roboadvisor.subscription.entity.SubscriptionVersionAction;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import com.finance.roboadvisor.subscription.mapper.SubscriptionVersionActionMapper;
import com.finance.roboadvisor.subscription.service.SubscriptionService;
import com.finance.roboadvisor.subscription.vo.MySubscriptionItemVO;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class SubscriptionServiceImpl implements SubscriptionService {

    private static final String STATUS_ACTIVE = "ACTIVE";
    private static final String STATUS_CANCELLED = "CANCELLED";
    private static final String ACTION_TYPE_CONFIRM_REQUIRED = "CONFIRM_REQUIRED";
    private static final String ACTION_STATUS_PENDING = "PENDING";
    private static final String ACTION_STATUS_CONFIRMED = "CONFIRMED";
    private static final String ACTION_STATUS_CANCELLED = "CANCELLED";
    private static final String DECISION_CONFIRM = "CONFIRM";
    private static final String DECISION_CANCEL = "CANCEL";
    private static final int DEFAULT_PAGE_NUM = 1;
    private static final int DEFAULT_PAGE_SIZE = 10;
    private static final String DEFAULT_SORT_BY = "subscribedAtDesc";

    private final SubscriptionMapper subscriptionMapper;
    private final PublicProductMapper publicProductMapper;
    private final SubscriptionVersionActionMapper subscriptionVersionActionMapper;
    private final NotificationService notificationService;
    private final ProductMapper productMapper;
    private final TransactionService transactionService;

    public SubscriptionServiceImpl(SubscriptionMapper subscriptionMapper,
                                   PublicProductMapper publicProductMapper,
                                   SubscriptionVersionActionMapper subscriptionVersionActionMapper,
                                   NotificationService notificationService,
                                   ProductMapper productMapper,
                                   TransactionService transactionService) {
        this.subscriptionMapper = subscriptionMapper;
        this.publicProductMapper = publicProductMapper;
        this.subscriptionVersionActionMapper = subscriptionVersionActionMapper;
        this.notificationService = notificationService;
        this.productMapper = productMapper;
        this.transactionService = transactionService;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void subscribe(Long productId, BigDecimal amount) {
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
            subscription.setInvestAmount(amount);
            subscription.setCurrentValue(amount);
            subscriptionMapper.insert(subscription);
            notifyAdvisorOnSubscription(productId, "订阅");
            // Notify the subscriber
            notificationService.createNotification(userId, "订阅成功", "您已成功订阅产品", "SUBSCRIPTION", "/my-subscriptions");
            if (amount != null) {
                com.finance.roboadvisor.product.entity.AdvisorProduct p = productMapper.selectById(productId);
                transactionService.record(userId, productId, p != null ? p.getName() : String.valueOf(productId), "SUBSCRIBE", amount);
            }
            return;
        }
        if (STATUS_ACTIVE.equals(existing.getStatus())) {
            return;
        }
        subscriptionMapper.updateStatusToActive(existing.getId());
        if (amount != null) {
            subscriptionMapper.updateInvestAmount(existing.getId(), amount, amount);
        }
        notifyAdvisorOnSubscription(productId, "订阅");
    }

    private void notifyAdvisorOnSubscription(Long productId, String action) {
        try {
            com.finance.roboadvisor.product.entity.AdvisorProduct product = productMapper.selectById(productId);
            if (product != null && product.getCreatorId() != null) {
                notificationService.createNotification(product.getCreatorId(),
                        "订阅通知",
                        "有用户" + action + "了您的产品「" + product.getName() + "」",
                        "SUBSCRIPTION",
                        "/admin/products/" + productId);
            }
        } catch (Exception ignored) {
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void unsubscribe(Long productId) {
        Long userId = SecurityUtil.getCurrentUserId();
        AdvisorProductSubscription existing = subscriptionMapper.selectByUserIdAndProductId(userId, productId);
        if (existing == null) {
            return;
        }
        if (STATUS_CANCELLED.equals(existing.getStatus())) {
            return;
        }
        subscriptionMapper.updateStatusToCancelled(existing.getId());
        notifyAdvisorOnSubscription(productId, "取消订阅");
    }

    @Override
    public List<MySubscriptionItemVO> listMySubscriptions() {
        Long userId = SecurityUtil.getCurrentUserId();
        List<MySubscriptionItemVO> records = subscriptionMapper.selectSubscriptionsByUserId(userId);
        attachPendingVersionActions(records);
        return records;
    }

    @Override
    public PageResult<MySubscriptionItemVO> listMySubscriptions(MySubscriptionQueryDTO queryDTO) {
        Long userId = SecurityUtil.getCurrentUserId();
        int safePageNum = queryDTO == null || queryDTO.getPageNum() == null || queryDTO.getPageNum() < 1
                ? DEFAULT_PAGE_NUM
                : queryDTO.getPageNum();
        int safePageSize = queryDTO == null || queryDTO.getPageSize() == null || queryDTO.getPageSize() < 1
                ? DEFAULT_PAGE_SIZE
                : queryDTO.getPageSize();
        int offset = (safePageNum - 1) * safePageSize;

        String keyword = trimToNull(queryDTO == null ? null : queryDTO.getKeyword());
        String subscriptionStatus = trimToNull(queryDTO == null ? null : queryDTO.getSubscriptionStatus());
        String productStatus = trimToNull(queryDTO == null ? null : queryDTO.getProductStatus());
        String sortBy = normalizeSortBy(queryDTO == null ? null : queryDTO.getSortBy());

        List<MySubscriptionItemVO> records = subscriptionMapper.selectSubscriptionsPageByUserId(
                userId,
                keyword,
                subscriptionStatus,
                productStatus,
                sortBy,
                offset,
                safePageSize
        );
        Long total = subscriptionMapper.countSubscriptionsByUserId(
                userId,
                keyword,
                subscriptionStatus,
                productStatus
        );
        attachPendingVersionActions(records);
        return new PageResult<>(records, total, safePageNum, safePageSize);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createVersionActions(Long productId,
                                     Long productVersionId,
                                     String changeType,
                                     String actionType,
                                     String actionStatus,
                                     String versionNote) {
        List<AdvisorProductSubscription> subscriptions = subscriptionMapper.selectActiveSubscriptionsByProductId(productId);
        if (subscriptions == null || subscriptions.isEmpty()) {
            return;
        }
        for (AdvisorProductSubscription subscription : subscriptions) {
            SubscriptionVersionAction action = new SubscriptionVersionAction();
            action.setSubscriptionId(subscription.getId());
            action.setProductId(productId);
            action.setProductVersionId(productVersionId);
            action.setActionType(actionType);
            action.setActionStatus(actionStatus);
            action.setChangeType(changeType);
            action.setVersionNote(trimToNull(versionNote));
            subscriptionVersionActionMapper.insert(action);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void decideVersionAction(Long subscriptionId, String decision) {
        Long userId = SecurityUtil.getCurrentUserId();
        AdvisorProductSubscription subscription = getOwnedSubscription(subscriptionId, userId);
        SubscriptionVersionAction action = getPendingDecisionAction(subscriptionId);
        String normalizedDecision = normalizeDecision(decision);
        if (DECISION_CONFIRM.equals(normalizedDecision)) {
            if (!ACTION_TYPE_CONFIRM_REQUIRED.equals(action.getActionType())
                    || !ACTION_STATUS_PENDING.equals(action.getActionStatus())) {
                throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前订阅无需确认");
            }
            subscriptionVersionActionMapper.updateStatus(action.getId(), ACTION_STATUS_CONFIRMED);
            return;
        }
        subscriptionMapper.updateStatusToCancelled(subscription.getId());
        subscriptionVersionActionMapper.updateStatus(action.getId(), ACTION_STATUS_CANCELLED);
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void attachPendingVersionActions(List<MySubscriptionItemVO> records) {
        if (records == null || records.isEmpty()) {
            return;
        }
        List<Long> subscriptionIds = new ArrayList<>();
        for (MySubscriptionItemVO item : records) {
            item.setPendingVersionActions(new ArrayList<>());
            if (item.getSubscriptionId() != null) {
                subscriptionIds.add(item.getSubscriptionId());
            }
        }
        if (subscriptionIds.isEmpty()) {
            return;
        }
        List<SubscriptionVersionAction> actions = subscriptionVersionActionMapper.selectPendingBySubscriptionIds(subscriptionIds);
        if (actions == null || actions.isEmpty()) {
            return;
        }
        Map<Long, List<SubscriptionVersionAction>> actionsBySubscriptionId = new LinkedHashMap<>();
        for (SubscriptionVersionAction action : actions) {
            if (action.getSubscriptionId() == null) {
                continue;
            }
            actionsBySubscriptionId
                    .computeIfAbsent(action.getSubscriptionId(), key -> new ArrayList<>())
                    .add(action);
        }
        for (MySubscriptionItemVO item : records) {
            List<SubscriptionVersionAction> pendingActions = actionsBySubscriptionId.get(item.getSubscriptionId());
            item.setPendingVersionActions(pendingActions == null ? new ArrayList<>() : pendingActions);
        }
    }

    private String normalizeSortBy(String sortBy) {
        if (sortBy == null || sortBy.isBlank()) {
            return DEFAULT_SORT_BY;
        }
        return switch (sortBy) {
            case "subscribedAtAsc", "productNameAsc", "productStatusFirst" -> sortBy;
            default -> DEFAULT_SORT_BY;
        };
    }

    private AdvisorProductSubscription getOwnedSubscription(Long subscriptionId, Long userId) {
        AdvisorProductSubscription subscription = subscriptionMapper.selectById(subscriptionId);
        if (subscription == null || !userId.equals(subscription.getUserId())) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "订阅不存在或无权操作");
        }
        return subscription;
    }

    private SubscriptionVersionAction getPendingDecisionAction(Long subscriptionId) {
        SubscriptionVersionAction action = subscriptionVersionActionMapper.selectLatestPendingBySubscriptionId(subscriptionId);
        if (action == null) {
            throw new BusinessException(ResultCode.STATUS_NOT_ALLOWED, "当前订阅没有待处理版本动作");
        }
        return action;
    }

    private String normalizeDecision(String decision) {
        if (!StringUtils.hasText(decision)) {
            throw new BusinessException(ResultCode.VALIDATE_FAILED, "订阅决策不能为空");
        }
        String normalized = decision.trim().toUpperCase();
        if (DECISION_CONFIRM.equals(normalized) || DECISION_CANCEL.equals(normalized)) {
            return normalized;
        }
        throw new BusinessException(ResultCode.VALIDATE_FAILED, "不支持的订阅决策");
    }
}
