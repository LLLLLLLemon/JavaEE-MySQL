<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>模型库 - LLM Benchmark</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="container">
    <div class="page-header">
        <h1>🤖 模型库</h1>
        <a href="${pageContext.request.contextPath}/" class="btn-back">返回首页</a>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>模型ID</th>
                    <th>模型名称</th>
                    <th>厂商</th>
                    <th>上下文窗口</th>
                    <th>开源</th>
                    <th>发布日期</th>
                    <th>擅长领域</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${dataList}">
                <tr>
                    <td>${item.modelId}</td>
                    <td>${item.modelName}</td>
                    <td>${item.creatorId}</td>
                    <td>${item.contextWindow}</td>
                    <td>${item.isOpenSource ? '是' : '否'}</td>
                    <td>${item.releaseDate}</td>
                    <td>${item.fieldExpertise}</td>
                </tr>
                </c:forEach>
                <c:if test="${empty dataList}">
                <tr><td colspan="7" class="empty">暂无数据</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>
</body>
</html>
