package com.finance.roboadvisor.product.vo;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class PublishedVersionVO {

    private Long versionId;
    private Integer versionNo;
    private String versionStatus;
    private LocalDateTime submittedAt;
    private Map<String, Object> baseInfo;
    private Map<String, Object> params;
    private List<DraftComponentVO> components;

    public Long getVersionId() {
        return versionId;
    }

    public void setVersionId(Long versionId) {
        this.versionId = versionId;
    }

    public Integer getVersionNo() {
        return versionNo;
    }

    public void setVersionNo(Integer versionNo) {
        this.versionNo = versionNo;
    }

    public String getVersionStatus() {
        return versionStatus;
    }

    public void setVersionStatus(String versionStatus) {
        this.versionStatus = versionStatus;
    }

    public LocalDateTime getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(LocalDateTime submittedAt) {
        this.submittedAt = submittedAt;
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
}
