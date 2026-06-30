package com.finance.roboadvisor.publicapi.vo;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.finance.roboadvisor.product.vo.DraftComponentVO;

import java.util.List;
import java.util.Map;

public class PublicProductDetailVO {

    private Long id;
    private String name;
    private String type;
    private String riskLevel;
    private String strategyCode;
    private Long versionId;
    private Integer versionNo;
    private List<String> featureTags;
    private Map<String, Object> baseInfo;
    private Map<String, Object> params;
    private List<DraftComponentVO> components;
    private List<PublicProductNavPointVO> navList;
    private Map<String, Object> holdingSnapshot;
    private String holdingSnapshotDate;
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

    public List<PublicProductNavPointVO> getNavList() {
        return navList;
    }

    public void setNavList(List<PublicProductNavPointVO> navList) {
        this.navList = navList;
    }

    public Map<String, Object> getHoldingSnapshot() {
        return holdingSnapshot;
    }

    public void setHoldingSnapshot(Map<String, Object> holdingSnapshot) {
        this.holdingSnapshot = holdingSnapshot;
    }

    public String getHoldingSnapshotDate() {
        return holdingSnapshotDate;
    }

    public void setHoldingSnapshotDate(String holdingSnapshotDate) {
        this.holdingSnapshotDate = holdingSnapshotDate;
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
