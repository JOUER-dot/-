package com.finance.roboadvisor.publicapi.vo;

import java.util.List;

public class PublicAdvisorVO {

    private Long id;
    private String name;
    private List<String> fundCompanies;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public List<String> getFundCompanies() { return fundCompanies; }
    public void setFundCompanies(List<String> fundCompanies) { this.fundCompanies = fundCompanies; }
}
