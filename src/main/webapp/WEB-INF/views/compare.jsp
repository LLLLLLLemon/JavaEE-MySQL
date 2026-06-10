<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>模型对比 - LLM Benchmark</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="container">
    <div class="page-header">
        <h1>📊 模型对比分析</h1>
        <a href="${pageContext.request.contextPath}/${source == 'fullview' ? 'list?type=fullview' : 'list?type=models'}" class="btn-back">${source == 'fullview' ? '返回综合表' : '返回模型库'}</a>
    </div>

    <%-- 并列表格 --%>
    <div class="table-wrapper compare-table-wrapper">
        <table id="compareTable" class="compare-table">
            <thead>
                <tr>
                    <th style="min-width:100px">指标</th>
                    <c:forEach var="m" items="${models}">
                        <th style="min-width:120px">${m.modelName}<br><small>${m.creatorName}</small></th>
                    </c:forEach>
                </tr>
            </thead>
            <tbody>
                <%-- 模型名称 --%>
                <tr><td class="label-cell">模型名称</td>
                    <c:forEach var="m" items="${models}"><td>${m.modelName}</td></c:forEach></tr>
                <%-- 厂商 --%>
                <tr><td class="label-cell">所属厂商</td>
                    <c:forEach var="m" items="${models}"><td>${m.creatorName}</td></c:forEach></tr>
                <%-- 上下文长度 --%>
                <tr><td class="label-cell">上下文长度</td>
                    <c:forEach var="m" items="${models}"><td class="num <c:if test='${m.contextWindow == maxCtx}'>best</c:if>">${m.contextWindow}</td></c:forEach></tr>
                <%-- 是否开源 --%>
                <tr><td class="label-cell">是否开源</td>
                    <c:forEach var="m" items="${models}"><td>${m.isOpenSource ? '是' : '否'}</td></c:forEach></tr>
                <%-- 智力指数 --%>
                <tr><td class="label-cell">智力指数</td>
                    <c:forEach var="m" items="${models}"><td class="num <c:if test='${m.artifIntelIdx == maxIntel}'>best</c:if>">${m.artifIntelIdx}</td></c:forEach></tr>
                <%-- 全能指数 --%>
                <tr><td class="label-cell">全能指数</td>
                    <c:forEach var="m" items="${models}"><td class="num <c:if test='${m.artifOmniIdx == maxOmni}'>best</c:if>">${m.artifOmniIdx}</td></c:forEach></tr>
                <%-- 综合价格（反向） --%>
                <tr><td class="label-cell">综合价格($/1M)</td>
                    <c:forEach var="m" items="${models}"><td class="num <c:if test='${m.blendedPrice != null && m.blendedPrice == minPrice}'>best</c:if>">${m.blendedPrice}</td></c:forEach></tr>
                <%-- 吞吐量 --%>
                <tr><td class="label-cell">吞吐量(tok/s)</td>
                    <c:forEach var="m" items="${models}"><td class="num <c:if test='${m.medianTokensS == maxTps}'>best</c:if>">${m.medianTokensS}</td></c:forEach></tr>
                <%-- 首字延迟（反向） --%>
                <tr><td class="label-cell">首字延迟(s)</td>
                    <c:forEach var="m" items="${models}"><td class="num <c:if test='${m.latencyFirstChunk != null && m.latencyFirstChunk == minLatency}'>best</c:if>">${m.latencyFirstChunk}</td></c:forEach></tr>
                <%-- 总响应时间（反向） --%>
                <tr><td class="label-cell">总响应时间(s)</td>
                    <c:forEach var="m" items="${models}"><td class="num <c:if test='${m.totalResponseTime != null && m.totalResponseTime == minRespTime}'>best</c:if>">${m.totalResponseTime}</td></c:forEach></tr>
                <%-- 擅长领域 --%>
                <tr><td class="label-cell">擅长领域</td>
                    <c:forEach var="m" items="${models}"><td>${m.fieldExpertise}</td></c:forEach></tr>
            </tbody>
        </table>
    </div>

    <%-- 差异总结 --%>
    <div class="summary-panel">
        <h3>📝 差异总结</h3>
        <div id="summaryContent"></div>
    </div>

    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>

<script>
const ctx = '${pageContext.request.contextPath}';
const models = [
    <c:forEach var="m" items="${models}" varStatus="s">
    {
        modelId: '${m.modelId}',
        modelName: '${m.modelName}',
        creatorName: '${m.creatorName}',
        contextWindow: ${m.contextWindow != null ? m.contextWindow : 'null'},
        isOpenSource: ${m.isOpenSource != null ? m.isOpenSource : 'null'},
        artifIntelIdx: ${m.artifIntelIdx != null ? m.artifIntelIdx : 'null'},
        artifOmniIdx: ${m.artifOmniIdx != null ? m.artifOmniIdx : 'null'},
        blendedPrice: ${m.blendedPrice != null ? m.blendedPrice : 'null'},
        medianTokensS: ${m.medianTokensS != null ? m.medianTokensS : 'null'},
        latencyFirstChunk: ${m.latencyFirstChunk != null ? m.latencyFirstChunk : 'null'},
        totalResponseTime: ${m.totalResponseTime != null ? m.totalResponseTime : 'null'}
    }${!s.last ? ',' : ''}
    </c:forEach>
];

// ===== 差异总结 =====
function generateSummary() {
    let html = '';

    // 1. 智力最高的模型
    const bestIntel = models.reduce((a, b) =>
        (a.artifIntelIdx || 0) >= (b.artifIntelIdx || 0) ? a : b
    );
    html += '<p>🧠 <strong>智力最高：</strong>' + bestIntel.modelName;
    if (bestIntel.artifIntelIdx != null) html += '（智力指数 ' + bestIntel.artifIntelIdx + '）';
    html += '</p>';

    // 2. 性价比最高的模型（价格最低且智力指数不低于平均值）
    const avgIntel = models.reduce((s, m) => s + (m.artifIntelIdx || 0), 0) / models.length;
    const sortedByPrice = [...models].filter(m => m.blendedPrice != null && m.artifIntelIdx != null)
        .sort((a, b) => a.blendedPrice - b.blendedPrice);
    let bestValue = null;
    for (let m of sortedByPrice) {
        if (m.artifIntelIdx >= avgIntel) {
            bestValue = m;
            break;
        }
    }
    if (bestValue) {
        html += '<p>💰 <strong>性价比最高：</strong>' + bestValue.modelName;
        html += '（价格 $' + bestValue.blendedPrice + '/1M，智力指数 ' + bestValue.artifIntelIdx + '）';
        html += ' — 价格低于平均水平同时智力指数达到或超过平均线</p>';
    } else if (sortedByPrice.length > 0) {
        html += '<p>💰 <strong>价格最低：</strong>' + sortedByPrice[0].modelName;
        html += '（$' + sortedByPrice[0].blendedPrice + '/1M）</p>';
    }

    // 3. 吞吐量最高的模型
    const bestTps = models.reduce((a, b) =>
        (a.medianTokensS || 0) >= (b.medianTokensS || 0) ? a : b
    );
    if (bestTps.medianTokensS != null) {
        html += '<p>⚡ <strong>吞吐量最高：</strong>' + bestTps.modelName + '（' + bestTps.medianTokensS + ' tok/s）</p>';
    }

    // 4. 上下文窗口最大的模型
    const bestCtx = models.reduce((a, b) =>
        (a.contextWindow || 0) >= (b.contextWindow || 0) ? a : b
    );
    if (bestCtx.contextWindow != null) {
        html += '<p>📐 <strong>上下文窗口最大：</strong>' + bestCtx.modelName + '（' + bestCtx.contextWindow + ' tokens）</p>';
    }

    // 5. 开源情况对比
    const openModels = models.filter(m => m.isOpenSource === true);
    const closedModels = models.filter(m => m.isOpenSource === false);
    if (openModels.length > 0) {
        html += '<p>🔓 <strong>开源模型：</strong>' + openModels.map(m => m.modelName).join('、') + '</p>';
    }
    if (closedModels.length > 0) {
        html += '<p>🔒 <strong>闭源模型：</strong>' + closedModels.map(m => m.modelName).join('、') + '</p>';
    }

    // 6. 综合推荐
    html += '<hr>';
    // 推荐1：追求性能选智力最高的
    html += '<p>🏆 <strong>综合推荐：</strong></p>';
    html += '<ul>';
    if (bestIntel.artifIntelIdx != null) {
        html += '<li><strong>追求最佳性能：</strong>选择 ' + bestIntel.modelName + '，其在智力评测中表现最优';
        if (bestIntel.medianTokensS != null) html += '，同时吞吐量达 ' + bestIntel.medianTokensS + ' tok/s';
        html += '</li>';
    }
    if (bestValue) {
        html += '<li><strong>追求性价比：</strong>选择 ' + bestValue.modelName + '，以较低价格提供了高于平均水平的智能表现</li>';
    }
    if (openModels.length > 0) {
        html += '<li><strong>开源需求：</strong>' + openModels.map(m => m.modelName).join('、') + ' 为开源模型，可本地部署和二次开发</li>';
    }
    html += '</ul>';

    document.getElementById('summaryContent').innerHTML = html;
}

generateSummary();
</script>
</body>
</html>
