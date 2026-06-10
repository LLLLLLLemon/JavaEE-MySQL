# 大模型性能对比评测系统（LLM Benchmark System）

基于 **Jakarta EE + MySQL** 的大模型多维度评估平台，支持厂商浏览、模型查询、性能指标筛选与多模型对比分析。

---

## 一、技术栈

| 组件 | 版本 | 说明 |
|------|------|------|
| Jakarta EE | Servlet 5.0 + JSP 3.0 | Web 层标准 |
| Java | 21 | LTS 版本 |
| 服务器 | Tomcat 10.1+ | Jakarta EE 兼容容器 |
| 数据库 | MySQL 8.0 | 关系型数据库 |
| JDBC 驱动 | MySQL Connector/J 8.0.33 | 稳定版 |
| 构建工具 | Maven 3.x | 依赖与构建管理 |
| 前端 | HTML + CSS + JSTL + JavaScript | 纯服务端渲染 + AJAX |
| JSON | 手动拼接 | 无第三方 JSON 库 |

---

## 二、快速启动

### 2.1 初始化数据库

```bash
mysql -u root -p < llm_benchmark.sql
```

验证数据：
```sql
USE llm_benchmark;
SELECT COUNT(*) AS 厂商数 FROM creators;   -- 19
SELECT COUNT(*) AS 模型数 FROM models;      -- 64
SELECT COUNT(*) AS 指标数 FROM model_metrics; -- 62
```

### 2.2 配置数据库连接

编辑 `src/main/resources/db.properties`，修改密码：

```properties
db.password=你的MySQL密码
```

### 2.3 IDEA 中配置 Maven

1. **设置 → Build, Execution, Deployment → Build Tools → Maven**
2. 勾选 **Override**，选择 `.mvn/settings.xml`
3. 确认 Local repository 为 `F:\maven-repo`
4. 右键 `pom.xml` → **Maven → Reload project**

### 2.4 部署运行

1. **配置 Tomcat 10.1+**：Run → Edit Configurations → 添加 Tomcat Server
2. **部署工件**：选择 `llm-benchmark:war exploded`
3. **启动**：点击 Run
4. **访问**：http://localhost:8080/llm-benchmark/

---

## 三、页面导航

| 路径 | 说明 | 功能 |
|------|------|------|
| `/` | 首页 | 四个导航卡片入口 |
| `/list?type=creators` | 厂商列表（19 条） | 查看/新增/编辑/删除厂商 |
| `/list?type=models` | 模型库（64 条） | 查看/新增/编辑/删除模型 |
| `/list?type=metrics` | 性能指标（62 条） | 查看/新增/编辑/删除指标 |
| `/list?type=fullview` | 综合表 | 三表 JOIN 一体化视图，支持条件筛选+排序+模型对比 |
| `/compare?ids=id1,id2&source=fullview` | 对比页面 | 2~5 个模型的横向对比分析，含差异总结 |

---

## 四、项目结构

```
src/main/
├── java/com/benchmark/
│   ├── util/
│   │   └── DBUtil.java              # 数据库连接工具
│   ├── entity/
│   │   ├── Creator.java             # 厂商实体（creators 表）
│   │   ├── Model.java               # 模型实体（models 表）
│   │   ├── ModelMetric.java         # 指标实体（model_metrics 表）
│   │   └── ModelCompareVO.java      # 综合表/对比页视图对象
│   ├── dao/
│   │   ├── BaseDAO.java             # 通用 DAO 抽象基类（模板方法模式）
│   │   ├── CreatorDAO.java          # 厂商 CRUD
│   │   ├── ModelDAO.java            # 模型 CRUD + 高级查询 + 多表 JOIN + 对比查询
│   │   └── ModelMetricDAO.java      # 指标 CRUD
│   └── servlet/
│       ├── ListServlet.java         # 静态列表页控制器
│       ├── ManageServlet.java       # CRUD + 综合表 AJAX 搜索 API
│       └── CompareServlet.java      # 对比页控制器
├── resources/
│   └── db.properties                # 数据库连接配置
└── webapp/
    ├── WEB-INF/
    │   ├── web.xml                  # Jakarta EE 5.0 部署描述
    │   └── views/
    │       ├── creators.jsp         # 厂商管理页
    │       ├── models.jsp           # 模型管理页
    │       ├── metrics.jsp          # 指标管理页
    │       ├── fullview.jsp         # 综合表（含筛选/排序/对比摘要栏）
    │       └── compare.jsp          # 对比分析页
    ├── css/style.css                # 全局样式
    └── index.html                   # 首页导航
```

---

## 五、数据库设计

### 5.1 三表关联关系

```
creators（厂商）──1:N──→ models（模型）──1:1──→ model_metrics（指标）
```

- **creators ← models**：通过 `creator_id` 外键关联，`ON DELETE RESTRICT`（有模型时禁止删除厂商）
- **models ← model_metrics**：通过 `model_id` 外键关联，`ON DELETE CASCADE`（删模型时级联删指标）

### 5.2 核心表结构

详见 [项目说明文档.md](./项目说明文档.md) 第三章"数据库设计"。

---

## 六、核心功能

### 6.1 综合表（fullview）

- 三表 JOIN 查询，展示厂商+模型+指标一体化视图
- 支持多条件筛选（厂商、开源状态、上下文窗口、智力指数、价格、吞吐量、发布日期范围）
- 支持多种排序（上下文窗口、智力指数、价格、吞吐量、发布日期升序/降序）
- 模型多选对比：勾选 2~5 个模型，点击"开始对比"跳转对比页
- **已选模型持久化**：搜索/筛选/排序/重置等操作**不会**清空勾选状态
- **已选模型摘要栏**：实时显示已选模型标签，支持逐个移除，可折叠

### 6.2 模型对比（compare）

- 选中模型的横向并列表格展示（含最优值高亮）
- 自动生成差异总结：智力最高、性价比最高、吞吐量最高、上下文最大、开源/闭源统计、综合推荐

### 6.3 CRUD 管理

厂商、模型、指标三表的增删改查，均通过模态框弹窗操作，支持实时 SQL 回显。

---

## 七、常见问题

**Q: 页面无数据？**
- 确认 MySQL 已启动并执行了 `llm_benchmark.sql`
- 检查 `db.properties` 中密码是否正确
- **JDBC URL 中 `characterEncoding` 必须使用 `UTF-8`（不是 `utf8mb4`）**
- 清理 Tomcat work 目录后重启

**Q: 404 错误？**
- 确认 Tomcat 10.1+ 已正确配置
- 检查项目访问路径是否正确

**Q: Maven 依赖下载失败？**
- 确认 `.mvn/settings.xml` 已配置阿里云镜像
- 检查本地仓库目录权限
- 在 IDEA 中刷新 Maven 项目

**Q: 综合表搜索后模型勾选丢失？**
- 本系统已修复此问题：搜索/筛选/排序/重置**永不**清空 `selectedModelIds`
- 仅在点击"开始对比"并跳转后，返回时自动清空
