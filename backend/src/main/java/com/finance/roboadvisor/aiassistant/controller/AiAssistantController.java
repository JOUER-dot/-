package com.finance.roboadvisor.aiassistant.controller;

import com.finance.roboadvisor.aiassistant.dto.ChatRequest;
import com.finance.roboadvisor.aiassistant.dto.ChatResponse;
import com.finance.roboadvisor.aiassistant.service.AiAssistantService;
import com.finance.roboadvisor.common.api.ApiResult;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
public class AiAssistantController {

    private final AiAssistantService aiAssistantService;

    public AiAssistantController(AiAssistantService aiAssistantService) {
        this.aiAssistantService = aiAssistantService;
    }

    @PostMapping("/chat")
    public ApiResult<ChatResponse> chat(@Valid @RequestBody ChatRequest request) {
        ChatResponse response = aiAssistantService.chat(request);
        return ApiResult.success(response);
    }
}
