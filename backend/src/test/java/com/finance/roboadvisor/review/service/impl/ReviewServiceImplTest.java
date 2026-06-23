package com.finance.roboadvisor.review.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.auth.entity.SysUser;
import com.finance.roboadvisor.auth.security.LoginUser;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductFlowLog;
import com.finance.roboadvisor.product.entity.AdvisorProductReview;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductFlowLogMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductReviewMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.review.dto.ReviewRejectDTO;
import com.finance.roboadvisor.review.mapper.ReviewMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ReviewServiceImplTest {

    @Mock
    private ReviewMapper reviewMapper;

    @Mock
    private ProductMapper productMapper;

    @Mock
    private ProductVersionMapper productVersionMapper;

    @Mock
    private ProductComponentMapper productComponentMapper;

    @Mock
    private ProductReviewMapper productReviewMapper;

    @Mock
    private ProductFlowLogMapper productFlowLogMapper;

    private ReviewServiceImpl reviewService;

    @BeforeEach
    void setUp() {
        reviewService = new ReviewServiceImpl(
                reviewMapper,
                productMapper,
                productVersionMapper,
                productComponentMapper,
                productReviewMapper,
                productFlowLogMapper,
                new ObjectMapper()
        );

        SysUser reviewer = new SysUser();
        reviewer.setId(3L);
        reviewer.setUsername("reviewer01");
        reviewer.setPasswordHash("test");
        reviewer.setStatus(1);
        LoginUser loginUser = new LoginUser(reviewer, List.of("REVIEWER"));
        SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(loginUser, null, loginUser.getAuthorities())
        );
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    @Test
    void approveProduct_shouldPublishProductAndWriteReviewRecords() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setStatus("PENDING_REVIEW");
        product.setCurrentVersionNo(2);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(11L);
        version.setProductId(1L);
        version.setVersionNo(2);
        version.setVersionStatus("SUBMITTED");

        when(productMapper.selectById(1L)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(1L)).thenReturn(version);

        reviewService.approveProduct(1L);

        verify(productMapper).updateApprovedReviewOutcome(1L, "PUBLISHED", 2);
        verify(productVersionMapper).updateVersionStatus(11L, "APPROVED");

        verify(productReviewMapper).insert(any(AdvisorProductReview.class));
        verify(productFlowLogMapper).insert(any(AdvisorProductFlowLog.class));
    }

    @Test
    void rejectProduct_shouldMarkRejectedAndPersistRejectComment() {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(2L);
        product.setStatus("PENDING_REVIEW");
        product.setCurrentVersionNo(3);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(21L);
        version.setProductId(2L);
        version.setVersionNo(3);
        version.setVersionStatus("SUBMITTED");

        ReviewRejectDTO dto = new ReviewRejectDTO();
        dto.setComment("单一行业集中度过高，请调整权重");

        when(productMapper.selectById(2L)).thenReturn(product);
        when(productVersionMapper.selectLatestSubmittedByProductId(2L)).thenReturn(version);

        reviewService.rejectProduct(2L, dto);

        verify(productMapper).updateRejectedReviewOutcome(2L, "REJECTED", "单一行业集中度过高，请调整权重");
        verify(productVersionMapper).updateVersionStatus(21L, "REJECTED");

        verify(productReviewMapper).insert(any(AdvisorProductReview.class));
        verify(productFlowLogMapper).insert(any(AdvisorProductFlowLog.class));
    }
}
