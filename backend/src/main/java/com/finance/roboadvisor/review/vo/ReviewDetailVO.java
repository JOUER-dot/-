package com.finance.roboadvisor.review.vo;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.product.vo.ReviewRecordVO;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class ReviewDetailVO {

    private Long id;
    private String name;
    private String type;
    private String riskLevel;
    private String strategyCode;
    private String status;
    private String creatorName;
    private Long versionId;
    private Integer versionNo;
    private String versionStatus;
    private LocalDateTime submittedAt;
    private List<String> featureTags;
    private Map<String, Object> baseInfo;
    private Map<String, Object> params;
    private List<DraftComponentVO> components;
    private List<ReviewRecordVO> reviewSummary;
    private ReviewVersionSummaryVO baseVersionSummary;
    private ReviewVersionSummaryVO currentVersionSummary;
    private List<ReviewDiffFieldVO> fieldDiffs;
    private List<ReviewDiffComponentVO> componentDiffs;
    private String changeType;
    private String versionNote;
    @JsonIgnore
    private String featureTagsText;
    @JsonIgnore
    private String baseInfoJson;
    @JsonIgnore
    private String paramsJson;

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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

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

    public List<String> getFeatureTags() {
        return featureTags;
    }

    public void setFeatureTags(List<String> featureTags) {
        this.featureTags = featureTags;
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

    public List<ReviewRecordVO> getReviewSummary() {
        return reviewSummary;
    }

    public void setReviewSummary(List<ReviewRecordVO> reviewSummary) {
        this.reviewSummary = reviewSummary;
    }

    public ReviewVersionSummaryVO getBaseVersionSummary() {
        return baseVersionSummary;
    }

    public void setBaseVersionSummary(ReviewVersionSummaryVO baseVersionSummary) {
        this.baseVersionSummary = baseVersionSummary;
    }

    public ReviewVersionSummaryVO getCurrentVersionSummary() {
        return currentVersionSummary;
    }

    public void setCurrentVersionSummary(ReviewVersionSummaryVO currentVersionSummary) {
        this.currentVersionSummary = currentVersionSummary;
    }

    public List<ReviewDiffFieldVO> getFieldDiffs() {
        return fieldDiffs;
    }

    public void setFieldDiffs(List<ReviewDiffFieldVO> fieldDiffs) {
        this.fieldDiffs = fieldDiffs;
    }

    public List<ReviewDiffComponentVO> getComponentDiffs() {
        return componentDiffs;
    }

    public void setComponentDiffs(List<ReviewDiffComponentVO> componentDiffs) {
        this.componentDiffs = componentDiffs;
    }

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getVersionNote() {
        return versionNote;
    }

    public void setVersionNote(String versionNote) {
        this.versionNote = versionNote;
    }

    public String getFeatureTagsText() {
        return featureTagsText;
    }

    public void setFeatureTagsText(String featureTagsText) {
        this.featureTagsText = featureTagsText;
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
}
