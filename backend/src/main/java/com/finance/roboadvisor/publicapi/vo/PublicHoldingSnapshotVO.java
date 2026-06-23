package com.finance.roboadvisor.publicapi.vo;

public class PublicHoldingSnapshotVO {

    private String snapshotDate;
    private String holdingJson;

    public String getSnapshotDate() {
        return snapshotDate;
    }

    public void setSnapshotDate(String snapshotDate) {
        this.snapshotDate = snapshotDate;
    }

    public String getHoldingJson() {
        return holdingJson;
    }

    public void setHoldingJson(String holdingJson) {
        this.holdingJson = holdingJson;
    }
}
