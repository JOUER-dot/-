-- 金融投顾平台 数据库初始化脚本
-- 数据库名称: finance
-- 字符集: utf8mb4
-- 执行前请确保数据库已创建: CREATE DATABASE IF NOT EXISTS finance DEFAULT CHARSET utf8mb4;

-- ==================== 用户与权限 ====================
CREATE TABLE IF NOT EXISTS sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(64),
    phone VARCHAR(20),
    email VARCHAR(128),
    status TINYINT DEFAULT 1 COMMENT '1-正常 0-禁用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_code VARCHAR(20) NOT NULL UNIQUE COMMENT 'ADMIN/ADVISOR/REVIEWER/USER',
    role_name VARCHAR(50) COMMENT '系统管理员/投顾/投资决策委员会/用户',
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sys_user_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    UNIQUE KEY uk_user_role (user_id, role_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==================== 产品模块 ====================
CREATE TABLE IF NOT EXISTS advisor_product (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    type VARCHAR(20) NOT NULL COMMENT 'STRATEGY/FOF',
    risk_level VARCHAR(10) NOT NULL COMMENT 'R1-R5',
    strategy_code VARCHAR(50),
    feature_tags VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' COMMENT 'DRAFT/PENDING_REVIEW/REJECTED/PUBLISHED/OFFLINE',
    creator_id BIGINT NOT NULL,
    current_version_no INT DEFAULT 0,
    published_version_no INT,
    last_reject_comment VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator (creator_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_draft (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    base_info_json TEXT COMMENT '基础信息JSON',
    params_json TEXT COMMENT '策略参数JSON',
    updated_by BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_draft_component (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    draft_id BIGINT NOT NULL,
    fund_id BIGINT NOT NULL,
    weight DECIMAL(10,6) NOT NULL,
    INDEX idx_draft_id (draft_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_version (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    version_no INT NOT NULL,
    version_status VARCHAR(20) DEFAULT 'SUBMITTED',
    change_type VARCHAR(20) DEFAULT 'NORMAL',
    version_note VARCHAR(500),
    base_info_json TEXT,
    params_json TEXT,
    base_version_id BIGINT,
    status_at_submit VARCHAR(20),
    submitted_by BIGINT,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_id (product_id),
    INDEX idx_product_version (product_id, version_no)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_component (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_version_id BIGINT NOT NULL,
    fund_id BIGINT,
    fund_code VARCHAR(20),
    fund_name VARCHAR(200),
    weight DECIMAL(10,6) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_version_id (product_version_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_review (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_version_id BIGINT,
    reviewer_id BIGINT,
    result VARCHAR(20) NOT NULL COMMENT 'APPROVED/REJECTED',
    comment VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_id (product_id),
    INDEX idx_reviewer_id (reviewer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_flow_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_version_id BIGINT,
    operator_id BIGINT,
    action_type VARCHAR(30) NOT NULL,
    comment VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_nav (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    nav_date DATE NOT NULL,
    nav DECIMAL(16,6) NOT NULL,
    cum_return DECIMAL(10,6),
    INDEX idx_product_date (product_id, nav_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_holding_snapshot (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    holding_json TEXT,
    snapshot_date DATE,
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_product_rule_decision (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_version_id BIGINT,
    base_rule_id BIGINT,
    reviewer_id BIGINT,
    override_min_fund_count INT,
    override_max_fund_count INT,
    override_max_single_weight DECIMAL(10,6),
    final_rule_json TEXT,
    decision_comment VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS advisor_strategy_rule (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    strategy_code VARCHAR(50) NOT NULL,
    product_type VARCHAR(20),
    min_fund_count INT,
    max_fund_count INT,
    min_single_weight DECIMAL(10,6),
    max_single_weight DECIMAL(10,6),
    allow_fund_types VARCHAR(200),
    risk_rule_mode VARCHAR(20),
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==================== 基金模块 ====================
CREATE TABLE IF NOT EXISTS fund_info (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fund_code VARCHAR(20) NOT NULL UNIQUE,
    fund_name VARCHAR(200) NOT NULL,
    fund_type VARCHAR(20),
    risk_level VARCHAR(10),
    company_name VARCHAR(200),
    status TINYINT DEFAULT 1 COMMENT '1-启用 0-停用',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS fund_nav (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    fund_id BIGINT NOT NULL,
    nav_date DATE NOT NULL,
    nav DECIMAL(16,6) NOT NULL,
    INDEX idx_fund_date (fund_id, nav_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==================== 订阅模块 ====================
CREATE TABLE IF NOT EXISTS advisor_product_subscription (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT 'ACTIVE/CANCELLED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_product (user_id, product_id),
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS subscription_version_action (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subscription_id BIGINT NOT NULL,
    product_version_id BIGINT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    action_status VARCHAR(20) DEFAULT 'PENDING',
    change_type VARCHAR(20),
    version_note VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    handled_at DATETIME,
    INDEX idx_subscription_id (subscription_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==================== 通知模块 ====================
CREATE TABLE IF NOT EXISTS notification (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    type VARCHAR(30) DEFAULT 'SYSTEM',
    is_read TINYINT DEFAULT 0,
    related_url VARCHAR(500),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_user_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==================== 种子数据 ====================
INSERT IGNORE INTO sys_role (role_code, role_name, status) VALUES
('ADMIN', '系统管理员', 1),
('ADVISOR', '投顾', 1),
('REVIEWER', '投资决策委员会', 1),
('USER', '普通用户', 1);

-- 默认密码: admin123 (BCrypt hash)
INSERT IGNORE INTO sys_user (username, password_hash, nickname, status) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '管理员', 1),
('advisor1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '张投顾', 1),
('reviewer1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '李审核', 1),
('user1', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '王用户', 1);

INSERT IGNORE INTO sys_user_role (user_id, role_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4);

INSERT IGNORE INTO advisor_strategy_rule (strategy_code, product_type, min_fund_count, max_fund_count, min_single_weight, max_single_weight, allow_fund_types, risk_rule_mode) VALUES
('GROWTH', 'STRATEGY', 3, 20, 0.0000, 0.3000, '股票型,混合型', 'WEIGHT_LIMIT'),
('BALANCED', 'STRATEGY', 3, 15, 0.0000, 0.2500, '股票型,债券型,混合型', 'WEIGHT_LIMIT'),
('FOF_BASIC', 'FOF', 3, 10, 0.0000, 0.5000, '股票型,债券型,混合型,货币型', 'WEIGHT_LIMIT');

INSERT IGNORE INTO fund_info (fund_code, fund_name, fund_type, risk_level, company_name, status) VALUES
('000001', '华夏成长混合', '混合型', 'R3', '华夏基金', 1),
('000011', '华夏大盘精选', '混合型', 'R4', '华夏基金', 1),
('002001', '华夏回报混合', '混合型', 'R3', '华夏基金', 1),
('110011', '易方达中小盘混合', '混合型', 'R4', '易方达基金', 1),
('005827', '易方达蓝筹精选', '混合型', 'R4', '易方达基金', 1),
('260108', '景顺长城新兴成长', '混合型', 'R4', '景顺长城基金', 1),
('161725', '招商中证白酒', '股票型', 'R5', '招商基金', 1),
('003834', '华夏能源革新', '股票型', 'R5', '华夏基金', 1),
('001938', '中欧时代先锋', '股票型', 'R4', '中欧基金', 1),
('110022', '易方达消费行业', '股票型', 'R4', '易方达基金', 1);
