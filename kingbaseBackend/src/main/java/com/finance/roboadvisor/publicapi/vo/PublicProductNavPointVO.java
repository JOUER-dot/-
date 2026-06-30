package com.finance.roboadvisor.publicapi.vo;

import java.math.BigDecimal;

public class PublicProductNavPointVO {

    private String navDate;
    private BigDecimal nav;
    private BigDecimal cumReturn;

    public String getNavDate() {
        return navDate;
    }

    public void setNavDate(String navDate) {
        this.navDate = navDate;
    }

    public BigDecimal getNav() {
        return nav;
    }

    public void setNav(BigDecimal nav) {
        this.nav = nav;
    }

    public BigDecimal getCumReturn() {
        return cumReturn;
    }

    public void setCumReturn(BigDecimal cumReturn) {
        this.cumReturn = cumReturn;
    }
}
