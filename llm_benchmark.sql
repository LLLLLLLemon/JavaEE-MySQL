/*
 Navicat Premium Data Transfer

 Source Server         : MySQL_1
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:3306
 Source Schema         : llm_benchmark

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 28/05/2026 19:43:51
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for creators
-- ----------------------------
DROP TABLE IF EXISTS `creators`;
CREATE TABLE `creators`  (
  `creator_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '厂商ID，极简可读（如 oai, ant, goog）',
  `creator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '厂商全称',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '厂商简介（技术背景与行业地位）',
  PRIMARY KEY (`creator_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '大模型厂商/组织表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of creators
-- ----------------------------
INSERT INTO `creators` VALUES ('ali', 'Alibaba', '阿里巴巴集团旗下的达摩院和通义实验室，推出Qwen（通义千问）系列，覆盖多语言和多模态。');
INSERT INTO `creators` VALUES ('amaz', 'Amazon', '亚马逊，Nova系列模型（前身为Amazon Titan），集成于AWS Bedrock平台。');
INSERT INTO `creators` VALUES ('ant', 'Anthropic', '由前OpenAI成员创立，专注于AI安全与可控性，代表模型为Claude系列，强调宪法AI原则。');
INSERT INTO `creators` VALUES ('cmcc', 'China Mobile', '中国移动，九天（JT）系列大模型，面向运营商和行业应用。');
INSERT INTO `creators` VALUES ('cohe', 'Cohere', '加拿大AI公司，专注于企业级NLP服务，Command系列模型强调高效与可定制。');
INSERT INTO `creators` VALUES ('deep', 'DeepSeek', '深度求索（DeepSeek）公司，以高性价比和开源模型著称，DeepSeek-V4系列在多项基准中表现优异。');
INSERT INTO `creators` VALUES ('goog', 'Google', '科技巨头，深耕AI领域多年，拥有Gemini（原Bard）、PaLM等模型，整合搜索与全生态能力。');
INSERT INTO `creators` VALUES ('incl', 'InclusionAI', '启元（InclusionAI），专注于千亿参数大模型，Ring/Ling系列强调超长上下文理解。');
INSERT INTO `creators` VALUES ('kimi', 'Kimi', '北京月之暗面科技有限公司，主打超长上下文（Kimi K2系列），擅长处理海量文本。');
INSERT INTO `creators` VALUES ('meta', 'Meta', '社交媒体巨头，开源大模型的推动者，Llama系列和Muse系列在学术界和工业界影响深远。');
INSERT INTO `creators` VALUES ('mist', 'Mistral', '法国AI初创公司，以高性能开源模型（Mistral 7B/8x7B）闻名，注重边缘部署。');
INSERT INTO `creators` VALUES ('mmax', 'MiniMax', '国内AI独角兽，开发MiniMax系列模型，提供高效的文本生成与对话能力。');
INSERT INTO `creators` VALUES ('nvda', 'NVIDIA', 'GPU与AI计算领导者，Nemotron系列模型为NVIDIA自研，面向企业级生成式AI。');
INSERT INTO `creators` VALUES ('oai', 'OpenAI', '全球领先的人工智能研究机构，开发了GPT系列、DALL·E等模型，致力于通用人工智能（AGI）的探索。');
INSERT INTO `creators` VALUES ('step', 'StepFun', '阶跃星辰（StepFun），国内新锐AI公司，Step系列模型在多模态和长文本上探索。');
INSERT INTO `creators` VALUES ('ten', 'Tencent', '腾讯，混元大模型（Hy系列）的研发者，覆盖社交、游戏、企业服务等多场景。');
INSERT INTO `creators` VALUES ('xai', 'xAI', '埃隆·马斯克创立的人工智能公司，Grok模型以实时知识、幽默风格和X平台整合为特色。');
INSERT INTO `creators` VALUES ('xiao', 'Xiaomi', '小米集团，AI实验室研发MiMo系列模型，注重端侧与云端协同。');
INSERT INTO `creators` VALUES ('zai', 'Z AI', '智谱华章（Zhipu AI），清华大学技术团队孵化，GLM系列模型擅长中文理解和复杂推理。');

-- ----------------------------
-- Table structure for model_metrics
-- ----------------------------
DROP TABLE IF EXISTS `model_metrics`;
CREATE TABLE `model_metrics`  (
  `model_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型ID（关联models表）',
  `artif_intel_idx` decimal(5, 2) NULL DEFAULT NULL COMMENT 'Artificial Analysis Intelligence Index',
  `artif_omni_idx` decimal(5, 2) NULL DEFAULT NULL COMMENT 'Artificial Analysis Omniscience Index',
  `terminal_bench_hard` decimal(5, 2) NULL DEFAULT NULL COMMENT 'Terminal-Bench Hard（百分比数值，如61代表61%）',
  `aa_omni_accuracy` decimal(5, 2) NULL DEFAULT NULL COMMENT 'AA-Omniscience Accuracy（百分比数值）',
  `blended_price` decimal(8, 4) NULL DEFAULT NULL COMMENT 'Blended (USD/1M Tokens)',
  `median_tokens_s` decimal(8, 2) NULL DEFAULT NULL COMMENT 'Median Tokens per second',
  `latency_first_chunk` decimal(8, 2) NULL DEFAULT NULL COMMENT 'Latency of first chunk (seconds)',
  `total_response_time` decimal(8, 2) NULL DEFAULT NULL COMMENT 'Total response time (seconds)',
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_metrics_intel`(`artif_intel_idx` ASC) USING BTREE,
  INDEX `idx_metrics_price`(`blended_price` ASC) USING BTREE,
  CONSTRAINT `model_metrics_ibfk_1` FOREIGN KEY (`model_id`) REFERENCES `models` (`model_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '模型数值指标表（宽表，每个模型一行）' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of model_metrics
-- ----------------------------
INSERT INTO `model_metrics` VALUES ('cl45hk', 37.00, -4.00, 27.00, 17.00, 0.8200, 132.00, 17.18, 20.96);
INSERT INTO `model_metrics` VALUES ('cl46mx', 52.00, 12.00, 53.00, 40.00, 2.4600, 63.00, 142.37, 150.34);
INSERT INTO `model_metrics` VALUES ('cl46nr', 44.00, -3.00, 46.00, 38.00, 2.4600, 49.00, 1.27, 11.42);
INSERT INTO `model_metrics` VALUES ('cl46nrl', 43.00, -2.00, 42.00, 36.00, 2.4600, 49.00, 1.49, 11.80);
INSERT INTO `model_metrics` VALUES ('cl47mx', 57.00, 26.00, 52.00, 46.00, 4.1000, 57.00, 19.14, 27.97);
INSERT INTO `model_metrics` VALUES ('cl47nr', 52.00, 14.00, 55.00, 44.00, 4.1000, 51.00, 1.88, 11.67);
INSERT INTO `model_metrics` VALUES ('cmdap', 37.00, -4.00, 25.00, 9.00, 0.0000, 209.00, 0.26, 12.23);
INSERT INTO `model_metrics` VALUES ('dsv4fh', 46.00, -22.00, 39.00, 36.00, 0.0800, NULL, NULL, NULL);
INSERT INTO `model_metrics` VALUES ('dsv4fl', 36.00, -44.00, 34.00, 26.00, 0.0600, 135.00, 1.17, 4.88);
INSERT INTO `model_metrics` VALUES ('dsv4fm', 47.00, -23.00, 36.00, 36.00, 0.0600, 135.00, 1.21, 46.45);
INSERT INTO `model_metrics` VALUES ('dsv4ph', 50.00, -19.00, 35.00, 37.00, 0.1800, 55.00, 1.96, 47.21);
INSERT INTO `model_metrics` VALUES ('dsv4pm', 52.00, -10.00, 46.00, 43.00, 0.1800, 54.00, 1.86, 92.96);
INSERT INTO `model_metrics` VALUES ('dsv4pr', 39.00, -30.00, 36.00, 31.00, 0.1800, 55.00, 1.92, 11.07);
INSERT INTO `model_metrics` VALUES ('gem25p', 35.00, -14.00, 27.00, 39.00, 1.3400, 146.00, 18.97, 22.38);
INSERT INTO `model_metrics` VALUES ('gem31p', 57.00, 33.00, 54.00, 55.00, 1.7400, 144.00, 28.52, 31.99);
INSERT INTO `model_metrics` VALUES ('gem35f', 55.00, 23.00, 41.00, 52.00, 1.3100, 208.00, 14.90, 17.31);
INSERT INTO `model_metrics` VALUES ('gem35fm', 43.00, 1.00, 46.00, 43.00, 1.3100, 201.00, 0.92, 3.41);
INSERT INTO `model_metrics` VALUES ('gemma4', 39.00, -45.00, 36.00, 20.00, 0.0000, 35.00, 1.09, 72.39);
INSERT INTO `model_metrics` VALUES ('glm51', 51.00, 2.00, 43.00, 24.00, 0.9000, 61.00, 1.58, 71.89);
INSERT INTO `model_metrics` VALUES ('glm5t', 47.00, -15.00, 33.00, 29.00, NULL, NULL, NULL, NULL);
INSERT INTO `model_metrics` VALUES ('glm5vt', 43.00, -19.00, 33.00, 29.00, NULL, NULL, NULL, NULL);
INSERT INTO `model_metrics` VALUES ('gpt53cx', 54.00, 10.00, 53.00, 52.00, 1.8700, 84.00, 74.69, 80.64);
INSERT INTO `model_metrics` VALUES ('gpt54md', 38.00, -20.00, 34.00, 37.00, 0.6500, 173.00, 5.32, 8.21);
INSERT INTO `model_metrics` VALUES ('gpt54na', 44.00, -19.00, 33.00, 21.00, 0.1800, 158.00, 5.10, 8.28);
INSERT INTO `model_metrics` VALUES ('gpt54nan', 38.00, -19.00, 33.00, 21.00, 0.1800, 152.00, 4.88, 8.17);
INSERT INTO `model_metrics` VALUES ('gpt54xh', 49.00, -19.00, 52.00, 37.00, 0.6500, 173.00, 3.99, 6.88);
INSERT INTO `model_metrics` VALUES ('gpt55hi', 59.00, 18.00, 60.00, 56.00, 4.3500, 77.00, 20.52, 27.03);
INSERT INTO `model_metrics` VALUES ('gpt55lo', 51.00, 15.00, 52.00, 54.00, 4.3500, 77.00, 1.91, 8.36);
INSERT INTO `model_metrics` VALUES ('gpt55md', 57.00, 17.00, 58.00, 56.00, 4.3500, 69.00, 5.82, 13.06);
INSERT INTO `model_metrics` VALUES ('gpt55nr', 41.00, -5.00, 49.00, 45.00, 4.3500, 74.00, 1.04, 7.83);
INSERT INTO `model_metrics` VALUES ('gpt55xh', 60.00, 20.00, 61.00, 57.00, 4.3500, 71.00, 32.54, 39.60);
INSERT INTO `model_metrics` VALUES ('grok43h', 53.00, 18.00, 38.00, 35.00, 0.6400, 172.00, 19.69, 22.59);
INSERT INTO `model_metrics` VALUES ('grok43l', 44.00, 14.00, 27.00, 26.00, 0.6400, 160.00, 3.31, 6.43);
INSERT INTO `model_metrics` VALUES ('grok43m', 49.00, 17.00, 30.00, 28.00, 0.6400, 172.00, 6.66, 9.56);
INSERT INTO `model_metrics` VALUES ('hy3pr', 42.00, -36.00, 32.00, 22.00, 0.1000, 96.00, 3.95, 29.86);
INSERT INTO `model_metrics` VALUES ('hy3pr2', 34.00, -36.00, 32.00, 22.00, 0.1000, 84.00, 4.06, 9.98);
INSERT INTO `model_metrics` VALUES ('jt35f', NULL, -23.00, 29.00, 25.00, NULL, NULL, NULL, NULL);
INSERT INTO `model_metrics` VALUES ('kimi26a', 54.00, 6.00, 44.00, 33.00, 0.7000, 37.00, 2.55, 136.43);
INSERT INTO `model_metrics` VALUES ('kimi26b', 43.00, -10.00, 38.00, 23.00, 0.7000, 38.00, 2.47, 15.56);
INSERT INTO `model_metrics` VALUES ('ling26', 34.00, -51.00, 31.00, 21.00, 0.5200, NULL, NULL, NULL);
INSERT INTO `model_metrics` VALUES ('mimo25', 49.00, -9.00, 42.00, 17.00, 0.1600, 97.00, 3.20, 29.04);
INSERT INTO `model_metrics` VALUES ('mimo25p', 54.00, 4.00, 43.00, 23.00, 0.5800, 53.00, 3.76, 50.99);
INSERT INTO `model_metrics` VALUES ('mimo25p2', 36.00, -38.00, 36.00, 27.00, 0.5800, 57.00, 3.29, 12.08);
INSERT INTO `model_metrics` VALUES ('mimo2fl', 41.00, -18.00, 31.00, 20.00, 0.0600, 137.00, 2.45, 20.71);
INSERT INTO `model_metrics` VALUES ('mimo2om', 45.00, -14.00, 36.00, 18.00, 0.3400, 112.00, 2.26, 24.51);
INSERT INTO `model_metrics` VALUES ('mimo2om2', 43.00, -17.00, 35.00, 19.00, 0.0000, 110.00, 2.34, 25.12);
INSERT INTO `model_metrics` VALUES ('mistm35', 39.00, -36.00, 33.00, 25.00, 2.1000, 152.00, 1.52, 17.93);
INSERT INTO `model_metrics` VALUES ('mm27', 50.00, 1.00, 39.00, 26.00, 0.2200, 60.00, 1.97, 51.33);
INSERT INTO `model_metrics` VALUES ('musespk', NULL, 4.00, 45.00, 45.00, NULL, NULL, NULL, NULL);
INSERT INTO `model_metrics` VALUES ('nova2lh', 35.00, -54.00, 17.00, 19.00, 0.5200, 157.00, 19.04, 34.92);
INSERT INTO `model_metrics` VALUES ('nova2pp', 36.00, -48.00, 24.00, 22.00, 1.4700, 131.00, 13.74, 32.76);
INSERT INTO `model_metrics` VALUES ('nvn3s', 36.00, -42.00, 29.00, 24.00, 0.2800, 152.00, 1.52, 17.98);
INSERT INTO `model_metrics` VALUES ('o3', 38.00, -15.00, 37.00, 38.00, 1.5500, 127.00, 7.51, 11.46);
INSERT INTO `model_metrics` VALUES ('qw35122a', 42.00, -54.00, 30.00, 19.00, 0.6800, 145.00, 2.38, 19.60);
INSERT INTO `model_metrics` VALUES ('qw35397a', 45.00, -30.00, 41.00, 31.00, 0.9000, 52.00, 2.61, 74.09);
INSERT INTO `model_metrics` VALUES ('qw35397b', 40.00, -36.00, 36.00, 24.00, 0.9000, 53.00, 2.52, 12.03);
INSERT INTO `model_metrics` VALUES ('qw35omp', 39.00, -12.00, 21.00, 17.00, 0.8400, 55.00, 2.39, 11.54);
INSERT INTO `model_metrics` VALUES ('qw3627b', 46.00, -53.00, 21.00, 17.00, 0.9000, 61.00, 3.89, 44.68);
INSERT INTO `model_metrics` VALUES ('qw3627b2', 37.00, -53.00, 21.00, 17.00, 0.9000, 65.00, 3.88, 11.60);
INSERT INTO `model_metrics` VALUES ('qw3635a', 43.00, -21.00, 35.00, 19.00, 0.3700, 183.00, 2.47, 16.14);
INSERT INTO `model_metrics` VALUES ('qw36pl', 50.00, 3.00, 44.00, 26.00, 0.4300, 52.00, 3.42, 120.26);
INSERT INTO `model_metrics` VALUES ('qw37mx', 57.00, 14.00, 51.00, 30.00, 1.4300, 210.00, 2.53, 16.37);
INSERT INTO `model_metrics` VALUES ('ring26', 38.00, -38.00, 29.00, 25.00, 0.5200, 127.00, 3.25, 22.91);
INSERT INTO `model_metrics` VALUES ('st35f', 38.00, -44.00, 33.00, 25.00, 0.0000, 191.00, 1.10, 14.15);

-- ----------------------------
-- Table structure for models
-- ----------------------------
DROP TABLE IF EXISTS `models`;
CREATE TABLE `models`  (
  `model_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型ID，极简可读（如 gpt55xh, cl47mx）',
  `model_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模型完整名称',
  `creator_id` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '所属厂商ID',
  `context_window` int NULL DEFAULT NULL COMMENT '上下文长度（单位：token）',
  `is_open_source` tinyint(1) NULL DEFAULT 0 COMMENT '是否开源（TRUE=开源, FALSE=闭源）',
  `release_date` date NULL DEFAULT NULL COMMENT '模型发布日期（格式 YYYY-MM-DD）',
  `field_expertise` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '擅长领域（如代码、推理、多语言等）',
  `version_upgrade_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '同版本不同配置的升级/对比说明',
  PRIMARY KEY (`model_id`) USING BTREE,
  INDEX `idx_models_creator`(`creator_id` ASC) USING BTREE,
  INDEX `idx_models_release_date`(`release_date` ASC) USING BTREE,
  INDEX `idx_models_open_source`(`is_open_source` ASC) USING BTREE,
  CONSTRAINT `models_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `creators` (`creator_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '大模型基础信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of models
-- ----------------------------
INSERT INTO `models` VALUES ('cl45hk', 'Claude 4.5 Haiku', 'ant', 200000, 0, '2025-10-15', '极速小模型，边缘场景', 'Haiku系列以低延迟著称。');
INSERT INTO `models` VALUES ('cl46mx', 'Claude Sonnet 4.6 (max)', 'ant', 1000000, 0, '2025-08-10', '平衡性能与经济性', 'Sonnet系列最大配置。');
INSERT INTO `models` VALUES ('cl46nr', 'Claude Sonnet 4.6 (Non-reasoning)', 'ant', 1000000, 0, '2025-08-10', '聊天、摘要', '非推理版本，速度提升。');
INSERT INTO `models` VALUES ('cl46nrl', 'Claude Sonnet 4.6 (Non-reasoning, Low Effort)', 'ant', 1000000, 0, '2025-08-10', '极速响应', '低努力模式，进一步降低延迟。');
INSERT INTO `models` VALUES ('cl47mx', 'Claude Opus 4.7 (max)', 'ant', 1000000, 0, '2026-04-16', '高难度推理、安全合规', 'max配置：最强能力，耗时长。');
INSERT INTO `models` VALUES ('cl47nr', 'Claude Opus 4.7 (Non-reasoning, high)', 'ant', 1000000, 0, '2026-04-16', '快速响应、安全对话', '去推理模式，高速版。');
INSERT INTO `models` VALUES ('cmdap', 'Command A+', 'cohe', 192000, 1, '2026-05-20', '企业RAG，工具调用', '2180亿MoE，Apache 2.0开源。');
INSERT INTO `models` VALUES ('dsv4fh', 'DeepSeek V4 Flash (High)', 'deep', 1000000, 1, '2026-04-24', '高速版', 'Flash High。');
INSERT INTO `models` VALUES ('dsv4fl', 'DeepSeek V4 Flash', 'deep', 1000000, 1, '2026-04-24', '默认Flash', '速度优先。');
INSERT INTO `models` VALUES ('dsv4fm', 'DeepSeek V4 Flash (Max)', 'deep', 1000000, 1, '2026-04-24', '极速版，最大配置', 'Flash Max。');
INSERT INTO `models` VALUES ('dsv4ph', 'DeepSeek V4 Pro (High)', 'deep', 1000000, 1, '2026-04-24', '高吞吐推理', 'High模式。');
INSERT INTO `models` VALUES ('dsv4pm', 'DeepSeek V4 Pro (Max)', 'deep', 1000000, 1, '2026-04-24', '极致性价比，代码能力强', 'Max模式，质量最高。');
INSERT INTO `models` VALUES ('dsv4pr', 'DeepSeek V4 Pro', 'deep', 1000000, 1, '2026-04-24', '标准Pro', '默认配置。');
INSERT INTO `models` VALUES ('gem25p', 'Gemini 2.5 Pro', 'goog', 1000000, 0, '2024-12-01', '稳定版Pro，多语言', '2.5代旗舰。');
INSERT INTO `models` VALUES ('gem31p', 'Gemini 3.1 Pro Preview', 'goog', 1000000, 0, '2026-02-19', '多模态、长上下文推理', 'Pro预览版，性能强劲。');
INSERT INTO `models` VALUES ('gem35f', 'Gemini 3.5 Flash', 'goog', 1000000, 0, '2026-05-19', '高速通用任务', 'Flash系列优化吞吐量。');
INSERT INTO `models` VALUES ('gem35fm', 'Gemini 3.5 Flash (minimal)', 'goog', 1000000, 0, '2026-05-19', '极简模式，最低延迟', '最小配置，速度优先。');
INSERT INTO `models` VALUES ('gemma4', 'Gemma 4 31B', 'goog', 256000, 1, '2026-04-03', '开源轻量，学术友好', '31B开源模型，Apache 2.0可商用。');
INSERT INTO `models` VALUES ('glm51', 'GLM-5.1', 'zai', 200000, 1, '2026-04-08', '中文任务、逻辑推理', '5.1版本，开源。');
INSERT INTO `models` VALUES ('glm5t', 'GLM-5-Turbo', 'zai', 200000, 0, '2026-03-16', 'Turbo加速版', '更高速度，面向OpenClaw场景，闭源。');
INSERT INTO `models` VALUES ('glm5vt', 'GLM 5V Turbo', 'zai', 200000, 0, '2026-05-22', '多模态Turbo', '支持视觉，高速版API。');
INSERT INTO `models` VALUES ('gpt53cx', 'GPT-5.3 Codex (xhigh)', 'oai', 400000, 0, '2026-02-05', '代码特化，高推理', 'Codex xhigh，编程优化。');
INSERT INTO `models` VALUES ('gpt54md', 'GPT-5.4 mini (medium)', 'oai', 400000, 0, '2026-03-17', 'mini中配', 'medium平衡。');
INSERT INTO `models` VALUES ('gpt54na', 'GPT-5.4 nano (xhigh)', 'oai', 400000, 0, '2026-03-17', 'nano xhigh', '极小参数量，高效能。');
INSERT INTO `models` VALUES ('gpt54nan', 'GPT-5.4 nano', 'oai', 400000, 0, '2026-03-17', 'nano标准', '默认配置。');
INSERT INTO `models` VALUES ('gpt54xh', 'GPT-5.4 mini (xhigh)', 'oai', 400000, 0, '2026-03-17', 'mini系列高配', 'xhigh小型化，高效推理。');
INSERT INTO `models` VALUES ('gpt55hi', 'GPT-5.5 (high)', 'oai', 922000, 0, '2026-04-23', '通用推理、代码生成', 'high配置：平衡质量与速度，默认推荐。');
INSERT INTO `models` VALUES ('gpt55lo', 'GPT-5.5 (low)', 'oai', 922000, 0, '2026-04-23', '简单任务、高吞吐场景', 'low配置：极致速度，质量略降。');
INSERT INTO `models` VALUES ('gpt55md', 'GPT-5.5 (medium)', 'oai', 922000, 0, '2026-04-23', '日常对话、快速响应', 'medium配置：轻量推理，适合高频调用。');
INSERT INTO `models` VALUES ('gpt55nr', 'GPT-5.5 (Non-reasoning)', 'oai', 922000, 0, '2026-04-23', '快速回复、基础对话', '去除了复杂推理链，延迟更低。');
INSERT INTO `models` VALUES ('gpt55xh', 'GPT-5.5 (xhigh)', 'oai', 922000, 0, '2026-04-23', '通用推理、代码生成、长文本分析', 'xhigh配置：最高推理深度，延迟较高，适合复杂任务。');
INSERT INTO `models` VALUES ('grok43h', 'Grok 4.3 (high)', 'xai', 1000000, 0, '2026-04-17', '实时知识、幽默风格', '高配置，Beta版上线。');
INSERT INTO `models` VALUES ('grok43l', 'Grok 4.3 (low)', 'xai', 1000000, 0, '2026-04-17', '快速响应', '低配置。');
INSERT INTO `models` VALUES ('grok43m', 'Grok 4.3 (medium)', 'xai', 1000000, 0, '2026-04-17', '平衡', '中配置。');
INSERT INTO `models` VALUES ('hy3pr', 'Hy3-preview', 'ten', 256000, 0, '2025-10-20', '混元第三代预览', '腾讯混元。');
INSERT INTO `models` VALUES ('hy3pr2', 'Hy3-preview (v2)', 'ten', 256000, 0, '2025-11-01', '混元更新预览版', '指标更新。');
INSERT INTO `models` VALUES ('jt35f', 'JT-35B-Flash', 'cmcc', 256000, 0, '2025-08-01', '运营商场景优化', '35B Flash。');
INSERT INTO `models` VALUES ('kimi26a', 'Kimi K2.6', 'kimi', 256000, 1, '2026-04-20', '超长文档理解、多Agent协同', '1万亿参数MoE，原生多模态，MIT协议开源。');
INSERT INTO `models` VALUES ('kimi26b', 'Kimi K2.6 (v2)', 'kimi', 256000, 1, '2026-04-20', '改进版长上下文', '同上系列，增强稳定性。');
INSERT INTO `models` VALUES ('ling26', 'Ling-2.6-1T', 'incl', 262000, 1, '2025-12-15', 'Ling超长文本', '对称架构，MIT开源。');
INSERT INTO `models` VALUES ('mimo25', 'MiMo-V2.5', 'xiao', 1000000, 0, '2026-04-23', '通用模型', '标准版。');
INSERT INTO `models` VALUES ('mimo25p', 'MiMo-V2.5-Pro', 'xiao', 1000000, 0, '2026-04-23', '专业级推理', 'Pro版本，性能旗舰。');
INSERT INTO `models` VALUES ('mimo25p2', 'MiMo-V2.5-Pro (v2)', 'xiao', 1000000, 0, '2026-04-23', '升级版Pro', '公测期间的指标更新版。');
INSERT INTO `models` VALUES ('mimo2fl', 'MiMo-V2-Flash (Feb 2026)', 'xiao', 256000, 0, '2026-02-01', '极速Flash', '低延迟版。');
INSERT INTO `models` VALUES ('mimo2om', 'MiMo-V2-Omni-0327', 'xiao', 256000, 0, '2026-03-27', '全模态（Omni）', '支持图文输入。');
INSERT INTO `models` VALUES ('mimo2om2', 'MiMo-V2-Omni (free)', 'xiao', 256000, 0, '2026-04-15', '免费版Omni', '零成本调用。');
INSERT INTO `models` VALUES ('mistm35', 'Mistral Medium 3.5', 'mist', 256000, 1, '2026-04-29', '中型开源风格', '128B参数，开放权重。');
INSERT INTO `models` VALUES ('mm27', 'MiniMax-M2.7', 'mmax', 205000, 0, '2026-03-18', '对话生成、角色扮演', 'M2.7版本，首次实现模型自我进化。');
INSERT INTO `models` VALUES ('musespk', 'Muse Spark', 'meta', 262000, 0, '2026-04-08', '创意生成、艺术辅助', '闭源专有模型，接入Meta全线产品。');
INSERT INTO `models` VALUES ('nova2lh', 'Nova 2.0 Lite (high)', 'amaz', 1000000, 0, '2025-12-02', '轻量级高配', 'Lite high。');
INSERT INTO `models` VALUES ('nova2pp', 'Nova 2.0 Pro Preview (medium)', 'amaz', 256000, 0, '2025-12-02', 'AWS集成，中等配置', 'Pro预览版。');
INSERT INTO `models` VALUES ('nvn3s', 'NVIDIA Nemotron 3 Super', 'nvda', 1000000, 1, '2026-03-11', '企业生成式AI', 'Super版本，120B参数，开源权重。');
INSERT INTO `models` VALUES ('o3', 'o3', 'oai', 200000, 0, '2025-03-20', '推理增强版', 'o系列推理模型，专注逻辑与数学。');
INSERT INTO `models` VALUES ('qw35122a', 'Qwen3.5 122B A10B', 'ali', 262000, 0, '2025-02-15', '中等规模MoE', '122B总参数，激活10B。');
INSERT INTO `models` VALUES ('qw35397a', 'Qwen3.5 397B A17B', 'ali', 262000, 0, '2025-03-10', '超大规模MoE，高精度', '397B总参数，激活17B。');
INSERT INTO `models` VALUES ('qw35397b', 'Qwen3.5 397B A17B (v2)', 'ali', 262000, 0, '2025-04-01', '升级版MoE', '指标略有差异的第二版。');
INSERT INTO `models` VALUES ('qw35omp', 'Qwen3.5 Omni Plus', 'ali', 256000, 0, '2025-05-20', '多模态增强', 'Omni系列支持图像输入。');
INSERT INTO `models` VALUES ('qw3627b', 'Qwen3.6 27B', 'ali', 262000, 1, '2025-07-15', '开源模型，轻量部署', '27B参数，可商用。');
INSERT INTO `models` VALUES ('qw3627b2', 'Qwen3.6 27B (v2)', 'ali', 262000, 1, '2025-08-01', '开源版本更新', '第二个发布版，速度提升。');
INSERT INTO `models` VALUES ('qw3635a', 'Qwen3.6 35B A3B', 'ali', 262000, 0, '2025-09-01', '高效MoE，低延迟', '35B总参，激活3B。');
INSERT INTO `models` VALUES ('qw36pl', 'Qwen3.6 Plus', 'ali', 1000000, 0, '2025-08-20', '长文本、Plus增强', 'Plus优化推理速度。');
INSERT INTO `models` VALUES ('qw37mx', 'Qwen3.7 Max', 'ali', 1000000, 0, '2026-05-20', '最强中文理解，数学', 'Max版本，综合性能最佳。');
INSERT INTO `models` VALUES ('ring26', 'Ring-2.6-1T', 'incl', 262000, 1, '2026-05-08', '超长上下文1T参数', 'Ring系列，MIT开源。');
INSERT INTO `models` VALUES ('st35f', 'Step 3.5 Flash 2603', 'step', 256000, 0, '2026-04-02', '多模态Flash', '2603版本，新增low think mode。');

SET FOREIGN_KEY_CHECKS = 1;
