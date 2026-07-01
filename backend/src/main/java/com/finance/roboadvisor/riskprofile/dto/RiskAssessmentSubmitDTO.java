package com.finance.roboadvisor.riskprofile.dto;

import java.math.BigDecimal;
import java.util.List;

public class RiskAssessmentSubmitDTO {

    private String incomeRange;
    private String assetRange;
    private String investmentGoal;
    private String experienceLevel;
    private String liquidityNeed;
    private Integer investmentHorizonMonths;
    private BigDecimal maxDrawdownTolerance;
    private String lossReaction;
    private String productExperience;
    private List<AnswerItem> answers;

    public String getIncomeRange() { return incomeRange; }
    public void setIncomeRange(String incomeRange) { this.incomeRange = incomeRange; }

    public String getAssetRange() { return assetRange; }
    public void setAssetRange(String assetRange) { this.assetRange = assetRange; }

    public String getInvestmentGoal() { return investmentGoal; }
    public void setInvestmentGoal(String investmentGoal) { this.investmentGoal = investmentGoal; }

    public String getExperienceLevel() { return experienceLevel; }
    public void setExperienceLevel(String experienceLevel) { this.experienceLevel = experienceLevel; }

    public String getLiquidityNeed() { return liquidityNeed; }
    public void setLiquidityNeed(String liquidityNeed) { this.liquidityNeed = liquidityNeed; }

    public Integer getInvestmentHorizonMonths() { return investmentHorizonMonths; }
    public void setInvestmentHorizonMonths(Integer investmentHorizonMonths) { this.investmentHorizonMonths = investmentHorizonMonths; }

    public BigDecimal getMaxDrawdownTolerance() { return maxDrawdownTolerance; }
    public void setMaxDrawdownTolerance(BigDecimal maxDrawdownTolerance) { this.maxDrawdownTolerance = maxDrawdownTolerance; }

    public String getLossReaction() { return lossReaction; }
    public void setLossReaction(String lossReaction) { this.lossReaction = lossReaction; }

    public String getProductExperience() { return productExperience; }
    public void setProductExperience(String productExperience) { this.productExperience = productExperience; }

    public List<AnswerItem> getAnswers() { return answers; }
    public void setAnswers(List<AnswerItem> answers) { this.answers = answers; }

    public static class AnswerItem {
        private String questionCode;
        private String questionTitle;
        private String optionCode;
        private String optionText;
        private String answerValue;
        private Integer score;
        private String dimension;

        public String getQuestionCode() { return questionCode; }
        public void setQuestionCode(String questionCode) { this.questionCode = questionCode; }

        public String getQuestionTitle() { return questionTitle; }
        public void setQuestionTitle(String questionTitle) { this.questionTitle = questionTitle; }

        public String getOptionCode() { return optionCode; }
        public void setOptionCode(String optionCode) { this.optionCode = optionCode; }

        public String getOptionText() { return optionText; }
        public void setOptionText(String optionText) { this.optionText = optionText; }

        public String getAnswerValue() { return answerValue; }
        public void setAnswerValue(String answerValue) { this.answerValue = answerValue; }

        public Integer getScore() { return score; }
        public void setScore(Integer score) { this.score = score; }

        public String getDimension() { return dimension; }
        public void setDimension(String dimension) { this.dimension = dimension; }
    }
}
