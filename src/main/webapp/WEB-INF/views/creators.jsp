<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>厂商列表 - LLM Benchmark</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="container">
    <div class="page-header">
        <h1>🏢 厂商列表</h1>
        <a href="${pageContext.request.contextPath}/" class="btn-back">返回首页</a>
    </div>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>厂商ID</th>
                    <th>厂商名称</th>
                    <th>简介</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${dataList}">
                <tr>
                    <td>${item.creatorId}</td>
                    <td>${item.creatorName}</td>
                    <td>${item.description}</td>
                </tr>
                </c:forEach>
                <c:if test="${empty dataList}">
                <tr><td colspan="3" class="empty">暂无数据</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>
</body>
</html>
