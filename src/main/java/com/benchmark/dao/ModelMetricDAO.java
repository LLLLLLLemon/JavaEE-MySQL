package com.benchmark.dao;

import com.benchmark.entity.ModelMetric;
import com.benchmark.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ModelMetricDAO extends BaseDAO<ModelMetric> {
    @Override
    protected String getTableName() {
        return "model_metrics";
    }

    @Override
    protected ModelMetric mapRow(ResultSet rs) throws Exception {
        ModelMetric m = new ModelMetric();
        m.setModelId(rs.getString("model_id"));
        m.setArtifIntelIdx(rs.getBigDecimal("artif_intel_idx"));
        m.setArtifOmniIdx(rs.getBigDecimal("artif_omni_idx"));
        m.setTerminalBenchHard(rs.getBigDecimal("terminal_bench_hard"));
        m.setAaOmniAccuracy(rs.getBigDecimal("aa_omni_accuracy"));
        m.setBlendedPrice(rs.getBigDecimal("blended_price"));
        m.setMedianTokensS(rs.getBigDecimal("median_tokens_s"));
        m.setLatencyFirstChunk(rs.getBigDecimal("latency_first_chunk"));
        m.setTotalResponseTime(rs.getBigDecimal("total_response_time"));
        return m;
    }

    /** 新增指标 */
    public void save(ModelMetric m) throws SQLException {
        String sql = "INSERT INTO model_metrics (model_id, artif_intel_idx, artif_omni_idx, terminal_bench_hard, aa_omni_accuracy, blended_price, median_tokens_s, latency_first_chunk, total_response_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getModelId());
            setBigDecimal(ps, 2, m.getArtifIntelIdx());
            setBigDecimal(ps, 3, m.getArtifOmniIdx());
            setBigDecimal(ps, 4, m.getTerminalBenchHard());
            setBigDecimal(ps, 5, m.getAaOmniAccuracy());
            setBigDecimal(ps, 6, m.getBlendedPrice());
            setBigDecimal(ps, 7, m.getMedianTokensS());
            setBigDecimal(ps, 8, m.getLatencyFirstChunk());
            setBigDecimal(ps, 9, m.getTotalResponseTime());
            ps.executeUpdate();
        }
    }

    /** 更新指标 */
    public void update(ModelMetric m) throws SQLException {
        String sql = "UPDATE model_metrics SET artif_intel_idx=?, artif_omni_idx=?, terminal_bench_hard=?, aa_omni_accuracy=?, blended_price=?, median_tokens_s=?, latency_first_chunk=?, total_response_time=? WHERE model_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            setBigDecimal(ps, 1, m.getArtifIntelIdx());
            setBigDecimal(ps, 2, m.getArtifOmniIdx());
            setBigDecimal(ps, 3, m.getTerminalBenchHard());
            setBigDecimal(ps, 4, m.getAaOmniAccuracy());
            setBigDecimal(ps, 5, m.getBlendedPrice());
            setBigDecimal(ps, 6, m.getMedianTokensS());
            setBigDecimal(ps, 7, m.getLatencyFirstChunk());
            setBigDecimal(ps, 8, m.getTotalResponseTime());
            ps.setString(9, m.getModelId());
            ps.executeUpdate();
        }
    }

    /** 删除指标 */
    public void deleteById(String modelId) throws SQLException {
        String sql = "DELETE FROM model_metrics WHERE model_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, modelId);
            ps.executeUpdate();
        }
    }

    /** 辅助：设置可空BigDecimal */
    private void setBigDecimal(PreparedStatement ps, int idx, java.math.BigDecimal val) throws SQLException {
        if (val != null) {
            ps.setBigDecimal(idx, val);
        } else {
            ps.setNull(idx, java.sql.Types.DECIMAL);
        }
    }
}
