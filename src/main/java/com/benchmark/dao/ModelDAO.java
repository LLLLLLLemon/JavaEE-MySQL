package com.benchmark.dao;

import com.benchmark.entity.Model;
import com.benchmark.entity.ModelCompareVO;
import com.benchmark.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ModelDAO extends BaseDAO<Model> {
    @Override
    protected String getTableName() {
        return "models";
    }

    @Override
    protected Model mapRow(ResultSet rs) throws Exception {
        Model m = new Model();
        m.setModelId(rs.getString("model_id"));
        m.setModelName(rs.getString("model_name"));
        m.setCreatorId(rs.getString("creator_id"));
        m.setContextWindow(rs.getObject("context_window") != null ? rs.getInt("context_window") : null);
        m.setIsOpenSource(rs.getObject("is_open_source") != null ? rs.getBoolean("is_open_source") : null);
        m.setReleaseDate(rs.getDate("release_date"));
        m.setFieldExpertise(rs.getString("field_expertise"));
        m.setVersionUpgradeNote(rs.getString("version_upgrade_note"));
        return m;
    }

    /** 新增模型 */
    public void save(Model m) throws SQLException {
        String sql = "INSERT INTO models (model_id, model_name, creator_id, context_window, is_open_source, release_date, field_expertise, version_upgrade_note) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getModelId());
            ps.setString(2, m.getModelName());
            ps.setString(3, m.getCreatorId());
            setInt(ps, 4, m.getContextWindow());
            setBoolean(ps, 5, m.getIsOpenSource());
            if (m.getReleaseDate() != null) {
                ps.setDate(6, m.getReleaseDate());
            } else {
                ps.setNull(6, java.sql.Types.DATE);
            }
            ps.setString(7, m.getFieldExpertise());
            ps.setString(8, m.getVersionUpgradeNote());
            ps.executeUpdate();
        }
    }

    /** 更新模型（不修改model_id） */
    public void update(Model m) throws SQLException {
        String sql = "UPDATE models SET model_name=?, creator_id=?, context_window=?, is_open_source=?, release_date=?, field_expertise=?, version_upgrade_note=? WHERE model_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getModelName());
            ps.setString(2, m.getCreatorId());
            setInt(ps, 3, m.getContextWindow());
            setBoolean(ps, 4, m.getIsOpenSource());
            if (m.getReleaseDate() != null) {
                ps.setDate(5, m.getReleaseDate());
            } else {
                ps.setNull(5, java.sql.Types.DATE);
            }
            ps.setString(6, m.getFieldExpertise());
            ps.setString(7, m.getVersionUpgradeNote());
            ps.setString(8, m.getModelId());
            ps.executeUpdate();
        }
    }

    /** 删除模型（CASCADE会同时删除关联指标） */
    public void deleteById(String modelId) throws SQLException {
        String sql = "DELETE FROM models WHERE model_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, modelId);
            ps.executeUpdate();
        }
    }

    /**
     * 高级条件查询 + 排序
     * @param params 查询条件Map，支持：creatorIds(List), isOpenSource(String), contextWindowMin/Max,
     *               artifIntelIdxMin/Max, blendedPriceMin/Max, medianTokensSMin/Max,
     *               releaseDateBegin/End, fieldExpertise(String)
     * @param orderBy 排序字段（如 "artif_intel_idx DESC"）
     */
    public List<Model> findByConditions(Map<String, Object> params, String orderBy) {
        List<Model> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT m.* FROM models m LEFT JOIN model_metrics mt ON m.model_id = mt.model_id WHERE 1=1");
        List<Object> paramValues = new ArrayList<>();

        // 厂商多选
        @SuppressWarnings("unchecked")
        List<String> creatorIds = (List<String>) params.get("creatorIds");
        if (creatorIds != null && !creatorIds.isEmpty()) {
            sql.append(" AND m.creator_id IN (");
            for (int i = 0; i < creatorIds.size(); i++) {
                sql.append(i > 0 ? ",?" : "?");
                paramValues.add(creatorIds.get(i));
            }
            sql.append(")");
        }

        // 开源状态
        String isOpenSource = (String) params.get("isOpenSource");
        if ("open".equals(isOpenSource)) {
            sql.append(" AND m.is_open_source = 1");
        } else if ("closed".equals(isOpenSource)) {
            sql.append(" AND m.is_open_source = 0");
        }

        // 上下文范围
        addRangeCondition(sql, paramValues, "m.context_window",
                params.get("contextWindowMin"), params.get("contextWindowMax"));

        // 智力指数
        addRangeCondition(sql, paramValues, "mt.artif_intel_idx",
                params.get("artifIntelIdxMin"), params.get("artifIntelIdxMax"));

        // 价格
        addRangeCondition(sql, paramValues, "mt.blended_price",
                params.get("blendedPriceMin"), params.get("blendedPriceMax"));

        // 吞吐量
        addRangeCondition(sql, paramValues, "mt.median_tokens_s",
                params.get("medianTokensSMin"), params.get("medianTokensSMax"));

        // 发布日期
        addRangeCondition(sql, paramValues, "m.release_date",
                params.get("releaseDateBegin"), params.get("releaseDateEnd"));

        // 擅长领域模糊匹配
        String fieldExpertise = (String) params.get("fieldExpertise");
        if (fieldExpertise != null && !fieldExpertise.trim().isEmpty()) {
            sql.append(" AND m.field_expertise LIKE ?");
            paramValues.add("%" + fieldExpertise.trim() + "%");
        }

        // 排序
        if (orderBy != null && !orderBy.trim().isEmpty()) {
            sql.append(" ORDER BY ").append(orderBy);
        }

        System.out.println("[DEBUG] 高级查询SQL: " + sql);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < paramValues.size(); i++) {
                ps.setObject(i + 1, paramValues.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 高级查询失败: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 带条件筛选+排序的综合表查询（JOIN三表）
     * @param params 查询条件Map，同 findByConditions
     * @param orderBy 排序字段（如 "mt.artif_intel_idx DESC"）
     */
    public List<ModelCompareVO> findAllWithMetricsByConditions(Map<String, Object> params, String orderBy) {
        List<ModelCompareVO> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT m.*, c.creator_name, mt.artif_intel_idx, mt.artif_omni_idx, " +
            "mt.terminal_bench_hard, mt.aa_omni_accuracy, mt.blended_price, " +
            "mt.median_tokens_s, mt.latency_first_chunk, mt.total_response_time " +
            "FROM models m " +
            "LEFT JOIN creators c ON m.creator_id = c.creator_id " +
            "LEFT JOIN model_metrics mt ON m.model_id = mt.model_id WHERE 1=1");
        List<Object> paramValues = new ArrayList<>();

        // 厂商多选
        @SuppressWarnings("unchecked")
        List<String> creatorIds = (List<String>) params.get("creatorIds");
        if (creatorIds != null && !creatorIds.isEmpty()) {
            sql.append(" AND m.creator_id IN (");
            for (int i = 0; i < creatorIds.size(); i++) {
                sql.append(i > 0 ? ",?" : "?");
                paramValues.add(creatorIds.get(i));
            }
            sql.append(")");
        }

        // 开源状态
        String isOpenSource = (String) params.get("isOpenSource");
        if ("open".equals(isOpenSource)) {
            sql.append(" AND m.is_open_source = 1");
        } else if ("closed".equals(isOpenSource)) {
            sql.append(" AND m.is_open_source = 0");
        }

        // 上下文范围
        addRangeCondition(sql, paramValues, "m.context_window",
                params.get("contextWindowMin"), params.get("contextWindowMax"));
        // 智力指数
        addRangeCondition(sql, paramValues, "mt.artif_intel_idx",
                params.get("artifIntelIdxMin"), params.get("artifIntelIdxMax"));
        // 价格
        addRangeCondition(sql, paramValues, "mt.blended_price",
                params.get("blendedPriceMin"), params.get("blendedPriceMax"));
        // 吞吐量
        addRangeCondition(sql, paramValues, "mt.median_tokens_s",
                params.get("medianTokensSMin"), params.get("medianTokensSMax"));
        // 发布日期
        addRangeCondition(sql, paramValues, "m.release_date",
                params.get("releaseDateBegin"), params.get("releaseDateEnd"));

        // 擅长领域模糊匹配
        String fieldExpertise = (String) params.get("fieldExpertise");
        if (fieldExpertise != null && !fieldExpertise.trim().isEmpty()) {
            sql.append(" AND m.field_expertise LIKE ?");
            paramValues.add("%" + fieldExpertise.trim() + "%");
        }

        // 排序
        if (orderBy != null && !orderBy.trim().isEmpty()) {
            sql.append(" ORDER BY ").append(orderBy);
        } else {
            sql.append(" ORDER BY c.creator_name, m.model_name");
        }

        System.out.println("[DEBUG] 综合表条件查询SQL: " + sql);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < paramValues.size(); i++) {
                ps.setObject(i + 1, paramValues.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapToCompareVO(rs));
                }
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 综合表条件查询失败: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /** 查询所有模型+指标（用于综合表，JOIN三表） */
    public List<ModelCompareVO> findAllWithMetrics() {
        List<ModelCompareVO> list = new ArrayList<>();
        String sql = "SELECT m.*, c.creator_name, mt.artif_intel_idx, mt.artif_omni_idx, " +
                "mt.terminal_bench_hard, mt.aa_omni_accuracy, mt.blended_price, " +
                "mt.median_tokens_s, mt.latency_first_chunk, mt.total_response_time " +
                "FROM models m " +
                "LEFT JOIN creators c ON m.creator_id = c.creator_id " +
                "LEFT JOIN model_metrics mt ON m.model_id = mt.model_id " +
                "ORDER BY c.creator_name, m.model_name";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapToCompareVO(rs));
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 综合表查询失败: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    private ModelCompareVO mapToCompareVO(ResultSet rs) throws Exception {
        ModelCompareVO vo = new ModelCompareVO();
        vo.setModelId(rs.getString("model_id"));
        vo.setModelName(rs.getString("model_name"));
        vo.setCreatorId(rs.getString("creator_id"));
        vo.setCreatorName(rs.getString("creator_name"));
        vo.setContextWindow(rs.getObject("context_window") != null ? rs.getInt("context_window") : null);
        vo.setIsOpenSource(rs.getObject("is_open_source") != null ? rs.getBoolean("is_open_source") : null);
        vo.setReleaseDate(rs.getDate("release_date"));
        vo.setFieldExpertise(rs.getString("field_expertise"));
        vo.setArtifIntelIdx(rs.getBigDecimal("artif_intel_idx"));
        vo.setArtifOmniIdx(rs.getBigDecimal("artif_omni_idx"));
        vo.setTerminalBenchHard(rs.getBigDecimal("terminal_bench_hard"));
        vo.setAaOmniAccuracy(rs.getBigDecimal("aa_omni_accuracy"));
        vo.setBlendedPrice(rs.getBigDecimal("blended_price"));
        vo.setMedianTokensS(rs.getBigDecimal("median_tokens_s"));
        vo.setLatencyFirstChunk(rs.getBigDecimal("latency_first_chunk"));
        vo.setTotalResponseTime(rs.getBigDecimal("total_response_time"));
        return vo;
    }

    /** 根据ID列表批量查询模型+指标（用于对比功能，JOIN三表） */
    public List<ModelCompareVO> findModelsByIds(List<String> ids) {
        List<ModelCompareVO> list = new ArrayList<>();
        if (ids == null || ids.isEmpty()) return list;

        StringBuilder sql = new StringBuilder(
                "SELECT m.*, c.creator_name, mt.artif_intel_idx, mt.artif_omni_idx, " +
                "mt.terminal_bench_hard, mt.aa_omni_accuracy, mt.blended_price, " +
                "mt.median_tokens_s, mt.latency_first_chunk, mt.total_response_time " +
                "FROM models m " +
                "LEFT JOIN creators c ON m.creator_id = c.creator_id " +
                "LEFT JOIN model_metrics mt ON m.model_id = mt.model_id " +
                "WHERE m.model_id IN (");
        for (int i = 0; i < ids.size(); i++) {
            sql.append(i > 0 ? ",?" : "?");
        }
        sql.append(")");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < ids.size(); i++) {
                ps.setString(i + 1, ids.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ModelCompareVO vo = new ModelCompareVO();
                    vo.setModelId(rs.getString("model_id"));
                    vo.setModelName(rs.getString("model_name"));
                    vo.setCreatorId(rs.getString("creator_id"));
                    vo.setCreatorName(rs.getString("creator_name"));
                    vo.setContextWindow(rs.getObject("context_window") != null ? rs.getInt("context_window") : null);
                    vo.setIsOpenSource(rs.getObject("is_open_source") != null ? rs.getBoolean("is_open_source") : null);
                    vo.setReleaseDate(rs.getDate("release_date"));
                    vo.setFieldExpertise(rs.getString("field_expertise"));
                    vo.setArtifIntelIdx(rs.getBigDecimal("artif_intel_idx"));
                    vo.setArtifOmniIdx(rs.getBigDecimal("artif_omni_idx"));
                    vo.setTerminalBenchHard(rs.getBigDecimal("terminal_bench_hard"));
                    vo.setAaOmniAccuracy(rs.getBigDecimal("aa_omni_accuracy"));
                    vo.setBlendedPrice(rs.getBigDecimal("blended_price"));
                    vo.setMedianTokensS(rs.getBigDecimal("median_tokens_s"));
                    vo.setLatencyFirstChunk(rs.getBigDecimal("latency_first_chunk"));
                    vo.setTotalResponseTime(rs.getBigDecimal("total_response_time"));
                    list.add(vo);
                }
            }
        } catch (Exception e) {
            System.err.println("[ERROR] 模型对比查询失败: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // ---- 辅助方法 ----

    private void addRangeCondition(StringBuilder sql, List<Object> params, String column, Object min, Object max) {
        if (min != null && !min.toString().trim().isEmpty()) {
            sql.append(" AND ").append(column).append(" >= ?");
            params.add(parseNumber(min));
        }
        if (max != null && !max.toString().trim().isEmpty()) {
            sql.append(" AND ").append(column).append(" <= ?");
            params.add(parseNumber(max));
        }
    }

    private Object parseNumber(Object val) {
        if (val instanceof Number) return val;
        String s = val.toString().trim();
        try {
            if (s.contains(".")) return Double.parseDouble(s);
            return Integer.parseInt(s);
        } catch (NumberFormatException e) {
            return s; // 日期字符串等直接返回
        }
    }

    private void setInt(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val != null) {
            ps.setInt(idx, val);
        } else {
            ps.setNull(idx, java.sql.Types.INTEGER);
        }
    }

    private void setBoolean(PreparedStatement ps, int idx, Boolean val) throws SQLException {
        if (val != null) {
            ps.setBoolean(idx, val);
        } else {
            ps.setNull(idx, java.sql.Types.BOOLEAN);
        }
    }
}
