package com.finance.roboadvisor.review.dto;

import jakarta.validation.constraints.NotBlank;

public class ReviewRejectDTO {

    @NotBlank(message = "驳回意见不能为空")
    private String comment;

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }
}
