package com.benchmark.servlet;

import com.benchmark.dao.CreatorDAO;
import com.benchmark.dao.ModelDAO;
import com.benchmark.dao.ModelMetricDAO;
import com.benchmark.entity.Creator;
import com.benchmark.entity.Model;
import com.benchmark.entity.ModelCompareVO;
import com.benchmark.entity.ModelMetric;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/manage")
public class ManageServlet extends HttpServlet {

    private CreatorDAO creatorDAO = new CreatorDAO();
    private ModelDAO modelDAO = new ModelDAO();
    private ModelMetricDAO metricDAO = new ModelMetricDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");

        try {
            switch (action) {
                // ---- 厂商 CRUD ----
                case "addCreator":
                    handleAddCreator(req, resp);
                    break;
                case "updateCreator":
                    handleUpdateCreator(req, resp);
                    break;
                case "deleteCreator":
                    handleDeleteCreator(req, resp);
                    break;
                // ---- 模型 CRUD ----
                case "addModel":
                    handleAddModel(req, resp);
                    break;
                case "updateModel":
                    handleUpdateModel(req, resp);
                    break;
                case "deleteModel":
                    handleDeleteModel(req, resp);
                    break;
                // ---- 指标 CRUD ----
                case "addMetric":
                    handleAddMetric(req, resp);
                    break;
                case "updateMetric":
                    handleUpdateMetric(req, resp);
                    break;
                case "deleteMetric":
                    handleDeleteMetric(req, resp);
                    break;
                default:
                    writeJson(resp, false, "未知操作: " + action);
            }
        } catch (SQLException e) {
            // 处理主键重复等数据库异常
            String msg = e.getMessage();
            if (msg != null && msg.contains("Duplicate entry")) {
                writeJson(resp, false, "主键重复，该ID已存在");
            } else if (msg != null && msg.contains("foreign key constraint")) {
                writeJson(resp, false, "操作失败：存在关联数据无法删除");
            } else {
                writeJson(resp, false, "数据库错误: " + e.getMessage());
            }
            e.printStackTrace();
        } catch (Exception e) {
            writeJson(resp, false, "操作失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        String action = req.getParameter("action");

        try {
            if ("getCreators".equals(action)) {
                List<Creator> creators = creatorDAO.findAll();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < creators.size(); i++) {
                    Creator c = creators.get(i);
                    if (i > 0) json.append(",");
                    json.append("{\"id\":\"").append(escapeJson(c.getCreatorId()))
                        .append("\",\"name\":\"").append(escapeJson(c.getCreatorName()))
                        .append("\"}");
                }
                json.append("]");
                resp.getWriter().write(json.toString());
            } else if ("getModelsWithoutMetrics".equals(action)) {
                List<com.benchmark.entity.Model> allModels = modelDAO.findAll();
                List<ModelMetric> allMetrics = metricDAO.findAll();
                Set<String> hasMetrics = allMetrics.stream()
                        .map(ModelMetric::getModelId).collect(Collectors.toSet());
                StringBuilder json = new StringBuilder("[");
                boolean first = true;
                for (com.benchmark.entity.Model m : allModels) {
                    if (!hasMetrics.contains(m.getModelId())) {
                        if (!first) json.append(",");
                        json.append("{\"id\":\"").append(escapeJson(m.getModelId()))
                            .append("\",\"name\":\"").append(escapeJson(m.getModelName()))
                            .append("\"}");
                        first = false;
                    }
                }
                json.append("]");
                resp.getWriter().write(json.toString());
            } else if ("getAllModels".equals(action)) {
                List<com.benchmark.entity.Model> allModels = modelDAO.findAll();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < allModels.size(); i++) {
                    com.benchmark.entity.Model m = allModels.get(i);
                    if (i > 0) json.append(",");
                    json.append("{\"id\":\"").append(escapeJson(m.getModelId()))
                        .append("\",\"name\":\"").append(escapeJson(m.getModelName()))
                        .append("\"}");
                }
                json.append("]");
                resp.getWriter().write(json.toString());
            } else if ("searchFullview".equals(action)) {
                Map<String, Object> params = new HashMap<>();
                String[] creatorIds = req.getParameterValues("creatorIds");
                if (creatorIds != null && creatorIds.length > 0) {
                    params.put("creatorIds", Arrays.asList(creatorIds));
                }
                String isOpen = req.getParameter("isOpenSource");
                if (isOpen != null && !isOpen.isEmpty()) params.put("isOpenSource", isOpen);
                addParam(params, req, "contextWindowMin");
                addParam(params, req, "contextWindowMax");
                addParam(params, req, "artifIntelIdxMin");
                addParam(params, req, "artifIntelIdxMax");
                addParam(params, req, "blendedPriceMin");
                addParam(params, req, "blendedPriceMax");
                addParam(params, req, "medianTokensSMin");
                addParam(params, req, "medianTokensSMax");
                addParam(params, req, "releaseDateBegin");
                addParam(params, req, "releaseDateEnd");
                String fieldExp = req.getParameter("fieldExpertise");
                if (fieldExp != null && !fieldExp.isEmpty()) params.put("fieldExpertise", fieldExp);
                String orderBy = req.getParameter("orderBy");

                List<ModelCompareVO> models = modelDAO.findAllWithMetricsByConditions(params, orderBy);
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < models.size(); i++) {
                    ModelCompareVO m = models.get(i);
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"modelId\":\"").append(escapeJson(m.getModelId())).append("\"");
                    json.append(",\"modelName\":\"").append(escapeJson(m.getModelName())).append("\"");
                    json.append(",\"creatorId\":\"").append(escapeJson(m.getCreatorId())).append("\"");
                    json.append(",\"creatorName\":\"").append(escapeJson(m.getCreatorName())).append("\"");
                    json.append(",\"contextWindow\":").append(m.getContextWindow() != null ? m.getContextWindow() : "null");
                    json.append(",\"isOpenSource\":").append(m.getIsOpenSource() != null ? m.getIsOpenSource() : "null");
                    json.append(",\"releaseDate\":\"").append(m.getReleaseDate() != null ? m.getReleaseDate().toString() : "").append("\"");
                    json.append(",\"fieldExpertise\":\"").append(escapeJson(m.getFieldExpertise())).append("\"");
                    json.append(",\"artifIntelIdx\":").append(m.getArtifIntelIdx() != null ? m.getArtifIntelIdx() : "null");
                    json.append(",\"artifOmniIdx\":").append(m.getArtifOmniIdx() != null ? m.getArtifOmniIdx() : "null");
                    json.append(",\"terminalBenchHard\":").append(m.getTerminalBenchHard() != null ? m.getTerminalBenchHard() : "null");
                    json.append(",\"aaOmniAccuracy\":").append(m.getAaOmniAccuracy() != null ? m.getAaOmniAccuracy() : "null");
                    json.append(",\"blendedPrice\":").append(m.getBlendedPrice() != null ? m.getBlendedPrice() : "null");
                    json.append(",\"medianTokensS\":").append(m.getMedianTokensS() != null ? m.getMedianTokensS() : "null");
                    json.append(",\"latencyFirstChunk\":").append(m.getLatencyFirstChunk() != null ? m.getLatencyFirstChunk() : "null");
                    json.append(",\"totalResponseTime\":").append(m.getTotalResponseTime() != null ? m.getTotalResponseTime() : "null");
                    json.append("}");
                }
                json.append("]");
                resp.getWriter().write(json.toString());
            } else {
                resp.getWriter().write("[]");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("[]");
        }
    }

    // ==================== 厂商 ====================

    private void handleAddCreator(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String creatorId = req.getParameter("creatorId");
        String creatorName = req.getParameter("creatorName");
        String description = req.getParameter("description");

        // 校验
        if (creatorId == null || creatorId.trim().isEmpty()) {
            writeJson(resp, false, "厂商ID不能为空");
            return;
        }
        if (!creatorId.matches("[a-zA-Z0-9]{1,10}")) {
            writeJson(resp, false, "厂商ID必须是1-10位字母或数字");
            return;
        }
        if (creatorName == null || creatorName.trim().isEmpty()) {
            writeJson(resp, false, "厂商名称不能为空");
            return;
        }

        Creator c = new Creator();
        c.setCreatorId(creatorId.trim());
        c.setCreatorName(creatorName.trim());
        c.setDescription(description != null ? description.trim() : null);
        creatorDAO.save(c);
        String sql = "INSERT INTO creators (creator_id, creator_name, description) VALUES ("
                + sqlStr(c.getCreatorId()) + ", " + sqlStr(c.getCreatorName()) + ", "
                + sqlStr(c.getDescription()) + ")";
        writeJson(resp, true, "厂商添加成功", sql);
    }

    private void handleUpdateCreator(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String creatorId = req.getParameter("creatorId");
        String creatorName = req.getParameter("creatorName");
        String description = req.getParameter("description");

        if (creatorName == null || creatorName.trim().isEmpty()) {
            writeJson(resp, false, "厂商名称不能为空");
            return;
        }

        Creator c = new Creator();
        c.setCreatorId(creatorId);
        c.setCreatorName(creatorName.trim());
        c.setDescription(description != null ? description.trim() : null);
        creatorDAO.update(c);
        String sql = "UPDATE creators SET creator_name = " + sqlStr(c.getCreatorName())
                + ", description = " + sqlStr(c.getDescription())
                + " WHERE creator_id = " + sqlStr(c.getCreatorId());
        writeJson(resp, true, "厂商更新成功", sql);
    }

    private void handleDeleteCreator(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String creatorId = req.getParameter("creatorId");
        if (creatorDAO.hasRelatedModels(creatorId)) {
            writeJson(resp, false, "请先删除该厂商下的所有模型");
            return;
        }
        creatorDAO.deleteById(creatorId);
        String sql = "DELETE FROM creators WHERE creator_id = " + sqlStr(creatorId);
        writeJson(resp, true, "厂商删除成功", sql);
    }

    // ==================== 模型 ====================

    private void handleAddModel(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String modelId = req.getParameter("modelId");
        String modelName = req.getParameter("modelName");
        String creatorId = req.getParameter("creatorId");

        if (modelId == null || modelId.trim().isEmpty()) {
            writeJson(resp, false, "模型ID不能为空");
            return;
        }
        if (modelName == null || modelName.trim().isEmpty()) {
            writeJson(resp, false, "模型名称不能为空");
            return;
        }
        if (creatorId == null || creatorId.trim().isEmpty()) {
            writeJson(resp, false, "请选择所属厂商");
            return;
        }

        Model m = new Model();
        m.setModelId(modelId.trim());
        m.setModelName(modelName.trim());
        m.setCreatorId(creatorId);

        String ctxStr = req.getParameter("contextWindow");
        if (ctxStr != null && !ctxStr.trim().isEmpty()) {
            m.setContextWindow(Integer.parseInt(ctxStr.trim()));
        }

        String isOpen = req.getParameter("isOpenSource");
        if ("1".equals(isOpen)) {
            m.setIsOpenSource(true);
        } else if ("0".equals(isOpen)) {
            m.setIsOpenSource(false);
        }

        String relDate = req.getParameter("releaseDate");
        if (relDate != null && !relDate.trim().isEmpty()) {
            m.setReleaseDate(Date.valueOf(relDate.trim()));
        }

        m.setFieldExpertise(req.getParameter("fieldExpertise"));
        m.setVersionUpgradeNote(req.getParameter("versionUpgradeNote"));

        modelDAO.save(m);
        String sql = "INSERT INTO models (model_id, model_name, creator_id, context_window, is_open_source, release_date, field_expertise, version_upgrade_note) VALUES ("
                + sqlStr(m.getModelId()) + ", " + sqlStr(m.getModelName()) + ", " + sqlStr(m.getCreatorId()) + ", "
                + sqlNum(m.getContextWindow()) + ", " + sqlBool(m.getIsOpenSource()) + ", "
                + sqlDate(m.getReleaseDate()) + ", " + sqlStr(m.getFieldExpertise()) + ", "
                + sqlStr(m.getVersionUpgradeNote()) + ")";
        writeJson(resp, true, "模型添加成功", sql);
    }

    private void handleUpdateModel(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String modelId = req.getParameter("modelId");
        String modelName = req.getParameter("modelName");
        String creatorId = req.getParameter("creatorId");

        if (modelName == null || modelName.trim().isEmpty()) {
            writeJson(resp, false, "模型名称不能为空");
            return;
        }
        if (creatorId == null || creatorId.trim().isEmpty()) {
            writeJson(resp, false, "请选择所属厂商");
            return;
        }

        Model m = new Model();
        m.setModelId(modelId);
        m.setModelName(modelName.trim());
        m.setCreatorId(creatorId);

        String ctxStr = req.getParameter("contextWindow");
        if (ctxStr != null && !ctxStr.trim().isEmpty()) {
            m.setContextWindow(Integer.parseInt(ctxStr.trim()));
        }

        String isOpen = req.getParameter("isOpenSource");
        if ("1".equals(isOpen)) {
            m.setIsOpenSource(true);
        } else if ("0".equals(isOpen)) {
            m.setIsOpenSource(false);
        }

        String relDate = req.getParameter("releaseDate");
        if (relDate != null && !relDate.trim().isEmpty()) {
            m.setReleaseDate(Date.valueOf(relDate.trim()));
        }

        m.setFieldExpertise(req.getParameter("fieldExpertise"));
        m.setVersionUpgradeNote(req.getParameter("versionUpgradeNote"));

        modelDAO.update(m);
        String sql = "UPDATE models SET model_name = " + sqlStr(m.getModelName())
                + ", creator_id = " + sqlStr(m.getCreatorId())
                + ", context_window = " + sqlNum(m.getContextWindow())
                + ", is_open_source = " + sqlBool(m.getIsOpenSource())
                + ", release_date = " + sqlDate(m.getReleaseDate())
                + ", field_expertise = " + sqlStr(m.getFieldExpertise())
                + ", version_upgrade_note = " + sqlStr(m.getVersionUpgradeNote())
                + " WHERE model_id = " + sqlStr(m.getModelId());
        writeJson(resp, true, "模型更新成功", sql);
    }

    private void handleDeleteModel(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String modelId = req.getParameter("modelId");
        modelDAO.deleteById(modelId);
        String sql = "DELETE FROM models WHERE model_id = " + sqlStr(modelId);
        writeJson(resp, true, "模型删除成功（关联的性能指标已同步删除）", sql);
    }

    // ==================== 指标 ====================

    private void handleAddMetric(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String modelId = req.getParameter("modelId");
        if (modelId == null || modelId.trim().isEmpty()) {
            writeJson(resp, false, "请选择模型");
            return;
        }

        ModelMetric m = new ModelMetric();
        m.setModelId(modelId);
        m.setArtifIntelIdx(getBigDecimal(req, "artifIntelIdx"));
        m.setArtifOmniIdx(getBigDecimal(req, "artifOmniIdx"));
        m.setTerminalBenchHard(getBigDecimal(req, "terminalBenchHard"));
        m.setAaOmniAccuracy(getBigDecimal(req, "aaOmniAccuracy"));

        // aa_omni_accuracy 0~100
        if (m.getAaOmniAccuracy() != null &&
                (m.getAaOmniAccuracy().compareTo(BigDecimal.ZERO) < 0 ||
                 m.getAaOmniAccuracy().compareTo(new BigDecimal("100")) > 0)) {
            writeJson(resp, false, "AA-Omni准确率必须在0~100之间");
            return;
        }

        m.setBlendedPrice(getBigDecimal(req, "blendedPrice"));
        m.setMedianTokensS(getBigDecimal(req, "medianTokensS"));
        m.setLatencyFirstChunk(getBigDecimal(req, "latencyFirstChunk"));
        m.setTotalResponseTime(getBigDecimal(req, "totalResponseTime"));

        metricDAO.save(m);
        String sql = "INSERT INTO model_metrics (model_id, artif_intel_idx, artif_omni_idx, terminal_bench_hard, aa_omni_accuracy, blended_price, median_tokens_s, latency_first_chunk, total_response_time) VALUES ("
                + sqlStr(m.getModelId()) + ", "
                + sqlNum(m.getArtifIntelIdx()) + ", " + sqlNum(m.getArtifOmniIdx()) + ", "
                + sqlNum(m.getTerminalBenchHard()) + ", " + sqlNum(m.getAaOmniAccuracy()) + ", "
                + sqlNum(m.getBlendedPrice()) + ", " + sqlNum(m.getMedianTokensS()) + ", "
                + sqlNum(m.getLatencyFirstChunk()) + ", " + sqlNum(m.getTotalResponseTime()) + ")";
        writeJson(resp, true, "指标添加成功", sql);
    }

    private void handleUpdateMetric(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String modelId = req.getParameter("modelId");

        ModelMetric m = new ModelMetric();
        m.setModelId(modelId);
        m.setArtifIntelIdx(getBigDecimal(req, "artifIntelIdx"));
        m.setArtifOmniIdx(getBigDecimal(req, "artifOmniIdx"));
        m.setTerminalBenchHard(getBigDecimal(req, "terminalBenchHard"));
        m.setAaOmniAccuracy(getBigDecimal(req, "aaOmniAccuracy"));

        if (m.getAaOmniAccuracy() != null &&
                (m.getAaOmniAccuracy().compareTo(BigDecimal.ZERO) < 0 ||
                 m.getAaOmniAccuracy().compareTo(new BigDecimal("100")) > 0)) {
            writeJson(resp, false, "AA-Omni准确率必须在0~100之间");
            return;
        }

        m.setBlendedPrice(getBigDecimal(req, "blendedPrice"));
        m.setMedianTokensS(getBigDecimal(req, "medianTokensS"));
        m.setLatencyFirstChunk(getBigDecimal(req, "latencyFirstChunk"));
        m.setTotalResponseTime(getBigDecimal(req, "totalResponseTime"));

        metricDAO.update(m);
        String sql = "UPDATE model_metrics SET artif_intel_idx = " + sqlNum(m.getArtifIntelIdx())
                + ", artif_omni_idx = " + sqlNum(m.getArtifOmniIdx())
                + ", terminal_bench_hard = " + sqlNum(m.getTerminalBenchHard())
                + ", aa_omni_accuracy = " + sqlNum(m.getAaOmniAccuracy())
                + ", blended_price = " + sqlNum(m.getBlendedPrice())
                + ", median_tokens_s = " + sqlNum(m.getMedianTokensS())
                + ", latency_first_chunk = " + sqlNum(m.getLatencyFirstChunk())
                + ", total_response_time = " + sqlNum(m.getTotalResponseTime())
                + " WHERE model_id = " + sqlStr(m.getModelId());
        writeJson(resp, true, "指标更新成功", sql);
    }

    private void handleDeleteMetric(HttpServletRequest req, HttpServletResponse resp)
            throws Exception {
        String modelId = req.getParameter("modelId");
        metricDAO.deleteById(modelId);
        String sql = "DELETE FROM model_metrics WHERE model_id = " + sqlStr(modelId);
        writeJson(resp, true, "指标删除成功", sql);
    }

    // ==================== 工具 ====================

    private BigDecimal getBigDecimal(HttpServletRequest req, String param) {
        String val = req.getParameter(param);
        if (val != null && !val.trim().isEmpty()) {
            try {
                return new BigDecimal(val.trim());
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }

    private void writeJson(HttpServletResponse resp, boolean success, String message)
            throws IOException {
        writeJson(resp, success, message, null);
    }

    private void writeJson(HttpServletResponse resp, boolean success, String message, String sql)
            throws IOException {
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":").append(success);
        json.append(",\"message\":\"").append(escapeJson(message)).append("\"");
        if (sql != null) {
            json.append(",\"sql\":\"").append(escapeJson(sql)).append("\"");
        }
        json.append("}");
        resp.getWriter().write(json.toString());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private void addParam(Map<String, Object> params, HttpServletRequest req, String name) {
        String val = req.getParameter(name);
        if (val != null && !val.trim().isEmpty()) {
            params.put(name, val.trim());
        }
    }

    // ==================== SQL 显示辅助方法 ====================

    private String sqlStr(String s) {
        return s != null ? "'" + s.replace("'", "''") + "'" : "NULL";
    }
    private String sqlNum(Number n) {
        return n != null ? n.toString() : "NULL";
    }
    private String sqlBool(Boolean b) {
        return b != null ? (b ? "1" : "0") : "NULL";
    }
    private String sqlDate(java.sql.Date d) {
        return d != null ? "'" + d.toString() + "'" : "NULL";
    }
}
