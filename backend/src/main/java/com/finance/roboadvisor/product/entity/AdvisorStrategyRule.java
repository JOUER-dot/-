package com.finance.roboadvisor.product.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AdvisorStrategyRule {

    private Long id;
    private String strategyCode;
    private String productType;
    private Integer minFundCount;
    private Integer maxFundCount;
    private BigDecimal minSingleWeight;
    private BigDecimal maxSingleWeight;
    private String allowFundTypes;
    private String riskRuleMode;
    private Integer status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getStrategyCode() {
        return strategyCode;
    }

    public void setStrategyCode(String strategyCode) {
        this.strategyCode = strategyCode;
    }

    public String getProductType() {
        return productType;
    }

    public void setProductType(String productType) {
        this.productType = productType;
    }

    public Integer getMinFundCount() {
        return minFundCount;
    }

    public void setMinFundCount(Integer minFundCount) {
        this.minFundCount = minFundCount;
    }

    public Integer getMaxFundCount() {
        return maxFundCount;
    }

    public void setMaxFundCount(Integer maxFundCount) {
        this.maxFundCount = maxFundCount;
    }

    public BigDecimal getMinSingleWeight() {
        return minSingleWeight;
    }

    public void setMinSingleWeight(BigDecimal minSingleWeight) {
        this.minSingleWeight = minSingleWeight;
    }

    public BigDecimal getMaxSingleWeight() {
        return maxSingleWeight;
    }

    public void setMaxSingleWeight(BigDecimal maxSingleWeight) {
        this.maxSingleWeight = maxSingleWeight;
    }

    public String getAllowFundTypes() {
        return allowFundTypes;
    }

    public void setAllowFundTypes(String allowFundTypes) {
        this.allowFundTypes = allowFundTypes;
    }

    public String getRiskRuleMode() {
        return riskRuleMode;
    }

    public void setRiskRuleMode(String riskRuleMode) {
        this.riskRuleMode = riskRuleMode;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
