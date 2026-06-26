package com.finance.roboadvisor.product.service.impl;

import com.finance.roboadvisor.common.util.SecurityUtil;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductNavMapper;
import com.finance.roboadvisor.product.service.WorkbenchService;
import com.finance.roboadvisor.product.vo.WorkbenchVO;
import com.finance.roboadvisor.subscription.mapper.SubscriptionMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class WorkbenchServiceImpl implements WorkbenchService {

    private final ProductMapper productMapper;
    private final SubscriptionMapper subscriptionMapper;

    public WorkbenchServiceImpl(ProductMapper productMapper,
                                SubscriptionMapper subscriptionMapper) {
        this.productMapper = productMapper;
        this.subscriptionMapper = subscriptionMapper;
    }

    @Override
    public WorkbenchVO getAdvisorWorkbench() {
        Long currentUserId = SecurityUtil.getCurrentUserId();
        WorkbenchVO vo = new WorkbenchVO();

        // 1. Overview stats
        WorkbenchVO.OverviewVO overview = new WorkbenchVO.OverviewVO();
        long total = productMapper.countByCreator(currentUserId, null, null, null, null);
        long published = productMapper.countByCreator(currentUserId, "PUBLISHED", null, null, null);
        long pending = productMapper.countByCreator(currentUserId, "PENDING_REVIEW", null, null, null);
        long rejected = productMapper.countByCreator(currentUserId, "REJECTED", null, null, null);
        long draft = productMapper.countByCreator(currentUserId, "DRAFT", null, null, null);
        overview.setTotalProducts(total);
        overview.setPublishedProducts(published);
        overview.setPendingReviewProducts(pending);
        overview.setRejectedProducts(rejected);
        overview.setDraftProducts(draft);
        overview.setTotalSubscriptions(subscriptionMapper.countActiveByCreatorId(currentUserId));
        overview.setRecentWeekSubscriptions(subscriptionMapper.countRecentWeekByCreatorId(currentUserId));
        vo.setOverview(overview);

        // 2. Urgent products (rejected first, then pending review, top 5)
        List<AdvisorProduct> allProducts = productMapper.selectByCreator(currentUserId, null, null, null, null, 0, 9999);
        List<WorkbenchVO.UrgentProductVO> urgent = allProducts.stream()
                .filter(p -> "REJECTED".equals(p.getStatus()) || "PENDING_REVIEW".equals(p.getStatus()))
                .sorted((a, b) -> {
                    int pa = "REJECTED".equals(a.getStatus()) ? 0 : 1;
                    int pb = "REJECTED".equals(b.getStatus()) ? 0 : 1;
                    if (pa != pb) return pa - pb;
                    return b.getUpdatedAt().compareTo(a.getUpdatedAt());
                })
                .limit(5)
                .map(p -> {
                    WorkbenchVO.UrgentProductVO u = new WorkbenchVO.UrgentProductVO();
                    u.setId(p.getId());
                    u.setName(p.getName());
                    u.setType(p.getType());
                    u.setRiskLevel(p.getRiskLevel());
                    u.setStatus(p.getStatus());
                    u.setLastRejectComment(p.getLastRejectComment());
                    u.setUpdatedAt(p.getUpdatedAt() != null ? p.getUpdatedAt().toString() : null);
                    u.setWaitingDays(p.getUpdatedAt() != null
                            ? ChronoUnit.DAYS.between(p.getUpdatedAt(), LocalDateTime.now())
                            : 0);
                    return u;
                })
                .toList();
        vo.setUrgentProducts(urgent);

        // 3. Product rankings (published products with subscriber counts)
        List<AdvisorProduct> publishedProducts = allProducts.stream()
                .filter(p -> "PUBLISHED".equals(p.getStatus()))
                .toList();
        List<WorkbenchVO.ProductRankingVO> rankings = publishedProducts.stream()
                .map(p -> {
                    WorkbenchVO.ProductRankingVO r = new WorkbenchVO.ProductRankingVO();
                    r.setId(p.getId());
                    r.setName(p.getName());
                    r.setType(p.getType());
                    r.setRiskLevel(p.getRiskLevel());
                    r.setLatestNav("-");
                    r.setCumReturn("-");
                    r.setSubscriberCount(subscriptionMapper.countByProductId(p.getId()));
                    return r;
                })
                .sorted((a, b) -> Long.compare(b.getSubscriberCount(), a.getSubscriberCount()))
                .toList();
        vo.setProductRankings(rankings);

        return vo;
    }
}
