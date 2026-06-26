package com.finance.roboadvisor.review.vo;

import java.math.BigDecimal;

public class ReviewDiffComponentVO {

    private String diffType;
    private Long fundId;
    private String fundCode;
    private String fundName;
    private BigDecimal beforeWeight;
    private BigDecimal afterWeight;
    private BigDecimal deltaWeight;

    public String getDiffType() {
        return diffType;
    }

    public void setDiffType(String diffType) {
        this.diffType = diffType;
    }

    public Long getFundId() {
        return fundId;
    }

    public void setFundId(Long fundId) {
        this.fundId = fundId;
    }

    public String getFundCode() {
        return fundCode;
    }

    public void setFundCode(String fundCode) {
        this.fundCode = fundCode;
    }

    public String getFundName() {
        return fundName;
    }

    public void setFundName(String fundName) {
        this.fundName = fundName;
    }

    public BigDecimal getBeforeWeight() {
        return beforeWeight;
    }

    public void setBeforeWeight(BigDecimal beforeWeight) {
        this.beforeWeight = beforeWeight;
    }

    public BigDecimal getAfterWeight() {
        return afterWeight;
    }

    public void setAfterWeight(BigDecimal afterWeight) {
        this.afterWeight = afterWeight;
    }

    public BigDecimal getDeltaWeight() {
        return deltaWeight;
    }

    public void setDeltaWeight(BigDecimal deltaWeight) {
        this.deltaWeight = deltaWeight;
    }
}
