package com.finance.roboadvisor.aiassistant.dto;

import java.util.List;

public class ReviewAdviceResponse {

    private String decisionHint;
    private String riskLevel;
    private String summary;
    private List<String> concerns;
    private List<String> evidence;
    private List<String> followUpQuestions;

    public ReviewAdviceResponse() {}

    public ReviewAdviceResponse(String decisionHint,
                                String riskLevel,
                                String summary,
                                List<String> concerns,
                                List<String> evidence,
                                List<String> followUpQuestions) {
        this.decisionHint = decisionHint;
        this.riskLevel = riskLevel;
        this.summary = summary;
        this.concerns = concerns;
        this.evidence = evidence;
        this.followUpQuestions = followUpQuestions;
    }

    public String getDecisionHint() { return decisionHint; }
    public void setDecisionHint(String decisionHint) { this.decisionHint = decisionHint; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }

    public List<String> getConcerns() { return concerns; }
    public void setConcerns(List<String> concerns) { this.concerns = concerns; }

    public List<String> getEvidence() { return evidence; }
    public void setEvidence(List<String> evidence) { this.evidence = evidence; }

    public List<String> getFollowUpQuestions() { return followUpQuestions; }
    public void setFollowUpQuestions(List<String> followUpQuestions) { this.followUpQuestions = followUpQuestions; }
}
