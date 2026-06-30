package com.finance.roboadvisor.aiassistant.dto;

import jakarta.validation.constraints.NotBlank;

import java.util.List;
import java.util.Map;

public class ChatRequest {

    @NotBlank(message = "问题不能为空")
    private String question;

    private Long productId;

    private String riskLevel;

    /** 对话历史：[{role: "user"/"assistant", content: "..."}] */
    private List<Map<String, String>> history;

    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }

    public List<Map<String, String>> getHistory() { return history; }
    public void setHistory(List<Map<String, String>> history) { this.history = history; }
}
