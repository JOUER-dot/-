package com.finance.roboadvisor.fund.service.impl;

import com.finance.roboadvisor.common.api.PageResult;
import com.finance.roboadvisor.fund.mapper.FundMapper;
import com.finance.roboadvisor.fund.vo.FundOptionVO;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
public class FundServiceImplTest {

    @Mock private FundMapper fundMapper;

    @InjectMocks
    private FundServiceImpl fundService;

    private FundOptionVO createFundOption(Long id, String code, String name, String type) {
        FundOptionVO vo = new FundOptionVO();
        vo.setId(id);
        vo.setFundCode(code);
        vo.setFundName(name);
        vo.setFundType(type);
        vo.setRiskLevel("R3");
        vo.setCompanyName("测试基金公司");
        return vo;
    }

    @Test
    void testSearchFundsWithKeyword() {
        List<FundOptionVO> funds = List.of(
                createFundOption(1L, "000001", "测试基金A", "EQUITY"),
                createFundOption(2L, "000002", "测试基金B", "BOND")
        );
        when(fundMapper.selectEnabledFunds(eq("测试"), isNull(), eq(0), eq(10))).thenReturn(funds);
        when(fundMapper.countEnabledFunds(eq("测试"), isNull())).thenReturn(2L);

        PageResult<FundOptionVO> result = fundService.searchFunds("测试", null, 1, 10);

        assertEquals(2, result.getRecords().size());
        assertEquals(2L, result.getTotal());
        assertEquals("测试基金A", result.getRecords().get(0).getFundName());
    }

    @Test
    void testSearchFundsWithType() {
        List<FundOptionVO> funds = List.of(
                createFundOption(1L, "000001", "股票基金", "EQUITY")
        );
        when(fundMapper.selectEnabledFunds(isNull(), eq("EQUITY"), eq(0), eq(10))).thenReturn(funds);
        when(fundMapper.countEnabledFunds(isNull(), eq("EQUITY"))).thenReturn(1L);

        PageResult<FundOptionVO> result = fundService.searchFunds(null, "EQUITY", 1, 10);

        assertEquals(1, result.getRecords().size());
        assertEquals("EQUITY", result.getRecords().get(0).getFundType());
    }

    @Test
    void testSearchFundsDefaultPagination() {
        when(fundMapper.selectEnabledFunds(isNull(), isNull(), eq(0), eq(10))).thenReturn(List.of());
        when(fundMapper.countEnabledFunds(isNull(), isNull())).thenReturn(0L);

        PageResult<FundOptionVO> result = fundService.searchFunds(null, null, null, null);

        assertEquals(0, result.getRecords().size());
        assertEquals(0L, result.getTotal());
        assertEquals(1, result.getPageNum());
        assertEquals(10, result.getPageSize());
    }

    @Test
    void testSearchFundsCustomPagination() {
        when(fundMapper.selectEnabledFunds(isNull(), isNull(), eq(20), eq(5))).thenReturn(List.of());
        when(fundMapper.countEnabledFunds(isNull(), isNull())).thenReturn(0L);

        PageResult<FundOptionVO> result = fundService.searchFunds(null, null, 5, 5);

        assertEquals(5, result.getPageNum());
        assertEquals(5, result.getPageSize());
    }

    @Test
    void testSearchFundsEmptyResult() {
        when(fundMapper.selectEnabledFunds(anyString(), any(), eq(0), eq(10))).thenReturn(List.of());
        when(fundMapper.countEnabledFunds(anyString(), any())).thenReturn(0L);

        PageResult<FundOptionVO> result = fundService.searchFunds("不存在", null, 1, 10);

        assertTrue(result.getRecords().isEmpty());
        assertEquals(0L, result.getTotal());
    }

    @Test
    void testSearchFundsTrimKeyword() {
        when(fundMapper.selectEnabledFunds(eq("trimmed"), isNull(), eq(0), eq(10))).thenReturn(List.of());
        when(fundMapper.countEnabledFunds(eq("trimmed"), isNull())).thenReturn(0L);

        fundService.searchFunds("  trimmed  ", null, 1, 10);

        // Verify the keyword is trimmed
        verify(fundMapper).selectEnabledFunds(eq("trimmed"), isNull(), eq(0), eq(10));
    }
}
