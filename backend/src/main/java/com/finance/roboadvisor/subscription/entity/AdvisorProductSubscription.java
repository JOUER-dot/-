package com.finance.roboadvisor.subscription.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AdvisorProductSubscription {

    private Long id;
    private Long productId;
    private Long userId;
    private String status;
    private BigDecimal investAmount;
    private BigDecimal currentValue;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public BigDecimal getInvestAmount() { return investAmount; }
    public void setInvestAmount(BigDecimal investAmount) { this.investAmount = investAmount; }
    public BigDecimal getCurrentValue() { return currentValue; }
    public void setCurrentValue(BigDecimal currentValue) { this.currentValue = currentValue; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
