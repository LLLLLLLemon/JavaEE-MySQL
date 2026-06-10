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
                    <th>厂商ID</th>
                    <th>厂商名称</th>
                    <th>简介</th>
                    <th style="width:140px">操作</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="item" items="${dataList}">
                <tr>
                    <td>${item.creatorId}</td>
                    <td>${item.creatorName}</td>
                    <td>${item.description}</td>
                    <td>
                        <button class="btn-sm btn-edit" onclick="openEditDialog('${item.creatorId}','${item.creatorName}','${item.description}')">编辑</button>
                        <button class="btn-sm btn-del" onclick="deleteCreator('${item.creatorId}')">删除</button>
                    </td>
                </tr>
                </c:forEach>
                <c:if test="${empty dataList}">
                <tr><td colspan="4" class="empty">暂无数据</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>

<!-- 新增/编辑模态框 -->
<dialog id="creatorDialog">
    <form method="dialog" id="creatorForm">
        <h2 id="dialogTitle">新增厂商</h2>
        <input type="hidden" id="actionType" value="add">
        <div class="form-group">
            <label>厂商ID</label>
            <input type="text" id="creatorId" maxlength="10" pattern="[a-zA-Z0-9]+" required>
            <small class="hint">字母或数字，1-10位，新增后不可修改</small>
        </div>
        <div class="form-group">
            <label>厂商名称</label>
            <input type="text" id="creatorName" required>
        </div>
        <div class="form-group">
            <label>简介</label>
            <textarea id="description" rows="3"></textarea>
        </div>
        <div class="form-actions">
            <button type="button" class="btn-back" onclick="closeDialog()">取消</button>
            <button type="submit" class="btn-primary">保存</button>
        </div>
    </form>
</dialog>

<script>
const ctx = '${pageContext.request.contextPath}';
const dialog = document.getElementById('creatorDialog');
const form = document.getElementById('creatorForm');

function openAddDialog() {
    document.getElementById('actionType').value = 'add';
    document.getElementById('dialogTitle').textContent = '新增厂商';
    document.getElementById('creatorId').value = '';
    document.getElementById('creatorId').disabled = false;
    document.getElementById('creatorName').value = '';
    document.getElementById('description').value = '';
    dialog.showModal();
}

function openEditDialog(id, name, desc) {
    document.getElementById('actionType').value = 'update';
    document.getElementById('dialogTitle').textContent = '编辑厂商';
    document.getElementById('creatorId').value = id;
    document.getElementById('creatorId').disabled = true;
    document.getElementById('creatorName').value = name;
    document.getElementById('description').value = desc || '';
    dialog.showModal();
}

function closeDialog() {
    dialog.close();
}

form.addEventListener('submit', function(e) {
    e.preventDefault();
    const actionType = document.getElementById('actionType').value;
    const data = new URLSearchParams();
    data.append('action', actionType === 'add' ? 'addCreator' : 'updateCreator');
    data.append('creatorId', document.getElementById('creatorId').value);
    data.append('creatorName', document.getElementById('creatorName').value);
    data.append('description', document.getElementById('description').value);

    fetch(ctx + '/manage', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            dialog.close();
            showSql(res.sql, '厂商已保存，页面即将刷新...');
            setTimeout(() => location.reload(), 2000);
        } else {
            alert('操作失败：' + res.message);
        }
    })
    .catch(err => alert('请求失败：' + err.message));
});

function deleteCreator(id) {
    if (!confirm('确定要删除厂商 \'' + id + '\' 吗？')) return;
    const data = new URLSearchParams();
    data.append('action', 'deleteCreator');
    data.append('creatorId', id);

    fetch(ctx + '/manage', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            showSql(res.sql, '厂商已删除，页面即将刷新...');
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
