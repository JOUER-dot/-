package com.finance.roboadvisor.product.vo;

import java.util.List;

public class WorkbenchVO {

    private OverviewVO overview;
    private List<UrgentProductVO> urgentProducts;
    private List<ProductRankingVO> productRankings;

    public OverviewVO getOverview() { return overview; }
    public void setOverview(OverviewVO overview) { this.overview = overview; }
    public List<UrgentProductVO> getUrgentProducts() { return urgentProducts; }
    public void setUrgentProducts(List<UrgentProductVO> urgentProducts) { this.urgentProducts = urgentProducts; }
    public List<ProductRankingVO> getProductRankings() { return productRankings; }
    public void setProductRankings(List<ProductRankingVO> productRankings) { this.productRankings = productRankings; }

    public static class OverviewVO {
        private long totalProducts;
        private long publishedProducts;
        private long pendingReviewProducts;
        private long rejectedProducts;
        private long draftProducts;
        private long totalSubscriptions;
        private long recentWeekSubscriptions;

        public long getTotalProducts() { return totalProducts; }
        public void setTotalProducts(long totalProducts) { this.totalProducts = totalProducts; }
        public long getPublishedProducts() { return publishedProducts; }
        public void setPublishedProducts(long publishedProducts) { this.publishedProducts = publishedProducts; }
        public long getPendingReviewProducts() { return pendingReviewProducts; }
        public void setPendingReviewProducts(long pendingReviewProducts) { this.pendingReviewProducts = pendingReviewProducts; }
        public long getRejectedProducts() { return rejectedProducts; }
        public void setRejectedProducts(long rejectedProducts) { this.rejectedProducts = rejectedProducts; }
        public long getDraftProducts() { return draftProducts; }
        public void setDraftProducts(long draftProducts) { this.draftProducts = draftProducts; }
        public long getTotalSubscriptions() { return totalSubscriptions; }
        public void setTotalSubscriptions(long totalSubscriptions) { this.totalSubscriptions = totalSubscriptions; }
        public long getRecentWeekSubscriptions() { return recentWeekSubscriptions; }
        public void setRecentWeekSubscriptions(long recentWeekSubscriptions) { this.recentWeekSubscriptions = recentWeekSubscriptions; }
    }

    public static class UrgentProductVO {
        private Long id;
        private String name;
        private String type;
        private String riskLevel;
        private String status;
        private String lastRejectComment;
        private String updatedAt;
        private long waitingDays;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getRiskLevel() { return riskLevel; }
        public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getLastRejectComment() { return lastRejectComment; }
        public void setLastRejectComment(String lastRejectComment) { this.lastRejectComment = lastRejectComment; }
        public String getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
        public long getWaitingDays() { return waitingDays; }
        public void setWaitingDays(long waitingDays) { this.waitingDays = waitingDays; }
    }

    public static class ProductRankingVO {
        private Long id;
        private String name;
        private String type;
        private String riskLevel;
        private String latestNav;
        private String cumReturn;
        private long subscriberCount;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getType() { return type; }
        public void setType(String type) { this.type = type; }
        public String getRiskLevel() { return riskLevel; }
        public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
        public String getLatestNav() { return latestNav; }
        public void setLatestNav(String latestNav) { this.latestNav = latestNav; }
        public String getCumReturn() { return cumReturn; }
        public void setCumReturn(String cumReturn) { this.cumReturn = cumReturn; }
        public long getSubscriberCount() { return subscriberCount; }
        public void setSubscriberCount(long subscriberCount) { this.subscriberCount = subscriberCount; }
    }
}
