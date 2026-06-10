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
        <div>
            <button class="btn-primary" onclick="openAddDialog()">＋ 新增</button>
            <a href="${pageContext.request.contextPath}/" class="btn-back">返回首页</a>
        </div>
    </div>

    <!-- SQL 执行展示 -->
    <div id="sqlDisplay" class="sql-display" style="display:none;">
        <span class="sql-label">已执行 SQL：</span>
        <code id="sqlCode"></code>
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
                    <th style="width:140px">操作</th>
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
                    <td>
                        <button class="btn-sm btn-edit" onclick='openEditDialog("${item.modelId}","${item.artifIntelIdx}","${item.artifOmniIdx}","${item.terminalBenchHard}","${item.aaOmniAccuracy}","${item.blendedPrice}","${item.medianTokensS}","${item.latencyFirstChunk}","${item.totalResponseTime}")'>编辑</button>
                        <button class="btn-sm btn-del" onclick="deleteMetric('${item.modelId}')">删除</button>
                    </td>
                </tr>
                </c:forEach>
                <c:if test="${empty dataList}">
                <tr><td colspan="10" class="empty">暂无数据</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>

<!-- 新增/编辑模态框 -->
<dialog id="metricDialog">
    <form method="dialog" id="metricForm">
        <h2 id="dialogTitle">新增指标</h2>
        <input type="hidden" id="actionType" value="add">
        <div class="form-group">
            <label>模型</label>
            <select id="modelId" required>
                <option value="">-- 请选择 --</option>
            </select>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>智力指数</label>
                <input type="number" id="artifIntelIdx" step="0.01">
            </div>
            <div class="form-group">
                <label>全能指数</label>
                <input type="number" id="artifOmniIdx" step="0.01">
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>Terminal-Bench</label>
                <input type="number" id="terminalBenchHard" step="0.01">
            </div>
            <div class="form-group">
                <label>AA-Omni准确率(0~100)</label>
                <input type="number" id="aaOmniAccuracy" step="0.01" min="0" max="100">
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>价格($/1M Tokens)</label>
                <input type="number" id="blendedPrice" step="0.0001" min="0">
            </div>
            <div class="form-group">
                <label>吞吐量(tok/s)</label>
                <input type="number" id="medianTokensS" step="0.01" min="0">
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>首字延迟(s)</label>
                <input type="number" id="latencyFirstChunk" step="0.01" min="0">
            </div>
            <div class="form-group">
                <label>总响应时间(s)</label>
                <input type="number" id="totalResponseTime" step="0.01" min="0">
            </div>
        </div>
        <div class="form-actions">
            <button type="button" class="btn-back" onclick="closeDialog()">取消</button>
            <button type="submit" class="btn-primary">保存</button>
        </div>
    </form>
</dialog>

<script>
const ctx = '${pageContext.request.contextPath}';
const dialog = document.getElementById('metricDialog');
const form = document.getElementById('metricForm');

function openAddDialog() {
    document.getElementById('actionType').value = 'add';
    document.getElementById('dialogTitle').textContent = '新增指标';
    document.getElementById('modelId').disabled = false;
    resetForm();
    loadModelsWithoutMetrics();
    dialog.showModal();
}

function openEditDialog(modelId, intelIdx, omniIdx, terminal, accuracy, price, tokens, latency, totalTime) {
    document.getElementById('actionType').value = 'update';
    document.getElementById('dialogTitle').textContent = '编辑指标 - ' + modelId;
    document.getElementById('modelId').disabled = true;
    document.getElementById('modelId').innerHTML = '<option value="' + modelId + '" selected>' + modelId + '</option>';
    document.getElementById('artifIntelIdx').value = intelIdx || '';
    document.getElementById('artifOmniIdx').value = omniIdx || '';
    document.getElementById('terminalBenchHard').value = terminal || '';
    document.getElementById('aaOmniAccuracy').value = accuracy || '';
    document.getElementById('blendedPrice').value = price || '';
    document.getElementById('medianTokensS').value = tokens || '';
    document.getElementById('latencyFirstChunk').value = latency || '';
    document.getElementById('totalResponseTime').value = totalTime || '';
    dialog.showModal();
}

function closeDialog() {
    dialog.close();
}

function resetForm() {
    document.getElementById('artifIntelIdx').value = '';
    document.getElementById('artifOmniIdx').value = '';
    document.getElementById('terminalBenchHard').value = '';
    document.getElementById('aaOmniAccuracy').value = '';
    document.getElementById('blendedPrice').value = '';
    document.getElementById('medianTokensS').value = '';
    document.getElementById('latencyFirstChunk').value = '';
    document.getElementById('totalResponseTime').value = '';
}

function loadModelsWithoutMetrics() {
    fetch(ctx + '/manage?action=getModelsWithoutMetrics')
        .then(r => r.json())
        .then(data => {
            const sel = document.getElementById('modelId');
            sel.innerHTML = '<option value="">-- 请选择 --</option>';
            data.forEach(m => {
                sel.innerHTML += '<option value="' + m.id + '">' + m.id + ' - ' + m.name + '</option>';
            });
        })
        .catch(err => console.error('加载模型列表失败:', err));
}

form.addEventListener('submit', function(e) {
    e.preventDefault();
    const actionType = document.getElementById('actionType').value;
    const data = new URLSearchParams();
    data.append('action', actionType === 'add' ? 'addMetric' : 'updateMetric');
    data.append('modelId', document.getElementById('modelId').value);
    data.append('artifIntelIdx', document.getElementById('artifIntelIdx').value);
    data.append('artifOmniIdx', document.getElementById('artifOmniIdx').value);
    data.append('terminalBenchHard', document.getElementById('terminalBenchHard').value);
    data.append('aaOmniAccuracy', document.getElementById('aaOmniAccuracy').value);
    data.append('blendedPrice', document.getElementById('blendedPrice').value);
    data.append('medianTokensS', document.getElementById('medianTokensS').value);
    data.append('latencyFirstChunk', document.getElementById('latencyFirstChunk').value);
    data.append('totalResponseTime', document.getElementById('totalResponseTime').value);

    fetch(ctx + '/manage', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            dialog.close();
            showSql(res.sql, '指标已保存，页面即将刷新...');
            setTimeout(() => location.reload(), 2000);
        } else {
            alert('操作失败：' + res.message);
        }
    })
    .catch(err => alert('请求失败：' + err.message));
});

function deleteMetric(id) {
    if (!confirm('确定要删除模型 \'' + id + '\' 的指标数据吗？')) return;
    const data = new URLSearchParams();
    data.append('action', 'deleteMetric');
    data.append('modelId', id);

    fetch(ctx + '/manage', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            showSql(res.sql, '指标已删除，页面即将刷新...');
            setTimeout(() => location.reload(), 2000);
        } else {
            alert('删除失败：' + res.message);
        }
    })
    .catch(err => alert('请求失败：' + err.message));
}

dialog.addEventListener('click', function(e) {
    if (e.target === dialog) dialog.close();
});

// ===== SQL 展示 =====
function showSql(sql, hint) {
    if (sql) {
        const el = document.getElementById('sqlDisplay');
        document.getElementById('sqlCode').textContent = sql;
        el.style.display = 'block';
        const hintEl = document.createElement('div');
        hintEl.className = 'sql-hint';
        hintEl.textContent = hint || '';
        el.appendChild(hintEl);
        setTimeout(() => { el.style.display = 'none'; }, 4000);
    }
}
</script>
</body>
</html>
