package com.finance.roboadvisor.subscription.vo;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class MySubscriptionItemVO {

    private Long subscriptionId;
    private Long productId;
    private String productName;
    private String type;
    private String riskLevel;
    private String productStatus;
    private String status;
    private BigDecimal latestNav;
    private BigDecimal latestCumReturn;
    private LocalDateTime subscribedAt;

    public Long getSubscriptionId() {
        return subscriptionId;
    }

    public void setSubscriptionId(Long subscriptionId) {
        this.subscriptionId = subscriptionId;
    }

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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public String getProductStatus() {
        return productStatus;
    }

    public void setProductStatus(String productStatus) {
        this.productStatus = productStatus;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getLatestNav() {
        return latestNav;
    }

    public void setLatestNav(BigDecimal latestNav) {
        this.latestNav = latestNav;
    }

    public BigDecimal getLatestCumReturn() {
        return latestCumReturn;
    }

    public void setLatestCumReturn(BigDecimal latestCumReturn) {
        this.latestCumReturn = latestCumReturn;
    }

    public LocalDateTime getSubscribedAt() {
        return subscribedAt;
    }

    public void setSubscribedAt(LocalDateTime subscribedAt) {
        this.subscribedAt = subscribedAt;
    }
}
