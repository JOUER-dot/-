package com.finance.roboadvisor.riskprofile.vo;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class RiskProfileVO {

    private boolean assessed;
    private String riskLevel;
    private String riskLabel;
    private Integer riskScore;
    private Integer capacityScore;
    private Integer attitudeScore;
    private Integer knowledgeScore;
    private Integer liquidityScore;
    private Integer investmentHorizonMonths;
    private BigDecimal maxDrawdownTolerance;
    private String experienceLevel;
    private String investmentGoal;
    private String liquidityNeed;
    private String profileSummary;
    private List<String> profileTags = new ArrayList<>();
    private LocalDateTime assessedAt;
    private LocalDateTime expiresAt;
    private ExposureSummary exposureSummary = new ExposureSummary();
    private List<String> suggestions = new ArrayList<>();

    public boolean isAssessed() { return assessed; }
    public void setAssessed(boolean assessed) { this.assessed = assessed; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getRiskLabel() { return riskLabel; }
    public void setRiskLabel(String riskLabel) { this.riskLabel = riskLabel; }

    public Integer getRiskScore() { return riskScore; }
    public void setRiskScore(Integer riskScore) { this.riskScore = riskScore; }

    public Integer getCapacityScore() { return capacityScore; }
    public void setCapacityScore(Integer capacityScore) { this.capacityScore = capacityScore; }

    public Integer getAttitudeScore() { return attitudeScore; }
    public void setAttitudeScore(Integer attitudeScore) { this.attitudeScore = attitudeScore; }

    public Integer getKnowledgeScore() { return knowledgeScore; }
    public void setKnowledgeScore(Integer knowledgeScore) { this.knowledgeScore = knowledgeScore; }

    public Integer getLiquidityScore() { return liquidityScore; }
    public void setLiquidityScore(Integer liquidityScore) { this.liquidityScore = liquidityScore; }

    public Integer getInvestmentHorizonMonths() { return investmentHorizonMonths; }
    public void setInvestmentHorizonMonths(Integer investmentHorizonMonths) { this.investmentHorizonMonths = investmentHorizonMonths; }

    public BigDecimal getMaxDrawdownTolerance() { return maxDrawdownTolerance; }
    public void setMaxDrawdownTolerance(BigDecimal maxDrawdownTolerance) { this.maxDrawdownTolerance = maxDrawdownTolerance; }

    public String getExperienceLevel() { return experienceLevel; }
    public void setExperienceLevel(String experienceLevel) { this.experienceLevel = experienceLevel; }

    public String getInvestmentGoal() { return investmentGoal; }
    public void setInvestmentGoal(String investmentGoal) { this.investmentGoal = investmentGoal; }

    public String getLiquidityNeed() { return liquidityNeed; }
    public void setLiquidityNeed(String liquidityNeed) { this.liquidityNeed = liquidityNeed; }

    public String getProfileSummary() { return profileSummary; }
    public void setProfileSummary(String profileSummary) { this.profileSummary = profileSummary; }

    public List<String> getProfileTags() { return profileTags; }
    public void setProfileTags(List<String> profileTags) { this.profileTags = profileTags; }

    public LocalDateTime getAssessedAt() { return assessedAt; }
    public void setAssessedAt(LocalDateTime assessedAt) { this.assessedAt = assessedAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public ExposureSummary getExposureSummary() { return exposureSummary; }
    public void setExposureSummary(ExposureSummary exposureSummary) { this.exposureSummary = exposureSummary; }

    public List<String> getSuggestions() { return suggestions; }
    public void setSuggestions(List<String> suggestions) { this.suggestions = suggestions; }

    public static class ExposureSummary {
        private Integer activeSubscriptionCount = 0;
        private String highestProductRiskLevel;
        private Integer mismatchCount = 0;
        private List<ProductExposure> products = new ArrayList<>();

        public Integer getActiveSubscriptionCount() { return activeSubscriptionCount; }
        public void setActiveSubscriptionCount(Integer activeSubscriptionCount) { this.activeSubscriptionCount = activeSubscriptionCount; }

        public String getHighestProductRiskLevel() { return highestProductRiskLevel; }
        public void setHighestProductRiskLevel(String highestProductRiskLevel) { this.highestProductRiskLevel = highestProductRiskLevel; }

        public Integer getMismatchCount() { return mismatchCount; }
        public void setMismatchCount(Integer mismatchCount) { this.mismatchCount = mismatchCount; }

        public List<ProductExposure> getProducts() { return products; }
        public void setProducts(List<ProductExposure> products) { this.products = products; }
    }

    public static class ProductExposure {
        private Long productId;
        private String productName;
        private String riskLevel;
        private String matchResult;

        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }

        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }

        public String getRiskLevel() { return riskLevel; }
        public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

        public String getMatchResult() { return matchResult; }
        public void setMatchResult(String matchResult) { this.matchResult = matchResult; }
    }
}
