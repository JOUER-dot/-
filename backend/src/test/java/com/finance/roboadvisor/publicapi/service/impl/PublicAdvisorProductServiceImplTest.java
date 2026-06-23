package com.finance.roboadvisor.publicapi.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.publicapi.vo.PublicHoldingSnapshotVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductNavPointVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PublicAdvisorProductServiceImplTest {

    @Mock
    private PublicProductMapper publicProductMapper;

    @Mock
    private ProductComponentMapper productComponentMapper;

    @Test
    void getPublishedProductDetail_shouldAssemblePublishedVersionData() {
        PublicProductDetailVO detailRow = new PublicProductDetailVO();
        detailRow.setId(1L);
        detailRow.setName("稳健FOF组合A");
        detailRow.setVersionId(11L);
        detailRow.setFeatureTagsText("稳健,低波动");
        detailRow.setBaseInfoJson("{\"intro\":\"适合稳健型投资者\"}");
        detailRow.setParamsJson("{\"rebalanceCycleDays\":30}");

        DraftComponentVO component = new DraftComponentVO();
        component.setFundCode("110022");
        component.setFundName("易方达消费行业股票");
        component.setWeight(new BigDecimal("0.3000"));

        PublicProductNavPointVO navPoint = new PublicProductNavPointVO();
        navPoint.setNavDate("2026-06-20");
        navPoint.setNav(new BigDecimal("1.2356"));

        PublicHoldingSnapshotVO holdingSnapshot = new PublicHoldingSnapshotVO();
        holdingSnapshot.setSnapshotDate("2026-06-20");
        holdingSnapshot.setHoldingJson("{\"topHoldings\":[{\"name\":\"易方达消费行业股票\",\"weight\":0.30}]}");

        when(publicProductMapper.selectPublishedProductDetail(1L)).thenReturn(detailRow);
        when(productComponentMapper.selectByVersionId(11L)).thenReturn(List.of(component));
        when(publicProductMapper.selectNavList(1L)).thenReturn(List.of(navPoint));
        when(publicProductMapper.selectLatestHoldingSnapshot(1L)).thenReturn(holdingSnapshot);

        PublicAdvisorProductServiceImpl service = new PublicAdvisorProductServiceImpl(
                publicProductMapper,
                productComponentMapper,
                new ObjectMapper()
        );

        PublicProductDetailVO result = service.getPublishedProductDetail(1L);

        assertThat(result.getFeatureTags()).containsExactly("稳健", "低波动");
        assertThat(result.getComponents()).hasSize(1);
        assertThat(result.getNavList()).hasSize(1);
        assertThat(result.getBaseInfo()).isEqualTo(Map.of("intro", "适合稳健型投资者"));
        assertThat(result.getHoldingSnapshot()).isNotEmpty();
    }
}
