package com.finance.roboadvisor.product.vo;

import java.time.LocalDateTime;
import java.util.List;

public class ProductListItemVO {

    private Long id;
    private String name;
    private String type;
    private String riskLevel;
    private String status;
    private List<String> featureTags;
    private LocalDateTime updatedAt;
    private String lastRejectComment;

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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public List<String> getFeatureTags() {
        return featureTags;
    }

    public void setFeatureTags(List<String> featureTags) {
        this.featureTags = featureTags;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getLastRejectComment() {
        return lastRejectComment;
    }

    public void setLastRejectComment(String lastRejectComment) {
        this.lastRejectComment = lastRejectComment;
    }
}
