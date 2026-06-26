package com.finance.roboadvisor.product.dto;

public class ProductSubmitDTO {

    private String changeType;

    private String versionNote;

    public String getChangeType() {
        return changeType;
    }

    public void setChangeType(String changeType) {
        this.changeType = changeType;
    }

    public String getVersionNote() {
        return versionNote;
    }

    public void setVersionNote(String versionNote) {
        this.versionNote = versionNote;
    }
}
