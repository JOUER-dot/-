package com.finance.roboadvisor.product.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AdvisorProductRuleDecision {

    private Long id;
    private Long productId;
    private Long productVersionId;
    private Long baseRuleId;
    private Long reviewerId;
    private Integer overrideMinFundCount;
    private Integer overrideMaxFundCount;
    private BigDecimal overrideMaxSingleWeight;
    private String finalRuleJson;
    private String decisionComment;
    private LocalDateTime createdAt;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public Long getProductVersionId() {
        return productVersionId;
    }

    public void setProductVersionId(Long productVersionId) {
        this.productVersionId = productVersionId;
    }

    public Long getBaseRuleId() {
        return baseRuleId;
    }

    public void setBaseRuleId(Long baseRuleId) {
        this.baseRuleId = baseRuleId;
    }

    public Long getReviewerId() {
        return reviewerId;
    }

    public void setReviewerId(Long reviewerId) {
        this.reviewerId = reviewerId;
    }

    public Integer getOverrideMinFundCount() {
        return overrideMinFundCount;
    }

    public void setOverrideMinFundCount(Integer overrideMinFundCount) {
        this.overrideMinFundCount = overrideMinFundCount;
    }

    public Integer getOverrideMaxFundCount() {
        return overrideMaxFundCount;
    }

    public void setOverrideMaxFundCount(Integer overrideMaxFundCount) {
        this.overrideMaxFundCount = overrideMaxFundCount;
    }

    public BigDecimal getOverrideMaxSingleWeight() {
        return overrideMaxSingleWeight;
    }

    public void setOverrideMaxSingleWeight(BigDecimal overrideMaxSingleWeight) {
        this.overrideMaxSingleWeight = overrideMaxSingleWeight;
    }

    public String getFinalRuleJson() {
        return finalRuleJson;
    }

    public void setFinalRuleJson(String finalRuleJson) {
        this.finalRuleJson = finalRuleJson;
    }

    public String getDecisionComment() {
        return decisionComment;
    }

    public void setDecisionComment(String decisionComment) {
        this.decisionComment = decisionComment;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
