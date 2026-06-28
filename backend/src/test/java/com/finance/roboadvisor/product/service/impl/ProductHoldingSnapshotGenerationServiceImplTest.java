package com.finance.roboadvisor.product.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.entity.AdvisorProductHoldingSnapshot;
import com.finance.roboadvisor.product.entity.AdvisorProductVersion;
import com.finance.roboadvisor.product.mapper.*;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class ProductHoldingSnapshotGenerationServiceImplTest {

    @Mock private ProductMapper productMapper;
    @Mock private ProductVersionMapper productVersionMapper;
    @Mock private ProductComponentMapper productComponentMapper;
    @Mock private ProductHoldingSnapshotMapper productHoldingSnapshotMapper;

    private ProductHoldingSnapshotGenerationServiceImpl snapshotService;

    @BeforeEach
    void setUp() {
        snapshotService = new ProductHoldingSnapshotGenerationServiceImpl(
                productMapper, productVersionMapper, productComponentMapper,
                productHoldingSnapshotMapper, new ObjectMapper()
        );
    }

    private AdvisorProduct createPublishedProduct(Long id, Integer publishedVersionNo) {
        AdvisorProduct p = new AdvisorProduct();
        p.setId(id);
        p.setName("测试产品");
        p.setStatus("PUBLISHED");
        p.setPublishedVersionNo(publishedVersionNo);
        return p;
    }

    private AdvisorProductVersion createVersion(Long id, Long productId, Integer versionNo) {
        AdvisorProductVersion v = new AdvisorProductVersion();
        v.setId(id);
        v.setProductId(productId);
        v.setVersionNo(versionNo);
        return v;
    }

    private DraftComponentVO createComponent(String code, String name, BigDecimal weight) {
        DraftComponentVO c = new DraftComponentVO();
        c.setFundCode(code);
        c.setFundName(name);
        c.setWeight(weight);
        return c;
    }

    @Test
    void testGenerateSnapshotSuccess() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createVersion(10L, productId, 1);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(version);

        DraftComponentVO comp = createComponent("000001", "测试基金", new BigDecimal("0.6"));
        DraftComponentVO comp2 = createComponent("000002", "测试基金B", new BigDecimal("0.4"));
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of(comp, comp2));

        snapshotService.generatePublishedHoldingSnapshot(productId);

        verify(productHoldingSnapshotMapper).upsert(argThat(snapshot -> {
            String json = snapshot.getHoldingJson();
            return snapshot.getProductId() == 1L &&
                    json.contains("000001") &&
                    json.contains("测试基金") &&
                    json.contains("0.6");
        }));
    }

    @Test
    void testGenerateSnapshotSingleComponent() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createVersion(10L, productId, 1);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(version);

        DraftComponentVO comp = createComponent("000001", "单一基金", BigDecimal.ONE);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of(comp));

        snapshotService.generatePublishedHoldingSnapshot(productId);

        verify(productHoldingSnapshotMapper).upsert(any(AdvisorProductHoldingSnapshot.class));
    }

    @Test
    void testGenerateSnapshotProductNotFound() {
        when(productMapper.selectById(999L)).thenReturn(null);
        assertThrows(BusinessException.class,
                () -> snapshotService.generatePublishedHoldingSnapshot(999L));
    }

    @Test
    void testGenerateSnapshotNotPublished() {
        AdvisorProduct product = createPublishedProduct(1L, null);
        product.setStatus("DRAFT");
        when(productMapper.selectById(1L)).thenReturn(product);

        assertThrows(BusinessException.class,
                () -> snapshotService.generatePublishedHoldingSnapshot(1L));
    }

    @Test
    void testGenerateSnapshotVersionNotFound() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> snapshotService.generatePublishedHoldingSnapshot(productId));
    }

    @Test
    void testGenerateSnapshotEmptyComponents() {
        Long productId = 1L;
        AdvisorProduct product = createPublishedProduct(productId, 1);
        when(productMapper.selectById(productId)).thenReturn(product);

        AdvisorProductVersion version = createVersion(10L, productId, 1);
        when(productVersionMapper.selectByProductAndVersionNo(productId, 1)).thenReturn(version);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());

        assertThrows(BusinessException.class,
                () -> snapshotService.generatePublishedHoldingSnapshot(productId));
    }
}
