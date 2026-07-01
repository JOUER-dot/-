package com.finance.roboadvisor.riskprofile.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class UserRiskProfile {

    private Long id;
    private Long userId;
    private String riskLevel;
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
    private String incomeRange;
    private String assetRange;
    private String profileTags;
    private String profileSummary;
    private String source;
    private String status;
    private LocalDateTime assessedAt;
    private LocalDateTime expiresAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

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

    public String getIncomeRange() { return incomeRange; }
    public void setIncomeRange(String incomeRange) { this.incomeRange = incomeRange; }

    public String getAssetRange() { return assetRange; }
    public void setAssetRange(String assetRange) { this.assetRange = assetRange; }

    public String getProfileTags() { return profileTags; }
    public void setProfileTags(String profileTags) { this.profileTags = profileTags; }

    public String getProfileSummary() { return profileSummary; }
    public void setProfileSummary(String profileSummary) { this.profileSummary = profileSummary; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getAssessedAt() { return assessedAt; }
    public void setAssessedAt(LocalDateTime assessedAt) { this.assessedAt = assessedAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
