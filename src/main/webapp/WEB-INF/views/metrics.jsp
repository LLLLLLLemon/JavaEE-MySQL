<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>性能指标 - LLM Benchmark</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="container">
    <div class="page-header">
        <h1>📊 性能指标</h1>
        <a href="${pageContext.request.contextPath}/" class="btn-back">返回首页</a>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>模型ID</th>
                    <th>智力指数</th>
                    <th>全能指数</th>
                    <th>Terminal-Bench</th>
                    <th>Omni准确率</th>
                    <th>价格($/1M)</th>
                    <th>吞吐量(tok/s)</th>
                    <th>首字延迟(s)</th>
                    <th>总响应(s)</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${dataList}">
                <tr>
                    <td>${item.modelId}</td>
                    <td>${item.artifIntelIdx}</td>
                    <td>${item.artifOmniIdx}</td>
                    <td>${item.terminalBenchHard}</td>
                    <td>${item.aaOmniAccuracy}</td>
                    <td>${item.blendedPrice}</td>
                    <td>${item.medianTokensS}</td>
                    <td>${item.latencyFirstChunk}</td>
                    <td>${item.totalResponseTime}</td>
                </tr>
                </c:forEach>
                <c:if test="${empty dataList}">
                <tr><td colspan="9" class="empty">暂无数据</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>
</body>
</html>
