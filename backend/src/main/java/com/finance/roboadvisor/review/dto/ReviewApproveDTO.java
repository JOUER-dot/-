package com.finance.roboadvisor.review.dto;

import java.math.BigDecimal;

public class ReviewApproveDTO {

    private Integer overrideMinFundCount;
    private Integer overrideMaxFundCount;
    private BigDecimal overrideMaxSingleWeight;
    private String decisionComment;

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

    public String getDecisionComment() {
        return decisionComment;
    }

    public void setDecisionComment(String decisionComment) {
        this.decisionComment = decisionComment;
    }
}
