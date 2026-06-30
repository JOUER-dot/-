package com.finance.roboadvisor.admin.vo;

import java.math.BigDecimal;
import java.util.List;

public class AdminDashboardVO {

    private long totalProducts;
    private long publishedProducts;
    private long pendingReviewProducts;
    private long totalAdvisors;
    private long totalUsers;
    private long totalSubscriptions;
    private List<ProductSubscriptionVO> topSubscribedProducts;
    private List<RecentChangeVO> recentChanges;

    public long getTotalProducts() {
        return totalProducts;
    }

    public void setTotalProducts(long totalProducts) {
        this.totalProducts = totalProducts;
    }

    public long getPublishedProducts() {
        return publishedProducts;
    }

    public void setPublishedProducts(long publishedProducts) {
        this.publishedProducts = publishedProducts;
    }

    public long getPendingReviewProducts() {
        return pendingReviewProducts;
    }

    public void setPendingReviewProducts(long pendingReviewProducts) {
        this.pendingReviewProducts = pendingReviewProducts;
    }

    public long getTotalAdvisors() {
        return totalAdvisors;
    }

    public void setTotalAdvisors(long totalAdvisors) {
        this.totalAdvisors = totalAdvisors;
    }

    public long getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(long totalUsers) {
        this.totalUsers = totalUsers;
    }

    public long getTotalSubscriptions() {
        return totalSubscriptions;
    }

    public void setTotalSubscriptions(long totalSubscriptions) {
        this.totalSubscriptions = totalSubscriptions;
    }

    public List<ProductSubscriptionVO> getTopSubscribedProducts() {
        return topSubscribedProducts;
    }

    public void setTopSubscribedProducts(List<ProductSubscriptionVO> topSubscribedProducts) {
        this.topSubscribedProducts = topSubscribedProducts;
    }

    public List<RecentChangeVO> getRecentChanges() {
        return recentChanges;
    }

    public void setRecentChanges(List<RecentChangeVO> recentChanges) {
        this.recentChanges = recentChanges;
    }

    public static class ProductSubscriptionVO {
        private Long productId;
        private String productName;
        private long subscriberCount;

        public Long getProductId() {
            return productId;
        }

        public void setProductId(Long productId) {
            this.productId = productId;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public long getSubscriberCount() {
            return subscriberCount;
        }

        public void setSubscriberCount(long subscriberCount) {
            this.subscriberCount = subscriberCount;
        }
    }

    public static class RecentChangeVO {
        private Long productId;
        private String productName;
        private String actionType;
        private String operatorName;
        private String createdAt;

        public Long getProductId() {
            return productId;
        }

        public void setProductId(Long productId) {
            this.productId = productId;
        }

        public String getProductName() {
            return productName;
        }

        public void setProductName(String productName) {
            this.productName = productName;
        }

        public String getActionType() {
            return actionType;
        }

        public void setActionType(String actionType) {
            this.actionType = actionType;
        }

        public String getOperatorName() {
            return operatorName;
        }

        public void setOperatorName(String operatorName) {
            this.operatorName = operatorName;
        }

        public String getCreatedAt() {
            return createdAt;
        }

        public void setCreatedAt(String createdAt) {
            this.createdAt = createdAt;
        }
    }
}
