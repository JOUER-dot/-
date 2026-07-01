package com.finance.roboadvisor.aiassistant.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.finance.roboadvisor.aiassistant.dto.ChatRequest;
import com.finance.roboadvisor.aiassistant.dto.ChatResponse;
import com.finance.roboadvisor.aiassistant.dto.ProductAnalysisResponse;
import com.finance.roboadvisor.aiassistant.dto.ReviewAdviceResponse;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import com.finance.roboadvisor.product.vo.DraftComponentVO;
import com.finance.roboadvisor.publicapi.service.PublicAdvisorProductService;
import com.finance.roboadvisor.publicapi.vo.PublicProductDetailVO;
import com.finance.roboadvisor.publicapi.vo.PublicProductNavPointVO;
import com.finance.roboadvisor.review.service.ReviewService;
import com.finance.roboadvisor.review.vo.ReviewDetailVO;
import com.finance.roboadvisor.review.vo.ReviewDiffComponentVO;
import com.finance.roboadvisor.review.vo.ReviewDiffFieldVO;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Stream;

@Service
public class AiAssistantService {

    private static final Logger log = LoggerFactory.getLogger(AiAssistantService.class);

    private final ProductMapper productMapper;
    private final PublicAdvisorProductService publicAdvisorProductService;
    private final ReviewService reviewService;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    @Value("${ai.deepseek.api-key:}")
    private String apiKey;

    @Value("${ai.deepseek.api-url:https://api.deepseek.com/chat/completions}")
    private String apiUrl;

    @Value("${ai.deepseek.model:deepseek-v4-flash}")
    private String model;

    @Value("${ai.deepseek.temperature:0.2}")
    private double temperature;

    @Value("${ai.deepseek.max-tokens:800}")
    private int maxTokens;

    public AiAssistantService(ProductMapper productMapper,
                              PublicAdvisorProductService publicAdvisorProductService,
                              ReviewService reviewService,
                              ObjectMapper objectMapper) {
        this.productMapper = productMapper;
        this.publicAdvisorProductService = publicAdvisorProductService;
        this.reviewService = reviewService;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    @PostConstruct
    public void logDeepSeekConfig() {
        String resolvedApiKey = resolveApiKey();
        log.info("DeepSeek config loaded. enabled={}, apiUrl={}, model={}, key={}",
                !resolvedApiKey.isBlank(),
                apiUrl,
                model,
                maskApiKey(resolvedApiKey));
    }

    public ChatResponse chat(ChatRequest request) {
        String systemPrompt = buildSystemPrompt(request, true);
        return callDeepSeek(systemPrompt, request);
    }

    public SseEmitter chatStream(ChatRequest request) {
        SseEmitter emitter = new SseEmitter(120_000L);
        CompletableFuture.runAsync(() -> {
            try {
                streamChat(request, emitter);
            } catch (Exception e) {
                log.error("Failed to stream AI response", e);
                sendSseEvent(emitter, "error", Map.of("message", "抱歉，AI 助手暂时无法完成流式回复，请稍后再试。"));
                emitter.complete();
            }
        });
        return emitter;
    }

    public ProductAnalysisResponse analyzeProduct(Long productId) {
        PublicProductDetailVO detail = publicAdvisorProductService.getPublishedProductDetail(productId);
        String context = buildPublishedProductContext(detail);
        String prompt = """
                你是金融投顾产品分析官。请基于给定产品资料生成用户可读的结构化分析报告。
                要求：只输出 JSON，不要 Markdown；不要承诺收益；必须提醒风险。
                JSON字段：
                {
                  "overview": "一句话说明产品定位，80字以内",
                  "suitability": "适合关注的人群，80字以内",
                  "allocationSummary": "资产成份/权重特点，80字以内",
                  "riskBadge": "低风险/中低风险/中风险/中高风险/高风险 之一",
                  "highlights": ["亮点1", "亮点2", "亮点3"],
                  "risks": ["风险点1", "风险点2", "风险点3"],
                  "checklist": ["订阅前检查项1", "订阅前检查项2", "订阅前检查项3"]
                }
                """;
        JsonNode root = callJsonCompletion(prompt, context);
        if (root == null) {
            return fallbackProductAnalysis(detail);
        }
        return new ProductAnalysisResponse(
                text(root, "overview", fallbackProductAnalysis(detail).getOverview()),
                text(root, "suitability", fallbackProductAnalysis(detail).getSuitability()),
                text(root, "allocationSummary", fallbackProductAnalysis(detail).getAllocationSummary()),
                text(root, "riskBadge", fallbackProductAnalysis(detail).getRiskBadge()),
                list(root, "highlights", fallbackProductAnalysis(detail).getHighlights()),
                list(root, "risks", fallbackProductAnalysis(detail).getRisks()),
                list(root, "checklist", fallbackProductAnalysis(detail).getChecklist())
        );
    }

    public ReviewAdviceResponse generateReviewAdvice(Long productId) {
        ReviewDetailVO detail = reviewService.getPendingProductDetail(productId);
        String context = buildReviewContext(detail);
        String prompt = """
                你是基金投顾产品审核辅助官。请基于待审产品资料、版本差异和成份权重生成审核辅助建议。
                要求：只输出 JSON，不要 Markdown；不要替代人工审核，只给关注点；避免承诺收益。
                JSON字段：
                {
                  "decisionHint": "建议通过/建议重点复核/建议驳回补充材料 之一",
                  "riskLevel": "低/中/高",
                  "summary": "审核摘要，100字以内",
                  "concerns": ["关注点1", "关注点2", "关注点3"],
                  "evidence": ["证据1", "证据2", "证据3"],
                  "followUpQuestions": ["给投顾的复核问题1", "给投顾的复核问题2", "给投顾的复核问题3"]
                }
                """;
        JsonNode root = callJsonCompletion(prompt, context);
        if (root == null) {
            return fallbackReviewAdvice(detail);
        }
        ReviewAdviceResponse fallback = fallbackReviewAdvice(detail);
        return new ReviewAdviceResponse(
                text(root, "decisionHint", fallback.getDecisionHint()),
                text(root, "riskLevel", fallback.getRiskLevel()),
                text(root, "summary", fallback.getSummary()),
                list(root, "concerns", fallback.getConcerns()),
                list(root, "evidence", fallback.getEvidence()),
                list(root, "followUpQuestions", fallback.getFollowUpQuestions())
        );
    }

    private String buildSystemPrompt(ChatRequest request, boolean jsonResponse) {
        StringBuilder sb = new StringBuilder();
        sb.append("你是「智能投顾平台」的AI投资助手，你的名字叫「小顾」。");
        sb.append("你的任务是帮助用户了解基金投顾产品、解答投资疑问。");
        sb.append("请用通俗易懂的中文回答，语气亲切友好。");
        sb.append("\n\n");

        appendProductContext(sb, request);

        // 用户风险等级
        if (request.getRiskLevel() != null) {
            sb.append("用户的风险偏好等级为：").append(request.getRiskLevel()).append("（R1=保守，R5=进取）\n");
        }

        sb.append("\n注意：");
        sb.append("1. 回答请用纯文本格式，不要使用 Markdown、不要加粗、不要列表、不要代码块等任何格式符号；");
        sb.append("2. 不提供具体的投资建议或承诺收益；");
        sb.append("3. 提示用户投资有风险，需谨慎决策。");
        sb.append("\n\n");
        if (jsonResponse) {
            sb.append("【重要】请严格按照以下 json 格式回复，不要包含其他内容：\n");
            sb.append("{\n");
            sb.append("  \"answer\": \"你的回答内容（纯文本，不要任何markdown格式）\",\n");
            sb.append("  \"suggestions\": [\"建议问题1\", \"建议问题2\", \"建议问题3\", \"建议问题4\"]\n");
            sb.append("}\n");
            sb.append("suggestions是用户可能继续追问的4个相关建议问题，要和当前话题相关。");
        } else {
            sb.append("请直接输出纯文本正文，不要使用任何 Markdown 语法（包括但不限于：**加粗**、*斜体*、# 标题、- 列表、`代码`、```代码块```、|表格|）。");
            sb.append("如果用户询问当前产品，请从产品定位、风险等级、资产成份、适合关注的人群和订阅前注意事项做分析。");
        }

        return sb.toString();
    }

    private ChatResponse callDeepSeek(String systemPrompt, ChatRequest request) {
        String resolvedApiKey = resolveApiKey();
        // 未配置 API Key 时走本地模拟
        if (resolvedApiKey.isBlank()) {
            log.warn("DEEPSEEK_API_KEY is not configured, using local mock AI response.");
            return mockResponse(request.getQuestion());
        }

        try {
            log.info("Calling DeepSeek chat API. url={}, model={}", apiUrl, model);
            String requestBody = objectMapper.writeValueAsString(buildDeepSeekPayload(systemPrompt, request, false, true));

            HttpRequest httpReq = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + resolvedApiKey)
                    .timeout(Duration.ofSeconds(30))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<String> response = httpClient.send(httpReq, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                JsonNode responseJson = objectMapper.readTree(response.body());
                JsonNode contentNode = responseJson.path("choices").path(0).path("message").path("content");
                if (contentNode.isMissingNode() || contentNode.asText().isBlank()) {
                    log.error("DeepSeek API returned empty content: {}", response.body());
                    return new ChatResponse("抱歉，我现在没有得到有效回复，请稍后再试。", defaultSuggestions());
                }
                String content = contentNode.asText().trim();
                return parseResponse(content);
            } else {
                log.error("DeepSeek API error: status={}, body={}", response.statusCode(), response.body());
                return new ChatResponse("抱歉，我现在有点忙，请稍后再试。", defaultSuggestions());
            }
        } catch (Exception e) {
            log.error("Failed to call DeepSeek API", e);
            return new ChatResponse("抱歉，我遇到了一些问题，请稍后再提问。", defaultSuggestions());
        }
    }

    private void streamChat(ChatRequest request, SseEmitter emitter) {
        String resolvedApiKey = resolveApiKey();
        if (resolvedApiKey.isBlank()) {
            log.warn("DEEPSEEK_API_KEY is not configured, using local mock AI stream response.");
            try {
                streamMockResponse(request, emitter);
            } catch (InterruptedException e) {
                log.warn("Mock stream response interrupted", e);
                Thread.currentThread().interrupt();
                sendSseEvent(emitter, "error", Map.of("message", "抱歉，AI 助手被中断，请稍后再试。"));
                emitter.complete();
            }
            return;
        }

        try {
            log.info("Calling DeepSeek stream chat API. url={}, model={}", apiUrl, model);
            String systemPrompt = buildSystemPrompt(request, false);
            String requestBody = objectMapper.writeValueAsString(buildDeepSeekPayload(systemPrompt, request, true, false));

            HttpRequest httpReq = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl))
                    .header("Content-Type", "application/json")
                    .header("Accept", "text/event-stream")
                    .header("Authorization", "Bearer " + resolvedApiKey)
                    .timeout(Duration.ofSeconds(60))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<Stream<String>> response = httpClient.send(httpReq, HttpResponse.BodyHandlers.ofLines());
            if (response.statusCode() != 200) {
                String body = "";
                if (response.body() != null) {
                    try (Stream<String> bodyLines = response.body()) {
                        body = bodyLines.reduce("", (left, right) -> left + right);
                    }
                }
                log.error("DeepSeek stream API error: status={}, body={}", response.statusCode(), body);
                sendSseEvent(emitter, "error", Map.of("message", "抱歉，AI 助手现在有点忙，请稍后再试。"));
                emitter.complete();
                return;
            }

            try (Stream<String> lines = response.body()) {
                Iterator<String> iterator = lines.iterator();
                while (iterator.hasNext()) {
                    String line = iterator.next();
                    if (!line.startsWith("data:")) {
                        continue;
                    }
                    String data = line.substring("data:".length()).trim();
                    if ("[DONE]".equals(data)) {
                        break;
                    }
                    String delta = extractStreamDelta(data);
                    if (!delta.isEmpty() && !sendSseEvent(emitter, "delta", Map.of("content", delta))) {
                        return;
                    }
                }
            }
            sendSseEvent(emitter, "done", Map.of("suggestions", suggestionsFor(request)));
            emitter.complete();
        } catch (Exception e) {
            log.error("Failed to call DeepSeek stream API", e);
            sendSseEvent(emitter, "error", Map.of("message", "抱歉，我遇到了一些问题，请稍后再提问。"));
            emitter.complete();
        }
    }

    private ObjectNode buildDeepSeekPayload(String systemPrompt, ChatRequest request, boolean stream, boolean jsonResponse) {
        ObjectNode root = objectMapper.createObjectNode();
        root.put("model", model);
        root.put("stream", stream);
        root.put("temperature", temperature);
        root.put("max_tokens", maxTokens);
        ObjectNode thinking = root.putObject("thinking");
        thinking.put("type", "disabled");
        if (jsonResponse) {
            ObjectNode responseFormat = root.putObject("response_format");
            responseFormat.put("type", "json_object");
        }

        ArrayNode messages = root.putArray("messages");
        ObjectNode systemMsg = messages.addObject();
        systemMsg.put("role", "system");
        systemMsg.put("content", systemPrompt);

        if (request.getHistory() != null) {
            for (Map<String, String> msg : request.getHistory()) {
                String role = msg.get("role");
                String content = msg.get("content");
                if (!isValidMessage(role, content)) {
                    continue;
                }
                ObjectNode historyMsg = messages.addObject();
                historyMsg.put("role", role);
                historyMsg.put("content", content);
            }
        }

        ObjectNode userMsg = messages.addObject();
        userMsg.put("role", "user");
        userMsg.put("content", request.getQuestion());
        return root;
    }

    private String extractStreamDelta(String data) {
        try {
            JsonNode root = objectMapper.readTree(data);
            return root.path("choices").path(0).path("delta").path("content").asText("");
        } catch (Exception e) {
            log.warn("Failed to parse DeepSeek stream delta. data={}", data);
            return "";
        }
    }

    private JsonNode callJsonCompletion(String systemPrompt, String userContent) {
        String resolvedApiKey = resolveApiKey();
        if (resolvedApiKey.isBlank()) {
            log.warn("DEEPSEEK_API_KEY is not configured, using local structured AI fallback.");
            return null;
        }

        try {
            ObjectNode root = objectMapper.createObjectNode();
            root.put("model", model);
            root.put("stream", false);
            root.put("temperature", temperature);
            root.put("max_tokens", maxTokens);
            ObjectNode thinking = root.putObject("thinking");
            thinking.put("type", "disabled");
            ObjectNode responseFormat = root.putObject("response_format");
            responseFormat.put("type", "json_object");

            ArrayNode messages = root.putArray("messages");
            ObjectNode systemMsg = messages.addObject();
            systemMsg.put("role", "system");
            systemMsg.put("content", systemPrompt);
            ObjectNode userMsg = messages.addObject();
            userMsg.put("role", "user");
            userMsg.put("content", userContent);

            HttpRequest httpReq = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + resolvedApiKey)
                    .timeout(Duration.ofSeconds(45))
                    .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(root)))
                    .build();

            HttpResponse<String> response = httpClient.send(httpReq, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() != 200) {
                log.error("DeepSeek structured API error: status={}, body={}", response.statusCode(), response.body());
                return null;
            }
            String content = objectMapper.readTree(response.body())
                    .path("choices").path(0).path("message").path("content").asText("").trim();
            if (content.isBlank()) {
                log.error("DeepSeek structured API returned empty content: {}", response.body());
                return null;
            }
            return objectMapper.readTree(unwrapJsonContent(content));
        } catch (Exception e) {
            log.error("Failed to call DeepSeek structured API", e);
            return null;
        }
    }

    private String buildPublishedProductContext(PublicProductDetailVO detail) {
        StringBuilder sb = new StringBuilder();
        sb.append("产品名称：").append(detail.getName()).append("\n");
        sb.append("产品类型：").append(detail.getType()).append("\n");
        sb.append("风险等级：").append(detail.getRiskLevel()).append("\n");
        sb.append("策略编码：").append(detail.getStrategyCode()).append("\n");
        if (detail.getFeatureTags() != null) {
            sb.append("特征标签：").append(String.join("、", detail.getFeatureTags())).append("\n");
        }
        appendMapValue(sb, detail.getBaseInfo(), "productSummary", "产品简介：");
        appendMapValue(sb, detail.getBaseInfo(), "targetCustomer", "目标客群：");
        appendMapValue(sb, detail.getBaseInfo(), "riskTips", "风险提示：");
        appendMapValue(sb, detail.getParams(), "investHorizonMonths", "建议持有（月）：");
        appendMapValue(sb, detail.getParams(), "strategyNotes", "策略说明：");
        if (detail.getComponents() != null && !detail.getComponents().isEmpty()) {
            sb.append("基金成份：\n");
            for (DraftComponentVO component : detail.getComponents()) {
                sb.append("- ").append(component.getFundName())
                        .append("(").append(component.getFundCode()).append(")")
                        .append("，类型").append(component.getFundType())
                        .append("，权重").append(component.getWeight())
                        .append("，风险").append(component.getRiskLevel())
                        .append("\n");
            }
        }
        if (detail.getNavList() != null && !detail.getNavList().isEmpty()) {
            PublicProductNavPointVO latest = detail.getNavList().get(detail.getNavList().size() - 1);
            sb.append("最新净值：").append(latest.getNav()).append("\n");
            sb.append("累计收益：").append(latest.getCumReturn()).append("\n");
            sb.append("净值日期：").append(latest.getNavDate()).append("\n");
        }
        return sb.toString();
    }

    private String buildReviewContext(ReviewDetailVO detail) {
        StringBuilder sb = new StringBuilder();
        sb.append("待审产品：").append(detail.getName()).append("\n");
        sb.append("产品类型：").append(detail.getType()).append("\n");
        sb.append("风险等级：").append(detail.getRiskLevel()).append("\n");
        sb.append("策略编码：").append(detail.getStrategyCode()).append("\n");
        sb.append("变更类型：").append(detail.getChangeType()).append("\n");
        sb.append("版本说明：").append(detail.getVersionNote()).append("\n");
        appendMapValue(sb, detail.getBaseInfo(), "productSummary", "产品简介：");
        appendMapValue(sb, detail.getBaseInfo(), "targetCustomer", "目标客群：");
        appendMapValue(sb, detail.getBaseInfo(), "riskTips", "风险提示：");
        appendMapValue(sb, detail.getParams(), "rebalanceCycleDays", "调仓周期：");
        appendMapValue(sb, detail.getParams(), "maxSingleFundWeight", "单基金最大权重：");
        appendMapValue(sb, detail.getParams(), "investHorizonMonths", "建议持有（月）：");
        if (detail.getComponents() != null && !detail.getComponents().isEmpty()) {
            sb.append("当前基金成份：\n");
            for (DraftComponentVO component : detail.getComponents()) {
                sb.append("- ").append(component.getFundName())
                        .append("(").append(component.getFundCode()).append(")")
                        .append("，权重").append(component.getWeight())
                        .append("，风险").append(component.getRiskLevel())
                        .append("\n");
            }
        }
        if (detail.getFieldDiffs() != null && !detail.getFieldDiffs().isEmpty()) {
            sb.append("字段变更：\n");
            for (ReviewDiffFieldVO diff : detail.getFieldDiffs()) {
                sb.append("- ").append(diff.getFieldLabel())
                        .append("：").append(diff.getBeforeValue())
                        .append(" -> ").append(diff.getAfterValue())
                        .append(diff.isMajorSignal() ? "（重大信号）" : "")
                        .append("\n");
            }
        }
        if (detail.getComponentDiffs() != null && !detail.getComponentDiffs().isEmpty()) {
            sb.append("成份变更：\n");
            for (ReviewDiffComponentVO diff : detail.getComponentDiffs()) {
                sb.append("- ").append(diff.getDiffType())
                        .append(" ").append(diff.getFundName())
                        .append("(").append(diff.getFundCode()).append(")")
                        .append("：").append(diff.getBeforeWeight())
                        .append(" -> ").append(diff.getAfterWeight())
                        .append("，变化").append(diff.getDeltaWeight())
                        .append("\n");
            }
        }
        return sb.toString();
    }

    private ProductAnalysisResponse fallbackProductAnalysis(PublicProductDetailVO detail) {
        String summary = valueFrom(detail.getBaseInfo(), "productSummary", "该产品为基金投顾组合产品，适合结合自身风险承受能力进一步了解。");
        return new ProductAnalysisResponse(
                summary,
                "适合风险偏好与产品等级 " + detail.getRiskLevel() + " 匹配，并能接受基金组合净值波动的用户关注。",
                "当前组合包含 " + (detail.getComponents() == null ? 0 : detail.getComponents().size()) + " 只基金成份，需重点查看权重分布和基金类型。",
                riskBadge(detail.getRiskLevel()),
                List.of("具备组合化配置特征", "产品信息和持仓明细可追踪", "可结合净值曲线观察表现"),
                List.of("基金净值存在波动", "历史表现不代表未来收益", "订阅前需确认风险等级是否匹配"),
                List.of("确认自身风险承受能力", "查看基金成份和权重集中度", "阅读产品风险提示")
        );
    }

    private ReviewAdviceResponse fallbackReviewAdvice(ReviewDetailVO detail) {
        double weightSum = 0D;
        double maxWeight = 0D;
        if (detail.getComponents() != null) {
            for (DraftComponentVO component : detail.getComponents()) {
                double weight = component.getWeight() == null ? 0D : component.getWeight().doubleValue();
                weightSum += weight;
                maxWeight = Math.max(maxWeight, weight);
            }
        }
        List<String> concerns = new ArrayList<>();
        if (Math.abs(weightSum - 1D) > 0.001D) {
            concerns.add("基金权重合计不是 1.0000，需要重点复核");
        }
        if (maxWeight > 0.5D) {
            concerns.add("存在单基金权重超过 50%，需要关注集中度风险");
        }
        if (concerns.isEmpty()) {
            concerns.add("基础字段和成份权重未发现明显异常，仍需结合规则和人工判断");
        }
        return new ReviewAdviceResponse(
                concerns.size() > 1 ? "建议重点复核" : "建议通过",
                maxWeight > 0.5D ? "高" : "中",
                "该建议基于产品基础信息、成份权重和版本差异自动生成，仅作为人工审核参考。",
                concerns,
                List.of("风险等级：" + detail.getRiskLevel(), "成份数量：" + (detail.getComponents() == null ? 0 : detail.getComponents().size()), "最大单基金权重：" + maxWeight),
                List.of("本次变更是否影响目标客群？", "风险提示是否覆盖主要波动来源？", "投顾是否说明权重调整原因？")
        );
    }

    private String text(JsonNode root, String field, String fallback) {
        String value = root.path(field).asText("");
        return value.isBlank() ? fallback : value;
    }

    private List<String> list(JsonNode root, String field, List<String> fallback) {
        JsonNode node = root.path(field);
        if (!node.isArray()) {
            return fallback;
        }
        List<String> values = new ArrayList<>();
        for (JsonNode item : node) {
            String value = item.asText("");
            if (!value.isBlank()) {
                values.add(value);
            }
        }
        return values.isEmpty() ? fallback : values.stream().limit(4).toList();
    }

    private String valueFrom(Map<String, Object> map, String key, String fallback) {
        if (map == null || map.get(key) == null) {
            return fallback;
        }
        String value = String.valueOf(map.get(key)).trim();
        return value.isBlank() ? fallback : value;
    }

    private String riskBadge(String riskLevel) {
        return switch (riskLevel == null ? "" : riskLevel.toUpperCase()) {
            case "R1" -> "低风险";
            case "R2" -> "中低风险";
            case "R4" -> "中高风险";
            case "R5" -> "高风险";
            default -> "中风险";
        };
    }

    private void appendProductContext(StringBuilder sb, ChatRequest request) {
        if (request.getProductId() == null) {
            return;
        }

        PublicProductDetailVO detail = null;
        try {
            detail = publicAdvisorProductService.getPublishedProductDetail(request.getProductId());
        } catch (Exception ex) {
            log.debug("Failed to load published product detail for AI context, productId={}", request.getProductId(), ex);
        }

        if (detail != null) {
            sb.append("用户当前正在查看以下已发布产品，请优先基于这些信息分析：\n");
            sb.append("- 产品名称：").append(detail.getName()).append("\n");
            sb.append("- 产品类型：").append(detail.getType()).append("\n");
            sb.append("- 风险等级：").append(detail.getRiskLevel()).append("\n");
            sb.append("- 策略编码：").append(detail.getStrategyCode()).append("\n");
            if (detail.getFeatureTags() != null && !detail.getFeatureTags().isEmpty()) {
                sb.append("- 特征标签：").append(String.join("、", detail.getFeatureTags())).append("\n");
            }
            appendMapValue(sb, detail.getBaseInfo(), "productSummary", "- 产品简介：");
            appendMapValue(sb, detail.getBaseInfo(), "intro", "- 产品简介：");
            appendMapValue(sb, detail.getBaseInfo(), "targetCustomer", "- 目标客群：");
            appendMapValue(sb, detail.getBaseInfo(), "targetUser", "- 目标客群：");
            appendMapValue(sb, detail.getBaseInfo(), "riskTips", "- 风险提示：");
            appendMapValue(sb, detail.getParams(), "investHorizonMonths", "- 建议持有（月）：");
            if (detail.getComponents() != null && !detail.getComponents().isEmpty()) {
                sb.append("- 基金成份：");
                int limit = Math.min(detail.getComponents().size(), 8);
                for (int i = 0; i < limit; i++) {
                    DraftComponentVO component = detail.getComponents().get(i);
                    if (i > 0) {
                        sb.append("；");
                    }
                    sb.append(component.getFundName())
                            .append("(").append(component.getFundCode()).append(")")
                            .append("，权重").append(component.getWeight())
                            .append("，风险").append(component.getRiskLevel());
                }
                sb.append("\n");
            }
            if (detail.getNavList() != null && !detail.getNavList().isEmpty()) {
                PublicProductNavPointVO latest = detail.getNavList().get(detail.getNavList().size() - 1);
                sb.append("- 最新净值日期：").append(latest.getNavDate()).append("\n");
                sb.append("- 最新净值：").append(latest.getNav()).append("\n");
                sb.append("- 累计收益：").append(latest.getCumReturn()).append("\n");
            }
            sb.append("\n");
            return;
        }

        AdvisorProduct product = productMapper.selectById(request.getProductId());
        if (product != null) {
            sb.append("用户当前正在查看以下产品信息：\n");
            sb.append("- 产品名称：").append(product.getName()).append("\n");
            sb.append("- 产品类型：").append(product.getType()).append("\n");
            sb.append("- 风险等级：").append(product.getRiskLevel()).append("\n");
            sb.append("- 策略编码：").append(product.getStrategyCode()).append("\n");
            sb.append("- 当前状态：").append(product.getStatus()).append("\n\n");
        }
    }

    private void appendMapValue(StringBuilder sb, Map<String, Object> map, String key, String label) {
        if (map == null || !map.containsKey(key) || map.get(key) == null) {
            return;
        }
        String value = String.valueOf(map.get(key)).trim();
        if (!value.isBlank()) {
            sb.append(label).append(value).append("\n");
        }
    }

    private void streamMockResponse(ChatRequest request, SseEmitter emitter) throws InterruptedException {
        ChatResponse mock = mockResponse(request.getQuestion());
        String answer = mock.getAnswer() == null ? "" : mock.getAnswer();
        for (int index = 0; index < answer.length(); index += 6) {
            String chunk = answer.substring(index, Math.min(index + 6, answer.length()));
            if (!sendSseEvent(emitter, "delta", Map.of("content", chunk))) {
                return;
            }
            Thread.sleep(35);
        }
        sendSseEvent(emitter, "done", Map.of("suggestions", mock.getSuggestions()));
        emitter.complete();
    }

    private boolean sendSseEvent(SseEmitter emitter, String eventName, Object data) {
        try {
            emitter.send(SseEmitter.event().name(eventName).data(objectMapper.writeValueAsString(data)));
            return true;
        } catch (IOException | IllegalStateException ex) {
            log.debug("Failed to send SSE event: {}", eventName, ex);
            return false;
        }
    }

    private List<String> suggestionsFor(ChatRequest request) {
        if (request.getProductId() != null) {
            return List.of(
                    "这只产品适合什么类型的投资者？",
                    "它的主要风险点有哪些？",
                    "基金成份配置有什么特点？",
                    "订阅前我应该重点看什么？"
            );
        }
        return defaultSuggestions();
    }

    /** 解析 DeepSeek 返回的 JSON */
    private ChatResponse parseResponse(String content) {
        try {
            String jsonContent = unwrapJsonContent(content);
            // 尝试直接解析 JSON
            if (jsonContent.startsWith("{")) {
                JsonNode root = objectMapper.readTree(jsonContent);
                String answer = root.has("answer") ? root.get("answer").asText() : content;
                List<String> suggestions = new ArrayList<>();
                if (root.has("suggestions") && root.get("suggestions").isArray()) {
                    for (JsonNode sug : root.get("suggestions")) {
                        String suggestion = sug.asText();
                        if (suggestion != null && !suggestion.isBlank()) {
                            suggestions.add(suggestion);
                        }
                    }
                }
                if (suggestions.isEmpty()) {
                    suggestions.addAll(defaultSuggestions());
                }
                return new ChatResponse(answer, suggestions.stream().limit(4).toList());
            }

            // 如果不是 JSON，尝试从文本中提取 "suggestions" 部分
            if (content.contains("建议问题") || content.contains("suggestions")) {
                String[] parts = content.split("\n");
                StringBuilder answer = new StringBuilder();
                for (String line : parts) {
                    if (!line.contains("建议问题") && !line.matches("^\\d+\\..*")) {
                        answer.append(line).append("\n");
                    }
                }
                return new ChatResponse(answer.toString().trim(), defaultSuggestions());
            }

            return new ChatResponse(content, defaultSuggestions());
        } catch (Exception e) {
            log.warn("Failed to parse AI response as JSON, using raw text. content={}", content);
            return new ChatResponse(content, defaultSuggestions());
        }
    }

    private boolean isValidMessage(String role, String content) {
        return ("user".equals(role) || "assistant".equals(role))
                && content != null
                && !content.isBlank();
    }

    private String resolveApiKey() {
        String configured = normalize(apiKey);
        if (!configured.isBlank()) {
            return configured;
        }
        String systemProperty = normalize(System.getProperty("DEEPSEEK_API_KEY"));
        if (!systemProperty.isBlank()) {
            return systemProperty;
        }
        String springSystemProperty = normalize(System.getProperty("ai.deepseek.api-key"));
        if (!springSystemProperty.isBlank()) {
            return springSystemProperty;
        }
        return normalize(System.getenv("DEEPSEEK_API_KEY"));
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private String maskApiKey(String value) {
        String key = normalize(value);
        if (key.isBlank()) {
            return "(empty)";
        }
        if (key.length() <= 8) {
            return "****";
        }
        return key.substring(0, 3) + "****" + key.substring(key.length() - 4);
    }

    private String unwrapJsonContent(String content) {
        String trimmed = content == null ? "" : content.trim();
        if (trimmed.startsWith("```")) {
            int firstLineEnd = trimmed.indexOf('\n');
            int lastFence = trimmed.lastIndexOf("```");
            if (firstLineEnd >= 0 && lastFence > firstLineEnd) {
                return trimmed.substring(firstLineEnd + 1, lastFence).trim();
            }
        }
        return trimmed;
    }

    /** 无 API Key 时的本地模拟回答 + 动态建议 */
    private ChatResponse mockResponse(String question) {
        String q = question.toLowerCase();
        String answer;
        List<String> suggestions;

        if (q.contains("风险") && q.contains("r1")) {
            answer = "R1 是低风险等级，适合保守型投资者。建议您关注以债券、货币基金为主的稳健型产品。";
            suggestions = List.of("R3等级适合什么产品？", "货币基金和债券基金有什么区别？", "如何查看产品的风险等级？", "保守型投资者该怎么配置？");
        } else if (q.contains("风险") && q.contains("r5")) {
            answer = "R5 是高风险等级，适合进取型投资者。这类产品可能包含股票型基金等波动较大的资产，收益潜力高但回撤也较大。";
            suggestions = List.of("R5产品适合长期持有吗？", "如何降低投资风险？", "历史收益怎么看？", "什么是最大回撤？");
        } else if (q.contains("订阅") || q.contains("购买")) {
            answer = "您可以在「产品专区」浏览已发布的产品，点击感兴趣的产品进入详情页，点击「立即订阅」按钮即可完成订阅。";
            suggestions = List.of("订阅后可以取消吗？", "如何查看我的订阅？", "产品审核流程是怎样的？", "订阅需要多少金额？");
        } else if (q.contains("什么是") || q.contains("介绍") || q.contains("平台")) {
            answer = "智能投顾平台是一站式基金投顾管理系统，支持投顾创建组合产品、审核流转、用户订阅的全流程管理。您可以在产品专区浏览各类基金组合产品。";
            suggestions = List.of("如何选择适合自己的产品？", "投顾和普通用户有什么区别？", "产品审核要多久？", "什么是FOF组合？");
        } else if (q.contains("fof")) {
            answer = "FOF（Fund of Funds）即基金中的基金，是一种专门投资于其他证券投资基金的基金。FOF不直接投股票或债券，而是通过持有其他基金来分散风险。";
            suggestions = List.of("FOF和普通基金有什么区别？", "FOF适合什么类型的投资者？", "如何挑选FOF产品？", "FOF的收益怎么样？");
        } else if (q.contains("策略") || q.contains("strategy")) {
            answer = "策略码代表产品的投资策略类型，不同的策略对应不同的资产配置方式和风险收益特征。投顾在创建产品时会选择对应的策略编码。";
            suggestions = List.of("有哪些投资策略可选？", "策略码和风险等级的关系？", "如何选择适合自己的策略？", "策略可以修改吗？");
        } else {
            answer = "您好！我是小顾，您的智能投资助手。我可以帮您解答关于基金产品、风险等级、订阅流程等问题。请问您想了解什么？";
            suggestions = List.of("如何选择适合我的产品？", "R1和R5风险等级有什么区别？", "如何订阅产品？", "什么是FOF组合？");
        }

        return new ChatResponse("【本地模拟】" + answer, suggestions);
    }

    private List<String> defaultSuggestions() {
        return List.of("如何选择适合我的产品？", "R1和R5风险等级有什么区别？", "如何订阅产品？", "什么是FOF组合？");
    }
}
