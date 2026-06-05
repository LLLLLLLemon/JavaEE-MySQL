package com.benchmark.dao;

import com.benchmark.entity.ModelMetric;

import java.sql.ResultSet;

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
}
