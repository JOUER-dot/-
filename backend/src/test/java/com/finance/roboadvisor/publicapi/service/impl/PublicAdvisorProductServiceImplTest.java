package com.finance.roboadvisor.publicapi.service.impl;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.common.exception.BusinessException;
import com.finance.roboadvisor.product.mapper.ProductComponentMapper;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.publicapi.mapper.PublicProductMapper;
import com.finance.roboadvisor.publicapi.service.PublicAdvisorProductService;
import com.finance.roboadvisor.publicapi.vo.PublicAdvisorVO;
import com.finance.roboadvisor.publicapi.vo.PublicHoldingSnapshotVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductListItemVO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class PublicAdvisorProductServiceImplTest {

    @Mock private PublicProductMapper publicProductMapper;
    @Mock private ProductComponentMapper productComponentMapper;

    private PublicAdvisorProductServiceImpl publicService;

    @BeforeEach
    void setUp() {
        publicService = new PublicAdvisorProductServiceImpl(
                publicProductMapper, productComponentMapper, new ObjectMapper()
        );
    }

    @Test
    void testListPublishedProducts() {
        PublicProductListItemVO item = new PublicProductListItemVO();
        item.setId(1L);
        item.setName("公开产品");
        item.setType("STRATEGY");
        item.setFeatureTagsText("稳健,成长");

        when(publicProductMapper.selectPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull(), eq(0), eq(10)))
                .thenReturn(List.of(item));
        when(publicProductMapper.countPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull()))
                .thenReturn(1L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                null, null, null, null, null, 1, 10);

        assertEquals(1, result.getRecords().size());
        assertEquals("公开产品", result.getRecords().get(0).getName());
        assertEquals(2, result.getRecords().get(0).getFeatureTags().size());
    }

    @Test
    void testListPublishedProductsWithFilters() {
        when(publicProductMapper.selectPublishedProducts(eq("keyword"), eq("FOF"), eq("R4"), eq(1L), eq("公司"), eq(0), eq(10)))
                .thenReturn(List.of());
        when(publicProductMapper.countPublishedProducts(eq("keyword"), eq("FOF"), eq("R4"), eq(1L), eq("公司")))
                .thenReturn(0L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                "keyword", "FOF", "R4", 1L, "公司", 1, 10);

        assertTrue(result.getRecords().isEmpty());
    }

    @Test
    void testListPublishedProductsDefaultPagination() {
        when(publicProductMapper.selectPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull(), eq(0), eq(10)))
                .thenReturn(List.of());
        when(publicProductMapper.countPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull()))
                .thenReturn(0L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                null, null, null, null, null, null, null);

        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
    }

    @Test
    void testListAdvisors() {
        PublicAdvisorVO advisor = new PublicAdvisorVO();
        advisor.setId(1L);
        advisor.setName("投顾A");

        when(publicProductMapper.selectAdvisorsWithProducts()).thenReturn(List.of(advisor));

        List<PublicAdvisorVO> result = publicService.listAdvisors();

        assertEquals(1, result.size());
        assertEquals("投顾A", result.get(0).getName());
    }

    @Test
    void testListAdvisorsEmpty() {
        when(publicProductMapper.selectAdvisorsWithProducts()).thenReturn(List.of());

        List<PublicAdvisorVO> result = publicService.listAdvisors();

        assertTrue(result.isEmpty());
    }

    @Test
    void testGetPublishedProductDetail() {
        Long productId = 1L;
        PublicProductDetailVO detail = new PublicProductDetailVO();
        detail.setId(productId);
        detail.setName("产品详情");
        detail.setFeatureTagsText("稳健");
        detail.setBaseInfoJson("{\"manager\":\"张三\"}");
        detail.setParamsJson("{\"rate\":\"0.05\"}");
        detail.setVersionId(10L);

        when(publicProductMapper.selectPublishedProductDetail(productId)).thenReturn(detail);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());
        when(publicProductMapper.selectNavList(productId)).thenReturn(List.of());
        when(publicProductMapper.selectLatestHoldingSnapshot(productId)).thenReturn(null);

        PublicProductDetailVO result = publicService.getPublishedProductDetail(productId);

        assertEquals("产品详情", result.getName());
        assertEquals(1, result.getFeatureTags().size());
        assertNotNull(result.getBaseInfo());
        assertNotNull(result.getParams());
        assertNotNull(result.getHoldingSnapshot());
    }

    @Test
    void testGetPublishedProductDetailWithHoldingSnapshot() {
        Long productId = 1L;
        PublicProductDetailVO detail = new PublicProductDetailVO();
        detail.setId(productId);
        detail.setName("持仓产品");
        detail.setFeatureTagsText("");
        detail.setBaseInfoJson("{}");
        detail.setParamsJson("{}");
        detail.setVersionId(10L);

        when(publicProductMapper.selectPublishedProductDetail(productId)).thenReturn(detail);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());
        when(publicProductMapper.selectNavList(productId)).thenReturn(List.of());

        PublicHoldingSnapshotVO snapshot = new PublicHoldingSnapshotVO();
        snapshot.setSnapshotDate("2026-06-28");
        snapshot.setHoldingJson("{\"components\":[{\"fundCode\":\"000001\",\"weight\":1.0}]}");
        when(publicProductMapper.selectLatestHoldingSnapshot(productId)).thenReturn(snapshot);

        PublicProductDetailVO result = publicService.getPublishedProductDetail(productId);

        assertNotNull(result.getHoldingSnapshotDate());
        assertFalse(result.getHoldingSnapshot().isEmpty());
    }

    @Test
    void testGetPublishedProductDetailNotFound() {
        when(publicProductMapper.selectPublishedProductDetail(999L)).thenReturn(null);

        assertThrows(BusinessException.class,
                () -> publicService.getPublishedProductDetail(999L));
    }

    // ===================== Additional tests for coverage =====================

    @Test
    void testGetPublishedProductDetailWithInvalidJson() {
        Long productId = 1L;
        PublicProductDetailVO detail = new PublicProductDetailVO();
        detail.setId(productId);
        detail.setName("产品");
        detail.setFeatureTagsText(null);
        detail.setBaseInfoJson("invalid json {{{");
        detail.setParamsJson("also invalid");
        detail.setVersionId(10L);

        when(publicProductMapper.selectPublishedProductDetail(productId)).thenReturn(detail);

        assertThrows(BusinessException.class,
                () -> publicService.getPublishedProductDetail(productId));
    }

    @Test
    void testGetPublishedProductDetailWithNullJson() {
        Long productId = 1L;
        PublicProductDetailVO detail = new PublicProductDetailVO();
        detail.setId(productId);
        detail.setName("产品");
        detail.setFeatureTagsText("");
        detail.setBaseInfoJson(null);
        detail.setParamsJson(null);
        detail.setVersionId(10L);

        when(publicProductMapper.selectPublishedProductDetail(productId)).thenReturn(detail);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());
        when(publicProductMapper.selectNavList(productId)).thenReturn(List.of());
        when(publicProductMapper.selectLatestHoldingSnapshot(productId)).thenReturn(null);

        PublicProductDetailVO result = publicService.getPublishedProductDetail(productId);

        assertNotNull(result.getBaseInfo());
        assertTrue(result.getBaseInfo().isEmpty());
        assertNotNull(result.getParams());
        assertTrue(result.getParams().isEmpty());
    }

    @Test
    void testListPublishedProductsWithCustomPagination() {
        when(publicProductMapper.selectPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull(), eq(10), eq(5)))
                .thenReturn(List.of());
        when(publicProductMapper.countPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull()))
                .thenReturn(0L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                null, null, null, null, null, 3, 5);

        assertEquals(3, result.getPageNum());
        assertEquals(5, result.getPageSize());
    }

    @Test
    void testListPublishedProductsWithInvalidPagination() {
        when(publicProductMapper.selectPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull(), eq(0), eq(10)))
                .thenReturn(List.of());
        when(publicProductMapper.countPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull()))
                .thenReturn(0L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                null, null, null, null, null, 0, 0);

        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
    }

    @Test
    void testListPublishedProductsWithNegativePagination() {
        when(publicProductMapper.selectPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull(), eq(0), eq(10)))
                .thenReturn(List.of());
        when(publicProductMapper.countPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull()))
                .thenReturn(0L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                null, null, null, null, null, -1, -5);

        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
    }

    @Test
    void testListPublishedProductsTrimKeyword() {
        when(publicProductMapper.selectPublishedProducts(eq("keyword"), isNull(), isNull(), isNull(), isNull(), eq(0), eq(10)))
                .thenReturn(List.of());
        when(publicProductMapper.countPublishedProducts(eq("keyword"), isNull(), isNull(), isNull(), isNull()))
                .thenReturn(0L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                "  keyword  ", "  ", "  ", null, "  ", 1, 10);

        assertTrue(result.getRecords().isEmpty());
    }

    @Test
    void testListPublishedProductsWithFeatureTagsText() {
        PublicProductListItemVO item1 = new PublicProductListItemVO();
        item1.setId(1L);
        item1.setName("产品A");
        item1.setFeatureTagsText("稳健,成长,高收益");
        PublicProductListItemVO item2 = new PublicProductListItemVO();
        item2.setId(2L);
        item2.setName("产品B");
        item2.setFeatureTagsText(null);

        when(publicProductMapper.selectPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull(), eq(0), eq(10)))
                .thenReturn(List.of(item1, item2));
        when(publicProductMapper.countPublishedProducts(isNull(), isNull(), isNull(), isNull(), isNull()))
                .thenReturn(2L);

        PageResult<PublicProductListItemVO> result = publicService.listPublishedProducts(
                null, null, null, null, null, 1, 10);

        assertEquals(3, result.getRecords().get(0).getFeatureTags().size());
        assertTrue(result.getRecords().get(1).getFeatureTags().isEmpty());
    }

    @Test
    void testGetPublishedProductDetailWithHoldingSnapshotInvalidJson() {
        Long productId = 1L;
        PublicProductDetailVO detail = new PublicProductDetailVO();
        detail.setId(productId);
        detail.setName("产品");
        detail.setFeatureTagsText("");
        detail.setBaseInfoJson("{}");
        detail.setParamsJson("{}");
        detail.setVersionId(10L);

        when(publicProductMapper.selectPublishedProductDetail(productId)).thenReturn(detail);
        when(productComponentMapper.selectByVersionId(10L)).thenReturn(List.of());
        when(publicProductMapper.selectNavList(productId)).thenReturn(List.of());

        PublicHoldingSnapshotVO snapshot = new PublicHoldingSnapshotVO();
        snapshot.setSnapshotDate("2026-06-28");
        snapshot.setHoldingJson("invalid json {{{");
        when(publicProductMapper.selectLatestHoldingSnapshot(productId)).thenReturn(snapshot);

        assertThrows(BusinessException.class,
                () -> publicService.getPublishedProductDetail(productId));
    }
}
