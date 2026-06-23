package com.finance.roboadvisor.product.vo;

import java.util.List;
import java.util.Map;

public class ProductDetailVO {

    private Long id;
    private String name;
    private String type;
    private String riskLevel;
    private String strategyCode;
    private List<String> featureTags;
    private String status;
    private String lastRejectComment;
    private Map<String, Object> baseInfo;
    private Map<String, Object> params;
    private List<DraftComponentVO> components;
    private PublishedVersionVO publishedVersion;
    private List<ReviewRecordVO> reviewSummary;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
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

    public String getStrategyCode() {
        return strategyCode;
    }

    public void setStrategyCode(String strategyCode) {
        this.strategyCode = strategyCode;
    }

    public List<String> getFeatureTags() {
        return featureTags;
    }

    public void setFeatureTags(List<String> featureTags) {
        this.featureTags = featureTags;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getLastRejectComment() {
        return lastRejectComment;
    }

    public void setLastRejectComment(String lastRejectComment) {
        this.lastRejectComment = lastRejectComment;
    }

    public Map<String, Object> getBaseInfo() {
        return baseInfo;
    }

    public void setBaseInfo(Map<String, Object> baseInfo) {
        this.baseInfo = baseInfo;
    }

    public Map<String, Object> getParams() {
        return params;
    }

    public void setParams(Map<String, Object> params) {
        this.params = params;
    }

    public List<DraftComponentVO> getComponents() {
        return components;
    }

    public void setComponents(List<DraftComponentVO> components) {
        this.components = components;
    }

    public PublishedVersionVO getPublishedVersion() {
        return publishedVersion;
    }

    public void setPublishedVersion(PublishedVersionVO publishedVersion) {
        this.publishedVersion = publishedVersion;
    }

    public List<ReviewRecordVO> getReviewSummary() {
        return reviewSummary;
    }

    public void setReviewSummary(List<ReviewRecordVO> reviewSummary) {
        this.reviewSummary = reviewSummary;
    }
}
