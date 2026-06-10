# 项目技术实现与SQL详解文档

> **项目名称**：大模型性能对比评测系统（LLM Benchmark System）
> **技术栈**：Jakarta EE 5.0（Servlet + JSP + JSTL）+ MySQL 8.0 + JDBC
> **本文定位**：面向答辩/技术评审，全面解析项目实现细节，重点剖析 SQL 编写与使用策略。

---

## 一、概述与架构

### 1.1 项目目标

构建一个 Web 端大模型多维性能评测平台，实现对 19 家 AI 厂商、64 个大模型、62 条性能指标数据的**可视化浏览、条件筛选、多维排序、多模型横向对比**，同时提供三张核心表的 **CRUD 管理功能**。

### 1.2 技术栈速览

| 层级 | 技术 | 版本 | 定位 |
|------|------|------|------|
| 后端语言 | Java | 21 LTS | 业务逻辑与数据访问 |
| Web 容器 | Apache Tomcat | 10.1+ | 原生支持 Jakarta EE 5.0 |
| Web 标准 | Jakarta Servlet + JSP | 5.0 + 3.0 | 请求分发与页面渲染 |
| 模板标签 | JSTL | 3.0 | JSP 内遍历集合、条件渲染 |
| 数据库 | MySQL | 8.0 | 关系型数据存储 |
| JDBC 驱动 | MySQL Connector/J | 8.0.33 | 数据库连接 |
| 构建 | Maven | 3.x | 依赖管理与 WAR 打包 |
| JSON | 手动拼接 | — | 无第三方库依赖，轻量实现 |

### 1.3 整体请求处理流程

```
浏览器请求
    │
    ├── GET /list?type=fullview ──→ ListServlet.doGet()
    │       └── modelDAO.findAllWithMetrics() → 三表 LEFT JOIN → fullview.jsp 渲染
    │
    ├── GET /manage?action=searchFullview&... ──→ ManageServlet.doGet()
    │       └── modelDAO.findAllWithMetricsByConditions() → 动态拼 SQL → 返回 JSON
    │
    ├── POST /manage?action=addModel&... ──→ ManageServlet.doPost()
    │       └── modelDAO.save() → INSERT → 返回 JSON（含 SQL 回显）
    │
    └── GET /compare?ids=gpt55xh,cl47mx ──→ CompareServlet.doGet()
            └── modelDAO.findModelsByIds() → IN 子句查询 → compare.jsp 渲染
```

**数据流向**：浏览器 → Servlet（解析参数、调用 DAO）→ DAO（拼接 SQL、执行 JDBC）→ MySQL → ResultSet → Entity/VO → Servlet（存入 request 或转 JSON）→ JSP/AJAX 回调渲染。

---

## 二、模块与文件职责

### 2.1 项目目录总览

```
src/main/
├── java/com/benchmark/
│   ├── util/
│   │   └── DBUtil.java              ← 数据库连接工厂
│   ├── entity/
│   │   ├── Creator.java             ← creators 表映射
│   │   ├── Model.java               ← models 表映射
│   │   ├── ModelMetric.java         ← model_metrics 表映射
│   │   └── ModelCompareVO.java      ← 三表 JOIN 视图对象
│   ├── dao/
│   │   ├── BaseDAO.java             ← 模板方法抽象基类
│   │   ├── CreatorDAO.java          ← 厂商 CRUD
│   │   ├── ModelDAO.java            ← 模型 CRUD + 多表查询 + 动态筛选
│   │   └── ModelMetricDAO.java      ← 指标 CRUD
│   └── servlet/
│       ├── ListServlet.java         ← 静态列表页分发
│       ├── ManageServlet.java       ← CRUD + AJAX 搜索 API
│       └── CompareServlet.java      ← 对比页控制器
├── resources/
│   └── db.properties                ← 数据库四要素
└── webapp/
    ├── WEB-INF/
    │   ├── web.xml                  ← Jakarta EE 部署描述
    │   └── views/
    │       ├── creators.jsp         ← 厂商管理页
    │       ├── models.jsp           ← 模型管理页
    │       ├── metrics.jsp          ← 指标管理页
    │       ├── fullview.jsp         ← 综合表（筛选+排序+对比）
    │       └── compare.jsp          ← 对比分析页
    ├── css/style.css                ← 全局样式
    └── index.html                   ← 首页导航
```

### 2.2 各类/文件核心职责与调用关系

#### 工具层

| 文件 | 核心职责 | 被调用方 |
|------|---------|---------|
| [DBUtil.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/util/DBUtil.java) | 静态代码块加载 `db.properties`，`Class.forName()` 注册驱动；暴露 `getConnection()` 静态工厂方法返回 `java.sql.Connection` | 所有 DAO 类 |

**关键实现**：静态代码块确保配置在类加载时一次性完成，连接通过 `DriverManager.getConnection()` 按需创建，每次调用返回全新连接，配合 try-with-resources 确保使用后立刻关闭。

#### 实体层

| 文件 | 映射表 | 字段类型决策 | 被调用方 |
|------|--------|-------------|---------|
| [Creator.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/entity/Creator.java) | `creators` | 三个字段全 `String`，因 `creator_id` 虽是主键但存储的是可读短 ID（如 `oai`） | `CreatorDAO`、`ManageServlet` |
| [Model.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/entity/Model.java) | `models` | `context_window` 用 `Integer`（包装类型）而非 `int`，因数据库 ALLOW NULL；`is_open_source` 用 `Boolean` 而非 `boolean`，NULL 表示"未知"；`release_date` 用 `java.sql.Date` | `ModelDAO`、`ManageServlet` |
| [ModelMetric.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/entity/ModelMetric.java) | `model_metrics` | 全部 8 个指标字段用 `BigDecimal`，精确匹配 MySQL `DECIMAL(p,s)` 类型，避免 `float`/`double` 的浮点精度丢失 | `ModelMetricDAO`、`ManageServlet` |
| [ModelCompareVO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/entity/ModelCompareVO.java) | 三表 JOIN 结果集 | 聚合 `models` 全部字段 + `creators.creator_name` + `model_metrics` 全部 8 个指标字段，专用于综合表与对比页的一体化视图对象 | `ModelDAO`（内部 `mapToCompareVO()`）、`CompareServlet` |

#### 数据访问层（DAO）

| 文件 | 核心方法 | 对应 SQL 类型 | 调用方 |
|------|---------|--------------|--------|
| [BaseDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/BaseDAO.java) | `findAll()` — 全表查询模板 | `SELECT * FROM {table}`（静态 `Statement`） | 被三个子类继承；`ListServlet` 间接使用 |
| [CreatorDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/CreatorDAO.java) | `findAll()`（继承）、`save()`、`update()`、`deleteById()`、`hasRelatedModels()` | SELECT * / INSERT / UPDATE / DELETE / SELECT COUNT(*) | `ListServlet`、`ManageServlet` |
| [ModelDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/ModelDAO.java) | `findAll()`（继承）、`save()`、`update()`、`deleteById()`、`findAllWithMetrics()`、`findAllWithMetricsByConditions()`、`findModelsByIds()`、`findByConditions()` | 单表静态查询 + 三表 JOIN（静态/动态）+ 带条件动态 SQL | `ListServlet`、`ManageServlet`、`CompareServlet` |
| [ModelMetricDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/ModelMetricDAO.java) | `findAll()`（继承）、`save()`、`update()`、`deleteById()` | SELECT * / INSERT / UPDATE / DELETE | `ListServlet`、`ManageServlet` |

**调用关系图**：

```
ListServlet ──→ CreatorDAO.findAll()
           ──→ ModelDAO.findAll()
           ──→ ModelMetricDAO.findAll()
           ──→ ModelDAO.findAllWithMetrics()

ManageServlet ──→ CreatorDAO.save/update/delete/hasRelatedModels
             ──→ ModelDAO.save/update/delete/findAllWithMetricsByConditions
             ──→ ModelMetricDAO.save/update/delete

CompareServlet ──→ ModelDAO.findModelsByIds()
```

#### 控制层（Servlet）

| 文件 | URL 映射 | 方法 | 核心职责 |
|------|---------|------|---------|
| [ListServlet.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/servlet/ListServlet.java) | `/list` | `doGet()` | 根据 `type` 参数分发到对应 DAO 并转发至 JSP |
| [ManageServlet.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/servlet/ManageServlet.java) | `/manage` | `doGet()` / `doPost()` | GET：返回 JSON（厂商列表、无指标模型、搜索）；POST：12 个 CRUD 操作 + SQL 回显 |
| [CompareServlet.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/servlet/CompareServlet.java) | `/compare` | `doGet()` | 接收逗号分隔 ID，校验 2~5 个，查询三表 JOIN，计算各指标最优值，转发对比页 |

#### 视图层（JSP + 静态资源）

| 文件 | 核心功能 | 依赖数据 |
|------|---------|---------|
| [index.html](file://F:/@work/JavaEE+MySQL/src/main/webapp/index.html) | 首页四张导航卡片（厂商、模型、指标、综合表） | 无 |
| [creators.jsp](file://F:/@work/JavaEE+MySQL/src/main/webapp/WEB-INF/views/creators.jsp) | 厂商表格 + 模态框 CRUD | `dataList`（`List<Creator>`） |
| [models.jsp](file://F:/@work/JavaEE+MySQL/src/main/webapp/WEB-INF/views/models.jsp) | 模型表格 + 模态框 CRUD | `dataList`（`List<Model>`） |
| [metrics.jsp](file://F:/@work/JavaEE+MySQL/src/main/webapp/WEB-INF/views/metrics.jsp) | 指标表格 + 模态框 CRUD | `dataList`（`List<ModelMetric>`） |
| [fullview.jsp](file://F:/@work/JavaEE+MySQL/src/main/webapp/WEB-INF/views/fullview.jsp) | 综合表（可折叠筛选面板、AJAX 搜索/排序、多选对比 + 摘要栏） | 初始 `dataList` + AJAX JSON |
| [compare.jsp](file://F:/@work/JavaEE+MySQL/src/main/webapp/WEB-INF/views/compare.jsp) | 横向对比表 + 最优值高亮 + 差异总结 | `models`（`List<ModelCompareVO>`）+ 7 个最优值 attribute |
| [style.css](file://F:/@work/JavaEE+MySQL/src/main/webapp/css/style.css) | 全局 UI 样式、表格、模态框、动画 | 无 |

---

## 三、SQL 代码深度解析（核心章节）

> 本章每一处 SQL 均结合项目实际代码，从**位置、作用、构造方式、参数传递、防注入措施**五个维度进行剖析。

---

### 3.1 数据库连接与配置

**配置来源**：[db.properties](file://F:/@work/JavaEE+MySQL/src/main/resources/db.properties)

```properties
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/llm_benchmark?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8&allowPublicKeyRetrieval=true
db.username=root
db.password=********
```

**加载流程**（[DBUtil.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/util/DBUtil.java) 第 15-27 行）：

```java
static {
    try (InputStream is = DBUtil.class.getClassLoader()
            .getResourceAsStream("db.properties")) {
        Properties props = new Properties();
        props.load(is);
        driver = props.getProperty("db.driver");
        url = props.getProperty("db.url");
        username = props.getProperty("db.username");
        password = props.getProperty("db.password");
        Class.forName(driver);   // 显式注册 MySQL 驱动
    }
}
```

**关键设计**：
- `characterEncoding=UTF-8`（**非** `utf8mb4`）：JDBC URL 中的 `characterEncoding` 参数使用的是 Java 运行时字符集名称，`utf8mb4` 是 MySQL 内部的字符集名字，JDBC 不认识。若错误使用会导致页面中文乱码。
- `allowPublicKeyRetrieval=true`：允许 MySQL 8.0 的 `caching_sha2_password` 认证插件从服务器获取公钥。
- **每次 `getConnection()` 都返回全新连接**，配合 DAO 层的 try-with-resources，连接生命周期与单次 SQL 操作绑定。

---

### 3.2 全表查询：BaseDAO.findAll()

**位置**：[BaseDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/BaseDAO.java) 第 13-29 行

**SQL**：
```sql
SELECT * FROM {table_name}
```

**Java 实现**：
```java
public List<T> findAll() {
    List<T> list = new ArrayList<>();
    String sql = "SELECT * FROM " + getTableName();
    try (Connection conn = DBUtil.getConnection();
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery(sql)) {
        while (rs.next()) {
            list.add(mapRow(rs));
        }
    }
    return list;
}
```

**静态拼接 vs Statement 的选择理由**：
- 此处使用 **`Statement`** 而非 `PreparedStatement`，因为 SQL 的表名来自子类的 `getTableName()` 硬编码返回（如 `return "creators"`），**不涉及任何用户输入**，无 SQL 注入风险。
- 使用 `Statement` 减少了一次预编译开销——该 SQL 结构极简，数据库优化器可直接执行。
- **模板方法模式**：`findAll()` 定义 JDBC 查询骨架（连接→执行→遍历→关闭），子类只需实现 `getTableName()` 和 `mapRow()`。

**执行场景与参数对照**：

| 请求 URL | DAO 调用 | 实际执行 SQL | 返回行数 |
|----------|---------|-------------|---------|
| `/list?type=creators` | `creatorDAO.findAll()` | `SELECT * FROM creators` | 19 |
| `/list?type=models` | `modelDAO.findAll()` | `SELECT * FROM models` | 64 |
| `/list?type=metrics` | `metricDAO.findAll()` | `SELECT * FROM model_metrics` | 62 |

---

### 3.3 三表 LEFT JOIN 查询

这是项目最核心的 SQL，服务于综合表初始加载、条件搜索、模型对比三个场景。

#### 3.3.1 无条件全量查询：findAllWithMetrics()

**位置**：[ModelDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/ModelDAO.java) 第 257-278 行

**SQL**：
```sql
SELECT m.*, c.creator_name,
       mt.artif_intel_idx, mt.artif_omni_idx,
       mt.terminal_bench_hard, mt.aa_omni_accuracy,
       mt.blended_price, mt.median_tokens_s,
       mt.latency_first_chunk, mt.total_response_time
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
ORDER BY c.creator_name, m.model_name
```

**Java 代码对照**：

```java
public List<ModelCompareVO> findAllWithMetrics() {
    List<ModelCompareVO> list = new ArrayList<>();
    String sql = "SELECT m.*, c.creator_name, mt.artif_intel_idx, ... " +
                 "FROM models m " +
                 "LEFT JOIN creators c ON m.creator_id = c.creator_id " +
                 "LEFT JOIN model_metrics mt ON m.model_id = mt.model_id " +
                 "ORDER BY c.creator_name, m.model_name";
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            list.add(mapToCompareVO(rs));
        }
    }
    return list;
}
```

**逐点解析**：

1. **两次 LEFT JOIN（非 INNER JOIN）**：
   - 第一次 `LEFT JOIN creators`：确保即使模型缺少厂商信息（虽然外键约束下不会发生）也能显示
   - 第二次 `LEFT JOIN model_metrics`：**关键——models 表 64 条记录，model_metrics 仅 62 条**，有 2 个模型无指标数据。使用 `LEFT JOIN` 确保无指标数据的模型依然出现在综合表中，其 8 个指标列返回 `NULL`，前端展示为 "—"
   - 若使用 `INNER JOIN`，那 2 个无指标的模型将被静默排除

2. **列选择**：`m.*` 一次获取 models 全部字段，避免逐一罗列。但额外显式写出 `c.creator_name` 和 `mt.*` 的 8 个指标列，清晰表达了"我们需要这些跨表数据"的意图

3. **排序**：`ORDER BY c.creator_name, m.model_name` — 按厂商名升序、同名厂商内按模型名升序，确保同一厂商的模型排列在一起，表格可读性好

4. **使用 `PreparedStatement`**：此处虽无参数，但统一使用 `PreparedStatement` 而非 `Statement` 是良好实践，未来若需添加参数无需改 API

5. **`mapToCompareVO()` 空值安全处理**（第 280-298 行）：
   ```java
   vo.setContextWindow(rs.getObject("context_window") != null
       ? rs.getInt("context_window") : null);
   vo.setArtifIntelIdx(rs.getBigDecimal("artif_intel_idx"));
   // BigDecimal 字段直接用 getBigDecimal，结果可为 null
   ```

**执行场景**：用户访问 `/list?type=fullview` → `ListServlet` 调用 → 转发 fullview.jsp 渲染全量数据表。

---

#### 3.3.2 动态条件 + 排序查询：findAllWithMetricsByConditions()

**位置**：[ModelDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/ModelDAO.java) 第 176-254 行

这是项目中**最复杂的 SQL 构建逻辑**，覆盖了所有动态条件场景。

**基础 SQL 骨架**：

```sql
SELECT m.*, c.creator_name,
       mt.artif_intel_idx, mt.artif_omni_idx,
       mt.terminal_bench_hard, mt.aa_omni_accuracy,
       mt.blended_price, mt.median_tokens_s,
       mt.latency_first_chunk, mt.total_response_time
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE 1=1
```

**「WHERE 1=1」技巧解析**：
- 这是一个经典动态 SQL 模式——`WHERE 1=1` 永远为 `TRUE`，使得后续所有条件可以统一用 `AND ...` 拼接，无需判断"当前条件是否是第一个"来决定使用 `WHERE` 还是 `AND`。
- 数据库优化器会自动忽略 `1=1` 这个恒真条件，不会产生性能开销。

##### （A）厂商多选：动态 IN 子句

```java
List<String> creatorIds = (List<String>) params.get("creatorIds");
if (creatorIds != null && !creatorIds.isEmpty()) {
    sql.append(" AND m.creator_id IN (");
    for (int i = 0; i < creatorIds.size(); i++) {
        sql.append(i > 0 ? ",?" : "?");    // 首个 ? 不加逗号，后续加逗号
        paramValues.add(creatorIds.get(i));
    }
    sql.append(")");
}
```

**生成示例**（勾选 OpenAI + Anthropic）：
```sql
AND m.creator_id IN (?, ?)    -- 参数：'oai', 'ant'
```

**安全机制**：每个厂商 ID 通过 `paramValues.add()` 进入参数列表，由 `ps.setObject()` 设置，**杜绝 SQL 注入**。占位符数量与传入 ID 数量严格一致，不会出现 `IN (1,2,3) --` 这样的注入点。

##### （B）开源状态筛选：静态常量拼接

```java
String isOpenSource = (String) params.get("isOpenSource");
if ("open".equals(isOpenSource)) {
    sql.append(" AND m.is_open_source = 1");
} else if ("closed".equals(isOpenSource)) {
    sql.append(" AND m.is_open_source = 0");
}
```

**为何不用占位符**：`"open"` / `"closed"` 是前端下拉框的固定枚举值，映射为 `= 1` 和 `= 0` 常量，不来自用户自由输入。直接拼接常量**安全且更高效**（少一次参数绑定）。

##### （C）范围条件：通用 addRangeCondition 方法

```java
private void addRangeCondition(StringBuilder sql, List<Object> params,
                               String column, Object min, Object max) {
    if (min != null && !min.toString().trim().isEmpty()) {
        sql.append(" AND ").append(column).append(" >= ?");
        params.add(parseNumber(min));
    }
    if (max != null && !max.toString().trim().isEmpty()) {
        sql.append(" AND ").append(column).append(" <= ?");
        params.add(parseNumber(max));
    }
}
```

**覆盖的 6 组范围字段**：

| 调用 | SQL 列 | 前端输入 |
|------|--------|---------|
| `addRangeCondition(sql, params, "m.context_window", min, max)` | `m.context_window` | 上下文窗口 Min/Max |
| `addRangeCondition(sql, params, "mt.artif_intel_idx", min, max)` | `mt.artif_intel_idx` | 智力指数 Min/Max |
| `addRangeCondition(sql, params, "mt.blended_price", min, max)` | `mt.blended_price` | 价格 Min/Max |
| `addRangeCondition(sql, params, "mt.median_tokens_s", min, max)` | `mt.median_tokens_s` | 吞吐量 Min/Max |
| `addRangeCondition(sql, params, "m.release_date", min, max)` | `m.release_date` | 发布日期范围 |

**parseNumber() 类型自适应**（第 366-375 行）：
```java
private Object parseNumber(Object val) {
    if (val instanceof Number) return val;
    String s = val.toString().trim();
    try {
        if (s.contains(".")) return Double.parseDouble(s);   // 小数
        return Integer.parseInt(s);                           // 整数
    } catch (NumberFormatException e) {
        return s;   // 日期字符串等，由 JDBC 驱动自行处理
    }
}
```

此方法自动识别整数、小数、日期字符串，避免将金额 `"2.46"` 误解析为整数而导致精度丢失。

**生成示例**（智力 40~60 且价格 ≤ 2.0）：
```sql
AND mt.artif_intel_idx >= ?    -- 参数：40 (Integer)
AND mt.artif_intel_idx <= ?    -- 参数：60 (Integer)
AND mt.blended_price <= ?      -- 参数：2.0 (Double)
```

##### （D）擅长领域模糊查询

```java
String fieldExpertise = (String) params.get("fieldExpertise");
if (fieldExpertise != null && !fieldExpertise.trim().isEmpty()) {
    sql.append(" AND m.field_expertise LIKE ?");
    paramValues.add("%" + fieldExpertise.trim() + "%");
}
```

**生成示例**（搜索"代码"）：
```sql
AND m.field_expertise LIKE ?    -- 参数：'%代码%'
```

- 通配符 `%` 在 Java 端拼接后存入参数列表，不能在 SQL 中写死 `%?%`（JDBC 不支持此种占位符写法）
- 用户输入 `fieldExpertise.trim()` 存在于参数值内部，由 `PreparedStatement` 自动转义，**防止 LIKE 注入**

##### （E）排序拼接

```java
if (orderBy != null && !orderBy.trim().isEmpty()) {
    sql.append(" ORDER BY ").append(orderBy);
} else {
    sql.append(" ORDER BY c.creator_name, m.model_name");
}
```

**示例**：
```sql
ORDER BY mt.artif_intel_idx DESC
ORDER BY m.release_date ASC
```

**安全考量**：`orderBy` 的值来自前端下拉框的固定选项（`mt.artif_intel_idx ASC`、`mt.blended_price DESC` 等），不来自用户自由输入，因此可以安全拼接。若需更高安全级别，可在 Servlet 端对 `orderBy` 做白名单校验。

##### 完整 SQL 合成示例

**输入条件**：厂商 = OpenAI + DeepSeek，开源状态 = 开源，智力指数 ≥ 50，按价格升序

**合成的 SQL**（参数绑定后）：
```sql
SELECT m.*, c.creator_name,
       mt.artif_intel_idx, mt.artif_omni_idx,
       mt.terminal_bench_hard, mt.aa_omni_accuracy,
       mt.blended_price, mt.median_tokens_s,
       mt.latency_first_chunk, mt.total_response_time
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE 1=1
  AND m.creator_id IN ('oai', 'deep')
  AND m.is_open_source = 1
  AND mt.artif_intel_idx >= 50
ORDER BY mt.blended_price ASC
```

**参数设置**（第 239-243 行）：
```java
try (Connection conn = DBUtil.getConnection();
     PreparedStatement ps = conn.prepareStatement(sql.toString())) {
    for (int i = 0; i < paramValues.size(); i++) {
        ps.setObject(i + 1, paramValues.get(i));
        // setObject 自动根据 Java 类型选择合适的 JDBC 类型
    }
}
```

**执行场景**：用户在综合表调整筛选条件后点击"搜索"→ `fullview.jsp` 中的 `searchFullview()` 发起 AJAX → `ManageServlet.doGet()?action=searchFullview` → 调用此方法 → 返回 JSON → `renderFullview(data)` 动态更新表格。

---

#### 3.3.3 按 ID 批量查询：findModelsByIds()

**位置**：[ModelDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/ModelDAO.java) 第 302-351 行

**SQL 骨架**：
```sql
SELECT m.*, c.creator_name,
       mt.artif_intel_idx, mt.artif_omni_idx, ... -- 同 3.3.1 的 SELECT 列
FROM models m
LEFT JOIN creators c ON m.creator_id = c.creator_id
LEFT JOIN model_metrics mt ON m.model_id = mt.model_id
WHERE m.model_id IN (?, ?, ?)
```

**Java 代码（IN 子句动态构建）**：
```java
StringBuilder sql = new StringBuilder("SELECT m.*, c.creator_name, ... FROM models m " +
    "LEFT JOIN creators c ON ... LEFT JOIN model_metrics mt ON ... WHERE m.model_id IN (");
for (int i = 0; i < ids.size(); i++) {
    sql.append(i > 0 ? ",?" : "?");
}
sql.append(")");

try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
    for (int i = 0; i < ids.size(); i++) {
        ps.setString(i + 1, ids.get(i));
    }
}
```

**执行示例**（对比 GPT-5.5 xhigh、Claude Opus 4.7、DeepSeek V4 Pro Max）：
```sql
WHERE m.model_id IN (?, ?, ?)    -- 参数：'gpt55xh', 'cl47mx', 'dsv4pm'
```

**与 findAllWithMetrics 的关系**：SELECT 部分和 JOIN 结构完全相同，仅 WHERE 条件不同——这是 **SQL 复用模式**，确保综合表和对比页展示的数据口径一致。

**执行场景**：用户勾选 2~5 个模型 → `CompareServlet` 接收 `ids` 参数 → 解析后调用此方法 → 返回 `List<ModelCompareVO>` → 存入 request 转发 compare.jsp。

---

### 3.4 单表 CRUD SQL

#### 3.4.1 厂商 INSERT

**位置**：[CreatorDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/CreatorDAO.java) 第 27-36 行

```sql
INSERT INTO creators (creator_id, creator_name, description) VALUES (?, ?, ?)
```

```java
ps.setString(1, c.getCreatorId());
ps.setString(2, c.getCreatorName());
ps.setString(3, c.getDescription());   // 可为 null，setString 容忍 null
ps.executeUpdate();
```

**校验逻辑**（Servlet 端）：
- `creator_id` 正则 `[a-zA-Z0-9]{1,10}` — 限 1~10 位字母数字
- `creator_name` 非空
- 若主键重复，MySQL 抛出 `Duplicate entry`，ManageServlet 捕获并返回友好提示

#### 3.4.2 厂商 UPDATE

```sql
UPDATE creators SET creator_name = ?, description = ? WHERE creator_id = ?
```

**设计决策**：主键 `creator_id` 不参与 UPDATE，仅作 WHERE 条件。这遵循了"主键不可变"原则，同时避免级联更新 `models` 表的外键（虽然外键定义了 `ON UPDATE CASCADE`）。

#### 3.4.3 厂商 DELETE（含前置检查）

```sql
-- 前置检查（hasRelatedModels）
SELECT COUNT(*) FROM models WHERE creator_id = ?
-- 若 count > 0，阻止删除

-- 实际删除
DELETE FROM creators WHERE creator_id = ?
```

**外键协同**：虽然在 Java 层做了前置检查，数据库层也有 `ON DELETE RESTRICT` 约束兜底——若有人绕过 Java 代码直接执行 SQL，外键约束同样会阻止删除。

---

#### 3.4.4 模型 INSERT（可空参数处理）

**位置**：[ModelDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/ModelDAO.java) 第 36-54 行

```sql
INSERT INTO models (model_id, model_name, creator_id, context_window,
                    is_open_source, release_date, field_expertise,
                    version_upgrade_note)
VALUES (?, ?, ?, ?, ?, ?, ?, ?)
```

**可空字段的参数设置策略**：

```java
// 普通 String：直接用 setString，null 也合法
ps.setString(1, m.getModelId());

// 可空 Integer：包装类型 + setNull
setInt(ps, 4, m.getContextWindow());

// 可空 Boolean：包装类型 + setNull
setBoolean(ps, 5, m.getIsOpenSource());

// 可空 Date：显式判断
if (m.getReleaseDate() != null) {
    ps.setDate(6, m.getReleaseDate());
} else {
    ps.setNull(6, java.sql.Types.DATE);
}

// 辅助方法实现（第 377-391 行）
private void setInt(PreparedStatement ps, int idx, Integer val) throws SQLException {
    if (val != null) ps.setInt(idx, val);
    else ps.setNull(idx, java.sql.Types.INTEGER);
}
private void setBoolean(PreparedStatement ps, int idx, Boolean val) throws SQLException {
    if (val != null) ps.setBoolean(idx, val);
    else ps.setNull(idx, java.sql.Types.BOOLEAN);
}
```

**为什么不用 `ps.setObject(idx, null)`**：JDBC 规定 `setObject(idx, null)` 在部分驱动实现中可能无法正确推断 SQL 类型，显式传递 `java.sql.Types.XXX` 可确保驱动生成正确的 `NULL` 字面量。

---

#### 3.4.5 模型 DELETE（级联删除）

```sql
DELETE FROM models WHERE model_id = ?
```

**级联效果**：外键 `model_metrics_ibfk_1` 定义了 `ON DELETE CASCADE`，因此只需删除 `models` 表的记录，`model_metrics` 表中对应行会被数据库自动删除。Java 层无需额外操作，但 ManageServlet 返回提示时会说明"关联的性能指标已同步删除"。

---

#### 3.4.6 指标 INSERT（BigDecimal 可空处理）

**位置**：[ModelMetricDAO.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/dao/ModelMetricDAO.java) 第 33-48 行

```sql
INSERT INTO model_metrics (model_id, artif_intel_idx, artif_omni_idx,
       terminal_bench_hard, aa_omni_accuracy, blended_price,
       median_tokens_s, latency_first_chunk, total_response_time)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
```

```java
ps.setString(1, m.getModelId());
setBigDecimal(ps, 2, m.getArtifIntelIdx());
// ... 其余 7 个 setBigDecimal

// 辅助方法（第 79-85 行）
private void setBigDecimal(PreparedStatement ps, int idx, java.math.BigDecimal val)
        throws SQLException {
    if (val != null) {
        ps.setBigDecimal(idx, val);
    } else {
        ps.setNull(idx, java.sql.Types.DECIMAL);
    }
}
```

**业务校验**（ManageServlet 第 396-401 行）：
```java
if (m.getAaOmniAccuracy() != null &&
    (m.getAaOmniAccuracy().compareTo(BigDecimal.ZERO) < 0 ||
     m.getAaOmniAccuracy().compareTo(new BigDecimal("100")) > 0)) {
    writeJson(resp, false, "AA-Omni准确率必须在0~100之间");
    return;
}
```
此校验在数据进入 DAO 前执行，防止无效数据提交到数据库。

---

### 3.5 SQL 回显辅助方法

**位置**：[ManageServlet.java](file://F:/@work/JavaEE+MySQL/src/main/java/com/benchmark/servlet/ManageServlet.java) 第 509-522 行

```java
private String sqlStr(String s)       // "hello" → 'hello'，单引号转义 ''''
private String sqlNum(Number n)       // 3.14 → 3.14，null → NULL
private String sqlBool(Boolean b)     // true → 1，false → 0，null → NULL
private String sqlDate(java.sql.Date d)  // 2026-04-23 → '2026-04-23'
```

这些方法并**不用于实际 SQL 执行**（执行都走 `PreparedStatement`），而是为 CRUD 操作生成一条**可读的 SQL 字符串**通过 JSON 返回前端，帮助用户理解后台实际执行了什么操作。

**示例输出**（新增模型）：
```json
{
  "success": true,
  "message": "模型添加成功",
  "sql": "INSERT INTO models (model_id, model_name, ...) VALUES ('gpt55xh', 'GPT-5.5 (xhigh)', 'oai', 922000, 0, '2026-04-23', '通用推理、代码生成、长文本分析', 'xhigh配置')"
}
```

---

### 3.6 SQL 使用策略总结

| 场景 | SQL 构造方式 | 使用 API | 防注入机制 |
|------|------------|---------|-----------|
| 全表查询 `SELECT * FROM table` | 静态字符串（表名来自子类） | `Statement` | 不涉及用户输入，零风险 |
| 无条件 JOIN 查询 | 静态字符串 | `PreparedStatement` | 无参数，遵循最佳实践 |
| 带条件查询（IN / LIKE / 范围） | `StringBuilder` 动态拼接骨架 + `List<Object>` 收集参数 | `PreparedStatement` + `setObject` | 所有用户输入通过 `?` 占位符传递 |
| 排序 `ORDER BY` | 直接拼接字符串 | `PreparedStatement` | 值来自前端固定下拉选项，非自由输入 |
| CRUD 写入 | 静态 SQL 模板 + `?` 占位符 | `PreparedStatement` + `setXxx` / `setNull` | 纯参数化查询 |
| 开源状态 `= 1` / `= 0` | 直接拼接常量 | `PreparedStatement` | 枚举值映射，非用户自由输入 |

---

## 四、前后端交互说明

### 4.1 服务端渲染（ListServlet）

```
GET /list?type=fullview
   → ListServlet.doGet()
   → modelDAO.findAllWithMetrics()    // 执行三表 LEFT JOIN
   → req.setAttribute("dataList", list)
   → req.getRequestDispatcher("fullview.jsp").forward(req, resp)
   → fullview.jsp 中用 <c:forEach items="${dataList}" var="m"> 迭代渲染
```

**关键点**：`ListServlet` 仅处理 GET 请求的页面分发，不做 CRUD 操作。它利用 `BaseDAO.findAll()` 的模板方法统一加载初始数据。

### 4.2 AJAX 异步交互（ManageServlet）

```
GET /manage?action=searchFullview&creatorIds=oai&artifIntelIdxMin=50&orderBy=mt.blended_price ASC
   → ManageServlet.doGet()
   → 解析所有查询参数到 Map<String, Object>
   → modelDAO.findAllWithMetricsByConditions(params, orderBy)
   → 手动拼接 JSON 字符串
   → resp.getWriter().write(json)
```

**参数解析细节**（ManageServlet 第 139-159 行）：
```java
String[] creatorIds = req.getParameterValues("creatorIds");  // 多值参数用 getParameterValues
if (creatorIds != null && creatorIds.length > 0) {
    params.put("creatorIds", Arrays.asList(creatorIds));
}
addParam(params, req, "contextWindowMin");   // 辅助方法：非空才放入 Map
addParam(params, req, "contextWindowMax");
```

`getParameterValues()` 处理前端 `?creatorIds=oai&creatorIds=ant` 这种同名多值参数，返回 `String[]`。

### 4.3 JSON 手动构建策略

**为何不用 Jackson/Gson**：保持项目轻量，无第三方依赖，且 JSON 结构简单（最多不过是对象数组），手动拼接足够清晰。

**escapeJson() 转义**（第 493-500 行）：
```java
private String escapeJson(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\")      // 反斜杠转义
            .replace("\"", "\\\"")      // 双引号转义
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
}
```

覆盖 JSON 规范要求的五个转义序列，防止模型名称或描述中的特殊字符破坏 JSON 结构。

### 4.4 前端 AJAX 流程（综合表搜索）

```
用户修改筛选条件 → 点击"搜索"按钮
    ↓
searchFullview() 函数：
    1. 读取表单各字段值
    2. 构建 URLSearchParams（含 creatorIds 多值、范围参数、orderBy）
    3. fetch('/manage?action=searchFullview&' + params.toString())
    ↓
收到 JSON 响应：
    1. renderFullview(data) 动态生成表格 <tr>
    2. 恢复已选模型的勾选状态（selectedModelIds Set 未清空）
    3. 更新 modelDataMap（增量添加新出现的模型名）
```

**已选状态持久化**：`selectedModelIds` 是一个 JavaScript `Set`，搜索/排序/重置操作**永不**修改它，仅在用户勾选/取消勾选时同步。这确保了"边选边搜"的流畅体验。

### 4.5 对比页交互

```
用户在综合表勾选 3 个模型 → 点击"开始对比"
    ↓
startCompare()：
    sessionStorage.setItem('compareExecuted', 'true')
    window.location.href = '/compare?ids=gpt55xh,cl47mx,dsv4pm&source=fullview'
    ↓
CompareServlet：
    1. 解析 ids → List<String>
    2. modelDAO.findModelsByIds(ids) → 执行 SQL
    3. 计算 7 个最优值（maxCtx, maxIntel, minPrice 等）
    4. forward → compare.jsp
    ↓
compare.jsp 渲染：
    - 横向并列表格 + 最优值绿底高亮
    - 差异总结面板（智力最高、性价比最高、综合推荐）
    ↓
点击"返回综合表" → fullview.jsp 检测 sessionStorage 标记 → 清空勾选状态
```

---

## 五、答辩备料要素

### 5.1 可演示 SQL 实例列表

| 编号 | SQL 类型 | 用途 | 演示方式 |
|------|---------|------|---------|
| 1 | `SELECT * FROM creators` | 全表查询（厂商 19 条） | 访问 `/list?type=creators` |
| 2 | `SELECT * FROM models` | 全表查询（模型 64 条） | 访问 `/list?type=models` |
| 3 | `SELECT * FROM model_metrics` | 全表查询（指标 62 条） | 访问 `/list?type=metrics` |
| 4 | 三表 LEFT JOIN + ORDER BY | 综合表初始加载（64 行，含 2 条无指标） | 访问 `/list?type=fullview` |
| 5 | 三表 JOIN + `WHERE creator_id IN` + 范围条件 + `ORDER BY` | 条件筛选（如 OpenAI+DeepSeek，智力≥50，按价格升序） | 综合表筛选面板操作 |
| 6 | 三表 JOIN + `WHERE model_id IN (?,?,?)` | 对比查询（2~5 个模型） | 勾选后点击"开始对比" |
| 7 | `INSERT INTO creators VALUES (?,?,?)` | 新增厂商（含回显） | 厂商管理页新增操作 |
| 8 | `DELETE FROM models WHERE model_id=?`（级联删指标） | 删除模型 | 模型管理页删除操作 |
| 9 | `SELECT COUNT(*) FROM models WHERE creator_id=?` | 删除前置检查 | 删除有模型的厂商触发提示 |
| 10 | `UPDATE model_metrics SET ... WHERE model_id=?` | 更新指标 | 指标管理页编辑操作 |

### 5.2 模块职责总结表（适合 PPT 速查）

| 层级 | 模块 | 一句话职责 | 关键设计 |
|------|------|-----------|---------|
| 工具 | `DBUtil` | 连接工厂，静态加载配置 | `characterEncoding=UTF-8` 避坑 |
| 实体 | `Creator` | 厂商 3 字段映射 | 全 String，主键为可读短 ID |
| 实体 | `Model` | 模型 8 字段映射 | `Integer`/`Boolean` 包装类型处理 NULL |
| 实体 | `ModelMetric` | 指标 9 字段映射 | `BigDecimal` 精确数值 |
| 实体 | `ModelCompareVO` | 三表 JOIN 视图 | 聚合模型+厂商名+8 个指标 |
| DAO | `BaseDAO<T>` | `SELECT *` 模板 | 模板方法模式，`Statement` 安全 |
| DAO | `CreatorDAO` | 厂商 CRUD + 关联检查 | `hasRelatedModels()` 前置校验 |
| DAO | `ModelDAO` | 模型 CRUD + 3 种 JOIN 查询 + 动态筛选 | `addRangeCondition` 通用方法 |
| DAO | `ModelMetricDAO` | 指标 CRUD | `setBigDecimal` / `setNull(DECIMAL)` |
| Servlet | `ListServlet` | 页面分发（`/list`） | GET 仅查询，无副作用 |
| Servlet | `ManageServlet` | CRUD + AJAX 搜索 API（`/manage`） | GET 查询/ POST 写操作，手动 JSON |
| Servlet | `CompareServlet` | 对比页 + 最优值计算（`/compare`） | Java Stream 计算 max/min |

### 5.3 设计决策答辩要点

#### 决策 1：指标表与模型表分离（1:1 而非合并）

**问题**：为何不将 `model_metrics` 的 8 个指标列直接放在 `models` 表中？

**理由**：
- **职责分离**：模型基础信息（名称、厂商、发布日期）与性能评测数据（智力指数、价格、延迟）属于不同关注域，独立表便于维护
- **可空字段隔离**：62/64 个模型有指标数据，2 个模型缺失指标。若合并在一表，大量 NULL 列会降低查询效率和可读性
- **独立索引**：`artif_intel_idx` 和 `blended_price` 上的索引仅服务于排序/范围查询，不影响 `models` 表主查询性能
- **扩展性**：未来新增指标时只需 ALTER `model_metrics` 表，不涉及 `models` 表

#### 决策 2：包装类型处理可空字段

**问题**：为什么 `context_window` 用 `Integer` 而非 `int`？

**理由**：
- 数据库列定义为 `INT NULL`，Java 基本类型 `int` 无法表达 `null`
- `rs.getInt("col")` 在数据库值为 NULL 时返回 0，这会与真实的 `context_window=0` 混淆
- 使用 `rs.getObject() != null ? rs.getInt() : null` 精确区分"值为 0"与"值不存在"
- 同样逻辑适用于 `is_open_source`（`Boolean` vs `boolean`）——NULL 表示"开源状态未知"

#### 决策 3：Statement vs PreparedStatement 的选择

| 场景 | API | 理由 |
|------|-----|------|
| `SELECT * FROM table` | `Statement` | 无参数、无用户输入、SQL 极简，Statement 足够且少一次预编译 |
| 所有带 `?` 的 SQL | `PreparedStatement` | 参数化查询防注入 + 类型安全 |
| CRUD 静态 SQL 模板 | `PreparedStatement` | 统一风格，便维护 |

#### 决策 4：LEFT JOIN 而非 INNER JOIN

核心原因：64 个模型中有 2 个缺少 `model_metrics` 记录。`INNER JOIN` 会静默排除这 2 个模型，用户可能在综合表中看不到它们而感到困惑。`LEFT JOIN` 保留所有模型，指标为 NULL 的行在前端显示 "—"，用户可明确感知数据缺失。

#### 决策 5：WHERE 1=1 的动态 SQL 策略

`WHERE 1=1` 使后续所有条件统一使用 `AND ...` 前缀，无需维护"是否为首个条件"的标志位，代码简洁且不易出错。数据库优化器会消除 `1=1` 恒真条件，无性能影响。

#### 决策 6：手动 JSON 拼接而非引入库

项目 JSON 结构简单（对象 + 基本类型数组），手动 `StringBuilder` 拼接避免了 Jackson/Gson 的依赖引入和类加载开销，同时 `escapeJson()` 覆盖了所有转义需求。此决策体现了"按需选择依赖"的工程原则。

---

## 六、部署与运行

| 环境项 | 要求 |
|--------|------|
| JDK | 21+ |
| Tomcat | 10.1+（必须支持 Jakarta EE 5.0） |
| MySQL | 8.0+（先执行 `llm_benchmark.sql` 初始化） |
| Maven | 3.x（使用 `.mvn/settings.xml` 阿里云镜像） |
| JDBC 驱动 | MySQL Connector/J 8.0.33（勿使用 9.x，API 不兼容） |

**关键避坑**：
1. JDBC URL 中 `characterEncoding=UTF-8`，不能写成 `utf8mb4`
2. 必须使用 `com.mysql.cj.jdbc.Driver`（8.x 驱动），而非旧版 `com.mysql.jdbc.Driver`
3. Tomcat 必须是 10.1+（`jakarta.servlet.*` 而非 `javax.servlet.*`）

---

*本文档基于项目 v1.0 源代码编写，所有 SQL 语句、Java 代码片段均来自实际文件，可直接用于代码审查与技术答辩。*
