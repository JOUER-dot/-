CREATE DATABASE IF NOT EXISTS finance DEFAULT CHARSET utf8mb4;
USE finance;

/*
 Navicat Premium Data Transfer

 Source Server         : mysql80
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : finance

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 27/06/2026 21:01:18
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for advisor_product
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product`;
CREATE TABLE `advisor_product`  (
                                    `id` bigint NOT NULL AUTO_INCREMENT,
                                    `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组合名称',
                                    `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'STRATEGY/FOF',
                                    `risk_level` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'R1~R5',
                                    `strategy_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '策略编码',
                                    `feature_tags` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签（可存逗号或JSON字符串）',
                                    `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'DRAFT/PENDING_REVIEW/REJECTED/PUBLISHED/OFFLINE',
                                    `creator_id` bigint NOT NULL COMMENT '创建人（投顾）',
                                    `current_version_no` int NOT NULL DEFAULT 0 COMMENT '当前版本号（每次提交审核+1）',
                                    `published_version_no` int NULL DEFAULT NULL COMMENT '已上架版本号（审核通过时写入）',
                                    `last_reject_comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最近一次驳回意见（便于列表展示，可选）',
                                    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                    PRIMARY KEY (`id`) USING BTREE,
                                    UNIQUE INDEX `uk_advisor_product_name`(`name` ASC) USING BTREE,
                                    INDEX `idx_advisor_product_status`(`status` ASC) USING BTREE,
                                    INDEX `idx_advisor_product_creator`(`creator_id` ASC) USING BTREE,
                                    INDEX `idx_advisor_product_type_risk`(`type` ASC, `risk_level` ASC) USING BTREE,
                                    CONSTRAINT `fk_advisor_product_creator` FOREIGN KEY (`creator_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '投顾组合产品主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product
-- ----------------------------
INSERT INTO `advisor_product` VALUES (1, '天弘全球新能源', '进取型', 'R5', '11', '固收增强', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-23 21:05:07', '2026-06-23 21:05:35');
INSERT INTO `advisor_product` VALUES (2, '1', '平衡型', 'R3', '2', '长期持有', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-23 22:45:38', '2026-06-23 22:54:15');
INSERT INTO `advisor_product` VALUES (3, '2', '平衡型', 'R4', '3', '权益增强', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-24 20:22:35', '2026-06-24 23:53:10');
INSERT INTO `advisor_product` VALUES (4, '平安保险', 'FOF', 'R3', '4', '低波动', 'OFFLINE', 3, 1, 1, NULL, '2026-06-25 00:32:12', '2026-06-25 14:21:32');
INSERT INTO `advisor_product` VALUES (5, '国泰', 'STRATEGY', 'R1', '12', '权益增强', 'REJECTED', 3, 1, NULL, '权重过高', '2026-06-26 18:21:57', '2026-06-26 21:31:13');
INSERT INTO `advisor_product` VALUES (9, '英伟达', 'FOF', 'R1', '11', '权益增强', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-26 18:23:50', '2026-06-26 20:03:54');
INSERT INTO `advisor_product` VALUES (11, '大成', 'STRATEGY', 'R5', '12', '固收增强', 'PUBLISHED', 3, 2, 2, NULL, '2026-06-26 20:13:19', '2026-06-27 00:46:59');
INSERT INTO `advisor_product` VALUES (12, '天弘', 'FOF', 'R2', '33', '固收增强,养老规划', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-26 21:53:47', '2026-06-27 03:21:46');
INSERT INTO `advisor_product` VALUES (13, '德邦', 'FOF', 'R4', '55', '长期持有', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-26 21:59:51', '2026-06-27 15:04:06');
INSERT INTO `advisor_product` VALUES (14, '天弘(副本)', 'FOF', 'R2', '33', '固收增强,养老规划', 'DRAFT', 3, 0, NULL, NULL, '2026-06-27 03:45:43', '2026-06-27 03:45:43');

-- ----------------------------
-- Table structure for advisor_product_component
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_component`;
CREATE TABLE `advisor_product_component`  (
                                              `id` bigint NOT NULL AUTO_INCREMENT,
                                              `product_version_id` bigint NOT NULL,
                                              `fund_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                              `fund_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                              `weight` decimal(10, 4) NOT NULL COMMENT '权重（建议存0~1小数；若存百分比需统一口径）',
                                              `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              PRIMARY KEY (`id`) USING BTREE,
                                              INDEX `idx_component_version`(`product_version_id` ASC) USING BTREE,
                                              INDEX `idx_component_fund_code`(`fund_code` ASC) USING BTREE,
                                              CONSTRAINT `fk_component_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 62 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品成份（基金及权重，挂版本）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_component
-- ----------------------------
INSERT INTO `advisor_product_component` VALUES (1, 1, '519674', '银河创新成长混合', 1.0000, '2026-06-23 21:05:07');
INSERT INTO `advisor_product_component` VALUES (2, 2, '159915', '易方达创业板ETF', 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (3, 2, '510300', '华泰柏瑞沪深300ETF', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (4, 2, '163406', '兴全合润混合', 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (5, 2, '000452', '南方医药保健灵活配置混合', 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (6, 2, '040046', '华安纳斯达克100指数', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (7, 2, '518880', '华安黄金ETF', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (8, 2, '161005', '富国天惠成长混合', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (9, 3, '040046', '华安纳斯达克100指数', 0.3000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_component` VALUES (10, 3, '513100', '国泰纳斯达克100ETF', 0.7000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_component` VALUES (11, 4, '040046', '华安纳斯达克100指数', 0.4000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_component` VALUES (12, 4, '513100', '国泰纳斯达克100ETF', 0.1000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_component` VALUES (13, 4, '161005', '富国天惠成长混合', 0.5000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_component` VALUES (14, 5, '159915', '易方达创业板ETF', 0.0100, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (15, 5, '163406', '兴全合润混合', 0.0500, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (16, 5, '513100', '国泰纳斯达克100ETF', 0.2000, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (17, 5, '518880', '华安黄金ETF', 0.0600, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (18, 5, '161005', '富国天惠成长混合', 0.6800, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (19, 6, '320007', '诺安成长混合', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (20, 6, '260108', '景顺长城新兴成长混合', 0.0800, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (21, 6, '163406', '兴全合润混合', 0.0120, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (22, 6, '000452', '南方医药保健灵活配置混合', 0.0010, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (23, 6, '040046', '华安纳斯达克100指数', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (24, 6, '513100', '国泰纳斯达克100ETF', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (25, 6, '000307', '易方达黄金ETF联接A', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (26, 6, '518880', '华安黄金ETF', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (27, 6, '161005', '富国天惠成长混合', 0.3000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (28, 6, '398011', '中海分红增利混合', 0.1070, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (29, 7, '159915', '易方达创业板ETF', 0.0100, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (30, 7, '163406', '兴全合润混合', 0.0500, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (31, 7, '513100', '国泰纳斯达克100ETF', 0.2000, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (32, 7, '518880', '华安黄金ETF', 0.0600, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (33, 7, '161005', '富国天惠成长混合', 0.6800, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (34, 8, '001838', '国投瑞银国家安全混合', 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (35, 8, '003096', '中欧医疗创新股票A', 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (36, 8, '001717', '工银前沿医疗股票A', 0.1230, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (37, 8, '110011', '易方达中小盘混合', 0.3442, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (38, 8, '519696', '交银环球精选混合(QDII)', 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (39, 8, '161039', '富国中证1000指数增强', 0.0200, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (40, 8, '159915', '易方达创业板ETF', 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (41, 8, '510300', '华泰柏瑞沪深300ETF', 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (42, 8, '512690', '鹏华中证酒ETF', 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (43, 8, '515790', '华夏中证新能源ETF', 0.0628, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (44, 9, '001632', '天弘中证食品饮料ETF联接A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (45, 9, '005827', '易方达蓝筹精选混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (46, 9, '006113', '汇添富创新医药混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (47, 9, '000248', '汇添富中证主要消费ETF联接', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (48, 9, '001875', '前海开源沪港深优势精选混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (49, 9, '002190', '农银新能源主题灵活配置混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (50, 9, '004851', '广发医疗保健股票A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (51, 9, '000960', '招商医药健康产业股票', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (52, 9, '001071', '华夏恒生ETF联接A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (53, 9, '006479', '中欧智能制造混合A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (54, 10, '320007', '诺安成长混合', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (55, 10, '260108', '景顺长城新兴成长混合', 0.0800, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (56, 10, '163406', '兴全合润混合', 0.0120, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (57, 10, '000452', '南方医药保健灵活配置混合', 0.0010, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (58, 10, '040046', '华安纳斯达克100指数', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (59, 10, '513100', '国泰纳斯达克100ETF', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (60, 10, '000307', '易方达黄金ETF联接A', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (61, 10, '398011', '中海分红增利混合', 0.5070, '2026-06-27 00:46:26');

-- ----------------------------
-- Table structure for advisor_product_draft
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_draft`;
CREATE TABLE `advisor_product_draft`  (
                                          `id` bigint NOT NULL AUTO_INCREMENT,
                                          `product_id` bigint NOT NULL COMMENT '产品ID',
                                          `base_info_json` json NOT NULL COMMENT '草稿基础信息',
                                          `params_json` json NULL COMMENT '草稿策略参数',
                                          `updated_by` bigint NOT NULL COMMENT '最后修改人',
                                          `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                          `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                          PRIMARY KEY (`id`) USING BTREE,
                                          UNIQUE INDEX `uk_draft_product_id`(`product_id` ASC) USING BTREE,
                                          INDEX `idx_draft_updated_by`(`updated_by` ASC) USING BTREE,
                                          CONSTRAINT `fk_draft_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                          CONSTRAINT `fk_draft_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品草稿表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_draft
-- ----------------------------
INSERT INTO `advisor_product_draft` VALUES (1, 1, '{\"riskTips\": \"111\", \"productSummary\": \"11\", \"targetCustomer\": \"111\"}', '{\"strategyNotes\": \"11111\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-23 21:05:07', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_draft` VALUES (2, 2, '{\"riskTips\": \"2\", \"productSummary\": \"2\", \"targetCustomer\": \"2\"}', '{\"strategyNotes\": \"222\", \"rebalanceCycleDays\": 3, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.06}', 3, '2026-06-23 22:45:38', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft` VALUES (3, 3, '{\"riskTips\": \"1\", \"productSummary\": \"1\", \"targetCustomer\": \"1\"}', '{\"strategyNotes\": \"1\", \"rebalanceCycleDays\": 2, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-24 20:22:35', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_draft` VALUES (4, 4, '{\"riskTips\": \"低风险\", \"productSummary\": \"养老保险\", \"targetCustomer\": \"老年人\"}', '{\"strategyNotes\": \"无\", \"rebalanceCycleDays\": 4, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.1}', 3, '2026-06-25 00:32:12', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft` VALUES (5, 5, '{\"riskTips\": \"223让人\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 18:21:57', '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft` VALUES (6, 9, '{\"riskTips\": \"223让人\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 18:23:50', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft` VALUES (7, 11, '{\"riskTips\": \"12321313\", \"productSummary\": \"2313131\", \"targetCustomer\": \"131213饿\"}', '{\"strategyNotes\": \"1212112\", \"rebalanceCycleDays\": 142, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 20:13:19', '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft` VALUES (8, 12, '{\"riskTips\": \"2342\", \"productSummary\": \"12\", \"targetCustomer\": \"23\"}', '{\"strategyNotes\": \"2342423\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 34, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 21:53:48', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft` VALUES (9, 13, '{\"riskTips\": \"1234\", \"productSummary\": \"去11\", \"targetCustomer\": \"564\"}', '{\"strategyNotes\": \"1313\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 120, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 21:59:51', '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft` VALUES (10, 14, '{\"riskTips\": \"2342\", \"productSummary\": \"12\", \"targetCustomer\": \"23\"}', '{\"strategyNotes\": \"2342423\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 34, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-27 03:45:43', '2026-06-27 03:45:43');

-- ----------------------------
-- Table structure for advisor_product_draft_component
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_draft_component`;
CREATE TABLE `advisor_product_draft_component`  (
                                                    `id` bigint NOT NULL AUTO_INCREMENT,
                                                    `draft_id` bigint NOT NULL COMMENT '草稿ID',
                                                    `fund_id` bigint NOT NULL COMMENT '基金ID',
                                                    `weight` decimal(10, 4) NOT NULL COMMENT '权重，建议0~1',
                                                    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                    PRIMARY KEY (`id`) USING BTREE,
                                                    UNIQUE INDEX `uk_draft_fund`(`draft_id` ASC, `fund_id` ASC) USING BTREE,
                                                    INDEX `idx_draft_component_fund_id`(`fund_id` ASC) USING BTREE,
                                                    CONSTRAINT `fk_draft_component_draft` FOREIGN KEY (`draft_id`) REFERENCES `advisor_product_draft` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                    CONSTRAINT `fk_draft_component_fund` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品草稿成份表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_draft_component
-- ----------------------------
INSERT INTO `advisor_product_draft_component` VALUES (1, 1, 6, 1.0000, '2026-06-23 21:05:07');
INSERT INTO `advisor_product_draft_component` VALUES (2, 2, 23, 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (3, 2, 24, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (4, 2, 29, 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (5, 2, 30, 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (6, 2, 31, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (7, 2, 34, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (8, 2, 35, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (9, 3, 31, 0.3000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_draft_component` VALUES (10, 3, 32, 0.7000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_draft_component` VALUES (14, 4, 31, 0.4000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft_component` VALUES (15, 4, 32, 0.1000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft_component` VALUES (16, 4, 35, 0.5000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft_component` VALUES (17, 5, 23, 0.0100, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (18, 5, 29, 0.0500, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (19, 5, 32, 0.2000, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (20, 5, 34, 0.0600, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (21, 5, 35, 0.6800, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (52, 6, 23, 0.0100, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (53, 6, 29, 0.0500, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (54, 6, 32, 0.2000, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (55, 6, 34, 0.0600, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (56, 6, 35, 0.6800, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (67, 8, 17, 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (68, 8, 18, 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (69, 8, 19, 0.1230, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (70, 8, 20, 0.3442, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (71, 8, 21, 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (72, 8, 22, 0.0200, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (73, 8, 23, 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (74, 8, 24, 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (75, 8, 25, 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (76, 8, 26, 0.0628, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (77, 9, 7, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (78, 9, 8, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (79, 9, 9, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (80, 9, 10, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (81, 9, 11, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (82, 9, 12, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (83, 9, 13, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (84, 9, 14, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (85, 9, 15, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (86, 9, 16, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (87, 7, 27, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (88, 7, 28, 0.0800, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (89, 7, 29, 0.0120, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (90, 7, 30, 0.0010, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (91, 7, 31, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (92, 7, 32, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (93, 7, 33, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (94, 7, 36, 0.5070, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (95, 10, 17, 0.0500, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (96, 10, 18, 0.0500, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (97, 10, 19, 0.1230, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (98, 10, 20, 0.3442, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (99, 10, 21, 0.0500, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (100, 10, 22, 0.0200, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (101, 10, 23, 0.1000, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (102, 10, 24, 0.1000, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (103, 10, 25, 0.1000, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (104, 10, 26, 0.0628, '2026-06-27 03:45:43');

-- ----------------------------
-- Table structure for advisor_product_flow_log
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_flow_log`;
CREATE TABLE `advisor_product_flow_log`  (
                                             `id` bigint NOT NULL AUTO_INCREMENT,
                                             `product_id` bigint NOT NULL,
                                             `product_version_id` bigint NULL DEFAULT NULL,
                                             `operator_id` bigint NOT NULL COMMENT '操作人',
                                             `action_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SAVE_DRAFT/SUBMIT/WITHDRAW/APPROVE/REJECT/PUBLISH/OFFLINE',
                                             `comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
                                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             PRIMARY KEY (`id`) USING BTREE,
                                             INDEX `idx_flow_product`(`product_id` ASC, `action_type` ASC) USING BTREE,
                                             INDEX `idx_flow_version`(`product_version_id` ASC) USING BTREE,
                                             INDEX `idx_flow_operator`(`operator_id` ASC) USING BTREE,
                                             CONSTRAINT `fk_flow_operator` FOREIGN KEY (`operator_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                             CONSTRAINT `fk_flow_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                             CONSTRAINT `fk_flow_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 44 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品流程日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_flow_log
-- ----------------------------
INSERT INTO `advisor_product_flow_log` VALUES (1, 1, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_flow_log` VALUES (2, 1, 1, 3, 'SUBMIT', '提交审核', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_flow_log` VALUES (3, 1, 1, 4, 'APPROVE', '审核通过', '2026-06-23 21:05:35');
INSERT INTO `advisor_product_flow_log` VALUES (4, 2, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_flow_log` VALUES (5, 2, 2, 3, 'SUBMIT', '提交审核', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_flow_log` VALUES (11, 2, 2, 4, 'APPROVE', '审核通过', '2026-06-23 22:54:15');
INSERT INTO `advisor_product_flow_log` VALUES (12, 3, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_flow_log` VALUES (13, 3, 3, 3, 'SUBMIT', '提交审核', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_flow_log` VALUES (14, 3, 3, 4, 'APPROVE', '审核通过', '2026-06-24 23:53:10');
INSERT INTO `advisor_product_flow_log` VALUES (15, 4, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-25 00:32:12');
INSERT INTO `advisor_product_flow_log` VALUES (16, 4, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_flow_log` VALUES (17, 4, 4, 3, 'SUBMIT', '提交审核', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_flow_log` VALUES (18, 4, 4, 4, 'APPROVE', '审核通过', '2026-06-25 00:32:46');
INSERT INTO `advisor_product_flow_log` VALUES (19, 5, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 18:21:57');
INSERT INTO `advisor_product_flow_log` VALUES (20, 9, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 18:23:50');
INSERT INTO `advisor_product_flow_log` VALUES (21, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:29:32');
INSERT INTO `advisor_product_flow_log` VALUES (22, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:32:03');
INSERT INTO `advisor_product_flow_log` VALUES (23, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:32:42');
INSERT INTO `advisor_product_flow_log` VALUES (24, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:37:04');
INSERT INTO `advisor_product_flow_log` VALUES (25, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:37:09');
INSERT INTO `advisor_product_flow_log` VALUES (26, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_flow_log` VALUES (27, 9, 5, 3, 'SUBMIT', '提交审核', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_flow_log` VALUES (28, 9, 5, 4, 'APPROVE', '审核通过', '2026-06-26 20:03:54');
INSERT INTO `advisor_product_flow_log` VALUES (29, 11, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 20:13:19');
INSERT INTO `advisor_product_flow_log` VALUES (30, 11, 6, 3, 'SUBMIT', '提交审核', '2026-06-26 20:13:19');
INSERT INTO `advisor_product_flow_log` VALUES (31, 5, 7, 3, 'SUBMIT', '提交审核', '2026-06-26 21:30:09');
INSERT INTO `advisor_product_flow_log` VALUES (32, 11, 6, 4, 'APPROVE', '审核通过', '2026-06-26 21:30:51');
INSERT INTO `advisor_product_flow_log` VALUES (33, 5, 7, 4, 'REJECT', '权重过高', '2026-06-26 21:31:13');
INSERT INTO `advisor_product_flow_log` VALUES (34, 12, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_flow_log` VALUES (35, 12, 8, 3, 'SUBMIT', '提交审核', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_flow_log` VALUES (36, 13, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 21:59:51');
INSERT INTO `advisor_product_flow_log` VALUES (37, 13, 9, 3, 'SUBMIT', '提交审核', '2026-06-26 21:59:52');
INSERT INTO `advisor_product_flow_log` VALUES (38, 11, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-27 00:46:25');
INSERT INTO `advisor_product_flow_log` VALUES (39, 11, 10, 3, 'SUBMIT', '提交审核', '2026-06-27 00:46:26');
INSERT INTO `advisor_product_flow_log` VALUES (40, 11, 10, 4, 'APPROVE', '审核通过', '2026-06-27 00:46:59');
INSERT INTO `advisor_product_flow_log` VALUES (41, 12, 8, 4, 'APPROVE', '审核通过', '2026-06-27 03:21:46');
INSERT INTO `advisor_product_flow_log` VALUES (42, 14, NULL, 3, 'COPY', '从产品 天弘(ID:12) 复制创建', '2026-06-27 03:45:43');
INSERT INTO `advisor_product_flow_log` VALUES (43, 13, 9, 4, 'APPROVE', '审核通过', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_holding_snapshot
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_holding_snapshot`;
CREATE TABLE `advisor_product_holding_snapshot`  (
                                                     `id` bigint NOT NULL AUTO_INCREMENT,
                                                     `product_id` bigint NOT NULL,
                                                     `snapshot_date` date NOT NULL,
                                                     `holding_json` json NOT NULL COMMENT '持仓快照（行业/资产/Top持仓等）',
                                                     `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                     PRIMARY KEY (`id`) USING BTREE,
                                                     UNIQUE INDEX `uk_holding_product_date`(`product_id` ASC, `snapshot_date` ASC) USING BTREE,
                                                     INDEX `idx_holding_snapshot_date`(`snapshot_date` ASC) USING BTREE,
                                                     CONSTRAINT `fk_holding_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组合持仓快照（可选扩展）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_holding_snapshot
-- ----------------------------
INSERT INTO `advisor_product_holding_snapshot` VALUES (1, 1, '2026-06-23', '{\"components\": [{\"weight\": 1.0000, \"fundCode\": \"519674\", \"fundName\": \"银河创新成长混合\"}]}', '2026-06-23 23:00:23');
INSERT INTO `advisor_product_holding_snapshot` VALUES (2, 2, '2026-06-23', '{\"components\": [{\"weight\": 0.2000, \"fundCode\": \"159915\", \"fundName\": \"易方达创业板ETF\"}, {\"weight\": 0.1000, \"fundCode\": \"510300\", \"fundName\": \"华泰柏瑞沪深300ETF\"}, {\"weight\": 0.2000, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.2000, \"fundCode\": \"000452\", \"fundName\": \"南方医药保健灵活配置混合\"}, {\"weight\": 0.1000, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1000, \"fundCode\": \"518880\", \"fundName\": \"华安黄金ETF\"}, {\"weight\": 0.1000, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}]}', '2026-06-23 23:00:23');
INSERT INTO `advisor_product_holding_snapshot` VALUES (3, 3, '2026-06-24', '{\"components\": [{\"weight\": 0.3, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.7, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}]}', '2026-06-24 23:53:10');
INSERT INTO `advisor_product_holding_snapshot` VALUES (4, 4, '2026-06-25', '{\"components\": [{\"weight\": 0.4, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.5, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}]}', '2026-06-25 00:32:46');
INSERT INTO `advisor_product_holding_snapshot` VALUES (5, 9, '2026-06-26', '{\"components\": [{\"weight\": 0.01, \"fundCode\": \"159915\", \"fundName\": \"易方达创业板ETF\"}, {\"weight\": 0.05, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.2, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.06, \"fundCode\": \"518880\", \"fundName\": \"华安黄金ETF\"}, {\"weight\": 0.68, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}]}', '2026-06-26 20:03:54');
INSERT INTO `advisor_product_holding_snapshot` VALUES (6, 11, '2026-06-26', '{\"components\": [{\"weight\": 0.1, \"fundCode\": \"320007\", \"fundName\": \"诺安成长混合\"}, {\"weight\": 0.08, \"fundCode\": \"260108\", \"fundName\": \"景顺长城新兴成长混合\"}, {\"weight\": 0.012, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.001, \"fundCode\": \"000452\", \"fundName\": \"南方医药保健灵活配置混合\"}, {\"weight\": 0.1, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.1, \"fundCode\": \"000307\", \"fundName\": \"易方达黄金ETF联接A\"}, {\"weight\": 0.1, \"fundCode\": \"518880\", \"fundName\": \"华安黄金ETF\"}, {\"weight\": 0.3, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}, {\"weight\": 0.107, \"fundCode\": \"398011\", \"fundName\": \"中海分红增利混合\"}]}', '2026-06-26 21:30:51');
INSERT INTO `advisor_product_holding_snapshot` VALUES (7, 11, '2026-06-27', '{\"components\": [{\"weight\": 0.1, \"fundCode\": \"320007\", \"fundName\": \"诺安成长混合\"}, {\"weight\": 0.08, \"fundCode\": \"260108\", \"fundName\": \"景顺长城新兴成长混合\"}, {\"weight\": 0.012, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.001, \"fundCode\": \"000452\", \"fundName\": \"南方医药保健灵活配置混合\"}, {\"weight\": 0.1, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.1, \"fundCode\": \"000307\", \"fundName\": \"易方达黄金ETF联接A\"}, {\"weight\": 0.507, \"fundCode\": \"398011\", \"fundName\": \"中海分红增利混合\"}]}', '2026-06-27 00:46:59');
INSERT INTO `advisor_product_holding_snapshot` VALUES (8, 12, '2026-06-27', '{\"components\": [{\"weight\": 0.05, \"fundCode\": \"001838\", \"fundName\": \"国投瑞银国家安全混合\"}, {\"weight\": 0.05, \"fundCode\": \"003096\", \"fundName\": \"中欧医疗创新股票A\"}, {\"weight\": 0.123, \"fundCode\": \"001717\", \"fundName\": \"工银前沿医疗股票A\"}, {\"weight\": 0.3442, \"fundCode\": \"110011\", \"fundName\": \"易方达中小盘混合\"}, {\"weight\": 0.05, \"fundCode\": \"519696\", \"fundName\": \"交银环球精选混合(QDII)\"}, {\"weight\": 0.02, \"fundCode\": \"161039\", \"fundName\": \"富国中证1000指数增强\"}, {\"weight\": 0.1, \"fundCode\": \"159915\", \"fundName\": \"易方达创业板ETF\"}, {\"weight\": 0.1, \"fundCode\": \"510300\", \"fundName\": \"华泰柏瑞沪深300ETF\"}, {\"weight\": 0.1, \"fundCode\": \"512690\", \"fundName\": \"鹏华中证酒ETF\"}, {\"weight\": 0.0628, \"fundCode\": \"515790\", \"fundName\": \"华夏中证新能源ETF\"}]}', '2026-06-27 03:21:46');
INSERT INTO `advisor_product_holding_snapshot` VALUES (9, 13, '2026-06-27', '{\"components\": [{\"weight\": 0.1, \"fundCode\": \"001632\", \"fundName\": \"天弘中证食品饮料ETF联接A\"}, {\"weight\": 0.1, \"fundCode\": \"005827\", \"fundName\": \"易方达蓝筹精选混合\"}, {\"weight\": 0.1, \"fundCode\": \"006113\", \"fundName\": \"汇添富创新医药混合\"}, {\"weight\": 0.1, \"fundCode\": \"000248\", \"fundName\": \"汇添富中证主要消费ETF联接\"}, {\"weight\": 0.1, \"fundCode\": \"001875\", \"fundName\": \"前海开源沪港深优势精选混合\"}, {\"weight\": 0.1, \"fundCode\": \"002190\", \"fundName\": \"农银新能源主题灵活配置混合\"}, {\"weight\": 0.1, \"fundCode\": \"004851\", \"fundName\": \"广发医疗保健股票A\"}, {\"weight\": 0.1, \"fundCode\": \"000960\", \"fundName\": \"招商医药健康产业股票\"}, {\"weight\": 0.1, \"fundCode\": \"001071\", \"fundName\": \"华夏恒生ETF联接A\"}, {\"weight\": 0.1, \"fundCode\": \"006479\", \"fundName\": \"中欧智能制造混合A\"}]}', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_nav
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_nav`;
CREATE TABLE `advisor_product_nav`  (
                                        `id` bigint NOT NULL AUTO_INCREMENT,
                                        `product_id` bigint NOT NULL,
                                        `nav_date` date NOT NULL,
                                        `nav` decimal(18, 8) NOT NULL COMMENT '单位净值',
                                        `cum_return` decimal(18, 8) NULL DEFAULT NULL COMMENT '累计收益（可选）',
                                        `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                        PRIMARY KEY (`id`) USING BTREE,
                                        UNIQUE INDEX `uk_nav_product_date`(`product_id` ASC, `nav_date` ASC) USING BTREE,
                                        INDEX `idx_nav_date`(`nav_date` ASC) USING BTREE,
                                        CONSTRAINT `fk_nav_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 241 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组合收益/净值' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_nav
-- ----------------------------
INSERT INTO `advisor_product_nav` VALUES (1, 2, '2026-05-25', 1.00000000, 0.00000000, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (2, 2, '2026-05-26', 1.00118516, 0.00118516, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (3, 2, '2026-05-27', 1.00258388, 0.00258388, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (4, 2, '2026-05-28', 1.00397708, 0.00397708, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (5, 2, '2026-05-29', 1.00498509, 0.00498509, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (6, 2, '2026-05-30', 1.00606604, 0.00606604, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (7, 2, '2026-05-31', 1.00725120, 0.00725120, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (8, 2, '2026-06-01', 1.00864992, 0.00864992, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (9, 2, '2026-06-02', 1.01004312, 0.01004312, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (10, 2, '2026-06-03', 1.01105112, 0.01105112, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (11, 2, '2026-06-04', 1.01213208, 0.01213208, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (12, 2, '2026-06-05', 1.01331723, 0.01331723, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (13, 2, '2026-06-06', 1.01471596, 0.01471596, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (14, 2, '2026-06-07', 1.01610915, 0.01610915, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (15, 2, '2026-06-08', 1.01711716, 0.01711716, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (16, 2, '2026-06-09', 1.01819811, 0.01819811, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (17, 2, '2026-06-10', 1.01938327, 0.01938327, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (18, 2, '2026-06-11', 1.02078199, 0.02078199, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (19, 2, '2026-06-12', 1.02217519, 0.02217519, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (20, 2, '2026-06-13', 1.02318320, 0.02318320, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (21, 2, '2026-06-14', 1.02426415, 0.02426415, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (22, 2, '2026-06-15', 1.02544931, 0.02544931, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (23, 2, '2026-06-16', 1.02684803, 0.02684803, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (24, 2, '2026-06-17', 1.02824123, 0.02824123, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (25, 2, '2026-06-18', 1.02924924, 0.02924924, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (26, 2, '2026-06-19', 1.03033019, 0.03033019, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (27, 2, '2026-06-20', 1.03151535, 0.03151535, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (28, 2, '2026-06-21', 1.03291407, 0.03291407, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (29, 2, '2026-06-22', 1.03430727, 0.03430727, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (30, 2, '2026-06-23', 1.03531528, 0.03531528, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (31, 3, '2026-05-25', 1.00000000, 0.00000000, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (32, 3, '2026-05-26', 1.00056962, 0.00056962, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (33, 3, '2026-05-27', 1.00232265, 0.00232265, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (34, 3, '2026-05-28', 1.00293152, 0.00293152, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (35, 3, '2026-05-29', 1.00424261, 0.00424261, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (36, 3, '2026-05-30', 1.00601527, 0.00601527, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (37, 3, '2026-05-31', 1.00658489, 0.00658489, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (38, 3, '2026-06-01', 1.00833792, 0.00833792, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (39, 3, '2026-06-02', 1.00894679, 0.00894679, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (40, 3, '2026-06-03', 1.01025788, 0.01025788, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (41, 3, '2026-06-04', 1.01203054, 0.01203054, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (42, 3, '2026-06-05', 1.01260016, 0.01260016, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (43, 3, '2026-06-06', 1.01435319, 0.01435319, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (44, 3, '2026-06-07', 1.01496206, 0.01496206, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (45, 3, '2026-06-08', 1.01627315, 0.01627315, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (46, 3, '2026-06-09', 1.01804581, 0.01804581, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (47, 3, '2026-06-10', 1.01861543, 0.01861543, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (48, 3, '2026-06-11', 1.02036846, 0.02036846, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (49, 3, '2026-06-12', 1.02097733, 0.02097733, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (50, 3, '2026-06-13', 1.02228843, 0.02228843, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (51, 3, '2026-06-14', 1.02406109, 0.02406109, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (52, 3, '2026-06-15', 1.02463071, 0.02463071, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (53, 3, '2026-06-16', 1.02638373, 0.02638373, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (54, 3, '2026-06-17', 1.02699261, 0.02699261, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (55, 3, '2026-06-18', 1.02830370, 0.02830370, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (56, 3, '2026-06-19', 1.03007636, 0.03007636, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (57, 3, '2026-06-20', 1.03064598, 0.03064598, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (58, 3, '2026-06-21', 1.03239901, 0.03239901, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (59, 3, '2026-06-22', 1.03300788, 0.03300788, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (60, 3, '2026-06-23', 1.03431897, 0.03431897, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (61, 4, '2026-05-25', 1.00000000, 0.00000000, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (62, 4, '2026-05-26', 1.00100675, 0.00100675, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (63, 4, '2026-05-27', 1.00219721, 0.00219721, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (64, 4, '2026-05-28', 1.00383766, 0.00383766, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (65, 4, '2026-05-29', 1.00436337, 0.00436337, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (66, 4, '2026-05-30', 1.00605698, 0.00605698, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (67, 4, '2026-05-31', 1.00706373, 0.00706373, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (68, 4, '2026-06-01', 1.00825419, 0.00825419, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (69, 4, '2026-06-02', 1.00989464, 0.00989464, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (70, 4, '2026-06-03', 1.01042035, 0.01042035, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (71, 4, '2026-06-04', 1.01211396, 0.01211396, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (72, 4, '2026-06-05', 1.01312070, 0.01312070, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (73, 4, '2026-06-06', 1.01431117, 0.01431117, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (74, 4, '2026-06-07', 1.01595161, 0.01595161, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (75, 4, '2026-06-08', 1.01647733, 0.01647733, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (76, 4, '2026-06-09', 1.01817093, 0.01817093, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (77, 4, '2026-06-10', 1.01917768, 0.01917768, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (78, 4, '2026-06-11', 1.02036815, 0.02036815, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (79, 4, '2026-06-12', 1.02200859, 0.02200859, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (80, 4, '2026-06-13', 1.02253431, 0.02253431, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (81, 4, '2026-06-14', 1.02422792, 0.02422792, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (82, 4, '2026-06-15', 1.02523466, 0.02523466, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (83, 4, '2026-06-16', 1.02642513, 0.02642513, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (84, 4, '2026-06-17', 1.02806557, 0.02806557, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (85, 4, '2026-06-18', 1.02859129, 0.02859129, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (86, 4, '2026-06-19', 1.03028489, 0.03028489, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (87, 4, '2026-06-20', 1.03129164, 0.03129164, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (88, 4, '2026-06-21', 1.03248211, 0.03248211, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (89, 4, '2026-06-22', 1.03412255, 0.03412255, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (90, 4, '2026-06-23', 1.03464827, 0.03464827, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (91, 9, '2026-05-25', 1.00000000, 0.00000000, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (92, 9, '2026-05-26', 1.00144580, 0.00144580, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (93, 9, '2026-05-27', 1.00252174, 0.00252174, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (94, 9, '2026-05-28', 1.00393457, 0.00393457, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (95, 9, '2026-05-29', 1.00448200, 0.00448200, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (96, 9, '2026-05-30', 1.00597806, 0.00597806, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (97, 9, '2026-05-31', 1.00742387, 0.00742387, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (98, 9, '2026-06-01', 1.00849981, 0.00849981, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (99, 9, '2026-06-02', 1.00991264, 0.00991264, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (100, 9, '2026-06-03', 1.01046007, 0.01046007, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (101, 9, '2026-06-04', 1.01195613, 0.01195613, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (102, 9, '2026-06-05', 1.01340193, 0.01340193, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (103, 9, '2026-06-06', 1.01447787, 0.01447787, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (104, 9, '2026-06-07', 1.01589070, 0.01589070, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (105, 9, '2026-06-08', 1.01643813, 0.01643813, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (106, 9, '2026-06-09', 1.01793419, 0.01793419, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (107, 9, '2026-06-10', 1.01938000, 0.01938000, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (108, 9, '2026-06-11', 1.02045594, 0.02045594, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (109, 9, '2026-06-12', 1.02186876, 0.02186876, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (110, 9, '2026-06-13', 1.02241620, 0.02241620, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (111, 9, '2026-06-14', 1.02391226, 0.02391226, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (112, 9, '2026-06-15', 1.02535806, 0.02535806, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (113, 9, '2026-06-16', 1.02643400, 0.02643400, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (114, 9, '2026-06-17', 1.02784683, 0.02784683, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (115, 9, '2026-06-18', 1.02839426, 0.02839426, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (116, 9, '2026-06-19', 1.02989032, 0.02989032, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (117, 9, '2026-06-20', 1.03133613, 0.03133613, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (118, 9, '2026-06-21', 1.03241207, 0.03241207, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (119, 9, '2026-06-22', 1.03382490, 0.03382490, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (120, 9, '2026-06-23', 1.03437233, 0.03437233, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (151, 11, '2026-05-25', 1.00000000, 0.00000000, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (152, 11, '2026-05-26', 1.00078884, 0.00078884, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (153, 11, '2026-05-27', 1.00256664, 0.00256664, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (154, 11, '2026-05-28', 1.00317305, 0.00317305, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (155, 11, '2026-05-29', 1.00462321, 0.00462321, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (156, 11, '2026-05-30', 1.00611126, 0.00611126, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (157, 11, '2026-05-31', 1.00690010, 0.00690010, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (158, 11, '2026-06-01', 1.00867789, 0.00867789, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (159, 11, '2026-06-02', 1.00928430, 0.00928430, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (160, 11, '2026-06-03', 1.01073447, 0.01073447, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (161, 11, '2026-06-04', 1.01222252, 0.01222252, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (162, 11, '2026-06-05', 1.01301136, 0.01301136, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (163, 11, '2026-06-06', 1.01478916, 0.01478916, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (164, 11, '2026-06-07', 1.01539556, 0.01539556, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (165, 11, '2026-06-08', 1.01684573, 0.01684573, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (166, 11, '2026-06-09', 1.01833377, 0.01833377, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (167, 11, '2026-06-10', 1.01912262, 0.01912262, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (168, 11, '2026-06-11', 1.02090041, 0.02090041, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (169, 11, '2026-06-12', 1.02150682, 0.02150682, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (170, 11, '2026-06-13', 1.02295698, 0.02295698, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (171, 11, '2026-06-14', 1.02444503, 0.02444503, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (172, 11, '2026-06-15', 1.02523388, 0.02523388, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (173, 11, '2026-06-16', 1.02701167, 0.02701167, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (174, 11, '2026-06-17', 1.02761808, 0.02761808, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (175, 11, '2026-06-18', 1.02906824, 0.02906824, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (176, 11, '2026-06-19', 1.03055629, 0.03055629, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (177, 11, '2026-06-20', 1.03134513, 0.03134513, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (178, 11, '2026-06-21', 1.03312293, 0.03312293, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (179, 11, '2026-06-22', 1.03372934, 0.03372934, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (180, 11, '2026-06-23', 1.03517950, 0.03517950, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (181, 12, '2026-05-25', 1.00000000, 0.00000000, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (182, 12, '2026-05-26', 1.00166693, 0.00166693, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (183, 12, '2026-05-27', 1.00239198, 0.00239198, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (184, 12, '2026-05-28', 1.00371365, 0.00371365, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (185, 12, '2026-05-29', 1.00525453, 0.00525453, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (186, 12, '2026-05-30', 1.00602931, 0.00602931, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (187, 12, '2026-05-31', 1.00769624, 0.00769624, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (188, 12, '2026-06-01', 1.00842130, 0.00842130, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (189, 12, '2026-06-02', 1.00974296, 0.00974296, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (190, 12, '2026-06-03', 1.01128384, 0.01128384, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (191, 12, '2026-06-04', 1.01205862, 0.01205862, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (192, 12, '2026-06-05', 1.01372555, 0.01372555, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (193, 12, '2026-06-06', 1.01445061, 0.01445061, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (194, 12, '2026-06-07', 1.01577228, 0.01577228, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (195, 12, '2026-06-08', 1.01731315, 0.01731315, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (196, 12, '2026-06-09', 1.01808793, 0.01808793, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (197, 12, '2026-06-10', 1.01975486, 0.01975486, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (198, 12, '2026-06-11', 1.02047992, 0.02047992, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (199, 12, '2026-06-12', 1.02180159, 0.02180159, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (200, 12, '2026-06-13', 1.02334246, 0.02334246, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (201, 12, '2026-06-14', 1.02411725, 0.02411725, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (202, 12, '2026-06-15', 1.02578417, 0.02578417, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (203, 12, '2026-06-16', 1.02650923, 0.02650923, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (204, 12, '2026-06-17', 1.02783090, 0.02783090, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (205, 12, '2026-06-18', 1.02937177, 0.02937177, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (206, 12, '2026-06-19', 1.03014656, 0.03014656, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (207, 12, '2026-06-20', 1.03181348, 0.03181348, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (208, 12, '2026-06-21', 1.03253854, 0.03253854, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (209, 12, '2026-06-22', 1.03386021, 0.03386021, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (210, 12, '2026-06-23', 1.03540108, 0.03540108, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (211, 13, '2026-05-25', 1.00000000, 0.00000000, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (212, 13, '2026-05-26', 1.00113051, 0.00113051, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (213, 13, '2026-05-27', 1.00194102, 0.00194102, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (214, 13, '2026-05-28', 1.00361134, 0.00361134, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (215, 13, '2026-05-29', 1.00463860, 0.00463860, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (216, 13, '2026-05-30', 1.00597469, 0.00597469, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (217, 13, '2026-05-31', 1.00710520, 0.00710520, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (218, 13, '2026-06-01', 1.00791572, 0.00791572, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (219, 13, '2026-06-02', 1.00958603, 0.00958603, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (220, 13, '2026-06-03', 1.01061329, 0.01061329, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (221, 13, '2026-06-04', 1.01194939, 0.01194939, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (222, 13, '2026-06-05', 1.01307990, 0.01307990, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (223, 13, '2026-06-06', 1.01389041, 0.01389041, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (224, 13, '2026-06-07', 1.01556072, 0.01556072, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (225, 13, '2026-06-08', 1.01658798, 0.01658798, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (226, 13, '2026-06-09', 1.01792408, 0.01792408, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (227, 13, '2026-06-10', 1.01905459, 0.01905459, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (228, 13, '2026-06-11', 1.01986510, 0.01986510, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (229, 13, '2026-06-12', 1.02153542, 0.02153542, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (230, 13, '2026-06-13', 1.02256268, 0.02256268, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (231, 13, '2026-06-14', 1.02389877, 0.02389877, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (232, 13, '2026-06-15', 1.02502928, 0.02502928, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (233, 13, '2026-06-16', 1.02583979, 0.02583979, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (234, 13, '2026-06-17', 1.02751011, 0.02751011, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (235, 13, '2026-06-18', 1.02853737, 0.02853737, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (236, 13, '2026-06-19', 1.02987347, 0.02987347, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (237, 13, '2026-06-20', 1.03100398, 0.03100398, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (238, 13, '2026-06-21', 1.03181449, 0.03181449, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (239, 13, '2026-06-22', 1.03348480, 0.03348480, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (240, 13, '2026-06-23', 1.03451206, 0.03451206, '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_review
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_review`;
CREATE TABLE `advisor_product_review`  (
                                           `id` bigint NOT NULL AUTO_INCREMENT,
                                           `product_id` bigint NOT NULL,
                                           `product_version_id` bigint NOT NULL,
                                           `reviewer_id` bigint NOT NULL,
                                           `result` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'APPROVED/REJECTED',
                                           `comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核意见/驳回原因',
                                           `reviewed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                           PRIMARY KEY (`id`) USING BTREE,
                                           INDEX `idx_review_product`(`product_id` ASC) USING BTREE,
                                           INDEX `idx_review_version`(`product_version_id` ASC) USING BTREE,
                                           INDEX `idx_review_reviewer`(`reviewer_id` ASC) USING BTREE,
                                           INDEX `idx_review_time`(`reviewed_at` ASC) USING BTREE,
                                           CONSTRAINT `fk_review_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                           CONSTRAINT `fk_review_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                           CONSTRAINT `fk_review_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品审核记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_review
-- ----------------------------
INSERT INTO `advisor_product_review` VALUES (1, 1, 1, 4, 'APPROVED', '审核通过', '2026-06-23 21:05:35');
INSERT INTO `advisor_product_review` VALUES (7, 2, 2, 4, 'APPROVED', '审核通过', '2026-06-23 22:54:15');
INSERT INTO `advisor_product_review` VALUES (8, 3, 3, 4, 'APPROVED', '审核通过', '2026-06-24 23:53:10');
INSERT INTO `advisor_product_review` VALUES (9, 4, 4, 4, 'APPROVED', '审核通过', '2026-06-25 00:32:46');
INSERT INTO `advisor_product_review` VALUES (10, 9, 5, 4, 'APPROVED', '审核通过', '2026-06-26 20:03:54');
INSERT INTO `advisor_product_review` VALUES (11, 11, 6, 4, 'APPROVED', '审核通过', '2026-06-26 21:30:51');
INSERT INTO `advisor_product_review` VALUES (12, 5, 7, 4, 'REJECTED', '权重过高', '2026-06-26 21:31:13');
INSERT INTO `advisor_product_review` VALUES (13, 11, 10, 4, 'APPROVED', '审核通过', '2026-06-27 00:46:59');
INSERT INTO `advisor_product_review` VALUES (14, 12, 8, 4, 'APPROVED', '审核通过', '2026-06-27 03:21:46');
INSERT INTO `advisor_product_review` VALUES (15, 13, 9, 4, 'APPROVED', '审核通过', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_rule_decision
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_rule_decision`;
CREATE TABLE `advisor_product_rule_decision`  (
                                                  `id` bigint NOT NULL AUTO_INCREMENT,
                                                  `product_id` bigint NOT NULL,
                                                  `product_version_id` bigint NOT NULL,
                                                  `base_rule_id` bigint NOT NULL COMMENT '引用的默认规则ID',
                                                  `reviewer_id` bigint NOT NULL,
                                                  `override_min_fund_count` int NULL DEFAULT NULL COMMENT '审核覆盖：最少成份数（可空）',
                                                  `override_max_fund_count` int NULL DEFAULT NULL COMMENT '审核覆盖：最多成份数（可空）',
                                                  `override_max_single_weight` decimal(10, 4) NULL DEFAULT NULL COMMENT '审核覆盖：单基金最大权重（可空）',
                                                  `final_rule_json` json NOT NULL COMMENT '最终规则快照（默认规则+覆盖后的固化结果）',
                                                  `decision_comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '调整原因/说明',
                                                  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                  PRIMARY KEY (`id`) USING BTREE,
                                                  UNIQUE INDEX `uk_rule_decision_version`(`product_version_id` ASC) USING BTREE,
                                                  INDEX `idx_rule_decision_product`(`product_id` ASC) USING BTREE,
                                                  INDEX `fk_rule_decision_rule`(`base_rule_id` ASC) USING BTREE,
                                                  INDEX `fk_rule_decision_reviewer`(`reviewer_id` ASC) USING BTREE,
                                                  CONSTRAINT `fk_rule_decision_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                  CONSTRAINT `fk_rule_decision_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                  CONSTRAINT `fk_rule_decision_rule` FOREIGN KEY (`base_rule_id`) REFERENCES `advisor_strategy_rule` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                  CONSTRAINT `fk_rule_decision_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '投决会规则调整决议（按版本留痕）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_rule_decision
-- ----------------------------

-- ----------------------------
-- Table structure for advisor_product_subscription
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_subscription`;
CREATE TABLE `advisor_product_subscription`  (
                                                 `id` bigint NOT NULL AUTO_INCREMENT,
                                                 `product_id` bigint NOT NULL,
                                                 `user_id` bigint NOT NULL,
                                                 `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/CANCELLED',
                                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                                 `invest_amount` decimal(16, 2) NULL DEFAULT 0.00 COMMENT '投入金额',
                                                 `current_value` decimal(16, 2) NULL DEFAULT 0.00 COMMENT '当前市值',
                                                 PRIMARY KEY (`id`) USING BTREE,
                                                 UNIQUE INDEX `uk_sub_user_product`(`user_id` ASC, `product_id` ASC) USING BTREE,
                                                 INDEX `idx_sub_product`(`product_id` ASC) USING BTREE,
                                                 INDEX `idx_sub_user`(`user_id` ASC) USING BTREE,
                                                 CONSTRAINT `fk_sub_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                 CONSTRAINT `fk_sub_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组合订阅记录（最小闭环）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_subscription
-- ----------------------------
INSERT INTO `advisor_product_subscription` VALUES (1, 1, 2, 'ACTIVE', '2026-06-23 21:33:27', '2026-06-23 21:33:27', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (2, 2, 2, 'ACTIVE', '2026-06-24 23:14:11', '2026-06-24 23:14:11', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (3, 9, 2, 'ACTIVE', '2026-06-27 00:39:34', '2026-06-27 00:39:34', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (4, 11, 2, 'ACTIVE', '2026-06-27 00:47:33', '2026-06-27 00:47:33', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (5, 12, 2, 'ACTIVE', '2026-06-27 03:56:12', '2026-06-27 03:56:12', 10000.00, 10000.00);
INSERT INTO `advisor_product_subscription` VALUES (6, 3, 2, 'ACTIVE', '2026-06-27 04:07:27', '2026-06-27 15:00:34', 9000.00, 9000.00);

-- ----------------------------
-- Table structure for advisor_product_version
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_version`;
CREATE TABLE `advisor_product_version`  (
                                            `id` bigint NOT NULL AUTO_INCREMENT,
                                            `product_id` bigint NOT NULL,
                                            `version_no` int NOT NULL COMMENT '版本号（从1开始递增）',
                                            `base_info_json` json NOT NULL COMMENT '基础信息快照（名称/风险/标签/介绍等）',
                                            `params_json` json NULL COMMENT '策略/产品参数快照',
                                            `version_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'SUBMITTED' COMMENT 'SUBMITTED/APPROVED/REJECTED/WITHDRAWN',
                                            `change_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'NORMAL/MAJOR',
                                            `base_version_id` bigint NULL DEFAULT NULL COMMENT '对比基线版本ID',
                                            `version_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '版本更新说明',
                                            `status_at_submit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提交时产品状态（可选）',
                                            `submitted_at` datetime NULL DEFAULT NULL COMMENT '提交审核时间',
                                            `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                            PRIMARY KEY (`id`) USING BTREE,
                                            UNIQUE INDEX `uk_product_version`(`product_id` ASC, `version_no` ASC) USING BTREE,
                                            INDEX `idx_version_product`(`product_id` ASC) USING BTREE,
                                            INDEX `idx_version_submitted_at`(`submitted_at` ASC) USING BTREE,
                                            INDEX `idx_version_product_status`(`product_id` ASC, `version_status` ASC) USING BTREE,
                                            CONSTRAINT `fk_version_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品版本快照表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_version
-- ----------------------------
INSERT INTO `advisor_product_version` VALUES (1, 1, 1, '{\"name\": \"天弘全球新能源\", \"type\": \"进取型\", \"riskTips\": \"111\", \"riskLevel\": \"R5\", \"featureTags\": [\"固收增强\"], \"strategyCode\": \"11\", \"productSummary\": \"11\", \"targetCustomer\": \"111\"}', '{\"strategyNotes\": \"11111\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-23 21:05:08', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_version` VALUES (2, 2, 1, '{\"name\": \"1\", \"type\": \"平衡型\", \"riskTips\": \"2\", \"riskLevel\": \"R3\", \"featureTags\": [\"长期持有\"], \"strategyCode\": \"2\", \"productSummary\": \"2\", \"targetCustomer\": \"2\"}', '{\"strategyNotes\": \"222\", \"rebalanceCycleDays\": 3, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.06}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-23 22:45:38', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_version` VALUES (3, 3, 1, '{\"name\": \"2\", \"type\": \"平衡型\", \"riskTips\": \"1\", \"riskLevel\": \"R4\", \"featureTags\": [\"权益增强\"], \"strategyCode\": \"3\", \"productSummary\": \"1\", \"targetCustomer\": \"1\"}', '{\"strategyNotes\": \"1\", \"rebalanceCycleDays\": 2, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-24 20:22:35', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_version` VALUES (4, 4, 1, '{\"name\": \"平安保险\", \"type\": \"FOF\", \"riskTips\": \"低风险\", \"riskLevel\": \"R3\", \"featureTags\": [\"低波动\"], \"strategyCode\": \"4\", \"productSummary\": \"养老保险\", \"targetCustomer\": \"老年人\"}', '{\"strategyNotes\": \"无\", \"rebalanceCycleDays\": 4, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.1}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-25 00:32:16', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_version` VALUES (5, 9, 1, '{\"name\": \"英伟达\", \"type\": \"FOF\", \"riskTips\": \"223让人\", \"riskLevel\": \"R1\", \"featureTags\": [\"权益增强\"], \"strategyCode\": \"11\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 18:37:39', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_version` VALUES (6, 11, 1, '{\"name\": \"大成\", \"type\": \"STRATEGY\", \"riskTips\": \"12321313\", \"riskLevel\": \"R5\", \"featureTags\": [\"固收增强\"], \"strategyCode\": \"12\", \"productSummary\": \"2313131\", \"targetCustomer\": \"131213饿\"}', '{\"strategyNotes\": \"1212112\", \"rebalanceCycleDays\": 142, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 20:13:20', '2026-06-26 20:13:19');
INSERT INTO `advisor_product_version` VALUES (7, 5, 1, '{\"name\": \"国泰\", \"type\": \"STRATEGY\", \"riskTips\": \"223让人\", \"riskLevel\": \"R1\", \"featureTags\": [\"权益增强\"], \"strategyCode\": \"12\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'REJECTED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 21:30:10', '2026-06-26 21:30:09');
INSERT INTO `advisor_product_version` VALUES (8, 12, 1, '{\"name\": \"天弘\", \"type\": \"FOF\", \"riskTips\": \"2342\", \"riskLevel\": \"R2\", \"featureTags\": [\"固收增强\", \"养老规划\"], \"strategyCode\": \"33\", \"productSummary\": \"12\", \"targetCustomer\": \"23\"}', '{\"strategyNotes\": \"2342423\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 34, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 21:53:48', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_version` VALUES (9, 13, 1, '{\"name\": \"德邦\", \"type\": \"FOF\", \"riskTips\": \"1234\", \"riskLevel\": \"R4\", \"featureTags\": [\"长期持有\"], \"strategyCode\": \"55\", \"productSummary\": \"去11\", \"targetCustomer\": \"564\"}', '{\"strategyNotes\": \"1313\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 120, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 21:59:52', '2026-06-26 21:59:52');
INSERT INTO `advisor_product_version` VALUES (10, 11, 2, '{\"name\": \"大成\", \"type\": \"STRATEGY\", \"riskTips\": \"12321313\", \"riskLevel\": \"R5\", \"featureTags\": [\"固收增强\"], \"strategyCode\": \"12\", \"productSummary\": \"2313131\", \"targetCustomer\": \"131213饿\"}', '{\"strategyNotes\": \"1212112\", \"rebalanceCycleDays\": 142, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', 6, '无重大变更', 'PUBLISHED', '2026-06-27 00:46:26', '2026-06-27 00:46:26');

-- ----------------------------
-- Table structure for advisor_strategy_rule
-- ----------------------------
DROP TABLE IF EXISTS `advisor_strategy_rule`;
CREATE TABLE `advisor_strategy_rule`  (
                                          `id` bigint NOT NULL AUTO_INCREMENT,
                                          `strategy_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '策略编码（advisor_product.strategy_code）',
                                          `product_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'STRATEGY/FOF',
                                          `min_fund_count` int NOT NULL COMMENT '最少成份数',
                                          `max_fund_count` int NOT NULL COMMENT '最多成份数',
                                          `min_single_weight` decimal(10, 4) NOT NULL COMMENT '单基金最小权重（0~1）',
                                          `max_single_weight` decimal(10, 4) NOT NULL COMMENT '单基金最大权重（0~1）',
                                          `allow_fund_types` json NULL COMMENT '允许基金类型（JSON数组），为空表示不限制',
                                          `risk_rule_mode` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '风险匹配规则',
                                          `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
                                          `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                          `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                          PRIMARY KEY (`id`) USING BTREE,
                                          UNIQUE INDEX `uk_strategy_rule`(`strategy_code` ASC, `product_type` ASC) USING BTREE,
                                          INDEX `idx_rule_type_status`(`product_type` ASC, `status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '策略/产品参数约束规则（平台默认）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_strategy_rule
-- ----------------------------
INSERT INTO `advisor_strategy_rule` VALUES (1, 'FOF_STABLE', 'FOF', 5, 20, 0.0200, 0.3000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');
INSERT INTO `advisor_strategy_rule` VALUES (2, 'BALANCE_ALPHA', 'STRATEGY', 3, 12, 0.0500, 0.5000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');
INSERT INTO `advisor_strategy_rule` VALUES (3, 'GROWTH_ATTACK', 'STRATEGY', 3, 10, 0.0500, 0.6000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');
INSERT INTO `advisor_strategy_rule` VALUES (4, 'THEME_MEDICAL', 'STRATEGY', 2, 8, 0.0500, 0.7000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');

-- ----------------------------
-- Table structure for fund_info
-- ----------------------------
DROP TABLE IF EXISTS `fund_info`;
CREATE TABLE `fund_info`  (
                              `id` bigint NOT NULL AUTO_INCREMENT,
                              `fund_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金代码',
                              `fund_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金名称',
                              `fund_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '基金类型',
                              `risk_level` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '风险等级',
                              `company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '基金公司',
                              `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
                              `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                              PRIMARY KEY (`id`) USING BTREE,
                              UNIQUE INDEX `uk_fund_code`(`fund_code` ASC) USING BTREE,
                              INDEX `idx_fund_name`(`fund_name` ASC) USING BTREE,
                              INDEX `idx_fund_type_status`(`fund_type` ASC, `status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金基础信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_info
-- ----------------------------
INSERT INTO `fund_info` VALUES (1, '110022', '易方达消费行业股票', '股票型', 'R4', '易方达基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (2, '003095', '中欧医疗健康混合', '混合型', 'R4', '中欧基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (3, '161725', '招商中证白酒指数', '指数型', 'R5', '招商基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (4, '000001', '华夏成长混合', '混合型', 'R3', '华夏基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (5, '002021', '国泰金牛创新成长混合', '混合型', 'R3', '国泰基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (6, '519674', '银河创新成长混合', '混合型', 'R4', '银河基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (7, '001632', '天弘中证食品饮料ETF联接A', '指数型', 'R4', '天弘基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (8, '005827', '易方达蓝筹精选混合', '混合型', 'R4', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (9, '006113', '汇添富创新医药混合', '混合型', 'R4', '汇添富基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (10, '000248', '汇添富中证主要消费ETF联接', '指数型', 'R4', '汇添富基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (11, '001875', '前海开源沪港深优势精选混合', '混合型', 'R4', '前海开源基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (12, '002190', '农银新能源主题灵活配置混合', '混合型', 'R4', '农银汇理基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (13, '004851', '广发医疗保健股票A', '股票型', 'R4', '广发基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (14, '000960', '招商医药健康产业股票', '股票型', 'R4', '招商基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (15, '001071', '华夏恒生ETF联接A', 'QDII', 'R4', '华夏基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (16, '006479', '中欧智能制造混合A', '混合型', 'R4', '中欧基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (17, '001838', '国投瑞银国家安全混合', '混合型', 'R4', '国投瑞银基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (18, '003096', '中欧医疗创新股票A', '股票型', 'R4', '中欧基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (19, '001717', '工银前沿医疗股票A', '股票型', 'R4', '工银瑞信基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (20, '110011', '易方达中小盘混合', '混合型', 'R4', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (21, '519696', '交银环球精选混合(QDII)', 'QDII', 'R4', '交银施罗德基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (22, '161039', '富国中证1000指数增强', '指数型', 'R4', '富国基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (23, '159915', '易方达创业板ETF', 'ETF', 'R5', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (24, '510300', '华泰柏瑞沪深300ETF', 'ETF', 'R4', '华泰柏瑞基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (25, '512690', '鹏华中证酒ETF', 'ETF', 'R5', '鹏华基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (26, '515790', '华夏中证新能源ETF', 'ETF', 'R5', '华夏基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (27, '320007', '诺安成长混合', '混合型', 'R5', '诺安基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (28, '260108', '景顺长城新兴成长混合', '混合型', 'R4', '景顺长城基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (29, '163406', '兴全合润混合', '混合型', 'R4', '兴证全球基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (30, '000452', '南方医药保健灵活配置混合', '混合型', 'R4', '南方基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (31, '040046', '华安纳斯达克100指数', 'QDII', 'R4', '华安基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (32, '513100', '国泰纳斯达克100ETF', 'ETF', 'R4', '国泰基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (33, '000307', '易方达黄金ETF联接A', '商品型', 'R3', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (34, '518880', '华安黄金ETF', 'ETF', 'R3', '华安基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (35, '161005', '富国天惠成长混合', '混合型', 'R4', '富国基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (36, '398011', '中海分红增利混合', '混合型', 'R3', '中海基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');

-- ----------------------------
-- Table structure for fund_nav
-- ----------------------------
DROP TABLE IF EXISTS `fund_nav`;
CREATE TABLE `fund_nav`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `fund_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金代码',
                             `fund_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金名称',
                             `nav_date` date NOT NULL COMMENT '净值日期',
                             `nav` decimal(18, 8) NOT NULL COMMENT '单位净值',
                             `daily_return` decimal(18, 8) NULL DEFAULT NULL COMMENT '日收益率，可选',
                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_fund_nav_code_date`(`fund_code` ASC, `nav_date` ASC) USING BTREE,
                             INDEX `idx_fund_nav_date`(`nav_date` ASC) USING BTREE,
                             INDEX `idx_fund_nav_code`(`fund_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1081 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金历史净值表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_nav
-- ----------------------------
INSERT INTO `fund_nav` VALUES (1, '110022', '易方达消费行业股票', '2026-06-23', 1.05849000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (2, '110022', '易方达消费行业股票', '2026-06-22', 1.05658000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (3, '110022', '易方达消费行业股票', '2026-06-21', 1.05577000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (4, '110022', '易方达消费行业股票', '2026-06-20', 1.05396000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (5, '110022', '易方达消费行业股票', '2026-06-19', 1.05235000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (6, '110022', '易方达消费行业股票', '2026-06-18', 1.05219000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (7, '110022', '易方达消费行业股票', '2026-06-17', 1.05028000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (8, '110022', '易方达消费行业股票', '2026-06-16', 1.04947000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (9, '110022', '易方达消费行业股票', '2026-06-15', 1.04766000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (10, '110022', '易方达消费行业股票', '2026-06-14', 1.04605000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (11, '110022', '易方达消费行业股票', '2026-06-13', 1.04589000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (12, '110022', '易方达消费行业股票', '2026-06-12', 1.04398000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (13, '110022', '易方达消费行业股票', '2026-06-11', 1.04317000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (14, '110022', '易方达消费行业股票', '2026-06-10', 1.04136000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (15, '110022', '易方达消费行业股票', '2026-06-09', 1.03975000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (16, '110022', '易方达消费行业股票', '2026-06-08', 1.03959000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (17, '110022', '易方达消费行业股票', '2026-06-07', 1.03768000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (18, '110022', '易方达消费行业股票', '2026-06-06', 1.03687000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (19, '110022', '易方达消费行业股票', '2026-06-05', 1.03506000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (20, '110022', '易方达消费行业股票', '2026-06-04', 1.03345000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (21, '110022', '易方达消费行业股票', '2026-06-03', 1.03329000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (22, '110022', '易方达消费行业股票', '2026-06-02', 1.03138000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (23, '110022', '易方达消费行业股票', '2026-06-01', 1.03057000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (24, '110022', '易方达消费行业股票', '2026-05-31', 1.02876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (25, '110022', '易方达消费行业股票', '2026-05-30', 1.02715000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (26, '110022', '易方达消费行业股票', '2026-05-29', 1.02699000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (27, '110022', '易方达消费行业股票', '2026-05-28', 1.02508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (28, '110022', '易方达消费行业股票', '2026-05-27', 1.02427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (29, '110022', '易方达消费行业股票', '2026-05-26', 1.02246000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (30, '110022', '易方达消费行业股票', '2026-05-25', 1.02085000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (31, '003095', '中欧医疗健康混合', '2026-06-23', 1.07113000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (32, '003095', '中欧医疗健康混合', '2026-06-22', 1.07032000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (33, '003095', '中欧医疗健康混合', '2026-06-21', 1.06851000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (34, '003095', '中欧医疗健康混合', '2026-06-20', 1.06690000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (35, '003095', '中欧医疗健康混合', '2026-06-19', 1.06674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (36, '003095', '中欧医疗健康混合', '2026-06-18', 1.06483000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (37, '003095', '中欧医疗健康混合', '2026-06-17', 1.06402000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (38, '003095', '中欧医疗健康混合', '2026-06-16', 1.06221000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (39, '003095', '中欧医疗健康混合', '2026-06-15', 1.06060000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (40, '003095', '中欧医疗健康混合', '2026-06-14', 1.06044000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (41, '003095', '中欧医疗健康混合', '2026-06-13', 1.05853000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (42, '003095', '中欧医疗健康混合', '2026-06-12', 1.05772000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (43, '003095', '中欧医疗健康混合', '2026-06-11', 1.05591000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (44, '003095', '中欧医疗健康混合', '2026-06-10', 1.05430000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (45, '003095', '中欧医疗健康混合', '2026-06-09', 1.05414000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (46, '003095', '中欧医疗健康混合', '2026-06-08', 1.05223000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (47, '003095', '中欧医疗健康混合', '2026-06-07', 1.05142000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (48, '003095', '中欧医疗健康混合', '2026-06-06', 1.04961000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (49, '003095', '中欧医疗健康混合', '2026-06-05', 1.04800000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (50, '003095', '中欧医疗健康混合', '2026-06-04', 1.04784000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (51, '003095', '中欧医疗健康混合', '2026-06-03', 1.04593000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (52, '003095', '中欧医疗健康混合', '2026-06-02', 1.04512000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (53, '003095', '中欧医疗健康混合', '2026-06-01', 1.04331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (54, '003095', '中欧医疗健康混合', '2026-05-31', 1.04170000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (55, '003095', '中欧医疗健康混合', '2026-05-30', 1.04154000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (56, '003095', '中欧医疗健康混合', '2026-05-29', 1.03963000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (57, '003095', '中欧医疗健康混合', '2026-05-28', 1.03882000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (58, '003095', '中欧医疗健康混合', '2026-05-27', 1.03701000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (59, '003095', '中欧医疗健康混合', '2026-05-26', 1.03540000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (60, '003095', '中欧医疗健康混合', '2026-05-25', 1.03524000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (61, '161725', '招商中证白酒指数', '2026-06-23', 1.08354000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (62, '161725', '招商中证白酒指数', '2026-06-22', 1.08163000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (63, '161725', '招商中证白酒指数', '2026-06-21', 1.08082000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (64, '161725', '招商中证白酒指数', '2026-06-20', 1.07901000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (65, '161725', '招商中证白酒指数', '2026-06-19', 1.07740000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (66, '161725', '招商中证白酒指数', '2026-06-18', 1.07724000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (67, '161725', '招商中证白酒指数', '2026-06-17', 1.07533000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (68, '161725', '招商中证白酒指数', '2026-06-16', 1.07452000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (69, '161725', '招商中证白酒指数', '2026-06-15', 1.07271000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (70, '161725', '招商中证白酒指数', '2026-06-14', 1.07110000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (71, '161725', '招商中证白酒指数', '2026-06-13', 1.07094000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (72, '161725', '招商中证白酒指数', '2026-06-12', 1.06903000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (73, '161725', '招商中证白酒指数', '2026-06-11', 1.06822000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (74, '161725', '招商中证白酒指数', '2026-06-10', 1.06641000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (75, '161725', '招商中证白酒指数', '2026-06-09', 1.06480000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (76, '161725', '招商中证白酒指数', '2026-06-08', 1.06464000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (77, '161725', '招商中证白酒指数', '2026-06-07', 1.06273000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (78, '161725', '招商中证白酒指数', '2026-06-06', 1.06192000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (79, '161725', '招商中证白酒指数', '2026-06-05', 1.06011000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (80, '161725', '招商中证白酒指数', '2026-06-04', 1.05850000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (81, '161725', '招商中证白酒指数', '2026-06-03', 1.05834000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (82, '161725', '招商中证白酒指数', '2026-06-02', 1.05643000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (83, '161725', '招商中证白酒指数', '2026-06-01', 1.05562000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (84, '161725', '招商中证白酒指数', '2026-05-31', 1.05381000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (85, '161725', '招商中证白酒指数', '2026-05-30', 1.05220000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (86, '161725', '招商中证白酒指数', '2026-05-29', 1.05204000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (87, '161725', '招商中证白酒指数', '2026-05-28', 1.05013000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (88, '161725', '招商中证白酒指数', '2026-05-27', 1.04932000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (89, '161725', '招商中证白酒指数', '2026-05-26', 1.04751000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (90, '161725', '招商中证白酒指数', '2026-05-25', 1.04590000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (91, '000001', '华夏成长混合', '2026-06-23', 1.04996000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (92, '000001', '华夏成长混合', '2026-06-22', 1.04819000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (93, '000001', '华夏成长混合', '2026-06-21', 1.04662000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (94, '000001', '华夏成长混合', '2026-06-20', 1.04650000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (95, '000001', '华夏成长混合', '2026-06-19', 1.04463000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (96, '000001', '华夏成长混合', '2026-06-18', 1.04386000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (97, '000001', '华夏成长混合', '2026-06-17', 1.04209000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (98, '000001', '华夏成长混合', '2026-06-16', 1.04052000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (99, '000001', '华夏成长混合', '2026-06-15', 1.04040000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (100, '000001', '华夏成长混合', '2026-06-14', 1.03853000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (101, '000001', '华夏成长混合', '2026-06-13', 1.03776000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (102, '000001', '华夏成长混合', '2026-06-12', 1.03599000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (103, '000001', '华夏成长混合', '2026-06-11', 1.03442000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (104, '000001', '华夏成长混合', '2026-06-10', 1.03430000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (105, '000001', '华夏成长混合', '2026-06-09', 1.03243000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (106, '000001', '华夏成长混合', '2026-06-08', 1.03166000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (107, '000001', '华夏成长混合', '2026-06-07', 1.02989000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (108, '000001', '华夏成长混合', '2026-06-06', 1.02832000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (109, '000001', '华夏成长混合', '2026-06-05', 1.02820000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (110, '000001', '华夏成长混合', '2026-06-04', 1.02633000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (111, '000001', '华夏成长混合', '2026-06-03', 1.02556000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (112, '000001', '华夏成长混合', '2026-06-02', 1.02379000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (113, '000001', '华夏成长混合', '2026-06-01', 1.02222000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (114, '000001', '华夏成长混合', '2026-05-31', 1.02210000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (115, '000001', '华夏成长混合', '2026-05-30', 1.02023000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (116, '000001', '华夏成长混合', '2026-05-29', 1.01946000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (117, '000001', '华夏成长混合', '2026-05-28', 1.01769000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (118, '000001', '华夏成长混合', '2026-05-27', 1.01612000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (119, '000001', '华夏成长混合', '2026-05-26', 1.01600000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (120, '000001', '华夏成长混合', '2026-05-25', 1.01413000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (121, '002021', '国泰金牛创新成长混合', '2026-06-23', 1.06262000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (122, '002021', '国泰金牛创新成长混合', '2026-06-22', 1.06074000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (123, '002021', '国泰金牛创新成长混合', '2026-06-21', 1.05996000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (124, '002021', '国泰金牛创新成长混合', '2026-06-20', 1.05818000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (125, '002021', '国泰金牛创新成长混合', '2026-06-19', 1.05660000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (126, '002021', '国泰金牛创新成长混合', '2026-06-18', 1.05647000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (127, '002021', '国泰金牛创新成长混合', '2026-06-17', 1.05459000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (128, '002021', '国泰金牛创新成长混合', '2026-06-16', 1.05381000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (129, '002021', '国泰金牛创新成长混合', '2026-06-15', 1.05203000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (130, '002021', '国泰金牛创新成长混合', '2026-06-14', 1.05045000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (131, '002021', '国泰金牛创新成长混合', '2026-06-13', 1.05032000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (132, '002021', '国泰金牛创新成长混合', '2026-06-12', 1.04844000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (133, '002021', '国泰金牛创新成长混合', '2026-06-11', 1.04766000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (134, '002021', '国泰金牛创新成长混合', '2026-06-10', 1.04588000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (135, '002021', '国泰金牛创新成长混合', '2026-06-09', 1.04430000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (136, '002021', '国泰金牛创新成长混合', '2026-06-08', 1.04417000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (137, '002021', '国泰金牛创新成长混合', '2026-06-07', 1.04229000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (138, '002021', '国泰金牛创新成长混合', '2026-06-06', 1.04151000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (139, '002021', '国泰金牛创新成长混合', '2026-06-05', 1.03973000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (140, '002021', '国泰金牛创新成长混合', '2026-06-04', 1.03815000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (141, '002021', '国泰金牛创新成长混合', '2026-06-03', 1.03802000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (142, '002021', '国泰金牛创新成长混合', '2026-06-02', 1.03614000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (143, '002021', '国泰金牛创新成长混合', '2026-06-01', 1.03536000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (144, '002021', '国泰金牛创新成长混合', '2026-05-31', 1.03358000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (145, '002021', '国泰金牛创新成长混合', '2026-05-30', 1.03200000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (146, '002021', '国泰金牛创新成长混合', '2026-05-29', 1.03187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (147, '002021', '国泰金牛创新成长混合', '2026-05-28', 1.02999000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (148, '002021', '国泰金牛创新成长混合', '2026-05-27', 1.02921000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (149, '002021', '国泰金牛创新成长混合', '2026-05-26', 1.02743000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (150, '002021', '国泰金牛创新成长混合', '2026-05-25', 1.02585000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (151, '519674', '银河创新成长混合', '2026-06-23', 1.04279000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (152, '519674', '银河创新成长混合', '2026-06-22', 1.04088000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (153, '519674', '银河创新成长混合', '2026-06-21', 1.04007000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (154, '519674', '银河创新成长混合', '2026-06-20', 1.03826000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (155, '519674', '银河创新成长混合', '2026-06-19', 1.03665000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (156, '519674', '银河创新成长混合', '2026-06-18', 1.03649000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (157, '519674', '银河创新成长混合', '2026-06-17', 1.03458000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (158, '519674', '银河创新成长混合', '2026-06-16', 1.03377000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (159, '519674', '银河创新成长混合', '2026-06-15', 1.03196000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (160, '519674', '银河创新成长混合', '2026-06-14', 1.03035000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (161, '519674', '银河创新成长混合', '2026-06-13', 1.03019000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (162, '519674', '银河创新成长混合', '2026-06-12', 1.02828000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (163, '519674', '银河创新成长混合', '2026-06-11', 1.02747000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (164, '519674', '银河创新成长混合', '2026-06-10', 1.02566000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (165, '519674', '银河创新成长混合', '2026-06-09', 1.02405000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (166, '519674', '银河创新成长混合', '2026-06-08', 1.02389000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (167, '519674', '银河创新成长混合', '2026-06-07', 1.02198000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (168, '519674', '银河创新成长混合', '2026-06-06', 1.02117000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (169, '519674', '银河创新成长混合', '2026-06-05', 1.01936000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (170, '519674', '银河创新成长混合', '2026-06-04', 1.01775000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (171, '519674', '银河创新成长混合', '2026-06-03', 1.01759000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (172, '519674', '银河创新成长混合', '2026-06-02', 1.01568000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (173, '519674', '银河创新成长混合', '2026-06-01', 1.01487000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (174, '519674', '银河创新成长混合', '2026-05-31', 1.01306000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (175, '519674', '银河创新成长混合', '2026-05-30', 1.01145000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (176, '519674', '银河创新成长混合', '2026-05-29', 1.01129000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (177, '519674', '银河创新成长混合', '2026-05-28', 1.00938000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (178, '519674', '银河创新成长混合', '2026-05-27', 1.00857000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (179, '519674', '银河创新成长混合', '2026-05-26', 1.00676000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (180, '519674', '银河创新成长混合', '2026-05-25', 1.00515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (181, '001632', '天弘中证食品饮料ETF联接A', '2026-06-23', 1.06888000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (182, '001632', '天弘中证食品饮料ETF联接A', '2026-06-22', 1.06812000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (183, '001632', '天弘中证食品饮料ETF联接A', '2026-06-21', 1.06636000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (184, '001632', '天弘中证食品饮料ETF联接A', '2026-06-20', 1.06480000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (185, '001632', '天弘中证食品饮料ETF联接A', '2026-06-19', 1.06469000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (186, '001632', '天弘中证食品饮料ETF联接A', '2026-06-18', 1.06283000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (187, '001632', '天弘中证食品饮料ETF联接A', '2026-06-17', 1.06207000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (188, '001632', '天弘中证食品饮料ETF联接A', '2026-06-16', 1.06031000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (189, '001632', '天弘中证食品饮料ETF联接A', '2026-06-15', 1.05875000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (190, '001632', '天弘中证食品饮料ETF联接A', '2026-06-14', 1.05864000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (191, '001632', '天弘中证食品饮料ETF联接A', '2026-06-13', 1.05678000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (192, '001632', '天弘中证食品饮料ETF联接A', '2026-06-12', 1.05602000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (193, '001632', '天弘中证食品饮料ETF联接A', '2026-06-11', 1.05426000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (194, '001632', '天弘中证食品饮料ETF联接A', '2026-06-10', 1.05270000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (195, '001632', '天弘中证食品饮料ETF联接A', '2026-06-09', 1.05259000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (196, '001632', '天弘中证食品饮料ETF联接A', '2026-06-08', 1.05073000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (197, '001632', '天弘中证食品饮料ETF联接A', '2026-06-07', 1.04997000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (198, '001632', '天弘中证食品饮料ETF联接A', '2026-06-06', 1.04821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (199, '001632', '天弘中证食品饮料ETF联接A', '2026-06-05', 1.04665000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (200, '001632', '天弘中证食品饮料ETF联接A', '2026-06-04', 1.04654000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (201, '001632', '天弘中证食品饮料ETF联接A', '2026-06-03', 1.04468000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (202, '001632', '天弘中证食品饮料ETF联接A', '2026-06-02', 1.04392000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (203, '001632', '天弘中证食品饮料ETF联接A', '2026-06-01', 1.04216000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (204, '001632', '天弘中证食品饮料ETF联接A', '2026-05-31', 1.04060000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (205, '001632', '天弘中证食品饮料ETF联接A', '2026-05-30', 1.04049000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (206, '001632', '天弘中证食品饮料ETF联接A', '2026-05-29', 1.03863000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (207, '001632', '天弘中证食品饮料ETF联接A', '2026-05-28', 1.03787000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (208, '001632', '天弘中证食品饮料ETF联接A', '2026-05-27', 1.03611000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (209, '001632', '天弘中证食品饮料ETF联接A', '2026-05-26', 1.03455000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (210, '001632', '天弘中证食品饮料ETF联接A', '2026-05-25', 1.03444000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (211, '005827', '易方达蓝筹精选混合', '2026-06-23', 1.07459000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (212, '005827', '易方达蓝筹精选混合', '2026-06-22', 1.07379000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (213, '005827', '易方达蓝筹精选混合', '2026-06-21', 1.07199000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (214, '005827', '易方达蓝筹精选混合', '2026-06-20', 1.07039000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (215, '005827', '易方达蓝筹精选混合', '2026-06-19', 1.07024000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (216, '005827', '易方达蓝筹精选混合', '2026-06-18', 1.06834000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (217, '005827', '易方达蓝筹精选混合', '2026-06-17', 1.06754000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (218, '005827', '易方达蓝筹精选混合', '2026-06-16', 1.06574000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (219, '005827', '易方达蓝筹精选混合', '2026-06-15', 1.06414000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (220, '005827', '易方达蓝筹精选混合', '2026-06-14', 1.06399000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (221, '005827', '易方达蓝筹精选混合', '2026-06-13', 1.06209000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (222, '005827', '易方达蓝筹精选混合', '2026-06-12', 1.06129000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (223, '005827', '易方达蓝筹精选混合', '2026-06-11', 1.05949000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (224, '005827', '易方达蓝筹精选混合', '2026-06-10', 1.05789000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (225, '005827', '易方达蓝筹精选混合', '2026-06-09', 1.05774000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (226, '005827', '易方达蓝筹精选混合', '2026-06-08', 1.05584000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (227, '005827', '易方达蓝筹精选混合', '2026-06-07', 1.05504000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (228, '005827', '易方达蓝筹精选混合', '2026-06-06', 1.05324000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (229, '005827', '易方达蓝筹精选混合', '2026-06-05', 1.05164000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (230, '005827', '易方达蓝筹精选混合', '2026-06-04', 1.05149000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (231, '005827', '易方达蓝筹精选混合', '2026-06-03', 1.04959000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (232, '005827', '易方达蓝筹精选混合', '2026-06-02', 1.04879000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (233, '005827', '易方达蓝筹精选混合', '2026-06-01', 1.04699000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (234, '005827', '易方达蓝筹精选混合', '2026-05-31', 1.04539000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (235, '005827', '易方达蓝筹精选混合', '2026-05-30', 1.04524000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (236, '005827', '易方达蓝筹精选混合', '2026-05-29', 1.04334000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (237, '005827', '易方达蓝筹精选混合', '2026-05-28', 1.04254000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (238, '005827', '易方达蓝筹精选混合', '2026-05-27', 1.04074000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (239, '005827', '易方达蓝筹精选混合', '2026-05-26', 1.03914000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (240, '005827', '易方达蓝筹精选混合', '2026-05-25', 1.03899000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (241, '006113', '汇添富创新医药混合', '2026-06-23', 1.07784000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (242, '006113', '汇添富创新医药混合', '2026-06-22', 1.07772000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (243, '006113', '汇添富创新医药混合', '2026-06-21', 1.07585000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (244, '006113', '汇添富创新医药混合', '2026-06-20', 1.07508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (245, '006113', '汇添富创新医药混合', '2026-06-19', 1.07331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (246, '006113', '汇添富创新医药混合', '2026-06-18', 1.07174000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (247, '006113', '汇添富创新医药混合', '2026-06-17', 1.07162000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (248, '006113', '汇添富创新医药混合', '2026-06-16', 1.06975000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (249, '006113', '汇添富创新医药混合', '2026-06-15', 1.06898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (250, '006113', '汇添富创新医药混合', '2026-06-14', 1.06721000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (251, '006113', '汇添富创新医药混合', '2026-06-13', 1.06564000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (252, '006113', '汇添富创新医药混合', '2026-06-12', 1.06552000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (253, '006113', '汇添富创新医药混合', '2026-06-11', 1.06365000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (254, '006113', '汇添富创新医药混合', '2026-06-10', 1.06288000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (255, '006113', '汇添富创新医药混合', '2026-06-09', 1.06111000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (256, '006113', '汇添富创新医药混合', '2026-06-08', 1.05954000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (257, '006113', '汇添富创新医药混合', '2026-06-07', 1.05942000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (258, '006113', '汇添富创新医药混合', '2026-06-06', 1.05755000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (259, '006113', '汇添富创新医药混合', '2026-06-05', 1.05678000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (260, '006113', '汇添富创新医药混合', '2026-06-04', 1.05501000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (261, '006113', '汇添富创新医药混合', '2026-06-03', 1.05344000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (262, '006113', '汇添富创新医药混合', '2026-06-02', 1.05332000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (263, '006113', '汇添富创新医药混合', '2026-06-01', 1.05145000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (264, '006113', '汇添富创新医药混合', '2026-05-31', 1.05068000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (265, '006113', '汇添富创新医药混合', '2026-05-30', 1.04891000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (266, '006113', '汇添富创新医药混合', '2026-05-29', 1.04734000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (267, '006113', '汇添富创新医药混合', '2026-05-28', 1.04722000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (268, '006113', '汇添富创新医药混合', '2026-05-27', 1.04535000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (269, '006113', '汇添富创新医药混合', '2026-05-26', 1.04458000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (270, '006113', '汇添富创新医药混合', '2026-05-25', 1.04281000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (271, '000248', '汇添富中证主要消费ETF联接', '2026-06-23', 1.03804000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (272, '000248', '汇添富中证主要消费ETF联接', '2026-06-22', 1.03625000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (273, '000248', '汇添富中证主要消费ETF联接', '2026-06-21', 1.03466000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (274, '000248', '汇添富中证主要消费ETF联接', '2026-06-20', 1.03452000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (275, '000248', '汇添富中证主要消费ETF联接', '2026-06-19', 1.03263000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (276, '000248', '汇添富中证主要消费ETF联接', '2026-06-18', 1.03184000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (277, '000248', '汇添富中证主要消费ETF联接', '2026-06-17', 1.03005000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (278, '000248', '汇添富中证主要消费ETF联接', '2026-06-16', 1.02846000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (279, '000248', '汇添富中证主要消费ETF联接', '2026-06-15', 1.02832000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (280, '000248', '汇添富中证主要消费ETF联接', '2026-06-14', 1.02643000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (281, '000248', '汇添富中证主要消费ETF联接', '2026-06-13', 1.02564000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (282, '000248', '汇添富中证主要消费ETF联接', '2026-06-12', 1.02385000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (283, '000248', '汇添富中证主要消费ETF联接', '2026-06-11', 1.02226000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (284, '000248', '汇添富中证主要消费ETF联接', '2026-06-10', 1.02212000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (285, '000248', '汇添富中证主要消费ETF联接', '2026-06-09', 1.02023000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (286, '000248', '汇添富中证主要消费ETF联接', '2026-06-08', 1.01944000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (287, '000248', '汇添富中证主要消费ETF联接', '2026-06-07', 1.01765000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (288, '000248', '汇添富中证主要消费ETF联接', '2026-06-06', 1.01606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (289, '000248', '汇添富中证主要消费ETF联接', '2026-06-05', 1.01592000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (290, '000248', '汇添富中证主要消费ETF联接', '2026-06-04', 1.01403000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (291, '000248', '汇添富中证主要消费ETF联接', '2026-06-03', 1.01324000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (292, '000248', '汇添富中证主要消费ETF联接', '2026-06-02', 1.01145000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (293, '000248', '汇添富中证主要消费ETF联接', '2026-06-01', 1.00986000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (294, '000248', '汇添富中证主要消费ETF联接', '2026-05-31', 1.00972000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (295, '000248', '汇添富中证主要消费ETF联接', '2026-05-30', 1.00783000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (296, '000248', '汇添富中证主要消费ETF联接', '2026-05-29', 1.00704000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (297, '000248', '汇添富中证主要消费ETF联接', '2026-05-28', 1.00525000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (298, '000248', '汇添富中证主要消费ETF联接', '2026-05-27', 1.00366000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (299, '000248', '汇添富中证主要消费ETF联接', '2026-05-26', 1.00352000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (300, '000248', '汇添富中证主要消费ETF联接', '2026-05-25', 1.00163000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (301, '001875', '前海开源沪港深优势精选混合', '2026-06-23', 1.08331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (302, '001875', '前海开源沪港深优势精选混合', '2026-06-22', 1.08321000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (303, '001875', '前海开源沪港深优势精选混合', '2026-06-21', 1.08136000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (304, '001875', '前海开源沪港深优势精选混合', '2026-06-20', 1.08061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (305, '001875', '前海开源沪港深优势精选混合', '2026-06-19', 1.07886000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (306, '001875', '前海开源沪港深优势精选混合', '2026-06-18', 1.07731000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (307, '001875', '前海开源沪港深优势精选混合', '2026-06-17', 1.07721000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (308, '001875', '前海开源沪港深优势精选混合', '2026-06-16', 1.07536000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (309, '001875', '前海开源沪港深优势精选混合', '2026-06-15', 1.07461000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (310, '001875', '前海开源沪港深优势精选混合', '2026-06-14', 1.07286000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (311, '001875', '前海开源沪港深优势精选混合', '2026-06-13', 1.07131000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (312, '001875', '前海开源沪港深优势精选混合', '2026-06-12', 1.07121000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (313, '001875', '前海开源沪港深优势精选混合', '2026-06-11', 1.06936000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (314, '001875', '前海开源沪港深优势精选混合', '2026-06-10', 1.06861000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (315, '001875', '前海开源沪港深优势精选混合', '2026-06-09', 1.06686000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (316, '001875', '前海开源沪港深优势精选混合', '2026-06-08', 1.06531000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (317, '001875', '前海开源沪港深优势精选混合', '2026-06-07', 1.06521000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (318, '001875', '前海开源沪港深优势精选混合', '2026-06-06', 1.06336000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (319, '001875', '前海开源沪港深优势精选混合', '2026-06-05', 1.06261000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (320, '001875', '前海开源沪港深优势精选混合', '2026-06-04', 1.06086000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (321, '001875', '前海开源沪港深优势精选混合', '2026-06-03', 1.05931000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (322, '001875', '前海开源沪港深优势精选混合', '2026-06-02', 1.05921000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (323, '001875', '前海开源沪港深优势精选混合', '2026-06-01', 1.05736000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (324, '001875', '前海开源沪港深优势精选混合', '2026-05-31', 1.05661000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (325, '001875', '前海开源沪港深优势精选混合', '2026-05-30', 1.05486000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (326, '001875', '前海开源沪港深优势精选混合', '2026-05-29', 1.05331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (327, '001875', '前海开源沪港深优势精选混合', '2026-05-28', 1.05321000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (328, '001875', '前海开源沪港深优势精选混合', '2026-05-27', 1.05136000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (329, '001875', '前海开源沪港深优势精选混合', '2026-05-26', 1.05061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (330, '001875', '前海开源沪港深优势精选混合', '2026-05-25', 1.04886000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (331, '002190', '农银新能源主题灵活配置混合', '2026-06-23', 1.06602000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (332, '002190', '农银新能源主题灵活配置混合', '2026-06-22', 1.06426000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (333, '002190', '农银新能源主题灵活配置混合', '2026-06-21', 1.06270000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (334, '002190', '农银新能源主题灵活配置混合', '2026-06-20', 1.06259000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (335, '002190', '农银新能源主题灵活配置混合', '2026-06-19', 1.06073000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (336, '002190', '农银新能源主题灵活配置混合', '2026-06-18', 1.05997000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (337, '002190', '农银新能源主题灵活配置混合', '2026-06-17', 1.05821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (338, '002190', '农银新能源主题灵活配置混合', '2026-06-16', 1.05665000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (339, '002190', '农银新能源主题灵活配置混合', '2026-06-15', 1.05654000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (340, '002190', '农银新能源主题灵活配置混合', '2026-06-14', 1.05468000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (341, '002190', '农银新能源主题灵活配置混合', '2026-06-13', 1.05392000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (342, '002190', '农银新能源主题灵活配置混合', '2026-06-12', 1.05216000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (343, '002190', '农银新能源主题灵活配置混合', '2026-06-11', 1.05060000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (344, '002190', '农银新能源主题灵活配置混合', '2026-06-10', 1.05049000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (345, '002190', '农银新能源主题灵活配置混合', '2026-06-09', 1.04863000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (346, '002190', '农银新能源主题灵活配置混合', '2026-06-08', 1.04787000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (347, '002190', '农银新能源主题灵活配置混合', '2026-06-07', 1.04611000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (348, '002190', '农银新能源主题灵活配置混合', '2026-06-06', 1.04455000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (349, '002190', '农银新能源主题灵活配置混合', '2026-06-05', 1.04444000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (350, '002190', '农银新能源主题灵活配置混合', '2026-06-04', 1.04258000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (351, '002190', '农银新能源主题灵活配置混合', '2026-06-03', 1.04182000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (352, '002190', '农银新能源主题灵活配置混合', '2026-06-02', 1.04006000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (353, '002190', '农银新能源主题灵活配置混合', '2026-06-01', 1.03850000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (354, '002190', '农银新能源主题灵活配置混合', '2026-05-31', 1.03839000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (355, '002190', '农银新能源主题灵活配置混合', '2026-05-30', 1.03653000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (356, '002190', '农银新能源主题灵活配置混合', '2026-05-29', 1.03577000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (357, '002190', '农银新能源主题灵活配置混合', '2026-05-28', 1.03401000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (358, '002190', '农银新能源主题灵活配置混合', '2026-05-27', 1.03245000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (359, '002190', '农银新能源主题灵活配置混合', '2026-05-26', 1.03234000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (360, '002190', '农银新能源主题灵活配置混合', '2026-05-25', 1.03048000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (361, '004851', '广发医疗保健股票A', '2026-06-23', 1.08184000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (362, '004851', '广发医疗保健股票A', '2026-06-22', 1.08104000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (363, '004851', '广发医疗保健股票A', '2026-06-21', 1.07924000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (364, '004851', '广发医疗保健股票A', '2026-06-20', 1.07764000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (365, '004851', '广发医疗保健股票A', '2026-06-19', 1.07749000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (366, '004851', '广发医疗保健股票A', '2026-06-18', 1.07559000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (367, '004851', '广发医疗保健股票A', '2026-06-17', 1.07479000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (368, '004851', '广发医疗保健股票A', '2026-06-16', 1.07299000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (369, '004851', '广发医疗保健股票A', '2026-06-15', 1.07139000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (370, '004851', '广发医疗保健股票A', '2026-06-14', 1.07124000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (371, '004851', '广发医疗保健股票A', '2026-06-13', 1.06934000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (372, '004851', '广发医疗保健股票A', '2026-06-12', 1.06854000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (373, '004851', '广发医疗保健股票A', '2026-06-11', 1.06674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (374, '004851', '广发医疗保健股票A', '2026-06-10', 1.06514000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (375, '004851', '广发医疗保健股票A', '2026-06-09', 1.06499000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (376, '004851', '广发医疗保健股票A', '2026-06-08', 1.06309000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (377, '004851', '广发医疗保健股票A', '2026-06-07', 1.06229000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (378, '004851', '广发医疗保健股票A', '2026-06-06', 1.06049000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (379, '004851', '广发医疗保健股票A', '2026-06-05', 1.05889000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (380, '004851', '广发医疗保健股票A', '2026-06-04', 1.05874000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (381, '004851', '广发医疗保健股票A', '2026-06-03', 1.05684000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (382, '004851', '广发医疗保健股票A', '2026-06-02', 1.05604000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (383, '004851', '广发医疗保健股票A', '2026-06-01', 1.05424000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (384, '004851', '广发医疗保健股票A', '2026-05-31', 1.05264000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (385, '004851', '广发医疗保健股票A', '2026-05-30', 1.05249000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (386, '004851', '广发医疗保健股票A', '2026-05-29', 1.05059000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (387, '004851', '广发医疗保健股票A', '2026-05-28', 1.04979000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (388, '004851', '广发医疗保健股票A', '2026-05-27', 1.04799000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (389, '004851', '广发医疗保健股票A', '2026-05-26', 1.04639000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (390, '004851', '广发医疗保健股票A', '2026-05-25', 1.04624000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (391, '000960', '招商医药健康产业股票', '2026-06-23', 1.05651000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (392, '000960', '招商医药健康产业股票', '2026-06-22', 1.05474000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (393, '000960', '招商医药健康产业股票', '2026-06-21', 1.05317000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (394, '000960', '招商医药健康产业股票', '2026-06-20', 1.05305000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (395, '000960', '招商医药健康产业股票', '2026-06-19', 1.05118000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (396, '000960', '招商医药健康产业股票', '2026-06-18', 1.05041000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (397, '000960', '招商医药健康产业股票', '2026-06-17', 1.04864000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (398, '000960', '招商医药健康产业股票', '2026-06-16', 1.04707000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (399, '000960', '招商医药健康产业股票', '2026-06-15', 1.04695000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (400, '000960', '招商医药健康产业股票', '2026-06-14', 1.04508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (401, '000960', '招商医药健康产业股票', '2026-06-13', 1.04431000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (402, '000960', '招商医药健康产业股票', '2026-06-12', 1.04254000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (403, '000960', '招商医药健康产业股票', '2026-06-11', 1.04097000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (404, '000960', '招商医药健康产业股票', '2026-06-10', 1.04085000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (405, '000960', '招商医药健康产业股票', '2026-06-09', 1.03898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (406, '000960', '招商医药健康产业股票', '2026-06-08', 1.03821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (407, '000960', '招商医药健康产业股票', '2026-06-07', 1.03644000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (408, '000960', '招商医药健康产业股票', '2026-06-06', 1.03487000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (409, '000960', '招商医药健康产业股票', '2026-06-05', 1.03475000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (410, '000960', '招商医药健康产业股票', '2026-06-04', 1.03288000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (411, '000960', '招商医药健康产业股票', '2026-06-03', 1.03211000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (412, '000960', '招商医药健康产业股票', '2026-06-02', 1.03034000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (413, '000960', '招商医药健康产业股票', '2026-06-01', 1.02877000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (414, '000960', '招商医药健康产业股票', '2026-05-31', 1.02865000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (415, '000960', '招商医药健康产业股票', '2026-05-30', 1.02678000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (416, '000960', '招商医药健康产业股票', '2026-05-29', 1.02601000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (417, '000960', '招商医药健康产业股票', '2026-05-28', 1.02424000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (418, '000960', '招商医药健康产业股票', '2026-05-27', 1.02267000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (419, '000960', '招商医药健康产业股票', '2026-05-26', 1.02255000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (420, '000960', '招商医药健康产业股票', '2026-05-25', 1.02068000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (421, '001071', '华夏恒生ETF联接A', '2026-06-23', 1.04755000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (422, '001071', '华夏恒生ETF联接A', '2026-06-22', 1.04676000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (423, '001071', '华夏恒生ETF联接A', '2026-06-21', 1.04497000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (424, '001071', '华夏恒生ETF联接A', '2026-06-20', 1.04338000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (425, '001071', '华夏恒生ETF联接A', '2026-06-19', 1.04324000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (426, '001071', '华夏恒生ETF联接A', '2026-06-18', 1.04135000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (427, '001071', '华夏恒生ETF联接A', '2026-06-17', 1.04056000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (428, '001071', '华夏恒生ETF联接A', '2026-06-16', 1.03877000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (429, '001071', '华夏恒生ETF联接A', '2026-06-15', 1.03718000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (430, '001071', '华夏恒生ETF联接A', '2026-06-14', 1.03704000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (431, '001071', '华夏恒生ETF联接A', '2026-06-13', 1.03515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (432, '001071', '华夏恒生ETF联接A', '2026-06-12', 1.03436000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (433, '001071', '华夏恒生ETF联接A', '2026-06-11', 1.03257000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (434, '001071', '华夏恒生ETF联接A', '2026-06-10', 1.03098000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (435, '001071', '华夏恒生ETF联接A', '2026-06-09', 1.03084000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (436, '001071', '华夏恒生ETF联接A', '2026-06-08', 1.02895000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (437, '001071', '华夏恒生ETF联接A', '2026-06-07', 1.02816000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (438, '001071', '华夏恒生ETF联接A', '2026-06-06', 1.02637000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (439, '001071', '华夏恒生ETF联接A', '2026-06-05', 1.02478000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (440, '001071', '华夏恒生ETF联接A', '2026-06-04', 1.02464000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (441, '001071', '华夏恒生ETF联接A', '2026-06-03', 1.02275000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (442, '001071', '华夏恒生ETF联接A', '2026-06-02', 1.02196000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (443, '001071', '华夏恒生ETF联接A', '2026-06-01', 1.02017000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (444, '001071', '华夏恒生ETF联接A', '2026-05-31', 1.01858000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (445, '001071', '华夏恒生ETF联接A', '2026-05-30', 1.01844000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (446, '001071', '华夏恒生ETF联接A', '2026-05-29', 1.01655000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (447, '001071', '华夏恒生ETF联接A', '2026-05-28', 1.01576000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (448, '001071', '华夏恒生ETF联接A', '2026-05-27', 1.01397000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (449, '001071', '华夏恒生ETF联接A', '2026-05-26', 1.01238000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (450, '001071', '华夏恒生ETF联接A', '2026-05-25', 1.01224000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (451, '006479', '中欧智能制造混合A', '2026-06-23', 1.04019000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (452, '006479', '中欧智能制造混合A', '2026-06-22', 1.03840000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (453, '006479', '中欧智能制造混合A', '2026-06-21', 1.03681000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (454, '006479', '中欧智能制造混合A', '2026-06-20', 1.03667000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (455, '006479', '中欧智能制造混合A', '2026-06-19', 1.03478000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (456, '006479', '中欧智能制造混合A', '2026-06-18', 1.03399000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (457, '006479', '中欧智能制造混合A', '2026-06-17', 1.03220000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (458, '006479', '中欧智能制造混合A', '2026-06-16', 1.03061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (459, '006479', '中欧智能制造混合A', '2026-06-15', 1.03047000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (460, '006479', '中欧智能制造混合A', '2026-06-14', 1.02858000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (461, '006479', '中欧智能制造混合A', '2026-06-13', 1.02779000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (462, '006479', '中欧智能制造混合A', '2026-06-12', 1.02600000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (463, '006479', '中欧智能制造混合A', '2026-06-11', 1.02441000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (464, '006479', '中欧智能制造混合A', '2026-06-10', 1.02427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (465, '006479', '中欧智能制造混合A', '2026-06-09', 1.02238000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (466, '006479', '中欧智能制造混合A', '2026-06-08', 1.02159000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (467, '006479', '中欧智能制造混合A', '2026-06-07', 1.01980000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (468, '006479', '中欧智能制造混合A', '2026-06-06', 1.01821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (469, '006479', '中欧智能制造混合A', '2026-06-05', 1.01807000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (470, '006479', '中欧智能制造混合A', '2026-06-04', 1.01618000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (471, '006479', '中欧智能制造混合A', '2026-06-03', 1.01539000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (472, '006479', '中欧智能制造混合A', '2026-06-02', 1.01360000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (473, '006479', '中欧智能制造混合A', '2026-06-01', 1.01201000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (474, '006479', '中欧智能制造混合A', '2026-05-31', 1.01187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (475, '006479', '中欧智能制造混合A', '2026-05-30', 1.00998000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (476, '006479', '中欧智能制造混合A', '2026-05-29', 1.00919000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (477, '006479', '中欧智能制造混合A', '2026-05-28', 1.00740000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (478, '006479', '中欧智能制造混合A', '2026-05-27', 1.00581000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (479, '006479', '中欧智能制造混合A', '2026-05-26', 1.00567000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (480, '006479', '中欧智能制造混合A', '2026-05-25', 1.00378000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (481, '001838', '国投瑞银国家安全混合', '2026-06-23', 1.06636000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (482, '001838', '国投瑞银国家安全混合', '2026-06-22', 1.06447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (483, '001838', '国投瑞银国家安全混合', '2026-06-21', 1.06368000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (484, '001838', '国投瑞银国家安全混合', '2026-06-20', 1.06189000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (485, '001838', '国投瑞银国家安全混合', '2026-06-19', 1.06030000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (486, '001838', '国投瑞银国家安全混合', '2026-06-18', 1.06016000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (487, '001838', '国投瑞银国家安全混合', '2026-06-17', 1.05827000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (488, '001838', '国投瑞银国家安全混合', '2026-06-16', 1.05748000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (489, '001838', '国投瑞银国家安全混合', '2026-06-15', 1.05569000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (490, '001838', '国投瑞银国家安全混合', '2026-06-14', 1.05410000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (491, '001838', '国投瑞银国家安全混合', '2026-06-13', 1.05396000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (492, '001838', '国投瑞银国家安全混合', '2026-06-12', 1.05207000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (493, '001838', '国投瑞银国家安全混合', '2026-06-11', 1.05128000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (494, '001838', '国投瑞银国家安全混合', '2026-06-10', 1.04949000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (495, '001838', '国投瑞银国家安全混合', '2026-06-09', 1.04790000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (496, '001838', '国投瑞银国家安全混合', '2026-06-08', 1.04776000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (497, '001838', '国投瑞银国家安全混合', '2026-06-07', 1.04587000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (498, '001838', '国投瑞银国家安全混合', '2026-06-06', 1.04508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (499, '001838', '国投瑞银国家安全混合', '2026-06-05', 1.04329000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (500, '001838', '国投瑞银国家安全混合', '2026-06-04', 1.04170000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (501, '001838', '国投瑞银国家安全混合', '2026-06-03', 1.04156000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (502, '001838', '国投瑞银国家安全混合', '2026-06-02', 1.03967000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (503, '001838', '国投瑞银国家安全混合', '2026-06-01', 1.03888000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (504, '001838', '国投瑞银国家安全混合', '2026-05-31', 1.03709000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (505, '001838', '国投瑞银国家安全混合', '2026-05-30', 1.03550000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (506, '001838', '国投瑞银国家安全混合', '2026-05-29', 1.03536000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (507, '001838', '国投瑞银国家安全混合', '2026-05-28', 1.03347000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (508, '001838', '国投瑞银国家安全混合', '2026-05-27', 1.03268000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (509, '001838', '国投瑞银国家安全混合', '2026-05-26', 1.03089000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (510, '001838', '国投瑞银国家安全混合', '2026-05-25', 1.02930000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (511, '003096', '中欧医疗创新股票A', '2026-06-23', 1.05912000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (512, '003096', '中欧医疗创新股票A', '2026-06-22', 1.05752000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (513, '003096', '中欧医疗创新股票A', '2026-06-21', 1.05737000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (514, '003096', '中欧医疗创新股票A', '2026-06-20', 1.05547000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (515, '003096', '中欧医疗创新股票A', '2026-06-19', 1.05467000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (516, '003096', '中欧医疗创新股票A', '2026-06-18', 1.05287000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (517, '003096', '中欧医疗创新股票A', '2026-06-17', 1.05127000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (518, '003096', '中欧医疗创新股票A', '2026-06-16', 1.05112000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (519, '003096', '中欧医疗创新股票A', '2026-06-15', 1.04922000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (520, '003096', '中欧医疗创新股票A', '2026-06-14', 1.04842000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (521, '003096', '中欧医疗创新股票A', '2026-06-13', 1.04662000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (522, '003096', '中欧医疗创新股票A', '2026-06-12', 1.04502000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (523, '003096', '中欧医疗创新股票A', '2026-06-11', 1.04487000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (524, '003096', '中欧医疗创新股票A', '2026-06-10', 1.04297000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (525, '003096', '中欧医疗创新股票A', '2026-06-09', 1.04217000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (526, '003096', '中欧医疗创新股票A', '2026-06-08', 1.04037000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (527, '003096', '中欧医疗创新股票A', '2026-06-07', 1.03877000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (528, '003096', '中欧医疗创新股票A', '2026-06-06', 1.03862000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (529, '003096', '中欧医疗创新股票A', '2026-06-05', 1.03672000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (530, '003096', '中欧医疗创新股票A', '2026-06-04', 1.03592000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (531, '003096', '中欧医疗创新股票A', '2026-06-03', 1.03412000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (532, '003096', '中欧医疗创新股票A', '2026-06-02', 1.03252000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (533, '003096', '中欧医疗创新股票A', '2026-06-01', 1.03237000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (534, '003096', '中欧医疗创新股票A', '2026-05-31', 1.03047000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (535, '003096', '中欧医疗创新股票A', '2026-05-30', 1.02967000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (536, '003096', '中欧医疗创新股票A', '2026-05-29', 1.02787000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (537, '003096', '中欧医疗创新股票A', '2026-05-28', 1.02627000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (538, '003096', '中欧医疗创新股票A', '2026-05-27', 1.02612000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (539, '003096', '中欧医疗创新股票A', '2026-05-26', 1.02422000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (540, '003096', '中欧医疗创新股票A', '2026-05-25', 1.02342000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (541, '001717', '工银前沿医疗股票A', '2026-06-23', 1.06876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (542, '001717', '工银前沿医疗股票A', '2026-06-22', 1.06866000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (543, '001717', '工银前沿医疗股票A', '2026-06-21', 1.06681000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (544, '001717', '工银前沿医疗股票A', '2026-06-20', 1.06606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (545, '001717', '工银前沿医疗股票A', '2026-06-19', 1.06431000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (546, '001717', '工银前沿医疗股票A', '2026-06-18', 1.06276000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (547, '001717', '工银前沿医疗股票A', '2026-06-17', 1.06266000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (548, '001717', '工银前沿医疗股票A', '2026-06-16', 1.06081000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (549, '001717', '工银前沿医疗股票A', '2026-06-15', 1.06006000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (550, '001717', '工银前沿医疗股票A', '2026-06-14', 1.05831000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (551, '001717', '工银前沿医疗股票A', '2026-06-13', 1.05676000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (552, '001717', '工银前沿医疗股票A', '2026-06-12', 1.05666000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (553, '001717', '工银前沿医疗股票A', '2026-06-11', 1.05481000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (554, '001717', '工银前沿医疗股票A', '2026-06-10', 1.05406000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (555, '001717', '工银前沿医疗股票A', '2026-06-09', 1.05231000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (556, '001717', '工银前沿医疗股票A', '2026-06-08', 1.05076000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (557, '001717', '工银前沿医疗股票A', '2026-06-07', 1.05066000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (558, '001717', '工银前沿医疗股票A', '2026-06-06', 1.04881000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (559, '001717', '工银前沿医疗股票A', '2026-06-05', 1.04806000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (560, '001717', '工银前沿医疗股票A', '2026-06-04', 1.04631000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (561, '001717', '工银前沿医疗股票A', '2026-06-03', 1.04476000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (562, '001717', '工银前沿医疗股票A', '2026-06-02', 1.04466000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (563, '001717', '工银前沿医疗股票A', '2026-06-01', 1.04281000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (564, '001717', '工银前沿医疗股票A', '2026-05-31', 1.04206000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (565, '001717', '工银前沿医疗股票A', '2026-05-30', 1.04031000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (566, '001717', '工银前沿医疗股票A', '2026-05-29', 1.03876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (567, '001717', '工银前沿医疗股票A', '2026-05-28', 1.03866000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (568, '001717', '工银前沿医疗股票A', '2026-05-27', 1.03681000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (569, '001717', '工银前沿医疗股票A', '2026-05-26', 1.03606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (570, '001717', '工银前沿医疗股票A', '2026-05-25', 1.03431000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (571, '110011', '易方达中小盘混合', '2026-06-23', 1.05252000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (572, '110011', '易方达中小盘混合', '2026-06-22', 1.05071000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (573, '110011', '易方达中小盘混合', '2026-06-21', 1.04910000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (574, '110011', '易方达中小盘混合', '2026-06-20', 1.04894000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (575, '110011', '易方达中小盘混合', '2026-06-19', 1.04703000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (576, '110011', '易方达中小盘混合', '2026-06-18', 1.04622000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (577, '110011', '易方达中小盘混合', '2026-06-17', 1.04441000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (578, '110011', '易方达中小盘混合', '2026-06-16', 1.04280000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (579, '110011', '易方达中小盘混合', '2026-06-15', 1.04264000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (580, '110011', '易方达中小盘混合', '2026-06-14', 1.04073000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (581, '110011', '易方达中小盘混合', '2026-06-13', 1.03992000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (582, '110011', '易方达中小盘混合', '2026-06-12', 1.03811000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (583, '110011', '易方达中小盘混合', '2026-06-11', 1.03650000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (584, '110011', '易方达中小盘混合', '2026-06-10', 1.03634000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (585, '110011', '易方达中小盘混合', '2026-06-09', 1.03443000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (586, '110011', '易方达中小盘混合', '2026-06-08', 1.03362000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (587, '110011', '易方达中小盘混合', '2026-06-07', 1.03181000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (588, '110011', '易方达中小盘混合', '2026-06-06', 1.03020000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (589, '110011', '易方达中小盘混合', '2026-06-05', 1.03004000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (590, '110011', '易方达中小盘混合', '2026-06-04', 1.02813000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (591, '110011', '易方达中小盘混合', '2026-06-03', 1.02732000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (592, '110011', '易方达中小盘混合', '2026-06-02', 1.02551000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (593, '110011', '易方达中小盘混合', '2026-06-01', 1.02390000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (594, '110011', '易方达中小盘混合', '2026-05-31', 1.02374000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (595, '110011', '易方达中小盘混合', '2026-05-30', 1.02183000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (596, '110011', '易方达中小盘混合', '2026-05-29', 1.02102000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (597, '110011', '易方达中小盘混合', '2026-05-28', 1.01921000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (598, '110011', '易方达中小盘混合', '2026-05-27', 1.01760000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (599, '110011', '易方达中小盘混合', '2026-05-26', 1.01744000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (600, '110011', '易方达中小盘混合', '2026-05-25', 1.01553000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (601, '519696', '交银环球精选混合(QDII)', '2026-06-23', 1.08083000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (602, '519696', '交银环球精选混合(QDII)', '2026-06-22', 1.07908000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (603, '519696', '交银环球精选混合(QDII)', '2026-06-21', 1.07753000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (604, '519696', '交银环球精选混合(QDII)', '2026-06-20', 1.07743000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (605, '519696', '交银环球精选混合(QDII)', '2026-06-19', 1.07558000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (606, '519696', '交银环球精选混合(QDII)', '2026-06-18', 1.07483000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (607, '519696', '交银环球精选混合(QDII)', '2026-06-17', 1.07308000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (608, '519696', '交银环球精选混合(QDII)', '2026-06-16', 1.07153000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (609, '519696', '交银环球精选混合(QDII)', '2026-06-15', 1.07143000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (610, '519696', '交银环球精选混合(QDII)', '2026-06-14', 1.06958000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (611, '519696', '交银环球精选混合(QDII)', '2026-06-13', 1.06883000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (612, '519696', '交银环球精选混合(QDII)', '2026-06-12', 1.06708000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (613, '519696', '交银环球精选混合(QDII)', '2026-06-11', 1.06553000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (614, '519696', '交银环球精选混合(QDII)', '2026-06-10', 1.06543000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (615, '519696', '交银环球精选混合(QDII)', '2026-06-09', 1.06358000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (616, '519696', '交银环球精选混合(QDII)', '2026-06-08', 1.06283000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (617, '519696', '交银环球精选混合(QDII)', '2026-06-07', 1.06108000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (618, '519696', '交银环球精选混合(QDII)', '2026-06-06', 1.05953000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (619, '519696', '交银环球精选混合(QDII)', '2026-06-05', 1.05943000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (620, '519696', '交银环球精选混合(QDII)', '2026-06-04', 1.05758000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (621, '519696', '交银环球精选混合(QDII)', '2026-06-03', 1.05683000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (622, '519696', '交银环球精选混合(QDII)', '2026-06-02', 1.05508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (623, '519696', '交银环球精选混合(QDII)', '2026-06-01', 1.05353000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (624, '519696', '交银环球精选混合(QDII)', '2026-05-31', 1.05343000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (625, '519696', '交银环球精选混合(QDII)', '2026-05-30', 1.05158000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (626, '519696', '交银环球精选混合(QDII)', '2026-05-29', 1.05083000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (627, '519696', '交银环球精选混合(QDII)', '2026-05-28', 1.04908000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (628, '519696', '交银环球精选混合(QDII)', '2026-05-27', 1.04753000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (629, '519696', '交银环球精选混合(QDII)', '2026-05-26', 1.04743000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (630, '519696', '交银环球精选混合(QDII)', '2026-05-25', 1.04558000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (631, '161039', '富国中证1000指数增强', '2026-06-23', 1.05523000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (632, '161039', '富国中证1000指数增强', '2026-06-22', 1.05447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (633, '161039', '富国中证1000指数增强', '2026-06-21', 1.05271000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (634, '161039', '富国中证1000指数增强', '2026-06-20', 1.05115000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (635, '161039', '富国中证1000指数增强', '2026-06-19', 1.05104000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (636, '161039', '富国中证1000指数增强', '2026-06-18', 1.04918000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (637, '161039', '富国中证1000指数增强', '2026-06-17', 1.04842000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (638, '161039', '富国中证1000指数增强', '2026-06-16', 1.04666000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (639, '161039', '富国中证1000指数增强', '2026-06-15', 1.04510000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (640, '161039', '富国中证1000指数增强', '2026-06-14', 1.04499000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (641, '161039', '富国中证1000指数增强', '2026-06-13', 1.04313000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (642, '161039', '富国中证1000指数增强', '2026-06-12', 1.04237000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (643, '161039', '富国中证1000指数增强', '2026-06-11', 1.04061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (644, '161039', '富国中证1000指数增强', '2026-06-10', 1.03905000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (645, '161039', '富国中证1000指数增强', '2026-06-09', 1.03894000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (646, '161039', '富国中证1000指数增强', '2026-06-08', 1.03708000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (647, '161039', '富国中证1000指数增强', '2026-06-07', 1.03632000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (648, '161039', '富国中证1000指数增强', '2026-06-06', 1.03456000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (649, '161039', '富国中证1000指数增强', '2026-06-05', 1.03300000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (650, '161039', '富国中证1000指数增强', '2026-06-04', 1.03289000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (651, '161039', '富国中证1000指数增强', '2026-06-03', 1.03103000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (652, '161039', '富国中证1000指数增强', '2026-06-02', 1.03027000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (653, '161039', '富国中证1000指数增强', '2026-06-01', 1.02851000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (654, '161039', '富国中证1000指数增强', '2026-05-31', 1.02695000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (655, '161039', '富国中证1000指数增强', '2026-05-30', 1.02684000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (656, '161039', '富国中证1000指数增强', '2026-05-29', 1.02498000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (657, '161039', '富国中证1000指数增强', '2026-05-28', 1.02422000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (658, '161039', '富国中证1000指数增强', '2026-05-27', 1.02246000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (659, '161039', '富国中证1000指数增强', '2026-05-26', 1.02090000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (660, '161039', '富国中证1000指数增强', '2026-05-25', 1.02079000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (661, '159915', '易方达创业板ETF', '2026-06-23', 1.05339000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (662, '159915', '易方达创业板ETF', '2026-06-22', 1.05153000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (663, '159915', '易方达创业板ETF', '2026-06-21', 1.05077000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (664, '159915', '易方达创业板ETF', '2026-06-20', 1.04901000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (665, '159915', '易方达创业板ETF', '2026-06-19', 1.04745000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (666, '159915', '易方达创业板ETF', '2026-06-18', 1.04734000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (667, '159915', '易方达创业板ETF', '2026-06-17', 1.04548000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (668, '159915', '易方达创业板ETF', '2026-06-16', 1.04472000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (669, '159915', '易方达创业板ETF', '2026-06-15', 1.04296000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (670, '159915', '易方达创业板ETF', '2026-06-14', 1.04140000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (671, '159915', '易方达创业板ETF', '2026-06-13', 1.04129000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (672, '159915', '易方达创业板ETF', '2026-06-12', 1.03943000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (673, '159915', '易方达创业板ETF', '2026-06-11', 1.03867000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (674, '159915', '易方达创业板ETF', '2026-06-10', 1.03691000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (675, '159915', '易方达创业板ETF', '2026-06-09', 1.03535000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (676, '159915', '易方达创业板ETF', '2026-06-08', 1.03524000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (677, '159915', '易方达创业板ETF', '2026-06-07', 1.03338000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (678, '159915', '易方达创业板ETF', '2026-06-06', 1.03262000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (679, '159915', '易方达创业板ETF', '2026-06-05', 1.03086000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (680, '159915', '易方达创业板ETF', '2026-06-04', 1.02930000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (681, '159915', '易方达创业板ETF', '2026-06-03', 1.02919000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (682, '159915', '易方达创业板ETF', '2026-06-02', 1.02733000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (683, '159915', '易方达创业板ETF', '2026-06-01', 1.02657000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (684, '159915', '易方达创业板ETF', '2026-05-31', 1.02481000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (685, '159915', '易方达创业板ETF', '2026-05-30', 1.02325000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (686, '159915', '易方达创业板ETF', '2026-05-29', 1.02314000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (687, '159915', '易方达创业板ETF', '2026-05-28', 1.02128000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (688, '159915', '易方达创业板ETF', '2026-05-27', 1.02052000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (689, '159915', '易方达创业板ETF', '2026-05-26', 1.01876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (690, '159915', '易方达创业板ETF', '2026-05-25', 1.01720000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (691, '510300', '华泰柏瑞沪深300ETF', '2026-06-23', 1.07937000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (692, '510300', '华泰柏瑞沪深300ETF', '2026-06-22', 1.07749000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (693, '510300', '华泰柏瑞沪深300ETF', '2026-06-21', 1.07671000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (694, '510300', '华泰柏瑞沪深300ETF', '2026-06-20', 1.07493000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (695, '510300', '华泰柏瑞沪深300ETF', '2026-06-19', 1.07335000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (696, '510300', '华泰柏瑞沪深300ETF', '2026-06-18', 1.07322000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (697, '510300', '华泰柏瑞沪深300ETF', '2026-06-17', 1.07134000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (698, '510300', '华泰柏瑞沪深300ETF', '2026-06-16', 1.07056000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (699, '510300', '华泰柏瑞沪深300ETF', '2026-06-15', 1.06878000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (700, '510300', '华泰柏瑞沪深300ETF', '2026-06-14', 1.06720000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (701, '510300', '华泰柏瑞沪深300ETF', '2026-06-13', 1.06707000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (702, '510300', '华泰柏瑞沪深300ETF', '2026-06-12', 1.06519000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (703, '510300', '华泰柏瑞沪深300ETF', '2026-06-11', 1.06441000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (704, '510300', '华泰柏瑞沪深300ETF', '2026-06-10', 1.06263000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (705, '510300', '华泰柏瑞沪深300ETF', '2026-06-09', 1.06105000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (706, '510300', '华泰柏瑞沪深300ETF', '2026-06-08', 1.06092000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (707, '510300', '华泰柏瑞沪深300ETF', '2026-06-07', 1.05904000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (708, '510300', '华泰柏瑞沪深300ETF', '2026-06-06', 1.05826000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (709, '510300', '华泰柏瑞沪深300ETF', '2026-06-05', 1.05648000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (710, '510300', '华泰柏瑞沪深300ETF', '2026-06-04', 1.05490000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (711, '510300', '华泰柏瑞沪深300ETF', '2026-06-03', 1.05477000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (712, '510300', '华泰柏瑞沪深300ETF', '2026-06-02', 1.05289000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (713, '510300', '华泰柏瑞沪深300ETF', '2026-06-01', 1.05211000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (714, '510300', '华泰柏瑞沪深300ETF', '2026-05-31', 1.05033000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (715, '510300', '华泰柏瑞沪深300ETF', '2026-05-30', 1.04875000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (716, '510300', '华泰柏瑞沪深300ETF', '2026-05-29', 1.04862000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (717, '510300', '华泰柏瑞沪深300ETF', '2026-05-28', 1.04674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (718, '510300', '华泰柏瑞沪深300ETF', '2026-05-27', 1.04596000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (719, '510300', '华泰柏瑞沪深300ETF', '2026-05-26', 1.04418000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (720, '510300', '华泰柏瑞沪深300ETF', '2026-05-25', 1.04260000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (721, '512690', '鹏华中证酒ETF', '2026-06-23', 1.07419000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (722, '512690', '鹏华中证酒ETF', '2026-06-22', 1.07240000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (723, '512690', '鹏华中证酒ETF', '2026-06-21', 1.07081000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (724, '512690', '鹏华中证酒ETF', '2026-06-20', 1.07067000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (725, '512690', '鹏华中证酒ETF', '2026-06-19', 1.06878000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (726, '512690', '鹏华中证酒ETF', '2026-06-18', 1.06799000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (727, '512690', '鹏华中证酒ETF', '2026-06-17', 1.06620000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (728, '512690', '鹏华中证酒ETF', '2026-06-16', 1.06461000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (729, '512690', '鹏华中证酒ETF', '2026-06-15', 1.06447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (730, '512690', '鹏华中证酒ETF', '2026-06-14', 1.06258000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (731, '512690', '鹏华中证酒ETF', '2026-06-13', 1.06179000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (732, '512690', '鹏华中证酒ETF', '2026-06-12', 1.06000000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (733, '512690', '鹏华中证酒ETF', '2026-06-11', 1.05841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (734, '512690', '鹏华中证酒ETF', '2026-06-10', 1.05827000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (735, '512690', '鹏华中证酒ETF', '2026-06-09', 1.05638000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (736, '512690', '鹏华中证酒ETF', '2026-06-08', 1.05559000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (737, '512690', '鹏华中证酒ETF', '2026-06-07', 1.05380000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (738, '512690', '鹏华中证酒ETF', '2026-06-06', 1.05221000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (739, '512690', '鹏华中证酒ETF', '2026-06-05', 1.05207000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (740, '512690', '鹏华中证酒ETF', '2026-06-04', 1.05018000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (741, '512690', '鹏华中证酒ETF', '2026-06-03', 1.04939000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (742, '512690', '鹏华中证酒ETF', '2026-06-02', 1.04760000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (743, '512690', '鹏华中证酒ETF', '2026-06-01', 1.04601000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (744, '512690', '鹏华中证酒ETF', '2026-05-31', 1.04587000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (745, '512690', '鹏华中证酒ETF', '2026-05-30', 1.04398000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (746, '512690', '鹏华中证酒ETF', '2026-05-29', 1.04319000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (747, '512690', '鹏华中证酒ETF', '2026-05-28', 1.04140000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (748, '512690', '鹏华中证酒ETF', '2026-05-27', 1.03981000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (749, '512690', '鹏华中证酒ETF', '2026-05-26', 1.03967000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (750, '512690', '鹏华中证酒ETF', '2026-05-25', 1.03778000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (751, '515790', '华夏中证新能源ETF', '2026-06-23', 1.05238000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (752, '515790', '华夏中证新能源ETF', '2026-06-22', 1.05058000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (753, '515790', '华夏中证新能源ETF', '2026-06-21', 1.04898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (754, '515790', '华夏中证新能源ETF', '2026-06-20', 1.04883000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (755, '515790', '华夏中证新能源ETF', '2026-06-19', 1.04693000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (756, '515790', '华夏中证新能源ETF', '2026-06-18', 1.04613000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (757, '515790', '华夏中证新能源ETF', '2026-06-17', 1.04433000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (758, '515790', '华夏中证新能源ETF', '2026-06-16', 1.04273000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (759, '515790', '华夏中证新能源ETF', '2026-06-15', 1.04258000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (760, '515790', '华夏中证新能源ETF', '2026-06-14', 1.04068000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (761, '515790', '华夏中证新能源ETF', '2026-06-13', 1.03988000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (762, '515790', '华夏中证新能源ETF', '2026-06-12', 1.03808000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (763, '515790', '华夏中证新能源ETF', '2026-06-11', 1.03648000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (764, '515790', '华夏中证新能源ETF', '2026-06-10', 1.03633000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (765, '515790', '华夏中证新能源ETF', '2026-06-09', 1.03443000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (766, '515790', '华夏中证新能源ETF', '2026-06-08', 1.03363000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (767, '515790', '华夏中证新能源ETF', '2026-06-07', 1.03183000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (768, '515790', '华夏中证新能源ETF', '2026-06-06', 1.03023000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (769, '515790', '华夏中证新能源ETF', '2026-06-05', 1.03008000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (770, '515790', '华夏中证新能源ETF', '2026-06-04', 1.02818000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (771, '515790', '华夏中证新能源ETF', '2026-06-03', 1.02738000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (772, '515790', '华夏中证新能源ETF', '2026-06-02', 1.02558000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (773, '515790', '华夏中证新能源ETF', '2026-06-01', 1.02398000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (774, '515790', '华夏中证新能源ETF', '2026-05-31', 1.02383000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (775, '515790', '华夏中证新能源ETF', '2026-05-30', 1.02193000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (776, '515790', '华夏中证新能源ETF', '2026-05-29', 1.02113000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (777, '515790', '华夏中证新能源ETF', '2026-05-28', 1.01933000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (778, '515790', '华夏中证新能源ETF', '2026-05-27', 1.01773000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (779, '515790', '华夏中证新能源ETF', '2026-05-26', 1.01758000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (780, '515790', '华夏中证新能源ETF', '2026-05-25', 1.01568000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (781, '320007', '诺安成长混合', '2026-06-23', 1.04090000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (782, '320007', '诺安成长混合', '2026-06-22', 1.03900000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (783, '320007', '诺安成长混合', '2026-06-21', 1.03820000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (784, '320007', '诺安成长混合', '2026-06-20', 1.03640000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (785, '320007', '诺安成长混合', '2026-06-19', 1.03480000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (786, '320007', '诺安成长混合', '2026-06-18', 1.03465000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (787, '320007', '诺安成长混合', '2026-06-17', 1.03275000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (788, '320007', '诺安成长混合', '2026-06-16', 1.03195000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (789, '320007', '诺安成长混合', '2026-06-15', 1.03015000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (790, '320007', '诺安成长混合', '2026-06-14', 1.02855000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (791, '320007', '诺安成长混合', '2026-06-13', 1.02840000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (792, '320007', '诺安成长混合', '2026-06-12', 1.02650000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (793, '320007', '诺安成长混合', '2026-06-11', 1.02570000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (794, '320007', '诺安成长混合', '2026-06-10', 1.02390000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (795, '320007', '诺安成长混合', '2026-06-09', 1.02230000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (796, '320007', '诺安成长混合', '2026-06-08', 1.02215000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (797, '320007', '诺安成长混合', '2026-06-07', 1.02025000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (798, '320007', '诺安成长混合', '2026-06-06', 1.01945000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (799, '320007', '诺安成长混合', '2026-06-05', 1.01765000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (800, '320007', '诺安成长混合', '2026-06-04', 1.01605000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (801, '320007', '诺安成长混合', '2026-06-03', 1.01590000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (802, '320007', '诺安成长混合', '2026-06-02', 1.01400000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (803, '320007', '诺安成长混合', '2026-06-01', 1.01320000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (804, '320007', '诺安成长混合', '2026-05-31', 1.01140000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (805, '320007', '诺安成长混合', '2026-05-30', 1.00980000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (806, '320007', '诺安成长混合', '2026-05-29', 1.00965000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (807, '320007', '诺安成长混合', '2026-05-28', 1.00775000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (808, '320007', '诺安成长混合', '2026-05-27', 1.00695000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (809, '320007', '诺安成长混合', '2026-05-26', 1.00515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (810, '320007', '诺安成长混合', '2026-05-25', 1.00355000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (811, '260108', '景顺长城新兴成长混合', '2026-06-23', 1.05604000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (812, '260108', '景顺长城新兴成长混合', '2026-06-22', 1.05413000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (813, '260108', '景顺长城新兴成长混合', '2026-06-21', 1.05332000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (814, '260108', '景顺长城新兴成长混合', '2026-06-20', 1.05151000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (815, '260108', '景顺长城新兴成长混合', '2026-06-19', 1.04990000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (816, '260108', '景顺长城新兴成长混合', '2026-06-18', 1.04974000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (817, '260108', '景顺长城新兴成长混合', '2026-06-17', 1.04783000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (818, '260108', '景顺长城新兴成长混合', '2026-06-16', 1.04702000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (819, '260108', '景顺长城新兴成长混合', '2026-06-15', 1.04521000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (820, '260108', '景顺长城新兴成长混合', '2026-06-14', 1.04360000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (821, '260108', '景顺长城新兴成长混合', '2026-06-13', 1.04344000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (822, '260108', '景顺长城新兴成长混合', '2026-06-12', 1.04153000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (823, '260108', '景顺长城新兴成长混合', '2026-06-11', 1.04072000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (824, '260108', '景顺长城新兴成长混合', '2026-06-10', 1.03891000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (825, '260108', '景顺长城新兴成长混合', '2026-06-09', 1.03730000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (826, '260108', '景顺长城新兴成长混合', '2026-06-08', 1.03714000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (827, '260108', '景顺长城新兴成长混合', '2026-06-07', 1.03523000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (828, '260108', '景顺长城新兴成长混合', '2026-06-06', 1.03442000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (829, '260108', '景顺长城新兴成长混合', '2026-06-05', 1.03261000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (830, '260108', '景顺长城新兴成长混合', '2026-06-04', 1.03100000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (831, '260108', '景顺长城新兴成长混合', '2026-06-03', 1.03084000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (832, '260108', '景顺长城新兴成长混合', '2026-06-02', 1.02893000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (833, '260108', '景顺长城新兴成长混合', '2026-06-01', 1.02812000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (834, '260108', '景顺长城新兴成长混合', '2026-05-31', 1.02631000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (835, '260108', '景顺长城新兴成长混合', '2026-05-30', 1.02470000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (836, '260108', '景顺长城新兴成长混合', '2026-05-29', 1.02454000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (837, '260108', '景顺长城新兴成长混合', '2026-05-28', 1.02263000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (838, '260108', '景顺长城新兴成长混合', '2026-05-27', 1.02182000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (839, '260108', '景顺长城新兴成长混合', '2026-05-26', 1.02001000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (840, '260108', '景顺长城新兴成长混合', '2026-05-25', 1.01840000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (841, '163406', '兴全合润混合', '2026-06-23', 1.04103000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (842, '163406', '兴全合润混合', '2026-06-22', 1.04022000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (843, '163406', '兴全合润混合', '2026-06-21', 1.03841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (844, '163406', '兴全合润混合', '2026-06-20', 1.03680000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (845, '163406', '兴全合润混合', '2026-06-19', 1.03664000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (846, '163406', '兴全合润混合', '2026-06-18', 1.03473000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (847, '163406', '兴全合润混合', '2026-06-17', 1.03392000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (848, '163406', '兴全合润混合', '2026-06-16', 1.03211000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (849, '163406', '兴全合润混合', '2026-06-15', 1.03050000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (850, '163406', '兴全合润混合', '2026-06-14', 1.03034000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (851, '163406', '兴全合润混合', '2026-06-13', 1.02843000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (852, '163406', '兴全合润混合', '2026-06-12', 1.02762000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (853, '163406', '兴全合润混合', '2026-06-11', 1.02581000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (854, '163406', '兴全合润混合', '2026-06-10', 1.02420000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (855, '163406', '兴全合润混合', '2026-06-09', 1.02404000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (856, '163406', '兴全合润混合', '2026-06-08', 1.02213000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (857, '163406', '兴全合润混合', '2026-06-07', 1.02132000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (858, '163406', '兴全合润混合', '2026-06-06', 1.01951000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (859, '163406', '兴全合润混合', '2026-06-05', 1.01790000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (860, '163406', '兴全合润混合', '2026-06-04', 1.01774000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (861, '163406', '兴全合润混合', '2026-06-03', 1.01583000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (862, '163406', '兴全合润混合', '2026-06-02', 1.01502000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (863, '163406', '兴全合润混合', '2026-06-01', 1.01321000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (864, '163406', '兴全合润混合', '2026-05-31', 1.01160000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (865, '163406', '兴全合润混合', '2026-05-30', 1.01144000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (866, '163406', '兴全合润混合', '2026-05-29', 1.00953000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (867, '163406', '兴全合润混合', '2026-05-28', 1.00872000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (868, '163406', '兴全合润混合', '2026-05-27', 1.00691000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (869, '163406', '兴全合润混合', '2026-05-26', 1.00530000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (870, '163406', '兴全合润混合', '2026-05-25', 1.00514000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (871, '000452', '南方医药保健灵活配置混合', '2026-06-23', 1.05356000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (872, '000452', '南方医药保健灵活配置混合', '2026-06-22', 1.05341000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (873, '000452', '南方医药保健灵活配置混合', '2026-06-21', 1.05151000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (874, '000452', '南方医药保健灵活配置混合', '2026-06-20', 1.05071000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (875, '000452', '南方医药保健灵活配置混合', '2026-06-19', 1.04891000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (876, '000452', '南方医药保健灵活配置混合', '2026-06-18', 1.04731000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (877, '000452', '南方医药保健灵活配置混合', '2026-06-17', 1.04716000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (878, '000452', '南方医药保健灵活配置混合', '2026-06-16', 1.04526000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (879, '000452', '南方医药保健灵活配置混合', '2026-06-15', 1.04446000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (880, '000452', '南方医药保健灵活配置混合', '2026-06-14', 1.04266000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (881, '000452', '南方医药保健灵活配置混合', '2026-06-13', 1.04106000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (882, '000452', '南方医药保健灵活配置混合', '2026-06-12', 1.04091000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (883, '000452', '南方医药保健灵活配置混合', '2026-06-11', 1.03901000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (884, '000452', '南方医药保健灵活配置混合', '2026-06-10', 1.03821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (885, '000452', '南方医药保健灵活配置混合', '2026-06-09', 1.03641000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (886, '000452', '南方医药保健灵活配置混合', '2026-06-08', 1.03481000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (887, '000452', '南方医药保健灵活配置混合', '2026-06-07', 1.03466000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (888, '000452', '南方医药保健灵活配置混合', '2026-06-06', 1.03276000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (889, '000452', '南方医药保健灵活配置混合', '2026-06-05', 1.03196000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (890, '000452', '南方医药保健灵活配置混合', '2026-06-04', 1.03016000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (891, '000452', '南方医药保健灵活配置混合', '2026-06-03', 1.02856000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (892, '000452', '南方医药保健灵活配置混合', '2026-06-02', 1.02841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (893, '000452', '南方医药保健灵活配置混合', '2026-06-01', 1.02651000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (894, '000452', '南方医药保健灵活配置混合', '2026-05-31', 1.02571000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (895, '000452', '南方医药保健灵活配置混合', '2026-05-30', 1.02391000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (896, '000452', '南方医药保健灵活配置混合', '2026-05-29', 1.02231000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (897, '000452', '南方医药保健灵活配置混合', '2026-05-28', 1.02216000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (898, '000452', '南方医药保健灵活配置混合', '2026-05-27', 1.02026000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (899, '000452', '南方医药保健灵活配置混合', '2026-05-26', 1.01946000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (900, '000452', '南方医药保健灵活配置混合', '2026-05-25', 1.01766000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (901, '040046', '华安纳斯达克100指数', '2026-06-23', 1.05418000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (902, '040046', '华安纳斯达克100指数', '2026-06-22', 1.05337000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (903, '040046', '华安纳斯达克100指数', '2026-06-21', 1.05156000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (904, '040046', '华安纳斯达克100指数', '2026-06-20', 1.04995000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (905, '040046', '华安纳斯达克100指数', '2026-06-19', 1.04979000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (906, '040046', '华安纳斯达克100指数', '2026-06-18', 1.04788000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (907, '040046', '华安纳斯达克100指数', '2026-06-17', 1.04707000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (908, '040046', '华安纳斯达克100指数', '2026-06-16', 1.04526000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (909, '040046', '华安纳斯达克100指数', '2026-06-15', 1.04365000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (910, '040046', '华安纳斯达克100指数', '2026-06-14', 1.04349000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (911, '040046', '华安纳斯达克100指数', '2026-06-13', 1.04158000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (912, '040046', '华安纳斯达克100指数', '2026-06-12', 1.04077000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (913, '040046', '华安纳斯达克100指数', '2026-06-11', 1.03896000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (914, '040046', '华安纳斯达克100指数', '2026-06-10', 1.03735000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (915, '040046', '华安纳斯达克100指数', '2026-06-09', 1.03719000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (916, '040046', '华安纳斯达克100指数', '2026-06-08', 1.03528000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (917, '040046', '华安纳斯达克100指数', '2026-06-07', 1.03447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (918, '040046', '华安纳斯达克100指数', '2026-06-06', 1.03266000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (919, '040046', '华安纳斯达克100指数', '2026-06-05', 1.03105000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (920, '040046', '华安纳斯达克100指数', '2026-06-04', 1.03089000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (921, '040046', '华安纳斯达克100指数', '2026-06-03', 1.02898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (922, '040046', '华安纳斯达克100指数', '2026-06-02', 1.02817000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (923, '040046', '华安纳斯达克100指数', '2026-06-01', 1.02636000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (924, '040046', '华安纳斯达克100指数', '2026-05-31', 1.02475000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (925, '040046', '华安纳斯达克100指数', '2026-05-30', 1.02459000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (926, '040046', '华安纳斯达克100指数', '2026-05-29', 1.02268000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (927, '040046', '华安纳斯达克100指数', '2026-05-28', 1.02187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (928, '040046', '华安纳斯达克100指数', '2026-05-27', 1.02006000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (929, '040046', '华安纳斯达克100指数', '2026-05-26', 1.01845000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (930, '040046', '华安纳斯达克100指数', '2026-05-25', 1.01829000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (931, '513100', '国泰纳斯达克100ETF', '2026-06-23', 1.05276000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (932, '513100', '国泰纳斯达克100ETF', '2026-06-22', 1.05120000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (933, '513100', '国泰纳斯达克100ETF', '2026-06-21', 1.05109000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (934, '513100', '国泰纳斯达克100ETF', '2026-06-20', 1.04923000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (935, '513100', '国泰纳斯达克100ETF', '2026-06-19', 1.04847000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (936, '513100', '国泰纳斯达克100ETF', '2026-06-18', 1.04671000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (937, '513100', '国泰纳斯达克100ETF', '2026-06-17', 1.04515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (938, '513100', '国泰纳斯达克100ETF', '2026-06-16', 1.04504000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (939, '513100', '国泰纳斯达克100ETF', '2026-06-15', 1.04318000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (940, '513100', '国泰纳斯达克100ETF', '2026-06-14', 1.04242000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (941, '513100', '国泰纳斯达克100ETF', '2026-06-13', 1.04066000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (942, '513100', '国泰纳斯达克100ETF', '2026-06-12', 1.03910000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (943, '513100', '国泰纳斯达克100ETF', '2026-06-11', 1.03899000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (944, '513100', '国泰纳斯达克100ETF', '2026-06-10', 1.03713000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (945, '513100', '国泰纳斯达克100ETF', '2026-06-09', 1.03637000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (946, '513100', '国泰纳斯达克100ETF', '2026-06-08', 1.03461000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (947, '513100', '国泰纳斯达克100ETF', '2026-06-07', 1.03305000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (948, '513100', '国泰纳斯达克100ETF', '2026-06-06', 1.03294000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (949, '513100', '国泰纳斯达克100ETF', '2026-06-05', 1.03108000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (950, '513100', '国泰纳斯达克100ETF', '2026-06-04', 1.03032000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (951, '513100', '国泰纳斯达克100ETF', '2026-06-03', 1.02856000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (952, '513100', '国泰纳斯达克100ETF', '2026-06-02', 1.02700000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (953, '513100', '国泰纳斯达克100ETF', '2026-06-01', 1.02689000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (954, '513100', '国泰纳斯达克100ETF', '2026-05-31', 1.02503000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (955, '513100', '国泰纳斯达克100ETF', '2026-05-30', 1.02427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (956, '513100', '国泰纳斯达克100ETF', '2026-05-29', 1.02251000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (957, '513100', '国泰纳斯达克100ETF', '2026-05-28', 1.02095000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (958, '513100', '国泰纳斯达克100ETF', '2026-05-27', 1.02084000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (959, '513100', '国泰纳斯达克100ETF', '2026-05-26', 1.01898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (960, '513100', '国泰纳斯达克100ETF', '2026-05-25', 1.01822000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (961, '000307', '易方达黄金ETF联接A', '2026-06-23', 1.04685000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (962, '000307', '易方达黄金ETF联接A', '2026-06-22', 1.04606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (963, '000307', '易方达黄金ETF联接A', '2026-06-21', 1.04427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (964, '000307', '易方达黄金ETF联接A', '2026-06-20', 1.04268000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (965, '000307', '易方达黄金ETF联接A', '2026-06-19', 1.04254000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (966, '000307', '易方达黄金ETF联接A', '2026-06-18', 1.04065000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (967, '000307', '易方达黄金ETF联接A', '2026-06-17', 1.03986000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (968, '000307', '易方达黄金ETF联接A', '2026-06-16', 1.03807000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (969, '000307', '易方达黄金ETF联接A', '2026-06-15', 1.03648000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (970, '000307', '易方达黄金ETF联接A', '2026-06-14', 1.03634000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (971, '000307', '易方达黄金ETF联接A', '2026-06-13', 1.03445000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (972, '000307', '易方达黄金ETF联接A', '2026-06-12', 1.03366000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (973, '000307', '易方达黄金ETF联接A', '2026-06-11', 1.03187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (974, '000307', '易方达黄金ETF联接A', '2026-06-10', 1.03028000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (975, '000307', '易方达黄金ETF联接A', '2026-06-09', 1.03014000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (976, '000307', '易方达黄金ETF联接A', '2026-06-08', 1.02825000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (977, '000307', '易方达黄金ETF联接A', '2026-06-07', 1.02746000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (978, '000307', '易方达黄金ETF联接A', '2026-06-06', 1.02567000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (979, '000307', '易方达黄金ETF联接A', '2026-06-05', 1.02408000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (980, '000307', '易方达黄金ETF联接A', '2026-06-04', 1.02394000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (981, '000307', '易方达黄金ETF联接A', '2026-06-03', 1.02205000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (982, '000307', '易方达黄金ETF联接A', '2026-06-02', 1.02126000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (983, '000307', '易方达黄金ETF联接A', '2026-06-01', 1.01947000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (984, '000307', '易方达黄金ETF联接A', '2026-05-31', 1.01788000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (985, '000307', '易方达黄金ETF联接A', '2026-05-30', 1.01774000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (986, '000307', '易方达黄金ETF联接A', '2026-05-29', 1.01585000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (987, '000307', '易方达黄金ETF联接A', '2026-05-28', 1.01506000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (988, '000307', '易方达黄金ETF联接A', '2026-05-27', 1.01327000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (989, '000307', '易方达黄金ETF联接A', '2026-05-26', 1.01168000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (990, '000307', '易方达黄金ETF联接A', '2026-05-25', 1.01154000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (991, '518880', '华安黄金ETF', '2026-06-23', 1.06429000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (992, '518880', '华安黄金ETF', '2026-06-22', 1.06243000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (993, '518880', '华安黄金ETF', '2026-06-21', 1.06167000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (994, '518880', '华安黄金ETF', '2026-06-20', 1.05991000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (995, '518880', '华安黄金ETF', '2026-06-19', 1.05835000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (996, '518880', '华安黄金ETF', '2026-06-18', 1.05824000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (997, '518880', '华安黄金ETF', '2026-06-17', 1.05638000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (998, '518880', '华安黄金ETF', '2026-06-16', 1.05562000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (999, '518880', '华安黄金ETF', '2026-06-15', 1.05386000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1000, '518880', '华安黄金ETF', '2026-06-14', 1.05230000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1001, '518880', '华安黄金ETF', '2026-06-13', 1.05219000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1002, '518880', '华安黄金ETF', '2026-06-12', 1.05033000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1003, '518880', '华安黄金ETF', '2026-06-11', 1.04957000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1004, '518880', '华安黄金ETF', '2026-06-10', 1.04781000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1005, '518880', '华安黄金ETF', '2026-06-09', 1.04625000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1006, '518880', '华安黄金ETF', '2026-06-08', 1.04614000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1007, '518880', '华安黄金ETF', '2026-06-07', 1.04428000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1008, '518880', '华安黄金ETF', '2026-06-06', 1.04352000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1009, '518880', '华安黄金ETF', '2026-06-05', 1.04176000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1010, '518880', '华安黄金ETF', '2026-06-04', 1.04020000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1011, '518880', '华安黄金ETF', '2026-06-03', 1.04009000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1012, '518880', '华安黄金ETF', '2026-06-02', 1.03823000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1013, '518880', '华安黄金ETF', '2026-06-01', 1.03747000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1014, '518880', '华安黄金ETF', '2026-05-31', 1.03571000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1015, '518880', '华安黄金ETF', '2026-05-30', 1.03415000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1016, '518880', '华安黄金ETF', '2026-05-29', 1.03404000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1017, '518880', '华安黄金ETF', '2026-05-28', 1.03218000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1018, '518880', '华安黄金ETF', '2026-05-27', 1.03142000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1019, '518880', '华安黄金ETF', '2026-05-26', 1.02966000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1020, '518880', '华安黄金ETF', '2026-05-25', 1.02810000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1021, '161005', '富国天惠成长混合', '2026-06-23', 1.04710000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1022, '161005', '富国天惠成长混合', '2026-06-22', 1.04699000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1023, '161005', '富国天惠成长混合', '2026-06-21', 1.04513000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1024, '161005', '富国天惠成长混合', '2026-06-20', 1.04437000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1025, '161005', '富国天惠成长混合', '2026-06-19', 1.04261000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1026, '161005', '富国天惠成长混合', '2026-06-18', 1.04105000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1027, '161005', '富国天惠成长混合', '2026-06-17', 1.04094000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1028, '161005', '富国天惠成长混合', '2026-06-16', 1.03908000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1029, '161005', '富国天惠成长混合', '2026-06-15', 1.03832000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1030, '161005', '富国天惠成长混合', '2026-06-14', 1.03656000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1031, '161005', '富国天惠成长混合', '2026-06-13', 1.03500000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1032, '161005', '富国天惠成长混合', '2026-06-12', 1.03489000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1033, '161005', '富国天惠成长混合', '2026-06-11', 1.03303000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1034, '161005', '富国天惠成长混合', '2026-06-10', 1.03227000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1035, '161005', '富国天惠成长混合', '2026-06-09', 1.03051000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1036, '161005', '富国天惠成长混合', '2026-06-08', 1.02895000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1037, '161005', '富国天惠成长混合', '2026-06-07', 1.02884000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1038, '161005', '富国天惠成长混合', '2026-06-06', 1.02698000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1039, '161005', '富国天惠成长混合', '2026-06-05', 1.02622000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1040, '161005', '富国天惠成长混合', '2026-06-04', 1.02446000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1041, '161005', '富国天惠成长混合', '2026-06-03', 1.02290000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1042, '161005', '富国天惠成长混合', '2026-06-02', 1.02279000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1043, '161005', '富国天惠成长混合', '2026-06-01', 1.02093000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1044, '161005', '富国天惠成长混合', '2026-05-31', 1.02017000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1045, '161005', '富国天惠成长混合', '2026-05-30', 1.01841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1046, '161005', '富国天惠成长混合', '2026-05-29', 1.01685000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1047, '161005', '富国天惠成长混合', '2026-05-28', 1.01674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1048, '161005', '富国天惠成长混合', '2026-05-27', 1.01488000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1049, '161005', '富国天惠成长混合', '2026-05-26', 1.01412000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1050, '161005', '富国天惠成长混合', '2026-05-25', 1.01236000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1051, '398011', '中海分红增利混合', '2026-06-23', 1.06237000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1052, '398011', '中海分红增利混合', '2026-06-22', 1.06077000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1053, '398011', '中海分红增利混合', '2026-06-21', 1.06062000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1054, '398011', '中海分红增利混合', '2026-06-20', 1.05872000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1055, '398011', '中海分红增利混合', '2026-06-19', 1.05792000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1056, '398011', '中海分红增利混合', '2026-06-18', 1.05612000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1057, '398011', '中海分红增利混合', '2026-06-17', 1.05452000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1058, '398011', '中海分红增利混合', '2026-06-16', 1.05437000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1059, '398011', '中海分红增利混合', '2026-06-15', 1.05247000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1060, '398011', '中海分红增利混合', '2026-06-14', 1.05167000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1061, '398011', '中海分红增利混合', '2026-06-13', 1.04987000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1062, '398011', '中海分红增利混合', '2026-06-12', 1.04827000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1063, '398011', '中海分红增利混合', '2026-06-11', 1.04812000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1064, '398011', '中海分红增利混合', '2026-06-10', 1.04622000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1065, '398011', '中海分红增利混合', '2026-06-09', 1.04542000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1066, '398011', '中海分红增利混合', '2026-06-08', 1.04362000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1067, '398011', '中海分红增利混合', '2026-06-07', 1.04202000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1068, '398011', '中海分红增利混合', '2026-06-06', 1.04187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1069, '398011', '中海分红增利混合', '2026-06-05', 1.03997000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1070, '398011', '中海分红增利混合', '2026-06-04', 1.03917000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1071, '398011', '中海分红增利混合', '2026-06-03', 1.03737000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1072, '398011', '中海分红增利混合', '2026-06-02', 1.03577000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1073, '398011', '中海分红增利混合', '2026-06-01', 1.03562000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1074, '398011', '中海分红增利混合', '2026-05-31', 1.03372000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1075, '398011', '中海分红增利混合', '2026-05-30', 1.03292000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1076, '398011', '中海分红增利混合', '2026-05-29', 1.03112000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1077, '398011', '中海分红增利混合', '2026-05-28', 1.02952000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1078, '398011', '中海分红增利混合', '2026-05-27', 1.02937000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1079, '398011', '中海分红增利混合', '2026-05-26', 1.02747000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1080, '398011', '中海分红增利混合', '2026-05-25', 1.02667000, NULL, '2026-06-23 22:53:34');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
                                 `id` bigint NOT NULL AUTO_INCREMENT,
                                 `user_id` bigint NOT NULL,
                                 `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                 `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
                                 `type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'SYSTEM' COMMENT 'REVIEW_RESULT/SUBSCRIPTION/SYSTEM',
                                 `is_read` tinyint NULL DEFAULT 0,
                                 `related_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                                 `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
                                 PRIMARY KEY (`id`) USING BTREE,
                                 INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
                                 INDEX `idx_user_read`(`user_id` ASC, `is_read` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, 4, '新待审产品', '投顾提交了产品「德邦」，请前往审核。', 'REVIEW_RESULT', 1, '/review/pending/13', '2026-06-26 21:59:52');
INSERT INTO `notification` VALUES (2, 3, '订阅通知', '有用户订阅了您的产品「英伟达」', 'SUBSCRIPTION', 1, '/admin/products/9', '2026-06-27 00:39:34');
INSERT INTO `notification` VALUES (3, 4, '新待审产品', '投顾提交了产品「大成」，请前往审核。', 'REVIEW_RESULT', 1, '/review/pending/11', '2026-06-27 00:46:26');
INSERT INTO `notification` VALUES (4, 3, '审核通过', '您的产品「大成」已通过审核，现已发布。', 'REVIEW_RESULT', 1, '/admin/products/11', '2026-06-27 00:46:59');
INSERT INTO `notification` VALUES (5, 3, '订阅通知', '有用户订阅了您的产品「大成」', 'SUBSCRIPTION', 1, '/admin/products/11', '2026-06-27 00:47:33');
INSERT INTO `notification` VALUES (6, 3, '审核通过', '您的产品「天弘」已通过审核，现已发布。', 'REVIEW_RESULT', 1, '/admin/products/12', '2026-06-27 03:21:46');
INSERT INTO `notification` VALUES (7, 3, '订阅通知', '有用户订阅了您的产品「天弘」', 'SUBSCRIPTION', 1, '/admin/products/12', '2026-06-27 03:56:12');
INSERT INTO `notification` VALUES (8, 3, '订阅通知', '有用户订阅了您的产品「2」', 'SUBSCRIPTION', 1, '/admin/products/3', '2026-06-27 04:07:27');
INSERT INTO `notification` VALUES (9, 2, '订阅成功', '您已成功订阅产品', 'SUBSCRIPTION', 0, '/my-subscriptions', '2026-06-27 04:07:27');
INSERT INTO `notification` VALUES (10, 3, '订阅通知', '有用户取消订阅了您的产品「2」', 'SUBSCRIPTION', 1, '/admin/products/3', '2026-06-27 14:59:59');
INSERT INTO `notification` VALUES (11, 3, '订阅通知', '有用户订阅了您的产品「2」', 'SUBSCRIPTION', 1, '/admin/products/3', '2026-06-27 15:00:34');
INSERT INTO `notification` VALUES (12, 3, '审核通过', '您的产品「德邦」已通过审核，现已发布。', 'REVIEW_RESULT', 1, '/admin/products/13', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for subscription_version_action
-- ----------------------------
DROP TABLE IF EXISTS `subscription_version_action`;
CREATE TABLE `subscription_version_action`  (
                                                `id` bigint NOT NULL AUTO_INCREMENT,
                                                `subscription_id` bigint NOT NULL COMMENT '订阅ID',
                                                `product_id` bigint NOT NULL COMMENT '产品ID',
                                                `product_version_id` bigint NOT NULL COMMENT '版本ID',
                                                `action_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'NOTICE/CONFIRM_REQUIRED',
                                                `action_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'PENDING/CONFIRMED/CANCELLED/NOTIFIED',
                                                `change_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'NORMAL/MAJOR',
                                                `version_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '版本说明',
                                                `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                `handled_at` datetime NULL DEFAULT NULL COMMENT '处理时间',
                                                PRIMARY KEY (`id`) USING BTREE,
                                                UNIQUE INDEX `uk_subscription_version_action`(`subscription_id` ASC, `product_version_id` ASC) USING BTREE,
                                                INDEX `idx_subscription_version_action_product`(`product_id` ASC, `product_version_id` ASC) USING BTREE,
                                                INDEX `idx_subscription_version_action_status`(`action_status` ASC, `action_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订阅版本动作表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subscription_version_action
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `role_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'ADVISOR/REVIEWER/USER',
                             `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_sys_role_code`(`role_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, 'USER', '普通用户', 1, '2026-06-22 19:26:17', '2026-06-22 19:26:17');
INSERT INTO `sys_role` VALUES (2, 'ADVISOR', '投顾', 1, '2026-06-22 19:26:17', '2026-06-22 19:26:17');
INSERT INTO `sys_role` VALUES (3, 'REVIEWER', '审核员', 1, '2026-06-22 19:26:17', '2026-06-22 19:26:17');
INSERT INTO `sys_role` VALUES (4, 'ADMIN', '系统管理员', 1, '2026-06-27 01:21:35', '2026-06-27 01:21:35');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                             `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                             `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                             `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             `sub_pin` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '交易密码（6位数字）',
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_sys_user_username`(`username` ASC) USING BTREE,
                             UNIQUE INDEX `uk_sys_user_phone`(`phone` ASC) USING BTREE,
                             UNIQUE INDEX `uk_sys_user_email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, '12345', '$2a$10$sKIQfeL8MiSxE1l1s4CoY.GS/1uwUwno0OR55XFuLAGCzObbM8zS2', 'LHB', '13983338801', NULL, 1, '2026-06-22 22:59:15', '2026-06-22 22:59:15', NULL);
INSERT INTO `sys_user` VALUES (2, 'user01', '$2b$12$vDM42Vq2dukO1xP5hlEvROBP4xylXf/FEwGxlgHrR.J6ZScGddYyC', '普通用户01', '13800000001', 'user01@test.com', 1, '2026-06-23 20:27:17', '2026-06-27 03:48:21', '123456');
INSERT INTO `sys_user` VALUES (3, 'advisor01', '$2b$12$vDM42Vq2dukO1xP5hlEvROBP4xylXf/FEwGxlgHrR.J6ZScGddYyC', '投顾01', '13800000002', 'advisor01@test.com', 1, '2026-06-23 20:27:17', '2026-06-23 20:27:17', NULL);
INSERT INTO `sys_user` VALUES (4, 'reviewer01', '$2b$12$vDM42Vq2dukO1xP5hlEvROBP4xylXf/FEwGxlgHrR.J6ZScGddYyC', '审核员01', '13800000003', 'reviewer01@test.com', 1, '2026-06-23 20:27:17', '2026-06-27 02:05:24', NULL);
INSERT INTO `sys_user` VALUES (6, 'admin', '$2b$10$pLwSJhvRoU7OgoAkEuwQu.cFMcrl5zQedpxeB2PW2tRiySxqFxJD.', '管理员', NULL, NULL, 1, '2026-06-27 01:21:49', '2026-06-27 01:34:15', NULL);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
                                  `id` bigint NOT NULL AUTO_INCREMENT,
                                  `user_id` bigint NOT NULL,
                                  `role_id` bigint NOT NULL,
                                  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  PRIMARY KEY (`id`) USING BTREE,
                                  UNIQUE INDEX `uk_sys_user_role`(`user_id` ASC, `role_id` ASC) USING BTREE,
                                  INDEX `idx_sur_role_id`(`role_id` ASC) USING BTREE,
                                  CONSTRAINT `fk_sur_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                  CONSTRAINT `fk_sur_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1, 1, '2026-06-22 22:59:15');
INSERT INTO `sys_user_role` VALUES (2, 2, 1, '2026-06-23 20:27:17');
INSERT INTO `sys_user_role` VALUES (3, 3, 2, '2026-06-23 20:27:17');
INSERT INTO `sys_user_role` VALUES (4, 4, 3, '2026-06-23 20:27:17');
INSERT INTO `sys_user_role` VALUES (5, 6, 4, '2026-06-27 01:25:40');

-- ----------------------------
-- Table structure for transaction_record
-- ----------------------------
DROP TABLE IF EXISTS `transaction_record`;
CREATE TABLE `transaction_record`  (
                                       `id` bigint NOT NULL AUTO_INCREMENT,
                                       `user_id` bigint NOT NULL,
                                       `product_id` bigint NOT NULL,
                                       `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                       `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SUBSCRIBE/UNSUBSCRIBE',
                                       `amount` decimal(16, 2) NOT NULL DEFAULT 0.00,
                                       `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'COMPLETED',
                                       `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
                                       PRIMARY KEY (`id`) USING BTREE,
                                       INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
                                       INDEX `idx_user_time`(`user_id` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of transaction_record
-- ----------------------------
INSERT INTO `transaction_record` VALUES (1, 2, 3, '2', 'SUBSCRIBE', 10000.00, 'COMPLETED', '2026-06-27 04:07:27');

SET FOREIGN_KEY_CHECKS = 1;
CREATE DATABASE IF NOT EXISTS finance DEFAULT CHARSET utf8mb4;
USE finance;

/*
 Navicat Premium Data Transfer

 Source Server         : mysql80
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : finance

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 27/06/2026 21:01:18
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for advisor_product
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product`;
CREATE TABLE `advisor_product`  (
                                    `id` bigint NOT NULL AUTO_INCREMENT,
                                    `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '组合名称',
                                    `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'STRATEGY/FOF',
                                    `risk_level` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'R1~R5',
                                    `strategy_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '策略编码',
                                    `feature_tags` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标签（可存逗号或JSON字符串）',
                                    `status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'DRAFT/PENDING_REVIEW/REJECTED/PUBLISHED/OFFLINE',
                                    `creator_id` bigint NOT NULL COMMENT '创建人（投顾）',
                                    `current_version_no` int NOT NULL DEFAULT 0 COMMENT '当前版本号（每次提交审核+1）',
                                    `published_version_no` int NULL DEFAULT NULL COMMENT '已上架版本号（审核通过时写入）',
                                    `last_reject_comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '最近一次驳回意见（便于列表展示，可选）',
                                    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                    PRIMARY KEY (`id`) USING BTREE,
                                    UNIQUE INDEX `uk_advisor_product_name`(`name` ASC) USING BTREE,
                                    INDEX `idx_advisor_product_status`(`status` ASC) USING BTREE,
                                    INDEX `idx_advisor_product_creator`(`creator_id` ASC) USING BTREE,
                                    INDEX `idx_advisor_product_type_risk`(`type` ASC, `risk_level` ASC) USING BTREE,
                                    CONSTRAINT `fk_advisor_product_creator` FOREIGN KEY (`creator_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '投顾组合产品主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product
-- ----------------------------
INSERT INTO `advisor_product` VALUES (1, '天弘全球新能源', '进取型', 'R5', '11', '固收增强', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-23 21:05:07', '2026-06-23 21:05:35');
INSERT INTO `advisor_product` VALUES (2, '1', '平衡型', 'R3', '2', '长期持有', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-23 22:45:38', '2026-06-23 22:54:15');
INSERT INTO `advisor_product` VALUES (3, '2', '平衡型', 'R4', '3', '权益增强', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-24 20:22:35', '2026-06-24 23:53:10');
INSERT INTO `advisor_product` VALUES (4, '平安保险', 'FOF', 'R3', '4', '低波动', 'OFFLINE', 3, 1, 1, NULL, '2026-06-25 00:32:12', '2026-06-25 14:21:32');
INSERT INTO `advisor_product` VALUES (5, '国泰', 'STRATEGY', 'R1', '12', '权益增强', 'REJECTED', 3, 1, NULL, '权重过高', '2026-06-26 18:21:57', '2026-06-26 21:31:13');
INSERT INTO `advisor_product` VALUES (9, '英伟达', 'FOF', 'R1', '11', '权益增强', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-26 18:23:50', '2026-06-26 20:03:54');
INSERT INTO `advisor_product` VALUES (11, '大成', 'STRATEGY', 'R5', '12', '固收增强', 'PUBLISHED', 3, 2, 2, NULL, '2026-06-26 20:13:19', '2026-06-27 00:46:59');
INSERT INTO `advisor_product` VALUES (12, '天弘', 'FOF', 'R2', '33', '固收增强,养老规划', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-26 21:53:47', '2026-06-27 03:21:46');
INSERT INTO `advisor_product` VALUES (13, '德邦', 'FOF', 'R4', '55', '长期持有', 'PUBLISHED', 3, 1, 1, NULL, '2026-06-26 21:59:51', '2026-06-27 15:04:06');
INSERT INTO `advisor_product` VALUES (14, '天弘(副本)', 'FOF', 'R2', '33', '固收增强,养老规划', 'DRAFT', 3, 0, NULL, NULL, '2026-06-27 03:45:43', '2026-06-27 03:45:43');

-- ----------------------------
-- Table structure for advisor_product_component
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_component`;
CREATE TABLE `advisor_product_component`  (
                                              `id` bigint NOT NULL AUTO_INCREMENT,
                                              `product_version_id` bigint NOT NULL,
                                              `fund_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                              `fund_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                              `weight` decimal(10, 4) NOT NULL COMMENT '权重（建议存0~1小数；若存百分比需统一口径）',
                                              `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                              PRIMARY KEY (`id`) USING BTREE,
                                              INDEX `idx_component_version`(`product_version_id` ASC) USING BTREE,
                                              INDEX `idx_component_fund_code`(`fund_code` ASC) USING BTREE,
                                              CONSTRAINT `fk_component_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 62 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品成份（基金及权重，挂版本）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_component
-- ----------------------------
INSERT INTO `advisor_product_component` VALUES (1, 1, '519674', '银河创新成长混合', 1.0000, '2026-06-23 21:05:07');
INSERT INTO `advisor_product_component` VALUES (2, 2, '159915', '易方达创业板ETF', 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (3, 2, '510300', '华泰柏瑞沪深300ETF', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (4, 2, '163406', '兴全合润混合', 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (5, 2, '000452', '南方医药保健灵活配置混合', 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (6, 2, '040046', '华安纳斯达克100指数', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (7, 2, '518880', '华安黄金ETF', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (8, 2, '161005', '富国天惠成长混合', 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_component` VALUES (9, 3, '040046', '华安纳斯达克100指数', 0.3000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_component` VALUES (10, 3, '513100', '国泰纳斯达克100ETF', 0.7000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_component` VALUES (11, 4, '040046', '华安纳斯达克100指数', 0.4000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_component` VALUES (12, 4, '513100', '国泰纳斯达克100ETF', 0.1000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_component` VALUES (13, 4, '161005', '富国天惠成长混合', 0.5000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_component` VALUES (14, 5, '159915', '易方达创业板ETF', 0.0100, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (15, 5, '163406', '兴全合润混合', 0.0500, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (16, 5, '513100', '国泰纳斯达克100ETF', 0.2000, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (17, 5, '518880', '华安黄金ETF', 0.0600, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (18, 5, '161005', '富国天惠成长混合', 0.6800, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_component` VALUES (19, 6, '320007', '诺安成长混合', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (20, 6, '260108', '景顺长城新兴成长混合', 0.0800, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (21, 6, '163406', '兴全合润混合', 0.0120, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (22, 6, '000452', '南方医药保健灵活配置混合', 0.0010, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (23, 6, '040046', '华安纳斯达克100指数', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (24, 6, '513100', '国泰纳斯达克100ETF', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (25, 6, '000307', '易方达黄金ETF联接A', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (26, 6, '518880', '华安黄金ETF', 0.1000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (27, 6, '161005', '富国天惠成长混合', 0.3000, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (28, 6, '398011', '中海分红增利混合', 0.1070, '2026-06-26 20:13:19');
INSERT INTO `advisor_product_component` VALUES (29, 7, '159915', '易方达创业板ETF', 0.0100, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (30, 7, '163406', '兴全合润混合', 0.0500, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (31, 7, '513100', '国泰纳斯达克100ETF', 0.2000, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (32, 7, '518880', '华安黄金ETF', 0.0600, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (33, 7, '161005', '富国天惠成长混合', 0.6800, '2026-06-26 21:30:09');
INSERT INTO `advisor_product_component` VALUES (34, 8, '001838', '国投瑞银国家安全混合', 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (35, 8, '003096', '中欧医疗创新股票A', 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (36, 8, '001717', '工银前沿医疗股票A', 0.1230, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (37, 8, '110011', '易方达中小盘混合', 0.3442, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (38, 8, '519696', '交银环球精选混合(QDII)', 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (39, 8, '161039', '富国中证1000指数增强', 0.0200, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (40, 8, '159915', '易方达创业板ETF', 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (41, 8, '510300', '华泰柏瑞沪深300ETF', 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (42, 8, '512690', '鹏华中证酒ETF', 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (43, 8, '515790', '华夏中证新能源ETF', 0.0628, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_component` VALUES (44, 9, '001632', '天弘中证食品饮料ETF联接A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (45, 9, '005827', '易方达蓝筹精选混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (46, 9, '006113', '汇添富创新医药混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (47, 9, '000248', '汇添富中证主要消费ETF联接', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (48, 9, '001875', '前海开源沪港深优势精选混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (49, 9, '002190', '农银新能源主题灵活配置混合', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (50, 9, '004851', '广发医疗保健股票A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (51, 9, '000960', '招商医药健康产业股票', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (52, 9, '001071', '华夏恒生ETF联接A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (53, 9, '006479', '中欧智能制造混合A', 0.1000, '2026-06-26 21:59:52');
INSERT INTO `advisor_product_component` VALUES (54, 10, '320007', '诺安成长混合', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (55, 10, '260108', '景顺长城新兴成长混合', 0.0800, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (56, 10, '163406', '兴全合润混合', 0.0120, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (57, 10, '000452', '南方医药保健灵活配置混合', 0.0010, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (58, 10, '040046', '华安纳斯达克100指数', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (59, 10, '513100', '国泰纳斯达克100ETF', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (60, 10, '000307', '易方达黄金ETF联接A', 0.1000, '2026-06-27 00:46:26');
INSERT INTO `advisor_product_component` VALUES (61, 10, '398011', '中海分红增利混合', 0.5070, '2026-06-27 00:46:26');

-- ----------------------------
-- Table structure for advisor_product_draft
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_draft`;
CREATE TABLE `advisor_product_draft`  (
                                          `id` bigint NOT NULL AUTO_INCREMENT,
                                          `product_id` bigint NOT NULL COMMENT '产品ID',
                                          `base_info_json` json NOT NULL COMMENT '草稿基础信息',
                                          `params_json` json NULL COMMENT '草稿策略参数',
                                          `updated_by` bigint NOT NULL COMMENT '最后修改人',
                                          `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                          `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                          PRIMARY KEY (`id`) USING BTREE,
                                          UNIQUE INDEX `uk_draft_product_id`(`product_id` ASC) USING BTREE,
                                          INDEX `idx_draft_updated_by`(`updated_by` ASC) USING BTREE,
                                          CONSTRAINT `fk_draft_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                          CONSTRAINT `fk_draft_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品草稿表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_draft
-- ----------------------------
INSERT INTO `advisor_product_draft` VALUES (1, 1, '{\"riskTips\": \"111\", \"productSummary\": \"11\", \"targetCustomer\": \"111\"}', '{\"strategyNotes\": \"11111\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-23 21:05:07', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_draft` VALUES (2, 2, '{\"riskTips\": \"2\", \"productSummary\": \"2\", \"targetCustomer\": \"2\"}', '{\"strategyNotes\": \"222\", \"rebalanceCycleDays\": 3, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.06}', 3, '2026-06-23 22:45:38', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft` VALUES (3, 3, '{\"riskTips\": \"1\", \"productSummary\": \"1\", \"targetCustomer\": \"1\"}', '{\"strategyNotes\": \"1\", \"rebalanceCycleDays\": 2, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-24 20:22:35', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_draft` VALUES (4, 4, '{\"riskTips\": \"低风险\", \"productSummary\": \"养老保险\", \"targetCustomer\": \"老年人\"}', '{\"strategyNotes\": \"无\", \"rebalanceCycleDays\": 4, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.1}', 3, '2026-06-25 00:32:12', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft` VALUES (5, 5, '{\"riskTips\": \"223让人\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 18:21:57', '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft` VALUES (6, 9, '{\"riskTips\": \"223让人\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 18:23:50', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft` VALUES (7, 11, '{\"riskTips\": \"12321313\", \"productSummary\": \"2313131\", \"targetCustomer\": \"131213饿\"}', '{\"strategyNotes\": \"1212112\", \"rebalanceCycleDays\": 142, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 20:13:19', '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft` VALUES (8, 12, '{\"riskTips\": \"2342\", \"productSummary\": \"12\", \"targetCustomer\": \"23\"}', '{\"strategyNotes\": \"2342423\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 34, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 21:53:48', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft` VALUES (9, 13, '{\"riskTips\": \"1234\", \"productSummary\": \"去11\", \"targetCustomer\": \"564\"}', '{\"strategyNotes\": \"1313\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 120, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-26 21:59:51', '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft` VALUES (10, 14, '{\"riskTips\": \"2342\", \"productSummary\": \"12\", \"targetCustomer\": \"23\"}', '{\"strategyNotes\": \"2342423\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 34, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 3, '2026-06-27 03:45:43', '2026-06-27 03:45:43');

-- ----------------------------
-- Table structure for advisor_product_draft_component
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_draft_component`;
CREATE TABLE `advisor_product_draft_component`  (
                                                    `id` bigint NOT NULL AUTO_INCREMENT,
                                                    `draft_id` bigint NOT NULL COMMENT '草稿ID',
                                                    `fund_id` bigint NOT NULL COMMENT '基金ID',
                                                    `weight` decimal(10, 4) NOT NULL COMMENT '权重，建议0~1',
                                                    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                    PRIMARY KEY (`id`) USING BTREE,
                                                    UNIQUE INDEX `uk_draft_fund`(`draft_id` ASC, `fund_id` ASC) USING BTREE,
                                                    INDEX `idx_draft_component_fund_id`(`fund_id` ASC) USING BTREE,
                                                    CONSTRAINT `fk_draft_component_draft` FOREIGN KEY (`draft_id`) REFERENCES `advisor_product_draft` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                    CONSTRAINT `fk_draft_component_fund` FOREIGN KEY (`fund_id`) REFERENCES `fund_info` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品草稿成份表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_draft_component
-- ----------------------------
INSERT INTO `advisor_product_draft_component` VALUES (1, 1, 6, 1.0000, '2026-06-23 21:05:07');
INSERT INTO `advisor_product_draft_component` VALUES (2, 2, 23, 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (3, 2, 24, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (4, 2, 29, 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (5, 2, 30, 0.2000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (6, 2, 31, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (7, 2, 34, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (8, 2, 35, 0.1000, '2026-06-23 22:45:38');
INSERT INTO `advisor_product_draft_component` VALUES (9, 3, 31, 0.3000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_draft_component` VALUES (10, 3, 32, 0.7000, '2026-06-24 20:22:35');
INSERT INTO `advisor_product_draft_component` VALUES (14, 4, 31, 0.4000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft_component` VALUES (15, 4, 32, 0.1000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft_component` VALUES (16, 4, 35, 0.5000, '2026-06-25 00:32:15');
INSERT INTO `advisor_product_draft_component` VALUES (17, 5, 23, 0.0100, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (18, 5, 29, 0.0500, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (19, 5, 32, 0.2000, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (20, 5, 34, 0.0600, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (21, 5, 35, 0.6800, '2026-06-26 18:21:57');
INSERT INTO `advisor_product_draft_component` VALUES (52, 6, 23, 0.0100, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (53, 6, 29, 0.0500, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (54, 6, 32, 0.2000, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (55, 6, 34, 0.0600, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (56, 6, 35, 0.6800, '2026-06-26 18:37:38');
INSERT INTO `advisor_product_draft_component` VALUES (67, 8, 17, 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (68, 8, 18, 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (69, 8, 19, 0.1230, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (70, 8, 20, 0.3442, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (71, 8, 21, 0.0500, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (72, 8, 22, 0.0200, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (73, 8, 23, 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (74, 8, 24, 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (75, 8, 25, 0.1000, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (76, 8, 26, 0.0628, '2026-06-26 21:53:48');
INSERT INTO `advisor_product_draft_component` VALUES (77, 9, 7, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (78, 9, 8, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (79, 9, 9, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (80, 9, 10, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (81, 9, 11, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (82, 9, 12, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (83, 9, 13, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (84, 9, 14, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (85, 9, 15, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (86, 9, 16, 0.1000, '2026-06-26 21:59:51');
INSERT INTO `advisor_product_draft_component` VALUES (87, 7, 27, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (88, 7, 28, 0.0800, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (89, 7, 29, 0.0120, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (90, 7, 30, 0.0010, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (91, 7, 31, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (92, 7, 32, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (93, 7, 33, 0.1000, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (94, 7, 36, 0.5070, '2026-06-27 00:46:25');
INSERT INTO `advisor_product_draft_component` VALUES (95, 10, 17, 0.0500, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (96, 10, 18, 0.0500, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (97, 10, 19, 0.1230, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (98, 10, 20, 0.3442, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (99, 10, 21, 0.0500, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (100, 10, 22, 0.0200, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (101, 10, 23, 0.1000, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (102, 10, 24, 0.1000, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (103, 10, 25, 0.1000, '2026-06-27 03:45:43');
INSERT INTO `advisor_product_draft_component` VALUES (104, 10, 26, 0.0628, '2026-06-27 03:45:43');

-- ----------------------------
-- Table structure for advisor_product_flow_log
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_flow_log`;
CREATE TABLE `advisor_product_flow_log`  (
                                             `id` bigint NOT NULL AUTO_INCREMENT,
                                             `product_id` bigint NOT NULL,
                                             `product_version_id` bigint NULL DEFAULT NULL,
                                             `operator_id` bigint NOT NULL COMMENT '操作人',
                                             `action_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SAVE_DRAFT/SUBMIT/WITHDRAW/APPROVE/REJECT/PUBLISH/OFFLINE',
                                             `comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
                                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                             PRIMARY KEY (`id`) USING BTREE,
                                             INDEX `idx_flow_product`(`product_id` ASC, `action_type` ASC) USING BTREE,
                                             INDEX `idx_flow_version`(`product_version_id` ASC) USING BTREE,
                                             INDEX `idx_flow_operator`(`operator_id` ASC) USING BTREE,
                                             CONSTRAINT `fk_flow_operator` FOREIGN KEY (`operator_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                             CONSTRAINT `fk_flow_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                             CONSTRAINT `fk_flow_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 44 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品流程日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_flow_log
-- ----------------------------
INSERT INTO `advisor_product_flow_log` VALUES (1, 1, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_flow_log` VALUES (2, 1, 1, 3, 'SUBMIT', '提交审核', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_flow_log` VALUES (3, 1, 1, 4, 'APPROVE', '审核通过', '2026-06-23 21:05:35');
INSERT INTO `advisor_product_flow_log` VALUES (4, 2, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_flow_log` VALUES (5, 2, 2, 3, 'SUBMIT', '提交审核', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_flow_log` VALUES (11, 2, 2, 4, 'APPROVE', '审核通过', '2026-06-23 22:54:15');
INSERT INTO `advisor_product_flow_log` VALUES (12, 3, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_flow_log` VALUES (13, 3, 3, 3, 'SUBMIT', '提交审核', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_flow_log` VALUES (14, 3, 3, 4, 'APPROVE', '审核通过', '2026-06-24 23:53:10');
INSERT INTO `advisor_product_flow_log` VALUES (15, 4, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-25 00:32:12');
INSERT INTO `advisor_product_flow_log` VALUES (16, 4, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_flow_log` VALUES (17, 4, 4, 3, 'SUBMIT', '提交审核', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_flow_log` VALUES (18, 4, 4, 4, 'APPROVE', '审核通过', '2026-06-25 00:32:46');
INSERT INTO `advisor_product_flow_log` VALUES (19, 5, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 18:21:57');
INSERT INTO `advisor_product_flow_log` VALUES (20, 9, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 18:23:50');
INSERT INTO `advisor_product_flow_log` VALUES (21, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:29:32');
INSERT INTO `advisor_product_flow_log` VALUES (22, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:32:03');
INSERT INTO `advisor_product_flow_log` VALUES (23, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:32:42');
INSERT INTO `advisor_product_flow_log` VALUES (24, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:37:04');
INSERT INTO `advisor_product_flow_log` VALUES (25, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:37:09');
INSERT INTO `advisor_product_flow_log` VALUES (26, 9, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_flow_log` VALUES (27, 9, 5, 3, 'SUBMIT', '提交审核', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_flow_log` VALUES (28, 9, 5, 4, 'APPROVE', '审核通过', '2026-06-26 20:03:54');
INSERT INTO `advisor_product_flow_log` VALUES (29, 11, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 20:13:19');
INSERT INTO `advisor_product_flow_log` VALUES (30, 11, 6, 3, 'SUBMIT', '提交审核', '2026-06-26 20:13:19');
INSERT INTO `advisor_product_flow_log` VALUES (31, 5, 7, 3, 'SUBMIT', '提交审核', '2026-06-26 21:30:09');
INSERT INTO `advisor_product_flow_log` VALUES (32, 11, 6, 4, 'APPROVE', '审核通过', '2026-06-26 21:30:51');
INSERT INTO `advisor_product_flow_log` VALUES (33, 5, 7, 4, 'REJECT', '权重过高', '2026-06-26 21:31:13');
INSERT INTO `advisor_product_flow_log` VALUES (34, 12, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_flow_log` VALUES (35, 12, 8, 3, 'SUBMIT', '提交审核', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_flow_log` VALUES (36, 13, NULL, 3, 'SAVE_DRAFT', '创建草稿', '2026-06-26 21:59:51');
INSERT INTO `advisor_product_flow_log` VALUES (37, 13, 9, 3, 'SUBMIT', '提交审核', '2026-06-26 21:59:52');
INSERT INTO `advisor_product_flow_log` VALUES (38, 11, NULL, 3, 'SAVE_DRAFT', '更新草稿', '2026-06-27 00:46:25');
INSERT INTO `advisor_product_flow_log` VALUES (39, 11, 10, 3, 'SUBMIT', '提交审核', '2026-06-27 00:46:26');
INSERT INTO `advisor_product_flow_log` VALUES (40, 11, 10, 4, 'APPROVE', '审核通过', '2026-06-27 00:46:59');
INSERT INTO `advisor_product_flow_log` VALUES (41, 12, 8, 4, 'APPROVE', '审核通过', '2026-06-27 03:21:46');
INSERT INTO `advisor_product_flow_log` VALUES (42, 14, NULL, 3, 'COPY', '从产品 天弘(ID:12) 复制创建', '2026-06-27 03:45:43');
INSERT INTO `advisor_product_flow_log` VALUES (43, 13, 9, 4, 'APPROVE', '审核通过', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_holding_snapshot
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_holding_snapshot`;
CREATE TABLE `advisor_product_holding_snapshot`  (
                                                     `id` bigint NOT NULL AUTO_INCREMENT,
                                                     `product_id` bigint NOT NULL,
                                                     `snapshot_date` date NOT NULL,
                                                     `holding_json` json NOT NULL COMMENT '持仓快照（行业/资产/Top持仓等）',
                                                     `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                     PRIMARY KEY (`id`) USING BTREE,
                                                     UNIQUE INDEX `uk_holding_product_date`(`product_id` ASC, `snapshot_date` ASC) USING BTREE,
                                                     INDEX `idx_holding_snapshot_date`(`snapshot_date` ASC) USING BTREE,
                                                     CONSTRAINT `fk_holding_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组合持仓快照（可选扩展）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_holding_snapshot
-- ----------------------------
INSERT INTO `advisor_product_holding_snapshot` VALUES (1, 1, '2026-06-23', '{\"components\": [{\"weight\": 1.0000, \"fundCode\": \"519674\", \"fundName\": \"银河创新成长混合\"}]}', '2026-06-23 23:00:23');
INSERT INTO `advisor_product_holding_snapshot` VALUES (2, 2, '2026-06-23', '{\"components\": [{\"weight\": 0.2000, \"fundCode\": \"159915\", \"fundName\": \"易方达创业板ETF\"}, {\"weight\": 0.1000, \"fundCode\": \"510300\", \"fundName\": \"华泰柏瑞沪深300ETF\"}, {\"weight\": 0.2000, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.2000, \"fundCode\": \"000452\", \"fundName\": \"南方医药保健灵活配置混合\"}, {\"weight\": 0.1000, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1000, \"fundCode\": \"518880\", \"fundName\": \"华安黄金ETF\"}, {\"weight\": 0.1000, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}]}', '2026-06-23 23:00:23');
INSERT INTO `advisor_product_holding_snapshot` VALUES (3, 3, '2026-06-24', '{\"components\": [{\"weight\": 0.3, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.7, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}]}', '2026-06-24 23:53:10');
INSERT INTO `advisor_product_holding_snapshot` VALUES (4, 4, '2026-06-25', '{\"components\": [{\"weight\": 0.4, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.5, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}]}', '2026-06-25 00:32:46');
INSERT INTO `advisor_product_holding_snapshot` VALUES (5, 9, '2026-06-26', '{\"components\": [{\"weight\": 0.01, \"fundCode\": \"159915\", \"fundName\": \"易方达创业板ETF\"}, {\"weight\": 0.05, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.2, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.06, \"fundCode\": \"518880\", \"fundName\": \"华安黄金ETF\"}, {\"weight\": 0.68, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}]}', '2026-06-26 20:03:54');
INSERT INTO `advisor_product_holding_snapshot` VALUES (6, 11, '2026-06-26', '{\"components\": [{\"weight\": 0.1, \"fundCode\": \"320007\", \"fundName\": \"诺安成长混合\"}, {\"weight\": 0.08, \"fundCode\": \"260108\", \"fundName\": \"景顺长城新兴成长混合\"}, {\"weight\": 0.012, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.001, \"fundCode\": \"000452\", \"fundName\": \"南方医药保健灵活配置混合\"}, {\"weight\": 0.1, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.1, \"fundCode\": \"000307\", \"fundName\": \"易方达黄金ETF联接A\"}, {\"weight\": 0.1, \"fundCode\": \"518880\", \"fundName\": \"华安黄金ETF\"}, {\"weight\": 0.3, \"fundCode\": \"161005\", \"fundName\": \"富国天惠成长混合\"}, {\"weight\": 0.107, \"fundCode\": \"398011\", \"fundName\": \"中海分红增利混合\"}]}', '2026-06-26 21:30:51');
INSERT INTO `advisor_product_holding_snapshot` VALUES (7, 11, '2026-06-27', '{\"components\": [{\"weight\": 0.1, \"fundCode\": \"320007\", \"fundName\": \"诺安成长混合\"}, {\"weight\": 0.08, \"fundCode\": \"260108\", \"fundName\": \"景顺长城新兴成长混合\"}, {\"weight\": 0.012, \"fundCode\": \"163406\", \"fundName\": \"兴全合润混合\"}, {\"weight\": 0.001, \"fundCode\": \"000452\", \"fundName\": \"南方医药保健灵活配置混合\"}, {\"weight\": 0.1, \"fundCode\": \"040046\", \"fundName\": \"华安纳斯达克100指数\"}, {\"weight\": 0.1, \"fundCode\": \"513100\", \"fundName\": \"国泰纳斯达克100ETF\"}, {\"weight\": 0.1, \"fundCode\": \"000307\", \"fundName\": \"易方达黄金ETF联接A\"}, {\"weight\": 0.507, \"fundCode\": \"398011\", \"fundName\": \"中海分红增利混合\"}]}', '2026-06-27 00:46:59');
INSERT INTO `advisor_product_holding_snapshot` VALUES (8, 12, '2026-06-27', '{\"components\": [{\"weight\": 0.05, \"fundCode\": \"001838\", \"fundName\": \"国投瑞银国家安全混合\"}, {\"weight\": 0.05, \"fundCode\": \"003096\", \"fundName\": \"中欧医疗创新股票A\"}, {\"weight\": 0.123, \"fundCode\": \"001717\", \"fundName\": \"工银前沿医疗股票A\"}, {\"weight\": 0.3442, \"fundCode\": \"110011\", \"fundName\": \"易方达中小盘混合\"}, {\"weight\": 0.05, \"fundCode\": \"519696\", \"fundName\": \"交银环球精选混合(QDII)\"}, {\"weight\": 0.02, \"fundCode\": \"161039\", \"fundName\": \"富国中证1000指数增强\"}, {\"weight\": 0.1, \"fundCode\": \"159915\", \"fundName\": \"易方达创业板ETF\"}, {\"weight\": 0.1, \"fundCode\": \"510300\", \"fundName\": \"华泰柏瑞沪深300ETF\"}, {\"weight\": 0.1, \"fundCode\": \"512690\", \"fundName\": \"鹏华中证酒ETF\"}, {\"weight\": 0.0628, \"fundCode\": \"515790\", \"fundName\": \"华夏中证新能源ETF\"}]}', '2026-06-27 03:21:46');
INSERT INTO `advisor_product_holding_snapshot` VALUES (9, 13, '2026-06-27', '{\"components\": [{\"weight\": 0.1, \"fundCode\": \"001632\", \"fundName\": \"天弘中证食品饮料ETF联接A\"}, {\"weight\": 0.1, \"fundCode\": \"005827\", \"fundName\": \"易方达蓝筹精选混合\"}, {\"weight\": 0.1, \"fundCode\": \"006113\", \"fundName\": \"汇添富创新医药混合\"}, {\"weight\": 0.1, \"fundCode\": \"000248\", \"fundName\": \"汇添富中证主要消费ETF联接\"}, {\"weight\": 0.1, \"fundCode\": \"001875\", \"fundName\": \"前海开源沪港深优势精选混合\"}, {\"weight\": 0.1, \"fundCode\": \"002190\", \"fundName\": \"农银新能源主题灵活配置混合\"}, {\"weight\": 0.1, \"fundCode\": \"004851\", \"fundName\": \"广发医疗保健股票A\"}, {\"weight\": 0.1, \"fundCode\": \"000960\", \"fundName\": \"招商医药健康产业股票\"}, {\"weight\": 0.1, \"fundCode\": \"001071\", \"fundName\": \"华夏恒生ETF联接A\"}, {\"weight\": 0.1, \"fundCode\": \"006479\", \"fundName\": \"中欧智能制造混合A\"}]}', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_nav
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_nav`;
CREATE TABLE `advisor_product_nav`  (
                                        `id` bigint NOT NULL AUTO_INCREMENT,
                                        `product_id` bigint NOT NULL,
                                        `nav_date` date NOT NULL,
                                        `nav` decimal(18, 8) NOT NULL COMMENT '单位净值',
                                        `cum_return` decimal(18, 8) NULL DEFAULT NULL COMMENT '累计收益（可选）',
                                        `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                        PRIMARY KEY (`id`) USING BTREE,
                                        UNIQUE INDEX `uk_nav_product_date`(`product_id` ASC, `nav_date` ASC) USING BTREE,
                                        INDEX `idx_nav_date`(`nav_date` ASC) USING BTREE,
                                        CONSTRAINT `fk_nav_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 241 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组合收益/净值' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_nav
-- ----------------------------
INSERT INTO `advisor_product_nav` VALUES (1, 2, '2026-05-25', 1.00000000, 0.00000000, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (2, 2, '2026-05-26', 1.00118516, 0.00118516, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (3, 2, '2026-05-27', 1.00258388, 0.00258388, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (4, 2, '2026-05-28', 1.00397708, 0.00397708, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (5, 2, '2026-05-29', 1.00498509, 0.00498509, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (6, 2, '2026-05-30', 1.00606604, 0.00606604, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (7, 2, '2026-05-31', 1.00725120, 0.00725120, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (8, 2, '2026-06-01', 1.00864992, 0.00864992, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (9, 2, '2026-06-02', 1.01004312, 0.01004312, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (10, 2, '2026-06-03', 1.01105112, 0.01105112, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (11, 2, '2026-06-04', 1.01213208, 0.01213208, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (12, 2, '2026-06-05', 1.01331723, 0.01331723, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (13, 2, '2026-06-06', 1.01471596, 0.01471596, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (14, 2, '2026-06-07', 1.01610915, 0.01610915, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (15, 2, '2026-06-08', 1.01711716, 0.01711716, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (16, 2, '2026-06-09', 1.01819811, 0.01819811, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (17, 2, '2026-06-10', 1.01938327, 0.01938327, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (18, 2, '2026-06-11', 1.02078199, 0.02078199, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (19, 2, '2026-06-12', 1.02217519, 0.02217519, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (20, 2, '2026-06-13', 1.02318320, 0.02318320, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (21, 2, '2026-06-14', 1.02426415, 0.02426415, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (22, 2, '2026-06-15', 1.02544931, 0.02544931, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (23, 2, '2026-06-16', 1.02684803, 0.02684803, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (24, 2, '2026-06-17', 1.02824123, 0.02824123, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (25, 2, '2026-06-18', 1.02924924, 0.02924924, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (26, 2, '2026-06-19', 1.03033019, 0.03033019, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (27, 2, '2026-06-20', 1.03151535, 0.03151535, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (28, 2, '2026-06-21', 1.03291407, 0.03291407, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (29, 2, '2026-06-22', 1.03430727, 0.03430727, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (30, 2, '2026-06-23', 1.03531528, 0.03531528, '2026-06-23 22:54:15');
INSERT INTO `advisor_product_nav` VALUES (31, 3, '2026-05-25', 1.00000000, 0.00000000, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (32, 3, '2026-05-26', 1.00056962, 0.00056962, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (33, 3, '2026-05-27', 1.00232265, 0.00232265, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (34, 3, '2026-05-28', 1.00293152, 0.00293152, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (35, 3, '2026-05-29', 1.00424261, 0.00424261, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (36, 3, '2026-05-30', 1.00601527, 0.00601527, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (37, 3, '2026-05-31', 1.00658489, 0.00658489, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (38, 3, '2026-06-01', 1.00833792, 0.00833792, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (39, 3, '2026-06-02', 1.00894679, 0.00894679, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (40, 3, '2026-06-03', 1.01025788, 0.01025788, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (41, 3, '2026-06-04', 1.01203054, 0.01203054, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (42, 3, '2026-06-05', 1.01260016, 0.01260016, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (43, 3, '2026-06-06', 1.01435319, 0.01435319, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (44, 3, '2026-06-07', 1.01496206, 0.01496206, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (45, 3, '2026-06-08', 1.01627315, 0.01627315, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (46, 3, '2026-06-09', 1.01804581, 0.01804581, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (47, 3, '2026-06-10', 1.01861543, 0.01861543, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (48, 3, '2026-06-11', 1.02036846, 0.02036846, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (49, 3, '2026-06-12', 1.02097733, 0.02097733, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (50, 3, '2026-06-13', 1.02228843, 0.02228843, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (51, 3, '2026-06-14', 1.02406109, 0.02406109, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (52, 3, '2026-06-15', 1.02463071, 0.02463071, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (53, 3, '2026-06-16', 1.02638373, 0.02638373, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (54, 3, '2026-06-17', 1.02699261, 0.02699261, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (55, 3, '2026-06-18', 1.02830370, 0.02830370, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (56, 3, '2026-06-19', 1.03007636, 0.03007636, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (57, 3, '2026-06-20', 1.03064598, 0.03064598, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (58, 3, '2026-06-21', 1.03239901, 0.03239901, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (59, 3, '2026-06-22', 1.03300788, 0.03300788, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (60, 3, '2026-06-23', 1.03431897, 0.03431897, '2026-06-24 23:53:10');
INSERT INTO `advisor_product_nav` VALUES (61, 4, '2026-05-25', 1.00000000, 0.00000000, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (62, 4, '2026-05-26', 1.00100675, 0.00100675, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (63, 4, '2026-05-27', 1.00219721, 0.00219721, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (64, 4, '2026-05-28', 1.00383766, 0.00383766, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (65, 4, '2026-05-29', 1.00436337, 0.00436337, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (66, 4, '2026-05-30', 1.00605698, 0.00605698, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (67, 4, '2026-05-31', 1.00706373, 0.00706373, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (68, 4, '2026-06-01', 1.00825419, 0.00825419, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (69, 4, '2026-06-02', 1.00989464, 0.00989464, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (70, 4, '2026-06-03', 1.01042035, 0.01042035, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (71, 4, '2026-06-04', 1.01211396, 0.01211396, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (72, 4, '2026-06-05', 1.01312070, 0.01312070, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (73, 4, '2026-06-06', 1.01431117, 0.01431117, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (74, 4, '2026-06-07', 1.01595161, 0.01595161, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (75, 4, '2026-06-08', 1.01647733, 0.01647733, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (76, 4, '2026-06-09', 1.01817093, 0.01817093, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (77, 4, '2026-06-10', 1.01917768, 0.01917768, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (78, 4, '2026-06-11', 1.02036815, 0.02036815, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (79, 4, '2026-06-12', 1.02200859, 0.02200859, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (80, 4, '2026-06-13', 1.02253431, 0.02253431, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (81, 4, '2026-06-14', 1.02422792, 0.02422792, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (82, 4, '2026-06-15', 1.02523466, 0.02523466, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (83, 4, '2026-06-16', 1.02642513, 0.02642513, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (84, 4, '2026-06-17', 1.02806557, 0.02806557, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (85, 4, '2026-06-18', 1.02859129, 0.02859129, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (86, 4, '2026-06-19', 1.03028489, 0.03028489, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (87, 4, '2026-06-20', 1.03129164, 0.03129164, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (88, 4, '2026-06-21', 1.03248211, 0.03248211, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (89, 4, '2026-06-22', 1.03412255, 0.03412255, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (90, 4, '2026-06-23', 1.03464827, 0.03464827, '2026-06-25 00:32:46');
INSERT INTO `advisor_product_nav` VALUES (91, 9, '2026-05-25', 1.00000000, 0.00000000, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (92, 9, '2026-05-26', 1.00144580, 0.00144580, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (93, 9, '2026-05-27', 1.00252174, 0.00252174, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (94, 9, '2026-05-28', 1.00393457, 0.00393457, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (95, 9, '2026-05-29', 1.00448200, 0.00448200, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (96, 9, '2026-05-30', 1.00597806, 0.00597806, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (97, 9, '2026-05-31', 1.00742387, 0.00742387, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (98, 9, '2026-06-01', 1.00849981, 0.00849981, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (99, 9, '2026-06-02', 1.00991264, 0.00991264, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (100, 9, '2026-06-03', 1.01046007, 0.01046007, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (101, 9, '2026-06-04', 1.01195613, 0.01195613, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (102, 9, '2026-06-05', 1.01340193, 0.01340193, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (103, 9, '2026-06-06', 1.01447787, 0.01447787, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (104, 9, '2026-06-07', 1.01589070, 0.01589070, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (105, 9, '2026-06-08', 1.01643813, 0.01643813, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (106, 9, '2026-06-09', 1.01793419, 0.01793419, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (107, 9, '2026-06-10', 1.01938000, 0.01938000, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (108, 9, '2026-06-11', 1.02045594, 0.02045594, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (109, 9, '2026-06-12', 1.02186876, 0.02186876, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (110, 9, '2026-06-13', 1.02241620, 0.02241620, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (111, 9, '2026-06-14', 1.02391226, 0.02391226, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (112, 9, '2026-06-15', 1.02535806, 0.02535806, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (113, 9, '2026-06-16', 1.02643400, 0.02643400, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (114, 9, '2026-06-17', 1.02784683, 0.02784683, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (115, 9, '2026-06-18', 1.02839426, 0.02839426, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (116, 9, '2026-06-19', 1.02989032, 0.02989032, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (117, 9, '2026-06-20', 1.03133613, 0.03133613, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (118, 9, '2026-06-21', 1.03241207, 0.03241207, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (119, 9, '2026-06-22', 1.03382490, 0.03382490, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (120, 9, '2026-06-23', 1.03437233, 0.03437233, '2026-06-26 20:03:54');
INSERT INTO `advisor_product_nav` VALUES (151, 11, '2026-05-25', 1.00000000, 0.00000000, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (152, 11, '2026-05-26', 1.00078884, 0.00078884, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (153, 11, '2026-05-27', 1.00256664, 0.00256664, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (154, 11, '2026-05-28', 1.00317305, 0.00317305, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (155, 11, '2026-05-29', 1.00462321, 0.00462321, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (156, 11, '2026-05-30', 1.00611126, 0.00611126, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (157, 11, '2026-05-31', 1.00690010, 0.00690010, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (158, 11, '2026-06-01', 1.00867789, 0.00867789, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (159, 11, '2026-06-02', 1.00928430, 0.00928430, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (160, 11, '2026-06-03', 1.01073447, 0.01073447, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (161, 11, '2026-06-04', 1.01222252, 0.01222252, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (162, 11, '2026-06-05', 1.01301136, 0.01301136, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (163, 11, '2026-06-06', 1.01478916, 0.01478916, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (164, 11, '2026-06-07', 1.01539556, 0.01539556, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (165, 11, '2026-06-08', 1.01684573, 0.01684573, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (166, 11, '2026-06-09', 1.01833377, 0.01833377, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (167, 11, '2026-06-10', 1.01912262, 0.01912262, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (168, 11, '2026-06-11', 1.02090041, 0.02090041, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (169, 11, '2026-06-12', 1.02150682, 0.02150682, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (170, 11, '2026-06-13', 1.02295698, 0.02295698, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (171, 11, '2026-06-14', 1.02444503, 0.02444503, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (172, 11, '2026-06-15', 1.02523388, 0.02523388, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (173, 11, '2026-06-16', 1.02701167, 0.02701167, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (174, 11, '2026-06-17', 1.02761808, 0.02761808, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (175, 11, '2026-06-18', 1.02906824, 0.02906824, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (176, 11, '2026-06-19', 1.03055629, 0.03055629, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (177, 11, '2026-06-20', 1.03134513, 0.03134513, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (178, 11, '2026-06-21', 1.03312293, 0.03312293, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (179, 11, '2026-06-22', 1.03372934, 0.03372934, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (180, 11, '2026-06-23', 1.03517950, 0.03517950, '2026-06-27 00:46:59');
INSERT INTO `advisor_product_nav` VALUES (181, 12, '2026-05-25', 1.00000000, 0.00000000, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (182, 12, '2026-05-26', 1.00166693, 0.00166693, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (183, 12, '2026-05-27', 1.00239198, 0.00239198, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (184, 12, '2026-05-28', 1.00371365, 0.00371365, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (185, 12, '2026-05-29', 1.00525453, 0.00525453, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (186, 12, '2026-05-30', 1.00602931, 0.00602931, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (187, 12, '2026-05-31', 1.00769624, 0.00769624, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (188, 12, '2026-06-01', 1.00842130, 0.00842130, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (189, 12, '2026-06-02', 1.00974296, 0.00974296, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (190, 12, '2026-06-03', 1.01128384, 0.01128384, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (191, 12, '2026-06-04', 1.01205862, 0.01205862, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (192, 12, '2026-06-05', 1.01372555, 0.01372555, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (193, 12, '2026-06-06', 1.01445061, 0.01445061, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (194, 12, '2026-06-07', 1.01577228, 0.01577228, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (195, 12, '2026-06-08', 1.01731315, 0.01731315, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (196, 12, '2026-06-09', 1.01808793, 0.01808793, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (197, 12, '2026-06-10', 1.01975486, 0.01975486, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (198, 12, '2026-06-11', 1.02047992, 0.02047992, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (199, 12, '2026-06-12', 1.02180159, 0.02180159, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (200, 12, '2026-06-13', 1.02334246, 0.02334246, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (201, 12, '2026-06-14', 1.02411725, 0.02411725, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (202, 12, '2026-06-15', 1.02578417, 0.02578417, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (203, 12, '2026-06-16', 1.02650923, 0.02650923, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (204, 12, '2026-06-17', 1.02783090, 0.02783090, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (205, 12, '2026-06-18', 1.02937177, 0.02937177, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (206, 12, '2026-06-19', 1.03014656, 0.03014656, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (207, 12, '2026-06-20', 1.03181348, 0.03181348, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (208, 12, '2026-06-21', 1.03253854, 0.03253854, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (209, 12, '2026-06-22', 1.03386021, 0.03386021, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (210, 12, '2026-06-23', 1.03540108, 0.03540108, '2026-06-27 03:21:46');
INSERT INTO `advisor_product_nav` VALUES (211, 13, '2026-05-25', 1.00000000, 0.00000000, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (212, 13, '2026-05-26', 1.00113051, 0.00113051, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (213, 13, '2026-05-27', 1.00194102, 0.00194102, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (214, 13, '2026-05-28', 1.00361134, 0.00361134, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (215, 13, '2026-05-29', 1.00463860, 0.00463860, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (216, 13, '2026-05-30', 1.00597469, 0.00597469, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (217, 13, '2026-05-31', 1.00710520, 0.00710520, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (218, 13, '2026-06-01', 1.00791572, 0.00791572, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (219, 13, '2026-06-02', 1.00958603, 0.00958603, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (220, 13, '2026-06-03', 1.01061329, 0.01061329, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (221, 13, '2026-06-04', 1.01194939, 0.01194939, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (222, 13, '2026-06-05', 1.01307990, 0.01307990, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (223, 13, '2026-06-06', 1.01389041, 0.01389041, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (224, 13, '2026-06-07', 1.01556072, 0.01556072, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (225, 13, '2026-06-08', 1.01658798, 0.01658798, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (226, 13, '2026-06-09', 1.01792408, 0.01792408, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (227, 13, '2026-06-10', 1.01905459, 0.01905459, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (228, 13, '2026-06-11', 1.01986510, 0.01986510, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (229, 13, '2026-06-12', 1.02153542, 0.02153542, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (230, 13, '2026-06-13', 1.02256268, 0.02256268, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (231, 13, '2026-06-14', 1.02389877, 0.02389877, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (232, 13, '2026-06-15', 1.02502928, 0.02502928, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (233, 13, '2026-06-16', 1.02583979, 0.02583979, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (234, 13, '2026-06-17', 1.02751011, 0.02751011, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (235, 13, '2026-06-18', 1.02853737, 0.02853737, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (236, 13, '2026-06-19', 1.02987347, 0.02987347, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (237, 13, '2026-06-20', 1.03100398, 0.03100398, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (238, 13, '2026-06-21', 1.03181449, 0.03181449, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (239, 13, '2026-06-22', 1.03348480, 0.03348480, '2026-06-27 15:04:07');
INSERT INTO `advisor_product_nav` VALUES (240, 13, '2026-06-23', 1.03451206, 0.03451206, '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_review
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_review`;
CREATE TABLE `advisor_product_review`  (
                                           `id` bigint NOT NULL AUTO_INCREMENT,
                                           `product_id` bigint NOT NULL,
                                           `product_version_id` bigint NOT NULL,
                                           `reviewer_id` bigint NOT NULL,
                                           `result` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'APPROVED/REJECTED',
                                           `comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '审核意见/驳回原因',
                                           `reviewed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                           PRIMARY KEY (`id`) USING BTREE,
                                           INDEX `idx_review_product`(`product_id` ASC) USING BTREE,
                                           INDEX `idx_review_version`(`product_version_id` ASC) USING BTREE,
                                           INDEX `idx_review_reviewer`(`reviewer_id` ASC) USING BTREE,
                                           INDEX `idx_review_time`(`reviewed_at` ASC) USING BTREE,
                                           CONSTRAINT `fk_review_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                           CONSTRAINT `fk_review_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                           CONSTRAINT `fk_review_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品审核记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_review
-- ----------------------------
INSERT INTO `advisor_product_review` VALUES (1, 1, 1, 4, 'APPROVED', '审核通过', '2026-06-23 21:05:35');
INSERT INTO `advisor_product_review` VALUES (7, 2, 2, 4, 'APPROVED', '审核通过', '2026-06-23 22:54:15');
INSERT INTO `advisor_product_review` VALUES (8, 3, 3, 4, 'APPROVED', '审核通过', '2026-06-24 23:53:10');
INSERT INTO `advisor_product_review` VALUES (9, 4, 4, 4, 'APPROVED', '审核通过', '2026-06-25 00:32:46');
INSERT INTO `advisor_product_review` VALUES (10, 9, 5, 4, 'APPROVED', '审核通过', '2026-06-26 20:03:54');
INSERT INTO `advisor_product_review` VALUES (11, 11, 6, 4, 'APPROVED', '审核通过', '2026-06-26 21:30:51');
INSERT INTO `advisor_product_review` VALUES (12, 5, 7, 4, 'REJECTED', '权重过高', '2026-06-26 21:31:13');
INSERT INTO `advisor_product_review` VALUES (13, 11, 10, 4, 'APPROVED', '审核通过', '2026-06-27 00:46:59');
INSERT INTO `advisor_product_review` VALUES (14, 12, 8, 4, 'APPROVED', '审核通过', '2026-06-27 03:21:46');
INSERT INTO `advisor_product_review` VALUES (15, 13, 9, 4, 'APPROVED', '审核通过', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for advisor_product_rule_decision
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_rule_decision`;
CREATE TABLE `advisor_product_rule_decision`  (
                                                  `id` bigint NOT NULL AUTO_INCREMENT,
                                                  `product_id` bigint NOT NULL,
                                                  `product_version_id` bigint NOT NULL,
                                                  `base_rule_id` bigint NOT NULL COMMENT '引用的默认规则ID',
                                                  `reviewer_id` bigint NOT NULL,
                                                  `override_min_fund_count` int NULL DEFAULT NULL COMMENT '审核覆盖：最少成份数（可空）',
                                                  `override_max_fund_count` int NULL DEFAULT NULL COMMENT '审核覆盖：最多成份数（可空）',
                                                  `override_max_single_weight` decimal(10, 4) NULL DEFAULT NULL COMMENT '审核覆盖：单基金最大权重（可空）',
                                                  `final_rule_json` json NOT NULL COMMENT '最终规则快照（默认规则+覆盖后的固化结果）',
                                                  `decision_comment` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '调整原因/说明',
                                                  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                  PRIMARY KEY (`id`) USING BTREE,
                                                  UNIQUE INDEX `uk_rule_decision_version`(`product_version_id` ASC) USING BTREE,
                                                  INDEX `idx_rule_decision_product`(`product_id` ASC) USING BTREE,
                                                  INDEX `fk_rule_decision_rule`(`base_rule_id` ASC) USING BTREE,
                                                  INDEX `fk_rule_decision_reviewer`(`reviewer_id` ASC) USING BTREE,
                                                  CONSTRAINT `fk_rule_decision_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                  CONSTRAINT `fk_rule_decision_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                  CONSTRAINT `fk_rule_decision_rule` FOREIGN KEY (`base_rule_id`) REFERENCES `advisor_strategy_rule` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                  CONSTRAINT `fk_rule_decision_version` FOREIGN KEY (`product_version_id`) REFERENCES `advisor_product_version` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '投决会规则调整决议（按版本留痕）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_rule_decision
-- ----------------------------

-- ----------------------------
-- Table structure for advisor_product_subscription
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_subscription`;
CREATE TABLE `advisor_product_subscription`  (
                                                 `id` bigint NOT NULL AUTO_INCREMENT,
                                                 `product_id` bigint NOT NULL,
                                                 `user_id` bigint NOT NULL,
                                                 `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/CANCELLED',
                                                 `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                 `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                                 `invest_amount` decimal(16, 2) NULL DEFAULT 0.00 COMMENT '投入金额',
                                                 `current_value` decimal(16, 2) NULL DEFAULT 0.00 COMMENT '当前市值',
                                                 PRIMARY KEY (`id`) USING BTREE,
                                                 UNIQUE INDEX `uk_sub_user_product`(`user_id` ASC, `product_id` ASC) USING BTREE,
                                                 INDEX `idx_sub_product`(`product_id` ASC) USING BTREE,
                                                 INDEX `idx_sub_user`(`user_id` ASC) USING BTREE,
                                                 CONSTRAINT `fk_sub_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                                 CONSTRAINT `fk_sub_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '组合订阅记录（最小闭环）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_subscription
-- ----------------------------
INSERT INTO `advisor_product_subscription` VALUES (1, 1, 2, 'ACTIVE', '2026-06-23 21:33:27', '2026-06-23 21:33:27', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (2, 2, 2, 'ACTIVE', '2026-06-24 23:14:11', '2026-06-24 23:14:11', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (3, 9, 2, 'ACTIVE', '2026-06-27 00:39:34', '2026-06-27 00:39:34', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (4, 11, 2, 'ACTIVE', '2026-06-27 00:47:33', '2026-06-27 00:47:33', 0.00, 0.00);
INSERT INTO `advisor_product_subscription` VALUES (5, 12, 2, 'ACTIVE', '2026-06-27 03:56:12', '2026-06-27 03:56:12', 10000.00, 10000.00);
INSERT INTO `advisor_product_subscription` VALUES (6, 3, 2, 'ACTIVE', '2026-06-27 04:07:27', '2026-06-27 15:00:34', 9000.00, 9000.00);

-- ----------------------------
-- Table structure for advisor_product_version
-- ----------------------------
DROP TABLE IF EXISTS `advisor_product_version`;
CREATE TABLE `advisor_product_version`  (
                                            `id` bigint NOT NULL AUTO_INCREMENT,
                                            `product_id` bigint NOT NULL,
                                            `version_no` int NOT NULL COMMENT '版本号（从1开始递增）',
                                            `base_info_json` json NOT NULL COMMENT '基础信息快照（名称/风险/标签/介绍等）',
                                            `params_json` json NULL COMMENT '策略/产品参数快照',
                                            `version_status` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'SUBMITTED' COMMENT 'SUBMITTED/APPROVED/REJECTED/WITHDRAWN',
                                            `change_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'NORMAL/MAJOR',
                                            `base_version_id` bigint NULL DEFAULT NULL COMMENT '对比基线版本ID',
                                            `version_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '版本更新说明',
                                            `status_at_submit` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '提交时产品状态（可选）',
                                            `submitted_at` datetime NULL DEFAULT NULL COMMENT '提交审核时间',
                                            `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                            PRIMARY KEY (`id`) USING BTREE,
                                            UNIQUE INDEX `uk_product_version`(`product_id` ASC, `version_no` ASC) USING BTREE,
                                            INDEX `idx_version_product`(`product_id` ASC) USING BTREE,
                                            INDEX `idx_version_submitted_at`(`submitted_at` ASC) USING BTREE,
                                            INDEX `idx_version_product_status`(`product_id` ASC, `version_status` ASC) USING BTREE,
                                            CONSTRAINT `fk_version_product` FOREIGN KEY (`product_id`) REFERENCES `advisor_product` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '产品版本快照表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_product_version
-- ----------------------------
INSERT INTO `advisor_product_version` VALUES (1, 1, 1, '{\"name\": \"天弘全球新能源\", \"type\": \"进取型\", \"riskTips\": \"111\", \"riskLevel\": \"R5\", \"featureTags\": [\"固收增强\"], \"strategyCode\": \"11\", \"productSummary\": \"11\", \"targetCustomer\": \"111\"}', '{\"strategyNotes\": \"11111\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-23 21:05:08', '2026-06-23 21:05:07');
INSERT INTO `advisor_product_version` VALUES (2, 2, 1, '{\"name\": \"1\", \"type\": \"平衡型\", \"riskTips\": \"2\", \"riskLevel\": \"R3\", \"featureTags\": [\"长期持有\"], \"strategyCode\": \"2\", \"productSummary\": \"2\", \"targetCustomer\": \"2\"}', '{\"strategyNotes\": \"222\", \"rebalanceCycleDays\": 3, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.06}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-23 22:45:38', '2026-06-23 22:45:38');
INSERT INTO `advisor_product_version` VALUES (3, 3, 1, '{\"name\": \"2\", \"type\": \"平衡型\", \"riskTips\": \"1\", \"riskLevel\": \"R4\", \"featureTags\": [\"权益增强\"], \"strategyCode\": \"3\", \"productSummary\": \"1\", \"targetCustomer\": \"1\"}', '{\"strategyNotes\": \"1\", \"rebalanceCycleDays\": 2, \"investHorizonMonths\": 2, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-24 20:22:35', '2026-06-24 20:22:35');
INSERT INTO `advisor_product_version` VALUES (4, 4, 1, '{\"name\": \"平安保险\", \"type\": \"FOF\", \"riskTips\": \"低风险\", \"riskLevel\": \"R3\", \"featureTags\": [\"低波动\"], \"strategyCode\": \"4\", \"productSummary\": \"养老保险\", \"targetCustomer\": \"老年人\"}', '{\"strategyNotes\": \"无\", \"rebalanceCycleDays\": 4, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 0.1}', 'APPROVED', NULL, NULL, NULL, 'DRAFT', '2026-06-25 00:32:16', '2026-06-25 00:32:15');
INSERT INTO `advisor_product_version` VALUES (5, 9, 1, '{\"name\": \"英伟达\", \"type\": \"FOF\", \"riskTips\": \"223让人\", \"riskLevel\": \"R1\", \"featureTags\": [\"权益增强\"], \"strategyCode\": \"11\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 18:37:39', '2026-06-26 18:37:38');
INSERT INTO `advisor_product_version` VALUES (6, 11, 1, '{\"name\": \"大成\", \"type\": \"STRATEGY\", \"riskTips\": \"12321313\", \"riskLevel\": \"R5\", \"featureTags\": [\"固收增强\"], \"strategyCode\": \"12\", \"productSummary\": \"2313131\", \"targetCustomer\": \"131213饿\"}', '{\"strategyNotes\": \"1212112\", \"rebalanceCycleDays\": 142, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 20:13:20', '2026-06-26 20:13:19');
INSERT INTO `advisor_product_version` VALUES (7, 5, 1, '{\"name\": \"国泰\", \"type\": \"STRATEGY\", \"riskTips\": \"223让人\", \"riskLevel\": \"R1\", \"featureTags\": [\"权益增强\"], \"strategyCode\": \"12\", \"productSummary\": \"11\", \"targetCustomer\": \"1313\"}', '{\"strategyNotes\": \"1111\", \"rebalanceCycleDays\": 11, \"investHorizonMonths\": 11, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'REJECTED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 21:30:10', '2026-06-26 21:30:09');
INSERT INTO `advisor_product_version` VALUES (8, 12, 1, '{\"name\": \"天弘\", \"type\": \"FOF\", \"riskTips\": \"2342\", \"riskLevel\": \"R2\", \"featureTags\": [\"固收增强\", \"养老规划\"], \"strategyCode\": \"33\", \"productSummary\": \"12\", \"targetCustomer\": \"23\"}', '{\"strategyNotes\": \"2342423\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 34, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 21:53:48', '2026-06-26 21:53:48');
INSERT INTO `advisor_product_version` VALUES (9, 13, 1, '{\"name\": \"德邦\", \"type\": \"FOF\", \"riskTips\": \"1234\", \"riskLevel\": \"R4\", \"featureTags\": [\"长期持有\"], \"strategyCode\": \"55\", \"productSummary\": \"去11\", \"targetCustomer\": \"564\"}', '{\"strategyNotes\": \"1313\", \"rebalanceCycleDays\": 23, \"investHorizonMonths\": 120, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', NULL, NULL, 'DRAFT', '2026-06-26 21:59:52', '2026-06-26 21:59:52');
INSERT INTO `advisor_product_version` VALUES (10, 11, 2, '{\"name\": \"大成\", \"type\": \"STRATEGY\", \"riskTips\": \"12321313\", \"riskLevel\": \"R5\", \"featureTags\": [\"固收增强\"], \"strategyCode\": \"12\", \"productSummary\": \"2313131\", \"targetCustomer\": \"131213饿\"}', '{\"strategyNotes\": \"1212112\", \"rebalanceCycleDays\": 142, \"investHorizonMonths\": 12, \"maxSingleFundWeight\": 1, \"minSingleFundWeight\": 1}', 'APPROVED', 'NORMAL', 6, '无重大变更', 'PUBLISHED', '2026-06-27 00:46:26', '2026-06-27 00:46:26');

-- ----------------------------
-- Table structure for advisor_strategy_rule
-- ----------------------------
DROP TABLE IF EXISTS `advisor_strategy_rule`;
CREATE TABLE `advisor_strategy_rule`  (
                                          `id` bigint NOT NULL AUTO_INCREMENT,
                                          `strategy_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '策略编码（advisor_product.strategy_code）',
                                          `product_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'STRATEGY/FOF',
                                          `min_fund_count` int NOT NULL COMMENT '最少成份数',
                                          `max_fund_count` int NOT NULL COMMENT '最多成份数',
                                          `min_single_weight` decimal(10, 4) NOT NULL COMMENT '单基金最小权重（0~1）',
                                          `max_single_weight` decimal(10, 4) NOT NULL COMMENT '单基金最大权重（0~1）',
                                          `allow_fund_types` json NULL COMMENT '允许基金类型（JSON数组），为空表示不限制',
                                          `risk_rule_mode` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '风险匹配规则',
                                          `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
                                          `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                          `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                          PRIMARY KEY (`id`) USING BTREE,
                                          UNIQUE INDEX `uk_strategy_rule`(`strategy_code` ASC, `product_type` ASC) USING BTREE,
                                          INDEX `idx_rule_type_status`(`product_type` ASC, `status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '策略/产品参数约束规则（平台默认）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of advisor_strategy_rule
-- ----------------------------
INSERT INTO `advisor_strategy_rule` VALUES (1, 'FOF_STABLE', 'FOF', 5, 20, 0.0200, 0.3000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');
INSERT INTO `advisor_strategy_rule` VALUES (2, 'BALANCE_ALPHA', 'STRATEGY', 3, 12, 0.0500, 0.5000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');
INSERT INTO `advisor_strategy_rule` VALUES (3, 'GROWTH_ATTACK', 'STRATEGY', 3, 10, 0.0500, 0.6000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');
INSERT INTO `advisor_strategy_rule` VALUES (4, 'THEME_MEDICAL', 'STRATEGY', 2, 8, 0.0500, 0.7000, NULL, 'MAX_COMPONENT_RISK_LE_PRODUCT_RISK', 1, '2026-06-24 19:53:25', '2026-06-24 20:24:18');

-- ----------------------------
-- Table structure for fund_info
-- ----------------------------
DROP TABLE IF EXISTS `fund_info`;
CREATE TABLE `fund_info`  (
                              `id` bigint NOT NULL AUTO_INCREMENT,
                              `fund_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金代码',
                              `fund_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金名称',
                              `fund_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '基金类型',
                              `risk_level` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '风险等级',
                              `company_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '基金公司',
                              `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
                              `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                              `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                              PRIMARY KEY (`id`) USING BTREE,
                              UNIQUE INDEX `uk_fund_code`(`fund_code` ASC) USING BTREE,
                              INDEX `idx_fund_name`(`fund_name` ASC) USING BTREE,
                              INDEX `idx_fund_type_status`(`fund_type` ASC, `status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金基础信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_info
-- ----------------------------
INSERT INTO `fund_info` VALUES (1, '110022', '易方达消费行业股票', '股票型', 'R4', '易方达基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (2, '003095', '中欧医疗健康混合', '混合型', 'R4', '中欧基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (3, '161725', '招商中证白酒指数', '指数型', 'R5', '招商基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (4, '000001', '华夏成长混合', '混合型', 'R3', '华夏基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (5, '002021', '国泰金牛创新成长混合', '混合型', 'R3', '国泰基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (6, '519674', '银河创新成长混合', '混合型', 'R4', '银河基金', 1, '2026-06-23 21:04:35', '2026-06-23 21:04:35');
INSERT INTO `fund_info` VALUES (7, '001632', '天弘中证食品饮料ETF联接A', '指数型', 'R4', '天弘基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (8, '005827', '易方达蓝筹精选混合', '混合型', 'R4', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (9, '006113', '汇添富创新医药混合', '混合型', 'R4', '汇添富基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (10, '000248', '汇添富中证主要消费ETF联接', '指数型', 'R4', '汇添富基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (11, '001875', '前海开源沪港深优势精选混合', '混合型', 'R4', '前海开源基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (12, '002190', '农银新能源主题灵活配置混合', '混合型', 'R4', '农银汇理基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (13, '004851', '广发医疗保健股票A', '股票型', 'R4', '广发基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (14, '000960', '招商医药健康产业股票', '股票型', 'R4', '招商基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (15, '001071', '华夏恒生ETF联接A', 'QDII', 'R4', '华夏基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (16, '006479', '中欧智能制造混合A', '混合型', 'R4', '中欧基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (17, '001838', '国投瑞银国家安全混合', '混合型', 'R4', '国投瑞银基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (18, '003096', '中欧医疗创新股票A', '股票型', 'R4', '中欧基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (19, '001717', '工银前沿医疗股票A', '股票型', 'R4', '工银瑞信基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (20, '110011', '易方达中小盘混合', '混合型', 'R4', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (21, '519696', '交银环球精选混合(QDII)', 'QDII', 'R4', '交银施罗德基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (22, '161039', '富国中证1000指数增强', '指数型', 'R4', '富国基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (23, '159915', '易方达创业板ETF', 'ETF', 'R5', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (24, '510300', '华泰柏瑞沪深300ETF', 'ETF', 'R4', '华泰柏瑞基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (25, '512690', '鹏华中证酒ETF', 'ETF', 'R5', '鹏华基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (26, '515790', '华夏中证新能源ETF', 'ETF', 'R5', '华夏基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (27, '320007', '诺安成长混合', '混合型', 'R5', '诺安基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (28, '260108', '景顺长城新兴成长混合', '混合型', 'R4', '景顺长城基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (29, '163406', '兴全合润混合', '混合型', 'R4', '兴证全球基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (30, '000452', '南方医药保健灵活配置混合', '混合型', 'R4', '南方基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (31, '040046', '华安纳斯达克100指数', 'QDII', 'R4', '华安基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (32, '513100', '国泰纳斯达克100ETF', 'ETF', 'R4', '国泰基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (33, '000307', '易方达黄金ETF联接A', '商品型', 'R3', '易方达基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (34, '518880', '华安黄金ETF', 'ETF', 'R3', '华安基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (35, '161005', '富国天惠成长混合', '混合型', 'R4', '富国基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');
INSERT INTO `fund_info` VALUES (36, '398011', '中海分红增利混合', '混合型', 'R3', '中海基金', 1, '2026-06-23 21:14:22', '2026-06-23 21:14:22');

-- ----------------------------
-- Table structure for fund_nav
-- ----------------------------
DROP TABLE IF EXISTS `fund_nav`;
CREATE TABLE `fund_nav`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `fund_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金代码',
                             `fund_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '基金名称',
                             `nav_date` date NOT NULL COMMENT '净值日期',
                             `nav` decimal(18, 8) NOT NULL COMMENT '单位净值',
                             `daily_return` decimal(18, 8) NULL DEFAULT NULL COMMENT '日收益率，可选',
                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_fund_nav_code_date`(`fund_code` ASC, `nav_date` ASC) USING BTREE,
                             INDEX `idx_fund_nav_date`(`nav_date` ASC) USING BTREE,
                             INDEX `idx_fund_nav_code`(`fund_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1081 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '基金历史净值表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of fund_nav
-- ----------------------------
INSERT INTO `fund_nav` VALUES (1, '110022', '易方达消费行业股票', '2026-06-23', 1.05849000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (2, '110022', '易方达消费行业股票', '2026-06-22', 1.05658000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (3, '110022', '易方达消费行业股票', '2026-06-21', 1.05577000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (4, '110022', '易方达消费行业股票', '2026-06-20', 1.05396000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (5, '110022', '易方达消费行业股票', '2026-06-19', 1.05235000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (6, '110022', '易方达消费行业股票', '2026-06-18', 1.05219000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (7, '110022', '易方达消费行业股票', '2026-06-17', 1.05028000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (8, '110022', '易方达消费行业股票', '2026-06-16', 1.04947000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (9, '110022', '易方达消费行业股票', '2026-06-15', 1.04766000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (10, '110022', '易方达消费行业股票', '2026-06-14', 1.04605000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (11, '110022', '易方达消费行业股票', '2026-06-13', 1.04589000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (12, '110022', '易方达消费行业股票', '2026-06-12', 1.04398000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (13, '110022', '易方达消费行业股票', '2026-06-11', 1.04317000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (14, '110022', '易方达消费行业股票', '2026-06-10', 1.04136000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (15, '110022', '易方达消费行业股票', '2026-06-09', 1.03975000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (16, '110022', '易方达消费行业股票', '2026-06-08', 1.03959000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (17, '110022', '易方达消费行业股票', '2026-06-07', 1.03768000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (18, '110022', '易方达消费行业股票', '2026-06-06', 1.03687000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (19, '110022', '易方达消费行业股票', '2026-06-05', 1.03506000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (20, '110022', '易方达消费行业股票', '2026-06-04', 1.03345000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (21, '110022', '易方达消费行业股票', '2026-06-03', 1.03329000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (22, '110022', '易方达消费行业股票', '2026-06-02', 1.03138000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (23, '110022', '易方达消费行业股票', '2026-06-01', 1.03057000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (24, '110022', '易方达消费行业股票', '2026-05-31', 1.02876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (25, '110022', '易方达消费行业股票', '2026-05-30', 1.02715000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (26, '110022', '易方达消费行业股票', '2026-05-29', 1.02699000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (27, '110022', '易方达消费行业股票', '2026-05-28', 1.02508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (28, '110022', '易方达消费行业股票', '2026-05-27', 1.02427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (29, '110022', '易方达消费行业股票', '2026-05-26', 1.02246000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (30, '110022', '易方达消费行业股票', '2026-05-25', 1.02085000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (31, '003095', '中欧医疗健康混合', '2026-06-23', 1.07113000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (32, '003095', '中欧医疗健康混合', '2026-06-22', 1.07032000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (33, '003095', '中欧医疗健康混合', '2026-06-21', 1.06851000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (34, '003095', '中欧医疗健康混合', '2026-06-20', 1.06690000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (35, '003095', '中欧医疗健康混合', '2026-06-19', 1.06674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (36, '003095', '中欧医疗健康混合', '2026-06-18', 1.06483000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (37, '003095', '中欧医疗健康混合', '2026-06-17', 1.06402000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (38, '003095', '中欧医疗健康混合', '2026-06-16', 1.06221000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (39, '003095', '中欧医疗健康混合', '2026-06-15', 1.06060000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (40, '003095', '中欧医疗健康混合', '2026-06-14', 1.06044000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (41, '003095', '中欧医疗健康混合', '2026-06-13', 1.05853000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (42, '003095', '中欧医疗健康混合', '2026-06-12', 1.05772000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (43, '003095', '中欧医疗健康混合', '2026-06-11', 1.05591000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (44, '003095', '中欧医疗健康混合', '2026-06-10', 1.05430000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (45, '003095', '中欧医疗健康混合', '2026-06-09', 1.05414000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (46, '003095', '中欧医疗健康混合', '2026-06-08', 1.05223000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (47, '003095', '中欧医疗健康混合', '2026-06-07', 1.05142000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (48, '003095', '中欧医疗健康混合', '2026-06-06', 1.04961000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (49, '003095', '中欧医疗健康混合', '2026-06-05', 1.04800000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (50, '003095', '中欧医疗健康混合', '2026-06-04', 1.04784000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (51, '003095', '中欧医疗健康混合', '2026-06-03', 1.04593000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (52, '003095', '中欧医疗健康混合', '2026-06-02', 1.04512000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (53, '003095', '中欧医疗健康混合', '2026-06-01', 1.04331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (54, '003095', '中欧医疗健康混合', '2026-05-31', 1.04170000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (55, '003095', '中欧医疗健康混合', '2026-05-30', 1.04154000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (56, '003095', '中欧医疗健康混合', '2026-05-29', 1.03963000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (57, '003095', '中欧医疗健康混合', '2026-05-28', 1.03882000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (58, '003095', '中欧医疗健康混合', '2026-05-27', 1.03701000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (59, '003095', '中欧医疗健康混合', '2026-05-26', 1.03540000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (60, '003095', '中欧医疗健康混合', '2026-05-25', 1.03524000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (61, '161725', '招商中证白酒指数', '2026-06-23', 1.08354000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (62, '161725', '招商中证白酒指数', '2026-06-22', 1.08163000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (63, '161725', '招商中证白酒指数', '2026-06-21', 1.08082000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (64, '161725', '招商中证白酒指数', '2026-06-20', 1.07901000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (65, '161725', '招商中证白酒指数', '2026-06-19', 1.07740000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (66, '161725', '招商中证白酒指数', '2026-06-18', 1.07724000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (67, '161725', '招商中证白酒指数', '2026-06-17', 1.07533000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (68, '161725', '招商中证白酒指数', '2026-06-16', 1.07452000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (69, '161725', '招商中证白酒指数', '2026-06-15', 1.07271000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (70, '161725', '招商中证白酒指数', '2026-06-14', 1.07110000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (71, '161725', '招商中证白酒指数', '2026-06-13', 1.07094000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (72, '161725', '招商中证白酒指数', '2026-06-12', 1.06903000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (73, '161725', '招商中证白酒指数', '2026-06-11', 1.06822000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (74, '161725', '招商中证白酒指数', '2026-06-10', 1.06641000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (75, '161725', '招商中证白酒指数', '2026-06-09', 1.06480000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (76, '161725', '招商中证白酒指数', '2026-06-08', 1.06464000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (77, '161725', '招商中证白酒指数', '2026-06-07', 1.06273000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (78, '161725', '招商中证白酒指数', '2026-06-06', 1.06192000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (79, '161725', '招商中证白酒指数', '2026-06-05', 1.06011000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (80, '161725', '招商中证白酒指数', '2026-06-04', 1.05850000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (81, '161725', '招商中证白酒指数', '2026-06-03', 1.05834000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (82, '161725', '招商中证白酒指数', '2026-06-02', 1.05643000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (83, '161725', '招商中证白酒指数', '2026-06-01', 1.05562000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (84, '161725', '招商中证白酒指数', '2026-05-31', 1.05381000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (85, '161725', '招商中证白酒指数', '2026-05-30', 1.05220000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (86, '161725', '招商中证白酒指数', '2026-05-29', 1.05204000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (87, '161725', '招商中证白酒指数', '2026-05-28', 1.05013000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (88, '161725', '招商中证白酒指数', '2026-05-27', 1.04932000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (89, '161725', '招商中证白酒指数', '2026-05-26', 1.04751000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (90, '161725', '招商中证白酒指数', '2026-05-25', 1.04590000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (91, '000001', '华夏成长混合', '2026-06-23', 1.04996000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (92, '000001', '华夏成长混合', '2026-06-22', 1.04819000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (93, '000001', '华夏成长混合', '2026-06-21', 1.04662000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (94, '000001', '华夏成长混合', '2026-06-20', 1.04650000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (95, '000001', '华夏成长混合', '2026-06-19', 1.04463000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (96, '000001', '华夏成长混合', '2026-06-18', 1.04386000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (97, '000001', '华夏成长混合', '2026-06-17', 1.04209000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (98, '000001', '华夏成长混合', '2026-06-16', 1.04052000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (99, '000001', '华夏成长混合', '2026-06-15', 1.04040000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (100, '000001', '华夏成长混合', '2026-06-14', 1.03853000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (101, '000001', '华夏成长混合', '2026-06-13', 1.03776000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (102, '000001', '华夏成长混合', '2026-06-12', 1.03599000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (103, '000001', '华夏成长混合', '2026-06-11', 1.03442000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (104, '000001', '华夏成长混合', '2026-06-10', 1.03430000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (105, '000001', '华夏成长混合', '2026-06-09', 1.03243000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (106, '000001', '华夏成长混合', '2026-06-08', 1.03166000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (107, '000001', '华夏成长混合', '2026-06-07', 1.02989000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (108, '000001', '华夏成长混合', '2026-06-06', 1.02832000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (109, '000001', '华夏成长混合', '2026-06-05', 1.02820000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (110, '000001', '华夏成长混合', '2026-06-04', 1.02633000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (111, '000001', '华夏成长混合', '2026-06-03', 1.02556000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (112, '000001', '华夏成长混合', '2026-06-02', 1.02379000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (113, '000001', '华夏成长混合', '2026-06-01', 1.02222000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (114, '000001', '华夏成长混合', '2026-05-31', 1.02210000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (115, '000001', '华夏成长混合', '2026-05-30', 1.02023000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (116, '000001', '华夏成长混合', '2026-05-29', 1.01946000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (117, '000001', '华夏成长混合', '2026-05-28', 1.01769000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (118, '000001', '华夏成长混合', '2026-05-27', 1.01612000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (119, '000001', '华夏成长混合', '2026-05-26', 1.01600000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (120, '000001', '华夏成长混合', '2026-05-25', 1.01413000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (121, '002021', '国泰金牛创新成长混合', '2026-06-23', 1.06262000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (122, '002021', '国泰金牛创新成长混合', '2026-06-22', 1.06074000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (123, '002021', '国泰金牛创新成长混合', '2026-06-21', 1.05996000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (124, '002021', '国泰金牛创新成长混合', '2026-06-20', 1.05818000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (125, '002021', '国泰金牛创新成长混合', '2026-06-19', 1.05660000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (126, '002021', '国泰金牛创新成长混合', '2026-06-18', 1.05647000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (127, '002021', '国泰金牛创新成长混合', '2026-06-17', 1.05459000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (128, '002021', '国泰金牛创新成长混合', '2026-06-16', 1.05381000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (129, '002021', '国泰金牛创新成长混合', '2026-06-15', 1.05203000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (130, '002021', '国泰金牛创新成长混合', '2026-06-14', 1.05045000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (131, '002021', '国泰金牛创新成长混合', '2026-06-13', 1.05032000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (132, '002021', '国泰金牛创新成长混合', '2026-06-12', 1.04844000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (133, '002021', '国泰金牛创新成长混合', '2026-06-11', 1.04766000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (134, '002021', '国泰金牛创新成长混合', '2026-06-10', 1.04588000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (135, '002021', '国泰金牛创新成长混合', '2026-06-09', 1.04430000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (136, '002021', '国泰金牛创新成长混合', '2026-06-08', 1.04417000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (137, '002021', '国泰金牛创新成长混合', '2026-06-07', 1.04229000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (138, '002021', '国泰金牛创新成长混合', '2026-06-06', 1.04151000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (139, '002021', '国泰金牛创新成长混合', '2026-06-05', 1.03973000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (140, '002021', '国泰金牛创新成长混合', '2026-06-04', 1.03815000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (141, '002021', '国泰金牛创新成长混合', '2026-06-03', 1.03802000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (142, '002021', '国泰金牛创新成长混合', '2026-06-02', 1.03614000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (143, '002021', '国泰金牛创新成长混合', '2026-06-01', 1.03536000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (144, '002021', '国泰金牛创新成长混合', '2026-05-31', 1.03358000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (145, '002021', '国泰金牛创新成长混合', '2026-05-30', 1.03200000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (146, '002021', '国泰金牛创新成长混合', '2026-05-29', 1.03187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (147, '002021', '国泰金牛创新成长混合', '2026-05-28', 1.02999000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (148, '002021', '国泰金牛创新成长混合', '2026-05-27', 1.02921000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (149, '002021', '国泰金牛创新成长混合', '2026-05-26', 1.02743000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (150, '002021', '国泰金牛创新成长混合', '2026-05-25', 1.02585000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (151, '519674', '银河创新成长混合', '2026-06-23', 1.04279000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (152, '519674', '银河创新成长混合', '2026-06-22', 1.04088000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (153, '519674', '银河创新成长混合', '2026-06-21', 1.04007000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (154, '519674', '银河创新成长混合', '2026-06-20', 1.03826000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (155, '519674', '银河创新成长混合', '2026-06-19', 1.03665000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (156, '519674', '银河创新成长混合', '2026-06-18', 1.03649000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (157, '519674', '银河创新成长混合', '2026-06-17', 1.03458000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (158, '519674', '银河创新成长混合', '2026-06-16', 1.03377000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (159, '519674', '银河创新成长混合', '2026-06-15', 1.03196000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (160, '519674', '银河创新成长混合', '2026-06-14', 1.03035000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (161, '519674', '银河创新成长混合', '2026-06-13', 1.03019000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (162, '519674', '银河创新成长混合', '2026-06-12', 1.02828000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (163, '519674', '银河创新成长混合', '2026-06-11', 1.02747000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (164, '519674', '银河创新成长混合', '2026-06-10', 1.02566000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (165, '519674', '银河创新成长混合', '2026-06-09', 1.02405000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (166, '519674', '银河创新成长混合', '2026-06-08', 1.02389000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (167, '519674', '银河创新成长混合', '2026-06-07', 1.02198000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (168, '519674', '银河创新成长混合', '2026-06-06', 1.02117000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (169, '519674', '银河创新成长混合', '2026-06-05', 1.01936000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (170, '519674', '银河创新成长混合', '2026-06-04', 1.01775000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (171, '519674', '银河创新成长混合', '2026-06-03', 1.01759000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (172, '519674', '银河创新成长混合', '2026-06-02', 1.01568000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (173, '519674', '银河创新成长混合', '2026-06-01', 1.01487000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (174, '519674', '银河创新成长混合', '2026-05-31', 1.01306000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (175, '519674', '银河创新成长混合', '2026-05-30', 1.01145000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (176, '519674', '银河创新成长混合', '2026-05-29', 1.01129000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (177, '519674', '银河创新成长混合', '2026-05-28', 1.00938000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (178, '519674', '银河创新成长混合', '2026-05-27', 1.00857000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (179, '519674', '银河创新成长混合', '2026-05-26', 1.00676000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (180, '519674', '银河创新成长混合', '2026-05-25', 1.00515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (181, '001632', '天弘中证食品饮料ETF联接A', '2026-06-23', 1.06888000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (182, '001632', '天弘中证食品饮料ETF联接A', '2026-06-22', 1.06812000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (183, '001632', '天弘中证食品饮料ETF联接A', '2026-06-21', 1.06636000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (184, '001632', '天弘中证食品饮料ETF联接A', '2026-06-20', 1.06480000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (185, '001632', '天弘中证食品饮料ETF联接A', '2026-06-19', 1.06469000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (186, '001632', '天弘中证食品饮料ETF联接A', '2026-06-18', 1.06283000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (187, '001632', '天弘中证食品饮料ETF联接A', '2026-06-17', 1.06207000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (188, '001632', '天弘中证食品饮料ETF联接A', '2026-06-16', 1.06031000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (189, '001632', '天弘中证食品饮料ETF联接A', '2026-06-15', 1.05875000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (190, '001632', '天弘中证食品饮料ETF联接A', '2026-06-14', 1.05864000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (191, '001632', '天弘中证食品饮料ETF联接A', '2026-06-13', 1.05678000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (192, '001632', '天弘中证食品饮料ETF联接A', '2026-06-12', 1.05602000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (193, '001632', '天弘中证食品饮料ETF联接A', '2026-06-11', 1.05426000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (194, '001632', '天弘中证食品饮料ETF联接A', '2026-06-10', 1.05270000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (195, '001632', '天弘中证食品饮料ETF联接A', '2026-06-09', 1.05259000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (196, '001632', '天弘中证食品饮料ETF联接A', '2026-06-08', 1.05073000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (197, '001632', '天弘中证食品饮料ETF联接A', '2026-06-07', 1.04997000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (198, '001632', '天弘中证食品饮料ETF联接A', '2026-06-06', 1.04821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (199, '001632', '天弘中证食品饮料ETF联接A', '2026-06-05', 1.04665000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (200, '001632', '天弘中证食品饮料ETF联接A', '2026-06-04', 1.04654000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (201, '001632', '天弘中证食品饮料ETF联接A', '2026-06-03', 1.04468000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (202, '001632', '天弘中证食品饮料ETF联接A', '2026-06-02', 1.04392000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (203, '001632', '天弘中证食品饮料ETF联接A', '2026-06-01', 1.04216000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (204, '001632', '天弘中证食品饮料ETF联接A', '2026-05-31', 1.04060000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (205, '001632', '天弘中证食品饮料ETF联接A', '2026-05-30', 1.04049000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (206, '001632', '天弘中证食品饮料ETF联接A', '2026-05-29', 1.03863000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (207, '001632', '天弘中证食品饮料ETF联接A', '2026-05-28', 1.03787000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (208, '001632', '天弘中证食品饮料ETF联接A', '2026-05-27', 1.03611000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (209, '001632', '天弘中证食品饮料ETF联接A', '2026-05-26', 1.03455000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (210, '001632', '天弘中证食品饮料ETF联接A', '2026-05-25', 1.03444000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (211, '005827', '易方达蓝筹精选混合', '2026-06-23', 1.07459000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (212, '005827', '易方达蓝筹精选混合', '2026-06-22', 1.07379000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (213, '005827', '易方达蓝筹精选混合', '2026-06-21', 1.07199000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (214, '005827', '易方达蓝筹精选混合', '2026-06-20', 1.07039000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (215, '005827', '易方达蓝筹精选混合', '2026-06-19', 1.07024000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (216, '005827', '易方达蓝筹精选混合', '2026-06-18', 1.06834000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (217, '005827', '易方达蓝筹精选混合', '2026-06-17', 1.06754000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (218, '005827', '易方达蓝筹精选混合', '2026-06-16', 1.06574000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (219, '005827', '易方达蓝筹精选混合', '2026-06-15', 1.06414000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (220, '005827', '易方达蓝筹精选混合', '2026-06-14', 1.06399000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (221, '005827', '易方达蓝筹精选混合', '2026-06-13', 1.06209000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (222, '005827', '易方达蓝筹精选混合', '2026-06-12', 1.06129000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (223, '005827', '易方达蓝筹精选混合', '2026-06-11', 1.05949000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (224, '005827', '易方达蓝筹精选混合', '2026-06-10', 1.05789000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (225, '005827', '易方达蓝筹精选混合', '2026-06-09', 1.05774000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (226, '005827', '易方达蓝筹精选混合', '2026-06-08', 1.05584000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (227, '005827', '易方达蓝筹精选混合', '2026-06-07', 1.05504000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (228, '005827', '易方达蓝筹精选混合', '2026-06-06', 1.05324000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (229, '005827', '易方达蓝筹精选混合', '2026-06-05', 1.05164000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (230, '005827', '易方达蓝筹精选混合', '2026-06-04', 1.05149000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (231, '005827', '易方达蓝筹精选混合', '2026-06-03', 1.04959000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (232, '005827', '易方达蓝筹精选混合', '2026-06-02', 1.04879000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (233, '005827', '易方达蓝筹精选混合', '2026-06-01', 1.04699000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (234, '005827', '易方达蓝筹精选混合', '2026-05-31', 1.04539000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (235, '005827', '易方达蓝筹精选混合', '2026-05-30', 1.04524000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (236, '005827', '易方达蓝筹精选混合', '2026-05-29', 1.04334000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (237, '005827', '易方达蓝筹精选混合', '2026-05-28', 1.04254000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (238, '005827', '易方达蓝筹精选混合', '2026-05-27', 1.04074000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (239, '005827', '易方达蓝筹精选混合', '2026-05-26', 1.03914000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (240, '005827', '易方达蓝筹精选混合', '2026-05-25', 1.03899000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (241, '006113', '汇添富创新医药混合', '2026-06-23', 1.07784000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (242, '006113', '汇添富创新医药混合', '2026-06-22', 1.07772000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (243, '006113', '汇添富创新医药混合', '2026-06-21', 1.07585000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (244, '006113', '汇添富创新医药混合', '2026-06-20', 1.07508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (245, '006113', '汇添富创新医药混合', '2026-06-19', 1.07331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (246, '006113', '汇添富创新医药混合', '2026-06-18', 1.07174000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (247, '006113', '汇添富创新医药混合', '2026-06-17', 1.07162000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (248, '006113', '汇添富创新医药混合', '2026-06-16', 1.06975000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (249, '006113', '汇添富创新医药混合', '2026-06-15', 1.06898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (250, '006113', '汇添富创新医药混合', '2026-06-14', 1.06721000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (251, '006113', '汇添富创新医药混合', '2026-06-13', 1.06564000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (252, '006113', '汇添富创新医药混合', '2026-06-12', 1.06552000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (253, '006113', '汇添富创新医药混合', '2026-06-11', 1.06365000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (254, '006113', '汇添富创新医药混合', '2026-06-10', 1.06288000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (255, '006113', '汇添富创新医药混合', '2026-06-09', 1.06111000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (256, '006113', '汇添富创新医药混合', '2026-06-08', 1.05954000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (257, '006113', '汇添富创新医药混合', '2026-06-07', 1.05942000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (258, '006113', '汇添富创新医药混合', '2026-06-06', 1.05755000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (259, '006113', '汇添富创新医药混合', '2026-06-05', 1.05678000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (260, '006113', '汇添富创新医药混合', '2026-06-04', 1.05501000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (261, '006113', '汇添富创新医药混合', '2026-06-03', 1.05344000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (262, '006113', '汇添富创新医药混合', '2026-06-02', 1.05332000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (263, '006113', '汇添富创新医药混合', '2026-06-01', 1.05145000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (264, '006113', '汇添富创新医药混合', '2026-05-31', 1.05068000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (265, '006113', '汇添富创新医药混合', '2026-05-30', 1.04891000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (266, '006113', '汇添富创新医药混合', '2026-05-29', 1.04734000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (267, '006113', '汇添富创新医药混合', '2026-05-28', 1.04722000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (268, '006113', '汇添富创新医药混合', '2026-05-27', 1.04535000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (269, '006113', '汇添富创新医药混合', '2026-05-26', 1.04458000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (270, '006113', '汇添富创新医药混合', '2026-05-25', 1.04281000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (271, '000248', '汇添富中证主要消费ETF联接', '2026-06-23', 1.03804000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (272, '000248', '汇添富中证主要消费ETF联接', '2026-06-22', 1.03625000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (273, '000248', '汇添富中证主要消费ETF联接', '2026-06-21', 1.03466000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (274, '000248', '汇添富中证主要消费ETF联接', '2026-06-20', 1.03452000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (275, '000248', '汇添富中证主要消费ETF联接', '2026-06-19', 1.03263000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (276, '000248', '汇添富中证主要消费ETF联接', '2026-06-18', 1.03184000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (277, '000248', '汇添富中证主要消费ETF联接', '2026-06-17', 1.03005000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (278, '000248', '汇添富中证主要消费ETF联接', '2026-06-16', 1.02846000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (279, '000248', '汇添富中证主要消费ETF联接', '2026-06-15', 1.02832000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (280, '000248', '汇添富中证主要消费ETF联接', '2026-06-14', 1.02643000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (281, '000248', '汇添富中证主要消费ETF联接', '2026-06-13', 1.02564000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (282, '000248', '汇添富中证主要消费ETF联接', '2026-06-12', 1.02385000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (283, '000248', '汇添富中证主要消费ETF联接', '2026-06-11', 1.02226000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (284, '000248', '汇添富中证主要消费ETF联接', '2026-06-10', 1.02212000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (285, '000248', '汇添富中证主要消费ETF联接', '2026-06-09', 1.02023000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (286, '000248', '汇添富中证主要消费ETF联接', '2026-06-08', 1.01944000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (287, '000248', '汇添富中证主要消费ETF联接', '2026-06-07', 1.01765000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (288, '000248', '汇添富中证主要消费ETF联接', '2026-06-06', 1.01606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (289, '000248', '汇添富中证主要消费ETF联接', '2026-06-05', 1.01592000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (290, '000248', '汇添富中证主要消费ETF联接', '2026-06-04', 1.01403000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (291, '000248', '汇添富中证主要消费ETF联接', '2026-06-03', 1.01324000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (292, '000248', '汇添富中证主要消费ETF联接', '2026-06-02', 1.01145000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (293, '000248', '汇添富中证主要消费ETF联接', '2026-06-01', 1.00986000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (294, '000248', '汇添富中证主要消费ETF联接', '2026-05-31', 1.00972000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (295, '000248', '汇添富中证主要消费ETF联接', '2026-05-30', 1.00783000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (296, '000248', '汇添富中证主要消费ETF联接', '2026-05-29', 1.00704000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (297, '000248', '汇添富中证主要消费ETF联接', '2026-05-28', 1.00525000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (298, '000248', '汇添富中证主要消费ETF联接', '2026-05-27', 1.00366000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (299, '000248', '汇添富中证主要消费ETF联接', '2026-05-26', 1.00352000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (300, '000248', '汇添富中证主要消费ETF联接', '2026-05-25', 1.00163000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (301, '001875', '前海开源沪港深优势精选混合', '2026-06-23', 1.08331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (302, '001875', '前海开源沪港深优势精选混合', '2026-06-22', 1.08321000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (303, '001875', '前海开源沪港深优势精选混合', '2026-06-21', 1.08136000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (304, '001875', '前海开源沪港深优势精选混合', '2026-06-20', 1.08061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (305, '001875', '前海开源沪港深优势精选混合', '2026-06-19', 1.07886000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (306, '001875', '前海开源沪港深优势精选混合', '2026-06-18', 1.07731000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (307, '001875', '前海开源沪港深优势精选混合', '2026-06-17', 1.07721000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (308, '001875', '前海开源沪港深优势精选混合', '2026-06-16', 1.07536000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (309, '001875', '前海开源沪港深优势精选混合', '2026-06-15', 1.07461000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (310, '001875', '前海开源沪港深优势精选混合', '2026-06-14', 1.07286000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (311, '001875', '前海开源沪港深优势精选混合', '2026-06-13', 1.07131000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (312, '001875', '前海开源沪港深优势精选混合', '2026-06-12', 1.07121000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (313, '001875', '前海开源沪港深优势精选混合', '2026-06-11', 1.06936000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (314, '001875', '前海开源沪港深优势精选混合', '2026-06-10', 1.06861000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (315, '001875', '前海开源沪港深优势精选混合', '2026-06-09', 1.06686000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (316, '001875', '前海开源沪港深优势精选混合', '2026-06-08', 1.06531000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (317, '001875', '前海开源沪港深优势精选混合', '2026-06-07', 1.06521000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (318, '001875', '前海开源沪港深优势精选混合', '2026-06-06', 1.06336000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (319, '001875', '前海开源沪港深优势精选混合', '2026-06-05', 1.06261000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (320, '001875', '前海开源沪港深优势精选混合', '2026-06-04', 1.06086000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (321, '001875', '前海开源沪港深优势精选混合', '2026-06-03', 1.05931000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (322, '001875', '前海开源沪港深优势精选混合', '2026-06-02', 1.05921000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (323, '001875', '前海开源沪港深优势精选混合', '2026-06-01', 1.05736000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (324, '001875', '前海开源沪港深优势精选混合', '2026-05-31', 1.05661000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (325, '001875', '前海开源沪港深优势精选混合', '2026-05-30', 1.05486000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (326, '001875', '前海开源沪港深优势精选混合', '2026-05-29', 1.05331000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (327, '001875', '前海开源沪港深优势精选混合', '2026-05-28', 1.05321000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (328, '001875', '前海开源沪港深优势精选混合', '2026-05-27', 1.05136000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (329, '001875', '前海开源沪港深优势精选混合', '2026-05-26', 1.05061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (330, '001875', '前海开源沪港深优势精选混合', '2026-05-25', 1.04886000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (331, '002190', '农银新能源主题灵活配置混合', '2026-06-23', 1.06602000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (332, '002190', '农银新能源主题灵活配置混合', '2026-06-22', 1.06426000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (333, '002190', '农银新能源主题灵活配置混合', '2026-06-21', 1.06270000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (334, '002190', '农银新能源主题灵活配置混合', '2026-06-20', 1.06259000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (335, '002190', '农银新能源主题灵活配置混合', '2026-06-19', 1.06073000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (336, '002190', '农银新能源主题灵活配置混合', '2026-06-18', 1.05997000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (337, '002190', '农银新能源主题灵活配置混合', '2026-06-17', 1.05821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (338, '002190', '农银新能源主题灵活配置混合', '2026-06-16', 1.05665000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (339, '002190', '农银新能源主题灵活配置混合', '2026-06-15', 1.05654000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (340, '002190', '农银新能源主题灵活配置混合', '2026-06-14', 1.05468000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (341, '002190', '农银新能源主题灵活配置混合', '2026-06-13', 1.05392000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (342, '002190', '农银新能源主题灵活配置混合', '2026-06-12', 1.05216000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (343, '002190', '农银新能源主题灵活配置混合', '2026-06-11', 1.05060000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (344, '002190', '农银新能源主题灵活配置混合', '2026-06-10', 1.05049000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (345, '002190', '农银新能源主题灵活配置混合', '2026-06-09', 1.04863000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (346, '002190', '农银新能源主题灵活配置混合', '2026-06-08', 1.04787000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (347, '002190', '农银新能源主题灵活配置混合', '2026-06-07', 1.04611000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (348, '002190', '农银新能源主题灵活配置混合', '2026-06-06', 1.04455000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (349, '002190', '农银新能源主题灵活配置混合', '2026-06-05', 1.04444000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (350, '002190', '农银新能源主题灵活配置混合', '2026-06-04', 1.04258000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (351, '002190', '农银新能源主题灵活配置混合', '2026-06-03', 1.04182000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (352, '002190', '农银新能源主题灵活配置混合', '2026-06-02', 1.04006000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (353, '002190', '农银新能源主题灵活配置混合', '2026-06-01', 1.03850000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (354, '002190', '农银新能源主题灵活配置混合', '2026-05-31', 1.03839000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (355, '002190', '农银新能源主题灵活配置混合', '2026-05-30', 1.03653000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (356, '002190', '农银新能源主题灵活配置混合', '2026-05-29', 1.03577000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (357, '002190', '农银新能源主题灵活配置混合', '2026-05-28', 1.03401000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (358, '002190', '农银新能源主题灵活配置混合', '2026-05-27', 1.03245000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (359, '002190', '农银新能源主题灵活配置混合', '2026-05-26', 1.03234000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (360, '002190', '农银新能源主题灵活配置混合', '2026-05-25', 1.03048000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (361, '004851', '广发医疗保健股票A', '2026-06-23', 1.08184000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (362, '004851', '广发医疗保健股票A', '2026-06-22', 1.08104000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (363, '004851', '广发医疗保健股票A', '2026-06-21', 1.07924000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (364, '004851', '广发医疗保健股票A', '2026-06-20', 1.07764000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (365, '004851', '广发医疗保健股票A', '2026-06-19', 1.07749000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (366, '004851', '广发医疗保健股票A', '2026-06-18', 1.07559000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (367, '004851', '广发医疗保健股票A', '2026-06-17', 1.07479000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (368, '004851', '广发医疗保健股票A', '2026-06-16', 1.07299000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (369, '004851', '广发医疗保健股票A', '2026-06-15', 1.07139000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (370, '004851', '广发医疗保健股票A', '2026-06-14', 1.07124000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (371, '004851', '广发医疗保健股票A', '2026-06-13', 1.06934000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (372, '004851', '广发医疗保健股票A', '2026-06-12', 1.06854000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (373, '004851', '广发医疗保健股票A', '2026-06-11', 1.06674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (374, '004851', '广发医疗保健股票A', '2026-06-10', 1.06514000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (375, '004851', '广发医疗保健股票A', '2026-06-09', 1.06499000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (376, '004851', '广发医疗保健股票A', '2026-06-08', 1.06309000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (377, '004851', '广发医疗保健股票A', '2026-06-07', 1.06229000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (378, '004851', '广发医疗保健股票A', '2026-06-06', 1.06049000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (379, '004851', '广发医疗保健股票A', '2026-06-05', 1.05889000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (380, '004851', '广发医疗保健股票A', '2026-06-04', 1.05874000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (381, '004851', '广发医疗保健股票A', '2026-06-03', 1.05684000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (382, '004851', '广发医疗保健股票A', '2026-06-02', 1.05604000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (383, '004851', '广发医疗保健股票A', '2026-06-01', 1.05424000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (384, '004851', '广发医疗保健股票A', '2026-05-31', 1.05264000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (385, '004851', '广发医疗保健股票A', '2026-05-30', 1.05249000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (386, '004851', '广发医疗保健股票A', '2026-05-29', 1.05059000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (387, '004851', '广发医疗保健股票A', '2026-05-28', 1.04979000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (388, '004851', '广发医疗保健股票A', '2026-05-27', 1.04799000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (389, '004851', '广发医疗保健股票A', '2026-05-26', 1.04639000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (390, '004851', '广发医疗保健股票A', '2026-05-25', 1.04624000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (391, '000960', '招商医药健康产业股票', '2026-06-23', 1.05651000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (392, '000960', '招商医药健康产业股票', '2026-06-22', 1.05474000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (393, '000960', '招商医药健康产业股票', '2026-06-21', 1.05317000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (394, '000960', '招商医药健康产业股票', '2026-06-20', 1.05305000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (395, '000960', '招商医药健康产业股票', '2026-06-19', 1.05118000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (396, '000960', '招商医药健康产业股票', '2026-06-18', 1.05041000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (397, '000960', '招商医药健康产业股票', '2026-06-17', 1.04864000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (398, '000960', '招商医药健康产业股票', '2026-06-16', 1.04707000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (399, '000960', '招商医药健康产业股票', '2026-06-15', 1.04695000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (400, '000960', '招商医药健康产业股票', '2026-06-14', 1.04508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (401, '000960', '招商医药健康产业股票', '2026-06-13', 1.04431000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (402, '000960', '招商医药健康产业股票', '2026-06-12', 1.04254000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (403, '000960', '招商医药健康产业股票', '2026-06-11', 1.04097000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (404, '000960', '招商医药健康产业股票', '2026-06-10', 1.04085000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (405, '000960', '招商医药健康产业股票', '2026-06-09', 1.03898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (406, '000960', '招商医药健康产业股票', '2026-06-08', 1.03821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (407, '000960', '招商医药健康产业股票', '2026-06-07', 1.03644000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (408, '000960', '招商医药健康产业股票', '2026-06-06', 1.03487000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (409, '000960', '招商医药健康产业股票', '2026-06-05', 1.03475000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (410, '000960', '招商医药健康产业股票', '2026-06-04', 1.03288000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (411, '000960', '招商医药健康产业股票', '2026-06-03', 1.03211000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (412, '000960', '招商医药健康产业股票', '2026-06-02', 1.03034000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (413, '000960', '招商医药健康产业股票', '2026-06-01', 1.02877000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (414, '000960', '招商医药健康产业股票', '2026-05-31', 1.02865000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (415, '000960', '招商医药健康产业股票', '2026-05-30', 1.02678000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (416, '000960', '招商医药健康产业股票', '2026-05-29', 1.02601000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (417, '000960', '招商医药健康产业股票', '2026-05-28', 1.02424000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (418, '000960', '招商医药健康产业股票', '2026-05-27', 1.02267000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (419, '000960', '招商医药健康产业股票', '2026-05-26', 1.02255000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (420, '000960', '招商医药健康产业股票', '2026-05-25', 1.02068000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (421, '001071', '华夏恒生ETF联接A', '2026-06-23', 1.04755000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (422, '001071', '华夏恒生ETF联接A', '2026-06-22', 1.04676000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (423, '001071', '华夏恒生ETF联接A', '2026-06-21', 1.04497000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (424, '001071', '华夏恒生ETF联接A', '2026-06-20', 1.04338000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (425, '001071', '华夏恒生ETF联接A', '2026-06-19', 1.04324000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (426, '001071', '华夏恒生ETF联接A', '2026-06-18', 1.04135000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (427, '001071', '华夏恒生ETF联接A', '2026-06-17', 1.04056000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (428, '001071', '华夏恒生ETF联接A', '2026-06-16', 1.03877000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (429, '001071', '华夏恒生ETF联接A', '2026-06-15', 1.03718000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (430, '001071', '华夏恒生ETF联接A', '2026-06-14', 1.03704000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (431, '001071', '华夏恒生ETF联接A', '2026-06-13', 1.03515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (432, '001071', '华夏恒生ETF联接A', '2026-06-12', 1.03436000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (433, '001071', '华夏恒生ETF联接A', '2026-06-11', 1.03257000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (434, '001071', '华夏恒生ETF联接A', '2026-06-10', 1.03098000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (435, '001071', '华夏恒生ETF联接A', '2026-06-09', 1.03084000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (436, '001071', '华夏恒生ETF联接A', '2026-06-08', 1.02895000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (437, '001071', '华夏恒生ETF联接A', '2026-06-07', 1.02816000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (438, '001071', '华夏恒生ETF联接A', '2026-06-06', 1.02637000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (439, '001071', '华夏恒生ETF联接A', '2026-06-05', 1.02478000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (440, '001071', '华夏恒生ETF联接A', '2026-06-04', 1.02464000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (441, '001071', '华夏恒生ETF联接A', '2026-06-03', 1.02275000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (442, '001071', '华夏恒生ETF联接A', '2026-06-02', 1.02196000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (443, '001071', '华夏恒生ETF联接A', '2026-06-01', 1.02017000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (444, '001071', '华夏恒生ETF联接A', '2026-05-31', 1.01858000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (445, '001071', '华夏恒生ETF联接A', '2026-05-30', 1.01844000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (446, '001071', '华夏恒生ETF联接A', '2026-05-29', 1.01655000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (447, '001071', '华夏恒生ETF联接A', '2026-05-28', 1.01576000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (448, '001071', '华夏恒生ETF联接A', '2026-05-27', 1.01397000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (449, '001071', '华夏恒生ETF联接A', '2026-05-26', 1.01238000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (450, '001071', '华夏恒生ETF联接A', '2026-05-25', 1.01224000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (451, '006479', '中欧智能制造混合A', '2026-06-23', 1.04019000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (452, '006479', '中欧智能制造混合A', '2026-06-22', 1.03840000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (453, '006479', '中欧智能制造混合A', '2026-06-21', 1.03681000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (454, '006479', '中欧智能制造混合A', '2026-06-20', 1.03667000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (455, '006479', '中欧智能制造混合A', '2026-06-19', 1.03478000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (456, '006479', '中欧智能制造混合A', '2026-06-18', 1.03399000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (457, '006479', '中欧智能制造混合A', '2026-06-17', 1.03220000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (458, '006479', '中欧智能制造混合A', '2026-06-16', 1.03061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (459, '006479', '中欧智能制造混合A', '2026-06-15', 1.03047000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (460, '006479', '中欧智能制造混合A', '2026-06-14', 1.02858000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (461, '006479', '中欧智能制造混合A', '2026-06-13', 1.02779000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (462, '006479', '中欧智能制造混合A', '2026-06-12', 1.02600000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (463, '006479', '中欧智能制造混合A', '2026-06-11', 1.02441000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (464, '006479', '中欧智能制造混合A', '2026-06-10', 1.02427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (465, '006479', '中欧智能制造混合A', '2026-06-09', 1.02238000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (466, '006479', '中欧智能制造混合A', '2026-06-08', 1.02159000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (467, '006479', '中欧智能制造混合A', '2026-06-07', 1.01980000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (468, '006479', '中欧智能制造混合A', '2026-06-06', 1.01821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (469, '006479', '中欧智能制造混合A', '2026-06-05', 1.01807000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (470, '006479', '中欧智能制造混合A', '2026-06-04', 1.01618000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (471, '006479', '中欧智能制造混合A', '2026-06-03', 1.01539000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (472, '006479', '中欧智能制造混合A', '2026-06-02', 1.01360000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (473, '006479', '中欧智能制造混合A', '2026-06-01', 1.01201000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (474, '006479', '中欧智能制造混合A', '2026-05-31', 1.01187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (475, '006479', '中欧智能制造混合A', '2026-05-30', 1.00998000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (476, '006479', '中欧智能制造混合A', '2026-05-29', 1.00919000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (477, '006479', '中欧智能制造混合A', '2026-05-28', 1.00740000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (478, '006479', '中欧智能制造混合A', '2026-05-27', 1.00581000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (479, '006479', '中欧智能制造混合A', '2026-05-26', 1.00567000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (480, '006479', '中欧智能制造混合A', '2026-05-25', 1.00378000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (481, '001838', '国投瑞银国家安全混合', '2026-06-23', 1.06636000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (482, '001838', '国投瑞银国家安全混合', '2026-06-22', 1.06447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (483, '001838', '国投瑞银国家安全混合', '2026-06-21', 1.06368000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (484, '001838', '国投瑞银国家安全混合', '2026-06-20', 1.06189000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (485, '001838', '国投瑞银国家安全混合', '2026-06-19', 1.06030000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (486, '001838', '国投瑞银国家安全混合', '2026-06-18', 1.06016000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (487, '001838', '国投瑞银国家安全混合', '2026-06-17', 1.05827000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (488, '001838', '国投瑞银国家安全混合', '2026-06-16', 1.05748000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (489, '001838', '国投瑞银国家安全混合', '2026-06-15', 1.05569000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (490, '001838', '国投瑞银国家安全混合', '2026-06-14', 1.05410000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (491, '001838', '国投瑞银国家安全混合', '2026-06-13', 1.05396000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (492, '001838', '国投瑞银国家安全混合', '2026-06-12', 1.05207000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (493, '001838', '国投瑞银国家安全混合', '2026-06-11', 1.05128000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (494, '001838', '国投瑞银国家安全混合', '2026-06-10', 1.04949000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (495, '001838', '国投瑞银国家安全混合', '2026-06-09', 1.04790000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (496, '001838', '国投瑞银国家安全混合', '2026-06-08', 1.04776000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (497, '001838', '国投瑞银国家安全混合', '2026-06-07', 1.04587000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (498, '001838', '国投瑞银国家安全混合', '2026-06-06', 1.04508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (499, '001838', '国投瑞银国家安全混合', '2026-06-05', 1.04329000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (500, '001838', '国投瑞银国家安全混合', '2026-06-04', 1.04170000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (501, '001838', '国投瑞银国家安全混合', '2026-06-03', 1.04156000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (502, '001838', '国投瑞银国家安全混合', '2026-06-02', 1.03967000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (503, '001838', '国投瑞银国家安全混合', '2026-06-01', 1.03888000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (504, '001838', '国投瑞银国家安全混合', '2026-05-31', 1.03709000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (505, '001838', '国投瑞银国家安全混合', '2026-05-30', 1.03550000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (506, '001838', '国投瑞银国家安全混合', '2026-05-29', 1.03536000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (507, '001838', '国投瑞银国家安全混合', '2026-05-28', 1.03347000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (508, '001838', '国投瑞银国家安全混合', '2026-05-27', 1.03268000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (509, '001838', '国投瑞银国家安全混合', '2026-05-26', 1.03089000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (510, '001838', '国投瑞银国家安全混合', '2026-05-25', 1.02930000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (511, '003096', '中欧医疗创新股票A', '2026-06-23', 1.05912000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (512, '003096', '中欧医疗创新股票A', '2026-06-22', 1.05752000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (513, '003096', '中欧医疗创新股票A', '2026-06-21', 1.05737000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (514, '003096', '中欧医疗创新股票A', '2026-06-20', 1.05547000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (515, '003096', '中欧医疗创新股票A', '2026-06-19', 1.05467000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (516, '003096', '中欧医疗创新股票A', '2026-06-18', 1.05287000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (517, '003096', '中欧医疗创新股票A', '2026-06-17', 1.05127000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (518, '003096', '中欧医疗创新股票A', '2026-06-16', 1.05112000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (519, '003096', '中欧医疗创新股票A', '2026-06-15', 1.04922000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (520, '003096', '中欧医疗创新股票A', '2026-06-14', 1.04842000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (521, '003096', '中欧医疗创新股票A', '2026-06-13', 1.04662000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (522, '003096', '中欧医疗创新股票A', '2026-06-12', 1.04502000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (523, '003096', '中欧医疗创新股票A', '2026-06-11', 1.04487000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (524, '003096', '中欧医疗创新股票A', '2026-06-10', 1.04297000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (525, '003096', '中欧医疗创新股票A', '2026-06-09', 1.04217000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (526, '003096', '中欧医疗创新股票A', '2026-06-08', 1.04037000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (527, '003096', '中欧医疗创新股票A', '2026-06-07', 1.03877000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (528, '003096', '中欧医疗创新股票A', '2026-06-06', 1.03862000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (529, '003096', '中欧医疗创新股票A', '2026-06-05', 1.03672000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (530, '003096', '中欧医疗创新股票A', '2026-06-04', 1.03592000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (531, '003096', '中欧医疗创新股票A', '2026-06-03', 1.03412000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (532, '003096', '中欧医疗创新股票A', '2026-06-02', 1.03252000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (533, '003096', '中欧医疗创新股票A', '2026-06-01', 1.03237000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (534, '003096', '中欧医疗创新股票A', '2026-05-31', 1.03047000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (535, '003096', '中欧医疗创新股票A', '2026-05-30', 1.02967000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (536, '003096', '中欧医疗创新股票A', '2026-05-29', 1.02787000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (537, '003096', '中欧医疗创新股票A', '2026-05-28', 1.02627000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (538, '003096', '中欧医疗创新股票A', '2026-05-27', 1.02612000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (539, '003096', '中欧医疗创新股票A', '2026-05-26', 1.02422000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (540, '003096', '中欧医疗创新股票A', '2026-05-25', 1.02342000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (541, '001717', '工银前沿医疗股票A', '2026-06-23', 1.06876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (542, '001717', '工银前沿医疗股票A', '2026-06-22', 1.06866000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (543, '001717', '工银前沿医疗股票A', '2026-06-21', 1.06681000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (544, '001717', '工银前沿医疗股票A', '2026-06-20', 1.06606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (545, '001717', '工银前沿医疗股票A', '2026-06-19', 1.06431000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (546, '001717', '工银前沿医疗股票A', '2026-06-18', 1.06276000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (547, '001717', '工银前沿医疗股票A', '2026-06-17', 1.06266000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (548, '001717', '工银前沿医疗股票A', '2026-06-16', 1.06081000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (549, '001717', '工银前沿医疗股票A', '2026-06-15', 1.06006000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (550, '001717', '工银前沿医疗股票A', '2026-06-14', 1.05831000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (551, '001717', '工银前沿医疗股票A', '2026-06-13', 1.05676000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (552, '001717', '工银前沿医疗股票A', '2026-06-12', 1.05666000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (553, '001717', '工银前沿医疗股票A', '2026-06-11', 1.05481000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (554, '001717', '工银前沿医疗股票A', '2026-06-10', 1.05406000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (555, '001717', '工银前沿医疗股票A', '2026-06-09', 1.05231000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (556, '001717', '工银前沿医疗股票A', '2026-06-08', 1.05076000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (557, '001717', '工银前沿医疗股票A', '2026-06-07', 1.05066000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (558, '001717', '工银前沿医疗股票A', '2026-06-06', 1.04881000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (559, '001717', '工银前沿医疗股票A', '2026-06-05', 1.04806000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (560, '001717', '工银前沿医疗股票A', '2026-06-04', 1.04631000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (561, '001717', '工银前沿医疗股票A', '2026-06-03', 1.04476000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (562, '001717', '工银前沿医疗股票A', '2026-06-02', 1.04466000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (563, '001717', '工银前沿医疗股票A', '2026-06-01', 1.04281000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (564, '001717', '工银前沿医疗股票A', '2026-05-31', 1.04206000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (565, '001717', '工银前沿医疗股票A', '2026-05-30', 1.04031000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (566, '001717', '工银前沿医疗股票A', '2026-05-29', 1.03876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (567, '001717', '工银前沿医疗股票A', '2026-05-28', 1.03866000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (568, '001717', '工银前沿医疗股票A', '2026-05-27', 1.03681000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (569, '001717', '工银前沿医疗股票A', '2026-05-26', 1.03606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (570, '001717', '工银前沿医疗股票A', '2026-05-25', 1.03431000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (571, '110011', '易方达中小盘混合', '2026-06-23', 1.05252000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (572, '110011', '易方达中小盘混合', '2026-06-22', 1.05071000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (573, '110011', '易方达中小盘混合', '2026-06-21', 1.04910000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (574, '110011', '易方达中小盘混合', '2026-06-20', 1.04894000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (575, '110011', '易方达中小盘混合', '2026-06-19', 1.04703000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (576, '110011', '易方达中小盘混合', '2026-06-18', 1.04622000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (577, '110011', '易方达中小盘混合', '2026-06-17', 1.04441000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (578, '110011', '易方达中小盘混合', '2026-06-16', 1.04280000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (579, '110011', '易方达中小盘混合', '2026-06-15', 1.04264000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (580, '110011', '易方达中小盘混合', '2026-06-14', 1.04073000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (581, '110011', '易方达中小盘混合', '2026-06-13', 1.03992000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (582, '110011', '易方达中小盘混合', '2026-06-12', 1.03811000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (583, '110011', '易方达中小盘混合', '2026-06-11', 1.03650000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (584, '110011', '易方达中小盘混合', '2026-06-10', 1.03634000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (585, '110011', '易方达中小盘混合', '2026-06-09', 1.03443000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (586, '110011', '易方达中小盘混合', '2026-06-08', 1.03362000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (587, '110011', '易方达中小盘混合', '2026-06-07', 1.03181000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (588, '110011', '易方达中小盘混合', '2026-06-06', 1.03020000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (589, '110011', '易方达中小盘混合', '2026-06-05', 1.03004000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (590, '110011', '易方达中小盘混合', '2026-06-04', 1.02813000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (591, '110011', '易方达中小盘混合', '2026-06-03', 1.02732000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (592, '110011', '易方达中小盘混合', '2026-06-02', 1.02551000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (593, '110011', '易方达中小盘混合', '2026-06-01', 1.02390000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (594, '110011', '易方达中小盘混合', '2026-05-31', 1.02374000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (595, '110011', '易方达中小盘混合', '2026-05-30', 1.02183000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (596, '110011', '易方达中小盘混合', '2026-05-29', 1.02102000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (597, '110011', '易方达中小盘混合', '2026-05-28', 1.01921000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (598, '110011', '易方达中小盘混合', '2026-05-27', 1.01760000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (599, '110011', '易方达中小盘混合', '2026-05-26', 1.01744000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (600, '110011', '易方达中小盘混合', '2026-05-25', 1.01553000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (601, '519696', '交银环球精选混合(QDII)', '2026-06-23', 1.08083000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (602, '519696', '交银环球精选混合(QDII)', '2026-06-22', 1.07908000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (603, '519696', '交银环球精选混合(QDII)', '2026-06-21', 1.07753000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (604, '519696', '交银环球精选混合(QDII)', '2026-06-20', 1.07743000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (605, '519696', '交银环球精选混合(QDII)', '2026-06-19', 1.07558000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (606, '519696', '交银环球精选混合(QDII)', '2026-06-18', 1.07483000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (607, '519696', '交银环球精选混合(QDII)', '2026-06-17', 1.07308000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (608, '519696', '交银环球精选混合(QDII)', '2026-06-16', 1.07153000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (609, '519696', '交银环球精选混合(QDII)', '2026-06-15', 1.07143000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (610, '519696', '交银环球精选混合(QDII)', '2026-06-14', 1.06958000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (611, '519696', '交银环球精选混合(QDII)', '2026-06-13', 1.06883000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (612, '519696', '交银环球精选混合(QDII)', '2026-06-12', 1.06708000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (613, '519696', '交银环球精选混合(QDII)', '2026-06-11', 1.06553000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (614, '519696', '交银环球精选混合(QDII)', '2026-06-10', 1.06543000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (615, '519696', '交银环球精选混合(QDII)', '2026-06-09', 1.06358000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (616, '519696', '交银环球精选混合(QDII)', '2026-06-08', 1.06283000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (617, '519696', '交银环球精选混合(QDII)', '2026-06-07', 1.06108000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (618, '519696', '交银环球精选混合(QDII)', '2026-06-06', 1.05953000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (619, '519696', '交银环球精选混合(QDII)', '2026-06-05', 1.05943000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (620, '519696', '交银环球精选混合(QDII)', '2026-06-04', 1.05758000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (621, '519696', '交银环球精选混合(QDII)', '2026-06-03', 1.05683000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (622, '519696', '交银环球精选混合(QDII)', '2026-06-02', 1.05508000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (623, '519696', '交银环球精选混合(QDII)', '2026-06-01', 1.05353000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (624, '519696', '交银环球精选混合(QDII)', '2026-05-31', 1.05343000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (625, '519696', '交银环球精选混合(QDII)', '2026-05-30', 1.05158000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (626, '519696', '交银环球精选混合(QDII)', '2026-05-29', 1.05083000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (627, '519696', '交银环球精选混合(QDII)', '2026-05-28', 1.04908000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (628, '519696', '交银环球精选混合(QDII)', '2026-05-27', 1.04753000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (629, '519696', '交银环球精选混合(QDII)', '2026-05-26', 1.04743000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (630, '519696', '交银环球精选混合(QDII)', '2026-05-25', 1.04558000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (631, '161039', '富国中证1000指数增强', '2026-06-23', 1.05523000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (632, '161039', '富国中证1000指数增强', '2026-06-22', 1.05447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (633, '161039', '富国中证1000指数增强', '2026-06-21', 1.05271000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (634, '161039', '富国中证1000指数增强', '2026-06-20', 1.05115000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (635, '161039', '富国中证1000指数增强', '2026-06-19', 1.05104000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (636, '161039', '富国中证1000指数增强', '2026-06-18', 1.04918000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (637, '161039', '富国中证1000指数增强', '2026-06-17', 1.04842000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (638, '161039', '富国中证1000指数增强', '2026-06-16', 1.04666000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (639, '161039', '富国中证1000指数增强', '2026-06-15', 1.04510000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (640, '161039', '富国中证1000指数增强', '2026-06-14', 1.04499000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (641, '161039', '富国中证1000指数增强', '2026-06-13', 1.04313000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (642, '161039', '富国中证1000指数增强', '2026-06-12', 1.04237000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (643, '161039', '富国中证1000指数增强', '2026-06-11', 1.04061000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (644, '161039', '富国中证1000指数增强', '2026-06-10', 1.03905000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (645, '161039', '富国中证1000指数增强', '2026-06-09', 1.03894000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (646, '161039', '富国中证1000指数增强', '2026-06-08', 1.03708000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (647, '161039', '富国中证1000指数增强', '2026-06-07', 1.03632000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (648, '161039', '富国中证1000指数增强', '2026-06-06', 1.03456000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (649, '161039', '富国中证1000指数增强', '2026-06-05', 1.03300000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (650, '161039', '富国中证1000指数增强', '2026-06-04', 1.03289000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (651, '161039', '富国中证1000指数增强', '2026-06-03', 1.03103000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (652, '161039', '富国中证1000指数增强', '2026-06-02', 1.03027000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (653, '161039', '富国中证1000指数增强', '2026-06-01', 1.02851000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (654, '161039', '富国中证1000指数增强', '2026-05-31', 1.02695000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (655, '161039', '富国中证1000指数增强', '2026-05-30', 1.02684000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (656, '161039', '富国中证1000指数增强', '2026-05-29', 1.02498000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (657, '161039', '富国中证1000指数增强', '2026-05-28', 1.02422000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (658, '161039', '富国中证1000指数增强', '2026-05-27', 1.02246000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (659, '161039', '富国中证1000指数增强', '2026-05-26', 1.02090000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (660, '161039', '富国中证1000指数增强', '2026-05-25', 1.02079000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (661, '159915', '易方达创业板ETF', '2026-06-23', 1.05339000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (662, '159915', '易方达创业板ETF', '2026-06-22', 1.05153000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (663, '159915', '易方达创业板ETF', '2026-06-21', 1.05077000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (664, '159915', '易方达创业板ETF', '2026-06-20', 1.04901000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (665, '159915', '易方达创业板ETF', '2026-06-19', 1.04745000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (666, '159915', '易方达创业板ETF', '2026-06-18', 1.04734000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (667, '159915', '易方达创业板ETF', '2026-06-17', 1.04548000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (668, '159915', '易方达创业板ETF', '2026-06-16', 1.04472000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (669, '159915', '易方达创业板ETF', '2026-06-15', 1.04296000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (670, '159915', '易方达创业板ETF', '2026-06-14', 1.04140000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (671, '159915', '易方达创业板ETF', '2026-06-13', 1.04129000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (672, '159915', '易方达创业板ETF', '2026-06-12', 1.03943000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (673, '159915', '易方达创业板ETF', '2026-06-11', 1.03867000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (674, '159915', '易方达创业板ETF', '2026-06-10', 1.03691000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (675, '159915', '易方达创业板ETF', '2026-06-09', 1.03535000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (676, '159915', '易方达创业板ETF', '2026-06-08', 1.03524000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (677, '159915', '易方达创业板ETF', '2026-06-07', 1.03338000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (678, '159915', '易方达创业板ETF', '2026-06-06', 1.03262000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (679, '159915', '易方达创业板ETF', '2026-06-05', 1.03086000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (680, '159915', '易方达创业板ETF', '2026-06-04', 1.02930000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (681, '159915', '易方达创业板ETF', '2026-06-03', 1.02919000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (682, '159915', '易方达创业板ETF', '2026-06-02', 1.02733000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (683, '159915', '易方达创业板ETF', '2026-06-01', 1.02657000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (684, '159915', '易方达创业板ETF', '2026-05-31', 1.02481000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (685, '159915', '易方达创业板ETF', '2026-05-30', 1.02325000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (686, '159915', '易方达创业板ETF', '2026-05-29', 1.02314000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (687, '159915', '易方达创业板ETF', '2026-05-28', 1.02128000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (688, '159915', '易方达创业板ETF', '2026-05-27', 1.02052000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (689, '159915', '易方达创业板ETF', '2026-05-26', 1.01876000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (690, '159915', '易方达创业板ETF', '2026-05-25', 1.01720000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (691, '510300', '华泰柏瑞沪深300ETF', '2026-06-23', 1.07937000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (692, '510300', '华泰柏瑞沪深300ETF', '2026-06-22', 1.07749000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (693, '510300', '华泰柏瑞沪深300ETF', '2026-06-21', 1.07671000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (694, '510300', '华泰柏瑞沪深300ETF', '2026-06-20', 1.07493000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (695, '510300', '华泰柏瑞沪深300ETF', '2026-06-19', 1.07335000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (696, '510300', '华泰柏瑞沪深300ETF', '2026-06-18', 1.07322000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (697, '510300', '华泰柏瑞沪深300ETF', '2026-06-17', 1.07134000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (698, '510300', '华泰柏瑞沪深300ETF', '2026-06-16', 1.07056000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (699, '510300', '华泰柏瑞沪深300ETF', '2026-06-15', 1.06878000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (700, '510300', '华泰柏瑞沪深300ETF', '2026-06-14', 1.06720000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (701, '510300', '华泰柏瑞沪深300ETF', '2026-06-13', 1.06707000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (702, '510300', '华泰柏瑞沪深300ETF', '2026-06-12', 1.06519000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (703, '510300', '华泰柏瑞沪深300ETF', '2026-06-11', 1.06441000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (704, '510300', '华泰柏瑞沪深300ETF', '2026-06-10', 1.06263000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (705, '510300', '华泰柏瑞沪深300ETF', '2026-06-09', 1.06105000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (706, '510300', '华泰柏瑞沪深300ETF', '2026-06-08', 1.06092000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (707, '510300', '华泰柏瑞沪深300ETF', '2026-06-07', 1.05904000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (708, '510300', '华泰柏瑞沪深300ETF', '2026-06-06', 1.05826000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (709, '510300', '华泰柏瑞沪深300ETF', '2026-06-05', 1.05648000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (710, '510300', '华泰柏瑞沪深300ETF', '2026-06-04', 1.05490000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (711, '510300', '华泰柏瑞沪深300ETF', '2026-06-03', 1.05477000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (712, '510300', '华泰柏瑞沪深300ETF', '2026-06-02', 1.05289000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (713, '510300', '华泰柏瑞沪深300ETF', '2026-06-01', 1.05211000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (714, '510300', '华泰柏瑞沪深300ETF', '2026-05-31', 1.05033000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (715, '510300', '华泰柏瑞沪深300ETF', '2026-05-30', 1.04875000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (716, '510300', '华泰柏瑞沪深300ETF', '2026-05-29', 1.04862000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (717, '510300', '华泰柏瑞沪深300ETF', '2026-05-28', 1.04674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (718, '510300', '华泰柏瑞沪深300ETF', '2026-05-27', 1.04596000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (719, '510300', '华泰柏瑞沪深300ETF', '2026-05-26', 1.04418000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (720, '510300', '华泰柏瑞沪深300ETF', '2026-05-25', 1.04260000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (721, '512690', '鹏华中证酒ETF', '2026-06-23', 1.07419000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (722, '512690', '鹏华中证酒ETF', '2026-06-22', 1.07240000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (723, '512690', '鹏华中证酒ETF', '2026-06-21', 1.07081000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (724, '512690', '鹏华中证酒ETF', '2026-06-20', 1.07067000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (725, '512690', '鹏华中证酒ETF', '2026-06-19', 1.06878000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (726, '512690', '鹏华中证酒ETF', '2026-06-18', 1.06799000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (727, '512690', '鹏华中证酒ETF', '2026-06-17', 1.06620000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (728, '512690', '鹏华中证酒ETF', '2026-06-16', 1.06461000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (729, '512690', '鹏华中证酒ETF', '2026-06-15', 1.06447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (730, '512690', '鹏华中证酒ETF', '2026-06-14', 1.06258000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (731, '512690', '鹏华中证酒ETF', '2026-06-13', 1.06179000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (732, '512690', '鹏华中证酒ETF', '2026-06-12', 1.06000000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (733, '512690', '鹏华中证酒ETF', '2026-06-11', 1.05841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (734, '512690', '鹏华中证酒ETF', '2026-06-10', 1.05827000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (735, '512690', '鹏华中证酒ETF', '2026-06-09', 1.05638000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (736, '512690', '鹏华中证酒ETF', '2026-06-08', 1.05559000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (737, '512690', '鹏华中证酒ETF', '2026-06-07', 1.05380000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (738, '512690', '鹏华中证酒ETF', '2026-06-06', 1.05221000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (739, '512690', '鹏华中证酒ETF', '2026-06-05', 1.05207000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (740, '512690', '鹏华中证酒ETF', '2026-06-04', 1.05018000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (741, '512690', '鹏华中证酒ETF', '2026-06-03', 1.04939000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (742, '512690', '鹏华中证酒ETF', '2026-06-02', 1.04760000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (743, '512690', '鹏华中证酒ETF', '2026-06-01', 1.04601000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (744, '512690', '鹏华中证酒ETF', '2026-05-31', 1.04587000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (745, '512690', '鹏华中证酒ETF', '2026-05-30', 1.04398000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (746, '512690', '鹏华中证酒ETF', '2026-05-29', 1.04319000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (747, '512690', '鹏华中证酒ETF', '2026-05-28', 1.04140000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (748, '512690', '鹏华中证酒ETF', '2026-05-27', 1.03981000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (749, '512690', '鹏华中证酒ETF', '2026-05-26', 1.03967000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (750, '512690', '鹏华中证酒ETF', '2026-05-25', 1.03778000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (751, '515790', '华夏中证新能源ETF', '2026-06-23', 1.05238000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (752, '515790', '华夏中证新能源ETF', '2026-06-22', 1.05058000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (753, '515790', '华夏中证新能源ETF', '2026-06-21', 1.04898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (754, '515790', '华夏中证新能源ETF', '2026-06-20', 1.04883000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (755, '515790', '华夏中证新能源ETF', '2026-06-19', 1.04693000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (756, '515790', '华夏中证新能源ETF', '2026-06-18', 1.04613000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (757, '515790', '华夏中证新能源ETF', '2026-06-17', 1.04433000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (758, '515790', '华夏中证新能源ETF', '2026-06-16', 1.04273000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (759, '515790', '华夏中证新能源ETF', '2026-06-15', 1.04258000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (760, '515790', '华夏中证新能源ETF', '2026-06-14', 1.04068000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (761, '515790', '华夏中证新能源ETF', '2026-06-13', 1.03988000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (762, '515790', '华夏中证新能源ETF', '2026-06-12', 1.03808000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (763, '515790', '华夏中证新能源ETF', '2026-06-11', 1.03648000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (764, '515790', '华夏中证新能源ETF', '2026-06-10', 1.03633000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (765, '515790', '华夏中证新能源ETF', '2026-06-09', 1.03443000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (766, '515790', '华夏中证新能源ETF', '2026-06-08', 1.03363000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (767, '515790', '华夏中证新能源ETF', '2026-06-07', 1.03183000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (768, '515790', '华夏中证新能源ETF', '2026-06-06', 1.03023000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (769, '515790', '华夏中证新能源ETF', '2026-06-05', 1.03008000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (770, '515790', '华夏中证新能源ETF', '2026-06-04', 1.02818000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (771, '515790', '华夏中证新能源ETF', '2026-06-03', 1.02738000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (772, '515790', '华夏中证新能源ETF', '2026-06-02', 1.02558000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (773, '515790', '华夏中证新能源ETF', '2026-06-01', 1.02398000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (774, '515790', '华夏中证新能源ETF', '2026-05-31', 1.02383000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (775, '515790', '华夏中证新能源ETF', '2026-05-30', 1.02193000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (776, '515790', '华夏中证新能源ETF', '2026-05-29', 1.02113000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (777, '515790', '华夏中证新能源ETF', '2026-05-28', 1.01933000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (778, '515790', '华夏中证新能源ETF', '2026-05-27', 1.01773000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (779, '515790', '华夏中证新能源ETF', '2026-05-26', 1.01758000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (780, '515790', '华夏中证新能源ETF', '2026-05-25', 1.01568000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (781, '320007', '诺安成长混合', '2026-06-23', 1.04090000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (782, '320007', '诺安成长混合', '2026-06-22', 1.03900000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (783, '320007', '诺安成长混合', '2026-06-21', 1.03820000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (784, '320007', '诺安成长混合', '2026-06-20', 1.03640000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (785, '320007', '诺安成长混合', '2026-06-19', 1.03480000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (786, '320007', '诺安成长混合', '2026-06-18', 1.03465000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (787, '320007', '诺安成长混合', '2026-06-17', 1.03275000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (788, '320007', '诺安成长混合', '2026-06-16', 1.03195000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (789, '320007', '诺安成长混合', '2026-06-15', 1.03015000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (790, '320007', '诺安成长混合', '2026-06-14', 1.02855000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (791, '320007', '诺安成长混合', '2026-06-13', 1.02840000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (792, '320007', '诺安成长混合', '2026-06-12', 1.02650000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (793, '320007', '诺安成长混合', '2026-06-11', 1.02570000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (794, '320007', '诺安成长混合', '2026-06-10', 1.02390000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (795, '320007', '诺安成长混合', '2026-06-09', 1.02230000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (796, '320007', '诺安成长混合', '2026-06-08', 1.02215000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (797, '320007', '诺安成长混合', '2026-06-07', 1.02025000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (798, '320007', '诺安成长混合', '2026-06-06', 1.01945000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (799, '320007', '诺安成长混合', '2026-06-05', 1.01765000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (800, '320007', '诺安成长混合', '2026-06-04', 1.01605000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (801, '320007', '诺安成长混合', '2026-06-03', 1.01590000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (802, '320007', '诺安成长混合', '2026-06-02', 1.01400000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (803, '320007', '诺安成长混合', '2026-06-01', 1.01320000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (804, '320007', '诺安成长混合', '2026-05-31', 1.01140000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (805, '320007', '诺安成长混合', '2026-05-30', 1.00980000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (806, '320007', '诺安成长混合', '2026-05-29', 1.00965000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (807, '320007', '诺安成长混合', '2026-05-28', 1.00775000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (808, '320007', '诺安成长混合', '2026-05-27', 1.00695000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (809, '320007', '诺安成长混合', '2026-05-26', 1.00515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (810, '320007', '诺安成长混合', '2026-05-25', 1.00355000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (811, '260108', '景顺长城新兴成长混合', '2026-06-23', 1.05604000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (812, '260108', '景顺长城新兴成长混合', '2026-06-22', 1.05413000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (813, '260108', '景顺长城新兴成长混合', '2026-06-21', 1.05332000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (814, '260108', '景顺长城新兴成长混合', '2026-06-20', 1.05151000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (815, '260108', '景顺长城新兴成长混合', '2026-06-19', 1.04990000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (816, '260108', '景顺长城新兴成长混合', '2026-06-18', 1.04974000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (817, '260108', '景顺长城新兴成长混合', '2026-06-17', 1.04783000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (818, '260108', '景顺长城新兴成长混合', '2026-06-16', 1.04702000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (819, '260108', '景顺长城新兴成长混合', '2026-06-15', 1.04521000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (820, '260108', '景顺长城新兴成长混合', '2026-06-14', 1.04360000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (821, '260108', '景顺长城新兴成长混合', '2026-06-13', 1.04344000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (822, '260108', '景顺长城新兴成长混合', '2026-06-12', 1.04153000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (823, '260108', '景顺长城新兴成长混合', '2026-06-11', 1.04072000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (824, '260108', '景顺长城新兴成长混合', '2026-06-10', 1.03891000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (825, '260108', '景顺长城新兴成长混合', '2026-06-09', 1.03730000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (826, '260108', '景顺长城新兴成长混合', '2026-06-08', 1.03714000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (827, '260108', '景顺长城新兴成长混合', '2026-06-07', 1.03523000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (828, '260108', '景顺长城新兴成长混合', '2026-06-06', 1.03442000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (829, '260108', '景顺长城新兴成长混合', '2026-06-05', 1.03261000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (830, '260108', '景顺长城新兴成长混合', '2026-06-04', 1.03100000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (831, '260108', '景顺长城新兴成长混合', '2026-06-03', 1.03084000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (832, '260108', '景顺长城新兴成长混合', '2026-06-02', 1.02893000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (833, '260108', '景顺长城新兴成长混合', '2026-06-01', 1.02812000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (834, '260108', '景顺长城新兴成长混合', '2026-05-31', 1.02631000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (835, '260108', '景顺长城新兴成长混合', '2026-05-30', 1.02470000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (836, '260108', '景顺长城新兴成长混合', '2026-05-29', 1.02454000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (837, '260108', '景顺长城新兴成长混合', '2026-05-28', 1.02263000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (838, '260108', '景顺长城新兴成长混合', '2026-05-27', 1.02182000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (839, '260108', '景顺长城新兴成长混合', '2026-05-26', 1.02001000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (840, '260108', '景顺长城新兴成长混合', '2026-05-25', 1.01840000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (841, '163406', '兴全合润混合', '2026-06-23', 1.04103000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (842, '163406', '兴全合润混合', '2026-06-22', 1.04022000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (843, '163406', '兴全合润混合', '2026-06-21', 1.03841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (844, '163406', '兴全合润混合', '2026-06-20', 1.03680000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (845, '163406', '兴全合润混合', '2026-06-19', 1.03664000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (846, '163406', '兴全合润混合', '2026-06-18', 1.03473000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (847, '163406', '兴全合润混合', '2026-06-17', 1.03392000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (848, '163406', '兴全合润混合', '2026-06-16', 1.03211000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (849, '163406', '兴全合润混合', '2026-06-15', 1.03050000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (850, '163406', '兴全合润混合', '2026-06-14', 1.03034000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (851, '163406', '兴全合润混合', '2026-06-13', 1.02843000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (852, '163406', '兴全合润混合', '2026-06-12', 1.02762000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (853, '163406', '兴全合润混合', '2026-06-11', 1.02581000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (854, '163406', '兴全合润混合', '2026-06-10', 1.02420000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (855, '163406', '兴全合润混合', '2026-06-09', 1.02404000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (856, '163406', '兴全合润混合', '2026-06-08', 1.02213000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (857, '163406', '兴全合润混合', '2026-06-07', 1.02132000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (858, '163406', '兴全合润混合', '2026-06-06', 1.01951000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (859, '163406', '兴全合润混合', '2026-06-05', 1.01790000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (860, '163406', '兴全合润混合', '2026-06-04', 1.01774000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (861, '163406', '兴全合润混合', '2026-06-03', 1.01583000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (862, '163406', '兴全合润混合', '2026-06-02', 1.01502000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (863, '163406', '兴全合润混合', '2026-06-01', 1.01321000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (864, '163406', '兴全合润混合', '2026-05-31', 1.01160000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (865, '163406', '兴全合润混合', '2026-05-30', 1.01144000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (866, '163406', '兴全合润混合', '2026-05-29', 1.00953000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (867, '163406', '兴全合润混合', '2026-05-28', 1.00872000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (868, '163406', '兴全合润混合', '2026-05-27', 1.00691000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (869, '163406', '兴全合润混合', '2026-05-26', 1.00530000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (870, '163406', '兴全合润混合', '2026-05-25', 1.00514000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (871, '000452', '南方医药保健灵活配置混合', '2026-06-23', 1.05356000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (872, '000452', '南方医药保健灵活配置混合', '2026-06-22', 1.05341000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (873, '000452', '南方医药保健灵活配置混合', '2026-06-21', 1.05151000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (874, '000452', '南方医药保健灵活配置混合', '2026-06-20', 1.05071000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (875, '000452', '南方医药保健灵活配置混合', '2026-06-19', 1.04891000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (876, '000452', '南方医药保健灵活配置混合', '2026-06-18', 1.04731000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (877, '000452', '南方医药保健灵活配置混合', '2026-06-17', 1.04716000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (878, '000452', '南方医药保健灵活配置混合', '2026-06-16', 1.04526000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (879, '000452', '南方医药保健灵活配置混合', '2026-06-15', 1.04446000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (880, '000452', '南方医药保健灵活配置混合', '2026-06-14', 1.04266000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (881, '000452', '南方医药保健灵活配置混合', '2026-06-13', 1.04106000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (882, '000452', '南方医药保健灵活配置混合', '2026-06-12', 1.04091000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (883, '000452', '南方医药保健灵活配置混合', '2026-06-11', 1.03901000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (884, '000452', '南方医药保健灵活配置混合', '2026-06-10', 1.03821000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (885, '000452', '南方医药保健灵活配置混合', '2026-06-09', 1.03641000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (886, '000452', '南方医药保健灵活配置混合', '2026-06-08', 1.03481000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (887, '000452', '南方医药保健灵活配置混合', '2026-06-07', 1.03466000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (888, '000452', '南方医药保健灵活配置混合', '2026-06-06', 1.03276000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (889, '000452', '南方医药保健灵活配置混合', '2026-06-05', 1.03196000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (890, '000452', '南方医药保健灵活配置混合', '2026-06-04', 1.03016000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (891, '000452', '南方医药保健灵活配置混合', '2026-06-03', 1.02856000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (892, '000452', '南方医药保健灵活配置混合', '2026-06-02', 1.02841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (893, '000452', '南方医药保健灵活配置混合', '2026-06-01', 1.02651000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (894, '000452', '南方医药保健灵活配置混合', '2026-05-31', 1.02571000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (895, '000452', '南方医药保健灵活配置混合', '2026-05-30', 1.02391000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (896, '000452', '南方医药保健灵活配置混合', '2026-05-29', 1.02231000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (897, '000452', '南方医药保健灵活配置混合', '2026-05-28', 1.02216000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (898, '000452', '南方医药保健灵活配置混合', '2026-05-27', 1.02026000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (899, '000452', '南方医药保健灵活配置混合', '2026-05-26', 1.01946000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (900, '000452', '南方医药保健灵活配置混合', '2026-05-25', 1.01766000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (901, '040046', '华安纳斯达克100指数', '2026-06-23', 1.05418000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (902, '040046', '华安纳斯达克100指数', '2026-06-22', 1.05337000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (903, '040046', '华安纳斯达克100指数', '2026-06-21', 1.05156000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (904, '040046', '华安纳斯达克100指数', '2026-06-20', 1.04995000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (905, '040046', '华安纳斯达克100指数', '2026-06-19', 1.04979000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (906, '040046', '华安纳斯达克100指数', '2026-06-18', 1.04788000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (907, '040046', '华安纳斯达克100指数', '2026-06-17', 1.04707000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (908, '040046', '华安纳斯达克100指数', '2026-06-16', 1.04526000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (909, '040046', '华安纳斯达克100指数', '2026-06-15', 1.04365000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (910, '040046', '华安纳斯达克100指数', '2026-06-14', 1.04349000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (911, '040046', '华安纳斯达克100指数', '2026-06-13', 1.04158000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (912, '040046', '华安纳斯达克100指数', '2026-06-12', 1.04077000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (913, '040046', '华安纳斯达克100指数', '2026-06-11', 1.03896000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (914, '040046', '华安纳斯达克100指数', '2026-06-10', 1.03735000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (915, '040046', '华安纳斯达克100指数', '2026-06-09', 1.03719000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (916, '040046', '华安纳斯达克100指数', '2026-06-08', 1.03528000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (917, '040046', '华安纳斯达克100指数', '2026-06-07', 1.03447000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (918, '040046', '华安纳斯达克100指数', '2026-06-06', 1.03266000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (919, '040046', '华安纳斯达克100指数', '2026-06-05', 1.03105000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (920, '040046', '华安纳斯达克100指数', '2026-06-04', 1.03089000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (921, '040046', '华安纳斯达克100指数', '2026-06-03', 1.02898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (922, '040046', '华安纳斯达克100指数', '2026-06-02', 1.02817000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (923, '040046', '华安纳斯达克100指数', '2026-06-01', 1.02636000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (924, '040046', '华安纳斯达克100指数', '2026-05-31', 1.02475000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (925, '040046', '华安纳斯达克100指数', '2026-05-30', 1.02459000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (926, '040046', '华安纳斯达克100指数', '2026-05-29', 1.02268000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (927, '040046', '华安纳斯达克100指数', '2026-05-28', 1.02187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (928, '040046', '华安纳斯达克100指数', '2026-05-27', 1.02006000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (929, '040046', '华安纳斯达克100指数', '2026-05-26', 1.01845000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (930, '040046', '华安纳斯达克100指数', '2026-05-25', 1.01829000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (931, '513100', '国泰纳斯达克100ETF', '2026-06-23', 1.05276000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (932, '513100', '国泰纳斯达克100ETF', '2026-06-22', 1.05120000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (933, '513100', '国泰纳斯达克100ETF', '2026-06-21', 1.05109000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (934, '513100', '国泰纳斯达克100ETF', '2026-06-20', 1.04923000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (935, '513100', '国泰纳斯达克100ETF', '2026-06-19', 1.04847000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (936, '513100', '国泰纳斯达克100ETF', '2026-06-18', 1.04671000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (937, '513100', '国泰纳斯达克100ETF', '2026-06-17', 1.04515000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (938, '513100', '国泰纳斯达克100ETF', '2026-06-16', 1.04504000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (939, '513100', '国泰纳斯达克100ETF', '2026-06-15', 1.04318000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (940, '513100', '国泰纳斯达克100ETF', '2026-06-14', 1.04242000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (941, '513100', '国泰纳斯达克100ETF', '2026-06-13', 1.04066000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (942, '513100', '国泰纳斯达克100ETF', '2026-06-12', 1.03910000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (943, '513100', '国泰纳斯达克100ETF', '2026-06-11', 1.03899000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (944, '513100', '国泰纳斯达克100ETF', '2026-06-10', 1.03713000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (945, '513100', '国泰纳斯达克100ETF', '2026-06-09', 1.03637000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (946, '513100', '国泰纳斯达克100ETF', '2026-06-08', 1.03461000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (947, '513100', '国泰纳斯达克100ETF', '2026-06-07', 1.03305000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (948, '513100', '国泰纳斯达克100ETF', '2026-06-06', 1.03294000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (949, '513100', '国泰纳斯达克100ETF', '2026-06-05', 1.03108000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (950, '513100', '国泰纳斯达克100ETF', '2026-06-04', 1.03032000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (951, '513100', '国泰纳斯达克100ETF', '2026-06-03', 1.02856000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (952, '513100', '国泰纳斯达克100ETF', '2026-06-02', 1.02700000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (953, '513100', '国泰纳斯达克100ETF', '2026-06-01', 1.02689000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (954, '513100', '国泰纳斯达克100ETF', '2026-05-31', 1.02503000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (955, '513100', '国泰纳斯达克100ETF', '2026-05-30', 1.02427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (956, '513100', '国泰纳斯达克100ETF', '2026-05-29', 1.02251000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (957, '513100', '国泰纳斯达克100ETF', '2026-05-28', 1.02095000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (958, '513100', '国泰纳斯达克100ETF', '2026-05-27', 1.02084000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (959, '513100', '国泰纳斯达克100ETF', '2026-05-26', 1.01898000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (960, '513100', '国泰纳斯达克100ETF', '2026-05-25', 1.01822000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (961, '000307', '易方达黄金ETF联接A', '2026-06-23', 1.04685000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (962, '000307', '易方达黄金ETF联接A', '2026-06-22', 1.04606000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (963, '000307', '易方达黄金ETF联接A', '2026-06-21', 1.04427000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (964, '000307', '易方达黄金ETF联接A', '2026-06-20', 1.04268000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (965, '000307', '易方达黄金ETF联接A', '2026-06-19', 1.04254000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (966, '000307', '易方达黄金ETF联接A', '2026-06-18', 1.04065000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (967, '000307', '易方达黄金ETF联接A', '2026-06-17', 1.03986000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (968, '000307', '易方达黄金ETF联接A', '2026-06-16', 1.03807000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (969, '000307', '易方达黄金ETF联接A', '2026-06-15', 1.03648000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (970, '000307', '易方达黄金ETF联接A', '2026-06-14', 1.03634000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (971, '000307', '易方达黄金ETF联接A', '2026-06-13', 1.03445000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (972, '000307', '易方达黄金ETF联接A', '2026-06-12', 1.03366000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (973, '000307', '易方达黄金ETF联接A', '2026-06-11', 1.03187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (974, '000307', '易方达黄金ETF联接A', '2026-06-10', 1.03028000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (975, '000307', '易方达黄金ETF联接A', '2026-06-09', 1.03014000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (976, '000307', '易方达黄金ETF联接A', '2026-06-08', 1.02825000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (977, '000307', '易方达黄金ETF联接A', '2026-06-07', 1.02746000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (978, '000307', '易方达黄金ETF联接A', '2026-06-06', 1.02567000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (979, '000307', '易方达黄金ETF联接A', '2026-06-05', 1.02408000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (980, '000307', '易方达黄金ETF联接A', '2026-06-04', 1.02394000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (981, '000307', '易方达黄金ETF联接A', '2026-06-03', 1.02205000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (982, '000307', '易方达黄金ETF联接A', '2026-06-02', 1.02126000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (983, '000307', '易方达黄金ETF联接A', '2026-06-01', 1.01947000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (984, '000307', '易方达黄金ETF联接A', '2026-05-31', 1.01788000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (985, '000307', '易方达黄金ETF联接A', '2026-05-30', 1.01774000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (986, '000307', '易方达黄金ETF联接A', '2026-05-29', 1.01585000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (987, '000307', '易方达黄金ETF联接A', '2026-05-28', 1.01506000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (988, '000307', '易方达黄金ETF联接A', '2026-05-27', 1.01327000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (989, '000307', '易方达黄金ETF联接A', '2026-05-26', 1.01168000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (990, '000307', '易方达黄金ETF联接A', '2026-05-25', 1.01154000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (991, '518880', '华安黄金ETF', '2026-06-23', 1.06429000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (992, '518880', '华安黄金ETF', '2026-06-22', 1.06243000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (993, '518880', '华安黄金ETF', '2026-06-21', 1.06167000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (994, '518880', '华安黄金ETF', '2026-06-20', 1.05991000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (995, '518880', '华安黄金ETF', '2026-06-19', 1.05835000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (996, '518880', '华安黄金ETF', '2026-06-18', 1.05824000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (997, '518880', '华安黄金ETF', '2026-06-17', 1.05638000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (998, '518880', '华安黄金ETF', '2026-06-16', 1.05562000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (999, '518880', '华安黄金ETF', '2026-06-15', 1.05386000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1000, '518880', '华安黄金ETF', '2026-06-14', 1.05230000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1001, '518880', '华安黄金ETF', '2026-06-13', 1.05219000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1002, '518880', '华安黄金ETF', '2026-06-12', 1.05033000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1003, '518880', '华安黄金ETF', '2026-06-11', 1.04957000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1004, '518880', '华安黄金ETF', '2026-06-10', 1.04781000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1005, '518880', '华安黄金ETF', '2026-06-09', 1.04625000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1006, '518880', '华安黄金ETF', '2026-06-08', 1.04614000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1007, '518880', '华安黄金ETF', '2026-06-07', 1.04428000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1008, '518880', '华安黄金ETF', '2026-06-06', 1.04352000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1009, '518880', '华安黄金ETF', '2026-06-05', 1.04176000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1010, '518880', '华安黄金ETF', '2026-06-04', 1.04020000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1011, '518880', '华安黄金ETF', '2026-06-03', 1.04009000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1012, '518880', '华安黄金ETF', '2026-06-02', 1.03823000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1013, '518880', '华安黄金ETF', '2026-06-01', 1.03747000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1014, '518880', '华安黄金ETF', '2026-05-31', 1.03571000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1015, '518880', '华安黄金ETF', '2026-05-30', 1.03415000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1016, '518880', '华安黄金ETF', '2026-05-29', 1.03404000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1017, '518880', '华安黄金ETF', '2026-05-28', 1.03218000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1018, '518880', '华安黄金ETF', '2026-05-27', 1.03142000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1019, '518880', '华安黄金ETF', '2026-05-26', 1.02966000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1020, '518880', '华安黄金ETF', '2026-05-25', 1.02810000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1021, '161005', '富国天惠成长混合', '2026-06-23', 1.04710000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1022, '161005', '富国天惠成长混合', '2026-06-22', 1.04699000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1023, '161005', '富国天惠成长混合', '2026-06-21', 1.04513000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1024, '161005', '富国天惠成长混合', '2026-06-20', 1.04437000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1025, '161005', '富国天惠成长混合', '2026-06-19', 1.04261000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1026, '161005', '富国天惠成长混合', '2026-06-18', 1.04105000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1027, '161005', '富国天惠成长混合', '2026-06-17', 1.04094000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1028, '161005', '富国天惠成长混合', '2026-06-16', 1.03908000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1029, '161005', '富国天惠成长混合', '2026-06-15', 1.03832000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1030, '161005', '富国天惠成长混合', '2026-06-14', 1.03656000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1031, '161005', '富国天惠成长混合', '2026-06-13', 1.03500000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1032, '161005', '富国天惠成长混合', '2026-06-12', 1.03489000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1033, '161005', '富国天惠成长混合', '2026-06-11', 1.03303000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1034, '161005', '富国天惠成长混合', '2026-06-10', 1.03227000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1035, '161005', '富国天惠成长混合', '2026-06-09', 1.03051000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1036, '161005', '富国天惠成长混合', '2026-06-08', 1.02895000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1037, '161005', '富国天惠成长混合', '2026-06-07', 1.02884000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1038, '161005', '富国天惠成长混合', '2026-06-06', 1.02698000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1039, '161005', '富国天惠成长混合', '2026-06-05', 1.02622000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1040, '161005', '富国天惠成长混合', '2026-06-04', 1.02446000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1041, '161005', '富国天惠成长混合', '2026-06-03', 1.02290000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1042, '161005', '富国天惠成长混合', '2026-06-02', 1.02279000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1043, '161005', '富国天惠成长混合', '2026-06-01', 1.02093000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1044, '161005', '富国天惠成长混合', '2026-05-31', 1.02017000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1045, '161005', '富国天惠成长混合', '2026-05-30', 1.01841000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1046, '161005', '富国天惠成长混合', '2026-05-29', 1.01685000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1047, '161005', '富国天惠成长混合', '2026-05-28', 1.01674000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1048, '161005', '富国天惠成长混合', '2026-05-27', 1.01488000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1049, '161005', '富国天惠成长混合', '2026-05-26', 1.01412000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1050, '161005', '富国天惠成长混合', '2026-05-25', 1.01236000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1051, '398011', '中海分红增利混合', '2026-06-23', 1.06237000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1052, '398011', '中海分红增利混合', '2026-06-22', 1.06077000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1053, '398011', '中海分红增利混合', '2026-06-21', 1.06062000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1054, '398011', '中海分红增利混合', '2026-06-20', 1.05872000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1055, '398011', '中海分红增利混合', '2026-06-19', 1.05792000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1056, '398011', '中海分红增利混合', '2026-06-18', 1.05612000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1057, '398011', '中海分红增利混合', '2026-06-17', 1.05452000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1058, '398011', '中海分红增利混合', '2026-06-16', 1.05437000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1059, '398011', '中海分红增利混合', '2026-06-15', 1.05247000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1060, '398011', '中海分红增利混合', '2026-06-14', 1.05167000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1061, '398011', '中海分红增利混合', '2026-06-13', 1.04987000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1062, '398011', '中海分红增利混合', '2026-06-12', 1.04827000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1063, '398011', '中海分红增利混合', '2026-06-11', 1.04812000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1064, '398011', '中海分红增利混合', '2026-06-10', 1.04622000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1065, '398011', '中海分红增利混合', '2026-06-09', 1.04542000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1066, '398011', '中海分红增利混合', '2026-06-08', 1.04362000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1067, '398011', '中海分红增利混合', '2026-06-07', 1.04202000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1068, '398011', '中海分红增利混合', '2026-06-06', 1.04187000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1069, '398011', '中海分红增利混合', '2026-06-05', 1.03997000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1070, '398011', '中海分红增利混合', '2026-06-04', 1.03917000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1071, '398011', '中海分红增利混合', '2026-06-03', 1.03737000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1072, '398011', '中海分红增利混合', '2026-06-02', 1.03577000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1073, '398011', '中海分红增利混合', '2026-06-01', 1.03562000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1074, '398011', '中海分红增利混合', '2026-05-31', 1.03372000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1075, '398011', '中海分红增利混合', '2026-05-30', 1.03292000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1076, '398011', '中海分红增利混合', '2026-05-29', 1.03112000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1077, '398011', '中海分红增利混合', '2026-05-28', 1.02952000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1078, '398011', '中海分红增利混合', '2026-05-27', 1.02937000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1079, '398011', '中海分红增利混合', '2026-05-26', 1.02747000, NULL, '2026-06-23 22:53:34');
INSERT INTO `fund_nav` VALUES (1080, '398011', '中海分红增利混合', '2026-05-25', 1.02667000, NULL, '2026-06-23 22:53:34');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
                                 `id` bigint NOT NULL AUTO_INCREMENT,
                                 `user_id` bigint NOT NULL,
                                 `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                 `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
                                 `type` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'SYSTEM' COMMENT 'REVIEW_RESULT/SUBSCRIPTION/SYSTEM',
                                 `is_read` tinyint NULL DEFAULT 0,
                                 `related_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                                 `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
                                 PRIMARY KEY (`id`) USING BTREE,
                                 INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
                                 INDEX `idx_user_read`(`user_id` ASC, `is_read` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, 4, '新待审产品', '投顾提交了产品「德邦」，请前往审核。', 'REVIEW_RESULT', 1, '/review/pending/13', '2026-06-26 21:59:52');
INSERT INTO `notification` VALUES (2, 3, '订阅通知', '有用户订阅了您的产品「英伟达」', 'SUBSCRIPTION', 1, '/admin/products/9', '2026-06-27 00:39:34');
INSERT INTO `notification` VALUES (3, 4, '新待审产品', '投顾提交了产品「大成」，请前往审核。', 'REVIEW_RESULT', 1, '/review/pending/11', '2026-06-27 00:46:26');
INSERT INTO `notification` VALUES (4, 3, '审核通过', '您的产品「大成」已通过审核，现已发布。', 'REVIEW_RESULT', 1, '/admin/products/11', '2026-06-27 00:46:59');
INSERT INTO `notification` VALUES (5, 3, '订阅通知', '有用户订阅了您的产品「大成」', 'SUBSCRIPTION', 1, '/admin/products/11', '2026-06-27 00:47:33');
INSERT INTO `notification` VALUES (6, 3, '审核通过', '您的产品「天弘」已通过审核，现已发布。', 'REVIEW_RESULT', 1, '/admin/products/12', '2026-06-27 03:21:46');
INSERT INTO `notification` VALUES (7, 3, '订阅通知', '有用户订阅了您的产品「天弘」', 'SUBSCRIPTION', 1, '/admin/products/12', '2026-06-27 03:56:12');
INSERT INTO `notification` VALUES (8, 3, '订阅通知', '有用户订阅了您的产品「2」', 'SUBSCRIPTION', 1, '/admin/products/3', '2026-06-27 04:07:27');
INSERT INTO `notification` VALUES (9, 2, '订阅成功', '您已成功订阅产品', 'SUBSCRIPTION', 0, '/my-subscriptions', '2026-06-27 04:07:27');
INSERT INTO `notification` VALUES (10, 3, '订阅通知', '有用户取消订阅了您的产品「2」', 'SUBSCRIPTION', 1, '/admin/products/3', '2026-06-27 14:59:59');
INSERT INTO `notification` VALUES (11, 3, '订阅通知', '有用户订阅了您的产品「2」', 'SUBSCRIPTION', 1, '/admin/products/3', '2026-06-27 15:00:34');
INSERT INTO `notification` VALUES (12, 3, '审核通过', '您的产品「德邦」已通过审核，现已发布。', 'REVIEW_RESULT', 1, '/admin/products/13', '2026-06-27 15:04:07');

-- ----------------------------
-- Table structure for subscription_version_action
-- ----------------------------
DROP TABLE IF EXISTS `subscription_version_action`;
CREATE TABLE `subscription_version_action`  (
                                                `id` bigint NOT NULL AUTO_INCREMENT,
                                                `subscription_id` bigint NOT NULL COMMENT '订阅ID',
                                                `product_id` bigint NOT NULL COMMENT '产品ID',
                                                `product_version_id` bigint NOT NULL COMMENT '版本ID',
                                                `action_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'NOTICE/CONFIRM_REQUIRED',
                                                `action_status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'PENDING/CONFIRMED/CANCELLED/NOTIFIED',
                                                `change_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'NORMAL/MAJOR',
                                                `version_note` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '版本说明',
                                                `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                                `handled_at` datetime NULL DEFAULT NULL COMMENT '处理时间',
                                                PRIMARY KEY (`id`) USING BTREE,
                                                UNIQUE INDEX `uk_subscription_version_action`(`subscription_id` ASC, `product_version_id` ASC) USING BTREE,
                                                INDEX `idx_subscription_version_action_product`(`product_id` ASC, `product_version_id` ASC) USING BTREE,
                                                INDEX `idx_subscription_version_action_status`(`action_status` ASC, `action_type` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '订阅版本动作表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of subscription_version_action
-- ----------------------------

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `role_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'ADVISOR/REVIEWER/USER',
                             `role_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_sys_role_code`(`role_code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, 'USER', '普通用户', 1, '2026-06-22 19:26:17', '2026-06-22 19:26:17');
INSERT INTO `sys_role` VALUES (2, 'ADVISOR', '投顾', 1, '2026-06-22 19:26:17', '2026-06-22 19:26:17');
INSERT INTO `sys_role` VALUES (3, 'REVIEWER', '审核员', 1, '2026-06-22 19:26:17', '2026-06-22 19:26:17');
INSERT INTO `sys_role` VALUES (4, 'ADMIN', '系统管理员', 1, '2026-06-27 01:21:35', '2026-06-27 01:21:35');

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `username` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                             `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                             `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                             `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
                             `status` tinyint NOT NULL DEFAULT 1 COMMENT '1启用 0禁用',
                             `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             `sub_pin` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '交易密码（6位数字）',
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `uk_sys_user_username`(`username` ASC) USING BTREE,
                             UNIQUE INDEX `uk_sys_user_phone`(`phone` ASC) USING BTREE,
                             UNIQUE INDEX `uk_sys_user_email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, '12345', '$2a$10$sKIQfeL8MiSxE1l1s4CoY.GS/1uwUwno0OR55XFuLAGCzObbM8zS2', 'LHB', '13983338801', NULL, 1, '2026-06-22 22:59:15', '2026-06-22 22:59:15', NULL);
INSERT INTO `sys_user` VALUES (2, 'user01', '$2b$12$vDM42Vq2dukO1xP5hlEvROBP4xylXf/FEwGxlgHrR.J6ZScGddYyC', '普通用户01', '13800000001', 'user01@test.com', 1, '2026-06-23 20:27:17', '2026-06-27 03:48:21', '123456');
INSERT INTO `sys_user` VALUES (3, 'advisor01', '$2b$12$vDM42Vq2dukO1xP5hlEvROBP4xylXf/FEwGxlgHrR.J6ZScGddYyC', '投顾01', '13800000002', 'advisor01@test.com', 1, '2026-06-23 20:27:17', '2026-06-23 20:27:17', NULL);
INSERT INTO `sys_user` VALUES (4, 'reviewer01', '$2b$12$vDM42Vq2dukO1xP5hlEvROBP4xylXf/FEwGxlgHrR.J6ZScGddYyC', '审核员01', '13800000003', 'reviewer01@test.com', 1, '2026-06-23 20:27:17', '2026-06-27 02:05:24', NULL);
INSERT INTO `sys_user` VALUES (6, 'admin', '$2b$10$pLwSJhvRoU7OgoAkEuwQu.cFMcrl5zQedpxeB2PW2tRiySxqFxJD.', '管理员', NULL, NULL, 1, '2026-06-27 01:21:49', '2026-06-27 01:34:15', NULL);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
                                  `id` bigint NOT NULL AUTO_INCREMENT,
                                  `user_id` bigint NOT NULL,
                                  `role_id` bigint NOT NULL,
                                  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  PRIMARY KEY (`id`) USING BTREE,
                                  UNIQUE INDEX `uk_sys_user_role`(`user_id` ASC, `role_id` ASC) USING BTREE,
                                  INDEX `idx_sur_role_id`(`role_id` ASC) USING BTREE,
                                  CONSTRAINT `fk_sur_role` FOREIGN KEY (`role_id`) REFERENCES `sys_role` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                                  CONSTRAINT `fk_sur_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1, 1, '2026-06-22 22:59:15');
INSERT INTO `sys_user_role` VALUES (2, 2, 1, '2026-06-23 20:27:17');
INSERT INTO `sys_user_role` VALUES (3, 3, 2, '2026-06-23 20:27:17');
INSERT INTO `sys_user_role` VALUES (4, 4, 3, '2026-06-23 20:27:17');
INSERT INTO `sys_user_role` VALUES (5, 6, 4, '2026-06-27 01:25:40');

-- ----------------------------
-- Table structure for transaction_record
-- ----------------------------
DROP TABLE IF EXISTS `transaction_record`;
CREATE TABLE `transaction_record`  (
                                       `id` bigint NOT NULL AUTO_INCREMENT,
                                       `user_id` bigint NOT NULL,
                                       `product_id` bigint NOT NULL,
                                       `product_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
                                       `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'SUBSCRIBE/UNSUBSCRIBE',
                                       `amount` decimal(16, 2) NOT NULL DEFAULT 0.00,
                                       `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'COMPLETED',
                                       `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
                                       PRIMARY KEY (`id`) USING BTREE,
                                       INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
                                       INDEX `idx_user_time`(`user_id` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of transaction_record
-- ----------------------------
INSERT INTO `transaction_record` VALUES (1, 2, 3, '2', 'SUBSCRIBE', 10000.00, 'COMPLETED', '2026-06-27 04:07:27');

SET FOREIGN_KEY_CHECKS = 1;
