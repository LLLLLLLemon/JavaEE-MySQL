<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>综合表 - LLM Benchmark</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
<style>
/* ===== 已选模型摘要栏 ===== */
.selected-summary-bar {
    background: #fff;
    border-radius: 12px;
    margin-bottom: 16px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    overflow: hidden;
}
.summary-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 20px;
    background: #f0f4ff;
    cursor: pointer;
    user-select: none;
}
.summary-header:hover {
    background: #e8f0fe;
}
.summary-header h3 {
    font-size: 1em;
    color: #1a1a2e;
    margin: 0;
}
.selected-count {
    font-size: 0.9em;
    color: #1a73e8;
    font-weight: 500;
}
.summary-body {
    padding: 12px 20px 16px;
}
.selected-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 12px;
}
.model-tag {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 8px 4px 12px;
    background: #e8f5e9;
    border: 1px solid #a5d6a7;
    border-radius: 16px;
    font-size: 0.85em;
}
.model-tag-name {
    max-width: 180px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.model-tag-remove {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 18px;
    height: 18px;
    border: none;
    background: transparent;
    color: #888;
    border-radius: 50%;
    cursor: pointer;
    font-size: 1em;
    line-height: 1;
    padding: 0;
}
.model-tag-remove:hover {
    background: #c8e6c9;
    color: #c62828;
}
.summary-actions {
    display: flex;
    gap: 8px;
    align-items: center;
}
</style>
</head>
<body>
<div class="container">
    <div class="page-header">
        <h1>📋 综合数据表</h1>
        <div>
            <span id="resultCount" class="result-count">共 ${dataList.size()} 条记录</span>
            <a href="${pageContext.request.contextPath}/" class="btn-back">返回首页</a>
        </div>
    </div>
    <p class="page-subtitle">厂商 → 模型 → 性能指标一体化视图</p>

    <!-- 可收缩查询面板 -->
    <div class="query-panel">
        <div class="query-panel-header" onclick="toggleQueryPanel()">
            <h3 id="queryPanelTitle">▼ 查询与排序</h3>
        </div>
        <div id="queryPanelBody">
            <form id="searchForm">
                <div class="query-row">
                    <div class="query-field">
                        <label>厂商</label>
                        <select id="qCreatorId">
                            <option value="">全部厂商</option>
                        </select>
                    </div>
                    <div class="query-field">
                        <label>开源状态</label>
                        <select id="qIsOpenSource">
                            <option value="">全部</option>
                            <option value="open">仅开源</option>
                            <option value="closed">仅闭源</option>
                        </select>
                    </div>
                    <div class="query-field">
                        <label>上下文窗口</label>
                        <div class="range-inputs">
                            <input type="number" id="qCtxMin" placeholder="最小" min="0">
                            <span>~</span>
                            <input type="number" id="qCtxMax" placeholder="最大" min="0">
                        </div>
                    </div>
                    <div class="query-field">
                        <label>智力指数</label>
                        <div class="range-inputs">
                            <input type="number" id="qIntelMin" placeholder="最小" min="0" max="100" step="0.1">
                            <span>~</span>
                            <input type="number" id="qIntelMax" placeholder="最大" min="0" max="100" step="0.1">
                        </div>
                    </div>
                </div>
                <div class="query-row">
                    <div class="query-field">
                        <label>价格($/1M Tokens)</label>
                        <div class="range-inputs">
                            <input type="number" id="qPriceMin" placeholder="最小" min="0" step="0.01">
                            <span>~</span>
                            <input type="number" id="qPriceMax" placeholder="最大" min="0" step="0.01">
                        </div>
                    </div>
                    <div class="query-field">
                        <label>吞吐量(tok/s)</label>
                        <div class="range-inputs">
                            <input type="number" id="qTpsMin" placeholder="最小" min="0" step="0.1">
                            <span>~</span>
                            <input type="number" id="qTpsMax" placeholder="最大" min="0" step="0.1">
                        </div>
                    </div>
                    <div class="query-field">
                        <label>发布日期</label>
                        <div class="range-inputs">
                            <input type="date" id="qDateBegin">
                            <span>~</span>
                            <input type="date" id="qDateEnd">
                        </div>
                    </div>
                </div>
                <div class="query-actions">
                    <button type="button" class="btn-primary" onclick="searchFullview()">🔍 搜索</button>
                    <button type="button" class="btn-reset" onclick="resetFullviewSearch()">重置</button>
                    <span class="query-sort">
                        <label>排序：</label>
                        <select id="qOrderBy" onchange="searchFullview()">
                            <option value="">默认排序</option>
                            <option value="m.context_window DESC">上下文窗口 ↓</option>
                            <option value="m.context_window ASC">上下文窗口 ↑</option>
                            <option value="mt.artif_intel_idx DESC">智力指数 ↓</option>
                            <option value="mt.artif_intel_idx ASC">智力指数 ↑</option>
                            <option value="mt.blended_price ASC">价格 ↑</option>
                            <option value="mt.blended_price DESC">价格 ↓</option>
                            <option value="mt.median_tokens_s DESC">吞吐量 ↓</option>
                            <option value="mt.median_tokens_s ASC">吞吐量 ↑</option>
                            <option value="m.release_date DESC">发布日期 ↓</option>
                            <option value="m.release_date ASC">发布日期 ↑</option>
                        </select>
                    </span>
                </div>
            </form>
        </div>
    </div>

    <!-- 已选模型摘要栏（合并后的唯一对比按钮位于此栏内） -->
    <div id="selectedSummaryBar" class="selected-summary-bar" style="display:none;">
        <div class="summary-header" onclick="toggleSummaryPanel()">
            <h3 id="summaryTitle">▼ 已选模型</h3>
            <span id="selectedCount" class="selected-count">已选 0 个模型</span>
        </div>
        <div id="summaryBody" class="summary-body">
            <div id="selectedTags" class="selected-tags"></div>
            <div class="summary-actions">
                <button class="btn-primary" id="summaryCompareBtn" onclick="startCompare()" disabled>📊 开始对比</button>
            </div>
        </div>
    </div>

    <!-- 数据表格 -->
    <div class="table-wrapper">
        <table id="fullviewTable">
            <colgroup>
                <col style="width:40px">
                <col style="min-width:75px">
                <col style="min-width:120px">
                <col style="width:85px">
                <col style="width:45px">
                <col style="width:90px">
                <col style="width:68px">
                <col style="width:68px">
                <col style="width:95px">
                <col style="width:85px">
                <col style="width:80px">
                <col style="width:85px">
                <col style="width:78px">
                <col style="width:78px">
            </colgroup>
            <thead>
                <tr>
                    <th style="width:40px"><input type="checkbox" id="selectAll" onchange="toggleAll()"></th>
                    <th>厂商名称</th>
                    <th>模型名称</th>
                    <th>上下文窗口</th>
                    <th>开源</th>
                    <th>发布日期</th>
                    <th class="num">智力指数</th>
                    <th class="num">全能指数</th>
                    <th class="num">Terminal-Bench</th>
                    <th class="num">Omni准确率</th>
                    <th class="num">价格($/1M)</th>
                    <th class="num">吞吐量(tok/s)</th>
                    <th class="num">首字延迟(s)</th>
                    <th class="num">总响应(s)</th>
                </tr>
            </thead>
            <tbody id="fullviewBody">
                <c:forEach var="item" items="${dataList}">
                <tr>
                    <td><input type="checkbox" class="model-checkbox" value="${item.modelId}" onchange="onCheckboxChange(this)"></td>
                    <td><strong>${item.creatorName}</strong></td>
                    <td>${item.modelName}</td>
                    <td class="num">${item.contextWindow}</td>
                    <td>${item.isOpenSource ? '是' : '否'}</td>
                    <td>${item.releaseDate}</td>
                    <td class="num">${item.artifIntelIdx}</td>
                    <td class="num">${item.artifOmniIdx}</td>
                    <td class="num">${item.terminalBenchHard}</td>
                    <td class="num">${item.aaOmniAccuracy}</td>
                    <td class="num">${item.blendedPrice}</td>
                    <td class="num">${item.medianTokensS}</td>
                    <td class="num">${item.latencyFirstChunk}</td>
                    <td class="num">${item.totalResponseTime}</td>
                </tr>
                </c:forEach>
                <c:if test="${empty dataList}">
                <tr><td colspan="14" class="empty">暂无数据</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <footer><p>LLM Benchmark System &copy; 2026</p></footer>
</div>

<script>
const ctx = '${pageContext.request.contextPath}';

// ===== 对比复选框预选集合 =====
let selectedModelIds = new Set();

// 从对比页面返回时清空已选（sessionStorage 标记由 startCompare 设置）
if (sessionStorage.getItem('compareExecuted') === 'true') {
    sessionStorage.removeItem('compareExecuted');
    // selectedModelIds 初始即为空 Set，无需显示清除
}

// ===== 模型数据映射（用于已选模型摘要栏显示名称） =====
let modelDataMap = {};
<c:forEach var="item" items="${dataList}" varStatus="s">
modelDataMap['${item.modelId}'] = {name: '${item.modelName}', creator: '${item.creatorName}'};
</c:forEach>

// 加载厂商下拉框
fetch(ctx + '/manage?action=getCreators')
    .then(r => r.json())
    .then(data => {
        const sel = document.getElementById('qCreatorId');
        data.forEach(c => {
            const opt = document.createElement('option');
            opt.value = c.id;
            opt.textContent = c.id + ' - ' + c.name;
            sel.appendChild(opt);
        });
    });

// 切换查询面板展开/收缩
function toggleQueryPanel() {
    const body = document.getElementById('queryPanelBody');
    const title = document.getElementById('queryPanelTitle');
    if (body.style.display === 'none') {
        body.style.display = 'block';
        title.textContent = '▼ 查询与排序';
    } else {
        body.style.display = 'none';
        title.textContent = '▶ 查询与排序';
    }
}

// ===== 复选框变更处理（同步 selectedModelIds） =====
function onCheckboxChange(cb) {
    if (cb.checked) {
        selectedModelIds.add(cb.value);
    } else {
        selectedModelIds.delete(cb.value);
    }
    // 更新全选状态
    const allVisible = document.querySelectorAll('#fullviewBody .model-checkbox');
    const allChecked = document.querySelectorAll('#fullviewBody .model-checkbox:checked');
    document.getElementById('selectAll').checked = allVisible.length > 0 && allVisible.length === allChecked.length;
    updateCompareBtn();
    updateSelectedSummary();
}

// 综合表条件查询（永远不清空 selectedModelIds）
function searchFullview() {
    const params = new URLSearchParams();
    params.append('action', 'searchFullview');

    const creatorId = document.getElementById('qCreatorId').value;
    if (creatorId) params.append('creatorIds', creatorId);

    const isOpen = document.getElementById('qIsOpenSource').value;
    if (isOpen) params.append('isOpenSource', isOpen);

    const fieldMap = {
        qCtxMin: 'contextWindowMin', qCtxMax: 'contextWindowMax',
        qIntelMin: 'artifIntelIdxMin', qIntelMax: 'artifIntelIdxMax',
        qPriceMin: 'blendedPriceMin', qPriceMax: 'blendedPriceMax',
        qTpsMin: 'medianTokensSMin', qTpsMax: 'medianTokensSMax',
        qDateBegin: 'releaseDateBegin', qDateEnd: 'releaseDateEnd'
    };
    for (let [elId, paramName] of Object.entries(fieldMap)) {
        const val = document.getElementById(elId).value;
        if (val) params.append(paramName, val);
    }

    const orderBy = document.getElementById('qOrderBy').value;
    if (orderBy) params.append('orderBy', orderBy);

    fetch(ctx + '/manage?' + params.toString())
        .then(r => r.json())
        .then(data => {
            // 不清空 selectedModelIds，仅增量更新 modelDataMap
            renderFullview(data);
            document.getElementById('resultCount').textContent = '共 ' + data.length + ' 条记录';
            updateSelectedSummary();
        })
        .catch(err => alert('查询失败：' + err.message));
}

function resetFullviewSearch() {
    document.getElementById('searchForm').reset();
    // 保留 selectedModelIds 不清除，直接调用 AJAX 搜索
    searchFullview();
}

function renderFullview(items) {
    // 增量更新模型数据映射（不清除旧数据，确保摘要栏始终能显示已选模型名称）
    items.forEach(m => {
        modelDataMap[m.modelId] = {name: m.modelName, creator: m.creatorName};
    });

    const tbody = document.getElementById('fullviewBody');
    if (items.length === 0) {
        tbody.innerHTML = '<tr><td colspan="14" class="empty">未找到匹配的数据</td></tr>';
        document.getElementById('selectAll').checked = false;
        updateCompareBtn();
        updateSelectedSummary();
        return;
    }
    let html = '';
    items.forEach(m => {
        const checked = selectedModelIds.has(m.modelId) ? ' checked' : '';
        html += '<tr>';
        html += '<td><input type="checkbox" class="model-checkbox" value="' + escapeHtml(m.modelId) + '"' + checked + ' onchange="onCheckboxChange(this)"></td>';
        html += '<td><strong>' + escapeHtml(m.creatorName || '') + '</strong></td>';
        html += '<td>' + escapeHtml(m.modelName) + '</td>';
        html += '<td class="num">' + (m.contextWindow != null ? m.contextWindow : '') + '</td>';
        html += '<td>' + (m.isOpenSource === true ? '是' : m.isOpenSource === false ? '否' : '') + '</td>';
        html += '<td>' + (m.releaseDate || '') + '</td>';
        html += '<td class="num">' + (m.artifIntelIdx != null ? m.artifIntelIdx : '') + '</td>';
        html += '<td class="num">' + (m.artifOmniIdx != null ? m.artifOmniIdx : '') + '</td>';
        html += '<td class="num">' + (m.terminalBenchHard != null ? m.terminalBenchHard : '') + '</td>';
        html += '<td class="num">' + (m.aaOmniAccuracy != null ? m.aaOmniAccuracy : '') + '</td>';
        html += '<td class="num">' + (m.blendedPrice != null ? m.blendedPrice : '') + '</td>';
        html += '<td class="num">' + (m.medianTokensS != null ? m.medianTokensS : '') + '</td>';
        html += '<td class="num">' + (m.latencyFirstChunk != null ? m.latencyFirstChunk : '') + '</td>';
        html += '<td class="num">' + (m.totalResponseTime != null ? m.totalResponseTime : '') + '</td>';
        html += '</tr>';
    });
    tbody.innerHTML = html;

    // 更新全选状态：若所有可见行均已勾选，则自动勾选全选框
    const allVisible = document.querySelectorAll('#fullviewBody .model-checkbox');
    const allChecked = document.querySelectorAll('#fullviewBody .model-checkbox:checked');
    document.getElementById('selectAll').checked = allVisible.length > 0 && allVisible.length === allChecked.length;
    updateCompareBtn();
    updateSelectedSummary();
}

// ===== 全选/取消全选（同步 selectedModelIds） =====
function toggleAll() {
    const checked = document.getElementById('selectAll').checked;
    document.querySelectorAll('#fullviewBody .model-checkbox').forEach(cb => {
        cb.checked = checked;
        if (checked) {
            selectedModelIds.add(cb.value);
        } else {
            selectedModelIds.delete(cb.value);
        }
    });
    updateCompareBtn();
    updateSelectedSummary();
}

function updateCompareBtn() {
    const count = selectedModelIds.size;
    const summaryBtn = document.getElementById('summaryCompareBtn');
    if (!summaryBtn) return;
    if (count >= 2 && count <= 5) {
        summaryBtn.disabled = false;
        summaryBtn.textContent = '📊 开始对比（已选 ' + count + ' 个）';
    } else {
        summaryBtn.disabled = true;
        summaryBtn.textContent = count > 5
            ? '⚠ 最多只能选择5个模型'
            : '📊 开始对比（需勾选2~5个模型）';
    }
}

function startCompare() {
    if (selectedModelIds.size < 2 || selectedModelIds.size > 5) {
        alert('请勾选2~5个模型进行对比');
        return;
    }
    // 标记对比已执行，返回综合表时通过 sessionStorage 触发清空
    sessionStorage.setItem('compareExecuted', 'true');
    const ids = Array.from(selectedModelIds).join(',');
    window.location.href = ctx + '/compare?ids=' + ids + '&source=fullview';
}

// ===== 已选模型摘要栏 =====

/** 更新摘要栏内容 */
function updateSelectedSummary() {
    const bar = document.getElementById('selectedSummaryBar');
    const tagsContainer = document.getElementById('selectedTags');
    const countSpan = document.getElementById('selectedCount');

    if (!bar || !tagsContainer || !countSpan) return;

    const count = selectedModelIds.size;
    countSpan.textContent = '已选 ' + count + ' 个模型';

    if (count === 0) {
        bar.style.display = 'none';
        return;
    }
    bar.style.display = 'block';

    // 构建标签HTML
    let tagsHtml = '';
    for (let id of selectedModelIds) {
        const data = modelDataMap[id];
        const displayName = data ? data.name : id;
        const creatorName = data ? data.creator : '';
        tagsHtml += '<span class="model-tag">'
            + '<span class="model-tag-name" title="' + escapeHtml(creatorName) + '">' + escapeHtml(displayName) + '</span>'
            + '<button class="model-tag-remove" onclick="removeSelectedModel(\'' + escapeHtml(id) + '\')" title="移除">&times;</button>'
            + '</span>';
    }
    tagsContainer.innerHTML = tagsHtml;

    // 同步对比按钮状态
    updateCompareBtn();
}

/** 从摘要栏移除模型 */
function removeSelectedModel(id) {
    selectedModelIds.delete(id);
    // 取消对应复选框
    const cb = document.querySelector('#fullviewBody .model-checkbox[value="' + id + '"]');
    if (cb) {
        cb.checked = false;
    }
    // 更新全选状态
    const allVisible = document.querySelectorAll('#fullviewBody .model-checkbox');
    const allChecked = document.querySelectorAll('#fullviewBody .model-checkbox:checked');
    document.getElementById('selectAll').checked = allVisible.length > 0 && allVisible.length === allChecked.length;
    updateCompareBtn();
    updateSelectedSummary();
}

/** 切换摘要栏展开/收缩 */
function toggleSummaryPanel() {
    const body = document.getElementById('summaryBody');
    const title = document.getElementById('summaryTitle');
    if (!body || !title) return;
    if (body.style.display === 'none') {
        body.style.display = 'block';
        title.textContent = '▼ 已选模型';
    } else {
        body.style.display = 'none';
        title.textContent = '▶ 已选模型（' + selectedModelIds.size + '）';
    }
}

function escapeHtml(s) {
    if (!s) return '';
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
</script>
</body>
</html>
