package com.finance.roboadvisor.product.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductHoldingSnapshot;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.mapper.ProductHoldingSnapshotMapper;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.mapper.ProductVersionMapper;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProductHoldingSnapshotGenerationServiceImplTest {

    @Mock
    private ProductMapper productMapper;

    @Mock
    private ProductVersionMapper productVersionMapper;

    @Mock
    private ProductComponentMapper productComponentMapper;

    @Mock
    private ProductHoldingSnapshotMapper productHoldingSnapshotMapper;

    @Test
    void generatePublishedHoldingSnapshot_shouldPersistPublishedComponentsAsJson() throws Exception {
        AdvisorProduct product = new AdvisorProduct();
        product.setId(1L);
        product.setStatus("PUBLISHED");
        product.setPublishedVersionNo(2);

        AdvisorProductVersion version = new AdvisorProductVersion();
        version.setId(11L);
        version.setProductId(1L);
        version.setVersionNo(2);

        DraftComponentVO componentA = new DraftComponentVO();
        componentA.setFundCode("110022");
        componentA.setFundName("易方达消费行业股票");
        componentA.setWeight(new BigDecimal("0.6000"));

        DraftComponentVO componentB = new DraftComponentVO();
        componentB.setFundCode("003095");
        componentB.setFundName("中欧医疗健康混合");
        componentB.setWeight(new BigDecimal("0.4000"));

        when(productMapper.selectById(1L)).thenReturn(product);
        when(productVersionMapper.selectByProductAndVersionNo(1L, 2)).thenReturn(version);
        when(productComponentMapper.selectByVersionId(11L)).thenReturn(java.util.List.of(componentA, componentB));

        ProductHoldingSnapshotGenerationServiceImpl service = new ProductHoldingSnapshotGenerationServiceImpl(
                productMapper,
                productVersionMapper,
                productComponentMapper,
                productHoldingSnapshotMapper,
                new ObjectMapper()
        );

        service.generatePublishedHoldingSnapshot(1L);

        ArgumentCaptor<AdvisorProductHoldingSnapshot> captor = ArgumentCaptor.forClass(AdvisorProductHoldingSnapshot.class);
        verify(productHoldingSnapshotMapper).upsert(captor.capture());
        AdvisorProductHoldingSnapshot snapshot = captor.getValue();

        assertThat(snapshot.getProductId()).isEqualTo(1L);
        JsonNode root = new ObjectMapper().readTree(snapshot.getHoldingJson());
        assertThat(root.has("components")).isTrue();
        assertThat(root.get("components").size()).isEqualTo(2);
        assertThat(root.get("components").get(0).get("fundCode").asText()).isEqualTo("110022");
        assertThat(root.get("components").get(0).get("weight").decimalValue()).isEqualByComparingTo("0.6000");
    }
}
