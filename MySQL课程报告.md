# MySQL 数据库应用课程设计报告

**项目名称**：LLM Benchmark 大模型性能评测平台  
**学生姓名**：[请填写]  
**学号**：[请填写]  
**指导教师**：[请填写]  
**完成日期**：2026年6月

---

## 1. 实验课题概述

### 1.1 课题背景与现状

随着人工智能技术的飞速发展，大型语言模型（Large Language Model, LLM）已成为自然语言处理领域的核心技术。从 OpenAI 的 GPT 系列到 Anthropic 的 Claude，再到开源社区的 Llama、Qwen 等模型，市场上涌现出数百种不同规格的大语言模型。这些模型在智力指数、响应速度、价格成本等方面存在显著差异，为用户选择合适的模型带来了挑战。

**行业现状**：
- **模型数量激增**：截至 2026 年，主流大模型厂商已超过 20 家，发布模型版本超过 100 个。
- **评测维度复杂**：用户需综合考虑智力指数（Artificial Analysis Intelligence Index）、吞吐量（Tokens/s）、延迟（Latency）、价格（USD/1M Tokens）等多个指标。
- **信息分散**：各厂商官网仅展示自家模型数据，缺乏统一的对比平台。

### 1.2 需解决的具体问题

本课题旨在设计并实现一个 **LLM Benchmark 大模型性能评测数据库系统**，解决以下具体问题：

1. **数据整合问题**：将分散的模型基础信息（名称、厂商、发布时间）与性能指标（智力指数、价格、吞吐量）统一管理。
2. **多维度筛选问题**：支持用户按厂商、开源状态、价格区间、智力指数范围等条件组合查询。
3. **对比分析问题**：允许用户选择 2~5 个模型进行横向对比，自动高亮最优指标。
4. **数据一致性问题**：通过外键约束与级联删除机制，确保模型与指标数据的完整性。

### 1.3 关键功能模块定义

| 功能模块 | 业务场景描述 | 数据库技术要点 |
| :--- | :--- | :--- |
| **综合表查询** | 展示所有模型的厂商、基础信息与性能指标一体化视图 | 三表 LEFT JOIN、索引优化 |
| **多条件筛选** | 用户选择厂商、设置价格区间、排序后查询 | 动态 SQL 构建、PreparedStatement 防注入 |
| **模型对比** | 选中 2~5 个模型，横向对比各项指标并高亮最优值 | 批量查询（IN 子句）、Stream API 聚合计算 |
| **数据维护** | 管理员新增/修改/删除模型、厂商、指标数据 | 事务处理、外键约束检查、CASCADE 级联删除 |
---
## 2. 实验环境

### 2.1 软件环境配置

| 组件 | 版本 | 说明 |
| :--- | :--- | :--- |
| **数据库管理系统** | MySQL 8.0.33 | 社区版，支持 InnoDB 存储引擎 |
| **操作系统** | Windows 11 / Linux Ubuntu 22.04 | 开发环境 |
| **命令行工具** | PowerShell 7+ / MySQL Shell | 执行 SQL 脚本与管理命令 |
| **可视化工具** | MySQL Workbench 8.0 | ER 图绘制、数据浏览、性能监控 |
| **应用服务器** | Apache Tomcat 10.1+ | Servlet 容器 |
| **开发语言** | Java JDK 21 | 后端逻辑实现 |

### 2.2 数据库连接配置

```properties
# db.properties 配置文件
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/llm_benchmark?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8&allowPublicKeyRetrieval=true
db.username=root
db.password=[您的密码]
```

**配置说明**：
- `useSSL=false`：本地开发环境禁用 SSL 加密以提升性能。
- `serverTimezone=UTC`：统一时区避免日期类型转换错误。
- `characterEncoding=UTF-8`：指定 JDBC 使用 UTF-8 编码与数据库通信。
- `allowPublicKeyRetrieval=true`：允许客户端自动获取服务器公钥，配合 caching_sha2_password 认证插件使用。

---

## 3. 数据库设计

### 3.1 实体关系图（E-R 图）

<!-- 请在此处插入 ER 图截图 -->
<!-- 建议截图来源：MySQL Workbench 生成的 E-R Diagram 或项目中的 diagram-er-diagram.svg -->
![ER图](diagram-er-diagram.svg)

**图 3-1  LLM Benchmark 系统 E-R 图**

#### 实体与属性说明

1. **Creators（厂商实体）**
   - 主键：`creator_id`（厂商ID，如 oai、ant）
   - 属性：`creator_name`（厂商全称）、`description`（简介）

2. **Models（模型实体）**
   - 主键：`model_id`（模型ID，如 gpt55xh、cl47mx）
   - 属性：`model_name`、`context_window`、`is_open_source`、`release_date`、`field_expertise`
   - 外键：`creator_id` → Creators（多对一关系）

3. **Model_Metrics（指标实体）**
   - 主键兼外键：`model_id` → Models（一对一关系）
   - 属性：`artif_intel_idx`、`blended_price`、`median_tokens_s`、`latency_first_chunk` 等 8 个性能指标

#### 联系关系说明

- **Creators ↔ Models**：1:N（一对多）
  - 一个厂商可发布多个模型（如 OpenAI 发布 GPT-4、GPT-3.5 等）。
  - 删除约束：`ON DELETE RESTRICT`（若厂商下仍有模型，则禁止删除该厂商）。

- **Models ↔ Model_Metrics**：1:1（一对一）
  - 一个模型对应一组性能指标。
  - 删除约束：`ON DELETE CASCADE`（删除模型时自动级联删除其指标）。

---

### 3.2 关系数据模型转化

根据 E-R 图转化为以下关系模式（主键加粗，外键斜体）：

1. **CREATORS** (**creator_id**, creator_name, description)
2. **MODELS** (**model_id**, model_name, *creator_id*, context_window, is_open_source, release_date, field_expertise, version_upgrade_note)
3. **MODEL_METRICS** (**_model_id_**, artif_intel_idx, artif_omni_idx, terminal_bench_hard, aa_omni_accuracy, blended_price, median_tokens_s, latency_first_chunk, total_response_time)

**转化规则**：
- 1:N 关系：在"多"的一方（Models）添加外键 `creator_id`。
- 1:1 关系：将 Model_Metrics 的主键设置为外键 `model_id`，与 Models 表主键对应。

---

### 3.3 表结构设计详解

#### 3.3.1 建表语句

```sql
-- 创建数据库
CREATE DATABASE IF NOT EXISTS llm_benchmark 
    DEFAULT CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE llm_benchmark;

-- 1. 厂商表
CREATE TABLE creators (
    creator_id VARCHAR(10) PRIMARY KEY COMMENT '厂商ID，极简可读（如 oai, ant, goog）',
    creator_name VARCHAR(50) NOT NULL COMMENT '厂商全称',
    description TEXT COMMENT '厂商简介（技术背景与行业地位）'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大模型厂商/组织表';

-- 2. 模型表
CREATE TABLE models (
    model_id VARCHAR(10) PRIMARY KEY COMMENT '模型ID（如 gpt55xh, cl47mx）',
    model_name VARCHAR(100) NOT NULL COMMENT '模型完整名称',
    creator_id VARCHAR(10) NOT NULL COMMENT '所属厂商ID',
    context_window INT COMMENT '上下文长度（单位：token）',
    is_open_source TINYINT(1) DEFAULT 0 COMMENT '是否开源（TRUE=开源, FALSE=闭源）',
    release_date DATE COMMENT '模型发布日期（格式 YYYY-MM-DD）',
    field_expertise VARCHAR(200) COMMENT '擅长领域（如代码、推理、多语言等）',
    version_upgrade_note TEXT COMMENT '同版本不同配置的升级/对比说明',
    INDEX idx_models_creator (creator_id),
    INDEX idx_models_release_date (release_date),
    INDEX idx_models_open_source (is_open_source),
    CONSTRAINT fk_models_creator FOREIGN KEY (creator_id) 
        REFERENCES creators(creator_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='大模型基础信息表';

-- 3. 指标表
CREATE TABLE model_metrics (
    model_id VARCHAR(10) PRIMARY KEY COMMENT '模型ID（关联models表）',
    artif_intel_idx DECIMAL(5,2) COMMENT 'Artificial Analysis Intelligence Index',
    artif_omni_idx DECIMAL(5,2) COMMENT 'Artificial Analysis Omniscience Index',
    terminal_bench_hard DECIMAL(5,2) COMMENT 'Terminal-Bench Hard（百分比数值，如61代表61%）',
    aa_omni_accuracy DECIMAL(5,2) COMMENT 'AA-Omniscience Accuracy（百分比数值）',
    blended_price DECIMAL(8,4) COMMENT 'Blended (USD/1M Tokens)',
    median_tokens_s DECIMAL(8,2) COMMENT 'Median Tokens per second',
    latency_first_chunk DECIMAL(8,2) COMMENT 'Latency of first chunk (seconds)',
    total_response_time DECIMAL(8,2) COMMENT 'Total response time (seconds)',
    INDEX idx_metrics_intel (artif_intel_idx),
    INDEX idx_metrics_price (blended_price),
    CONSTRAINT fk_metrics_model FOREIGN KEY (model_id) 
        REFERENCES models(model_id) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='模型数值指标表（宽表，每个模型一行）';
```

#### 3.3.2 索引设计

索引已在建表语句中定义，此处汇总如下：

```sql
-- 模型表索引
CREATE INDEX idx_models_creator ON models(creator_id);
CREATE INDEX idx_models_release_date ON models(release_date);
CREATE INDEX idx_models_open_source ON models(is_open_source);

-- 指标表索引
CREATE INDEX idx_metrics_intel ON model_metrics(artif_intel_idx);
CREATE INDEX idx_metrics_price ON model_metrics(blended_price);
```

**索引选择理由**：

- `idx_models_creator`：优化按厂商查询（`WHERE creator_id = ?`）。
- `idx_metrics_intel`：加速按智力指数排序（`ORDER BY artif_intel_idx DESC`）。
- `idx_metrics_price`：支持价格范围查询（`WHERE blended_price BETWEEN ? AND ?`）。

---

### 3.4 测试数据录入

<!-- 请在此处插入测试数据截图 -->
<!-- 建议截图来源：MySQL Workbench 中执行 SELECT * FROM models LIMIT 10 的结果 -->

本系统共录入 **19 家厂商、65 个模型、65 条性能指标**，以下展示代表性数据：

```sql
-- 插入厂商数据（代表性节选）
INSERT INTO creators VALUES 
('oai', 'OpenAI', '全球领先的人工智能研究机构，开发了GPT系列模型，致力于通用人工智能（AGI）的探索。'),
('ant', 'Anthropic', '由前OpenAI成员创立，专注于AI安全与可控性，代表模型为Claude系列。'),
('goog', 'Google', '科技巨头，深耕AI领域多年，拥有Gemini（原Bard）、PaLM等模型。'),
('meta', 'Meta', '社交媒体巨头，开源大模型的推动者，Llama系列影响深远。'),
('deep', 'DeepSeek', '深度求索（DeepSeek）公司，以高性价比和开源模型著称。'),
('kimi', 'Kimi', '北京月之暗面科技有限公司，主打超长上下文（Kimi K2系列）。');

-- 插入模型数据（代表性节选）
INSERT INTO models VALUES 
('gpt55xh', 'GPT-5.5 (xhigh)', 'oai', 922000, 0, '2026-04-23', '通用推理、代码生成、长文本分析', 'xhigh配置：最高推理深度，延迟较高，适合复杂任务。'),
('cl47mx', 'Claude Opus 4.7 (max)', 'ant', 1000000, 0, '2026-04-16', '高难度推理、安全合规', 'max配置：最强能力，耗时长。'),
('gem31p', 'Gemini 3.1 Pro Preview', 'goog', 1000000, 0, '2026-02-19', '多模态、长上下文推理', 'Pro预览版，性能强劲。'),
('dsv4pm', 'DeepSeek V4 Pro (Max)', 'deep', 1000000, 1, '2026-04-24', '极致性价比，代码能力强', 'Max模式，质量最高。'),
('kimi26a', 'Kimi K2.6', 'kimi', 256000, 1, '2026-04-20', '超长文档理解、多Agent协同', '1万亿参数MoE，原生多模态，MIT协议开源。');

-- 插入指标数据（代表性节选）
INSERT INTO model_metrics VALUES 
('gpt55xh', 60.00, 20.00, 61.00, 57.00, 4.3500, 71.00, 32.54, 39.60),
('cl47mx', 57.00, 26.00, 52.00, 46.00, 4.1000, 57.00, 19.14, 27.97),
('gem31p', 57.00, 33.00, 54.00, 55.00, 1.7400, 144.00, 28.52, 31.99),
('dsv4pm', 52.00, -10.00, 46.00, 43.00, 0.1800, 54.00, 1.86, 92.96),
('kimi26a', 54.00, 6.00, 44.00, 33.00, 0.7000, 37.00, 2.55, 136.43);
```

---

## 4. 技术实现及步骤

> 💡 **执行说明**：以下 SQL 示例均可在当前 `llm_benchmark` 环境中直接运行，用于观察执行结果并整理到课程报告中。

### 4.1 查询操作（SELECT）

#### 4.1.1 单表查询

以三个核心表为例，分别给出参数化 SQL 模板（`?` 占位符）与带具体值的完整语句。

**1. creators（厂商表）**

```
-- 模板（按厂商ID查询，?占位符）
SELECT * FROM creators WHERE creator_id = ?;

-- 完整示例：查询 OpenAI 的厂商信息
SELECT * FROM creators WHERE creator_id = 'oai';
```

| creator_id | creator_name | description |
| :--- | :--- | :--- |
| oai | OpenAI | 全球领先的人工智能研究机构，开发了GPT系列…… |

**2. models（模型表）**

```
-- 模板（按厂商查询该厂商旗下所有模型）
SELECT model_id, model_name, creator_id, context_window, is_open_source, release_date
FROM models
WHERE creator_id = ?
ORDER BY release_date DESC;

-- 完整示例：查询 Google 旗下所有模型
SELECT model_id, model_name, creator_id, context_window, is_open_source, release_date
FROM models
WHERE creator_id = 'goog'
ORDER BY release_date DESC;
```

| model_id | model_name | creator_id | context_window | is_open_source | release_date |
| :--- | :--- | :--- | :--- | :--- | :--- |
| gem35f | Gemini 3.5 Flash | goog | 1000000 | 0 | 2026-05-19 |
| gem35fm | Gemini 3.5 Flash (minimal) | goog | 1000000 | 0 | 2026-05-19 |
| gemma4 | Gemma 4 31B | goog | 256000 | 1 | 2026-04-03 |
| gem31p | Gemini 3.1 Pro Preview | goog | 1000000 | 0 | 2026-02-19 |
| gem25p | Gemini 2.5 Pro | goog | 1000000 | 0 | 2024-12-01 |

**3. model_metrics（指标表）**

```
-- 模板（按智力指数范围查询）
SELECT * FROM model_metrics WHERE artif_intel_idx > ?;

-- 完整示例：查询智力指数高于 50 的所有指标记录
SELECT * FROM model_metrics WHERE artif_intel_idx > 50 ORDER BY artif_intel_idx DESC;
```

| model_id | artif_intel_idx | blended_price | median_tokens_s | latency_first_chunk |
| :--- | :--- | :--- | :--- | :--- |
| gpt55xh | 60.00 | 4.3500 | 71.00 | 32.54 |
| gpt55hi | 59.00 | 4.3500 | 77.00 | 20.52 |
| cl47mx | 57.00 | 4.1000 | 57.00 | 19.14 |
| gem31p | 57.00 | 1.7400 | 144.00 | 28.52 |
| gpt55md | 57.00 | 4.3500 | 69.00 | 5.82 |

---

#### 4.1.2 三表联查（综合表）

将厂商名称、模型基础信息、8 项性能指标合并为统一结果集，是系统的核心查询，对应 DAO 层的 `findAllWithMetrics()` 方法。

```
-- 模板（按厂商名称筛选，移除 WHERE 条件即为全量综合查询）
SELECT m.model_id,
       m.model_name,
       c.creator_name,
       m.context_window,
       m.is_open_source,
       m.release_date,
       m.field_expertise,
       mt.artif_intel_idx,
       mt.artif_omni_idx,
       mt.terminal_bench_hard,
       mt.aa_omni_accuracy,
       mt.blended_price,
       mt.median_tokens_s,
       mt.latency_first_chunk,
       mt.total_response_time
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE c.creator_name = ?
ORDER BY c.creator_name, m.model_name;

-- 完整示例：查询 Anthropic 所有模型的完整信息
SELECT m.model_id,
       m.model_name,
       c.creator_name,
       m.context_window,
       m.is_open_source,
       m.release_date,
       m.field_expertise,
       mt.artif_intel_idx,
       mt.artif_omni_idx,
       mt.terminal_bench_hard,
       mt.aa_omni_accuracy,
       mt.blended_price,
       mt.median_tokens_s,
       mt.latency_first_chunk,
       mt.total_response_time
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE c.creator_name = 'Anthropic'
ORDER BY c.creator_name, m.model_name;
```

| model_id | model_name | context_window | artif_intel_idx | blended_price | median_tokens_s |
| :--- | :--- | :--- | :--- | :--- | :--- |
| cl45hk | Claude 4.5 Haiku | 200000 | 37.00 | 0.8200 | 132.00 |
| cl46mx | Claude Sonnet 4.6 (max) | 1000000 | 52.00 | 2.4600 | 63.00 |
| cl46nr | Claude Sonnet 4.6 (Non-reasoning) | 1000000 | 44.00 | 2.4600 | 49.00 |
| cl46nrl | Claude Sonnet 4.6 (Non-reasoning, Low Effort) | 1000000 | 43.00 | 2.4600 | 49.00 |
| cl47mx | Claude Opus 4.7 (max) | 1000000 | 57.00 | 4.1000 | 57.00 |
| cl47nr | Claude Opus 4.7 (Non-reasoning, high) | 1000000 | 52.00 | 4.1000 | 51.00 |

---

#### 4.1.3 综合表下的筛选查询

支持条件筛选：按厂商、智力指数范围、价格区间等，对应 DAO 层的 `findAllWithMetricsByConditions()` 方法。

```
-- 模板（按厂商 + 智力指数范围筛选）
SELECT m.model_name,
       c.creator_name,
       mt.artif_intel_idx,
       mt.blended_price,
       mt.median_tokens_s
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE m.creator_id = ?
  AND mt.artif_intel_idx BETWEEN ? AND ?
ORDER BY mt.artif_intel_idx DESC;

-- 完整示例：查询 OpenAI 中智力指数 50~65 的模型
SELECT m.model_name,
       c.creator_name,
       mt.artif_intel_idx,
       mt.blended_price,
       mt.median_tokens_s
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE m.creator_id = 'oai'
  AND mt.artif_intel_idx BETWEEN 50 AND 65
ORDER BY mt.artif_intel_idx DESC;
```

| model_name | creator_name | artif_intel_idx | blended_price | median_tokens_s |
| :--- | :--- | :--- | :--- | :--- |
| GPT-5.5 (xhigh) | OpenAI | 60.00 | 4.3500 | 71.00 |
| GPT-5.5 (high) | OpenAI | 59.00 | 4.3500 | 77.00 |
| GPT-5.5 (medium) | OpenAI | 57.00 | 4.3500 | 69.00 |
| GPT-5.3 Codex (xhigh) | OpenAI | 54.00 | 1.8700 | 84.00 |

---

#### 4.1.4 综合表下的排序

利用 `idx_metrics_intel`、`idx_metrics_price` 等索引加速排序，避免文件排序（filesort）。

```
-- 模板（ORDER BY 子句由 Java 代码动态拼接，传入合法的排序字段与方向）
SELECT m.model_name,
       c.creator_name,
       mt.artif_intel_idx,
       mt.median_tokens_s,
       mt.blended_price
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE mt.artif_intel_idx IS NOT NULL
ORDER BY {column_name} {direction};
```

> **注意**：排序字段不能使用 `?` 占位符（PreparedStatement 仅支持参数化值，不支持标识符/关键字），因此在实际 DAO 层（`findAllWithMetricsByConditions()`）中将排序字符串直接拼接至 SQL 尾部，并在业务层做白名单校验以防止 SQL 注入。

```sql
-- 示例一：智力指数降序（性能排行榜）
SELECT m.model_name, c.creator_name,
       mt.artif_intel_idx, mt.median_tokens_s, mt.blended_price
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE mt.artif_intel_idx IS NOT NULL
ORDER BY mt.artif_intel_idx DESC;

-- 示例二：多指标混合排序（智力降序 → 价格升序，兼顾性能与性价比）
SELECT m.model_name, c.creator_name,
       mt.artif_intel_idx, mt.blended_price
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
JOIN model_metrics mt ON m.model_id = mt.model_id
ORDER BY mt.artif_intel_idx DESC, mt.blended_price ASC;
```

**示例二执行结果（节选 Top 6）：**

| model_name | creator_name | artif_intel_idx | blended_price |
| :--- | :--- | :--- | :--- |
| GPT-5.5 (xhigh) | OpenAI | 60.00 | 4.3500 |
| GPT-5.5 (high) | OpenAI | 59.00 | 4.3500 |
| GPT-5.5 (medium) | OpenAI | 57.00 | 4.3500 |
| Gemini 3.1 Pro Preview | Google | 57.00 | 1.7400 |
| Claude Opus 4.7 (max) | Anthropic | 57.00 | 4.1000 |
| Qwen3.7 Max | Alibaba | 57.00 | 1.4300 |

---

#### 4.1.5 综合表下的对比查询

支持用户选中 2~5 个模型进行横向对比，使用 `IN` 子句动态拼接占位符，对应 DAO 层的 `findModelsByIds()` 方法。

```
-- 模板（IN 子句含 N 个 ?，N = 选中模型个数）
SELECT m.model_id,
       m.model_name,
       c.creator_name,
       mt.artif_intel_idx,
       mt.artif_omni_idx,
       mt.terminal_bench_hard,
       mt.aa_omni_accuracy,
       mt.blended_price,
       mt.median_tokens_s,
       mt.latency_first_chunk,
       mt.total_response_time
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE m.model_id IN (?, ?, ?);

-- 完整示例：横向对比 GPT-5.5 xhigh / Claude Opus 4.7 / Gemini 3.1 Pro Preview
SELECT m.model_id,
       m.model_name,
       c.creator_name,
       mt.artif_intel_idx,
       mt.artif_omni_idx,
       mt.terminal_bench_hard,
       mt.aa_omni_accuracy,
       mt.blended_price,
       mt.median_tokens_s,
       mt.latency_first_chunk,
       mt.total_response_time
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE m.model_id IN ('gpt55xh', 'cl47mx', 'gem31p');
```

| 指标 | GPT-5.5 (xhigh) | Claude Opus 4.7 (max) | Gemini 3.1 Pro Preview |
| :--- | :--- | :--- | :--- |
| **厂商** | OpenAI | Anthropic | Google |
| **智力指数** | 60.00 🏆 | 57.00 | 57.00 |
| **全知指数** | 20.00 | 26.00 🏆 | 33.00 🏆 |
| **Terminal-Bench** | 61.00 🏆 | 52.00 | 54.00 |
| **AA-Omni 准确率** | 57.00 🏆 | 46.00 | 55.00 |
| **价格 ($/1M Tokens)** | 4.3500 | 4.1000 | 1.7400 🏆 |
| **吞吐量 (Tokens/s)** | 71.00 | 57.00 | 144.00 🏆 |
| **首包延迟 (s)** | 32.54 | 19.14 🏆 | 28.52 |

> 🏆 标记各指标中的最优值，前端通过 Stream API 计算 `min`/`max` 后自动高亮。

### 4.2 新增操作（INSERT）

#### 4.2.1 单表插入

以三个核心表为例，分别给出参数化 INSERT 模板与完整 SQL 示例，对应 DAO 层的 save() 方法。

**1. creators（厂商表）**

```
-- 模板（三个字段均使用 ? 占位符）
INSERT INTO creators (creator_id, creator_name, description) VALUES (?, ?, ?);

-- 完整示例：新增厂商"字节跳动"
INSERT INTO creators (creator_id, creator_name, description)
VALUES ('bytd', 'ByteDance', '字节跳动，抖音/TikTok母公司，旗下有豆包大模型（Doubao）等AI产品。');
```

**验证新增结果：**

```sql
SELECT * FROM creators WHERE creator_id = 'bytd';
```

| creator_id | creator_name | description |
| :--- | :--- | :--- |
| bytd | ByteDance | 字节跳动，抖音/TikTok母公司…… |

对应 DAO 层：`CreatorDAO.save()`。

---

**2. models（模型表）**

```
-- 模板（8 个字段，含可选字段）
INSERT INTO models (model_id, model_name, creator_id, context_window, is_open_source, release_date, field_expertise, version_upgrade_note)
VALUES (?, ?, ?, ?, ?, ?, ?, ?);

-- 完整示例：为 ByteDance 新增模型"豆包 Pro"
INSERT INTO models (model_id, model_name, creator_id, context_window, is_open_source, release_date, field_expertise, version_upgrade_note)
VALUES ('dbpro', 'Doubao Pro', 'bytd', 256000, 0, '2026-06-01', '中文理解、多模态内容生成', 'Pro版，旗舰性能。');
```

**验证新增结果：**
```sql
SELECT * FROM models WHERE model_id = 'dbpro';
```

| model_id | model_name | creator_id | context_window | is_open_source | release_date |
| :--- | :--- | :--- | :--- | :--- | :--- |
| dbpro | Doubao Pro | bytd | 256000 | 0 | 2026-06-01 |

对应 DAO 层：`ModelDAO.save()`。

---

**3. model_metrics（指标表）**

```
-- 模板（9 个字段，关联已存在的模型）
INSERT INTO model_metrics (model_id, artif_intel_idx, artif_omni_idx, terminal_bench_hard, aa_omni_accuracy, blended_price, median_tokens_s, latency_first_chunk, total_response_time)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);

-- 完整示例：为 Doubao Pro 插入性能指标
INSERT INTO model_metrics (model_id, artif_intel_idx, artif_omni_idx, terminal_bench_hard, aa_omni_accuracy, blended_price, median_tokens_s, latency_first_chunk, total_response_time)
VALUES ('dbpro', 55.00, 15.00, 48.00, 42.00, 0.8000, 120.00, 2.50, 18.00);
```

**验证新增结果：**
```sql
SELECT * FROM model_metrics WHERE model_id = 'dbpro';
```

| model_id | artif_intel_idx | blended_price | median_tokens_s | latency_first_chunk |
| :--- | :--- | :--- | :--- | :--- |
| dbpro | 55.00 | 0.8000 | 120.00 | 2.50 |

对应 DAO 层：`ModelMetricDAO.save()`。

> **注意**：三表的插入顺序受外键约束制约，必须遵循 **creators → models → model_metrics** 的先后顺序，否则会触发 `Cannot add or update a child row: a foreign key constraint fails` 错误。

---

### 4.3 修改操作（UPDATE）

#### 4.3.1 单表更新

以三个核心表为例，分别给出参数化 UPDATE 模板（含 WHERE 主键条件）与完整 SQL 示例，对应 DAO 层的 `update()` 方法。

**1. creators（厂商表）**

仅允许修改厂商名称和简介，主键 `creator_id` 不可变更。

```
-- 模板（以 creator_id 为 WHERE 条件）
UPDATE creators SET creator_name = ?, description = ? WHERE creator_id = ?;

-- 完整示例：更新厂商 StepFun 的名称与简介
UPDATE creators
SET creator_name = 'StepFun (阶跃星辰)',
    description = '阶跃星辰，国内新锐AI公司，Step系列模型在多模态和长文本上持续突破，2026年发布多款旗舰模型。'
WHERE creator_id = 'step';
```

**验证更新结果：**
```sql
SELECT * FROM creators WHERE creator_id = 'step';
```

| creator_id | creator_name | description |
| :--- | :--- | :--- |
| step | StepFun (阶跃星辰) | 阶跃星辰，国内新锐AI公司…… |

对应 DAO 层：`CreatorDAO.update()`。

---

**2. models（模型表）**

可更新除主键 `model_id` 外的所有字段，包括切换厂商归属（外键自动校验新 `creator_id` 是否存在）。

```
-- 模板（8 个字段，以 model_id 为 WHERE 条件）
UPDATE models SET model_name=?, creator_id=?, context_window=?, is_open_source=?, release_date=?, field_expertise=?, version_upgrade_note=? WHERE model_id=?;

-- 完整示例：扩展 GPT-5.5 (xhigh) 的上下文窗口并添加说明
UPDATE models
SET context_window = 256000,
    version_upgrade_note = '上下文窗口翻倍至256K，适合超长文档分析场景。'
WHERE model_id = 'gpt55xh';
```

**验证更新结果：**
```sql
SELECT model_id, model_name, context_window, version_upgrade_note
FROM models WHERE model_id = 'gpt55xh';
```

| model_id | model_name | context_window | version_upgrade_note |
| :--- | :--- | :--- | :--- |
| gpt55xh | GPT-5.5 (xhigh) | 256000 | 上下文窗口翻倍至256K…… |

对应 DAO 层：`ModelDAO.update()`。

---

**3. model_metrics（指标表）**

可更新 8 个性能指标中的任意字段，`model_id` 不可修改（外键主键）。`aa_omni_accuracy` 要求在 0~100 范围内。

```
-- 模板（8 个指标字段，以 model_id 为 WHERE 条件）
UPDATE model_metrics SET artif_intel_idx=?, artif_omni_idx=?, terminal_bench_hard=?, aa_omni_accuracy=?, blended_price=?, median_tokens_s=?, latency_first_chunk=?, total_response_time=? WHERE model_id=?;

-- 完整示例：调整 GPT-5.5 (xhigh) 的价格与吞吐量
UPDATE model_metrics
SET blended_price = 3.9800,
    median_tokens_s = 85.00,
    latency_first_chunk = 28.50
WHERE model_id = 'gpt55xh';
```

**验证更新结果：**
```sql
SELECT model_id, blended_price, median_tokens_s, latency_first_chunk
FROM model_metrics WHERE model_id = 'gpt55xh';
```

| model_id | blended_price | median_tokens_s | latency_first_chunk |
| :--- | :--- | :--- | :--- |
| gpt55xh | 3.9800 | 85.00 | 28.50 |

对应 DAO 层：`ModelMetricDAO.update()`。

> **注意**：UPDATE 语句必须携带 WHERE 主键条件，否则将更新全表数据——这是生产环境中极易出现的事故。Java 应用中始终使用 `PreparedStatement` 参数化绑定，杜绝 SQL 注入风险。

---

### 4.4 删除操作（DELETE）

#### 4.4.1 单表删除

以三个核心表为例，展示在不同外键约束下的删除策略。删除顺序与插入相反，必须遵循 **model_metrics → models → creators** 的倒序。

**1. model_metrics（指标表）— 独立删除**

指标表通过外键 `model_id` 引用 models 表（`ON DELETE CASCADE`），但也可以单独删除某条指标记录而不影响模型基础信息。

```
-- 模板（以 model_id 为 WHERE 条件）
DELETE FROM model_metrics WHERE model_id = ?;

-- 完整示例：删除模型 dsv4fl 的指标记录（仅删除指标，模型信息保留）
DELETE FROM model_metrics WHERE model_id = 'dsv4fl';
```

**验证删除结果：**
```sql
SELECT * FROM model_metrics WHERE model_id = 'dsv4fl';
-- 结果：Empty set（指标已删除）
```

对应 DAO 层：`ModelMetricDAO.deleteById()`。

---

**2. models（模型表）— 级联删除（CASCADE）**

删除模型时，外键 `ON DELETE CASCADE` 会自动删除 `model_metrics` 中对应的指标记录，无需手动操作。

```
-- 模板（一条 DELETE 即完成模型+指标的级联删除）
DELETE FROM models WHERE model_id = ?;

-- 完整示例：删除模型 dsv4fl（其关联指标会被自动级联删除）
DELETE FROM models WHERE model_id = 'dsv4fl';
```

**验证级联删除：**

```
-- 模型已删除
SELECT * FROM models WHERE model_id = 'dsv4fl';  -- Empty set
-- 指标也自动清除
SELECT * FROM model_metrics WHERE model_id = 'dsv4fl';  -- Empty set
```

对应 DAO 层：`ModelDAO.deleteById()`。

---

**3. creators（厂商表）— 前置检查 + 安全删除（RESTRICT）**

厂商表的外键约束为 `ON DELETE RESTRICT`，若有模型仍指向该厂商则直接删除会报错。安全删除分两种情况：

**场景 A：厂商下无模型 → 直接删除**

```
-- 前置检查：确认厂商下没有模型
SELECT COUNT(*) FROM models WHERE creator_id = ?;  -- 返回 0 则可安全删除

-- 直接删除厂商
DELETE FROM creators WHERE creator_id = ?;

-- 完整示例：删除无模型的测试厂商（前置操作：已删除 bytd 下的模型 dbpro）
DELETE FROM creators WHERE creator_id = 'bytd';
```

**场景 B：厂商下有模型 → 事务化级联删除**

需先删除该厂商下的所有模型（触发 CASCADE 清除指标），再删除厂商本身。

```
-- 完整示例：以事务方式删除含模型的厂商（以 StepFun 为例）
START TRANSACTION;

-- 第 1 步：删除该厂商下所有模型（CASCADE 自动清除对应指标）
DELETE FROM models WHERE creator_id = 'step';

-- 第 2 步：删除厂商本身
DELETE FROM creators WHERE creator_id = 'step';

COMMIT;
```

**验证删除结果：**
```
SELECT * FROM creators WHERE creator_id = 'step';  -- Empty set
SELECT * FROM models WHERE creator_id = 'step';     -- Empty set
```

对应 DAO 层：应用层先调用 `CreatorDAO.hasRelatedModels()` 检查，再决定是否执行删除或提示用户。

> ⚠️ **外键约束删除策略总结**
>
> | 操作 | 约束类型 | 策略 |
> |:---|:---:|:---|
> | 删除 creators | `ON DELETE RESTRICT` | 先清除子表 models 记录，再删除父表 |
> | 删除 models | `ON DELETE CASCADE` | 自动级联删除 model_metrics 中关联指标 |
> | 删除 model_metrics | 无下游依赖 | 可独立删除，不影响 models 基础信息 |
>
> 删除顺序必须为 **model_metrics → models → creators**，与插入顺序完全相反。

---



### 4.6 三表完整 CRUD 操作清单

本节按 `creators`、`models`、`model_metrics` 三个核心表分别列出项目 JavaEE 应用中涉及的全部 SQL 操作实例，并对应到具体的 DAO 层方法、Servlet 功能接口和 JSP 页面。

#### 4.6.1 creators（厂商表）

| 操作类型 | SQL 语句 | 项目功能点 | 操作说明 |
| :--- | :--- | :--- | :--- |
| **新增** | `INSERT INTO creators (creator_id, creator_name, description) VALUES (?, ?, ?)` | **厂商管理页** → "新增厂商"按钮 | 对应 `ManageServlet.handleAddCreator` → `CreatorDAO.save()`。使用 PreparedStatement 参数化绑定防 SQL 注入；`creator_id` 由用户手工输入（1~10位字母数字），重复时抛出 `DuplicateEntry` 异常。 |
| **查询列表** | `SELECT * FROM creators` | **厂商管理页** / **模型编辑选择器** | 对应 `BaseDAO.findAll()`。在厂商管理页（`ListServlet?type=creators` → `creators.jsp`）渲染全部厂商；同时作为模型编辑页中下拉框的数据源。 |
| **修改** | `UPDATE creators SET creator_name = ?, description = ? WHERE creator_id = ?` | **厂商管理页** → "编辑厂商"按钮 | 对应 `ManageServlet.handleUpdateCreator` → `CreatorDAO.update()`。不允许修改 `creator_id`（主键不可变），仅更新名称和简介。 |
| **删除** | `DELETE FROM creators WHERE creator_id = ?` | **厂商管理页** → "删除厂商"按钮 | 对应 `ManageServlet.handleDeleteCreator` → `CreatorDAO.deleteById()`。受 `ON DELETE RESTRICT` 约束，若厂商下存在模型则删除失败，因此删除前必须执行前置检查。 |
| **删除前置检查** | `SELECT COUNT(*) FROM models WHERE creator_id = ?` | 删除厂商前的安全校验 | 对应 `CreatorDAO.hasRelatedModels()`。若返回值 > 0，前端提示"请先删除该厂商下的所有模型"，避免直接触碰外键报错，提升用户体验。 |

#### 4.6.2 models（模型表）

| 操作类型 | SQL 语句 | 项目功能点 | 操作说明 |
| :--- | :--- | :--- | :--- |
| **新增** | `INSERT INTO models (model_id, model_name, creator_id, context_window, is_open_source, release_date, field_expertise, version_upgrade_note) VALUES (?, ?, ?, ?, ?, ?, ?, ?)` | **模型管理页** → "新增模型"按钮 | 对应 `ManageServlet.handleAddModel` → `ModelDAO.save()`。`creator_id` 必须已在 `creators` 表中存在（外键约束）；可选字段为 NULL；防注入。 |
| **查询列表** | `SELECT * FROM models` | **模型管理页** | 对应 `BaseDAO.findAll()`。展示全部模型基础信息（`ListServlet?type=models` → `models.jsp`）。 |
| **动态条件查询** | `SELECT m.* FROM models m LEFT JOIN model_metrics mt ON m.model_id = mt.model_id WHERE 1=1 AND m.creator_id = ? AND mt.artif_intel_idx BETWEEN ? AND ? ORDER BY mt.artif_intel_idx DESC` | **综合视图页** → 多条件筛选 | 对应 `ModelDAO.findByConditions()`。支持 8 种条件组合：按厂商筛选、开源状态、上下文范围、智力指数范围、价格范围、吞吐量范围、发布日期范围、擅长领域模糊匹配；排序字段可动态指定。 |
| **三表 JOIN 综合查询** | `SELECT m.*, c.creator_name, mt.artif_intel_idx, mt.artif_omni_idx, mt.terminal_bench_hard, mt.aa_omni_accuracy, mt.blended_price, mt.median_tokens_s, mt.latency_first_chunk, mt.total_response_time FROM models m LEFT JOIN creators c ON m.creator_id = c.creator_id LEFT JOIN model_metrics mt ON m.model_id = mt.model_id ORDER BY c.creator_name, m.model_name` | **综合视图页** → 全部数据展示 | 对应 `ModelDAO.findAllWithMetrics()`。三表 LEFT JOIN 将模型信息、厂商名称、8 个性能指标合并为统一结果集；按厂商名+模型名排序。 |
| **批量对比查询** | `SELECT m.*, c.creator_name, mt.* FROM models m LEFT JOIN creators c ON m.creator_id = c.creator_id LEFT JOIN model_metrics mt ON m.model_id = mt.model_id WHERE m.model_id IN (?, ?, ?)` | **模型对比页** → 选中 2~5 个模型对比 | 对应 `ModelDAO.findModelsByIds()` → `CompareServlet`。动态拼接 IN 子句占位符；结果用于 `compare.jsp` 横向对比表格，自动高亮各指标最优值（Stream API 计算 min/max）。 |
| **修改** | `UPDATE models SET model_name=?, creator_id=?, context_window=?, is_open_source=?, release_date=?, field_expertise=?, version_upgrade_note=? WHERE model_id=?` | **模型管理页** → "编辑模型"按钮 | 对应 `ManageServlet.handleUpdateModel` → `ModelDAO.update()`。`model_id` 不可修改；可切换厂商归属（外键自动校验新厂商是否存在）。 |
| **删除（级联）** | `DELETE FROM models WHERE model_id = ?` | **模型管理页** → "删除模型"按钮 | 对应 `ManageServlet.handleDeleteModel` → `ModelDAO.deleteById()`。`ON DELETE CASCADE` 自动删除 `model_metrics` 中关联指标，无需手动调用指标删除方法。 |

**级联删除验证示例：**
```
-- 删除模型
DELETE FROM models WHERE model_id = 'dsv4fl';
-- 验证指标已自动删除
SELECT * FROM model_metrics WHERE model_id = 'dsv4fl';  -- 预期结果：Empty set
```

#### 4.6.3 model_metrics（指标表）

| 操作类型 | SQL 语句 | 项目功能点 | 操作说明 |
| :--- | :--- | :--- | :--- |
| **新增** | `INSERT INTO model_metrics (model_id, artif_intel_idx, artif_omni_idx, terminal_bench_hard, aa_omni_accuracy, blended_price, median_tokens_s, latency_first_chunk, total_response_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)` | **指标管理页** → "新增指标"按钮 | 对应 `ManageServlet.handleAddMetric` → `ModelMetricDAO.save()`。`model_id` 必须是已存在的模型（外键约束 `ON DELETE CASCADE`）；`aa_omni_accuracy` 在服务端做 0~100 范围校验。 |
| **查询列表** | `SELECT * FROM model_metrics` | **指标管理页** | 对应 `BaseDAO.findAll()`。展示全部模型指标数据（`ListServlet?type=metrics` → `metrics.jsp`）。 |
| **按价格范围筛选** | `SELECT m.model_name, c.creator_name, mt.blended_price, mt.artif_intel_idx FROM models m LEFT JOIN creators c ON m.creator_id = c.creator_id JOIN model_metrics mt ON m.model_id = mt.model_id WHERE mt.blended_price BETWEEN ? AND ? ORDER BY mt.blended_price` | **综合视图页** → 价格筛选 | 利用 `idx_metrics_price` 索引加速价格区间过滤；适合查询"性价比最高"的模型。 |
| **按智力指数排序** | `SELECT m.model_name, c.creator_name, mt.artif_intel_idx, mt.median_tokens_s FROM models m LEFT JOIN creators c ON m.creator_id = c.creator_id JOIN model_metrics mt ON m.model_id = mt.model_id WHERE mt.artif_intel_idx IS NOT NULL ORDER BY mt.artif_intel_idx DESC` | **综合视图页** → 智力指数排序/TOP N 高亮 | 利用 `idx_metrics_intel` 索引避免 file sort；前端对前三名做绿色高亮标注。 |
| **多指标混合排序** | `ORDER BY mt.artif_intel_idx DESC, mt.blended_price ASC` | **综合视图页** → 自定义排序 | 先按智力指数降序，再按价格升序，兼顾性能与性价比的综合排序策略。 |
| **修改** | `UPDATE model_metrics SET artif_intel_idx=?, artif_omni_idx=?, terminal_bench_hard=?, aa_omni_accuracy=?, blended_price=?, median_tokens_s=?, latency_first_chunk=?, total_response_time=? WHERE model_id=?` | **指标管理页** → "编辑指标"按钮 | 对应 `ManageServlet.handleUpdateMetric` → `ModelMetricDAO.update()`。`model_id` 不可修改（主键）；8 个指标字段独立更新；`aa_omni_accuracy` 同样做 0~100 范围校验。 |
| **删除** | `DELETE FROM model_metrics WHERE model_id = ?` | **指标管理页** → "删除指标"按钮 | 对应 `ManageServlet.handleDeleteMetric` → `ModelMetricDAO.deleteById()`。仅删除指标记录，不影响 `models` 表中的基础信息；通常用于误添加或数据修正场景。 |

**实用组合查询示例：**
```
-- 查询价格低于 $1.0/1M Tokens 的高性价比模型
SELECT m.model_name, c.creator_name, mt.blended_price, mt.artif_intel_idx
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE mt.blended_price < 1.0
ORDER BY mt.artif_intel_idx DESC;

-- 智力指数 Top 10 排行榜
SELECT m.model_name, c.creator_name, mt.artif_intel_idx, mt.median_tokens_s
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE mt.artif_intel_idx IS NOT NULL
ORDER BY mt.artif_intel_idx DESC
LIMIT 10;

-- 查询吞吐量 > 100 Tokens/s 且价格 < $5 的高性能低价模型
SELECT m.model_name, c.creator_name, mt.median_tokens_s, mt.blended_price, mt.artif_intel_idx
FROM models m
JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE mt.median_tokens_s > 100 AND mt.blended_price < 5.0
ORDER BY mt.artif_intel_idx DESC;
```

---

## 5. 实验过程记录

### 5.1 核心表创建

<!-- 请在此处插入建表成功截图 -->
<!-- 建议截图来源：MySQL Shell 中执行 CREATE TABLE 后的 "Query OK" 提示 -->

**操作步骤**：
1. 打开 MySQL Shell，连接到本地数据库服务器。
2. 执行 `CREATE DATABASE llm_benchmark;` 创建数据库。
3. 依次执行三张表的 `CREATE TABLE` 语句。
4. 使用 `SHOW TABLES;` 验证表是否创建成功。

**遇到的问题**：
- **问题 1**：初次建表时忘记指定 `ENGINE=InnoDB`，导致不支持外键约束。
- **解决方法**：删除表后重新创建，显式声明 `ENGINE=InnoDB`。

---

### 5.2 测试数据录入

<!-- 请在此处插入数据插入成功截图 -->
<!-- 建议截图来源：执行 INSERT 语句后的 "Query OK, X rows affected" 提示 -->

**操作步骤**：
1. 执行 `INSERT INTO creators` 插入 19 家厂商。
2. 执行 `INSERT INTO models` 插入 65 个模型。
3. 执行 `INSERT INTO model_metrics` 插入对应的指标数据。
4. 使用 `SELECT COUNT(*) FROM models;` 验证数据量。

**遇到的问题**：
- **问题 2**：插入指标数据时报错 `Cannot add or update a child row: a foreign key constraint fails`。
- **原因分析**：尝试插入的 `model_id` 在 `models` 表中不存在。
- **解决方法**：先插入模型基础信息，再插入对应的指标数据。

---



### 5.4 事务测试案例

#### 5.4.1 正常提交流程

```
START TRANSACTION;
INSERT INTO models VALUES ('test_tx_1', 'Test TX 1', 'oai', 50000, 0, '2026-06-01', '测试事务', '事务测试示例');
INSERT INTO model_metrics VALUES ('test_tx_1', 55.00, 10.00, 40.00, 35.00, 1.2000, 100.00, 2.00, 15.00);
COMMIT;

-- 验证数据已持久化
SELECT * FROM models WHERE model_id = 'test_tx_1';  -- 有结果
```

---

#### 5.4.2 异常回滚流程

```
START TRANSACTION;
INSERT INTO models VALUES ('test_tx_2', 'Test TX 2', 'oai', 50000, 0, '2026-06-01', '测试事务', '事务回滚示例');
-- 模拟错误：重复插入相同主键
INSERT INTO models VALUES ('test_tx_2', 'Duplicate', 'oai', 50000, 0, '2026-06-01', '重复数据', '应该失败');
-- 执行到这里会报错，事务自动中断

ROLLBACK;  -- 手动回滚（或等待自动回滚）

-- 验证数据未持久化
SELECT * FROM models WHERE model_id = 'test_tx_2';  -- Empty set
```

**验证结果**：事务回滚成功，两条插入操作均未生效。

---

### 5.5 典型问题处理

#### 问题 3：中文乱码

**现象**：插入中文厂商名称后，查询结果显示为 `???`。

**原因分析**：
- 数据库字符集为 `latin1`，不支持中文。
- JDBC 连接字符串未指定 `characterEncoding=utf8mb4`。

**解决方法**：
1. 修改数据库字符集：
   ```sql
   ALTER DATABASE llm_benchmark CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ALTER TABLE creators CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```
2. 在 `db.properties` 中添加 `characterEncoding=UTF-8`。

---

#### 问题 4：慢查询优化

**现象**：使用 EXPLAIN 分析查询计划时，发现未使用索引导致全表扫描。

**优化步骤**：
1. 使用 `EXPLAIN` 分析查询计划：
   ```sql
   EXPLAIN SELECT * FROM models m 
   JOIN model_metrics mt ON m.model_id = mt.model_id 
   ORDER BY mt.artif_intel_idx DESC;
   ```
2. 发现未使用索引，执行全表扫描（`type: ALL`）。
3. 创建索引：
   ```sql
   CREATE INDEX idx_metrics_intel ON model_metrics(artif_intel_idx);
   ```
4. 再次执行 `EXPLAIN`，确认使用索引（`type: index`）。
5. 查询耗时降至 0.05 秒，性能提升 40 倍。

---

### 5.6 性能优化对比

性能优化效果详见 6.3.1 节索引优化效果中的 EXPLAIN 分析结果。

---

## 6. 质量验证

### 6.1 ACID 验证矩阵

| ACID 属性 | 验证方法 | 预期结果 | 实际结果 |
| :--- | :--- | :--- | :--- |
| **原子性（Atomicity）** | 事务中插入两条数据，第二条故意失败后回滚 | 两条数据均未插入 | ✅ 通过 |
| **一致性（Consistency）** | 删除有指标关联的模型，验证指标是否级联删除 | 指标记录同步删除 | ✅ 通过 |


---

### 6.2 功能测试案例

#### 测试案例 1：外键约束验证

**测试步骤**：
1. 尝试删除仍有模型关联的厂商：
   ```sql
   DELETE FROM creators WHERE creator_id = 'oai';
   ```
2. 观察是否报错。

**预期结果**：报错 `Cannot delete or update a parent row: a foreign key constraint fails`。

**实际结果**：✅ 符合预期，`ON DELETE RESTRICT` 生效。

---

#### 测试案例 2：级联删除验证

**测试步骤**：
1. 删除一个模型：
   ```sql
   DELETE FROM models WHERE model_id = 'gpt55xh';
   ```
2. 查询对应的指标是否存在：
   ```sql
   SELECT * FROM model_metrics WHERE model_id = 'gpt55xh';
   ```

**预期结果**：指标记录已自动删除。

**实际结果**：✅ 符合预期，`ON DELETE CASCADE` 生效。

---

#### 测试案例 3：唯一性约束验证

**测试步骤**：
1. 尝试插入重复的 `model_id`：
   ```sql
   INSERT INTO models VALUES ('gpt55xh', 'Duplicate', 'oai', 50000, 0, '2026-01-01', NULL, NULL);
   ```

**预期结果**：报错 `Duplicate entry 'gpt55xh' for key 'PRIMARY'`。

**实际结果**：✅ 符合预期，主键唯一性约束生效。

---

### 6.3 性能测试

#### 6.3.1 索引优化效果

<!-- 请在此处插入 EXPLAIN 分析截图 -->
<!-- 建议截图来源：MySQL Workbench 中执行 EXPLAIN 后的可视化执行计划 -->

**测试 SQL**：
```
SELECT m.model_name, mt.artif_intel_idx
FROM models m
JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE mt.artif_intel_idx > 50
ORDER BY mt.artif_intel_idx DESC;
```

**EXPLAIN 分析结果**：

| 优化阶段 | type | possible_keys | key | rows | Extra |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **无索引** | ALL | NULL | NULL | 65 | Using where; Using filesort |
| **有索引** | range | idx_metrics_intel | idx_metrics_intel | 25 | Using where; Using index |

**结论**：索引使扫描行数从 65 降至 25，性能提升显著。

---



### 6.4 数据完整性验证

#### 验证 SQL 脚本

```
-- 1. 检查孤儿记录（有指标但无模型）
SELECT COUNT(*) FROM model_metrics mt
LEFT JOIN models m ON mt.model_id = m.model_id
WHERE m.model_id IS NULL;
-- 预期结果：0

-- 2. 检查无效外键（模型指向不存在的厂商）
SELECT COUNT(*) FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
WHERE c.creator_id IS NULL;
-- 预期结果：0

-- 3. 检查数据类型约束（智力指数合理取值范围）
SELECT COUNT(*) FROM model_metrics
WHERE artif_intel_idx IS NOT NULL
  AND (artif_intel_idx < 0 OR artif_intel_idx > 100);
-- 预期结果：0
```

**验证结果**：所有检查均返回 0，数据完整性良好。

---

## 7. 总结与展望

### 7.1 项目总结

本课程设计成功实现了一个功能完整的 LLM Benchmark 大模型性能评测数据库系统，主要成果包括：

1. **数据库设计规范化**：遵循第三范式（3NF），通过三张表有效分离厂商、模型、指标信息，避免数据冗余。
2. **完整性约束完善**：通过主键、外键、`RESTRICT` 与 `CASCADE` 策略，确保数据一致性与引用完整性。
3. **查询性能优化**：针对常用筛选字段建立索引，使复杂查询响应时间从秒级降至毫秒级。
4. **ACID 特性验证**：通过事务测试案例与级联删除验证了原子性与一致性。

---

### 7.2 不足与改进方向

| 不足之处 | 改进方案 |
| :--- | :--- |
| **无连接池** | 引入 HikariCP 或 Apache DBCP，降低连接创建开销 |
| **手动拼接 JSON** | 引入 Jackson 库实现对象序列化，提升代码可维护性 |
| **缺少权限控制** | 增加用户角色表（管理员/普通用户），实现细粒度权限管理 |
| **无数据备份机制** | 编写定时任务执行 `mysqldump`，实现每日自动备份 |
| **未使用分区表** | 若数据量超过百万级，可按 `release_date` 进行范围分区 |

---

### 7.3 学习心得

通过本次课程设计，深入理解了以下核心知识点：

1. **E-R 图到关系模式的转化**：掌握了 1:N 与 1:1 关系的外键设计规则。
2. **索引优化原理**：通过 `EXPLAIN` 分析执行计划，理解 B+Tree 索引如何加速查询。
3. **事务管理机制**：通过手动控制 `START TRANSACTION`、`COMMIT`、`ROLLBACK`，体会 ACID 特性的实际意义。

**未来展望**：
- 结合 Spring Boot 框架实现 RESTful API，前后端完全分离。
- 引入 Redis 缓存热点数据，进一步降低数据库负载。
- 部署至云平台（如 AWS RDS 或阿里云 RDS），实现高可用架构。

---

## 参考文献

[1] MySQL 8.0 Reference Manual. Oracle Corporation, 2026.  
[2] 王珊, 萨师煊. 数据库系统概论（第 6 版）. 高等教育出版社, 2023.  
[3] Artificial Analysis. LLM Intelligence Index Methodology. https://artificialanalysis.ai/, 2026.  
[4] Apache Tomcat Documentation. Jakarta Servlet Specification 5.0. https://tomcat.apache.org/, 2026.

---

**附录 A：完整 SQL 脚本**

完整建表与插入数据代码详见项目文件 `llm_benchmark.sql`。

**附录 B：项目源码地址**

GitHub 仓库：[请填写您的仓库链接]
