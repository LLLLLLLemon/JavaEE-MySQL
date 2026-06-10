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

    <!-- 表格 -->
    <div class="table-wrapper">
        <table id="modelTable">
            <thead>
                <tr>
                    <th>模型ID</th>
                    <th>模型名称</th>
                    <th>厂商</th>
                    <th>上下文窗口</th>
                    <th>开源</th>
                    <th>发布日期</th>
                    <th>擅长领域</th>
                    <th style="width:150px">操作</th>
                </tr>
            </thead>
            <tbody id="modelTableBody">
                <c:forEach var="item" items="${dataList}">
                <tr>
                    <td>${item.modelId}</td>
                    <td>${item.modelName}</td>
                    <td>${item.creatorId}</td>
                    <td>${item.contextWindow}</td>
                    <td>${item.isOpenSource ? '是' : '否'}</td>
                    <td>${item.releaseDate}</td>
                    <td>${item.fieldExpertise}</td>
                    <td>
                        <button class="btn-sm btn-edit" onclick='openEditDialog("${item.modelId}","${item.modelName}","${item.creatorId}","${item.contextWindow}","${item.isOpenSource}","${item.releaseDate}","${item.fieldExpertise}","${item.versionUpgradeNote}")'>编辑</button>
                        <button class="btn-sm btn-del" onclick="deleteModel('${item.modelId}')">删除</button>
                    </td>
                </tr>
                </c:forEach>
                <c:if test="${empty dataList}">
                <tr id="emptyRow"><td colspan="8" class="empty">暂无数据</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>

<!-- 新增/编辑模态框 -->
<dialog id="modelDialog">
    <form method="dialog" id="modelForm">
        <h2 id="dialogTitle">新增模型</h2>
        <input type="hidden" id="actionType" value="add">
        <div class="form-group">
            <label>模型ID</label>
            <input type="text" id="modelId" maxlength="10" required>
            <small class="hint">新增后不可修改</small>
        </div>
        <div class="form-group">
            <label>模型名称</label>
            <input type="text" id="modelName" required>
        </div>
        <div class="form-group">
            <label>所属厂商</label>
            <select id="editCreatorId" required></select>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>上下文窗口</label>
                <input type="number" id="contextWindow" min="0" step="1">
            </div>
            <div class="form-group">
                <label>是否开源</label>
                <select id="isOpenSource">
                    <option value="">--</option>
                    <option value="1">是</option>
                    <option value="0">否</option>
                </select>
            </div>
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>发布日期</label>
                <input type="date" id="releaseDate">
            </div>
            <div class="form-group">
                <label>擅长领域</label>
                <input type="text" id="fieldExpertise">
            </div>
        </div>
        <div class="form-group">
            <label>版本升级说明</label>
            <textarea id="versionUpgradeNote" rows="2"></textarea>
        </div>
        <div class="form-actions">
            <button type="button" class="btn-back" onclick="closeDialog()">取消</button>
            <button type="submit" class="btn-primary">保存</button>
        </div>
    </form>
</dialog>

<script>
const ctx = '${pageContext.request.contextPath}';
const dialog = document.getElementById('modelDialog');
const form = document.getElementById('modelForm');

// ===== 加载厂商下拉框 =====
fetch(ctx + '/manage?action=getCreators')
    .then(r => r.json())
    .then(data => {
        const sel = document.getElementById('editCreatorId');
        sel.innerHTML = '<option value="">-- 请选择 --</option>';
        data.forEach(c => {
            sel.innerHTML += '<option value="' + c.id + '">' + c.id + ' - ' + c.name + '</option>';
        });
    });

// ===== CRUD: 新增/编辑 =====
function openAddDialog() {
    document.getElementById('actionType').value = 'add';
    document.getElementById('dialogTitle').textContent = '新增模型';
    document.getElementById('modelId').disabled = false;
    document.getElementById('modelId').value = '';
    document.getElementById('modelName').value = '';
    document.getElementById('editCreatorId').value = '';
    document.getElementById('contextWindow').value = '';
    document.getElementById('isOpenSource').value = '';
    document.getElementById('releaseDate').value = '';
    document.getElementById('fieldExpertise').value = '';
    document.getElementById('versionUpgradeNote').value = '';
    dialog.showModal();
}

function openEditDialog(id, name, creatorId, ctxWin, isOpen, date, expertise, note) {
    document.getElementById('actionType').value = 'update';
    document.getElementById('dialogTitle').textContent = '编辑模型';
    document.getElementById('modelId').disabled = true;
    document.getElementById('modelId').value = id;
    document.getElementById('modelName').value = name;
    document.getElementById('editCreatorId').value = creatorId;
    document.getElementById('contextWindow').value = ctxWin || '';
    document.getElementById('isOpenSource').value = isOpen === 'true' ? '1' : isOpen === 'false' ? '0' : '';
    document.getElementById('releaseDate').value = date || '';
    document.getElementById('fieldExpertise').value = expertise || '';
    document.getElementById('versionUpgradeNote').value = note || '';
    dialog.showModal();
}

function closeDialog() {
    dialog.close();
}

form.addEventListener('submit', function(e) {
    e.preventDefault();
    const actionType = document.getElementById('actionType').value;
    const data = new URLSearchParams();
    data.append('action', actionType === 'add' ? 'addModel' : 'updateModel');
    data.append('modelId', document.getElementById('modelId').value);
    data.append('modelName', document.getElementById('modelName').value);
    data.append('creatorId', document.getElementById('editCreatorId').value);
    data.append('contextWindow', document.getElementById('contextWindow').value);
    data.append('isOpenSource', document.getElementById('isOpenSource').value);
    data.append('releaseDate', document.getElementById('releaseDate').value);
    data.append('fieldExpertise', document.getElementById('fieldExpertise').value);
    data.append('versionUpgradeNote', document.getElementById('versionUpgradeNote').value);

    fetch(ctx + '/manage', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            dialog.close();
            showSql(res.sql, '模型已保存，页面即将刷新...');
            setTimeout(() => location.reload(), 2000);
        } else {
            alert('操作失败：' + res.message);
        }
    })
    .catch(err => alert('请求失败：' + err.message));
});

// ===== CRUD: 删除 =====
function deleteModel(id) {
    if (!confirm('确定要删除模型 \'' + id + '\' 吗？\n注意：删除模型会同时删除其性能指标数据！')) return;
    const data = new URLSearchParams();
    data.append('action', 'deleteModel');
    data.append('modelId', id);

    fetch(ctx + '/manage', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: data
    })
    .then(r => r.json())
    .then(res => {
        if (res.success) {
            showSql(res.sql, '模型已删除，页面即将刷新...');
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