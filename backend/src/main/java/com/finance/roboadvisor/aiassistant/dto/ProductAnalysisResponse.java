package com.finance.roboadvisor.aiassistant.dto;

import java.util.List;

public class ProductAnalysisResponse {

    private String overview;
    private String suitability;
    private String allocationSummary;
    private String riskBadge;
    private List<String> highlights;
    private List<String> risks;
    private List<String> checklist;

    public ProductAnalysisResponse() {}

    public ProductAnalysisResponse(String overview,
                                   String suitability,
                                   String allocationSummary,
                                   String riskBadge,
                                   List<String> highlights,
                                   List<String> risks,
                                   List<String> checklist) {
        this.overview = overview;
        this.suitability = suitability;
        this.allocationSummary = allocationSummary;
        this.riskBadge = riskBadge;
        this.highlights = highlights;
        this.risks = risks;
        this.checklist = checklist;
    }

    public String getOverview() { return overview; }
    public void setOverview(String overview) { this.overview = overview; }

    public String getSuitability() { return suitability; }
    public void setSuitability(String suitability) { this.suitability = suitability; }

    public String getAllocationSummary() { return allocationSummary; }
    public void setAllocationSummary(String allocationSummary) { this.allocationSummary = allocationSummary; }

    public String getRiskBadge() { return riskBadge; }
    public void setRiskBadge(String riskBadge) { this.riskBadge = riskBadge; }

    public List<String> getHighlights() { return highlights; }
    public void setHighlights(List<String> highlights) { this.highlights = highlights; }

    public List<String> getRisks() { return risks; }
    public void setRisks(List<String> risks) { this.risks = risks; }

    public List<String> getChecklist() { return checklist; }
    public void setChecklist(List<String> checklist) { this.checklist = checklist; }
}
