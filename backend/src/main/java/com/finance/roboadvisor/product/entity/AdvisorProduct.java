package com.finance.roboadvisor.product.entity;

import java.time.LocalDateTime;

public class AdvisorProduct {

    private Long id;
    private String name;
    private String type;
    private String riskLevel;
    private String strategyCode;
    private String featureTags;
    private String status;
    private Long creatorId;
    private Integer currentVersionNo;
    private Integer publishedVersionNo;
    private String lastRejectComment;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

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

    public String getFeatureTags() {
        return featureTags;
    }

    public void setFeatureTags(String featureTags) {
        this.featureTags = featureTags;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getCreatorId() {
        return creatorId;
    }

    public void setCreatorId(Long creatorId) {
        this.creatorId = creatorId;
    }

    public Integer getCurrentVersionNo() {
        return currentVersionNo;
    }

    public void setCurrentVersionNo(Integer currentVersionNo) {
        this.currentVersionNo = currentVersionNo;
    }

    public Integer getPublishedVersionNo() {
        return publishedVersionNo;
    }

    public void setPublishedVersionNo(Integer publishedVersionNo) {
        this.publishedVersionNo = publishedVersionNo;
    }

    public String getLastRejectComment() {
        return lastRejectComment;
    }

    public void setLastRejectComment(String lastRejectComment) {
        this.lastRejectComment = lastRejectComment;
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
