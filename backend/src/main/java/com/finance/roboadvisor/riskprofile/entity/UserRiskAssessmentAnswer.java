package com.finance.roboadvisor.riskprofile.entity;

import java.time.LocalDateTime;

public class UserRiskAssessmentAnswer {

    private Long id;
    private Long assessmentId;
    private String questionCode;
    private String questionTitle;
    private String optionCode;
    private String optionText;
    private String answerValue;
    private Integer score;
    private String dimension;
    private LocalDateTime createdAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getAssessmentId() { return assessmentId; }
    public void setAssessmentId(Long assessmentId) { this.assessmentId = assessmentId; }

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

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
