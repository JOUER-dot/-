package com.finance.roboadvisor.aiassistant.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.finance.roboadvisor.aiassistant.dto.ChatRequest;
import com.finance.roboadvisor.aiassistant.dto.ChatResponse;
import com.finance.roboadvisor.product.entity.AdvisorProduct;
import com.finance.roboadvisor.product.mapper.ProductMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class AiAssistantService {

    private static final Logger log = LoggerFactory.getLogger(AiAssistantService.class);

    private final ProductMapper productMapper;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    @Value("${ai.deepseek.api-key:}")
    private String apiKey;

    @Value("${ai.deepseek.api-url:https://api.deepseek.com/v1/chat/completions}")
    private String apiUrl;

    @Value("${ai.deepseek.model:deepseek-chat}")
    private String model;

    public AiAssistantService(ProductMapper productMapper, ObjectMapper objectMapper) {
        this.productMapper = productMapper;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(10))
                .build();
    }

    public ChatResponse chat(ChatRequest request) {
        String systemPrompt = buildSystemPrompt(request);
        return callDeepSeek(systemPrompt, request);
    }

    private String buildSystemPrompt(ChatRequest request) {
        StringBuilder sb = new StringBuilder();
        sb.append("你是「智能投顾平台」的AI投资助手，你的名字叫「小顾」。");
        sb.append("你的任务是帮助用户了解基金投顾产品、解答投资疑问。");
        sb.append("请用通俗易懂的中文回答，语气亲切友好。");
        sb.append("\n\n");

        // 产品上下文
        if (request.getProductId() != null) {
            AdvisorProduct product = productMapper.selectById(request.getProductId());
            if (product != null) {
                sb.append("用户当前正在查看以下产品信息：\n");
                sb.append("- 产品名称：").append(product.getName()).append("\n");
                sb.append("- 产品类型：").append(product.getType()).append("\n");
                sb.append("- 风险等级：").append(product.getRiskLevel()).append("\n");
                sb.append("- 策略编码：").append(product.getStrategyCode()).append("\n");
                sb.append("- 当前状态：").append(product.getStatus()).append("\n");
                sb.append("\n请基于以上产品信息回答用户的问题。");
            }
        }

        // 用户风险等级
        if (request.getRiskLevel() != null) {
            sb.append("用户的风险偏好等级为：").append(request.getRiskLevel()).append("（R1=保守，R5=进取）\n");
        }

        sb.append("\n注意：");
        sb.append("1. 回答应简洁明了，控制在200字以内；");
        sb.append("2. 不提供具体的投资建议或承诺收益；");
        sb.append("3. 提示用户投资有风险，需谨慎决策。");
        sb.append("\n\n");
        sb.append("【重要】请严格按照以下JSON格式回复，不要包含其他内容：\n");
        sb.append("{\n");
        sb.append("  \"answer\": \"你的回答内容\",\n");
        sb.append("  \"suggestions\": [\"建议问题1\", \"建议问题2\", \"建议问题3\", \"建议问题4\"]\n");
        sb.append("}\n");
        sb.append("suggestions是用户可能继续追问的4个相关建议问题，要和当前话题相关。");

        return sb.toString();
    }

    private ChatResponse callDeepSeek(String systemPrompt, ChatRequest request) {
        // 未配置 API Key 时走本地模拟
        if (apiKey == null || apiKey.isEmpty() || apiKey.isBlank()) {
            return mockResponse(request.getQuestion());
        }

        try {
            ObjectNode root = objectMapper.createObjectNode();
            root.put("model", model);
            root.put("stream", false);

            ArrayNode messages = root.putArray("messages");
            // 1. 系统提示词
            ObjectNode systemMsg = messages.addObject();
            systemMsg.put("role", "system");
            systemMsg.put("content", systemPrompt);

            // 2. 对话历史（如果有）
            if (request.getHistory() != null) {
                for (Map<String, String> msg : request.getHistory()) {
                    ObjectNode historyMsg = messages.addObject();
                    historyMsg.put("role", msg.get("role"));
                    historyMsg.put("content", msg.get("content"));
                }
            }

            // 3. 当前用户问题
            ObjectNode userMsg = messages.addObject();
            userMsg.put("role", "user");
            userMsg.put("content", request.getQuestion());

            String requestBody = objectMapper.writeValueAsString(root);

            HttpRequest httpReq = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + apiKey)
                    .timeout(Duration.ofSeconds(30))
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<String> response = httpClient.send(httpReq, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                JsonNode responseJson = objectMapper.readTree(response.body());
                String content = responseJson.get("choices").get(0).get("message").get("content").asText().trim();
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

    /** 解析 DeepSeek 返回的 JSON */
    private ChatResponse parseResponse(String content) {
        try {
            // 尝试直接解析 JSON
            if (content.startsWith("{")) {
                JsonNode root = objectMapper.readTree(content);
                String answer = root.has("answer") ? root.get("answer").asText() : content;
                List<String> suggestions = new ArrayList<>();
                if (root.has("suggestions") && root.get("suggestions").isArray()) {
                    for (JsonNode sug : root.get("suggestions")) {
                        suggestions.add(sug.asText());
                    }
                }
                if (suggestions.isEmpty()) {
                    suggestions.addAll(defaultSuggestions());
                }
                return new ChatResponse(answer, suggestions);
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

        return new ChatResponse(answer, suggestions);
    }

    private List<String> defaultSuggestions() {
        return List.of("如何选择适合我的产品？", "R1和R5风险等级有什么区别？", "如何订阅产品？", "什么是FOF组合？");
    }
}
