package com.finance.roboadvisor.aiassistant.controller;

import com.finance.roboadvisor.aiassistant.dto.ChatRequest;
import com.finance.roboadvisor.aiassistant.dto.ChatResponse;
import com.finance.roboadvisor.aiassistant.dto.ProductAnalysisResponse;
import com.finance.roboadvisor.aiassistant.dto.ReviewAdviceResponse;
import com.finance.roboadvisor.aiassistant.service.AiAssistantService;
import com.finance.roboadvisor.common.api.ApiResult;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
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

    @PostMapping(value = "/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter chatStream(@Valid @RequestBody ChatRequest request) {
        return aiAssistantService.chatStream(request);
    }

    @PostMapping("/products/{productId}/analysis")
    public ApiResult<ProductAnalysisResponse> analyzeProduct(@PathVariable("productId") Long productId) {
        return ApiResult.success(aiAssistantService.analyzeProduct(productId));
    }

    @PreAuthorize("hasRole('REVIEWER')")
    @PostMapping("/review/products/{productId}/advice")
    public ApiResult<ReviewAdviceResponse> reviewAdvice(@PathVariable("productId") Long productId) {
        return ApiResult.success(aiAssistantService.generateReviewAdvice(productId));
    }
}
