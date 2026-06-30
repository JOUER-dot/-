package com.finance.roboadvisor.publicapi.vo;

import com.fasterxml.jackson.annotation.JsonIgnore;

import java.math.BigDecimal;
import java.util.List;

public class PublicProductListItemVO {

    private Long id;
    private String name;
    private String type;
    private String riskLevel;
    private String strategyCode;
    private List<String> featureTags;
    private BigDecimal latestNav;
    private BigDecimal latestCumReturn;
    private String creatorName;
    private String fundCompaniesText;
    @JsonIgnore
    private String featureTagsText;

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

    public BigDecimal getLatestNav() {
        return latestNav;
    }

    public void setLatestNav(BigDecimal latestNav) {
        this.latestNav = latestNav;
    }

    public BigDecimal getLatestCumReturn() {
        return latestCumReturn;
    }

    public void setLatestCumReturn(BigDecimal latestCumReturn) {
        this.latestCumReturn = latestCumReturn;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public String getFundCompaniesText() {
        return fundCompaniesText;
    }

    public void setFundCompaniesText(String fundCompaniesText) {
        this.fundCompaniesText = fundCompaniesText;
    }

    public List<String> getFundCompanies() {
        if (fundCompaniesText == null || fundCompaniesText.isBlank()) return List.of();
        return java.util.Arrays.stream(fundCompaniesText.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
    }

    public String getFeatureTagsText() {
        return featureTagsText;
    }

    public void setFeatureTagsText(String featureTagsText) {
        this.featureTagsText = featureTagsText;
    }
}
