package com.benchmark.entity;

import java.math.BigDecimal;

public class ModelMetric {
    private String modelId;
    private BigDecimal artifIntelIdx;
    private BigDecimal artifOmniIdx;
    private BigDecimal terminalBenchHard;
    private BigDecimal aaOmniAccuracy;
    private BigDecimal blendedPrice;
    private BigDecimal medianTokensS;
    private BigDecimal latencyFirstChunk;
    private BigDecimal totalResponseTime;

    public String getModelId() { return modelId; }
    public void setModelId(String modelId) { this.modelId = modelId; }
    public BigDecimal getArtifIntelIdx() { return artifIntelIdx; }
    public void setArtifIntelIdx(BigDecimal artifIntelIdx) { this.artifIntelIdx = artifIntelIdx; }
    public BigDecimal getArtifOmniIdx() { return artifOmniIdx; }
    public void setArtifOmniIdx(BigDecimal artifOmniIdx) { this.artifOmniIdx = artifOmniIdx; }
    public BigDecimal getTerminalBenchHard() { return terminalBenchHard; }
    public void setTerminalBenchHard(BigDecimal terminalBenchHard) { this.terminalBenchHard = terminalBenchHard; }
    public BigDecimal getAaOmniAccuracy() { return aaOmniAccuracy; }
    public void setAaOmniAccuracy(BigDecimal aaOmniAccuracy) { this.aaOmniAccuracy = aaOmniAccuracy; }
    public BigDecimal getBlendedPrice() { return blendedPrice; }
    public void setBlendedPrice(BigDecimal blendedPrice) { this.blendedPrice = blendedPrice; }
    public BigDecimal getMedianTokensS() { return medianTokensS; }
    public void setMedianTokensS(BigDecimal medianTokensS) { this.medianTokensS = medianTokensS; }
    public BigDecimal getLatencyFirstChunk() { return latencyFirstChunk; }
    public void setLatencyFirstChunk(BigDecimal latencyFirstChunk) { this.latencyFirstChunk = latencyFirstChunk; }
    public BigDecimal getTotalResponseTime() { return totalResponseTime; }
    public void setTotalResponseTime(BigDecimal totalResponseTime) { this.totalResponseTime = totalResponseTime; }
}
