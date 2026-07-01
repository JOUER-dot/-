package com.finance.roboadvisor.riskprofile.entity;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class UserRiskAssessment {

    private Long id;
    private Long userId;
    private String assessmentNo;
    private String questionnaireVersion;
    private String riskLevel;
    private Integer riskScore;
    private Integer capacityScore;
    private Integer attitudeScore;
    private Integer knowledgeScore;
    private Integer liquidityScore;
    private Integer investmentHorizonMonths;
    private BigDecimal maxDrawdownTolerance;
    private String resultSummary;
    private String rawResultJson;
    private String source;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getAssessmentNo() { return assessmentNo; }
    public void setAssessmentNo(String assessmentNo) { this.assessmentNo = assessmentNo; }

    public String getQuestionnaireVersion() { return questionnaireVersion; }
    public void setQuestionnaireVersion(String questionnaireVersion) { this.questionnaireVersion = questionnaireVersion; }

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

    public String getResultSummary() { return resultSummary; }
    public void setResultSummary(String resultSummary) { this.resultSummary = resultSummary; }

    public String getRawResultJson() { return rawResultJson; }
    public void setRawResultJson(String rawResultJson) { this.rawResultJson = rawResultJson; }

    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
