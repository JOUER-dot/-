package com.finance.roboadvisor.product.entity;

import java.time.LocalDateTime;

public class AdvisorProductVersion {

    private Long id;
    private Long productId;
    private Integer versionNo;
    private String baseInfoJson;
    private String paramsJson;
    private String versionStatus;
    private String statusAtSubmit;
    private LocalDateTime submittedAt;
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

    public Integer getVersionNo() {
        return versionNo;
    }

    public void setVersionNo(Integer versionNo) {
        this.versionNo = versionNo;
    }

    public String getBaseInfoJson() {
        return baseInfoJson;
    }

    public void setBaseInfoJson(String baseInfoJson) {
        this.baseInfoJson = baseInfoJson;
    }

    public String getParamsJson() {
        return paramsJson;
    }

    public void setParamsJson(String paramsJson) {
        this.paramsJson = paramsJson;
    }

    public String getVersionStatus() {
        return versionStatus;
    }

    public void setVersionStatus(String versionStatus) {
        this.versionStatus = versionStatus;
    }

    public String getStatusAtSubmit() {
        return statusAtSubmit;
    }

    public void setStatusAtSubmit(String statusAtSubmit) {
        this.statusAtSubmit = statusAtSubmit;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
