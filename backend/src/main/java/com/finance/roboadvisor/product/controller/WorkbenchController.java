package com.finance.roboadvisor.product.controller;

import com.finance.roboadvisor.common.api.ApiResult;
import com.finance.roboadvisor.product.service.WorkbenchService;
import com.finance.roboadvisor.product.vo.WorkbenchVO;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/workbench")
public class WorkbenchController {

    private final WorkbenchService workbenchService;

    public WorkbenchController(WorkbenchService workbenchService) {
        this.workbenchService = workbenchService;
    }

    @GetMapping
    public ApiResult<WorkbenchVO> getWorkbench() {
        return ApiResult.success(workbenchService.getAdvisorWorkbench());
    }
}
