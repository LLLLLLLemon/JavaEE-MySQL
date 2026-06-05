# 大模型性能对比评测系统

基于 **Jakarta EE + MySQL** 的大模型多维度评估平台，支持在 Web 页面浏览厂商、模型和性能指标数据。

## 技术栈

| 组件 | 版本 |
|------|------|
| Jakarta EE | Servlet 5.0 + JSP 3.0 |
| Java | 21 |
| 服务器 | Tomcat 10.1.53 |
| 数据库 | MySQL 8.0 |
| 构建工具 | Maven |
| 前端 | HTML + CSS + JSTL |

## 快速启动

### 1. 初始化数据库

```bash
mysql -u root -p < llm_benchmark.sql
```

验证：
```sql
USE llm_benchmark;
SELECT COUNT(*) FROM creators;  -- 19
SELECT COUNT(*) FROM models;    -- 64
```

### 2. 配置数据库连接

编辑 `src/main/resources/db.properties`，修改数据库密码：

```properties
db.password=你的MySQL密码
```

### 3. IDEA 中配置 Maven

1. **设置 → Build, Execution, Deployment → Build Tools → Maven**
2. 勾选 **Override**，选择 `.mvn/settings.xml`
3. 确认 Local repository 显示为 `F:\maven-repo`
4. 点击 **Apply → OK**
5. 右键 `pom.xml` → **Maven → Reload project**

### 4. 部署运行

1. **配置 Tomcat 10.1.53**：Run → Edit Configurations → 添加 Tomcat Server
2. **部署工件**：选择 `llm-benchmark:war exploded`
3. **启动**：点击 Run
4. **访问**：http://localhost:8080/llm-benchmark/

## 页面导航

| 路径 | 说明 |
|------|------|
| `/` | 首页（导航卡片） |
| `/list?type=creators` | 厂商列表（19条） |
| `/list?type=models` | 模型库（64条） |
| `/list?type=metrics` | 性能指标（62条） |

## 项目结构

```
F:\@work\JavaEE+MySQL/
├── pom.xml                     # Maven 构建配置
├── llm_benchmark.sql           # 数据库初始化脚本
├── .mvn/settings.xml           # Maven 设置（阿里云镜像）
├── src/main/
│   ├── java/com/benchmark/
│   │   ├── entity/             # 实体类（Creator, Model, ModelMetric）
│   │   ├── dao/                # 数据访问层（BaseDAO + 3个具体DAO）
│   │   ├── servlet/            # 控制器（ListServlet）
│   │   └── util/               # 工具类（DBUtil）
│   ├── resources/
│   │   └── db.properties       # 数据库配置
│   └── webapp/
│       ├── WEB-INF/
│       │   ├── views/          # JSP 页面（3个）
│       │   └── web.xml         # Web 配置
│       ├── css/style.css       # 样式
│       └── index.html          # 首页
```

## 常见问题

**Q: 页面无数据？**
- 确认 MySQL 已启动并执行了 `llm_benchmark.sql`
- 检查 `db.properties` 中密码是否正确
- **JDBC URL 中 `characterEncoding` 必须使用 `UTF-8`（不是 `utf8mb4`）**
- 查看 IDEA Run 窗口是否有红色错误
- 清理 Tomcat work 目录后重启

**Q: 404 错误？**
- 确认 Tomcat 10.1.53 已正确配置
- 检查访问 URL 路径是否正确

**Q: Maven 依赖下载失败？**
- 确认 `.mvn/settings.xml` 已配置阿里云镜像
- 检查 `F:\maven-repo` 目录权限
- 在 IDEA 中刷新 Maven 项目
