package com.finance.roboadvisor.review.vo;

public class ReviewDiffFieldVO {

    private String fieldKey;
    private String fieldLabel;
    private Object beforeValue;
    private Object afterValue;
    private boolean majorSignal;

    public String getFieldKey() {
        return fieldKey;
    }

    public void setFieldKey(String fieldKey) {
        this.fieldKey = fieldKey;
    }

    public String getFieldLabel() {
        return fieldLabel;
    }

    public void setFieldLabel(String fieldLabel) {
        this.fieldLabel = fieldLabel;
    }

    public Object getBeforeValue() {
        return beforeValue;
    }

    public void setBeforeValue(Object beforeValue) {
        this.beforeValue = beforeValue;
    }

    public Object getAfterValue() {
        return afterValue;
    }

    public void setAfterValue(Object afterValue) {
        this.afterValue = afterValue;
    }

    public boolean isMajorSignal() {
        return majorSignal;
    }

    public void setMajorSignal(boolean majorSignal) {
        this.majorSignal = majorSignal;
    }
}
